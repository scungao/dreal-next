#include <sys/stat.h>
#include <ezOptionParser/ezOptionParser.hpp>
#include <algorithm>
#include <cassert>
#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <exception>
#include <fstream>
#include <iostream>
#include <limits>
#include <list>
#include <sstream>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>
#include "./config.h"
#include "./version.h"
#include "opensmt/api/OpenSMTContext.h"
#include "opensmt/egraph/Enode.h"
#include "tools/inv/config.h"
#include "util/subst_enode.h"
#include "tools/inv/inv.h"
#include "util/logging.h"
#include "util/string.h"

using std::back_inserter;
using std::cerr;
using std::cout;
using std::copy;
using std::endl;
using std::list;
using std::numeric_limits;
using std::ofstream;
using std::pair;
using std::runtime_error;
using std::sort;
using std::string;
using std::unordered_map;
using std::vector;
using std::stringstream;
using std::ostream;

//Parser
extern int invset_in(FILE * fin);
extern int invparse();
extern int invlex_destroy();
extern void inv_init_parser();
extern void inv_cleanup_parser();

extern OpenSMTContext * inv_ctx;
extern double inv_prec; 
extern unordered_map<Enode*,Enode*> inv_plant;
extern unordered_map<string, Enode*> inv_var_map;
extern Enode * inv_barrier;
extern Enode * inv_barrierD;

namespace inv {

static const char g_minimum_name[] = "min";

Enode * subst_exist_vars_to_univerally_quantified(OpenSMTContext & ctx, unordered_map<string, Enode *> const & m, Enode * f) {
    // Input:  f(x1, ..., xn) where xi is existentially quantified var.
    // Output: f(y1, ..., yn) where yi is universally quantified var.
    unordered_map<Enode *, Enode *> subst_map;
    // 1. need to create a mapping from exist variables to forall variables
    Snode * const real_sort = ctx.mkSortReal();
    for (auto const & p : m) {
        string const name = p.first;
        string const forall_var_name = string("forall_") + name;
        Enode * exist_var = p.second;
        double const lb = exist_var->getDomainLowerBound();
        double const ub = exist_var->getDomainUpperBound();
        ctx.DeclareFun(forall_var_name.c_str(), real_sort);
        Enode * const forall_var = ctx.mkVar(forall_var_name.c_str(), true);
        forall_var->setForallVar();
        forall_var->setDomainLowerBound(lb);
        forall_var->setDomainUpperBound(ub);
        forall_var->setValueLowerBound(lb);
        forall_var->setValueUpperBound(ub);
        subst_map.emplace(exist_var, forall_var);
    }
    // 2. need to make f(y1, y2) based on f(x1, x2)
    Enode * forall_f = dreal::subst(ctx, f, subst_map);
    return forall_f;
}

Enode * make_leq_cost(OpenSMTContext & ctx, unordered_map<string, Enode *> const & m, Enode * f, Enode * min_var) {
    // Input:  f(x1, ..., xn)        where xi is existentially quantified var.
    // Output: min <= f(y1, ..., yn) where yi is universally quantified var.
    Enode * forall_f = subst_exist_vars_to_univerally_quantified(ctx, m, f);
    Enode * const args_list = ctx.mkCons(min_var, ctx.mkCons(forall_f));
    Enode * const leq = ctx.mkLeq(args_list);
    return leq;
}

Enode * make_min_var(OpenSMTContext & ctx, unordered_map<string, Enode *> & m, unsigned int i) {
    stringstream ss;
    Snode * const real_sort = ctx.mkSortReal();
    ss << g_minimum_name << "_" << i;
    string name = ss.str();
    ctx.DeclareFun(name.c_str(), real_sort);
    Enode * const min_var = ctx.mkVar(name.c_str(), true);
    min_var->setDomainLowerBound(numeric_limits<double>::lowest());
    min_var->setDomainUpperBound(numeric_limits<double>::max());
    m.emplace(name, min_var);
    return min_var;
}

Enode * make_eq_cost(OpenSMTContext & ctx, Enode * e1, Enode * e2) {
    Enode * const eq = ctx.mkEq(ctx.mkCons(e1, ctx.mkCons(e2)));
    return eq;
}

ostream & display(ostream & out, string const & name, Enode * const e) {
    out << name << " = "
        << "[" << e->getValueLowerBound() << ", "
        << e->getValueUpperBound() << "]";
    return out;
}

void print_result(unordered_map<string, Enode*> const & map) {
    vector<pair<string, Enode*>> vec;
    vec.insert(vec.end(), map.begin(), map.end());
    sort(vec.begin(), vec.end(), [](pair<string, Enode *> const & p1, pair<string, Enode *> const & p2) {
            bool const p1_starts_with_min = dreal::starts_with(p1.first, g_minimum_name);
            bool const p2_starts_with_min = dreal::starts_with(p2.first, g_minimum_name);
            if (p1_starts_with_min && !p2_starts_with_min) {
                return false;
            }
            if (!p1_starts_with_min && p2_starts_with_min) {
                return true;
            }
            return p1.first < p2.first;
        });
    for (auto const item : vec) {
        string name = item.first;
        Enode * e = item.second;
        cout << "\t"; inv::display(cout, name, e) << endl;
    }
}

Enode * make_vec_to_list(OpenSMTContext & ctx, vector<Enode *> v) {
    list<Enode*> args(v.begin(), v.end());
    return ctx.mkCons(args);
}

int process_main(OpenSMTContext & ctx,
                 config const & config) {
    Enode * pre = ctx.mkEq(ctx.mkCons(inv_barrier, ctx.mkCons(ctx.mkNum("0"))));
    Enode * post = ctx.mkLeq(ctx.mkCons(inv_barrierD, ctx.mkCons(ctx.mkNum("-0.001"))));
    Enode * formula = ctx.mkNot(ctx.mkCons(ctx.mkImplies(ctx.mkCons(pre,ctx.mkCons(post)))));
    ctx.Assert(formula);
    auto result = ctx.CheckSAT();
    cout << "Result     : ";
    if (result == l_True) {
        cout << "delta-sat" << endl;
    } else {
        cout << "unsat" << endl;
    }
    return 0;
}

int process_inv(config const & config) {
    FILE * fin = nullptr;
    string filename = config.get_filename();
    // Make sure file exists
    if ((fin = fopen(filename.c_str(), "rt")) == nullptr) {
        opensmt_error2("can't open file", filename.c_str());
    }
    ::invset_in(fin);
    ::inv_init_parser();
    ::invparse();
    OpenSMTContext & ctx = *inv_ctx;
    if (inv_prec > 0) {
        ctx.setPrecision(inv_prec);
    }
    if (config.get_precision() > 0) {
        ctx.setPrecision(config.get_precision());
    }
    int const ret = process_main(ctx, config);
    ::invlex_destroy();
    fclose(fin);
    ::inv_cleanup_parser();
    return ret;
}

}//namespace inv

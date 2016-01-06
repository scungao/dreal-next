#include <string>
#include <exception>
#include "tools/lypsyn/var_map.h"

namespace lypsyn {

using std::string;
using std::runtime_error;
using std::cerr;
using std::endl;

double var_map::pop_num() {
    double const v = m_double_vec.back();
    m_double_vec.pop_back();
    return v;
}

void var_map::push_num(double const n) { m_double_vec.push_back(n); }

void var_map::push_id(string const & name) { m_str = name; }

void var_map::set_lb() {
    double const lb = m_double_vec.back();
    auto it = m_map.find(m_str);
    assert(it != m_map.end());
    Enode * const e = it->second;
    e->setDomainLowerBound(lb);
    e->setValueLowerBound(lb);
    m_double_vec.pop_back();
    cerr << "set_lb: " << e << " " << lb << endl;
}

void var_map::set_ub() {
    double const ub = m_double_vec.back();
    auto it = m_map.find(m_str);
    assert(it != m_map.end());
    Enode * const e = it->second;
    e->setDomainUpperBound(ub);
    e->setValueUpperBound(ub);
    m_double_vec.pop_back();
    cerr << "set_ub: " << e << " " << ub << endl;
}

void var_map::push_var_decl() {
    Snode * const sort = m_ctx.mkSortReal();
    m_ctx.DeclareFun(m_str.c_str(), sort);
    Enode * const e = m_ctx.mkVar(m_str.c_str(), true);
    m_map.emplace(m_str, e);
    cerr << "push_var_decl: " << e << endl;
    if (m_double_vec.size() == 2) {
        set_ub();
        set_lb();
    }
}

Enode * var_map::find(string const & name) const {
    auto it = m_map.find(name);
    if (it != m_map.end()) {
        return it->second;
    }
    return nullptr;
}
}

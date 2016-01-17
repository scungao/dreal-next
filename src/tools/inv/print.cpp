#include <iostream>
#include <string>
#include <functional>
#include "opensmt/egraph/Enode.h"

namespace inv {

using std::ostream;
using std::string;
using std::function;

ostream & print_infix_op(ostream & out, Enode * const e, string const & op, std::function<ostream & (ostream &, Enode * const)> const & f) {
    assert(e->getArity() >= 2);
    out << "(";
    f(out, e->get1st());
    Enode * tmp = e->getCdr()->getCdr();
    while (!tmp->isEnil()) {
        out << " " << op << " ";
        f(out, tmp->getCar());
        tmp = tmp->getCdr();
    }
    out << ")";
    return out;
}

ostream & print_call(ostream & out, Enode * const e, string const & fname,
                     std::function<ostream & (ostream &, Enode * const)> const & f, string const & lp, string const & rp) {
    assert(e->getArity() >= 1);
    out << fname;
    out << lp;
    f(out, e->get1st());
    Enode * tmp = e->getCdr()->getCdr();
    while (!tmp->isEnil()) {
        out << ", ";
        f(out, tmp->getCar());
        tmp = tmp->getCdr();
    }
    out << rp;
    return out;
}

ostream & print_call_bar(ostream & out, Enode * const e, string const & fname, std::function<ostream & (ostream &, Enode * const)> const & f) {
    return print_call(out, e, fname, f, "\\|", "\\|");
}

ostream & print_call_brace(ostream & out, Enode * const e, string const & fname, std::function<ostream & (ostream &, Enode * const)> const & f) {
    return print_call(out, e, fname, f, "{", "}");
}

ostream & print_call_paren(ostream & out, Enode * const e, string const & fname, std::function<ostream & (ostream &, Enode * const)> const & f) {
    return print_call(out, e, fname, f, "(", ")");
}

}  

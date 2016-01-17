#pragma once
#include <iostream>
#include <string>
#include <functional>
#include "opensmt/egraph/Enode.h"

namespace lypsyn {

std::ostream & print_infix_op(std::ostream & out, Enode * const e, std::string const & op, std::function<std::ostream & (std::ostream &, Enode * const)> const & f);
std::ostream & print_call_bar(std::ostream & out, Enode * const e, std::string const & fname, std::function<std::ostream & (std::ostream &, Enode * const)> const & f);
std::ostream & print_call_brace(std::ostream & out, Enode * const e, std::string const & fname, std::function<std::ostream & (std::ostream &, Enode * const)> const & f);
std::ostream & print_call_paren(std::ostream & out, Enode * const e, std::string const & fname, std::function<std::ostream & (std::ostream &, Enode * const)> const & f);

}

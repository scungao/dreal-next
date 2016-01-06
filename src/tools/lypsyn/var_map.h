#pragma once
#include <string>
#include <unordered_map>
#include <vector>
#include "opensmt/egraph/Enode.h"
#include "opensmt/api/OpenSMTContext.h"

namespace lypsyn {

class var_map {
private:
    OpenSMTContext & m_ctx;
    std::string m_str;
    std::vector<double> m_double_vec;
    std::vector<std::string> m_vec_str;
    std::unordered_map<std::string, Enode*> m_map;

public:
    explicit var_map(OpenSMTContext & ctx) : m_ctx(ctx) { }
    double pop_num();
    void push_num(double const n);
    void push_id(std::string const & name);
    void set_lb();
    void set_ub();
    void push_var_decl();
    Enode * find(std::string const & name) const;
    std::unordered_map<std::string, Enode*> get_var_map() const { return m_map; }
};

} 


#pragma once
#include <cassert>
#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include "opensmt/egraph/Enode.h"
#include "ezOptionParser/ezOptionParser.hpp"

namespace inv {

class config {
private:
    std::string m_filename;
    unsigned long m_vis_cell = 50.0;
    bool m_run_visualization = false;
    bool m_save_visualization = false;
    bool m_local_opt = false;
    bool m_debug = false;
    bool m_polytope = false;
    double m_prec = 0.0;
    bool m_sync = true;
    bool m_stat = false;
    bool m_worklist_fp = false;

    void printUsage(ez::ezOptionParser & opt);
    void set_filename(std::string const & filename) { m_filename = filename; }
    void set_run_visualization(bool const b) { m_run_visualization = b; }
    void set_save_visualization(bool const b) { m_save_visualization = b; }
    void set_vis_cell(unsigned long const vis_cell) { m_vis_cell = vis_cell; }
    void set_precision(double const prec) { m_prec = prec; }
    void set_local_opt(bool const b) { m_local_opt = b; }
    void set_debug(bool const b) { m_debug = b; }
    void set_polytope(bool const b) { m_polytope = b; }
    void set_sync(bool const b) { m_sync = b; }
    void set_stat(bool const b) { m_stat = b; }
    void set_worklist_fp(bool const b) { m_worklist_fp = b; }

public:
    config(int const argc, const char * argv[]);
    std::string get_filename() const { return m_filename; }
    unsigned long get_vis_cell() const { return m_vis_cell; }
    bool get_run_visualization() const { return m_run_visualization; }
    bool get_save_visualization() const { return m_save_visualization; }
    double get_precision() const {
        return m_prec;
    }
    bool get_local_opt() const { return m_local_opt; }
    bool get_debug() const { return m_debug; }
    bool get_polytope() const { return m_polytope; }
    bool get_sync() const { return m_sync; }
    bool get_stat() const { return m_stat; }
    bool get_worklist_fp() const { return m_worklist_fp; }
    friend std::ostream & operator<<(std::ostream & out, config const & c);
};

std::ostream & operator<<(std::ostream & out, config const & c);

}  // namespace dop

#include "tools/inv/config.h"
#include <sys/stat.h>
#include <cassert>
#include <algorithm>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>

namespace inv {

using std::cerr;
using std::cout;
using std::endl;
using std::ostream;
using std::string;
using std::vector;

void config::printUsage(ez::ezOptionParser & opt) {
        string usage;
        opt.getUsage(usage, 160);
        cout << usage;
        exit(1);
}

config::config(int const argc, const char * argv[]) {
    ez::ezOptionParser opt;
    opt.add("", false, 0, 0,
            "Display usage instructions.",
            "-h", "-help", "--help", "--usage");
    opt.add("", false, 0, 0,
            "visualize the result",
            "--run-visualization", "--run-vis");
    opt.add("", false, 0, 0,
            "save Python visualization code",
            "--save-visualization", "--save-vis");
    opt.add("", false, 1, 0,
            "[visualization] # of cells in one dimension",
            "--vis-cell");
    opt.add("", false, 1, 0,
            "set precision (default 0.001)\n"
            "this overrides the value specified in input files",
            "--precision");
    opt.add("", false, 0, 0,
            "use local optimization to refine counterexamples",
            "--local-opt");
    opt.add("", false, 0, 0,
            "show debug information",
            "--debug");
    opt.add("", false, 0, 0,
            "use polytope contractor",
            "--polytope");
    opt.add("", false, 0, 0,
            "NO sync the domains of forall variables using corresponding existential variables",
            "--no-sync");
    opt.add("", false, 0, 0,
            "Use worklist fixed-point algorithm in solving",
            "--worklist-fp");
    opt.add("", false, 0, 0,
            "print out statistics",
            "--stat");
    opt.parse(argc, argv);
    opt.overview  = "dOp ";

    // Usage Information
    opt.overview += " : delta-complete Optimizer";
    opt.syntax    = "dOp [OPTIONS] <input file>";
    if (opt.isSet("-h")) {
        printUsage(opt);
    }

    // precision
    if (opt.isSet("--precision")) {
        double prec = 0.0;
        opt.get("--precision")->getDouble(prec);
        set_precision(prec);
    }

    // visualization options
    if (opt.isSet("--run-visualization")) { set_run_visualization(true); }
    if (opt.isSet("--save-visualization")) { set_save_visualization(true); }
    if (opt.isSet("--vis-cell")) {
        unsigned long vis_cell = 0.0;
        opt.get("--vis-cell")->getULong(vis_cell);
        set_vis_cell(vis_cell);
    }
    if (opt.isSet("--local-opt")) { set_local_opt(true); }
    if (opt.isSet("--debug")) { set_debug(true); }
//    if (opt.isSet("--polytope")) { set_polytope(true); }
    set_polytope(true);  //always set it
    if (opt.isSet("--no-sync")) { set_sync(false); }
    if (opt.isSet("--stat")) { set_stat(true); }
    if (opt.isSet("--worklist-fp")) { set_worklist_fp(true); }

    // Set up filename
    string filename;
    vector<string*> args;
    args.insert(args.end(), opt.firstArgs.begin() + 1, opt.firstArgs.end());
    args.insert(args.end(), opt.unknownArgs.begin(),   opt.unknownArgs.end());
    args.insert(args.end(), opt.lastArgs.begin(),      opt.lastArgs.end());
    if (args.size() != 1) {
        printUsage(opt);
    }
    filename = *args[0];
    if (filename.length() > 0) {
        struct stat s;
        if (stat(filename.c_str(), &s) != 0 || !(s.st_mode & S_IFREG)) {
            cerr << "can't open file:" << filename << endl;
            exit(1);
        }
        size_t pos_of_dot_in_filename = filename.find_last_of(".");
        if (pos_of_dot_in_filename == string::npos) {
            cerr << "filename: " << filename
                 << " does not have an extension.";
            exit(1);
        }
        string const file_ext = filename.substr(pos_of_dot_in_filename + 1);
        if (file_ext != "inv") {
            cerr << "Input file: " << filename << endl
                 << "Note: we only support .inv files." << endl;
            exit(1);
        }
    }
    set_filename(filename);
}

ostream & operator<<(ostream & out, config const & c) {
    out << "filename           = " << c.m_filename << endl;
    out << "vis_cell           = " << c.m_vis_cell << endl;
    out << "run visualization  = " << c.m_run_visualization << endl;
    out << "save visualization = " << c.m_save_visualization << endl;
    out << "precision          = " << c.m_prec;
    return out;
}

}  

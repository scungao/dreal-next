#include "tools/lypsyn/lypsyn.h"

int main(int argc, const char * argv[]) {
#ifdef LOGGING
    START_EASYLOGGINGPP(argc, argv);
#endif
    lypsyn::config config(argc, argv);
    return lypsyn::process_lypsyn(config);
}

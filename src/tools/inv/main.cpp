#include "tools/inv/inv.h"

int main(int argc, const char * argv[]) {
#ifdef LOGGING
    START_EASYLOGGINGPP(argc, argv);
#endif
    inv::config config(argc, argv);
    return inv::process_inv(config);
}

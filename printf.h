int ee_printf(const char *fmt, ...);

#ifndef PRINTF_REDEFINED
    #define printf(...) ee_printf(__VA_ARGS__)
    #define fprintf(...)
    #define fflush(...)
    #define PRINTF_REDEFINED
#endif
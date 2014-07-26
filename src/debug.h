#ifndef DEBUG__
#define DEBUG__


#define DEBUG_PRINT 1

#if DEBUG_PRINT
#  include <stdlib.h> // for sprintf()
#  include "simple_uart.h"
#  define str(x)      (const uint8_t *)(x)
#  define DP_cnf(...) simple_uart_config(__VA_ARGS__)
#  define DP_str(x)   simple_uart_putstring(str(x))
#  define DP_int(x)   { char s[12]; sprintf(s,"%d", (x)); DP_str(str(s)); }
#else
#  define DP_cnf(...)
#  define DP_str(x)
#  define DP_int(x)
#endif


#endif

/* Linker script to configure memory regions. */

SEARCH_DIR(.)
GROUP(-lgcc -lc -lnosys)

MEMORY
{
  FLASH (rx) : ORIGIN = 0x00014000, LENGTH = 0x2C000 /* should it be 0x13C00 ? */
  RAM (rwx) :  ORIGIN = 0x20002000, LENGTH = 0x2530  /* IT SHOULD BE 0x2000 !! */
}


INCLUDE "gcc_nrf51_common.ld"

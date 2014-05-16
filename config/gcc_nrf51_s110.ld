/* Linker script to configure memory regions. */

SEARCH_DIR(.)
GROUP(-lgcc -lc -lnosys)

MEMORY
{
  FLASH (rx) : ORIGIN = 0x0003B800, LENGTH = 0x4400
  bootloader_settings (rwx) : ORIGIN = 0x0003FC00, LENGTH = 0x400
  NRF_UICR_BOOT_START (rwx) : ORIGIN = 0x10001014, LENGTH = 0x4
  RAM (rwx) :  ORIGIN = 0x20002000, LENGTH = 0x2000
}


INCLUDE "gcc_nrf51_common.ld"

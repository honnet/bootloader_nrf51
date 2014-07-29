# Project Source
C_SOURCE_FILES += main.c
C_SOURCE_FILES += ble_bdt.c
C_SOURCE_FILES += simple_uart.c

# APP Common
C_SOURCE_FILES += app_button.c
C_SOURCE_FILES += app_timer.c
C_SOURCE_FILES += app_scheduler.c
C_SOURCE_FILES += app_gpiote.c
C_SOURCE_FILES += crc16.c
C_SOURCE_FILES += pstorage.c
C_SOURCE_FILES += softdevice_handler.c

# BLE
C_SOURCE_FILES += ble_srv_common.c
C_SOURCE_FILES += ble_advdata.c
C_SOURCE_FILES += ble_conn_params.c
C_SOURCE_FILES += ble_debug_assert_handler.c
C_SOURCE_FILES += ble_error_log.c

# startup files
C_SOURCE_FILES += system_$(DEVICESERIES).c
ASSEMBLER_SOURCE_FILES += gcc_startup_$(DEVICESERIES).s

SDK_PATH = lib/nrf51822/sdk_nrf51822_5.2.0/
SDK_SOURCE_PATH = $(SDK_PATH)Source/
SDK_INCLUDE_PATH = $(SDK_PATH)Include/

USE_LOADER := 0
USE_S110 := 1
SOFTDEVICE := lib/nrf51822/s110_nrf51822_6.0.0/s110_nrf51822_6.0.0_softdevice.hex

OBJECT_DIRECTORY := obj
LISTING_DIRECTORY := bin
OUTPUT_BINARY_DIRECTORY := build
OUTPUT_FILENAME := DFU_trigger
ELF := $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out

DEVICE := NRF51
DEVICESERIES := nrf51
CPU := cortex-m0

GDB_PORT_NUMBER := 2331

# Toolchain (must be in PATH)
GNU_VERSION := 4.8.3
GNU_PREFIX := arm-none-eabi
CC       		:= $(GNU_PREFIX)-gcc
AS       		:= $(GNU_PREFIX)-as
AR       		:= $(GNU_PREFIX)-ar -r
LD       		:= $(GNU_PREFIX)-ld
NM       		:= $(GNU_PREFIX)-nm
OBJDUMP  		:= $(GNU_PREFIX)-objdump
OBJCOPY  		:= $(GNU_PREFIX)-objcopy
GDB       		:= $(GNU_PREFIX)-gdb
CGDB            := "/usr/local/bin/cgdb"

MK 				:= mkdir
RM 				:= rm -rf
ECHO			:= /bin/echo -e

# Programmer
JLINK = -JLinkExe
JLINKGDBSERVER = JLinkGDBServer

# Source Paths
C_SOURCE_PATHS += src
C_SOURCE_PATHS += src/startup
C_SOURCE_PATHS += $(SDK_SOURCE_PATH)app_common
C_SOURCE_PATHS += $(SDK_SOURCE_PATH)sd_common
C_SOURCE_PATHS += $(SDK_SOURCE_PATH)ble
C_SOURCE_PATHS += $(SDK_SOURCE_PATH)ble/ble_services
C_SOURCE_PATHS += $(SDK_SOURCE_PATH)simple_uart

ASSEMBLER_SOURCE_PATHS = src/startup

# Include Paths
INCLUDEPATHS += -Isrc
INCLUDEPATHS += -I$(SDK_PATH)Include
INCLUDEPATHS += -I$(SDK_PATH)Include/gcc
INCLUDEPATHS += -I$(SDK_PATH)Include/app_common
INCLUDEPATHS += -I$(SDK_PATH)Include/sd_common
INCLUDEPATHS += -I$(SDK_PATH)Include/s110
INCLUDEPATHS += -I$(SDK_PATH)Include/ble
INCLUDEPATHS += -I$(SDK_PATH)Include/ble/ble_services

# Compiler flags
CFLAGS += -mcpu=$(CPU) -mthumb -mabi=aapcs -D$(DEVICE) --std=gnu99
CFLAGS += -DBLE_STACK_SUPPORT_REQD
CFLAGS += -Wall -Werror # -Wextra
CFLAGS += -ffunction-sections -fdata-sections # split bin in little sections...

# Linker flags
CONFIG_PATH += config/
LINKER_SCRIPT = gcc_$(DEVICESERIES)_s110.ld
LDFLAGS += -L"$(GNU_INSTALL_ROOT)/arm-none-eabi/lib/armv6-m"
LDFLAGS += -L"$(GNU_INSTALL_ROOT)/lib/gcc/arm-none-eabi/$(GNU_VERSION)/armv6-m"
LDFLAGS += -Xlinker -Map=$(LISTING_DIRECTORY)/$(OUTPUT_FILENAME).map
LDFLAGS += -mcpu=$(CPU) -mthumb -mabi=aapcs
LDFLAGS += -L$(CONFIG_PATH) -T$(LINKER_SCRIPT)
LDFLAGS += -Wl,--gc-sections # remove unused sections (separated thanks to the last CFLAGS)
LDFLAGS += -use-gold # use more efficient linker

FLASH_START_ADDRESS = 0x14000

# Sorting removes duplicates
BUILD_DIRECTORIES := $(sort $(OBJECT_DIRECTORY) $(OUTPUT_BINARY_DIRECTORY) $(LISTING_DIRECTORY) )


####################################################################
# Rules                                                            #
####################################################################

C_SOURCE_FILENAMES = $(notdir $(C_SOURCE_FILES) )
ASSEMBLER_SOURCE_FILENAMES = $(notdir $(ASSEMBLER_SOURCE_FILES) )

C_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(C_SOURCE_FILENAMES:.c=.o) )
ASSEMBLER_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(ASSEMBLER_SOURCE_FILENAMES:.s=.o) )

# Set source lookup paths
vpath %.c $(C_SOURCE_PATHS)
vpath %.s $(ASSEMBLER_SOURCE_PATHS)

# Include automatically previously generated dependencies
-include $(addprefix $(OBJECT_DIRECTORY)/, $(COBJS:.o=.d))

## Default build target
.PHONY: all
all: release

clean:
	$(RM) $(OUTPUT_BINARY_DIRECTORY)/*
	$(RM) $(OBJECT_DIRECTORY)/*
	$(RM) $(LISTING_DIRECTORY)/*
	- $(RM) JLink.log
	- $(RM) .gdbinit

### Targets
.PHONY: debug
debug:    CFLAGS += -DDEBUG -g3 -O0
debug:    $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

.PHONY: release
release:  CFLAGS += -DNDEBUG -Os
release:  $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

echostuff:
	echo $(C_OBJECTS)
	echo $(C_SOURCE_FILES)

## Create build directories
$(BUILD_DIRECTORIES):
	$(MK) $@

## Create objects from C source files
$(OBJECT_DIRECTORY)/%.o: %.c
# Build header dependencies
	$(CC) $(CFLAGS) $(INCLUDEPATHS) -M $< -MF "$(@:.o=.d)" -MT $@
# Do the actual compilation
	$(CC) $(CFLAGS) $(INCLUDEPATHS) -c -o $@ $<

## Assemble .s files
$(OBJECT_DIRECTORY)/%.o: %.s
	$(CC) $(ASMFLAGS) $(INCLUDEPATHS) -c -o $@ $<

## Link C and assembler objects to an .out file
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out: $(BUILD_DIRECTORIES) $(C_OBJECTS) $(ASSEMBLER_OBJECTS)
	$(CC) $(LDFLAGS) $(C_OBJECTS) $(ASSEMBLER_OBJECTS) -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out

## Create binary .bin file from the .out file
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin: $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	$(OBJCOPY) -O binary $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin

## Create binary .hex file from the .out file
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex: $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	$(OBJCOPY) -O ihex $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

## Program device
recover: recover.jlink erase-all.jlink pin-reset.jlink
	$(JLINK) $(OUTPUT_BINARY_DIRECTORY)/recover.jlink
	$(JLINK) $(OUTPUT_BINARY_DIRECTORY)/erase-all.jlink
	$(JLINK) $(OUTPUT_BINARY_DIRECTORY)/pin-reset.jlink

recover.jlink:
	$(ECHO) "si 0\nt0\nsleep 1\ntck1\nsleep 1\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\ntck0\nsleep 100\nsi 1\nr\nexit\n" > $(OUTPUT_BINARY_DIRECTORY)/recover.jlink

pin-reset.jlink:
	$(ECHO) "device nrf51822\nw4 4001e504 2\nw4 40000544 1\nr\nexit\n" > $(OUTPUT_BINARY_DIRECTORY)/pin-reset.jlink

erase-all: erase-all.jlink
	$(JLINK) $(OUTPUT_BINARY_DIRECTORY)/erase-all.jlink

erase-all.jlink:
	$(ECHO) "device nrf51822\nw4 4001e504 2\nw4 4001e50c 1\nw4 4001e514 1\nr\nexit\n" > $(OUTPUT_BINARY_DIRECTORY)/erase-all.jlink

startgdbserver: stopgdbserver debug.jlink .gdbinit
	-killall $(JLINKGDBSERVER)
	$(JLINKGDBSERVER) -if swd -speed 1000 -port $(GDB_PORT_NUMBER) &
	sleep 1

stopgdbserver:
	-killall $(JLINKGDBSERVER)

startdebug: stopdebug startgdbserver
	$(GDB) $(ELF)

stopdebug: stopgdbserver

.gdbinit:
	$(ECHO) "target remote localhost:$(GDB_PORT_NUMBER)\nmonitor flash download = 1\nmonitor flash device = nrf51822\nbreak main\nmon reset\n" > .gdbinit

debug.jlink:
	echo "Device nrf51822" > $(OUTPUT_BINARY_DIRECTORY)/debug.jlink

SOFTDEVICE_ELF = ${OUTPUT_BINARY_DIRECTORY}/${shell basename ${SOFTDEVICE:.hex=.elf}}

${SOFTDEVICE_ELF}: ${SOFTDEVICE}
	mkdir -p ${shell dirname ${SOFTDEVICE_ELF}}
	${OBJCOPY} -Iihex -Oelf32-littlearm ${SOFTDEVICE} ${SOFTDEVICE_ELF}

flash: release ${ELF} startgdbserver
	${GDB} -ex "source scripts/flash-dfu.gdb" -ex "flash ${ELF}" -ex "set confirm off" -ex "quit"
	$(MAKE) stopgdbserver

flash-all: release ${SOFTDEVICE_ELF} ${ELF} startgdbserver
	${GDB} -ex "source scripts/flash-dfu.gdb" -ex "flash-all ${SOFTDEVICE_ELF} ${ELF}" -ex "set confirm off" -ex "quit"
	$(MAKE) stopgdbserver

enter-dfu: startgdbserver
	$(GDB) -ex "source scripts/flash-dfu.gdb" -ex "enter-dfu" -ex "set confirm off" -ex "quit"

.PHONY: flash flash-dfu flash-softdevice erase-all startdebug stopdebug startgdbserver stopgdbserver enter-dfu


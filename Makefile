# Project Source
C_SOURCE_FILES += main.c

# SDK Source
C_SOURCE_FILES += nrf_delay.c

# startup files
C_SOURCE_FILES += system_$(DEVICESERIES).c
ASSEMBLER_SOURCE_FILES += gcc_startup_$(DEVICESERIES).s

SDK_PATH = lib/nrf51822/sdk_nrf51822_5.2.0/
SDK_SOURCE_PATH = $(SDK_PATH)Source/
SDK_INCLUDE_PATH = $(SDK_PATH)Include/

OBJECT_DIRECTORY := obj
LISTING_DIRECTORY := bin
OUTPUT_BINARY_DIRECTORY := build
DROPBOX_DIR := $(HOME)/Dropbox/twi
OUTPUT_FILENAME := blink-test
ELF := $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out

DEVICE := NRF51
DEVICESERIES := nrf51
CPU := cortex-m0

GDB_PORT_NUMBER := 2331

# Toolchain
GNU_INSTALL_ROOT := /usr
GNU_VERSION := 4.8.3
GNU_PREFIX := arm-none-eabi
CC       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-gcc"
AS       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-as"
AR       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ar" -r
LD       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ld"
NM       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-nm"
OBJDUMP  		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objdump"
OBJCOPY  		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objcopy"
GDB       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-gdb"
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
C_SOURCE_PATHS += $(SDK_SOURCE_PATH)nrf_delay
ASSEMBLER_SOURCE_PATHS = src/startup

# Include Paths
INCLUDEPATHS += -Isrc
INCLUDEPATHS += -I$(SDK_PATH)Include
INCLUDEPATHS += -I$(SDK_PATH)Include/gcc

# Compiler flags
CFLAGS += -mcpu=$(CPU) -mthumb -mabi=aapcs -D$(DEVICE) --std=gnu99

# Linker flags
CONFIG_PATH += config/
LINKER_SCRIPT = gcc_$(DEVICESERIES)_s110.ld
LDFLAGS += -L"$(GNU_INSTALL_ROOT)/arm-none-eabi/lib/armv6-m"
LDFLAGS += -L"$(GNU_INSTALL_ROOT)/lib/gcc/arm-none-eabi/$(GNU_VERSION)/armv6-m"
LDFLAGS += -Xlinker -Map=$(LISTING_DIRECTORY)/$(OUTPUT_FILENAME).map
LDFLAGS += -mcpu=$(CPU) -mthumb -mabi=aapcs
LDFLAGS += -L$(CONFIG_PATH) -T$(LINKER_SCRIPT)

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
	- $(RM) $(DROPBOX_DIR)/$(OUTPUT_FILENAME).hex

### Targets
.PHONY: debug
debug:    CFLAGS += -DDEBUG -g3 -O0
debug:    $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

.PHONY: release
release:  CFLAGS += -DNDEBUG -Os
release:  $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

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

## Create binary .hex file from the .out file
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex: $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	$(OBJCOPY) -O ihex $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

## Program device # TODO: generify
dropbox: all
	cp $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex $(DROPBOX_DIR)

startdebug: stopdebug debug.jlink .gdbinit
	$(JLINKGDBSERVER) -single -if swd -speed 1000 -port $(GDB_PORT_NUMBER) &
	sleep 1
	$(GDB) $(ELF)

stopdebug:
	-killall $(JLINKGDBSERVER)

.gdbinit:
	$(ECHO) "target remote localhost:$(GDB_PORT_NUMBER)\nmonitor flash download = 1\nmonitor flash device = nrf51822\nbreak main\nmon reset\n" > .gdbinit

debug.jlink:
	echo "Device nrf51822" > $(OUTPUT_BINARY_DIRECTORY)/debug.jlink

.PHONY: dropbox startdebug stopdebug


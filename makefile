#
# Simple make steps to build stm32f4 disco based proects
# Author: Felipe Silva Neves
#
TOOLCHAN_PATH=/Users/felipeneves/Documents/toolchains/arm-gcc/bin/
PREFIX=arm-none-eabi-
CC=gcc
LD=g++
AS=as
OD=objcopy
SIZ=size
GDB=gdb
CFLAGS= -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv5-sp-d16  -g -c -O0
SFLAGS= -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv5-sp-d16  -g -O0

OUTFILE= stm32f4_fota
SIZ = size
SIZEFLAGS = --format=berkeley

#
# Add include directories:
#
CFLAGS += -DSTM32F429xx #-D__FPU_PRESENT=1 -D__FPU_USED=1
CFLAGS += -I proj_include
CFLAGS += -I proj_include/cmsis
CFLAGS += -I drivers
CFLAGS += -I debug_util
CFLAGS += -I board
CFLAGS += -I board/Components
CFLAGS += -I board/Fonts





#
# Add source directories:
#


# add drivers folder:
SRC += $(wildcard drivers/*.c)

#add debug drivers:
SRC += $(wildcard debug_util/*.c)

#add bsp files:
SRC += $(wildcard board/*.c)
SRC += $(wildcard board/Components/*.c)
SRC += $(wildcard board/Fonts/*.c)

#add main or other c file stuff
SRC += $(wildcard *.c)
SRC += $(wildcard system/*.c)

#add startup code:
AS_SRC = $(wildcard system/*.s)



#
# Define linker script files:
#
LDS=system/linker_script.ld
LDFLAGS =  -g -mthumb -mcpu=cortex-m4  -mfloat-abi=hard -mfpu=fpv5-sp-d16 --specs=nosys.specs  -Wl,-static,--gc-sections
LDFLAGS += -T$(LDS) -Xlinker -Map=$(OUTFILE).map
LIBS = -lm


#
# .c to .o recursion magic:
#
OBJS  = $(SRC:.c=.o)
OBJS += $(AS_SRC:.S=.o)


#
# Define the build chain:
#
.PHONY: all, clean,connect,debug_jlink,debug

debug: $(OUTFILE).elf
	@echo arm-none-eabi-gdb $<
	@target remote localhost:3333
	@monitor reset halt
	@load


all: $(OUTFILE).elf
	@echo "[BIN]: Generating binary files and calculating sizes!"
	@$(TOOLCHAN_PATH)$(PREFIX)$(OD) -O ihex $< $(OUTFILE).hex
	@$(TOOLCHAN_PATH)$(PREFIX)$(OD) -I ihex $<  -O binary $(OUTFILE).bin
	@$(TOOLCHAN_PATH)$(PREFIX)$(SIZ) $(SIZFLAGS) $<
	@echo "[BIN]: Generated the $(OUTFILE).bin binary file!"
	@echo "[ELF]: Generated $< file successfully!"

connect:

debug_jlink: $(OUTFILE).elf
	@echo "starting debugger!"



clean:
	@echo "[CLEAN]: Cleaning !"
	@rm -f *.elf
	@rm -f  system/*.o
	@rm -f  *.o
	@rm -f  drivers/*.o
	@rm -f  debug_util/*.o
	@rm -f  board/*.o
	@rm -f  board/Components/*.o
	@rm -f  board/Fonts/*.o
	@rm -f  *.map
	@echo "[CLEAN]: Done !"


#
# Linking step:
#
$(OUTFILE).elf: $(OBJS)
	@echo "[LD]: Linking files!"
	@$(TOOLCHAN_PATH)$(PREFIX)$(LD) $(LDFLAGS) -Xlinker --start-group $(OBJS) $(LIBS) -Xlinker --end-group -o $@
	@echo "[LD]: Cleaning intermediate files!"
	@rm -f  system/*.o
	@rm -f  *.o
	@rm -f  drivers/*.o
	@rm -f  debug_util/*.o
	@rm -f  board/*.o
	@rm -f  board/Components/*.o
	@rm -f  board/Fonts/*.o

#
# Compiling step:
#
.c.o:
	@echo "[CC]: $< "
	@$(TOOLCHAN_PATH)$(PREFIX)$(CC) $(CFLAGS) -o $@  $<

#
# startup code step:
#
.s.o:
	@echo "[AS]: $< "
	@$(TOOLCHAN_PATH)$(PREFIX)$(CC) $(SFLAGS) -o $@  $<

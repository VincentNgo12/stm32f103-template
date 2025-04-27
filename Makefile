# -----------------------------------------------------------------------------
# Makefile for STM32F103 baremetal project
# -----------------------------------------------------------------------------

# Project name (no extension)
PROGRAM = blink

# Compiler and flags
CC = arm-none-eabi-gcc
CFLAGS = -mcpu=cortex-m3 -mthumb -nostdlib -Wall -Werror
CPPFLAGS = -DSTM32F103xB \
	-Ivendor/CMSIS/Device/ST/STM32F1/Include \
	-Ivendor/CMSIS/CMSIS/Core/Include \
	-Isrc

# Linker file
LINKER_FILE = linker_script.ld
LDFLAGS = -T $(LINKER_FILE)


# Source files
SRC = src/main.c src/startup.c ./vendor/CMSIS/Device/ST/STM32F1/Source/Templates/system_stm32f1xx.c 

# Object files (replace .c with .o)
OBJ = $(addprefix $(BUILD_DIR)/, $(SRC:.c=.o))


# -----------------------------------------------------------------------------
# Build rules
# -----------------------------------------------------------------------------
all: $(PROGRAM).elf

# Link object files into final ELF
$(PROGRAM).elf: $(OBJ)
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ -o $(PROGRAM).elf

#Compile each C files into obj file (inside build folder).
$(BUILD_DIR)/%.o: src/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

# -----------------------------------------------------------------------------
# Cleaning
# -----------------------------------------------------------------------------
.PHONY: clean
clean:
	rm -f *.o *.elf

# -----------------------------------------------------------------------------
# Flashing to target (using OpenOCD and ST-Link)
# -----------------------------------------------------------------------------
PROGRAMMER=openocd
PROGRAMMER_FLAGS=-f /usr/share/openocd/scripts/interface/stlink-v2.cfg -f /usr/share/openocd/scripts/target/stm32f1x.cfg

flash: $(PROGRAM).elf
	$(PROGRAMMER) $(PROGRAMMER_FLAGS) -c "program $(PROGRAM).elf verify reset exit"
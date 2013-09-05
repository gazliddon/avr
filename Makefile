# Avr makfile
# Nasty, recompiles all the source every build :D

PROJECT = avr

SOURCE := $(wildcard *.s)
INCLUDES :=$(wildcard *.i)  

BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/objs
FIRMWARE_DIR = $(BUILD_DIR)/firmware
ALL_DIRS = $(OBJ_DIR) $(FIRMWARE_DIR)

OBJ_FILE = $(OBJ_DIR)/$(PROJECT).o
HEX_FILE = $(BUILD_DIR)/$(PROJECT).hex
MAP_FILE = $(BUILD_DIR)/$(PROJECT).map

all : $(ALL_DIRS) $(HEX_FILE)
	@echo All done

$(ALL_DIRS) :
	mkdir -p $@

$(HEX_FILE) : $(OBJ_FILE)
	avr-ld --oformat ihex -o $@ $^

$(OBJ_FILE) : $(SOURCE) $(INCLUDES)
	avr-gcc \
	-Xlinker -Tdata -Xlinker 0x800100 \
	-Xlinker -M -nostdlib \
	-O2 -B/usr/avr/lib \
	-I/usr/local/avr/include -Wall \
	-mmcu=avr4 -D__AVR_ATmega88__ \
	-o $@ $(SOURCE) > $(MAP_FILE)



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
	@mkdir -p $@
	@echo Made directories

$(HEX_FILE) : $(OBJ_FILE)
	@avr-ld --oformat ihex -o $@ $^
	@echo Created $@

$(OBJ_FILE) : $(SOURCE) $(INCLUDES) Makefile
	@avr-gcc \
	-Xlinker -Tdata -Xlinker 0x800100 \
	-Xlinker -M -nostdlib \
	-Wall -mmcu=atmega328 \
	-o $@ $(SOURCE) > $(MAP_FILE)
	@echo Compiled source

clean:
	@rm -rf $(BUILD_DIR)

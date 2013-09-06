

# Avr makfile
# Nasty, recompiles all the source every build :D

PROJECT = avr

SOURCE := $(wildcard *.s)
INCLUDES :=$(wildcard *.i)  

BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/objs
FIRMWARE_DIR = $(BUILD_DIR)/firmware
ALL_DIRS = $(OBJ_DIR) $(FIRMWARE_DIR)

HEX_FILE = $(BUILD_DIR)/$(PROJECT).hex
MAP_FILE = $(BUILD_DIR)/$(PROJECT).map

OBJ_FILES := 	$(addprefix $(OBJ_DIR)/, \
		  $(addsuffix .o, $(basename $(notdir $(SOURCE)))$(TEMP))) 

all : $(ALL_DIRS) $(HEX_FILE)
	@echo All done

$(ALL_DIRS) :
	@mkdir -p $@
	@echo Made directories

$(HEX_FILE) : $(OBJ_FILES)
	@avr-ld --section-start=.boot=0x0 -nostdlib --oformat ihex -o $@ $^ -Map $(MAP_FILE)
	@echo Created $@

$(OBJ_FILES) : Makefile $(INCLUDES)

$(OBJ_DIR)/%.o : %.s
	@echo Compiling $<
	@avr-as -o $@ --fatal-warnings -mmcu=atmega328 $<

.PHONY : clean
clean:
	@rm -rf $(BUILD_DIR)

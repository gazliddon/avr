# Avr makfile

PROJECT := avr
TYPE := atmega88

AVR_SIM := ../simavr/simavr/run_avr 

SOURCE := 	$(wildcard *.s)
INCLUDES := 	$(wildcard *.i)  

BUILD_DIR :=	build
OBJ_DIR := 	$(BUILD_DIR)/objs
FIRMWARE_DIR := $(BUILD_DIR)/firmware
ALL_DIRS := 	$(OBJ_DIR) $(FIRMWARE_DIR)

DEBUG_FILE := 	$(BUILD_DIR)/$(PROJECT).axf
MAP_FILE := 	$(BUILD_DIR)/$(PROJECT).map

OBJ_FILES := 	$(addprefix $(OBJ_DIR)/, $(addsuffix .o, $(basename $(notdir $(SOURCE)))$(TEMP))) 

all : $(ALL_DIRS) $(DEBUG_FILE)
	@echo All done

# Directories
$(ALL_DIRS) :
	@mkdir -p $@
	@echo Made directories

# File we can debug with
$(DEBUG_FILE) : $(OBJ_FILES)
	@avr-ld --section-start=.boot=0x0 -nostdlib -o $@ $^ -Map $(MAP_FILE)
	@echo Created $@

$(OBJ_FILES) : Makefile $(INCLUDES)

# Compile asm -> o
$(OBJ_DIR)/%.o : %.s
	@echo Compiling $<
	@avr-as -g -o $@ --fatal-warnings -mmcu=$(TYPE) $<

# Clean all intermediate files
.PHONY : clean
clean:
	@rm -rf $(BUILD_DIR)

run : all
	$(AVR_SIM) -m $(TYPE) -g $(DEBUG_FILE)
	@ehco All run!

debug : all
	avr-gdb -tui $(DEBUG_FILE) -ex 'target remote :1234'
  

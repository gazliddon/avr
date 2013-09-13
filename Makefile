# Avr makfile

PROJECT := avr
TYPE := atmega88
FREQ := 20000000

AVR_SIM := 	../simavr/simavr/run_avr 

SOURCE := 	$(wildcard *.s)
INCLUDES := 	$(wildcard *.i)  

BUILD_DIR :=	build
OBJ_DIR := 	$(BUILD_DIR)/objs
FIRMWARE_DIR := $(BUILD_DIR)/firmware
TMP_DIR := 	$(BUILD_DIR)/tmp
ALL_DIRS := 	$(OBJ_DIR) $(FIRMWARE_DIR) $(TMP_DIR)

UTILS_DIR := 	utils


DEBUG_FILE := 	$(BUILD_DIR)/$(PROJECT).axf
MAP_FILE := 	$(BUILD_DIR)/$(PROJECT).map
OBJ_FILES := 	$(addprefix $(OBJ_DIR)/, $(addsuffix .o, $(basename $(notdir $(SOURCE)))$(TEMP))) 
TRACE_INFO := 	$(UTILS_DIR)/traceinfo/dist/build/traceinfo/traceinfo

OBJ_FILES :=  	$(OBJ_FILES) $(OBJ_DIR)/trace.o  

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

# yaml -> compiled source
$(OBJ_DIR)/%.o : %.yaml
	$(TRACE_INFO) $<> $(TMP_DIR)/tmp.s
	@avr-as -g -o $@ --fatal-warnings -mmcu=$(TYPE) $(TMP_DIR)/tmp.s

# Clean all intermediate files
.PHONY : clean
clean:
	@rm -rf $(BUILD_DIR)

run : all
	$(AVR_SIM) -f $(FREQ) -m $(TYPE) $(DEBUG_FILE)
	@echo All run!

debugrun : all
	$(AVR_SIM) -g -f $(FREQ) -m $(TYPE) $(DEBUG_FILE)
	@echo All run!

gdb : all
	gdb -tui --args $(AVR_SIM) -g -f $(FREQ) -m $(TYPE) $(DEBUG_FILE)
	@echo All run!

trace : all
	$(AVR_SIM) -r -f $(FREQ) -m $(TYPE) $(DEBUG_FILE)
	@echo All run!

debug : all
	avr-gdb -tui $(DEBUG_FILE) -ex 'target remote :1234'
  

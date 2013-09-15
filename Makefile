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
TRACE_DIR := 	$(BUILD_DIR)/trace

ALL_DIRS := 	$(TRACE_DIR) $(OBJ_DIR) $(FIRMWARE_DIR) $(TMP_DIR)

UTILS_DIR := 	utils

DEBUG_FILE := 	$(BUILD_DIR)/$(PROJECT).axf
MAP_FILE := 	$(BUILD_DIR)/$(PROJECT).map
OBJ_FILES := 	$(addprefix $(OBJ_DIR)/, $(addsuffix .o, $(basename $(notdir $(SOURCE)))$(TEMP))) 
TRACE_INFO := 	$(UTILS_DIR)/traceinfo/dist/build/traceinfo/traceinfo


OBJ_FILES :=  	$(OBJ_FILES) $(OBJ_DIR)/trace.o  

all : $(ALL_DIRS) $(DEBUG_FILE)
	@echo All done

COMP :=  @avr-gcc -nostdlib -g -c -mmcu=$(TYPE) 
LNK := 	 @avr-gcc -Xlinker -Tdata -Xlinker 0x800100 -nostdlib 

# Directories
$(ALL_DIRS) :
	@mkdir -p $@
	@echo Made directories

# File we can debug with
$(DEBUG_FILE) : $(OBJ_FILES)
	$(LNK) -o $@ $^ 
	@echo Created $@

$(OBJ_FILES) : Makefile $(INCLUDES)

# Compile asm -> o
$(OBJ_DIR)/%.o : %.s
	@echo Compiling $<
	$(COMP) -o $@ $<

# yaml -> compiled source
$(OBJ_DIR)/%.o : %.yaml
	$(TRACE_INFO) $< > $(TMP_DIR)/tmp.s
	$(COMP) -o $@ $(TMP_DIR)/tmp.s

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
  

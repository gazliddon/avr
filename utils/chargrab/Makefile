BUILD_DIR :=	build

EXE = $(BUILD_DIR)/grabchar

SOURCE := 	$(wildcard *.cpp)
INCLUDES := 	$(wildcard *.h)  


TMP_DIR := 	$(BUILD_DIR)/tmp
OBJ_DIR := 	$(BUILD_DIR)/objs
ALL_DIRS := 	$(OBJ_DIR) $(TMP_DIR)

COMP :=  	@g++ -c -std=c++11 -I.
LNK := 	 	@g++ 

OBJ_FILES := 	$(addprefix $(OBJ_DIR)/, $(addsuffix .o, $(basename $(notdir $(SOURCE)))$(TEMP))) 


all : $(ALL_DIRS) $(EXE)
	@echo All Built

clean :
	@rm -rf $(BUILD_DIR)
	@echo cleaned

test : all
	$(EXE)

$(OBJ_FILES) : Makefile $(INCLUDES)

$(ALL_DIRS) :
	@mkdir -p $(ALL_DIRS)
	@echo Made directories

$(EXE) : $(OBJ_FILES)
	$(LNK) $(OBJ_FILES) -o $@ -lSDL2
	@echo Linked

$(OBJ_DIR)/%.o : %.cpp
	@echo Compiling $<
	$(COMP) -o $@ $<

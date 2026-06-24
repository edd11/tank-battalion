# Tank Battalion - Makefile for TASM (Turbo Assembler)
# Target: DOS .EXE for DOSBox

ASM = tasm
LINK = tlink
ASMFLAGS = /zi /m2
LINKFLAGS = /v

SRC_DIR = src
BUILD_DIR = build
TARGET = $(BUILD_DIR)\tankbatl.exe

all: dirs $(TARGET)

dirs:
	@if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)

$(TARGET): $(SRC_DIR)\main.asm
	$(ASM) $(ASMFLAGS) $(SRC_DIR)\main.asm, $(BUILD_DIR)\main.obj
	$(LINK) $(LINKFLAGS) $(BUILD_DIR)\main.obj, $(TARGET), $(BUILD_DIR)\main.map

run: $(TARGET)
	dosbox $(TARGET) -exit

clean:
	@if exist $(BUILD_DIR)\*.obj del $(BUILD_DIR)\*.obj
	@if exist $(BUILD_DIR)\*.exe del $(BUILD_DIR)\*.exe
	@if exist $(BUILD_DIR)\*.map del $(BUILD_DIR)\*.map

.PHONY: all dirs run clean

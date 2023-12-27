BUILD=build
MBR= mbr.bin
OUT= disk.img

all: run

build: always $(OUT)
always:
	mkdir -p ./$(BUILD)

$(BUILD)/$(MBR): mbr.asm
	nasm $< -f bin -o $@

$(OUT): $(BUILD)/$(MBR)
	dd if=/dev/zero of=$@ bs=512 count=100
	dd if=$< of=$@ bs=512 count=1 conv=notrunc

run: build
	qemu-system-x86_64 -hda $(OUT) -nographic -echr 24 

clean:
	$(RM) $(BUILD)/* $(OUT) 

.phony: build all always run

CC=gcc
CPPFLAGS= -I.
CFLAGS= -m32

KERN_ENT= kernel_entry.o
KERN_BASE_SRC= $(shell find . -type f -name "*.c") 
KERN_BASE= $(KERN_BASE_SRC:.c=.o) 
KERN= kernel.bin

BOOTLOADER= bootloader.bin

OS= os.bin

BUILD=build
OUT= disk.img

all: run

build: always $(OUT)

always:
	mkdir -p ./$(BUILD)

$(BUILD)/$(BOOTLOADER): mbr.asm
	nasm $< -f bin -o $@

$(BUILD)/$(KERN_ENT): kernel_entry.asm
	nasm $< -f elf -o $@

$(BUILD)/$(KERN): $(BUILD)/$(KERN_ENT) $(KERN_BASE)
	$(LD) -o $@ -T link.ld $(BUILD)/$(KERN_ENT) $(KERN_BASE) -m elf_i386
	# objcopy -O binary $@.elf $@ -F elf32-i386

$(OUT): $(BUILD)/$(BOOTLOADER) $(BUILD)/$(KERN)
	dd if=/dev/zero of=$@ bs=512 count=100
	dd if=$(BUILD)/$(BOOTLOADER) of=$@ count=1 conv=notrunc
	dd if=$(BUILD)/$(KERN) of=$@ seek=1 skip=1 conv=notrunc


run: build
	qemu-system-x86_64 -hda $(OUT) -echr 24 

clean:
	$(RM) $(BUILD)/* $(OUT) $(KERN_BASE)

.phony: build all always run

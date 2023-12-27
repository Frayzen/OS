CC=gcc
CFLAGS= -m32

KERN_ENT= kernel_entry.o
KERN_BASE= kernel_base.o
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

$(BUILD)/$(KERN_BASE): kernel_base.c
	$(CC) -c $< $(CFLAGS) -o $@

$(BUILD)/$(KERN): $(BUILD)/$(KERN_ENT) $(BUILD)/$(KERN_BASE)
	$(LD) -o $@.elf -Ttext 0x1000 $(BUILD)/$(KERN_ENT) $(BUILD)/$(KERN_BASE) -m elf_i386
	objcopy -O binary $@.elf $@ -F elf32-i386

$(OUT): $(BUILD)/$(BOOTLOADER) $(BUILD)/$(KERN)
	dd if=/dev/zero of=$@ bs=512 count=100
	dd if=$(BUILD)/$(BOOTLOADER) of=$@ count=1 conv=notrunc
	dd if=$(BUILD)/$(KERN) of=$@ seek=1 skip=1 conv=notrunc

%.o: %.c
	$(CC) $(CFLAGS) -o $(BUILD)/$@ -c $<

run: build
	qemu-system-x86_64 -hda $(OUT) -echr 24 

clean:
	$(RM) $(BUILD)/* $(OUT) 

.phony: build all always run

AS = nasm
CC = x86_64-elf-gcc
LD = x86_64-elf-ld
OBJCOPY = x86_64-elf-objcopy

CFLAGS = -ffreestanding -mno-red-zone -m64 -Wall -Wextra -O2
LDFLAGS = -T linker.ld

KERNEL = kernel/kernel.o \
         kernel/Main-Kernel.o \
         kernel/drivers/vga.o \
         kernel/memory/memory.o \
         kernel/filesystem/fs.o \
         kernel/interrupts/idt.o

all: falcon-os.img

boot.bin:
	$(AS) -f bin boot.asm -o boot.bin

kernel/kernel.o:
	$(AS) -f elf64 kernel/kernel.asm -o kernel/kernel.o

kernel/Main-Kernel.o:
	$(CC) $(CFLAGS) -c kernel/Main-Kernel.c -o kernel/Main-Kernel.o

kernel/drivers/vga.o:
	$(CC) $(CFLAGS) -c kernel/drivers/vga.c -o kernel/drivers/vga.o

kernel/memory/memory.o:
	$(CC) $(CFLAGS) -c kernel/memory/memory.c -o kernel/memory/memory.o

kernel/filesystem/fs.o:
	$(CC) $(CFLAGS) -c kernel/filesystem/fs.c -o kernel/filesystem/fs.o

kernel/interrupts/idt.o:
	$(CC) $(CFLAGS) -c kernel/interrupts/idt.c -o kernel/interrupts/idt.o

kernel.elf: $(KERNEL)
	$(LD) $(LDFLAGS) -o kernel.elf $(KERNEL)

falcon-os.img: boot.bin kernel.elf
	$(OBJCOPY) -O binary kernel.elf kernel.bin
	cat boot.bin kernel.bin > falcon-os.img

clean:
	rm -f boot.bin kernel.bin kernel.elf falcon-os.img
	rm -f kernel/*.o
	rm -f kernel/drivers/*.o
	rm -f kernel/memory/*.o
	rm -f kernel/filesystem/*.o
	rm -f kernel/interrupts/*.o

.PHONY: all clean
.RECIPEPREFIX := >

AS = nasm
CC = clang
LD = ld.lld
OBJCOPY = llvm-objcopy
QEMU = qemu-system-x86_64

CFLAGS = --target=x86_64-unknown-elf \
         -ffreestanding \
         -fno-builtin \
         -fno-stack-protector \
         -mno-red-zone \
         -m64 \
         -O2 \
         -Wall \
         -Wextra

LDFLAGS = -m elf_x86_64 -T linker.ld

KERNEL_OBJECTS = \
    kernel/kernel.o \
    kernel/Main-Kernel.o \
    kernel/drivers/keyboard.o

all: falcon-os.img

boot.bin: boot.asm
>$(AS) -f bin boot.asm -o boot.bin

kernel/kernel.o: kernel/kernel.asm
>$(AS) -f elf64 kernel/kernel.asm -o kernel/kernel.o

kernel/Main-Kernel.o: kernel/Main-Kernel.c kernel/kernel.h
>$(CC) $(CFLAGS) -c kernel/Main-Kernel.c -o kernel/Main-Kernel.o

kernel/drivers/keyboard.o: kernel/drivers/keyboard.c
>$(CC) $(CFLAGS) -c kernel/drivers/keyboard.c -o kernel/drivers/keyboard.o

kernel.elf: $(KERNEL_OBJECTS) linker.ld
>$(LD) $(LDFLAGS) -o kernel.elf $(KERNEL_OBJECTS)

kernel.bin: kernel.elf
>$(OBJCOPY) -O binary kernel.elf kernel.bin
>python -c "p='kernel.bin'; d=open(p,'rb').read(); open(p,'wb').write(d + b'\0' * (32768-len(d))) if len(d)<32768 else None"

falcon-os.img: boot.bin kernel.bin
>cat boot.bin kernel.bin > falcon-os.img

run: falcon-os.img
>$(QEMU) -drive format=raw,file=falcon-os.img

clean:
>rm -f boot.bin kernel.bin kernel.elf falcon-os.img
>rm -f kernel/*.o kernel/drivers/*.o

.PHONY: all run clean
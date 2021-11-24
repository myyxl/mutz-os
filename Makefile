C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)
LDFLAGS = -T boot/link.ld -melf_i386
AS = nasm
ASFLAGS = -f elf
OBJ = ${C_SOURCES:.c=.o}
CC = gcc
CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs
STAGE2_ELTORITO = /usr/lib/grub/x86_64-pc/stage2_eltorito

kernel.elf: loader.asm $(OBJ)
	ld $(LDFLAGS) boot/loader.o $(OBJ) -o kernel.elf 

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

loader.asm:
	$(AS) $(ASFLAGS) boot/loader.asm -o boot/loader.o

clean:
	rm -rf *.bin *.dis *.o os-image.bin *.elf *.iso
	rm -rf kernel/*.o boot/*.bin drivers/*.o boot/*.o
	rm -rf iso/

iso: kernel.elf
	mkdir -p iso/boot/grub
	cp $(STAGE2_ELTORITO) iso/boot/grub/
	cp kernel.elf iso/boot/
	cp boot/menu.lst iso/boot/grub/
	genisoimage -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -A MutzOS -boot-info-table -o ./mutz-os.iso iso
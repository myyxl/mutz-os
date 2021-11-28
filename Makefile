# Sources
C_SOURCES = $(shell find . -type f -name "*.c")
ASM_SOURCES = $(shell find . -type f -name "*.asm")
OBJECTS = $(C_SOURCES:.c=.o) $(ASM_SOURCES:.asm=.o)

# Executables
ASSEMBLER = nasm
COMPILER = gcc
LINKER = ld
STAGE2_ELTORITO = boot/stage2_eltorito
EMU = qemu-system-x86_64

# Flags
LDFLAGS = -T link.ld -melf_i386
ASFLAGS = -f elf
CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs -Isrc/include/
EMU_FLAGS = -cdrom

# Other
OUTFILE = ./mutz-os.iso

default: iso

kernel.elf: $(OBJECTS)
	$(LINKER) $(LDFLAGS) $(OBJECTS) -o kernel.elf 

%.o: %.c
	$(COMPILER) $(CFLAGS) -c $< -o $@

%.o: %.asm
	$(ASSEMBLER) $(ASFLAGS) $< -o $@

clean:
	find . -iregex '.*\.\(o\|elf\|iso\)$$' -delete
	rm -rf iso

iso: kernel.elf
	mkdir -p iso/boot/grub
	cp $(STAGE2_ELTORITO) iso/boot/grub/
	cp kernel.elf iso/boot/
	cp boot/menu.lst iso/boot/grub/
	genisoimage -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -A MutzOS -boot-info-table -o $(OUTFILE) iso

run: iso
	$(EMU) $(EMU_FLAGS) $(OUTFILE)
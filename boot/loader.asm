global _start

MAGIC_NUMBER         equ 0x1BADB002             ; magic number which identifies the header
FLAGS                equ 0x0                    ; flags
CHECKSUM             equ -MAGIC_NUMBER          ; header checksum which must have a sum of zero when added to the other fields
                                                ; MAGIC_NUMBER + FLAGS + CHECKSUM = 0x1BADB002 + 0 + (-0x1BADB002) = 0
                                                ; https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#Header-layout
                                                ; the sections must be 4 bytes aligned
                                                ; https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#OS-image-format

KERNEL_STACK_SIZE    equ 4096                   ; stack size of the kernel

section .text                                   ; .text section is used for code
align 4                                         ; write the header values
    dd MAGIC_NUMBER
    dd FLAGS
    dd CHECKSUM

_start:
    mov esp, kernel_stack + KERNEL_STACK_SIZE   ; set the stack pointer to the end of the stack
    extern kmain
    call kmain                                  ; call the main function in kernel.c
    jmp $

section .bss                                    ; .bss is used for uninitialized data
align 4
kernel_stack:
    resb KERNEL_STACK_SIZE                      ; reserve 4096 bytes of memory for the stack
    
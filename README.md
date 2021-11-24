# MutzOS

## Installing dependencies
Run the following command to install the required dependencies:
```
apt install genisoimage grub nasm
```
## Setup
If your `stage2_eltorito` is not at `/usr/lib/grub/x86_64-pc/stage2_eltorito` you need to change the
path inside the Makefile
## Compiling
To compile from source you can run `make iso`, this will generate an iso file.

To delete all generated output files run `make clean`.

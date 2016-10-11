http://wiki.osdev.org/Bare_Bones


i686-elf-as boot.s -o boot.o
i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
i686-elf-gcc -T linker.ld -o myos.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc
qemu-system-i386 -kernel myos.bin


compiler
	Working i686 gcc (doesn't work for meaty skeleton:
		http://newos.org/toolchains/i686-elf-4.9.1-Linux-x86_64.tar.xz
	found i686 compiler on:
		http://wiki.osdev.org/GCC_Cross-Compiler

==========================================================

#git clone https://github.com/rm-hull/barebones-toolchain.git
#cd barebones-toolchain
#add ./setenv.sh to bashrc
#ln -s /bin/bash/ /usr/bin/bash


gcc -T linker.ld -o myos.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc -m32


bootable:
mkdir -p isodir/boot/grub
cp myos.bin isodir/boot/myos.bin
cp grub.cfg isodir/boot/grub/grub.cfg


#needed for grub-mkrescue
#sudo apt-get install xorriso

grub-mkrescue -o myos.iso isodir

sudo apt-get install qemu-system-x86


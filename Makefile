
.PHONY: default

default: myos.bin clean

oldp=$(shell pwd)

path = ../cross/i686-elf-2/i686-elf-4.9.1-Linux-x86_64

clean:
	rm -f kernel.o boot.o myos.bin myos.iso

myos.bin:
	cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-as boot.s -o boot.o
	cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-gcc -T linker.ld -o myos.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc
	qemu-system-i386 -kernel myos.bin



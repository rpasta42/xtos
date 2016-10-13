
.PHONY: default

default: myos.bin clean

oldp=$(shell pwd)

path = ../cross/i686-elf-2/i686-elf-4.9.1-Linux-x86_64

clean:
	rm -f kernel.o boot.o myos.bin myos.iso
	rm -fr *.o isodir

iso: myos.bin
	mkdir -p isodir/boot/grub
	cp myos.bin isodir/boot/myos.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o myos.iso isodir

myos.bin:
	#nasm -f elf32 vid.s -o vid.o
	#nasm -w+gnu-elf-extensions -f elf32 vid.s -o vid.o #need elf 32 bit #yasm -m x86 -a x86 -f bin vid.s -o vid.o #nasm -f aout vid.s -o vid.o
	#nasm -w+gnu-elf-extensions -f aout vid.s -o vid.o #need elf 32 bit #yasm -m x86 -a x86 -f bin vid.s -o vid.o #nasm -f aout vid.s -o vid.o

	cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-as boot.s -o boot.o
	cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

	cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-gcc -c idt.c -o idt.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-gcc -c gdt.c -o gdt.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-gcc -c isrs.c -o isrs.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

	#cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-gcc -T linker.ld -o myos.bin -ffreestanding -O2 -nostdlib boot.o kernel.o vid.o -lgcc

      #includes interrupts and gdt
	cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-gcc -T linker.ld -o myos.bin -ffreestanding -O2 -nostdlib isrs.o gdt.o idt.o boot.o kernel.o -lgcc
	#cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-gcc -T linker.ld -o myos.bin -ffreestanding -O2 -nostdlib idt.o boot.o kernel.o -lgcc #includes interrupts
	#cd $(path); . ./setenv.sh; cd ${oldp}; i686-elf-gcc -T linker.ld -o myos.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc

	qemu-system-i386 -kernel myos.bin



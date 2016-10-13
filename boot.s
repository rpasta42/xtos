# Declare constants for the multiboot header.
.set ALIGN,    1<<0             # align loaded modules on page boundaries
.set MEMINFO,  1<<1             # provide memory map
.set FLAGS,    ALIGN | MEMINFO  # this is the Multiboot 'flag' field
.set MAGIC,    0x1BADB002       # 'magic number' lets bootloader find the header
.set CHECKSUM, -(MAGIC + FLAGS) # checksum of above, to prove we are multiboot

# Declare a multiboot header that marks the program as a kernel. These are magic
# values that are documented in the multiboot standard. The bootloader will
# search for this signature in the first 8 KiB of the kernel file, aligned at a
# 32-bit boundary. The signature is in its own section so the header can be
# forced to be within the first 8 KiB of the kernel file.
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# The multiboot standard does not define the value of the stack pointer register
# (esp) and it is up to the kernel to provide a stack. This allocates room for a
# small stack by creating a symbol at the bottom of it, then allocating 16384
# bytes for it, and finally creating a symbol at the top. The stack grows
# downwards on x86. The stack is in its own section so it can be marked nobits,
# which means the kernel file is smaller because it does not contain an
# uninitialized stack. The stack on x86 must be 16-byte aligned according to the
# System V ABI standard and de-facto extensions. The compiler will assume the
# stack is properly aligned and failure to align the stack will result in
# undefined behavior.
.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

# The linker script specifies _start as the entry point to the kernel and the
# bootloader will jump to this position once the kernel has been loaded. It
# doesn't make sense to return from this function as the bootloader is gone.
.section .text

######################

#extern _gp

.global _gdt_flush
.type _gdt_flush, @function
_gdt_flush:
   lgdt (gp)
   #mov %ax, 0x10
   #mov %ds, %ax
   #mov %es, %ax
   #mov %fs, %ax
   #mov %gs, %ax
   #mov %ss, %ax
   movw 0x10, %ax
   movw %ax, %ds
   movw %ax, %es
   movw %ax, %fs
   movw %ax, %gs
   movw %ax, %ss

   #jmp $0x08:flush2
   #jmp *flush2, 0x08
   jmp (flush2+0x08)
   #jmp (flush2+$08)
   #jmp (flush2) + $08


flush2:
   ret

#.global _kk
#.type _kk, @function
#_kk:
#   #mov %ax,0x13
#   #int 0x10
#   mov %ax, 0x13
#   int $10


###########setup interrupts
#http://www.osdever.net/bkerndev/Docs/idt.htm
.global _idt_load
.type _idt_load, @function
_idt_load:
   lidt idtp
   ret


.global _isr0
.type _isr0, @function
_isr0:
   cli
   #push byte 0
   #push byte 0
   push 0x0
   push 0x0
   jmp isr_common_stub


#extern _fault_handler
isr_common_stub:
   pusha
   pushw %ds
   pushw %es
   pushw %fs
   pushw %gs
   movw 0x10, %ax
   movw %ax, %ds
   movw %ax, %es
   #pusha
   #push %ds
   #push %es
   #push %fs
   #push %gs
   #mov %ax, 0x10
   #mov %ds, %ax
   #mov %es, %ax


   #mov %fs, %ax
   movw %ax, %fs
   #mov %gs, %ax
   movw %ax, %gs

   #mov %eax, %esp
   movl %esp, %eax

   #push %eax
   pushl %eax

   #mov %eax, fault_handler
   movl fault_handler, %eax

   #call %eax
   call %eax

   popl %eax
   popw %gs
   popw %fs
   popw %es
   popw %ds
   popa

   #add %esp, 0
   addl 0x0, %esp

   iret

#.global _isr1
#.global _isr2
#.global _isr3
#.global _isr4
#.global _isr5
#.global _isr6
#.global _isr7
#.global _isr8
#.global _isr9
#.global _isr10
#.global _isr
#.global _isr
#.global _isr
#.global _isr
#.global _isr

##########################

.global _start
.type _start, @function
_start:
	# The bootloader has loaded us into 32-bit protected mode on a x86
	# machine. Interrupts are disabled. Paging is disabled. The processor
	# state is as defined in the multiboot standard. The kernel has full
	# control of the CPU. The kernel can only make use of hardware features
	# and any code it provides as part of itself. There's no printf
	# function, unless the kernel provides its own <stdio.h> header and a
	# printf implementation. There are no security restrictions, no
	# safeguards, no debugging mechanisms, only what the kernel provides
	# itself. It has absolute and complete power over the
	# machine.

	# To set up a stack, we set the esp register to point to the top of our
	# stack (as it grows downwards on x86 systems). This is necessarily done
	# in assembly as languages such as C cannot function without a stack.
	mov $stack_top, %esp

	# This is a good place to initialize crucial processor state before the
	# high-level kernel is entered. It's best to minimize the early
	# environment where crucial features are offline. Note that the
	# processor is not fully initialized yet: Features such as floating
	# point instructions and instruction set extensions are not initialized
	# yet. The GDT should be loaded here. Paging should be enabled here.
	# C++ features such as global constructors and exceptions will require
	# runtime support to work as well.

	# Enter the high-level kernel. The ABI requires the stack is 16-byte
	# aligned at the time of the call instruction (which afterwards pushes
	# the return pointer of size 4 bytes). The stack was originally 16-byte
	# aligned above and we've since pushed a multiple of 16 bytes to the
	# stack since (pushed 0 bytes so far) and the alignment is thus
	# preserved and the call is well defined.

   #mov %ax, 0x13
   #int $10


      mov %edi,0x0A0000
      # the color of the pixel
      mov %al, 0x0F
      mov (%edi), %al

      mov %edi,0x0A0020
      # the color of the pixel
      mov %al, 0x0F
      mov (%edi), %al

      mov %edi,0x0A0030
      # the color of the pixel
      mov %al, 0x0F
      mov (%edi), %al

	call kernel_main

	# If the system has nothing more to do, put the computer into an
	# infinite loop. To do that:
	# 1) Disable interrupts with cli (clear interrupt enable in eflags).
	#    They are already disabled by the bootloader, so this is not needed.
	#    Mind that you might later enable interrupts and return from
	#    kernel_main (which is sort of nonsensical to do).
	# 2) Wait for the next interrupt to arrive with hlt (halt instruction).
	#    Since they are disabled, this will lock up the computer.
	# 3) Jump to the hlt instruction if it ever wakes up due to a
	#    non-maskable interrupt occurring or due to system management mode.
	cli
1:	hlt
	jmp 1b

# Set the size of the _start symbol to the current location '.' minus its start.
# This is useful when debugging or when you implement call tracing.
.size _start, . - _start


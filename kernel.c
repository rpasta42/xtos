/* Surely you will remove the processor conditionals and this comment
   appropriately depending on whether or not you use C++. */
#if !defined(__cplusplus)
#include <stdbool.h> /* C doesn't have booleans by default. */
#endif
#include <stddef.h>
#include <stdint.h>

/* Check if the compiler thinks we are targeting the wrong operating system. */
#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif

/* This tutorial will only work for the 32-bit ix86 targets. */
#if !defined(__i386__)
#error "This tutorial needs to be compiled with a ix86-elf compiler"
#endif

/* Hardware text mode color constants. */
enum vga_color {
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE = 1,
	VGA_COLOR_GREEN = 2,
	VGA_COLOR_CYAN = 3,
	VGA_COLOR_RED = 4,
	VGA_COLOR_MAGENTA = 5,
	VGA_COLOR_BROWN = 6,
	VGA_COLOR_LIGHT_GREY = 7,
	VGA_COLOR_DARK_GREY = 8,
	VGA_COLOR_LIGHT_BLUE = 9,
	VGA_COLOR_LIGHT_GREEN = 10,
	VGA_COLOR_LIGHT_CYAN = 11,
	VGA_COLOR_LIGHT_RED = 12,
	VGA_COLOR_LIGHT_MAGENTA = 13,
	VGA_COLOR_LIGHT_BROWN = 14,
	VGA_COLOR_WHITE = 15,
};

static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) {
	return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
	return (uint16_t) uc | (uint16_t) color << 8;
}

size_t strlen(const char* str) {
	size_t len = 0;
	while (str[len])
		len++;
	return len;
}

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;

void terminal_initialize(void) {
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
	terminal_buffer = (uint16_t*) 0xB8000;
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}

void terminal_setcolor(uint8_t color) {
	terminal_color = color;
}

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) {
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}

void terminal_putchar(char c) {
	terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
	if (++terminal_column == VGA_WIDTH) {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT)
			terminal_row = 0;
	}
}

void terminal_write(const char* data, size_t size) {
	for (size_t i = 0; i < size; i++) {
		terminal_putchar(data[i]);
            /*if (terminal_color++ > 15)
               terminal_color = 2;*/
      }
}

void terminal_writestring(const char* data) {
	terminal_write(data, strlen(data));
}

static inline void outb(uint16_t port, uint8_t val) {
    asm volatile( "outb %0, %1" : : "a"(val), "Nd"(port));
    /* There's an outb %al, $imm8  encoding, for compile-time constant port numbers that fit in 8b.  (N constraint).
     * Wider immediate constants would be truncated at assemble-time (e.g. "i" constraint).
     * The  outb  %al, %dx  encoding is the only option for all other cases.
     * %1 expands to %dx because  port  is a uint16_t.  %w1 could be used if we had the port number a wider C type */
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile("inb %1, %0"
                 : "=a"(ret)
                 : "Nd"(port));
    return ret;
}

int mem_start = 100;
void* malloc(int num) {
   void* ret = (void*)mem_start;
   mem_start += num;
   return ret;
}
// 1/1000th of a second
void sleep(int milli) {
   for (int i = 0; i < milli * 1000; i++) {
      asm("hlt");
   }
}

char digit_to_char(int i) {
   return '0' + i;
}

#define uint8_t char
#define bool char
#define true 1
#define false 0

char* int_to_str(int num) {
   int MAX_NUM_STR_LEN = 15;
   char* ret = malloc(MAX_NUM_STR_LEN);

   int i = MAX_NUM_STR_LEN-1;
   ret[i--] = '\0';

   bool done = false;

   if (num < 10)
      goto small_num; //TODO: could we just change do while to while?

   int rem = 0;
   do {
      rem = num % 10;
      num = (num - rem) / 10;
      ret[i--] = digit_to_char(rem);
   } while (num >= 10); //(num > 1); //(rem != 0)

small_num:
   ret[i] = digit_to_char(num);
   //ret[MAX_NUM_STR_LEN - digit_counter++] = '\0';

   return ret + i;
}

void test_int_to_str() {
   terminal_writestring(int_to_str(100)); terminal_putchar(' ');
   terminal_writestring(int_to_str(102)); terminal_putchar(' ');
   terminal_writestring(int_to_str(350)); terminal_putchar(' ');
   terminal_writestring(int_to_str(0)); terminal_putchar(' ');
   terminal_writestring(int_to_str(15)); terminal_putchar(' ');
   terminal_writestring(int_to_str(8)); terminal_putchar(' ');
   terminal_writestring(int_to_str(10)); terminal_putchar(' ');
}

void test_write_string() {
   // Newline support is left as an exercise.
   terminal_writestring("Hello, kernel World!\n");
   terminal_writestring("$WAG_M0NEY");
}

void test_random() {
   /*char first = *((char*)(0x64));

   i = 0;
   while (true) {
      //if (i++ != 100) continue;
      i = 0;
      char c = *((char*)(0x64));
      //terminal_putchar(c);
      if (c != first) terminal_putchar(c);
   }*/

      //i = 0;
      //while(true) { terminal_putchar(i++); }


}

char getScancode() {
   char c = 0;
   do {
      if (inb(0x60) != c) {
         c = inb(0x60);
         if (c > 0)
            return c;
      }
   } while(1);
}

//char getch() {}

#define scank(n, ret) if (scan_code == (n)) return ret;

char scanToKey(char scan_code) {

   //16 = 'q'
   /*uint8_t q_to_p = 'p' - 'q';
   if (scan_code >= 16 && (scan_code <= (scan_code + q_to_p))) {
      _scank(scan_code, 'q' + q_to_p)
   }*/

   //char top_row[] = {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']'};

   scank(41, '`');
   char qwerty[] = "qwertyuiop[]..asdfghjkl;'`..zxcvbnm,./";

   for (uint8_t i = 0; i < sizeof(qwerty)/sizeof(char); i++) {
      scank(i + 16, qwerty[i]);
   }

   char top_row[] = "1234567890-=";
   if (scan_code >= 2 && scan_code <= 13) {
      scank(scan_code, top_row[scan_code - 2]);
   }


   /*scank(16, 'q')
   scank(17, 'w')
   scank(18, 'e')
   scank(19, 'r')
   scank(20, 't')
   scank(21, 'y')
   scank(21, 'u')
   scank(21, 'i')*/

   scank(46, 'c')
   scank(30, 'a')
   scank(31, 's')
   scank(48, 'b')

   return ' ';
}

void test_keyboard() {

   /*terminal_writestring(int_to_str('.'));
   terminal_writestring(int_to_str('.'));
   return;*/

   char prev = NULL;

   while (true) {
      char c = getScancode();
      if (prev != c) {
         terminal_writestring(int_to_str(c));

         terminal_putchar(' ');
         terminal_putchar(scanToKey(c));

         terminal_putchar(' ');
         terminal_putchar(c);

         terminal_row++;
         terminal_column = 0;

         //terminal_putchar(c);
      }
      prev = c;
   }
}



#if defined(__cplusplus)
extern "C" /* Use C linkage for kernel_main. */
#endif
void kernel_main(void) {
   terminal_initialize(); // Initialize terminal interface
   //sleep(1000);
   //asm("hlt");

   //test_write_string();
   //test_random();
   test_keyboard();
   return;
}



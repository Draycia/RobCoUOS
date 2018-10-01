#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <sys/io.h>

#include <kernel/tty.h>

#include "vga.h"

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;
static uint16_t* const VGA_MEMORY = (uint16_t*) 0xC03FF000;

static size_t terminal_row;
static size_t terminal_column;
static uint8_t terminal_color;
static uint16_t* terminal_buffer;

void terminal_movecursor(int x, int y) {
	uint16_t pos = y * VGA_WIDTH + x;
 
	outb(0x3D4, 0x0F);
	outb(0x3D5, (uint8_t) (pos & 0xFF));
	outb(0x3D4, 0x0E);
	outb(0x3D5, (uint8_t) ((pos >> 8) & 0xFF));
}

void terminal_scroll() {
	//terminal_scrollsection(1, 0, 0, 24, 84);
}

void terminal_drawbox(unsigned char c, int x1, int y1, int x2, int y2) {
	int ybuf = y1;
	while (x1 <= x2) {
		y1 = ybuf;
		while (y1 <= y2) {
			terminal_putentryat(c, terminal_color, y1, x1);
			y1++;
		}
		x1++;
	}
}

void terminal_clearscreen() {
	for (int i = VGA_HEIGHT - 1; i >= 0; i--) {
		for (int j = 0; j < VGA_WIDTH; j++) {
			terminal_putentryat(' ', terminal_color, j, i);
		}
	}
	terminal_movecursor(0, 0);
	terminal_row = 0;
	terminal_column = 0;
}

void terminal_fillscreen(unsigned char c) {
	for (int i = VGA_HEIGHT - 1; i >= 0; i--) {
		for (int j = 0; j < VGA_WIDTH; j++) {
			terminal_putentryat(c, terminal_color, j, i);
		}
	}
	terminal_movecursor(0, 0);
	terminal_row = 0;
	terminal_column = 0;
}

void terminal_initialize(void) {
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);
	terminal_buffer = VGA_MEMORY;
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

void terminal_putentryat(unsigned char c, uint8_t color, size_t x, size_t y) {
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}

void terminal_putchar(char c) {
	if (c == '\n') {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT) {
			terminal_row = 0;
		}
	} else if (c == '\b') {
		terminal_clearscreen();
	} else {
		terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
		if (++terminal_column == VGA_WIDTH) {
			terminal_column = 0;
			if (++terminal_row >= VGA_HEIGHT) {
				terminal_row = VGA_HEIGHT;
				terminal_scroll();
			}
		}
	}
	terminal_movecursor(terminal_column, terminal_row);
}

void terminal_write(const char* data, size_t size) {
	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
}

void terminal_writem(const char* data, size_t size) {
	for (size_t i = 0; i < terminal_alignm(size); i++)
		terminal_putchar(' ');

	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
}

size_t terminal_alignm(size_t size) {
	return (VGA_WIDTH - size) - ((VGA_WIDTH - size) / 2);
}

void terminal_writestring(const char* data) {
	terminal_write(data, strlen(data));
}

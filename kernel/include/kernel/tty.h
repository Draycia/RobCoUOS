#ifndef _KERNEL_TTY_H
#define _KERNEL_TTY_H

#include <stddef.h>

void terminal_initialize(void);
void terminal_putchar(char c);
void terminal_drawbox(unsigned char c, int x1, int y1, int x2, int y2);
void terminal_fillscreen(unsigned char c);
void terminal_movecursor(int x, int y);
void terminal_write(const char* data, size_t size);
void terminal_writem(const char* data, size_t size);
size_t terminal_alignm(size_t size);
void terminal_writestring(const char* data);

#endif

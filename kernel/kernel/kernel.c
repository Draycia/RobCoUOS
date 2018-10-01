#include <stdio.h>

#include <kernel/tty.h>

void kernel_main(void) {
	terminal_initialize();
	printf("               WELCOME TO ROBCO INDUSTRIES (TM) TERMLINK PROTOCOL\n");
	
}

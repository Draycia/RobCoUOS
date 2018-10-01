#include <stdio.h>

#include <kernel/tty.h>
#include <kernel/gdt.h>

// WELCOME TO ROBCO INDUSTRIES (TM) TERMLINK
// 
// >SET TERMINAL/INQUIRE
// 
// RIT-V300
// 
// >SET FILE/PROTECTION=OWNER:RWED ACCOUNTS.F
// >SET HALT RESTART/MAINT
// 
// Initializing Robco Industries(TM) MF Boot Agent v2.3.0
// RESTROS BIOS
// RBIOS-4.02.08.00 52EE5.E7.E8
// Copyright 2201-2203 Robco Ind.
// Uppermem: 64 KB
// Root (5A8)
// Maintenance Mode
// 
// >RUN DEBUG/ACCOUNTS.F

// Show total amount of memory instead of up to 640K
// Once userland and shell are setup, use ACCOUNTS.F to store credentials
// The way it works ingame is it loads the file into memory and maintenance mode
//		renders a memory dump
// The termlink protocol is used to log into the system and recover lost credentials
// https://fallout.gamepedia.com/RobCo_Industries_Termlink

void kernel_main(void) {
	terminal_initialize();
	gdt_initialize();
}

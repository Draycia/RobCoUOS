; ==================================================================
; MikeOS -- The Mike Operating System kernel
; Copyright (C) 2006 - 2014 MikeOS Developers -- see doc/LICENSE.TXT
;
; COMMAND LINE INTERFACE
; ==================================================================


os_command_line:
	call os_clear_screen

	mov si, robco_one
	call os_print_string
	call os_print_newline
	mov si, robco_two
	call os_print_string
	call os_print_newline
	mov si, server_name
	call os_print_string
	call os_print_newline
	mov si, welcome_admin
	call os_print_string
	call os_print_newline
	mov si, box_line
	call os_print_string
	call os_print_newline
	mov si, prompt_edit
	call os_print_string
	call os_print_newline
	mov si, prompt_view
	call os_print_string
	call os_print_newline

redo:
	mov ah,0
	int 0x16
	cmp ah,0x48
	je up_pressed
	cmp ah,0x50
	je down_pressed
	cmp ah,1
	jne redo
	
down_pressed:
	call os_fatal_error

up_pressed:	
	call os_fatal_error
	
exit:
	ret

; ------------------------------------------------------------------

	input			times 256 db 0
	command			times 32 db 0

	dirlist			times 1024 db 0
	tmp_string		times 15 db 0

	file_size		dw 0
	param_list		dw 0

	prompt			db '> ', 0
	prompt_edit		db '> EDIT ENTRIES', 0
	prompt_view		db '> VIEW ENTRIES', 0

	help_text		db 'COMMANDS: CLS, DIR, LOGON', 13, 10, 0
	nofilename_msg	db 'No filename or not enough filenames', 13, 10, 0

	robco_one		db 'ROBCO INDUSTRIES UNIFIED OPERATING SYSTEM', 0
	robco_two		db '  COPYRIGHT 2075-2077 ROBCO INDUSTRIES   ', 0
	server_name		db '               -Server 0-                ', 0
	welcome_admin	db 'Welcome, admin.', 0
	box_line		db '_______________', 0

	version_msg		db 'RobcoOS ', MIKEOS_VER, 13, 10, 0

; ==================================================================


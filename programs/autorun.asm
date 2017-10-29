	BITS 16
	%INCLUDE "mikedev.inc"
	ORG 32768
	
command_line:
	call os_clear_screen
	mov si, welcome_msg
	call os_print_string

start_cmd:					; Main processing loop
	call os_read_string
	mov [input], si
	mov [param_list], di
	
	mov di, cls_string		; 'CLS' entered?
	call os_string_compare
	jc clear_screen
	
	mov di, logon_string	; 'LOGON' entered?
	call os_string_compare
	jc logon
	
	mov di, set_string		; 'SET' entered?
	call os_string_compare
	jc set
	
	mov di, run_string		; 'RUN' entered?
	call os_string_compare
	jc run
	
	mov di, start_string	; 'START' entered?
	call os_string_compare
	jc start
	
	mov di, help_string		; 'HELP' entered?
	call os_string_compare
	jc help
	
	mov di, ram_string		; 'RAM' entered?
	call os_string_compare
	jc ram
	
	mov di, debug_string	; 'DEBUG' entered?
	call os_string_compare
	jc debug
		
	mov si, user_error
	call os_print_string
	mov si, [input]
	call os_print_string
	call os_print_newline
	jmp start_cmd
	
; ------------------------------------------------------------------

debug:
	call os_dump_registers
	call os_print_string
	mov ax, [progression]
	call os_int_to_string
	mov si, ax
	call os_print_string
	jmp start_cmd

; ------------------------------------------------------------------

ram:
	call os_conv_mem		; get conventional mem up to 640k
	
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov si, .kbu_one
	call os_print_string
	call os_print_newline

	call os_upper_mem		; get extended memory from 1MB to 16MB
	
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov si, .kbu_two
	call os_print_string
	call os_print_newline

	mov ax, bx				; move segment count to ax
	mov bx, 64				; move segment size to bx
	mul bx					; multiply segment size by segment count
	call os_int_to_string	; can't output ints ;)
	mov si, ax
	call os_print_string

	mov si, .kbu_three
	call os_print_string
	call os_print_newline

	jmp start_cmd
	
.error:
	mov si, .ram_error
	call os_print_string
	call os_print_newline
	jmp start_cmd
	
	.ram_error	db 'ERROR GETTING MEMORY SIZE', 0
	.kbu_one	db ' KB conventional up to 640K', 0
	.kbu_two	db ' KB extended past 640K up to 16M', 0
	.kbu_three	db ' KB extended past 16M up to 48M', 0
	
; ------------------------------------------------------------------

logon: ; this works
	mov word si, [param_list]
	mov di, .username	; Was "admin" specified?
	call os_string_compare
	jc .admin_yes ; if so, goto .admin_yes
	mov si, user_error ; if not, error and return.
	call os_print_string
	call os_print_newline
	jmp start_cmd
	
.admin_yes:
	mov si, .pass_request
	call os_print_string
	call os_print_newline
	call os_read_string
	mov [input], si

	
	mov di, .password
	call os_string_compare
	jc .pass_success
	mov si, .pass_error
	call os_print_string
	call os_print_newline
	jmp start_cmd
	
.pass_success:
	ret

	.pass_error	db 'PASSWORD INCORRECT', 0
	.password	db 'BURIED', 0
	.username	db 'ADMIN', 0
	.logon_success	db 'LOGON SUCCESS. THIS IS A PLACEHOLDER.', 0
	.pass_request	db 'Please Enter Password...', 0

; ------------------------------------------------------------------

set:
	mov si, [param_list]
	mov di, .terminal_inquire	; "SET TERMINAL/INQUIRE" entered?
	call os_string_compare
	jc .inquire
	
	mov di, .file_protection	; "SET FILE/PROTECTION=OWNER:RWED ACCOUNTS.F" entered?
	call os_string_compare
	jc .protection
	
	mov di, .halt_restart		; "SET HALT RESTART/MAINT" entered?
	call os_string_compare
	jc .maint
	
	jmp .error
	
.inquire:
	call os_print_newline
	mov si, .rit_v300
	call os_print_string
	call os_print_newline
	call os_print_newline
	mov byte [progression], 1	; step one complete
	jmp start_cmd
	
.maint:
	cmp byte [progression], 2
	je .maint_success
	
.protection:
	cmp byte [progression], 1
	je .prot_success
	
.error:
	mov si, .err_msg
	call os_print_string
	call os_print_newline
	jmp start_cmd
	
.prot_success:
	mov byte [progression], 2	; step two complete
	jmp start_cmd
	
.maint_success:
	mov byte [progression], 3	; step three complete
	mov si, .restart_one
	call os_newline_string

	call os_upper_mem
	
	mov word [uppermem], ax		; store upper mem

	mov ax, bx					; move segment count to ax
	mov bx, 64					; move segment size to bx
	mul bx						; multiply segment size by segment count
	
	add ax, word [uppermem]		; Add extended mem to stored value
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov ah, 0Eh					; int 10h teletype function
	mov al, 4Bh					; Load character 'K' into AL
	int 10h						; Print character
	call os_print_newline
	
	mov si, .restart_two
	call os_newline_string
	call os_print_newline
	
	jmp start_cmd
	
	.ram_error			db 'ERROR GETTING MEMORY SIZE', 0	
	.err_msg			db 'An error occured when running that command', 0
	.terminal_inquire	db 'TERMINAL/INQUIRE', 0
	.file_protection	db 'FILE/PROTECTION=OWNER:RWED ACCOUNTS.F', 0
	.halt_restart		db 'HALT RESTART/MAINT', 0
	.rit_v300			db 'RIT-V300', 0
	.success			db 'SUCCESS!', 0
	.restart_one		db 'Initializing Robco Industries(TM) MF Boot Agent v2.3.0', 0x0a, 'RESTROS BIOS', 0x0a, 'RBIOS-4.02.08.00 52EE5.E7.E8', 0x0a, 'Copyright 2201-2203 Robco Ind.', 0x0a, 'Uppermem: ', 0
	.restart_two		db 'Root (5A8)', 0x0a, 'Maintenance Mode', 0

; ------------------------------------------------------------------

run:
	mov di, .debug_accounts		; "RUN DEBUG/ACCOUNTS.F" entered?
	jc .debug
	jmp start_cmd
	
.debug:
	cmp byte [progression], 3	; if so, and in stage 3, start hackign sequence
	je start
	jmp .error

.error:
	jmp start_cmd				; else return to command line
	
	.debug_accounts		db 'DEBUG/ACCOUNTS.F', 0
	.success 			db 'success', 0
	.accounts_bin		db 'ACCCOUNTS.BIN', 0

; ------------------------------------------------------------------

help:
	;SET
	;RUN
	;LOGON
	;START
	;HELP
	;CLS / CLEAR
	jmp start_cmd

; ------------------------------------------------------------------

clear_screen:
	call os_clear_screen
	jmp start_cmd

; ------------------------------------------------------------------
; ==================================================================
; ------------------------------------------------------------------

start:
	call os_clear_screen		; clear the screen and print out everything for the hacking sequence
	mov si, robco
	call os_print_string
	call os_print_newline
	mov si, enter_pass
	call os_print_string
	call os_print_newline
	call os_print_newline
	mov si, attempts
	call os_print_string
	call os_print_newline
	call os_print_newline
	mov si, hex_string
	call os_newline_string
	call os_print_newline

cmd_get:
	mov ax, 0
	cmp ax, 4
	je .lockout
	
	mov di, input				; Clear input buffer each time
	mov al, 0
	mov cx, 256
	rep stosb

	mov di, command				; And single command buffer
	mov cx, 32
	rep stosb

	mov dh, 21
	mov dl, 41
	call os_move_cursor
	mov si, blank_space
	call os_print_string
	mov dh, 21
	mov dl, 41
	call os_move_cursor
	
	mov si, slim_prompt			; Main loop; prompt for input
	call os_print_string

	mov ax, input				; Get command string from user
	call os_hack_input

	call os_print_newline

	mov ax, input				; Remove trailing spaces
	call os_string_chomp

	mov si, input				; If just enter pressed, prompt again
	cmp byte [si], 0
	je cmd_get

	mov si, input				; Separate out the individual command
	mov al, ' '
	call os_string_tokenize

	mov word [param_list], di	; Store location of full parameters

	mov ax, input
	call os_string_uppercase

	mov si, input
	
	mov di, buried				; "buried" entered?
	call os_string_compare
	jc .guess_success
	
	jmp .fail_count
	
; ------------------------------------------------------------------

.fail_count:
	mov word ax, [failures]		; incriment failure count
	inc ax
	mov word [failures], ax		; and store it
	
	cmp ax, 1
	je .guess_fail_one	
	cmp ax, 2
	je .guess_fail_two	
	cmp ax, 3
	je .guess_fail_three
	cmp ax, 4					; if failure count == 4, lockout.
	je .lockout
	
	jmp .guess_check

 .guess_fail_one:
	mov dh, 3
	mov dl, 28
	call os_move_cursor
	mov si, blank_two
	call os_print_string
	mov dh, 3
	mov dl, 0
	call os_move_cursor
	mov si, three
	call os_print_string
	
	jmp .guess_check
	
 .guess_fail_two:
	mov dh, 3
	mov dl, 25
	call os_move_cursor
	mov si, blank_two
	call os_print_string
	mov dh, 3
	mov dl, 0
	call os_move_cursor
	mov si, two
	call os_print_string
	
	jmp .guess_check
	
 .guess_fail_three:
 	mov dh, 3
	mov dl, 22
	call os_move_cursor
	mov si, blank_two
	call os_print_string
	mov dh, 3
	mov dl, 0
	call os_move_cursor
	mov si, one
	call os_print_string 
	
	jmp .guess_check

; ------------------------------------------------------------------
.move_blank:
	call os_move_cursor
	mov si, blank_space
	call os_print_string
	ret

.guess_check:
	mov dh, 15
	mov dl, 41
	call .move_blank
	
	mov dh, 15
	mov dl, 42
	call .move_blank
	
	mov dh, 16
	mov dl, 41
	call .move_blank
	
	mov dh, 17
	call .move_blank
	
	mov dh, 18
	call .move_blank
	
	mov dh, 19
	call .move_blank

	mov si, input
	
	mov di, bodies
	call os_string_compare
	jc .bodies
	
	mov di, perian
	call os_string_compare
	jc .perian

	mov di, barely
	call os_string_compare
	jc .barely
	
	mov di, indian
	call os_string_compare
	jc .indian
	
	jmp .the_fuck

 .barely:
 	mov dh, 17
	mov dl, 42
	call os_move_cursor
	mov si, barely
	call os_print_string

	mov dh, 19
	mov dl, 41
	call os_move_cursor
	mov si, two_correct
	call os_print_string
	
	jmp cmd_get

 .bodies:
 	mov dh, 17
	mov dl, 42
	call os_move_cursor
	mov si, bodies
	call os_print_string

	mov dh, 19
	mov dl, 41
	call os_move_cursor
	mov si, three_correct
	call os_print_string
	
	jmp cmd_get
	
 .perian:
 	mov dh, 17
	mov dl, 42
	call os_move_cursor
	mov si, perian
	call os_print_string

	mov dh, 19
	mov dl, 41
	call os_move_cursor
	mov si, two_correct
	call os_print_string
	
	jmp cmd_get
	
 .indian:
 	mov dh, 17
	mov dl, 41
	call os_move_cursor
	mov si, indian
	call os_print_string

	mov dh, 19
	mov dl, 41
	call os_move_cursor
	mov si, one_correct
	call os_print_string
	
	jmp cmd_get
	
; ------------------------------------------------------------------

.the_fuck:
	mov dh, 18
	mov dl, 41
	call os_move_cursor
	mov si, blank_space
	call os_print_string
	
 	mov dh, 17
	mov dl, 41
	call os_move_cursor
	mov si, blank_space
	call os_print_string

	mov dh, 19
	mov dl, 41
	call os_move_cursor
	mov si, entry_denied
	call os_print_string
	
	jmp cmd_get

; ------------------------------------------------------------------

.guess_success:
	mov dh, 15
	mov dl, 41
	call os_move_cursor
	mov si, prompt
	call os_print_string
	
	mov dh, 15
	mov dl, 42
	call os_move_cursor
	mov si, buried
	call os_print_string
	
	mov dh, 16
	mov dl, 41
	call os_move_cursor
	mov si, exact_match
	call os_print_string
	
	mov dh, 17
	mov dl, 41
	call os_move_cursor
	mov si, please_wait
	call os_print_string
	
	mov dh, 18
	mov dl, 41
	call os_move_cursor
	mov si, while_system
	call os_print_string
	
	mov dh, 19
	mov dl, 41
	call os_move_cursor
	mov si, is_accessed
	call os_print_string
	call os_hide_cursor
	
	mov ax, 30
	call os_pause
	
	call os_show_cursor
	ret
		
; ------------------------------------------------------------------

.lockout:
	call os_clear_screen		; in the future, create a file and check if it exists on boot
	mov ax, total_failure		; and use a custom lockout screen
	call os_fatal_error			; instead of this

; 
; ==================================================================

	input			times 256 db 0
	command			times 32 db 0
	uppermem		db 0
	param_list		dw 0
	prompt			db '> ', 0
	slim_prompt		db '>', 0
	welcome_msg		db '               WELCOME TO ROBCO INDUSTRIES (TM) TERMLINK PROTOCOL', 13, 10, 0
	user_error		db 'UNKNOWN COMMAND: ', 0
	cls_string		db 'CLS', 0
	logon_string	db 'LOGON', 0
	set_string		db 'SET', 0
	run_string		db 'RUN', 0
	start_string	db 'START', 0
	help_string		db 'HELP', 0
	ram_string		db 'RAM', 0
	debug_string	db 'DEBUG', 0
	progression	db 0
	failures	dw 0	
	one			db '1', 0
	two			db '2', 0
	three		db '3', 0	
	blank_space db '             ', 0
	blank_two	db '  ', 0	
	perian		db 'PERIAN', 0
	buried		db 'BURIED', 0
	bodies		db 'BODIES', 0
	barely		db 'BARELY', 0
	indian		db 'INDIAN', 0	
	total_failure	db 'TERMINAL LOCKED - PLEASE CONTACT AN ADMINISTRATOR', 0	
	entry_denied	db '>Entry denied', 0
	one_correct		db '>1/6 correct.', 0
	two_correct		db '>2/6 correct.', 0
	three_correct	db '>3/6 correct.', 0	
	exact_match		db '>Exact match!', 0
	please_wait		db '>Please wait ', 0
	while_system	db '>while system', 0
	is_accessed		db '>is accessed.', 0	
	robco		db 'ROBCO INDUSTRIES (TM) TERMLINK PROTOCOL', 0
	enter_pass	db 'ENTER PASSWORD NOW', 0
	attempts	db '4 ATTEMPT(S) LEFT: [] [] [] []', 0	
	hex_string	db '0xF748 ;_$!&*[,,&*{ 0xF814 [*@&//_>}]"%', 0x0a, '0xF754 :/$+&-(,@^/) 0xF820 !:_<!:^;]%,)', 0x0a, '0xF760 *,[(*,?,_@>P 0xF82C !"%*$:*/?)"(', 0x0a, '0xF76C ERIAN]%?-+<{ 0xF838 :/")$}>#!BOD', 0x0a, '0xF778 (;=>,/_+$_-= 0xF844 IES>=#$[^+"{', 0x0a, '0xF784 _$@+.,{.@>*; 0xF850 ^,:+[,(#-[%)', 0x0a, '0xF790 @@{-,,-]<*[] 0xF85C =(&&<]{-$"<!', 0x0a, '0xF79C {{?*?}->(,"> 0xF868 .&#_<{[#?-*$', 0x0a, '0xF7A8 :^=&([/%<$}@ 0xF874 !,$:-:)-]^IN', 0x0a, '0xF7B4 )_@;:$;*=":_ 0xF880 DIAN}@=.(>%#', 0x0a, '0xF7C0 >&>^]!/)"+{, 0xF88C ).+$*[{>_@;}', 0x0a, '0xF7CC $#?]/_[+{.,: 0xF898 #/#$)<];*%?.', 0x0a, '0xF7D8 :="%,)]}!;/$ 0xF8A4 *_%%,)[#.-%)', 0x0a, '0xF7E4 +,*."$}%)};B 0xF8B0 ]>.){.-{>"}"', 0x0a, '0xF7F0 URIED)"?})&: 0xF8BC [{%.?%*}.>__', 0x0a, '0xF7FC %&[("-+/?<(( 0xF8C8 <]]<;!@)%>;.', 0x0a, '0xF808 &}{:,><=-_{< 0xF8D4 &$;%)>_]_-)*', 0

; ==================================================================
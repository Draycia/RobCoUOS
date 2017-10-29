; ==================================================================
; VARIOUS SYSTEM CALLS
; ==================================================================

; ------------------------------------------------------------------
; os_newline_string -- Extended os_print_string with newline support
; IN: SI = message location (zero-terminated string)
; OUT: Nothing (registers preserved)

os_newline_string:
	pusha

	mov ah, 0Eh			; int 10h teletype function

.repeat:
	lodsb				; Get char from string
	cmp al, 0
	je .done			; If char is zero, end of string
	cmp al, 0x0a		; 0x0a = ascii newline
	je .newline			; If char is newline, print newline

	int 10h				; Print char
	jmp .repeat			; And move on to next char

.newline:
	call os_print_newline
	jmp .repeat

.done:
	popa
	ret
	
; ------------------------------------------------------------------
; os_read_string -- Input string from user
; IN: Nothing
; OUT: SI message location, DI param list location (both zero-terminated strings)

os_read_string:
	pusha

.repeat:
	mov di, .input
	mov al, 0
	mov cx, 256
	rep stosb

	mov di, .command
	mov cx, 32
	rep stosb

	mov si, .prompt
	call os_print_string

	mov ax, .input
	call os_input_string

	call os_print_newline

	mov ax, .input
	call os_string_chomp
	
	cmp byte [si], 0
	je .repeat

	mov si, .input			; Separate out the individual command
	mov al, ' '
	call os_string_tokenize

	mov word [.param_list], di	; Store location of full parameters

	mov si, .input			; Store copy of command for later modifications
	mov di, .command
	call os_string_copy

	; First, let's check to see if it's an internal command...
	mov ax, .input
	call os_string_uppercase

	popa
	mov si, .input
	mov di, word [.param_list]
	ret

	.input			times 256 db 0
	.command		times 32 db 0
	.prompt			db '> ', 0
	.param_list		dw 0
	
; ------------------------------------------------------------------
; os_conv_mem -- Returns conventional memory found (0KB to 640KB)
; IN: Nothing
; OUT: AX amount of memory found in KB
	
os_conv_mem:
	clc
	int 0x12
	jc .error
	cmp ax, 637
	jg .correct_conv
	ret
	
.correct_conv:
	mov ax, 640
	ret
	
.error:
	; Print some error shit
	ret

; ------------------------------------------------------------------
; os_upper_mem -- Returns conventional memory found (0KB to 640KB)
; IN: Nothing
; OUT: CBA to remember

os_upper_mem:
	xor cx, cx
	xor dx, dx
	mov ax, 0xe801
	int 0x15		; request upper memory size
	jc short .error
	cmp ah, 0x86		; unsupported function
	je short .error
	cmp ah, 0x80		; invalid command
	je short .error

	ret
	
.error:
	mov si, .ram_error
	call os_print_string
	call os_print_newline
	ret
	
	.ram_error	db 'ERROR GETTING MEMORY SIZE', 0

; ------------------------------------------------------------------
; os_input_string -- Take string from keyboard entry
; IN/OUT: AX = location of string, other regs preserved
; (Location will contain up to 255 characters, zero-terminated)

os_hack_input:
	pusha

	mov di, ax			; DI is where we'll store input (buffer)
	mov cx, 0			; Character received counter for backspace


.more:					; Now onto string getting
	call os_wait_for_key

	cmp al, 13			; If Enter key pressed, finish
	je .done

	cmp al, 8			; Backspace pressed?
	je .backspace			; If not, skip following checks

	cmp al, ' '			; In ASCII range (32 - 126)?
	jb .more			; Ignore most non-printing characters

	cmp al, '~'
	ja .more

	jmp .nobackspace


.backspace:
	cmp cx, 0			; Backspace at start of string?
	je .more			; Ignore it if so

	call os_get_cursor_pos		; Backspace at start of screen line?
	cmp dl, 0
	je .backspace_linestart

	pusha
	mov ah, 0Eh			; If not, write space and move cursor back
	mov al, 8
	int 10h				; Backspace twice, to clear space
	mov al, 32
	int 10h
	mov al, 8
	int 10h
	popa

	dec di				; Character position will be overwritten by new
					; character or terminator at end

	dec cx				; Step back counter

	jmp .more


.backspace_linestart:
	dec dh				; Jump back to end of previous line
	mov dl, 79
	call os_move_cursor

	mov al, ' '			; Print space there
	mov ah, 0Eh
	int 10h

	mov dl, 79			; And jump back before the space
	call os_move_cursor

	dec di				; Step back position in string
	dec cx				; Step back counter

	jmp .more


.nobackspace:
	pusha
	mov ah, 0Eh			; Output entered, printable character
	int 10h
	popa

	stosb				; Store character in designated buffer
	inc cx				; Characters processed += 1
	cmp cx, 12			; Make sure we don't exhaust buffer
	jae near .done

	jmp near .more			; Still room for more


.done:
	mov ax, 0
	stosb

	popa
	ret

; ------------------------------------------------------------------

















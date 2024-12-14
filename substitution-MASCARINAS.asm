section .bss
    input resb 128    ; Buffer for user input 
    output resb 128   ; Output buffer

section .text
    global _start

_start:
    ; Prompt user for input
    mov eax, 1          ; syscall: write
    mov edi, 1          ; file descriptor: stdout
    mov rsi, prompt     ; message to write
    mov edx, prompt_len ; message length
    syscall

    ; Read user input
    mov eax, 0          ; syscall: read
    mov edi, 0          ; file descriptor: stdin
    mov rsi, input      ; buffer to store input
    mov edx, 128        ; maximum bytes to read
    syscall

    ; Remove newline character from input
    mov rdi, input      ; Address of input buffer
.trim_newline:
    lodsb               ; Load next byte into AL
    cmp al, 10          ; Check if newline character (LF)
    je .null_terminate  ; Replace newline with null terminator
    cmp al, 0           ; Check for end of string
    je .null_terminate  ; Null-terminate if end reached
    stosb               ; Store character in output buffer
    jmp .trim_newline
.null_terminate:
    dec rdi            ; Adjust pointer to overwrite newline
    mov byte [rdi], 0  ; Null-terminate the string

    ; Load address of input and output buffers
    mov esi, input     ; Source index (input)
    mov edi, output    ; Destination index (output)

    ; Define a simple substitution cipher key (A-Z mapped to other letters)
    ; Example: A->Q, B->W, C->E, ..., Z->P
    ; This can be changed to any other substitution key as needed
    ; Substitution key is hardcoded in a table
    ; Each index corresponds to a letter A-Z (0-25)
    ; Here, we use a simple shifting pattern for illustration

    ; Substitution key table for A-Z
    ; The ASCII values for Q, W, E, etc. will be loaded into registers
    mov byte [substitution_table], 'Q'
    mov byte [substitution_table + 1], 'W'
    mov byte [substitution_table + 2], 'E'
    mov byte [substitution_table + 3], 'R'
    mov byte [substitution_table + 4], 'T'
    mov byte [substitution_table + 5], 'Y'
    mov byte [substitution_table + 6], 'U'
    mov byte [substitution_table + 7], 'I'
    mov byte [substitution_table + 8], 'O'
    mov byte [substitution_table + 9], 'P'
    mov byte [substitution_table + 10], 'A'
    mov byte [substitution_table + 11], 'S'
    mov byte [substitution_table + 12], 'D'
    mov byte [substitution_table + 13], 'F'
    mov byte [substitution_table + 14], 'G'
    mov byte [substitution_table + 15], 'H'
    mov byte [substitution_table + 16], 'J'
    mov byte [substitution_table + 17], 'K'
    mov byte [substitution_table + 18], 'L'
    mov byte [substitution_table + 19], 'Z'
    mov byte [substitution_table + 20], 'X'
    mov byte [substitution_table + 21], 'C'
    mov byte [substitution_table + 22], 'V'
    mov byte [substitution_table + 23], 'B'
    mov byte [substitution_table + 24], 'N'
    mov byte [substitution_table + 25], 'M'

    ; Loop through each character of the input string
.loop:
    lodsb             ; Load byte at [esi] into AL
    cmp al, 0         ; Check if end of string (null terminator)
    je .done          ; If null terminator, end loop

    ; Check if the character is an uppercase letter (A-Z)
    cmp al, 'A'
    jl .not_upper     ; Skip if less than 'A'
    cmp al, 'Z'
    jg .not_upper     ; Skip if greater than 'Z'

    ; Find index of the letter in the alphabet (0-25)
    sub al, 'A'       ; Convert character to 0-25 range
    mov bl, al        ; Store the index in BL

    ; Zero-extend BL to RBX to handle 64-bit addressing
    movzx rbx, bl     ; Zero-extend BL into RBX (64-bit)

    ; Get the substituted letter from the table
    mov al, [substitution_table + rbx]

    ; Store the substituted character in output buffer
    stosb

    jmp .loop

.not_upper:
    ; Non-uppercase letters are copied unchanged to the output
    stosb
    jmp .loop

.done:
    ; Null-terminate the output string
    mov byte [edi], 0

    ; Display the output
    mov eax, 1          ; syscall: write
    mov edi, 1          ; file descriptor: stdout
    mov rsi, output_msg ; message to write before output
    mov edx, output_msg_len ; message length
    syscall

    mov eax, 1          ; syscall: write
    mov edi, 1          ; file descriptor: stdout
    mov rsi, output     ; message to write (ciphered text)
    mov edx, 128        ; maximum bytes to write
    syscall

    ; Exit program
    mov eax, 60         ; syscall: exit
    xor edi, edi        ; status: 0
    syscall

section .data
    prompt db 'Enter text to encrypt using substitution cipher (uppercase A-Z only): ', 0
    prompt_len equ $-prompt
    output_msg db 'Encrypted text: ', 0
    output_msg_len equ $-output_msg

section .bss
    substitution_table resb 26 ; Substitution table for A-Z

; Program: Atbash Cipher in Assembly
; Encrypts and decrypts a given text using the Atbash cipher.
; Assumes input text is uppercase alphabet only (A-Z).

section .bss
    input resb 128   ; Buffer for user input (128 bytes)
    output resb 128  ; Output buffer

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
    mov byte [rdi], 0 ; Null-terminate the string

    ; Load address of input and output buffers
    mov esi, input    ; Source index (input)
    mov edi, output   ; Destination index (output)

    ; Loop through each character of the input string
.loop:
    lodsb             ; Load byte at [esi] into AL
    cmp al, 0         ; Check if end of string (null terminator)
    je .done          ; If null terminator, end loop

    ; Apply Atbash cipher transformation
    sub al, 'A'       ; Convert character to 0-25 range
    mov bl, 25        ; Total letters in alphabet - 1
    sub bl, al        ; Compute reverse position
    add bl, 'A'       ; Convert back to ASCII
    mov al, bl        ; Store result in AL

    stosb             ; Store AL into [edi]
    jmp .loop         ; Continue to next character

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
    mov rsi, output     ; message to write (encrypted text)
    mov edx, 128        ; maximum bytes to write
    syscall

    ; Exit program
    mov eax, 60         ; syscall: exit
    xor edi, edi        ; status: 0
    syscall

section .data
    prompt db 'Enter text to encrypt/decrypt (uppercase A-Z only): ', 0
    prompt_len equ $-prompt
    output_msg db 'Encrypted/Decrypted text: ', 0
    output_msg_len equ $-output_msg

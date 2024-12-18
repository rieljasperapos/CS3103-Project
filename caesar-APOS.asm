section .data
    prompt db "Enter your text: ", 0
    output db "Result: ", 0
    newline db 13, 10, 0  ; Carriage return and newline
    text_buffer times 128 db 0
    shift_value db 3      ; Caesar cipher shift value

section .bss
    text_length resb 1

section .text
    extern GetStdHandle, ReadConsoleA, WriteConsoleA, ExitProcess
    global _start

_start:
    ; Get handle to standard input (STD_INPUT_HANDLE = -10)
    mov rcx, -10
    call GetStdHandle
    mov r12, rax  ; Save input handle

    ; Get handle to standard output (STD_OUTPUT_HANDLE = -11)
    mov rcx, -11
    call GetStdHandle
    mov r13, rax  ; Save output handle

    ; Write prompt to stdout
    lea rdx, [prompt]
    mov r8, 16                ; Length of the prompt
    mov r9, 0                 ; Reserved (must be 0)
    mov rcx, r13              ; Output handle
    call WriteConsoleA

    ; Read user input from stdin
    lea rdx, [text_buffer]
    mov r8, 128               ; Max buffer size
    lea r9, [text_length]     ; Pointer to store bytes read
    mov rcx, r12              ; Input handle
    call ReadConsoleA

    ; Remove trailing newline character
    movzx rax, byte [text_length]
    dec rax                  ; Adjust for newline (CRLF)
    mov byte [text_buffer + rax], 0  ; Null-terminate string

    ; Apply Caesar cipher (shift by 3)
    lea rsi, [text_buffer]  ; Load address of the text_buffer
    movzx rdx, byte [shift_value]  ; Load the shift value
caesar_loop:
    mov al, byte [rsi]      ; Load a character from the buffer
    test al, al             ; Check for null terminator
    jz caesar_done          ; If null, we're done

    ; If the character is a letter (A-Z or a-z), apply the Caesar shift
    cmp al, 'A'
    jl caesar_next_char
    cmp al, 'Z'
    jg caesar_check_lower
    add al, dl              ; Shift the character
    cmp al, 'Z' + 1
    jle caesar_store_char
    sub al, 26              ; Wrap around if past 'Z'
    jmp caesar_store_char

caesar_check_lower:
    cmp al, 'a'
    jl caesar_next_char
    cmp al, 'z'
    jg caesar_next_char
    add al, dl              ; Shift the character
    cmp al, 'z' + 1
    jle caesar_store_char
    sub al, 26              ; Wrap around if past 'z'

caesar_store_char:
    mov byte [rsi], al      ; Store the shifted character

caesar_next_char:
    inc rsi                 ; Move to the next character
    jmp caesar_loop

caesar_done:

    ; Write "Hello, " to stdout
    lea rdx, [output]
    mov r8, 7                 ; Length of the output
    mov r9, 0                 ; Reserved (must be 0)
    mov rcx, r13              ; Output handle
    call WriteConsoleA

    ; Write the users text input to stdout (after ciphering)
    lea rdx, [text_buffer]
    movzx r8, byte [text_length]  ; Length of the text
    dec r8                        ; Remove newline character
    mov r9, 0
    mov rcx, r13
    call WriteConsoleA

    ; Write a newline to stdout
    lea rdx, [newline]
    mov r8, 2                 ; Length of the newline
    mov r9, 0
    mov rcx, r13
    call WriteConsoleA

    ; Exit the program
    xor rcx, rcx
    call ExitProcess

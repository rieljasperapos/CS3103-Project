section .bss
    input resb 128     ; Buffer for user input (128 bytes)
    output resb 128    ; Buffer for output (encrypted/decrypted text)

section .data
    prompt db 'Enter text to encrypt/decrypt (A-Z only): ', 0
    prompt_len equ $ - prompt

    mode_prompt db 'Choose mode: [E]ncrypt or [D]ecrypt: ', 0
    mode_prompt_len equ $ - mode_prompt

    result_msg db 'Result: ', 0
    result_msg_len equ $ - result_msg

    subst_table db 'QWERTYUIOPASDFGHJKLZXCVBNM' ; Substitution table for encryption
    reverse_table db 26 dup(0)                 ; Placeholder for the reverse table

section .text
    global _start

_start:
    ; Build the reverse table for decryption
    mov rsi, subst_table   ; Source: substitution table
    mov rdi, reverse_table ; Destination: reverse table
    mov rcx, 26            ; Number of characters to process
    xor rbx, rbx           ; RBX will store the index (0-25)

build_reverse_table:
    mov al, [rsi + rbx]    ; Get the character at subst_table[index]
    sub al, 'A'            ; Convert to 0-25 range
    mov [rdi + rax], bl    ; reverse_table[subst_table[index]] = index
    inc rbx                ; Move to next index in subst_table
    loop build_reverse_table

    ; Prompt user for input
    mov eax, 1
    mov edi, 1
    mov rsi, prompt
    mov edx, prompt_len
    syscall

    ; Read user input
    mov eax, 0
    mov edi, 0
    mov rsi, input
    mov edx, 128
    syscall

    ; Prompt user for mode selection (E/D)
    mov eax, 1
    mov edi, 1
    mov rsi, mode_prompt
    mov edx, mode_prompt_len
    syscall

    ; Read the mode selection
    mov eax, 0
    mov edi, 0
    mov rsi, input + 127  ; Use last byte of input buffer for mode selection
    mov edx, 1
    syscall
    mov al, [input + 127] ; Load user's mode choice into AL

    ; Compare user's choice
    cmp al, 'E'
    je encrypt_mode       ; Jump to encryption mode if 'E'
    cmp al, 'D'
    je decrypt_mode       ; Jump to decryption mode if 'D'

    ; Invalid input: Exit the program
    jmp exit_program

encrypt_mode:
    ; Set up for encryption
    mov rsi, input        ; Source: input buffer
    mov rdi, output       ; Destination: output buffer
    mov rbx, subst_table  ; Table for encryption
    jmp process_text

decrypt_mode:
    ; Set up for decryption
    mov rsi, input        ; Source: input buffer
    mov rdi, output       ; Destination: output buffer
    mov rbx, reverse_table; Table for decryption

process_text:
    lodsb                 ; Load next byte from input into AL
    cmp al, 0             ; End of input string?
    je output_result      ; If null terminator, finish

    cmp al, 'A'
    jb copy_char          ; If below 'A', just copy the character
    cmp al, 'Z'
    ja copy_char          ; If above 'Z', just copy the character

    ; Perform substitution
    sub al, 'A'           ; Convert character to 0-25 range
    movzx rax, al         ; Zero-extend AL for indexing
    mov al, [rbx + rax]   ; Get corresponding character from the table
    add al, 'A'           ; Convert back to ASCII
    stosb                 ; Store the result in the output buffer
    jmp process_text

copy_char:
    stosb                 ; Copy non-alphabetic characters as is
    jmp process_text

output_result:
    ; Null-terminate the output
    mov byte [rdi], 0

    ; Display result message
    mov eax, 1
    mov edi, 1
    mov rsi, result_msg
    mov edx, result_msg_len
    syscall

    ; Display the output text
    mov eax, 1
    mov edi, 1
    mov rsi, output
    mov edx, 128
    syscall

exit_program:
    ; Exit program
    mov eax, 60
    xor edi, edi
    syscall

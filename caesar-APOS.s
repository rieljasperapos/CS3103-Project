section .bss
    encrypted_buffer resb 256      ; Buffer for encrypted result

section .text
    global _start

_start:
    ; Print input prompt
    mov eax, 1                     ; sys_write
    mov edi, 1                     ; file descriptor (stdout)
    mov esi, input_prompt          ; pointer to message
    mov edx, input_prompt_len      ; message length
    syscall

    ; Read user input
    mov eax, 0                     ; sys_read
    mov edi, 0                     ; file descriptor (stdin)
    mov esi, input                 ; pointer to buffer
    mov edx, 256                   ; buffer size
    syscall

    ; Encrypt the input string
    lea esi, [input]               ; Load address of input buffer
    lea edi, [encrypted_buffer]    ; Load address of encrypted buffer
    movzx ecx, byte [shift]        ; Load the shift value as an 8-bit value

encrypt_loop:
    mov al, byte [esi]             ; Load current character (8-bit register)
    cmp al, 0                      ; Check if null terminator
    je done_encrypt                ; Exit loop if null

    ; Check if uppercase letter
    cmp al, 'A'
    jl not_upper                   ; If less than 'A', not uppercase
    cmp al, 'Z'
    jg not_upper                   ; If greater than 'Z', not uppercase

    ; Apply Caesar cipher for uppercase letters
    sub al, 'A'                    ; Normalize to 0-25
    add al, cl                     ; Apply shift
    cmp al, 26                     ; Check for wrap-around
    jl no_wrap_upper               ; If less than 26, no wrap needed
    sub al, 26                     ; Wrap around
no_wrap_upper:
    add al, 'A'                    ; Restore ASCII value
    jmp write_char                 

not_upper:
    ; Check if lowercase letter
    cmp al, 'a'
    jl write_char                  ; If less than 'a', just copy it
    cmp al, 'z'
    jg write_char                  ; If greater than 'z', just copy it

    ; Apply Caesar cipher for lowercase letters
    sub al, 'a'                    ; Normalize to 0-25
    add al, cl                     ; Apply shift
    cmp al, 26                     ; Check for wrap-around
    jl no_wrap_lower               ; If less than 26, no wrap needed
    sub al, 26                     ; Wrap around
no_wrap_lower:
    add al, 'a'                    ; Restore ASCII value

write_char:
    mov byte [edi], al             ; Write character to output buffer
    inc esi                        ; Move to next input character
    inc edi                        ; Move to next output character
    jmp encrypt_loop               ; Repeat for next character

done_encrypt:
    mov byte [edi], 0              ; Null-terminate the encrypted string

    ; Write the encrypted result to stdout
    mov eax, 1                     ; sys_write
    mov edi, 1                     ; file descriptor (stdout)
    lea esi, [encrypted_buffer]    ; Pointer to encrypted string
    mov edx, 256                   ; Length of buffer (max size)
    syscall

    ; Exit the program
    mov eax, 60                    ; sys_exit
    xor edi, edi                   ; Exit code 0
    syscall

section .data
    input_prompt db "Enter a string: ", 0
    input_prompt_len equ $ - input_prompt
    input db 256 dup(0)            ; Buffer for user input (256 bytes)
    shift db 3                     ; Shift amount for encryption

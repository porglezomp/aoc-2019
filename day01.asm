SYS_EXIT: equ   0x2000001
SYS_READ: equ   0x2000003
SYS_WRITE: equ  0x2000004
STDIN: equ      0
STDOUT: equ     1
NEWLINE: equ    10

global start

start:
    mov rax, 413
    call print_num
    call newline

exit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

print_num:
    mov rbp, rsp
    mov rsi, 0 ;; no characters written yet
    mov rdi, 10 ;; need to divide by 10

    ;; Fill a buffer with digits.
    ;; We fill the buffer backwards from the least significant digit.
print_num_loop:
    mov rdx, 0
    div rdi  ;; rax /= 10
    dec rsp  ;; address handling...
    inc rsi
    add rdx, '0'
    mov BYTE [rsp], dl
    cmp rax, 0
    jne print_num_loop

    ;; Write the buffer to stdout
    ;; write(stdout, rsp, rsi)
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rdx, rsi
    mov rsi, rsp
    syscall

    mov rsp, rbp
    ret

newline:
    ;; Make a 1 character string with a newline
    sub rsp, 1
    mov BYTE [rsp], NEWLINE

    ;; write(stdout, "\n", 1)
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall

    add rsp, 1
    ret

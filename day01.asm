SYS_EXIT: equ   0x2000001
SYS_READ: equ   0x2000003
SYS_WRITE: equ  0x2000004
STDIN: equ      0
STDOUT: equ     1
NEWLINE: equ    10

global start

start:
    call tests
    mov r8, 0
    mov r9, 0
main_loop:
    call read_num
    cmp rax, 0
    je main_loop_done
    mov r10, rax
    call rocket_equation
    add r8, rax
    mov rax, r10
    call rocket_equation2
    add r9, rax
    jmp main_loop

main_loop_done:
    mov rax, r8
    call print_num
    call newline

    mov rax, r9
    call print_num
    call newline

exit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall


tests:
    mov rax, 14
    call rocket_equation2
    mov rdi, 1
    cmp rax, 2
    jne fail

    mov rax, 1969
    call rocket_equation2
    mov rdi, 2
    cmp rax, 966
    jne fail

    mov rax, 100756
    call rocket_equation2
    mov rdi, 3
    cmp rax, 50346
    jne fail

    ret

fail:
    mov rax, SYS_EXIT
    syscall


rocket_equation:
    mov rdx, 0
    mov rbx, 3
    idiv rbx
    sub rax, 2
    ret


rocket_equation2:
    push r8
    mov r8, 0
rocket_equation2_loop:
    call rocket_equation
    cmp rax, 0
    jle rocket_equation2_loop_end
    add r8, rax
    jmp rocket_equation2_loop
rocket_equation2_loop_end
    mov rax, r8
    pop r8
    ret


;; returns the read number on stdout
;; reads until a newline
read_num:
    push r8
    mov rbx, 0
    mov r8, 10
    sub rsp, 1

read_num_loop:
    mov BYTE [rsp], NEWLINE ;; store a newline so at EOF we see a newline
    ;; read(stdin, sp, 1)
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, rsp
    mov rdx, 1
    syscall

    cmp BYTE [rsp], NEWLINE
    je  read_num_done

    mov rax, rbx
    mul r8  ;; rax *= 10
    movzx rbx, BYTE [rsp]
    sub rbx, '0'
    add rbx, rax
    jmp read_num_loop

read_num_done:
    add rsp, 1
    pop r8
    mov rax, rbx
    ret


;; rax contains the number to print
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

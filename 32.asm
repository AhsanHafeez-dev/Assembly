SECTION .text
GLOBAL _start

; ------------------------------------------------------------------
; Program Purpose:
; Linux x86 (32-bit) Assembly
; Prints "Hello World" followed by a newline to stdout.
; Uses Linux system calls via INT 0x80:
;   - sys_write (eax=4)
;   - sys_exit  (eax=1)
; ------------------------------------------------------------------

_start:
    ; sys_write (int 0x80, eax=4)
    mov eax,4                ; syscall number 4 = sys_write
    mov ebx,1                ; file descriptor 1 = stdout
    mov ecx,message          ; pointer to message buffer
    mov edx,messageLength    ; length of message
    int 0x80                 ; invoke kernel

    ; sys_exit (int 0x80, eax=1)
    mov eax,1                ; syscall number 1 = sys_exit
    mov ebx,0                ; return code = 0
    int 0x80                 ; exit program

SECTION .data
message: db "Hello World",0xA,0x0 ; "Hello World\n" + null terminator
messageLength: equ $-message       ; length of message (without needing to hardcode)

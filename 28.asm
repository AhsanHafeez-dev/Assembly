; ---------------------------------------------------------
; Program Purpose:
; This program reads a string from the user (up to 80 chars)
; using DOS buffered input (INT 21h / AH=0Ah).
; After input, it prints a greeting "Hello" and then echoes
; the string entered by the user.
; ---------------------------------------------------------

[org 0x0100]               ; COM file origin at offset 0x100
jmp start                  ; jump to start of code

; ---------------------------
; Data Section
; ---------------------------
maxlength: dw 80           ; maximum input length (not used in buffered input here)
message   : db 10,13,'Hello ',10,13,'$'  ; greeting message with CR+LF
buffer    : db 80          ; first byte = max buffer size (80 characters)
           db 0            ; second byte = number of chars actually entered
           times 80 db 0   ; actual input buffer space

; ---------------------------
; Code Section
; ---------------------------
start:
    mov dx,buffer          ; DX points to buffer structure
    mov ah,0x0A            ; DOS function 0Ah - buffered input
    int 0x21               ; read input from keyboard

    ; At this point:
    ; buffer[0] = max size (80)
    ; buffer[1] = number of characters read
    ; buffer[2..] = actual characters entered (no '$' terminator)

    ; Add '$' terminator to user input so DOS print (AH=09h) can work
    mov bh,0
    mov bl,[buffer+1]      ; BL = number of chars entered
    mov byte [buffer+2+bx],'$' ; place '$' after last char

    ; Print greeting message
    mov dx,message
    mov ah,9               ; DOS function 09h - print string (terminated by '$')
    int 0x21

    ; Print user input
    mov dx,buffer+2        ; DX points to actual string entered
    mov ah,9               ; DOS function 09h
    int 0x21

    ; Exit program
    mov ax,0x4C00          ; DOS terminate program (AH=4Ch, AL=0)
    int 0x21

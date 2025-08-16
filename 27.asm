[org 0x0100]               ; program origin (COM file starts at offset 0x100)
jmp start                  ; jump to start of program

; ---------------------------
; Data Section
; ---------------------------
maxlength: dw 80           ; maximum length of input string (80 chars)
message   : db 10,13,'Hello $' ; greeting message, with CR+LF at start
buffer    : times 81 db 0  ; space for input string (80 chars + '$' terminator)

; ---------------------------
; Code Section
; ---------------------------
start:
    mov cx,[maxlength]     ; load maximum characters allowed into CX (loop counter)
    mov si,buffer          ; SI points to start of buffer

nextchar:
    mov ah,1               ; DOS function 01h - read character from keyboard
    int 0x21               ; wait for key and return ASCII in AL

    cmp al,13              ; check if Enter key (ASCII 13) was pressed
    je exit                ; if Enter pressed, jump to exit

    mov [si],al            ; store character in buffer
    inc si                 ; move to next buffer position
    loop nextchar          ; decrement CX and repeat until CX=0

exit:
    mov byte [si],'$'      ; append '$' terminator for DOS string printing

    mov dx,message         ; point DX to greeting message
    mov ah,9               ; DOS function 09h - display string (terminated by '$')
    int 0x21               ; print greeting

    mov dx,buffer          ; point DX to start of input buffer
    mov ah,9               ; DOS function 09h - display string
    int 0x21               ; print user input

    mov ax,0x4C00          ; DOS terminate program (AH=4Ch, AL=00 return code)
    int 0x21

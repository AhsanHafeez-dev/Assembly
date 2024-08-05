[org 0x0100]        ; Set the origin to 0x0100 for COM file format

mov al, [num1]      ; Load the byte at memory location num1 into AL (num1 = 5)
mov bl, [num1+1]    ; Load the byte at memory location num1+1 into BL (num1+1 = 10)
add al, bl          ; Add the value in BL (10) to AL (5), result is 15
mov bl, [num1+2]    ; Load the byte at memory location num1+2 into BL (num1+2 = 15)
add al, bl          ; Add the value in BL (15) to AL (15), result is 30
mov [num1+3], al    ; Store the result (30) into memory location num1+3

mov ax, 0x4c00      ; Load 0x4c00 into AX (function 4Ch of DOS interrupt to terminate program)
int 0x21            ; Interrupt 21h to call DOS function (terminate program)

num1 : db 5, 10, 15, 0 ; Define byte data at label num1 with values 5, 10, 15, and 0

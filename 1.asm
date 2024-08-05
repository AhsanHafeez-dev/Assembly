[org 0x0100]    ; Set the origin to 0x0100 for COM file format

mov ax, 5       ; Load the value 5 into register AX
mov bx, 10      ; Load the value 10 into register BX
add ax, bx      ; Add the value in BX (10) to AX (5), result is 15

mov bx, 15      ; Load the value 15 into register BX
add ax, bx      ; Add the value in BX (15) to AX (15), result is 30

mov ax, 0x4c00  ; Load 0x4c00 into AX (function 4Ch of DOS interrupt to terminate program)
int 0x21        ; Interrupt 21h to call DOS function (terminate program)

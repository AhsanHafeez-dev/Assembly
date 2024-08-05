[org 0x0100]        ; Set the origin to 0x0100 for COM file format

mov ax, [num1]      ; Load the value at memory location num1 into AX (num1 = 5)
mov bx, [num1+2]    ; Load the value at memory location num1+2 into BX (num1+2 = 10)
add ax, bx          ; Add the value in BX (10) to AX (5), result is 15
mov bx, [num1+4]    ; Load the value at memory location num1+4 into BX (num1+4 = 15)
add ax, bx          ; Add the value in BX (15) to AX (15), result is 30
mov [num1+6], ax    ; Store the result (30) into memory location num1+6

mov ax, 0x4c00      ; Load 0x4c00 into AX (function 4Ch of DOS interrupt to terminate program)
int 0x21            ; Interrupt 21h to call DOS function (terminate program)

num1 : dw 5, 10, 15, 0 ; Define word data at label num1 with values 5, 10, 15, and 0

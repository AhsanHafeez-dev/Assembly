org 0x0100      ; Set the origin to 0x0100 for COM file format

mov ax, [num1]  ; Load the value at memory location num1 into register AX (num1 = 5)
mov bx, [num2]  ; Load the value at memory location num2 into register BX (num2 = 10)
add ax, bx      ; Add the value in BX (10) to AX (5), result is 15
mov bx, [num3]  ; Load the value at memory location num3 into register BX (num3 = 15)
add ax, bx      ; Add the value in BX (15) to AX (15), result is 30
mov [num4], ax  ; Store the result (30) into memory location num4

mov ax, 0x4c00  ; Load 0x4c00 into AX (function 4Ch of DOS interrupt to terminate program)
int 0x21        ; Interrupt 21h to call DOS function (terminate program)

num1 : dw 5     ; Define word data at label num1 with value 5
num2 : dw 10    ; Define word data at label num2 with value 10
num3 : dw 15    ; Define word data at label num3 with value 15
num4 : dw 0     ; Define word data at label num4 with value 0 (initially)

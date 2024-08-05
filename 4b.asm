[org 0x0100]        ; Set the origin to 0x0100 for COM file format

mov bx, num1        ; Load the address of num1 into BX
mov ax, [bx]        ; Load the value at memory location pointed to by BX (num1 = 5) into AX
add bx, 2           ; Increment BX to point to the next word (num1+2)
add ax, [bx]        ; Add the value at memory location pointed to by BX (num1+2 = 10) to AX, result is 15
add bx, 2           ; Increment BX to point to the next word (num1+4)
add ax, [bx]        ; Add the value at memory location pointed to by BX (num1+4 = 15) to AX, result is 30
add bx, 2           ; Increment BX to point to the next word (num1+6)
mov [bx], ax        ; Store the result (30) into the memory location pointed to by BX (num1+6 = 0)

mov ax, 0x4c00      ; Load 0x4c00 into AX (function 4Ch of DOS interrupt to terminate program)
int 0x21            ; Interrupt 21h to call DOS function (terminate program)

num1 : dw 5, 10, 15, 0 ; Define word data at label num

[org 0x0100]            ; Set the origin to 0x0100 for COM file format

xor ax, 0               ; Clear AX (XOR is used for efficiency)
xor bx, 0               ; Clear BX (XOR is used for efficiency)

startOfLoop:
    mov ax, [num1+bx]   ; Load the value at memory location (num1 + offset in BX) into AX
    add bx, 2           ; Increment BX by 2 to point to the next word (2 bytes)
    cmp bx, 20          ; Compare BX with 20 (end of loop condition)
    jne startOfLoop     ; Jump to startOfLoop if BX is not equal to 20 (loop until all values are processed)

mov ax, 0x4c00          ; Load 0x4c00 into AX (function 4Ch of DOS interrupt to terminate program)
int 0x21                ; Interrupt 21h to call DOS function (terminate program)

num1 : dw 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 ; Define word data at label num1 with 10 values
total : dw 0            ; Define a word data at label total initialized to 0 (not used in this code)

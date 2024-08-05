[org 0x0100]            ; Set the origin to 0x0100 for COM file format

mov bx, num1            ; Load the address of num1 into BX
mov cx, 10              ; Load the value 10 into CX (loop counter)
xor ax, ax              ; Clear AX (set AX to 0)

iteration:
add ax, [bx]            ; Add the value at memory location pointed to by BX to AX
add bx, 2               ; Increment BX to point to the next word (2 bytes)
sub cx, 1               ; Decrement CX by 1
jnz iteration           ; Jump to iteration if CX is not zero (loop until CX is 0)

mov [num1+20], ax       ; Store the result (sum of values) into the memory location num1+20 (after the last number)
mov ax, 0x4c00          ; Load 0x4c00 into AX (function 4Ch of DOS interrupt to terminate program)
int 0x21                ; Interrupt 21h to call DOS function (terminate program)

num1 : dw 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 0  ; Define word data at label num1 with 10 values and an extra 0

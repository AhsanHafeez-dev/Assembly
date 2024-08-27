[org 0x0100]
jmp start
num1 : dd 80000
num2 : dd 40000

start:
        mov ax,[num2]
        sub word[num1],ax
        mov ax,[num2+2]
        sbb [num1+2],ax

mov ax,0x4c00
int 0x21        
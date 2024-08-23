[org 0x0100]
jmp start
num1 : dd 40000
num2 : dd 80000

start:
        mov ax,[num2]
        add word[num1],ax
        mov ax,[num2+2]
        adc [num1+2],ax

mov ax,0x4c00
int 0x21        
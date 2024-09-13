[org 0x0100]
jmp start
multiplicant : dd 1300
multiplier : dw 500
result : dd 0
start
mov bx,[multiplicant]
mov dx,[multiplier]

loopstart:
mov cx,16

        b:
        shr dx,1
        jnc noadd

test
        mov ax,[multiplicant]
        add word[result],ax
        mov ax,[multiplicant+2]
        adc [result+2],ax

noadd:
    shl word[multiplicant],1
    rcl word[multiplicant+2],1

    dec cx
    jnz b

mov ax,0x4c00
int 0x21        
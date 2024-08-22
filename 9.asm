[org 0x0100]
jmp start

multiplicant: db 13
multiplier: db 5
result : db 0


start:
mov bl,[multiplicant]
mov  dl,[multiplier]
mov cx,4
        loops:
        shr dl,1

        jnc noadd

            add [result],bl
            
        noadd:
        shl bl,1
        dec cl
        jnz loops

mov ax,0x4c00 
int 0x21


            

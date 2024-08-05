[org 0x0100]

    xor ax,0  ;xor is faster than mov
    xor bx,0

startOfLoop:
         mov ax,[num1+bx]
         add bx,2
         cmp bx,20
         jne startOfLoop


    mov ax,0x4c00
    int 0x21

num1 :  dw 10,20,30,40,50,60,70,80,90,100
total : dw 0
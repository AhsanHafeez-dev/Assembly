[org 0x0100]

mov bx,0
mov cx,10
xor ax,ax
iteration:
add ax,[bx+num1]
add bx,2
sub cx,1
jnz iteration

mov [num1+20],ax
mov ax,0x4c00
int 0x21

num1 : dw 5,10,15,20,25,30,35,40,45,50,0
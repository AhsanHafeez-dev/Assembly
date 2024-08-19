[org 0x0100]
jmp outerloop
data : dw 7,6,5,4,3,2,1,-1,-2,-3
swap : db 0



    outerloop :
        mov byte[swap],0
        mov bx,0
            
            innerloop:
                mov ax,[data+bx]
                cmp ax,[data+bx+2]
                jbe noswap              ;unsighned comparison 
                        mov dx,[data+bx+2]
                        mov [data+bx],dx
                        mov [data+2+bx],ax
                        mov byte[swap],1


                noswap:
                    add bx,2
                    cmp bx,18
                    jnz innerloop



    cmp byte[swap],1
    jz outerloop

mov ax,0x4c00
int 0x21
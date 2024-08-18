[org 0x0100]

jmp start

data : dw 10,9,8,7,6,5,4,3,2,1
flag : db 0
start:
; mov cx,[flag]

        outerloop:
            mov bx,0
            mov byte[flag],0

                innerloop:
                    mov ax,[data+bx]
                    cmp ax,[data+bx+2]
                    jbe noswap

                            mov dx,[data+bx+2]
                            mov [data+bx+2],ax
                            mov [data+bx],dx
                            mov byte[flag],1

                        noswap:
                        add bx,2
                        cmp bx,18
                        jnz innerloop
            
            cmp byte[flag],1
            jz outerloop

mov ax,0x4c00
int 0x21




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
                jle noswap              ;sighned comparison 
                ;now when we do unsighned comparison with sighned number data will not be sorted bcz it compare magnitude not the siighns
                        
                        mov dx,[data+bx+2]   ;mov next number to dx register
                        mov [data+bx],dx     ;mov value of dx to prev pos 
                        mov [data+2+bx],ax   ;now mov value of ax to next position
                        mov byte[swap],1     ; setting swap flag


                noswap:
                    add bx,2       
                    cmp bx,18       ; stopping at 18 bcz we are comparing to next number so we want to be stop one before last number
                    jnz innerloop



    cmp byte[swap],1
    jz outerloop

mov ax,0x4c00
int 0x21
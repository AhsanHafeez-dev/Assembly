[org 0x0100]
jmp start
data  : dw 9,8,7,6,5,4,3,2,1,0
data2 : dw 10,11,12,13,14,15,16,17,18,19
        dw 20,21,22,23,24,25,26,27,28,29
flag : db 0
bubblesort:
        push bp
        mov bp,sp
        sub  sp,2
        push cx
        push si
        push dx
        push bx
        mov cx,[bp+4]
        mov bx,[bp+6]
        dec cx
        shl cx,1

        outerloop:
        mov word[bp-2],0
        mov si,0

        innerloop:
        mov dx,[bx+si]
        cmp dx,[bx+si+2]
        jbe noswap
                call swap
    noswap:
    add si,2
    cmp si,cx
    jnz innerloop

    ;sub cx,2
    cmp word[bp-2],1
    jz outerloop
    pop bx
    pop dx
    pop si
    pop cx
    ; add sp,2
    mov bp,sp
    pop bp
    ret 4

swap:
                push ax
                mov ax,[bx+si+2]
                mov [bx+si+2],dx
                mov [bx+si],ax
                mov byte[flag],1
                pop ax
                ret

start:
push data
;mov bx,data

;mov cx,10
push 10
call bubblesort

push data2
;mov bx,data2
;mov cx,20
push 20
call bubblesort
        
mov ax,0x4c00
int 0x21        


[org 0x0100]
jmp start

string: db 'Hello World'
stringlength: dw 11
clrscr:
push ax 
push es 
push cx  
push di 

mov ax,0xb800
mov es,ax
xor di,di
mov cx,2000
mov ax,0x720

cld    ;incrementing order
;by default
; src in ds:si and dest is es:di
;stosw moves a word memroy from src to destination
rep stosw ;repeat cx time 

pop di 
pop cx 
pop es 
pop ax 
ret 
printstring:
        push bp
        mov bp,sp
        push ax
        push bx
        push cx 
        push es 
        push di 
        push si

        mov di,160
        mov ax,0xb800
        mov es,ax
        mov ah,[bp+8]
        mov si,[bp+4]
        mov cx,[bp+6]
        cld
            printchar:
                lodsb
                stosw 
                loop printchar




        pop si
        pop di 
        pop es 
        pop cx 
        pop bx 
        pop ax 
        pop bp
        ret 4

pop di 
pop cx 
pop es 
pop ax 

ret

start:
call clrscr
mov ax,1
push ax
mov ax,[stringlength]
push ax
mov ax,string
push ax

call printstring

mov ax,0x4c00
int 0x21
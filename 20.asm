[org 0x0100]
jmp start
string:db 'Hello World'

start:
    mov ah,0x13  ;service  13--this is video service
    mov al,0     ; sub service in video service sub service one is for pritning string
    mov bh,0     ;on which page to print
    mov bl,7     ;attribute
    mov dh,0x0A ;yposition
    mov dl,0x03  ;xposition
    mov cx,11 ;length of string
    push cs      
    pop es       ;we need segment in es
    mov bp,string;we need offset in bp     
    int 0x10

mov ax,0x4c00
int 0x21
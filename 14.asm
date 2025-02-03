[org 0x0100]

mov ax ,0xb800  ;address of video memory
mov es,ax      ;seeting extended segment to video memory so we can use offset over segment
mov di,0        ;using it for iterating over video memory

nextchar:
    mov word[es:di],0x720
    add di,2
    cmp di,4000
    jnz nextchar
    
mov ax,0x4c00
int 0x21
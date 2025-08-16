[org 0x0100]              ; .COM file starts execution at offset 0x100

mov ax,0x0013             ; set 320x200 graphics mode (Mode 13h, 256 colors)
int 0x10                  ; BIOS video service

mov ax,0x0C07             ; AH=0Ch -> write pixel, AL=07h -> color (white/gray depending on palette)
xor bx,bx                 ; BX=0 -> page number 0
mov cx,200                ; CX = 200 -> initial X coordinate
mov dx,200                ; DX = 200 -> initial Y coordinate

l1:
int 0x10                  ; draw pixel at (CX,DX) with color in AL
dec dx                    ; move pixel one step upward (decrease Y)
loop l1                   ; decrease CX and repeat until CX=0

mov ah,0                  ; AH=0 -> wait for keypress
int 0x16                  ; BIOS keyboard service

mov ax,0x0003             ; set text mode 80x25 (Mode 3)
int 0x10                  ; BIOS video service

mov ax,0x4C00             ; terminate program with return code 0
int 0x21                  ; DOS interrupt

; ------------------------------------------------------------------------
; COM program to load the BIOS ROM font into RAM, modify each glyph,
; and install it as the active font via BIOS video service.
; ------------------------------------------------------------------------
[org 0x0100]           ; Origin for a .COM file

font: 
    times 256*16 db 0  ; Reserve 256 characters × 16 bytes per glyph = 4096 bytes

    jmp start          ; Jump to program entry, skipping data area

; ------------------------------------------------------------------------
; Program entry point
; ------------------------------------------------------------------------
start:
    ; BIOS service 10h, subfunction 11h: Select font block and size
    mov ah, 11h        ; AH = 11h (font function)
    mov al, 30h        ; AL = 30h (load 8×16 font, block 0)
    mov bx, 0600h      ; BX = start row (6), end row (0) – sets font rows
    int 10h            ; Call BIOS video interrupt

    ; Copy ROM font data (at address ES:BP) into our 'font' buffer
    mov si, bp         ; SI ← offset of ROM font data (BIOS places it at ES:BP)
    mov di, font       ; DI ← destination buffer
    mov cx, 256*16     ; CX = total bytes to copy (4096)
    push ds            ; Save DS
    push es            ; Save ES
    pop ds             ; DS ← ES (source segment)
    pop es             ; ES unchanged (destination segment)
    cld                ; Clear direction flag (forward copy)
    rep movsb          ; Copy CX bytes from [DS:SI] to [ES:DI]

    ; Restore DS to our code segment for subsequent data accesses
    push cs            ; Push CS
    pop ds             ; DS ← CS

    ; Modify each character’s first byte in our font buffer to 0xFF
    ; so the top row of every glyph is solid.
    lea si, [font-1]   ; SI = address just before first glyph byte
    mov cx, 256        ; CX = number of characters
change_loop:
    add si, 16         ; Move SI to the first byte of next glyph (each is 16 bytes)
    mov byte [si], 0FFh; Set top row byte to 0xFF
    loop change_loop   ; Repeat for all 256 glyphs

    ; Install our modified font via BIOS video service 10h, subfunction 11h/10h
    mov bp, font       ; BP ← offset of our font buffer
    mov bx, 1000h      ; BX: high byte = block number (1), low byte = bytes/char (16)
    mov cx, 0100h      ; CX = number of characters (256)
    xor dx, dx         ; DL = first character code to modify (0)
    mov ax, 1110h      ; AH = 11h, AL = 10h (load user font)
    int 10h            ; Call BIOS video interrupt

    ; Exit to DOS
    mov ax, 4C00h      ; AH = 4Ch (terminate), AL = return code 0
    int 21h            ; DOS interrupt

; ------------------------------------------------------------------------
; Note:
; - This code assumes the BIOS font is initially accessible at ES:BP
;   after the first INT 10h call.
; - We create a simple effect: a solid top row for every character.
; ------------------------------------------------------------------------

[org 0x0100]
; ------------------------------------------------------------------
; Program Purpose:
; iAPX 8088 / 8086 Assembly (MS-DOS)
; Writes a character repeatedly to video memory in text mode.
; - Uses segment 0xB800 (color text video memory).
; - Fills entire 80x25 screen (2000 characters).
; - Each character cell = 2 bytes (char + attribute).
; - Character written = 'e' (0x65) with attribute 0x07 (white on black).
; - Terminates cleanly back to DOS.
; ------------------------------------------------------------------

jmp start                    ; jump over data (none here)

start:
    mov ax,0xB800            ; video memory segment (color text mode)
    mov es,ax                ; ES -> video memory
    xor di,di                ; DI = 0, start at top-left of screen

    mov ax,0x0765            ; AX = 0x0765
                             ;   AL = 0x65 = 'e'
                             ;   AH = 0x07 = attribute (white on black)
    mov cx,2000              ; number of character cells (80 * 25)

    cli                      ; clear interrupts (not strictly needed here)
    rep stosw                ; store AX into ES:[DI], increment DI by 2, repeat CX times

    mov ax,0x4C00            ; DOS terminate program
    int 0x21

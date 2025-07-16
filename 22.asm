[org 0x0100]          ; Origin: program load offset for a COM file

    in   al, 0x21     ; Read current master PIC interrupt-mask register into AL
                      ; Port 0x21 is the PIC’s data port (IMR) for IRQs 0–7

    or   al, 2        ; Set bit 1 (0-based) in AL (binary 0000 0010)
                      ; This masks IRQ1 (the keyboard interrupt)

    out  0x21, al     ; Write the modified mask back to the PIC’s data port

    mov  ax, 0x4C00   ; Prepare DOS “terminate program” call:
                      ; AH = 4Ch (function), AL = 00 (return code)

    int  0x21         ; Invoke DOS interrupt 21h to exit the program

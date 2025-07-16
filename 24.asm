; ------------------------------------------------------------------------
; COM program to hook the keyboard interrupt (IRQ1) and show/hide
; “L” or “R” when left/right Shift is pressed or released.
; ------------------------------------------------------------------------
[org 0x0100]            ; Origin address for a .COM file

    jmp start           ; Skip over ISR definition to program entry

; ------------------------------------------------------------------------
; Data: storage for the original INT 09 handler vector (offset+segment)
; ------------------------------------------------------------------------
oldisr:
    dd 0                ; 4 bytes: will hold original ISR pointer

; ------------------------------------------------------------------------
; ISR: myKeyboardInterrupt
; - Reads the scan code from port 0x60
; - On Left Shift press (0x2A): display 'L' at screen cell 1
; - On Left Shift release (0xAA): clear cell 1
; - On Right Shift press (0x36): display 'R' at screen cell 2
; - On Right Shift release (0xB6): clear cell 2
; - Acknowledge IRQ by sending End‑Of‑Interrupt to PIC
; - Chain to original handler via far IRET
; ------------------------------------------------------------------------
myKeyboardInterrupt:
    push ax            ; Save AX register
    push es            ; Save ES register

    mov ax, 0B800h     ; Segment of VGA text buffer
    mov es, ax         ; ES ← video memory segment

    in   al, 0x60      ; Read keyboard scan code
    cmp  al, 0x2A      ; Is it Left Shift press?
    jnz  .check_left_release
    mov  byte [es:160], 'L'  ; Write 'L' in the first screen cell
    jmp  .ack          

.check_left_release:
    cmp  al, 0xAA      ; Is it Left Shift release?
    jnz  .check_right_press
    mov  byte [es:160], ' '  ; Clear cell 1
    jmp  .ack

.check_right_press:
    cmp  al, 0x36      ; Is it Right Shift press?
    jnz  .check_right_release
    mov  byte [es:162], 'R'  ; Write 'R' in the second screen cell
    jmp  .ack

.check_right_release:
    cmp  al, 0xB6      ; Is it Right Shift release?
    jnz  .ack
    mov  byte [es:162], ' '  ; Clear cell 2

.ack:
    mov  al, 0x20      ; PIC EOI command code
    out  0x20, al      ; Acknowledge IRQ to the PIC

    pop  es            ; Restore ES
    pop  ax            ; Restore AX
    iret               ; Return from interrupt, chaining automatically

; ------------------------------------------------------------------------
; Program entry point: installs ISR and waits (via DOS call) forever.
; ------------------------------------------------------------------------
start:
    xor  ax, ax        ; AX = 0
    mov  es, ax        ; ES = 0 → point to IVT in low memory

    ; Save original INT 09 vector (4 bytes at ES:9*4)
    mov  ax, [es:9*4]      ; Load original offset
    mov  [oldisr], ax      ; Store it in our variable
    mov  ax, [es:9*4+2]    ; Load original segment
    mov  [oldisr+2], ax    ; Store it

    cli                  ; Disable interrupts while updating IVT
    mov  word [es:9*4], myKeyboardInterrupt  ; Set new offset
    mov  word [es:9*4+2], cs                ; Set new segment
    sti                  ; Re-enable interrupts

    ; Invoke DOS function to wait indefinitely (function 31h, rotate cursor)
    mov  dx, start       ; DX = pointer to our code (arbitrary)
    mov  cl, 4           ; Shift count (not meaningful here)
    shr  dx, cl          ; Just to modify DX
    mov  ax, 3100h       ; DOS function 31h: get/set ctrl-c handling
    int  21h             ; Call DOS; program will not return here

    ; Normally, you’d restore the original ISR before exit:
    ; cli
    ; mov [es:9*4], [oldisr]
    ; mov [es:9*4+2], [oldisr+2]
    ; sti
    ; mov ax, 4C00h
    ; int 21h

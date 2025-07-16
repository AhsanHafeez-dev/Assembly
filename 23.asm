; ------------------------------------------------------------------------
; COM program that hooks the keyboard interrupt (IRQ1) to display
; 'L' or 'R' at the top‐left of the screen when Left or Right Shift
; keys are pressed, then restores the original handler on ESC.
; ------------------------------------------------------------------------
[org 0x0100]

    jmp start                   ; Skip over ISR code to program entry

; ------------------------------------------------------------------------
; Data: Storage for original ISR vector (4 bytes: offset, segment)
; ------------------------------------------------------------------------
oldisr: 
    dd 0                        ; Will hold original INT 09 pointer

; ------------------------------------------------------------------------
; ISR: myKeyboardInterrupt
; - Reads BIOS keyboard port (0x60) scan code
; - On Left Shift (scan code 0x2A), writes 'L' at screen position 0
; - On Right Shift (scan code 0x36), writes 'R' at screen position 0
; - Chains to original handler via far JMP
; ------------------------------------------------------------------------
myKeyboardInterrupt:
    push ax                     ; Preserve AX
    push es                     ; Preserve ES

    mov ax, 0B800h              ; VGA text mode segment
    mov es, ax                  ; ES ← video memory

    in   al, 0x60               ; Read scan code from keyboard controller
    cmp  al, 0x2A               ; Compare to Left Shift make code
    jnz  .check_right_shift     
    mov  byte [es:0], 'L'       ; Write 'L' in top‐left cell
.check_right_shift:
    cmp  al, 0x36               ; Compare to Right Shift make code
    jnz  .done                  ; If not, skip
    mov  byte [es:0], 'R'       ; Write 'R' in top‐left cell

.done:
    pop  es                     ; Restore ES
    pop  ax                     ; Restore AX

    jmp  far [cs:oldisr]        ; Jump to original INT 09 handler

; ------------------------------------------------------------------------
; Program Entry: Hook the keyboard interrupt, then wait for ESC
; ------------------------------------------------------------------------
start:
    xor  ax, ax                 ; AX = 0
    mov  es, ax                 ; ES = 0 → point to Interrupt Vector Table (IVT)

    ; Save original INT 09 vector (4 bytes at ES:9*4)
    mov  ax, [es:9*4]           ; Load original offset
    mov  [oldisr], ax           ; Store it
    mov  ax, [es:9*4+2]         ; Load original segment
    mov  [oldisr+2], ax         ; Store it

    cli                         ; Disable interrupts while we update IVT
    mov  word [es:9*4], myKeyboardInterrupt  ; New offset
    mov  word [es:9*4+2], cs               ; New segment
    sti                         ; Re‐enable interrupts

; Wait loop: poll keyboard until ESC (scan code 1Bh) is pressed
.wait_esc:
    mov  ah, 00h                ; BIOS: read keyboard without echo
    int  16h                    ; Call keyboard BIOS service
    cmp  al, 1Bh                ; AL = scan code; 0x1B = ESC
    jne  .wait_esc              ; If not ESC, keep waiting

    ; Restore original INT 09 vector before exit
    mov  ax, [oldisr]           ; Original offset
    mov  bx, [oldisr+2]         ; Original segment
    cli
    mov  [es:9*4], ax           ; Restore offset
    mov  [es:9*4+2], bx         ; Restore segment
    sti

    ; Exit back to DOS
    mov  ax, 4C00h              ; DOS terminate function (AH=4Ch, AL=0)
    int  21h

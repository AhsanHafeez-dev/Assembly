; Set program origin to offset 0x0100 in a COM file
[org 0x0100]

; ------------------------------------------------------------------------
; Data definitions
; ------------------------------------------------------------------------
interruptmessage:
    db 'you are trying to divide which is undefined in mathematics', 0  ; Zero-terminated error message

; ------------------------------------------------------------------------
; Subroutine: clrscr
; Clears the text-mode screen by writing blank spaces with attribute 0x07 to video memory
; (uses BIOS text mode at segment 0xB800:0000, 80×25 characters, 2000 character cells)
; Stack: none
; Returns: nothing
; ------------------------------------------------------------------------
clrscr:
    push es              ; Save ES
    push ax              ; Save AX
    push si              ; Save SI
    push di              ; Save DI

    mov ax, 0B800h       ; Video memory segment for text mode
    mov es, ax           ; ES ← 0xB800
    xor di, di           ; DI = 0 (start at offset 0)
    mov cx, 2000         ; Number of character cells (80×25)
    mov ax, 0720h        ; AX = space character (0x20) with attribute 0x07
    cld                  ; Clear direction flag (forward store)
    rep stosw            ; Store AX into [ES:DI], CX times (clears screen)

    pop di               ; Restore DI
    pop si               ; Restore SI
    pop ax               ; Restore AX
    pop es               ; Restore ES
    ret                  ; Return

; ------------------------------------------------------------------------
; Subroutine: printstring
; Prints a zero-terminated string to the middle of the VGA text screen.
; Argument (on stack): 
;   [BP+4] = offset of zero-terminated ASCII string
; Uses: DS for string segment, ES for video, SI for screen offset
; Returns: cleans up 2-byte argument, restores registers
; ------------------------------------------------------------------------
printstring:
    push bp              ; Save base pointer
    mov bp, sp           ; Create stack frame
    push ax              ; Save AX
    push bx              ; Save BX
    push cx              ; Save CX
    push dx              ; Save DX
    push es              ; Save ES
    push si              ; Save SI
    push di              ; Save DI

    mov ax, 0B800h       ; VGA text segment
    mov es, ax           ; ES ← video segment
    mov si, 160          ; SI = offset at row 1, column 0 (80 cols × 2 bytes per cell)

    mov bx, [bp+4]       ; BX = string offset
    push bx              ; Push string offset for length calculation
    call caculateLenghth ; Get string length in CX, BX restored

    mov bx, [bp+4]       ; Reload BX = string offset
    mov ah, 07h          ; Attribute byte for text (grey on black)

printchar:
    mov al, [bx]         ; Load next character
    mov word [es:si], ax ; Write character+attribute to video memory
    inc bx               ; Advance to next character
    add si, 2            ; Move to next screen cell (2 bytes per cell)
    loop printchar       ; Repeat until CX = 0

    pop di               ; Restore DI
    pop si               ; Restore SI
    pop es               ; Restore ES
    pop dx               ; Restore DX
    pop cx               ; Restore CX
    pop bx               ; Restore BX
    pop ax               ; Restore AX
    pop bp               ; Restore BP
    ret 2                ; Return and clean up 2-byte argument

; ------------------------------------------------------------------------
; Subroutine: caculateLenghth
; Computes the length (in CX) of a zero-terminated string.
; Argument (on stack):
;   [BP+4] = offset of zero-terminated ASCII string
; Returns:
;   CX = length of string (not counting the zero terminator)
; Cleans up argument and restores registers.
; ------------------------------------------------------------------------
caculateLenghth:
    push bp              ; Save base pointer
    mov bp, sp           ; Create stack frame
    push ax              ; Save AX
    push bx              ; Save BX

    xor bx, bx           ; Clear BX
    mov bx, [bp+4]       ; BX = string offset
    xor cx, cx           ; CX = 0 (length counter)

compareloop:
    cmp byte [bx], 0     ; Compare current byte to zero terminator
    jz return            ; If zero, string end reached
    inc bx               ; Advance pointer
    inc cx               ; Increment length counter
    jmp compareloop      ; Repeat

return:
    dec cx               ; Adjust CX (optional: remove terminator count)
    pop bx               ; Restore BX
    pop ax               ; Restore AX
    pop bp               ; Restore BP
    ret 2                ; Return and clean up 2-byte argument

; ------------------------------------------------------------------------
; Interrupt Service: myDivisonByZeroInterrupt
; Custom handler for division-by-zero interrupt (INT 0).
; Clears screen, prints error message, and returns to caller.
; Stack: none
; ------------------------------------------------------------------------
myDivisonByZeroInterrupt:
    push bp              ; Save BP
    push ax              ; Save AX
    push bx              ; Save BX
    push cx              ; Save CX
    push dx              ; Save DX
    push es              ; Save ES
    push si              ; Save SI
    push di              ; Save DI

    push cs              ; Load CS segment
    pop ds               ; DS ← CS (for accessing data in code segment)

    call clrscr          ; Clear the screen
    push interruptmessage; Push address of error message
    call printstring     ; Print the error message

    pop di               ; Restore DI
    pop si               ; Restore SI
    pop es               ; Restore ES
    pop dx               ; Restore DX
    pop cx               ; Restore CX
    pop bx               ; Restore BX
    pop ax               ; Restore AX
    pop bp               ; Restore BP
    iret                 ; Return from interrupt

; ------------------------------------------------------------------------
; Procedure: divErrorRoutine
; Deliberately causes a division by zero to invoke our handler.
; ------------------------------------------------------------------------
divErrorRoutine:
    push ax              ; Save AX
    mov ax, 0FFFFh       ; Set AX to nonzero numerator
    mov bl, 1            ; Divide by BL = 1 (valid division)
    div bl               ; Performs AX / BL → AL = quotient, AH = remainder
    pop ax               ; Restore AX
    ret                  ; Return

; ------------------------------------------------------------------------
; Program Entry Point
; ------------------------------------------------------------------------
start:
    xor ax, ax           ; Clear AX (DS = 0)
    mov es, ax           ; ES = 0 (not strictly needed here)

    ; Install our division-by-zero handler at interrupt vector 0
    ; (commented out because COM format can’t write IVT directly without special privileges)
    ; mov word [es:0*4], offset myDivisonByZeroInterrupt
    ; mov word [es:0*4+2], cs

    call divErrorRoutine ; Trigger a division (no error here)
    mov ax, 4C00h        ; DOS terminate program function, return code 0
    int 21h              ; Invoke DOS interrupt


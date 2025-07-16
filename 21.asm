; Set program origin to offset 0x0100 in memory (COM file)
[org 0x0100]

; Jump over data and routines to program entry point
    jmp start        

; ------------------------------------------------------------------------
; Data: three zero‑terminated messages to display
; ------------------------------------------------------------------------
message1:
    db 'mat kar', 0                              ; First message

message2:
    db 'baaz aaja tune me btareya', 0           ; Second message

message3:
    db 'tu meno janta nhi hai shoreya', 0       ; Third message

; ------------------------------------------------------------------------
; Subroutine: clrscr
; Clears the 80×25 text screen by filling video memory with blanks.
; Uses VGA text segment at 0xB800:0000.
; ------------------------------------------------------------------------
clrscr:
    push es              ; Save ES register
    push ax              ; Save AX register
    push si              ; Save SI register
    push di              ; Save DI register

    mov ax, 0B800h       ; Point AX to VGA text buffer segment
    mov es, ax           ; ES ← 0xB800
    xor di, di           ; DI = 0 (start at top‑left of screen)
    mov cx, 2000         ; 80 cols × 25 rows = 2000 character cells
    mov ax, 0720h        ; AX = blank character (0x20) with attribute 0x07
    cld                  ; Clear direction flag (forward writing)
    rep stosw            ; Write AX to [ES:DI], CX times

    pop di               ; Restore DI
    pop si               ; Restore SI
    pop ax               ; Restore AX
    pop es               ; Restore ES
    ret                  ; Return to caller

; ------------------------------------------------------------------------
; Subroutine: printstring
; Prints a zero‑terminated string at row 1, column 0 of the text screen.
; Argument (stack): [BP+4] = offset of string in our segment.
; ------------------------------------------------------------------------
printstring:
    push bp              ; Save BP
    mov bp, sp           ; Set up stack frame
    push ax              ; Save AX
    push bx              ; Save BX
    push cx              ; Save CX
    push dx              ; Save DX
    push es              ; Save ES
    push si              ; Save SI
    push di              ; Save DI

    mov ax, 0B800h       ; VGA text segment
    mov es, ax           ; ES ← 0xB800
    mov si, 160          ; SI = offset for start of second row (80 cols × 2 bytes)

    mov bx, [bp+4]       ; BX ← string offset argument
    push bx              ; Push BX for length calculation
    call caculateLenghth ; CX ← length of string
    mov bx, [bp+4]       ; Reload BX = string offset
    mov ah, 07h          ; AH = attribute (grey on black)

printchar:
    mov al, [bx]         ; AL ← next character
    mov word [es:si], ax ; Write character+attribute to screen
    inc bx               ; Move to next character in string
    add si, 2            ; Move to next screen cell (2 bytes)
    loop printchar       ; Repeat CX times

    pop di               ; Restore DI
    pop si               ; Restore SI
    pop es               ; Restore ES
    pop dx               ; Restore DX
    pop cx               ; Restore CX
    pop bx               ; Restore BX
    pop ax               ; Restore AX
    pop bp               ; Restore BP
    ret 2                ; Clean up 2‑byte argument and return

; ------------------------------------------------------------------------
; Subroutine: caculateLenghth
; Computes length of zero‑terminated string.
; Argument (stack): [BP+4] = offset of string.
; Returns CX = number of characters before the zero terminator.
; ------------------------------------------------------------------------
caculateLenghth:
    push bp              ; Save BP
    mov bp, sp           ; Set up stack frame
    push ax              ; Save AX
    push bx              ; Save BX

    mov bx, [bp+4]       ; BX ← string offset
    xor cx, cx           ; CX = 0 (length counter)

length_loop:
    cmp byte [bx], 0     ; Check if current byte is zero terminator
    jz done_length       ; If yes, done
    inc bx               ; Advance to next character
    inc cx               ; Increment counter
    jmp length_loop      ; Repeat

done_length:
    pop bx               ; Restore BX
    pop ax               ; Restore AX
    pop bp               ; Restore BP
    ret 2                ; Clean up argument and return (CX holds length)

; ------------------------------------------------------------------------
; Program entry point
; ------------------------------------------------------------------------
start:
    ; Set blinking cursor and video mode attribute
    mov ah, 10h          ; BIOS: set cursor/start attribute
    mov al, 03h          ; AL = end scan line (cursor shape)
    mov bl, 1            ; BL = cursor blink
    int 10h              ; Call BIOS video interrupt

    mov ah, 00h          ; BIOS: wait for keypress
    int 16h              ; Call keyboard interrupt

    call clrscr          ; Clear the screen

    ; Display first message
    mov ax, message1     ; AX = offset of message1
    push ax              ; Push argument
    call printstring     ; Print it

    mov ah, 00h          ; Wait for next keypress
    int 16h              ; Call keyboard interrupt
    call clrscr          ; Clear screen again

    ; Display second message
    mov ax, message2     ; AX = offset of message2
    push ax
    call printstring

    mov ah, 00h
    int 16h
    call clrscr

    ; Display third message
    mov ax, message3     ; AX = offset of message3
    push ax
    call printstring

    ; Exit to DOS
    mov ax, 4C00h        ; DOS function 4Ch: terminate program
    int 21h              ; Call DOS interrupt

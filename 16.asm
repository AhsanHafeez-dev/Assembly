[org 0x0100]       ; Set the origin of the code at offset 0x0100  
jmp start          ; Jump to the start label to begin execution  

;----------------------------------
; Data Section
;----------------------------------
data : dw 4529     ; The number to be printed  
base : dw 8        ; The base in which the number will be printed (e.g., 8 for octal)  

;----------------------------------
; Clear Screen Subroutine (clrscr)
;----------------------------------
clrscr:
        push ax  ; Save AX register  
        push es  ; Save ES register  
        push di  ; Save DI register  

        mov ax, 0xb800  ; Address of video memory (text mode)  
        mov es, ax      ; Set ES to point to video memory  
        mov di, 0       ; Initialize DI to start from the beginning of video memory  

nextchar:
        mov word [es:di], 0x0720  ; Write a space (' ') with attribute (color)  
        add di, 2                 ; Move to the next character position  
        cmp di, 4000              ; Check if the whole screen is cleared (80x25 = 2000 words = 4000 bytes)  
        jnz nextchar              ; If not done, repeat  

        pop di  ; Restore DI register  
        pop es  ; Restore ES register  
        pop ax  ; Restore AX register  
        ret     ; Return from subroutine  

;----------------------------------
; Print Number Subroutine (printnum)
;----------------------------------
; Converts a number to a specified base and prints it on the screen.
;
; Parameters:
;   [BP+6] - Number to be converted (data)
;   [BP+4] - Base for conversion (e.g., 10 for decimal, 8 for octal)
;----------------------------------
printnum:   
    push bp      ; Save BP register  
    mov bp, sp   ; Set BP to point to the stack frame  
    push cx      ; Save CX register  
    push si      ; Save SI register  
    push es      ; Save ES register  
    push ax      ; Save AX register  
    push dx      ; Save DX register  

    xor ax, ax        ; Clear AX  
    mov ax, [bp+6]    ; Load the number to be printed  
    mov bx, [bp+4]    ; Load the base (e.g., 8 for octal, 10 for decimal)  

    mov dh, 07        ; Set text attribute (white on black)  
    xor cx, cx        ; Clear CX (counter for the number of digits)  

;----------------------------------
; Convert the number to the specified base
;----------------------------------
remainder:
    xor dx, dx        ; Clear DX  
    div bx            ; AX / BX -> Quotient in AX, Remainder in DX  
    add dl, 0x30      ; Convert remainder to ASCII character  
    mov dh, 0x07      ; Set attribute (white text)  
    push dx           ; Store converted character on stack  
    inc cx            ; Increase digit count  
    cmp ax, 0         ; If quotient is 0, we're done  
    jnz remainder     ; Otherwise, continue conversion  

;----------------------------------
; Print the converted number
;----------------------------------
mov ax, 0xb800   ; Set video memory segment  
mov es, ax       ; Load ES with video memory segment  
mov si, 160      ; Start printing from the second row  

printing:
    pop ax        ; Get the next digit from the stack  
    mov [es:si], ax  ; Print character at current position  
    add si, 2     ; Move to next position in video memory  
    loop printing ; Repeat for all digits  

;----------------------------------
; Restore registers and return
;----------------------------------
    pop dx  
    pop ax  
    pop es  
    pop si  
    pop bp  
    pop cx  
    ret 4    ; Return and clean up stack (restore parameters)  

;----------------------------------
; Program Entry Point
;----------------------------------
start:
    call clrscr           ; Clear the screen  
    push word [data]      ; Push the number to be printed  
    push word [base]      ; Push the base (e.g., 8 for octal)  
    call printnum         ; Call print number subroutine  

    mov ax, 0x4c00        ; Terminate program  
    int 0x21              ; DOS interrupt to exit  

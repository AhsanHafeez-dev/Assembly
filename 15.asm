[org 0x0100]       ; Set the origin of the code at offset 0x0100  
jmp start          ; Jump to the start label to begin execution  

; Define the string "Hello World"  
string       : db 'Hello World'    ; Define the string  
stringlength : dw 11               ; Define the length of the string  

;-------------------------------
; Clear Screen Subroutine (clrscr)
;-------------------------------
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

;--------------------------------------
; Print String Subroutine (printstring)
;--------------------------------------
printstring:
        push bp  ; Save BP register  
        mov bp, sp  ; Set BP to point to stack frame  
        push ax  ; Save AX register  
        push bx  ; Save BX register  
        push si  ; Save SI register  
        push di  ; Save DI register  
        push cx  ; Save CX register  

        mov ax, 0xb800  ; Set video memory segment  
        mov es, ax  
        mov bx, [bp+6]  ; Load pointer to string (passed argument)  
        mov cx, [bp+4]  ; Load string length (passed argument)  
        mov ah, 0x19    ; Set attribute for the characters (text color)  
        mov si, 0       ; Initialize SI (video memory pointer)  

printchar:
        mov al, [bx]     ; Load a character from the string  
        mov [es:si], ax  ; Write the character with the attribute to video memory  
        inc bl           ; Move to the next character in the string  
        add si, 2        ; Move to the next position in video memory  
        loop printchar   ; Repeat until all characters are printed  

        pop cx  ; Restore CX register  
        pop di  ; Restore DI register  
        pop si  ; Restore SI register  
        pop bx  ; Restore BX register  
        pop ax  ; Restore AX register  
        pop bp  ; Restore BP register  
        ret 4   ; Return and clean up stack (restore parameters)  

;-----------------------
; Program Entry Point
;-----------------------
start:
        call clrscr         ; Call clear screen subroutine  
        mov ax, string      ; Load string address into AX  
        push ax            ; Push the string address as an argument  
        mov ax, [stringlength]  ; Load string length  
        push ax            ; Push the string length as an argument  
        call printstring   ; Call the print string subroutine  

        mov ax, 0x4c00     ; Terminate program  
        int 0x21          ; DOS interrupt to exit  

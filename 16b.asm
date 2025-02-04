[org 0x0100]       ; Set the origin of the code at offset 0x0100  
jmp start          ; Jump to the start label to begin execution  

;----------------------------------
; Data Section
;----------------------------------
string      : db 'Hello World'  ; Define the string to be printed  
stringlength: dw 11             ; Define the length of the string  
xposition   : dw 10             ; X position (column) where the string will be printed  
yposition   : dw 20             ; Y position (row) where the string will be printed  
attribute   : dw 0x71           ; Text attribute (gray background, white text)  

;----------------------------------
; Clear Screen Subroutine (clrscr)
;----------------------------------
clrscr:
        push es     ; Save ES register  
        push ax     ; Save AX register  
        push di     ; Save DI register  

        mov ax, 0xb800  ; Address of video memory (text mode)  
        mov es, ax      ; Set ES to point to video memory  
        xor di, di      ; Initialize DI to start from the beginning of video memory  

nextchar:
        mov word [es:di], 0x0720  ; Write a space (' ') with attribute (color)  
        add di, 2                 ; Move to the next character position  
        cmp di, 4000              ; Check if the whole screen is cleared (80x25 = 2000 words = 4000 bytes)  
        jnz nextchar              ; If not done, repeat  

        pop di  ; Restore DI register  
        pop ax  ; Restore AX register  
        pop es  ; Restore ES register  
        ret     ; Return from subroutine  

;----------------------------------
; Print String Subroutine (printstring)
;----------------------------------
; Prints a string at a specified (x, y) position on the screen.
;
; Parameters (passed via stack):
;   [BP+12] - Address of string
;   [BP+10] - Length of string
;   [BP+8]  - X position (column)
;   [BP+6]  - Y position (row)
;   [BP+4]  - Attribute (color)
;----------------------------------
printstring:

        push bp       ; Save BP register  
        mov bp, sp    ; Set BP to point to the stack frame  
        push ax       ; Save AX register  
        push bx       ; Save BX register  
        push si       ; Save SI register  
        push di       ; Save DI register  
        push cx       ; Save CX register  

        mov bx, [bp+12]  ; Load address of string  
        mov cx, [bp+10]  ; Load length of string  
        mov ax, 0xb800   ; Load video memory segment  
        mov es, ax       ; Set ES to point to video memory  

        xor ax, ax       ; Clear AX  
        mov al, 80       ; Each row has 80 columns  
        mul byte [bp+6]  ; Multiply by Y position to calculate the row offset  
        add ax, [bp+8]   ; Add X position to get final screen offset  
        mov si, ax       ; Set SI as the starting position  
        mov dh, [bp+4]   ; Load attribute for text color  

nextcharp:
        mov dl, [bx]     ; Load character from string  
        mov word [es:si], dx  ; Write character with attribute to video memory  
        inc bl           ; Move to the next character in the string  
        add si, 2        ; Move to the next position in video memory  
        loop nextcharp   ; Repeat until all characters are printed  

        pop cx  ; Restore CX register  
        pop di  ; Restore DI register  
        pop si  ; Restore SI register  
        pop bx  ; Restore BX register  
        pop ax  ; Restore AX register  
        pop bp  ; Restore BP register  
        ret 10  ; Return and clean up stack (restore parameters)  

;----------------------------------
; Program Entry Point
;----------------------------------
start:
    call clrscr              ; Clear the screen  
    mov ax, string           ; Load address of the string  
    push ax                  ; Push the string address  
    push word [stringlength] ; Push the string length  
    push word [xposition]    ; Push the X position  
    push word [yposition]    ; Push the Y position  
    push word [attribute]    ; Push the text attribute  
    call printstring         ; Call the print string subroutine  

    mov ax, 0x4c00           ; Terminate program  
    int 0x21                 ; DOS interrupt to exit  

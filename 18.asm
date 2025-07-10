; Define the starting address of the program
[org 0x0100]

; Jump past the data/function definitions to the program entry point
    jmp start        

; Define the string "Hello world" terminated by a zero byte
string:
    db "Hello world", 0

; ------------------------------------------------------------------------
; Function: lengthstr
; Calculates the length of a zero-terminated string whose address
; is passed on the stack (near call). Returns length in AX.
; Stack layout on entry:
;   [BP+4] → offset of the string
; ------------------------------------------------------------------------
lengthstr:
    push bp            ; Save base pointer of caller
    mov bp, sp         ; Establish new stack frame

    ; Save registers that we'll modify
    push ax
    push bx
    push cx
    push di
    push si
    push es

    ; Prepare ES:DI to scan memory starting at passed-in string address
    push ds            ; Save DS
    pop es             ; Copy DS into ES
    mov di, [bp+4]     ; Load DI with offset of string argument

    ; Set CX to maximum possible (used as counter for SCASB)
    mov cx, 0ffffh
    xor al, al         ; AL = 0 to search for the zero terminator

    ; Scan forward in ES:DI for the zero byte, decrementing CX each time
    repne scasb        ; Repeat SCASB until AL matches [ES:DI] or CX = 0

    ; After scan:
    mov ax, 0ffffh     ; AX = all 1s
    sub ax, cx         ; AX = number of scanned bytes (including terminator)
    dec ax             ; Subtract 1 to exclude the terminator itself

    ; Restore registers in reverse order
    pop es
    pop si
    pop di
    pop cx
    pop bx
    pop ax

    pop bp             ; Restore original base pointer
    ret 2              ; Return, cleaning up the two-byte argument

; ------------------------------------------------------------------------
; Program entry point
; ------------------------------------------------------------------------
start:
    mov ax, string     ; Load DS:AX pointer to the string
    push ax            ; Push string offset for lengthstr
    call lengthstr     ; Call function to compute length

    ; Upon return, AX holds the length of "Hello world"
    ; We will now exit to DOS
    mov ax, 4C00h      ; DOS function 4Ch: terminate program with return code AL
    int 21h            ; DOS interrupt

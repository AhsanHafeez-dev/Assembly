[org 0x0100]
; ------------------------------------------------------------------
; Program Purpose:
; iAPX 8088 / 80386 Assembly (MS-DOS)
; Demonstrates switching from Real Mode to Protected Mode.
; - Creates a simple GDT with null, code, and data segments.
; - Loads the GDT.
; - Sets CR0 to enable Protected Mode.
; - Performs far jump to 32-bit code segment.
; - Sets up segment registers and stack in protected mode.
; - Writes a character 'A' to video memory.
; NOTE: After switching to protected mode, DOS interrupts (like int 21h)
;       no longer work. This code is mostly educational.
; ------------------------------------------------------------------

jmp start                   ; skip over data section

; ---------------------------
; Global Descriptor Table (GDT)
; ---------------------------
gdt:
    dd 0x00000000            ; null descriptor (required)
    dd 0x0000FFFF,0x00CF9A00 ; code segment descriptor (base=0, limit=0xFFFFF, DPL=0, executable)
    dd 0x0000FFFF,0x00CF9200 ; data segment descriptor (base=0, limit=0xFFFFF, writable)

; ---------------------------
; GDT register structure
; ---------------------------
gdtreg:
    dw 0x17                  ; limit (size of GDT - 1 = 3 entries * 8 - 1 = 23 = 0x17)
    dd 0x00000000            ; base (filled at runtime)

; ---------------------------
; Stack space (256 doublewords = 1024 bytes)
; ---------------------------
stack: times 256 dd 0
stacktop:                    ; label for top of stack

; ---------------------------
; Code Section
; ---------------------------
start:
    ; Enable A20 line (function 2401h, INT 15h)
    mov ax,0x2401
    int 0x15

    ; Setup GDT base dynamically
    xor eax,eax
    mov ax,cs                ; get current CS segment
    shl eax,4                ; convert to linear base address
    mov [gdt+0x08+2],ax      ; patch code segment base low word
    shr eax,16
    mov [gdt+0x08+4],al      ; patch code segment base high byte

    ; Setup stack pointer (EDX = linear address of stack top)
    xor edx,edx
    mov dx,cs
    shl edx,4
    add edx,stacktop

    ; Setup GDT register base = linear address of gdt
    xor eax,eax
    mov ax,cs
    shl eax,4
    add eax,gdt
    mov [gdtreg+2],eax

    ; Load GDT
    lgdt [gdtreg]

    ; Enter protected mode
    mov eax,cr0
    or eax,1
    cli                      ; clear interrupts (important before PM switch)
    mov cr0,eax

    ; Far jump to protected mode (CS=0x08 -> code descriptor)
    jmp 0x08:pstart

; ---------------------------
; Protected Mode (32-bit code)
; ---------------------------
[bits 32]
pstart:
    mov eax,0x10             ; data segment selector (2nd descriptor, index=2, offset=0x10)
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax
    mov esp,edx              ; set stack pointer (from earlier calculation)

    ; Write character 'A' into video memory (B8000h: text mode video buffer)
    mov byte [0x000B8000],'A'

    jmp $                    ; infinite loop (halt here, since DOS calls won’t work anymore)

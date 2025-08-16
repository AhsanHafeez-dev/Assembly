[org 0x0100]                 
; ----------------------------------------------------------
; Program Purpose:
; iAPX 8088 assembly program for MS-DOS
; Reads the root directory sector (FAT12/FAT16) directly
; using BIOS disk interrupt (INT 13h).
; Displays filenames (first 11 bytes of each 32-byte entry).
; ----------------------------------------------------------

jmp start                    ; jump over data section

; ---------------------------
; Data Section
; ---------------------------
sector:     times 512 db 0   ; buffer for one disk sector
entryname:  times 11 db 0    ; buffer for a single 11-char filename
            db 10,13,'$'     ; newline + DOS string terminator

; ---------------------------
; Code Section
; ---------------------------
start:
    ; Reset disk drive 0
    mov ah,0                 ; function 00h = reset disk
    mov dl,0                 ; DL=0 => first floppy drive (A:)
    int 0x13                 ; BIOS disk service
    jc error                 ; if carry set, jump to error

    ; Read root directory sector (CH=0, CL=2, DH=1)
    mov ah,2                 ; function 02h = read sector(s)
    mov al,1                 ; read 1 sector
    mov ch,0                 ; cylinder = 0
    mov cl,2                 ; sector number = 2
    mov dh,1                 ; head = 1
    mov dl,0                 ; drive = 0 (A:)
    mov bx,sector            ; ES:BX = buffer
    int 0x13                 ; BIOS disk read
    jc error                 ; if error, jump to error

    mov bx,0                 ; BX = offset inside sector

; ---------------------------
; Loop through directory entries
; Each entry = 32 bytes, filename = first 11 bytes
; ---------------------------
nextentry:
    mov di,entryname         ; DI -> output buffer
    mov si,sector            ; SI -> start of sector buffer
    add si,bx                ; SI -> current entry
    mov cx,11                ; copy 11 chars (filename + extension)
    cld                      ; clear direction flag
    rep movsb                ; copy [SI] -> [DI], CX times

    mov ah,9                 ; DOS function 09h - print string
    mov dx,entryname         ; DX -> filename buffer
    int 0x21                 ; print filename

    add bx,32                ; move to next directory entry
    cmp bx,512               ; processed all 512 bytes?
    jne nextentry            ; if not, process next entry

; ---------------------------
; Exit on error or after processing
; ---------------------------
error:
    mov ax,0x4C00            ; DOS terminate program (AH=4Ch, AL=00)
    int 0x21

bits 16
org 0x7c00

;
; REAL MODE CODE
;

mov [BOOT_DISK], dl  ; save disk number

; Setup stack
mov bp, 0x8000
mov sp, bp

;Print text
mov si, text
loop:
    lodsb
    mov ah, 0x0E    ; Function code for printing character
    int 0x10        ; BIOS interrupt call
    or al, al
    jne loop
; end loop

; Read kernel
xor ax, ax ; reset ax, es and ds
mov es, ax
mov ds, ax
mov bx, KERNEL_LOCATION ; ES:BX is the address of the buffer
mov dh, 20              ; If something is broken this nb is probably too low
mov ah, 0x02
mov al, dh              ; nb of sector to be read
mov ch, 0x00            ; cylinder nb (bits 0-5) upper bit of sector nb (6-7)
mov cl, 0x02            ; sector nb (bits 0-5) drive nb (6-7)
mov dh, 0x00            ; head nb
mov dl, [BOOT_DISK]     ; drive nb
int 0x13

; Set video mode
mov ah, 0x0
mov al, 0x3
int 0x10 
; Hide cursors
mov ah, 0x01   ; Set cursor function
mov cx, 0x2607 ; Hide cursors
int 0x10       ; BIOS video interrupt

; Start protected mode
cli
lgdt [GDT_Descriptor]
; change last bit of cr0 to 1
mov eax, cr0
or eax, 1
mov cr0, eax
; 32 bit protected mode !
; far jump
jmp CODE_SEG:start_protected_mode

;
; DATA
;
text:
    db "Bootloader loading...", 0



GDT_Start:
    null_descriptor:
        dd 0b0        ; 4 zeros
        dd 0b0        ; again
    code_descriptor:
        dw 0xffff   ; First 16 bits of the limit
        dw 0b0        ; First 24 bits of the base
        db 0b0        ; -
        db 0b10011010 ; pres, priv, type and type flag
        ;  p,p,t,type
        db 0b11001111
        ; Other + limit (last 4 bits)
        db 0b0        ; Last 8 bits of the base
    data_descriptor:
        dw 0xffff   ; First 16 bits of the limit
        dw 0b0        ; First 24 bits of the base
        db 0b0        ; -
        db 0b10010010 ; pres, priv, type and type flag
        ;  p,p,t,type
        db 0b11001111
        ; Other + limit (last 4 bits)
        db 0b0        ; Last 8 bits of the base
GDT_End:

CODE_SEG equ code_descriptor - GDT_Start
DATA_SEG equ data_descriptor - GDT_Start
; eq is used to set constant

KERNEL_LOCATION equ 0x200

GDT_Descriptor:
    dw GDT_End - GDT_Start - 1 ;size
    dd GDT_Start               ;start

BOOT_DISK: db 0

;
; PROTECTED MODE CODE
;

[bits 32]
start_protected_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x90000
    mov esp, ebp
    jmp KERNEL_LOCATION

times 510 - ($ - $$) db 0
dw 0xaa55


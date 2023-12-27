bits 16
org 0x7c00

;
; CODE
;

mov [BOOT_DISK], dl  ; save disk number

; Setup stack
mov bp, 0x7c00
mov sp, bp
mov si, text
loop:
    lodsb
    mov ah, 0x0E    ; Function code for printing character
    int 0x10        ; BIOS interrupt call
    or al, al
    jne loop
; end loop

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

GDT_Descriptor:
    dw GDT_End - GDT_Start - 1 ;size
    dd GDT_Start               ;start

BOOT_DISK: db 0

[bits 32]
start_protected_mode:
    ; in protected mode, video memory starts at 0xb8000
    ; first byte: char | second byte: colour
    mov al, 'A'
    mov ah, 0x0f
    mov [0xb8000], ax
    jmp $

times 510 - ($ - $$) db 0
dw 0xaa55


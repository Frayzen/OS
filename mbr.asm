bits 16
org 0x7c00


; Setup stack
mov bp, 0x9000
mov sp, bp
mov si, text
loop:
    lodsb
    mov ah, 0x0E    ; Function code for printing character
    int 0x10        ; BIOS interrupt call
    or al, al
    jne loop

; Endless loop to prevent the program from exiting
jmp $           ; Infinite loop

text:
    db "Hello World", 0

times 510 - ($ - $$) db 0
dw 0xaa55


bits 32
extern kernel_start

extern loadPageDirectory
extern enablePaging 

kernel_entry:
    call kernel_start

; Still to modify

loadPageDirectory:
    push ebp
    mov ebp, esp
    mov eax, [esp + 8]
    mov cr3, eax
    mov esp, ebp
    pop ebp
    ret

enablePaging:
    push ebp
    mov ebp, esp
    ; mov cr0, eax
    ; or 0x80000000, eax
    ; mov eax, cr0
    mov esp, ebp
    pop ebp
    ret

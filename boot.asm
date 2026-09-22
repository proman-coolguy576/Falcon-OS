bits 16
org 0x7C00

start:
    cli

    mov [boot_drive], dl

    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Enable A20
    in al, 0x92
    or al, 00000010b
    out 0x92, al

    ; Load kernel from LBA 1
    mov si, dap
    mov dl, [boot_drive]
    mov ah, 0x42
    int 0x13
    jc disk_error

    ; Load GDT
    lgdt [gdt_descriptor]

    ; Enter 32-bit protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode


disk_error:
    mov si, error_message

.print:
    lodsb
    test al, al
    jz .hang

    mov ah, 0x0E
    int 0x10
    jmp .print

.hang:
    cli
    hlt
    jmp .hang


boot_drive:
    db 0


error_message:
    db "DISK ERROR!", 0


; ============================================================
; BIOS EXTENDED DISK READ
; ============================================================

dap:
    db 0x10
    db 0
    dw 64
    dw 0x0000
    dw 0x1000
    dq 1


; ============================================================
; GDT
; ============================================================

align 8

gdt_start:

gdt_null:
    dq 0

gdt_code32:
    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0

gdt_data:
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0

gdt_code64:
    dw 0
    dw 0
    db 0
    db 10011010b
    db 10101111b
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start


; ============================================================
; 32-BIT PROTECTED MODE
; ============================================================

bits 32

protected_mode:

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov esp, 0x90000

    ; Copy kernel
    ; Source: 0x10000
    ; Destination: 0x100000
    ; Size: 32768 bytes

    mov esi, 0x10000
    mov edi, 0x100000

    mov ecx, 16384
    cld
    rep movsw


    ; ========================================================
    ; Clear page tables
    ; ========================================================

    xor eax, eax
    mov edi, 0x2000
    mov ecx, 3072 / 4
    rep stosd


    ; PML4 -> PDPT
    mov dword [0x2000], 0x3003

    ; PDPT -> Page Directory
    mov dword [0x3000], 0x4003

    ; Page Directory
    ; 2 MiB identity mapping
    mov dword [0x4000], 0x0083


    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax


    ; Load PML4
    mov eax, 0x2000
    mov cr3, eax


    ; Enable Long Mode
    mov ecx, 0xC0000080
    rdmsr

    or eax, 1 << 8

    wrmsr


    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax


    ; Enter 64-bit mode
    jmp 0x18:long_mode


; ============================================================
; 64-BIT LONG MODE
; ============================================================

bits 64

long_mode:

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov rsp, 0x90000

    ; Kernel is loaded at 1 MiB
    mov rax, 0x100000

    jmp rax


; ============================================================
; BOOT SIGNATURE
; ============================================================

times 510 - ($ - $$) db 0

dw 0xAA55
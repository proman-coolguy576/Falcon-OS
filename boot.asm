; ============================================================
; Falcon OS - 64-bit Bootloader
; Stage 1: BIOS -> 16-bit -> 32-bit -> 64-bit Long Mode
; NASM
; ============================================================

bits 16
org 0x7C00

start:
    cli

    ; BIOS gives us DL = boot drive.
    mov [boot_drive], dl

    ; Set temporary real-mode stack
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00

    ; --------------------------------------------------------
    ; Enable A20
    ; --------------------------------------------------------
    in al, 0x92
    or al, 00000010b
    out 0x92, al

    ; --------------------------------------------------------
    ; Load Global Descriptor Table
    ; --------------------------------------------------------
    lgdt [gdt_descriptor]

    ; --------------------------------------------------------
    ; Enter 32-bit Protected Mode
    ; --------------------------------------------------------
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode


; ============================================================
; 32-BIT PROTECTED MODE
; ============================================================

bits 32

protected_mode:

    ; Set data segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    ; Temporary 32-bit stack
    mov esp, 0x90000

    ; --------------------------------------------------------
    ; Clear page-table memory
    ;
    ; PML4 = 0x1000
    ; PDPT = 0x2000
    ; PD   = 0x3000
    ; --------------------------------------------------------

    xor eax, eax
    mov edi, 0x1000
    mov ecx, 3072 / 4
    rep stosd

    ; --------------------------------------------------------
    ; PML4[0] -> PDPT
    ; --------------------------------------------------------

    mov dword [0x1000], 0x2003
    mov dword [0x1004], 0

    ; --------------------------------------------------------
    ; PDPT[0] -> Page Directory
    ; --------------------------------------------------------

    mov dword [0x2000], 0x3003
    mov dword [0x2004], 0

    ; --------------------------------------------------------
    ; Page Directory
    ;
    ; Identity-map the first 1 GB using 2 MB pages.
    ; Each entry maps one 2 MB region.
    ; --------------------------------------------------------

    mov edi, 0x3000
    mov eax, 0x00000083
    mov ecx, 512

.map_2mb:
    mov [edi], eax
    mov dword [edi + 4], 0

    add eax, 0x200000
    add edi, 8

    loop .map_2mb

    ; --------------------------------------------------------
    ; Enable PAE
    ; --------------------------------------------------------

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; --------------------------------------------------------
    ; Tell CPU where PML4 is
    ; --------------------------------------------------------

    mov eax, 0x1000
    mov cr3, eax

    ; --------------------------------------------------------
    ; Enable Long Mode through EFER MSR
    ; --------------------------------------------------------

    mov ecx, 0xC0000080
    rdmsr

    or eax, 1 << 8          ; LME = Long Mode Enable

    wrmsr

    ; --------------------------------------------------------
    ; Enable Paging
    ; --------------------------------------------------------

    mov eax, cr0
    or eax, 1 << 31         ; PG
    mov cr0, eax

    ; --------------------------------------------------------
    ; Jump into 64-bit Long Mode
    ; --------------------------------------------------------

    jmp 0x18:long_mode


; ============================================================
; 64-BIT LONG MODE
; ============================================================

bits 64

long_mode:

    ; Set data segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; 64-bit stack
    mov rsp, 0x90000

    ; --------------------------------------------------------
    ; VGA TEXT MODE
    ;
    ; 0xB8000 = VGA text memory
    ; Each character = 2 bytes
    ;
    ; byte 0 = character
    ; byte 1 = color
    ; --------------------------------------------------------

    mov rdi, 0xB8000
    mov rsi, message
    mov ah, 0x0F

.print:
    lodsb

    test al, al
    jz .done

    stosw
    jmp .print

.done:
    cli

.hang:
    hlt
    jmp .hang


; ============================================================
; DATA
; ============================================================

boot_drive:
    db 0

message:
    db "FALCON OS - 64 BIT LONG MODE!", 0


; ============================================================
; GLOBAL DESCRIPTOR TABLE
; ============================================================

align 8

gdt_start:

; Null descriptor
gdt_null:
    dq 0

; 32-bit code segment
gdt_code32:
    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0

; Data segment
gdt_data:
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0

; 64-bit code segment
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
; BOOT SIGNATURE
; ============================================================

times 510 - ($ - $$) db 0
dw 0xAA55
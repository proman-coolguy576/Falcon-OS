; SPDX-License-Identifier: GPL-2.0-only
;
; Falcon OS Kernel
; Copyright (C) 2026 Falcon OS contributors
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License version 2.
;
; Falcon OS - 64-bit Kernel
; First kernel stage

bits 64

section .text

global kernel_start

kernel_start:

    ; --------------------------------------------------------
    ; VGA text memory
    ; 0xB8000
    ;
    ; Every character uses 2 bytes:
    ;   byte 0 = ASCII character
    ;   byte 1 = colour
    ; --------------------------------------------------------

    mov rdi, 0xB8000
    mov rsi, message
    mov ah, 0x0F

print_loop:

    lodsb

    test al, al
    jz kernel_done

    stosw
    jmp print_loop


kernel_done:

    cli

.hang:
    hlt
    jmp .hang


section .rodata

message:
    db "Welcome to Falcon OS!", 0
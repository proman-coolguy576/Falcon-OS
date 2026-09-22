bits 64

section .text

global kernel_start
extern kernel_main

kernel_start:
    call kernel_main

.hang:
    hlt
    jmp .hang
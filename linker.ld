/* SPDX-License-Identifier: GPL-2.0-only */

/*
 * Falcon OS Kernel Linker Script
 *
 * Kernel is loaded at 1 MiB (0x100000).
 */

ENTRY(kernel_start)

SECTIONS
{
    . = 0x100000;

    .text : ALIGN(4K)
    {
        KEEP(*(.text))
    }

    .rodata : ALIGN(4K)
    {
        *(.rodata)
    }

    .data : ALIGN(4K)
    {
        *(.data)
    }

    .bss : ALIGN(4K)
    {
        *(COMMON)
        *(.bss)
    }

    /DISCARD/ :
    {
        *(.comment)
        *(.note*)
    }
}
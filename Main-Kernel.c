/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Falcon OS - Main Kernel
 * Copyright (C) 2026 Falcon OS contributors
 */

#include <stdint.h>

#define VGA_MEMORY ((volatile uint16_t*)0xB8000)
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

static void clear_screen(void)
{
    for (int y = 0; y < VGA_HEIGHT; y++)
    {
        for (int x = 0; x < VGA_WIDTH; x++)
        {
            VGA_MEMORY[y * VGA_WIDTH + x] =
                ((uint16_t)0x0F << 8) | ' ';
        }
    }
}

static void print(const char *text)
{
    static int position = 0;

    while (*text)
    {
        VGA_MEMORY[position++] =
            ((uint16_t)0x0F << 8) | (uint8_t)*text;

        text++;
    }
}

void kernel_main(void)
{
    clear_screen();

    print("========================================");
    print("        FALCON OS KERNEL");
    print("========================================");

    while (1)
    {
        __asm__ volatile ("hlt");
    }
}
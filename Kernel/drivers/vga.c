/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Falcon OS - VGA Driver
 */

#include <stdint.h>

#define VGA_MEMORY  ((volatile uint16_t*)0xB8000)
#define VGA_WIDTH   80
#define VGA_HEIGHT  25

static uint8_t color = 0x0F;
static uint8_t row = 0;
static uint8_t column = 0;

void vga_clear(void)
{
    for (int y = 0; y < VGA_HEIGHT; y++)
    {
        for (int x = 0; x < VGA_WIDTH; x++)
        {
            VGA_MEMORY[y * VGA_WIDTH + x] =
                ((uint16_t)color << 8) | ' ';
        }
    }

    row = 0;
    column = 0;
}

void vga_putchar(char c)
{
    if (c == '\n')
    {
        column = 0;
        row++;
        return;
    }

    VGA_MEMORY[row * VGA_WIDTH + column] =
        ((uint16_t)color << 8) | (uint8_t)c;

    column++;

    if (column >= VGA_WIDTH)
    {
        column = 0;
        row++;
    }

    if (row >= VGA_HEIGHT)
        row = 0;
}

void vga_print(const char *text)
{
    while (*text)
    {
        vga_putchar(*text);
        text++;
    }
}

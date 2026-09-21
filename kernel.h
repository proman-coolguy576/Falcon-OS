/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Falcon OS - Kernel Header
 */

#ifndef FALCON_KERNEL_H
#define FALCON_KERNEL_H

#include <stdint.h>

/* Kernel */
void kernel_main(void);

/* VGA driver */
void vga_clear(void);
void vga_putchar(char c);
void vga_print(const char *text);

#endif


 /*
 * SPDX-License-Identifier: GPL-2.0-only
 */

#include <stdint.h>

struct IDTEntry
{
    uint16_t offset_low;
    uint16_t selector;
    uint8_t  ist;
    uint8_t  type_attr;
    uint16_t offset_mid;
    uint32_t offset_high;
    uint32_t zero;
} __attribute__((packed));

struct IDTPointer
{
    uint16_t limit;
    uint64_t base;
} __attribute__((packed));

static struct IDTEntry idt[256];
static struct IDTPointer idt_pointer;

void idt_init(void)
{
    for (int i = 0; i < 256; i++)
    {
        idt[i].offset_low = 0;
        idt[i].selector = 0x08;
        idt[i].ist = 0;
        idt[i].type_attr = 0x8E;
        idt[i].offset_mid = 0;
        idt[i].offset_high = 0;
        idt[i].zero = 0;
    }

    idt_pointer.limit = sizeof(idt) - 1;
    idt_pointer.base = (uint64_t)&idt;

    __asm__ volatile ("lidt %0" : : "m"(idt_pointer));
}
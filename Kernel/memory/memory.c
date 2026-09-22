/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Falcon OS - Basic Memory Manager
 */

#include <stdint.h>

#define MEMORY_START 0x100000
#define MEMORY_SIZE  0x100000

static uint8_t memory_map[MEMORY_SIZE / 4096];

void memory_init(void)
{
    for (uint32_t i = 0; i < sizeof(memory_map); i++)
        memory_map[i] = 0;
}

void *memory_alloc(uint32_t pages)
{
    for (uint32_t i = 0; i < sizeof(memory_map); i++)
    {
        if (memory_map[i] == 0)
        {
            memory_map[i] = 1;
            return (void *)(MEMORY_START + i * 4096);
        }
    }

    return 0;
}

void memory_free(void *address)
{
    uint32_t addr = (uint32_t)address;

    if (addr < MEMORY_START)
        return;

    uint32_t page = (addr - MEMORY_START) / 4096;

    if (page < sizeof(memory_map))
        memory_map[page] = 0;
}                             
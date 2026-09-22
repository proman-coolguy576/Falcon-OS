#include <stdint.h>

#define MOUSE_DATA    0x60
#define MOUSE_STATUS  0x64
#define MOUSE_COMMAND 0x64

static inline uint8_t inb(uint16_t port)
{
    uint8_t value;

    __asm__ volatile (
        "inb %1, %0"
        : "=a"(value)
        : "Nd"(port)
    );

    return value;
}

static inline void outb(uint16_t port, uint8_t value)
{
    __asm__ volatile (
        "outb %0, %1"
        :
        : "a"(value), "Nd"(port)
    );
}

void mouse_wait(void)
{
    for (volatile int i = 0; i < 100000; i++)
    {
        if (inb(MOUSE_STATUS) & 1)
            return;
    }
}

void mouse_enable(void)
{
    outb(MOUSE_COMMAND, 0xA8);
}

uint8_t mouse_read(void)
{
    mouse_wait();
    return inb(MOUSE_DATA);
}
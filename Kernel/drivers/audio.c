#include <stdint.h>

#define PIT_COMMAND 0x43
#define PIT_CHANNEL2 0x42
#define SPEAKER 0x61

static inline void outb(uint16_t port, uint8_t value)
{
    __asm__ volatile (
        "outb %0, %1"
        :
        : "a"(value), "Nd"(port)
    );
}

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

void audio_beep(uint32_t frequency)
{
    if (frequency == 0)
        return;

    uint32_t divisor = 1193180 / frequency;

    outb(PIT_COMMAND, 0xB6);

    outb(PIT_CHANNEL2, divisor & 0xFF);
    outb(PIT_CHANNEL2, (divisor >> 8) & 0xFF);

    uint8_t value = inb(SPEAKER);

    if ((value & 3) != 3)
        outb(SPEAKER, value | 3);
}

void audio_stop(void)
{
    uint8_t value = inb(SPEAKER);
    outb(SPEAKER, value & 0xFC);
}
#include <stdint.h>

#define KBD_DATA   0x60
#define KBD_STATUS 0x64

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

static const char keymap[128] = {
    0,
    0,
    '1','2','3','4','5','6','7','8','9','0',
    '-','=',
    '\b',
    '\t',
    'q','w','e','r','t','y','u','i','o','p',
    '[',']',
    '\n',
    0,
    'a','s','d','f','g','h','j','k','l',
    ';','\'','`',
    0,
    '\\',
    'z','x','c','v','b','n','m',
    ',','.','/',
    0,
    '*',
    0,
    ' '
};

char keyboard_get_char(void)
{
    if ((inb(KBD_STATUS) & 1) == 0)
        return 0;

    uint8_t scancode = inb(KBD_DATA);

    if (scancode & 0x80)
        return 0;

    if (scancode < 128)
        return keymap[scancode];

    return 0;
}
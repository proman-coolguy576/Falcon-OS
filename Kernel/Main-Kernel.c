#include <stdint.h>
#include "kernel.h"

#define VGA_MEMORY ((volatile uint16_t*)0xB8000)

#define WIDTH 80
#define HEIGHT 25

#define BLACK  0x00
#define NORMAL 0x0F
#define BLUE   0x19
#define GREEN  0x0A
#define CYAN   0x0B
#define YELLOW 0x0E

static int cursor_x = 0;
static int cursor_y = 0;

static int bash_open = 0;
static int notepad_open = 0;
static int files_open = 0;

static char command[64];
static int command_length = 0;

static void put(int x, int y, char c, uint8_t color)
{
    VGA_MEMORY[y * WIDTH + x] =
        ((uint16_t)color << 8) | (uint8_t)c;
}

static void clear_screen(uint8_t color)
{
    for (int y = 0; y < HEIGHT; y++)
    {
        for (int x = 0; x < WIDTH; x++)
            put(x, y, ' ', color);
    }

    cursor_x = 0;
    cursor_y = 0;
}

static void print_at(int x, int y, const char *text, uint8_t color)
{
    while (*text && x < WIDTH)
    {
        put(x++, y, *text++, color);
    }
}

static int string_equal(const char *a, const char *b)
{
    while (*a && *b)
    {
        if (*a != *b)
            return 0;

        a++;
        b++;
    }

    return *a == *b;
}

static void draw_desktop(void)
{
    clear_screen(BLUE);

    print_at(2, 1, "FALCON OS", NORMAL);

    print_at(4, 5, "[ NOTEPAD ]", NORMAL);
    print_at(25, 5, "[ FILE MANAGER ]", NORMAL);
    print_at(57, 5, "[ BASH ]", GREEN);

    for (int x = 0; x < WIDTH; x++)
        put(x, 22, '=', NORMAL);

    print_at(2, 23, "Falcon OS", NORMAL);
    print_at(60, 23, "Ready", NORMAL);
}

static void draw_window(const char *title, int x, int y, int w, int h)
{
    for (int i = 0; i < w; i++)
    {
        put(x + i, y, '-', NORMAL);
        put(x + i, y + h - 1, '-', NORMAL);
    }

    for (int i = 0; i < h; i++)
    {
        put(x, y + i, '|', NORMAL);
        put(x + w - 1, y + i, '|', NORMAL);
    }

    put(x, y, '+', NORMAL);
    put(x + w - 1, y, '+', NORMAL);
    put(x, y + h - 1, '+', NORMAL);
    put(x + w - 1, y + h - 1, '+', NORMAL);

    print_at(x + 2, y, title, NORMAL);
}

static void open_bash(void)
{
    clear_screen(BLACK);

    draw_window(" Falcon Bash ", 8, 3, 64, 18);

    print_at(11, 5, "Falcon Bash", GREEN);
    print_at(11, 6, "Type 'help' for commands.", NORMAL);

    print_at(11, 8, "falcon@os:~$ ", GREEN);

    cursor_x = 24;
    cursor_y = 8;

    command_length = 0;

    bash_open = 1;
    notepad_open = 0;
    files_open = 0;
}

static void open_notepad(void)
{
    clear_screen(BLACK);

    draw_window(" Notepad ", 10, 4, 60, 16);

    print_at(13, 6, "Falcon Notepad", CYAN);
    print_at(13, 8, "Welcome to Falcon OS!", NORMAL);
    print_at(13, 10, "Notepad is running.", NORMAL);

    notepad_open = 1;
    bash_open = 0;
    files_open = 0;
}

static void open_files(void)
{
    clear_screen(BLACK);

    draw_window(" File Manager ", 8, 3, 64, 18);

    print_at(11, 5, "Falcon File Manager", CYAN);

    print_at(11, 7, "[DIR] kernel", NORMAL);
    print_at(11, 8, "[FILE] boot.asm", NORMAL);
    print_at(11, 9, "[FILE] linker.ld", NORMAL);
    print_at(11, 10, "[FILE] Makefile", NORMAL);
    print_at(11, 11, "[FILE] README.md", NORMAL);

    files_open = 1;
    bash_open = 0;
    notepad_open = 0;
}

static void print_command_result(void)
{
    if (string_equal(command, "help"))
    {
        print_at(11, 10, "help  clear  echo  ver  ls  pwd  about", NORMAL);
    }
    else if (string_equal(command, "clear"))
    {
        open_bash();
        return;
    }
    else if (string_equal(command, "ver"))
    {
        print_at(11, 10, "Falcon OS 0.1", NORMAL);
    }
    else if (string_equal(command, "pwd"))
    {
        print_at(11, 10, "/", NORMAL);
    }
    else if (string_equal(command, "ls"))
    {
        print_at(11, 10, "kernel  boot.asm  linker.ld  Makefile", NORMAL);
    }
    else if (string_equal(command, "about"))
    {
        print_at(11, 10, "Falcon OS - experimental x86-64 OS", NORMAL);
    }
    else if (command_length >= 5 &&
             command[0] == 'e' &&
             command[1] == 'c' &&
             command[2] == 'h' &&
             command[3] == 'o' &&
             command[4] == ' ')
    {
        print_at(11, 10, command + 5, NORMAL);
    }
    else if (command_length != 0)
    {
        print_at(11, 10, "Command not found.", YELLOW);
    }

    print_at(11, 12, "falcon@os:~$ ", GREEN);

    cursor_x = 24;
    cursor_y = 12;

    command_length = 0;
}

static void bash_input(char key)
{
    if (key == '\n')
    {
        print_command_result();
        return;
    }

    if (key == '\b')
    {
        if (command_length > 0)
        {
            command_length--;

            if (cursor_x > 24)
                cursor_x--;

            put(cursor_x, cursor_y, ' ', BLACK);
        }

        return;
    }

    if (command_length < 63)
    {
        command[command_length++] = key;
        command[command_length] = '\0';

        put(cursor_x, cursor_y, key, NORMAL);

        cursor_x++;

        if (cursor_x >= 72)
        {
            cursor_x = 24;
            cursor_y++;
        }
    }
}

void kernel_main(void)
{
    draw_desktop();

    while (1)
    {
        char key = keyboard_get_char();

        if (key)
        {
            /*
             * Temporary keyboard shortcuts.
             *
             * B = Bash
             * N = Notepad
             * F = File Manager
             */

            if (!bash_open && !notepad_open && !files_open)
            {
                if (key == 'b')
                    open_bash();

                else if (key == 'n')
                    open_notepad();

                else if (key == 'f')
                    open_files();
            }
            else if (bash_open)
            {
                bash_input(key);
            }
        }

    }
}
# 🦅 Falcon OS

A small open-source 64-bit operating system project built from scratch.

## 🚀 About

Falcon OS is a learning-focused x86-64 operating system written mainly in:

* Assembly
* C

The project is being built from the ground up, starting with the bootloader and kernel.

## 🧩 Current Components

* 64-bit bootloader
* 64-bit kernel
* VGA text driver
* Basic memory manager
* Basic filesystem layer
* Interrupt Descriptor Table
* GNU Make build system

## 🛠️ Project Structure

```text
Falcon-OS/
├── boot.asm
├── linker.ld
├── Makefile
├── LICENCE
│
└── kernel/
    ├── Main-Kernel.c
    ├── kernel.asm
    ├── kernel.h
    │
    ├── drivers/
    │   └── vga.c
    │
    ├── interrupts/
    │   └── idt.c
    │
    ├── memory/
    │   └── memory.c
    │
    └── filesystem/
        └── fs.c
```

## 🎯 Goals

The long-term goal is to build:

* Hardware drivers
* Memory management
* Filesystem support
* Process management
* Keyboard and mouse support
* Graphics
* Desktop environment
* Applications

## 🧪 Status

**Early development**

Falcon OS is currently a work in progress. APIs, architecture, and file organization may change.

## 📜 License

Falcon OS is released under the **GNU General Public License v2.0 (GPL-2.0-only)**.

See [`LICENCE`](LICENCE) for the full license text.

## 🤝 Contributing

Contributions, experiments, bug fixes, and improvements are welcome.

If you modify Falcon OS, please follow the terms of the GPL-2.0 license.

---

**Built from scratch. Built to learn. Built to fly. 🦅**

# uboot, kernel, rootfs

## 概述

**Linux系统软件架构**主要分为4层，由低到高分别为：*引导加载程序(Bootloader)*，*系统内核(Kernel)*，*文件系统(File System)*，*用户程序(Application)*

### Bootloader

引导加载程序（Bootloader）是固化在硬件Flash中的一段引导代码，用于完成硬件的一些基本配置，**引导内核启动**。([firmware](https://en.wikipedia.org/wiki/Firmware) is a specific class of [computer software](https://en.wikipedia.org/wiki/Computer_software) that provides the [low-level control](https://en.wikipedia.org/wiki/High-_and_low-level) for a device's specific [hardware](https://en.wikipedia.org/wiki/Computer_hardware).)

同时，Bootloader会在自身与内核分区之间存放一些可设置的参数（Boot parameters），比如IP地址，串口波特率，要传递给内核的命令行参数。

### Kernel

系统内核（Kernel）是整个操作系统的**最底层**，它负责整个硬件的驱动，以及提供各种系统所需的核心功能，包括防火墙机制、是否支持LVM或Quota等文件系统等等，如果内核不认识某个最新的硬件，那么硬件也就无法被驱动，你也就无法使用该硬件。计算机真正工作的东西其实是硬件，例如数值运算要使用到CPU、数据储存要使用到硬盘、图形显示会用到显示适配器、音乐发声要有音效芯片、连接Internet 可能需要网络卡等等。内核就是控制这些芯片如何工作。

### File System

Linux文件系统（File System）中的文件是**数据的集合**，文件系统不仅包含着**文件中的数据**而且还有**文件系统的结构**，所有Linux 用户和程序看到的**文件**、**目录**、**软连接**及**文件保护信息**等都存储在其中。

文件系统是操作系统用于明确存储设备（常见的是磁盘，也有基于NAND Flash的固态硬盘）或分区上的文件的方法和数据结构；即在存储设备上组织文件的方法。操作系统中负责管理和存储文件信息的软件机构称为文件管理系统，简称文件系统。

### Application

用户应用程序（Application）为了完成某项或某几项特定任务而被开发运行于操作系统之上的计算机程序。

## Linux 启动过程





## Reference

1. 

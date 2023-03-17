# ko file

## introduction

**ko –> Kernel Object**

- **module file** used by the Linux kernel, the central component of the Linux operating system
- contains program code that extends the functionality of the Linux kernel, such as code for a **computer device driver**
- can be loaded without restarting the operating system
- may have other required module dependencies that must be loaded first.

## More Information

KO modules may be loaded by using the `insmod` Linux program. Installed kernel modules can be listed using the `lsmod` program, or they may be browsed in the `/proc/modules` directory.

As of Linux kernel version 2.6, `.ko` files are used in place of `.o` files and contain additional information that the kernel uses to load modules. The Linux program `modpost` can be used to convert `.o` files into `.ko` files.

**NOTE:** KO files may also be loaded by FreeBSD using the `kldload` program.


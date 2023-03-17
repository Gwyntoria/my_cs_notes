# Root File System

The root filesystem should generally be small, since it contains very critical files and a small, infrequently modified filesystem has a better chance of not getting corrupted. A corrupted root filesystem will generally mean that the system becomes unbootable except with special measures (e.g., from a floppy), so you don't want to risk it.

**The root directory generally doesn't contain any files**, except perhaps on older systems where the standard boot image for the system, usually called `/vmlinuz` was kept there. (Most distributions have moved those files the the `/boot` directory. Otherwise, **all files are kept in subdirectories under the root filesystem**:

- **`/bin`**
  Commands needed during bootup that might be used by normal users (probably after bootup).

- **`/sbin`**

  Like `/bin`, but the commands are not intended for normal users, although they may use them if necessary and allowed. `/sbin` is not usually in the default path of normal users, but will be in root's default path.

- **`/etc`**

  Configuration files specific to the machine.

- **`/root`**

  The home directory for user root. This is usually not accessible to other users on the system

- **`/lib`**

  Shared libraries needed by the programs on the root filesystem.

- **`/lib/modules`**

  Loadable kernel modules, especially those that are needed to boot the system when recovering from disasters (e.g., network and filesystem drivers).

- **`/dev`**

  Device files. These are special files that help the user interface with the various devices on the system.

- **`/tmp`**

  Temporary files. As the name suggests, programs running often store temporary files in here.

- **`/boot`**

  Files used by the bootstrap loader, e.g., LILO or GRUB. Kernel images are often kept here instead of in the root directory. If there are many kernel images, the directory can easily grow rather big, and it might be better to keep it in a separate filesystem. Another reason would be to make sure the kernel images are within the first 1024 cylinders of an IDE disk. This 1024 cylinder limit is no longer true in most cases. With modern BIOSes and later versions of LILO (the LInux LOader) the 1024 cylinder limit can be passed with logical block addressing (LBA). See the **lilo** manual page for more details.

- **`/mnt`**

  Mount point for temporary mounts by the system administrator. Programs aren't supposed to mount on `/mnt` automatically. `/mnt` might be divided into subdirectories (e.g., `/mnt/dosa` might be the floppy drive using an MS-DOS filesystem, and `/mnt/exta` might be the same with an ext2 filesystem).

- **`/proc`, `/usr`, `/var`, `/home`**

  Mount points for the other filesystems. Although `/proc` does not reside on any disk in reality it is still mentioned here. See the section about `/proc` later in the chapter.

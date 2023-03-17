# u-boot, kernel, rootfs烧录指令及启动参数

**Notes: ** 如果使用 HiBurn 烧录的固件无法正常运行，需要在 u-boot 中使用指令烧录

## 地址说明

dv300地址起始位为0x80000000；ev300地址起始位为0x40000000

以容量为 256M Bytes 的 DDR 内存为例：

![image-20221208133548351](../assets/image-20221208133548351.png)

## tftp

```sh
# board ip
setenv ipaddr 10.0.0.80
# tftp server ip
setenv serverip 10.0.1.101
# MAC
setenv ethaddr xx:xx:xx:xx:xx:xx
# netmask
setenv netmask 255.255.252.0
# gateway
setenv gatewayip 10.0.1.1

ping serverip 
```

## SPI nand Flash

### u-boot

```sh
mw.b 0x82000000 0xff 0x80000
tftp 0x82000000 u-boot-hi3516dv300.bin
nand erase 0x0 0x80000
nand write 0x82000000 0x0 0x80000
```

### kernel

```sh
mw.b 0x82000000 0xff 0x400000
tftp 0x82000000 uImage_hi3516dv300_smp
nand erase 0x100000 0x400000
nand write 0x82000000 0x100000 0x400000
```

### rootfs

```sh
mw.b 0x82000000 0xff 0x2000000
tftp 0x82000000 rootfs_hi3516dv300_2k_4bit.yaffs2
nand erase 0x500000 0xfa00000
nand write.yaffs 0x82000000 0x500000 0x11cc100
```

**注意：0x1183e00 为 rootfs 文件的实际大小（16 进制）**

## SPI  nor Flash

### u-boot

```sh
mw.b 0x42000000 0xff 0x80000
tftp 0x42000000 u-boot-hi3516ev300.bin
sf probe 0x0;sf erase 0x0 0x80000;sf write 0x42000000 0x0 0x80000
```

### kernel

```sh
mw.b 0x42000000 0xff 0x400000
tftp 0x42000000 uImage_hi3516ev300
sf probe 0x0;sf erase 0x100000 0x400000;sf write 0x42000000 0x100000 0x400000
```

### rootfs

```sh
mw.b 0x42000000 0xff 0xb00000
tftp 0x42000000 rootfs_hi3516ev300_64k.jffs2
sf probe 0x0;sf erase 0x500000 0xb00000;sf write 0x42000000 0x500000 0xb00000
```

## EMMC

### u-boot

```shell
mw.b 0x82000000 0xff 0x80000
tftp 0x82000000 u-boot-hi3516dv300.bin
mmc write 0x0 0x82000000 0x0 0x400
```

### kernel

```shell
mw.b 0x82000000 0xff 0x400000
tftp 0x82000000 uImage_hi3516dv300_smp
mmc write 0 0x82000000 0x800 0x2000
```

### rootfs

```shell
mw.b 0x82000000 0xff 0x6000000
tftp 0x82000000 rootfs_hi3516dv300_256M.ext4
mmc write.ext4sp 0 0x82000000 0x2800 0x30000
```





## 配置启动参数

**Notes: **linux-4.9.y kernel 默认文件系统只读，需要在 bootargs 中加入 rw 选项，文件系统才可读写

`bootargs`中`mem`的数值为系统内存的大小，需要与load3516dv300文件中的表示的`os_mem`相匹配，属于Linux OS的部分

### nand flash

```shell
setenv bootargs 'mem=512M console=ttyAMA0,115200 root=/dev/mtdblock2 rootfstype=yaffs2 rw mtdparts=hinand:1M(boot),4M(kernel),250M(rootfs)'
setenv bootcmd 'nand read 0x82000000 0x100000 0x400000;bootm 0x82000000'
```

### nor flash

```shell
setenv bootargs 'mem=32M console=ttyAMA0,115200 root=/dev/mtdblock2 rootfstype=jffs2 rw mtdparts=hi_sfc:1M(boot),4M(kernel),11M(rootfs)'
setenv bootcmd 'sf probe 0;sf read 0x42000000 0x100000 0x400000;bootm 0x42000000'
```

### eMMC

```sh
setenv bootargs 'mem=256M console=ttyAMA0,115200 root=/dev/mmcblk0p3 rw rootfstype=ext4 rootwait blkdevparts=mmcblk0:1M(boot),4M(kernel),256M(rootfs)'
setenv bootcmd 'mw.b 82000000 ff 0xC00000;mmc read 0 0x82000000 800 6000;bootm 0x82000000
```

## 修改load文件

**注：**不修改`load`文件是否会影响文件系统的启动暂未确定，`load`文件的作用是**为文件系统加载 SDK 提供的`.ko`文件**

```sh
mem_total=256                 # 256M, total mem
mem_start=0x80000000          # phy mem start
os_mem_size=128               # 128M, os mem
mmz_start=0x88000000;         # mmz start addr
mmz_size=128M;                # 128M, mmz size
```

**NOTE:** 可以不修改load文件，而在加载load文件是配置参数。

## Reference

1. [Uboot的bootargs引导参数说明](https://www.365seal.com/y/ABpkZMg6VM.html)
1. [海思芯片系统镜像烧写教程](https://zhuanlan.zhihu.com/p/71789194)
1. Release Doc/01.software/board/SDK 安装及升级使用说明.pdf


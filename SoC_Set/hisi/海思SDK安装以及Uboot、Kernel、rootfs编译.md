# 海思SDK安装以及uboot、kernel、rootfs编译

## Ubuntu修改默认脚本解释器为bash

**note: **在ubuntu上面默认使用的解释器不是bash，而是dash。dash是Ubuntu中默认使用的脚本解释器。

所以当脚本文件的第一行为`#!/bin/sh`时，Ubuntu将使用默认的dash去解释脚本文件，只用修改`/bin/sh`的链接或者解除dash的默认设置，才可以将Ubuntu的默认解释器修改为bash。

```bash
ls -lh /bin/sh
# lrwxrwxrwx 1 root root 4 7月  25 15:55 /bin/sh -> dash
# Ubuntu系统默认将 /bin/sh 链接到 dash

# Configuring dash
sudo dpkg-reconfigure dash # 选 no

ls -lh /bin/sh
# lrwxrwxrwx 1 root root 4 7月  25 17:44 /bin/sh -> bash
# 将 /bin/sh 链接到 bash 后，脚本文件第一行声明为 /bin/sh 时，系统将使用bash作为脚本解释器
```

![image-20221021170845802](../assets/image-20221021170845802.png)

或者

```bash
# 直接修改链接
sudo ln -fs /bin/bash /bin/sh
```

## 安装依赖库

```bash
# 开发指南
sudo apt-get install gcc g++ make cmake vim net-tools tree u-boot-tools lib32z1 lib32z1-dev lib32stdc++6 zlib1g-dev liblzo2-dev uuid-dev libacl1-dev libncurses5-dev bison pkg-config autoconf gpart openssh-server xz-utils automake1.11
```

但是有错误结果：

![image-20220629144810420](../assets/image-20220629144810420.png)

```bash
# 后加入的依赖库
sudo apt-get install uuid-dev pkg-config autoconf
```

## 交叉编译链

Ubuntu 22.04 为64位机(20.04.4, 18.04.6为64位)，交叉编译工具链的目标为32位的开发板，所以需要先安装对应的32位库。

```bash
sudo apt-get install lib32z1 lib32z1-dev
```

**注：**

> - `lib32z1` 是海思开发环境搭建指南中指明需要的依赖库
> - `lib32z1-dev` 是博客[《海思hi3516d交叉编译器安装问题》](https://blog.csdn.net/spts2008/article/details/79640568)中所提出的解决方案

### 补遗：普通包和dev包的区别：

```bash
apt show lib32z1 lib32z1-dev
```

可以使用此命令查看两个包之间的区别

普通包的描述：

![普通包的描述](../assets/image-20220629102756348.png)

dev包的描述：

![dev包的描述](../assets/image-20220629103005434.png)

### 安装交叉编译链：

```bash
tar -xzvf arm-himix200-linux.tgz # 解压
cd arm-himix200-linux 
chmod +x ./arm-himix200-linux.install # 使文件可执行
sudo ./arm-himix200-linux.install # 执行安装脚本
# 执行完后重启，系统会重新加载 /etc/profile 文件，sdk 会将环境变量写入 /etc/profile
export PATH="/opt/hisi-linux/x86-arm/arm-himix200-linux/bin:$PATH" # 临时将编译链路径加入path变量
```

### 永久修改`path`变量

1. 系统环境变量

```bash
# 修改 /etc/profile 文件 –> 添加导入PATH变量的命令
export PATH="/opt/hisi-linux/x86-arm/arm-himix200-linux/bin:$PATH"
```

2. 用户环境变量

```bash
# 修改 ~/.bashrc 文件 –> 添加导入PATH变量的命令
# source /etc/profile
export PATH="/opt/hisi-linux/x86-arm/arm-himix200-linux/bin:$PATH"
```

## SDK 包

```bash
# 解压
tar -zxvf ...

# 修改unpack脚本的第一行(可将系统sh链接到bash)
# sh --> bash
# 执行unpack
./sdk.unpack

# 增加gzip补丁

# 添加linux-4.9.37 kernel 包
# 修改kernel包中scripts/dtc/下的dtc-lexer.lex.c_shipped
# 将yylloc添加extern声明
```

## 编译 ERRORS

### 1. `fseterr.c` 和 `fseeko.c` 需要移植

![image-20220629182549641](../assets/image-20220629182549641.png)

**Resolution: **添加补丁

**Reference: **

1. [问题解决：error: #error “Please port gnulib fseterr.c to your platform! Look at the definitions of ferror](https://blog.csdn.net/m0_37983106/article/details/108049940)
2. https://forum.openwrt.org/t/tools-bison-lib-fseterr-c-build-problems-on-18-06-0-due-to-glibc-2-28-changes/18926
3. https://src.fedoraproject.org/rpms/gcal//blob/rawhide/f/gcal-glibc-no-libio.patch

### 2. `fflush.c` 

**Error: **`_IO_IN_BACKUP` 未声明

**Resolution：**

1. 将 `_IO_IN_BACKUP` 直接替换为 `0x100`
2. 改 hi_gzip 下的 Makefile –> Makefile 中删除了 SDK 中原有的 patch 语句，只保留新增补丁的 patch 语句

**猜测：** 

1. 缺少头文件
2. 变量未声明为全局变量

### 3. Linux-4.9.37 kernel包中 

**Error: **yylloc 多次定义

**Resolution：**

改包中的源文件

**Reference: **

1. https://github.com/BPI-SINOVOIP/BPI-M4-bsp/issues/4
2. https://lkml.org/lkml/2020/4/1/1206

### 4. hibusybox

**`cp`指令执行问题**(后续使用原Makefile中未出现此问题)

```makefile
cp -af $(OSDRV_DIR)/opensource/busybox/$(BUSYBOX_VER)/_install/* $(OSDRV_DIR)/pub/$(PUB_ROOTFS)
```

原`makefile`中的`-af`指令在执行时无法创建文件夹，改为`-arf`后在删除通配符`*`，以保证将整个目录下的美内容复制过去

```makefile
cp -arf $(OSDRV_DIR)/opensource/busybox/$(BUSYBOX_VER)/_install/ $(OSDRV_DIR)/pub/$(PUB_ROOTFS)
```

### 5. hipctools

#### 5.1 `major`和`minor` 提示 is not a function or function pointer

```C
// 在对应的文件下添加以下头文件
#include <sys/sysmacros.h>
```

**Refence: **

1.  https://blog.csdn.net/MACMACip/article/details/107923340

#### 5.2 `mksquashfs.o` 中 `fwriter_buffer` 被多次定义：

修改源文件，修改为全局变量

 ## 烧录

1. [Hi3516dv300使用tftp进行烧录](https://blog.51cto.com/u_15316847/3220965)
2. HiTools 软件

**Reference: **

1.  [烧录 kernel 、rootfs](烧录 kernel 、rootfs.md)

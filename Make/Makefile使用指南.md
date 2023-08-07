# Makefile 使用指南

| Version | Date      | Description     |
| :------ | :-------- | :-------------- |
| 1.0     | 2023-7-20 | Initial release |

## 概述

`make`是一个命令，是可执行程序，用来解析`Makefile`文件

`Makefile`是一个文件，文件中描述了程序的编译规则

**采用`Makefile`的好处**：

1. 简化编译程序时所需要输入的命令，编译时只需要使用`make`命令就可以了
2. 可以节省编译时间，提高编译效率

## 基础语法规则

```makefile
target: prerequisites ...
    command
    ...
    ...
```

1. **target（目标）：**需要产生的文件。可以是一个object file（目标文件），或者是可执行文件，还可以是一个标签（label），或者叫动作（例如：clean）。
2. **prerequisites（依赖列表）：**生成该target所需要的内容。文件和/或target
3. **command（命令列表）：**该target要执行的命令（任意的shell命令）

> prerequisites 中如果有一个以上的文件比 target 文件要新的话，command 所定义的命令就会被执行。

**假想目标：**没有依赖的目标。clean就是一个假想目标，没有依赖，只有命令集。

这样的方法非常有用，我们可以在一个`Makefile`中定义不用的编译或是和编译无关的命令，比如程序的打包，程序的备份，等等。

### 示例一

```makefile
main : main.o fun.o # 创建目标main的依赖关系
    gcc main.o fun.o -o main 
main.o : main.c
    gcc -c main.c -o main.o
fun.o : fun.c
    gcc -c fun.c -o fun.o
clean:
    rm *.o main
```

### 示例二

```makefile
edit : main.o kbd.o command.o display.o \
        insert.o search.o files.o utils.o
    cc main.o kbd.o command.o display.o \
        insert.o search.o files.o utils.o -o edit

main.o : main.c defs.h
    cc -c main.c -o main.o
kbd.o : kbd.c defs.h command.h
    cc -c kbd.c -o kbd.o
command.o : command.c defs.h command.h
    cc -c command.c -o command.o
display.o : display.c defs.h buffer.h
    cc -c display.c -o display.o
insert.o : insert.c defs.h buffer.h
    cc -c insert.c -o insert.o
search.o : search.c defs.h buffer.h
    cc -c search.c -o search.o
files.o : files.c defs.h buffer.h command.h
    cc -c files.c -o files.o
utils.o : utils.c defs.h
    cc -c utils.c -o utils.o
    
clean :
    rm edit main.o kbd.o command.o display.o \
        insert.o search.o files.o utils.o
```

`make`并不管命令是怎么工作的，他只管执行所定义的命令。`make`会比较targets文件和prerequisites文件的修改日期，如果prerequisites文件的日期要比targets文件的日期要新，或者target不存在的话，那么，`make`就会执行后续定义的命令。

## make是如何工作的

1. `make`会在当前目录下找名字叫`Makefile`或`Makefile`的文件
2. 如果找到，它会找文件中的第一个目标文件（target），在上面的例子中，他会找到`edit`这个文件，并把这个文件作为最终的目标文件
3. 如果`edit`文件不存在，或是`edit`所依赖的后面的 `.o` 文件的文件修改时间要比 `edit` 这个文件新，那么，他就会执行后面所定义的命令来生成 `edit` 这个文件
4. 如果 `edit` 所依赖的 `.o` 文件也不存在，那么`make`会在当前文件中找目标为 `.o` 文件的依赖性，如果找到则再根据那一个规则生成 `.o` 文件。（这有点像一个堆栈的过程）
5. `.c`文件和`.h`文件是存在的啦，于是`make`会生成 `.o` 文件，然后再用 `.o` 文件生成`make`的终极任务，也就是执行文件 `edit` 了

### make会一层又一层地去找文件的依赖关系，直到最终编译出第一个目标文件

在找寻的过程中，如果出现错误，比如最后被依赖的文件找不到，那么`make`就会直接退出，并报错，而对于所定义的命令的错误，或是编译不成功，`make`并不关注

`make`只管文件的依赖性，即，如果在`make`找到了文件依赖关系之后，冒号后面的文件还是不在，`make`就会停止工作

## `Makefile`变量

### `Makefile`变量概述

`Makefile`变量类似于C语言当中的宏定义。当`Makefile`被`make`工具解析时，其中的变量会被展开(类似C语言中的预处理)

**变量的作用：**

- 保存文件名 列表
- 保存文件目录列表
- 保存编译器名
- 保存编译参数
- 保存编译的输出
- ……

### `Makefile`的变量分类

1. 自定义变量：在`Makefile`文件中定义的变量，`make`工具传给`Makefile`的变量
2. 系统环境变量：`make`工具解析`Makefile`前，读取系统环境变量并设置为`Makefile`的变量
3. 预定义变量（自动变量）：`Makefile`中预先就被定义好的变量

### 自定义变量语法

定义变量：

```makefile
# 变量名 = 变量值
objects = main.o kbd.o command.o display.o \ 
    insert.o search.o files.o utils.o # 命令行最前面一定是用TAP来缩进
    
# 修改编译器名
# cc = gcc
# cc = arm-linux-gcc
cc = arm-himix200-linux-gcc
```

引用变量：

```makefile
EXEC = edit
OBJ = main.o kbd.o command.o display.o \ 
    insert.o search.o files.o utils.o
    
cc = arm-himix200-linux-gcc
    
# 通过 $(变量名) 的形式引用变量
$(EXEC) : $(OBJ)
    $(cc) $(OBJ) -o $(EXEC)
    
......

clean : 
    rm $(EXEC) $(OBJ)
```

**注意：**

1. 变量是大小写敏感的
2. 变量一般都在`Makefile`文件的头部定义
3. 变量几乎可在`Makefile`的任何地方使用

`make`工具可以传给`Makefile`的变量：`make  cc = arm-himix200-linux-gcc`

### 系统环境变量

`make`工具可以识别并拷贝系统的环境变量并将其设置为`Makefile`的变量，在`Makefile`中可直接读取或修改拷贝后的变量

**查看环境变量：**env

```makefile
# pwd 打印工作目录的路径（系统环境变量）
clean : 
    rm $(EXEC) $(OBJ)
    echo "$(pwd)"
```

### 预定义变量

`Makefile`中被预定义的变量，可以直接使用

```makefile
$@ # 目标名
$< # 依赖文件列表的第一个文件
$^ # 依赖文件列表中除去重复文件的部分
```

```makefile
EXEC = main
OBJ = main.o fun.o
cc = arm-himix200-linux-gcc

$(EXEC) : $(OBJ)
    $(cc) $^ -o $@
main.o : mian.c
    $(cc) -c $< -o $@
fun.o : fun.c fun.h
    $(cc) -c $^ -o $@
clean :
    rm $(EXEC) $(OBJ)
```

## 让`make`自动推导

GNU的`make`很强大，它可以自动推导文件以及文件依赖关系后面的命令，于是我们就没必要去在每一个 `.o` 文件后都写上类似的命令，因为，`make`会自动识别，并自己推导命令。

只要`make`看到一个 `.o` 文件，它就会自动的把 `.c` 文件加在依赖关系中，如果`make`找到一个 `whatever.o` ，那么 `whatever.c` 就会是 `whatever.o` 的依赖文件。并且 `cc -c whatever.c -o whatever.o` 也会被推导出来，于是，`Makefile`文件就可以被简化

```makefile
OBJ = main.o kbd.o command.o display.o \
    insert.o search.o files.o utils.o

edit : $(OBJ)
    cc $(OBJ) -o edit

main.o : defs.h     # mian.c 被自动加入
kbd.o : defs.h command.h
command.o : defs.h command.h
display.o : defs.h buffer.h
insert.o : defs.h buffer.h
search.o : defs.h buffer.h
files.o : defs.h buffer.h command.h
utils.o : defs.h

.PHONY : clean
clean :
    rm edit $(OBJ)
```

这种方法，也就是make的“隐式规则”。

上面文件内容中， **`.PHONY` 表示 `clean` 是个伪目标文件**。

## 清空目标文件的规则

每个`Makefile`中都应该写一个清空目标文件（ `.o` 和执行文件）的规则，这不仅便于重编译，也很利于保持文件的清洁。

```makefile
clean : 
    rm edit $(OBJ)
```

更为稳健的做法：

```makefile
.PHONY : clean
clean :
    -rm edit $(OBJ)
```

 `.PHONY` 表示 `clean` 是一个“伪目标”。而在 `rm` 命令前面加了一个小减号的意思就是，也许某些文件出现问题，但不要管，继续做后面的事。

当然， `clean` 的规则不要放在文件的开头，不然，这就会变成make的默认目标，相信谁也不愿意这样。不成文的规矩是——“clean从来都是放在文件的最后”。

## `Makefile`的主要内容

显式规则、隐式规则、变量定义、文件指示、注释

1. 显示规则：显式规则说明了如何生成一个或多个目标文件。这是由`Makefile`的书写者明显指出要生成的文件、文件的依赖文件和生成的命令。
2. 隐式规则：由于我们的make有自动推导的功能，所以隐晦的规则可以让我们比较简略地书写 `Makefile`，这是由make所支持的。
3. 变量的定义：在`Makefile`中我们要定义一系列的变量，变量一般都是字符串，这个有点像你C语言中的宏，当`Makefile`被执行时，其中的变量都会被扩展到相应的引用位置上。
4. 文件指示：包括了三个部分
   1. 一个是在一个`Makefile`中引用另一个`Makefile`，类似C语言中的`#include`；
   2. 另一个是指根据某些情况指定`Makefile`中的有效部分，类似C语言中的预编译`#if`；
   3. 还有就是定义一个多行的命令。
5. 注释：`Makefile`中只有行注释，和UNIX的Shell脚本一样，其注释是用 `#` 字符，这个就像C/C++中的 `//` 一样。如果你要在你的`Makefile`中使用 `#` 字符，可以用反斜杠进行转义，如： `\#` 。

## 引用其它的`Makefile`

在`Makefile`使用 `include` 关键字可以把别的`Makefile`包含进来，这很像C语言的 `#include` ，*被包含的文件会原模原样的放在当前文件的包含位置*

```makefile
include <filename>
```

如果文件都没有指定绝对路径或是相对路径的话，`make`会在当前目录下首先寻找，如果当前目录下没有找到，那么，`make`还会在下面的几个目录下找：

1. 如果`make`执行时，有 `-I` 或 `--include-dir` 参数，那么`make`就会在这个参数所指定的目录下去寻找。
2. 如果目录 `<prefix>/include` （一般是： `/usr/local/bin` 或 `/usr/include` ）存在的话，`make`也会去找。

如果有文件没有找到的话，`make`会生成一条警告信息，但不会马上出现致命错误。它会继续载入其它的文件，一旦完成`Makefile`的读取，`make`会再重试这些没有找到，或是不能读取的文件，如果还是不行，`make`才会出现一条致命信息。

如果想让`make`不理那些无法读取的文件，而继续执行，你可以在include前加一个减号“-”

```makefile
-include <filename>
```

其表示，无论`include`过程中出现什么错误，都不要报错继续执行。和其它版本`make`兼容的相关命令是`sinclude`，其作用和这一个是一样的

## 函数

### `patsubst`

```makefile
SRCS := $(wildcard *.c)
OBJS := $(SRCS:%.c=%.o)
OBJS := $(patsubst %.c, %.o, $(SRCS))
```

`$(var:<pattern>=<replacement>)` 相当于 `$(patsubst <pattern>,<replacement>,$(var))`

`$(var: <suffix>=<replacement>)` 相当于 `$(patsubst %<suffix>,%<replacement>,$(var))`

```makefile
$(SRCS:%.c=%.o)
$(patsubst %.c, %.o, $(SRCS))
```

## Reference

[GNU make](http://www.gnu.org/software/make/manual/html_node/index.html)

[跟我一起写`Makefile`](https://seisman.github.io/how-to-write-makefile/index.html)

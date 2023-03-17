# GCC常用参数解释

## `-g` 使可执行程序包含调试信息

使`gdb`能够识别

## `-o` 指定输出文件名

一般语法：`gcc filename.c -o filename`

如果不加上 `-o filename`（直接使用`gcc filename.c` ），默认输出为`a.out`

## `-c` 只编译不链接

产生obj文件，不产生执行文件

## `-D` 添加宏定义

例：`gcc test.c -o test -DOPEN_PRINTF_DEBUG`

## `-Wall` 现实所有编译中出现的异常

## `-Werror` 将所有异常都转变为`error`提示

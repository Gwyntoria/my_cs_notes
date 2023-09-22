# 文件 IO 操作

## 示例

将log信息写入本地文件：

```c
int OpenLogFile(FILE* file, char* filename) {   
    // 打开文件以进行写入（二进制模式）
    file = fopen(filename, "a");

    if (file == NULL) {
        perror("无法打开文件");
        return 1;
    }

    return 0;
}

int WriteLogFile(char* log) {
    size_t dataSize = sizeof(log);

    // 将二进制数据写入文件
    size_t bytesWritten = fwrite(log, 1, dataSize, file);

    if (bytesWritten != dataSize) {
        perror("写入文件时出错");
        return 1;
    }

    return 0;
}

void CloseLogFile(FILE* file) {
    fclose(file);
}
```

## 读写权限

`fopen`的第二个参数规定了文件句柄的读写权限。

"w" 表示以写入（write）模式打开文件。这意味着你可以向文件写入数据，**如果文件不存在，则会创建一个新文件**。如果文件已存在，_它的内容将被截断（即清空）_，然后写入新的数据。

"b" 表示以二进制（binary）模式打开文件。在二进制模式下，文件中的数据将按原样写入，而不会进行特殊的文本处理。这意味着不会发生自动的文本转换（如换行符或回车符的转换），因此适用于处理二进制数据。

"r" 表示以读取（read）模式打开文件。**如果文件不存在，则打开失败**。

"a" 表示以追加（append）模式打开文件。如果文件不存在，则创建新文件；如果文件已存在，将在文件末尾追加数据而不清空原有数据。

"a+", "r+", "w+" 均表示以读写模式打开文件。

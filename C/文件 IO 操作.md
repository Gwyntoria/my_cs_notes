# 文件 IO 操作

## 示例

将log信息写入本地文件：

```c
int Com_OpenFile(FILE *file, const char *filename, const char *openType)
{
    file = fopen(filename, openType);

    if (file == NULL) {
        perror("Open file error");
        return 1;
    }

    return 0;
}

int Com_WriteFile(FILE *file, char *data, size_t dataSize)
{
    size_t bytesWritten = fwrite(data, 1, dataSize, file);

    if (bytesWritten != dataSize) {
        perror("Write file error");
        return 1;
    }

    return 0;
}

int Com_ReadFile(FILE *file, char *data, size_t dataSize)
{
    size_t bytesRead = fread(data, 1, dataSize, file);

    if (bytesRead != dataSize) {
        perror("Read file error");
        return 1;
    }

    return 0;
}

void Com_CloseFile(FILE *file)
{
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

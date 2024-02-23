# new vs malloc in C++

`new` 和 `malloc` 都是用于在 C++ 中在堆上动态分配内存的方法。

## 类型安全

- `new` 是一个运算符，它可以在内存分配的同时调用对象的构造函数，因此它是类型安全的。例如：`int *p = new int`; 会分配一个整数大小的内存，并调用 int 类型的构造函数。
- `malloc` 只是一个库函数，它返回 `void*`，不负责调用对象的构造函数。因此，如果你使用 `malloc` 分配内存，你需要自己调用构造函数。这可能导致类型不匹配和未初始化的问题。

## 大小信息

- `new` 不需要显式提供要分配的内存大小，它会根据类型信息自动计算。例如：`int *p = new int;` 只需要指定类型，而不需要指定大小。
- `malloc` 需要显式提供要分配的字节数，因此你需要手动计算大小并传递给 `malloc`。例如：`int *p = (int*)malloc(sizeof(int));`

## 返回类型

- `new` 返回的是对象的指针，而不是 `void*`。例如：`int *p = new int`;
- `malloc` 返回 `void*`，因此在使用时需要进行强制类型转换。例如：`int *p = (int*)malloc(sizeof(int));`

## 释放内存的方式

- 用 `new` 分配的内存，应该使用 `delete` 运算符来释放。
- 用 `malloc` 分配的内存，应该使用 `free` 函数来释放。

```c++
// 使用new和delete
int *p = new int;   // 分配内存并调用int的构造函数
delete p;           // 释放内存并调用int的析构函数

// 使用malloc和free
int *q = (int*)malloc(sizeof(int));   // 分配内存，但不调用构造函数
free(q);                             // 释放内存，但不调用析构函数
```

> **NOTE:** 除非有特殊的需求，推荐在 C++ 中使用 new 和 delete，因为它们提供了更好的类型安全性和便利性。

# Callback Function

In computer programming, a **callback** or **callback function** is any reference to executable code that is passed as an argument to another piece of code; that code is expected to call back (execute) the callback function as part of its job. This execution may be immediate as in a **synchronous callback**, or it might happen at a later point in time as in an **asynchronous callback**. They are also called **blocking** and **non-blocking**.

A callback is often back on the level of the original caller:

<img src="../assets/1920px-Callback-notitle.svg.png" alt="1920px-Callback-notitle.svg" width="100%" />

Firstly, the main function should invoke the registration function to register the callback function with the library function. Subsequently, the library function should be called, and within the library function, the callback function is then executed.

## Synchronous Callback(同步回调) vs. Asynchronous Callback(异步回调)

### 同步回调

**同步（Synchronous）**： 同步操作是指**程序按照预定的顺序执行**，每个操作都要等待上一个操作完成后才能继续。在同步模式下，程序会阻塞（即暂停执行）直到当前操作完成。这种方式可以确保操作的顺序和结果的可靠性，但可能会导致程序的响应时间较慢，尤其是在某些耗时的操作中。

同步回调指在函数调用过程中，被调用的函数会立即执行，然后**等待该函数执行完成后才继续执行下一步操作**。在同步回调中，调用方需要**等待被调用的函数执行完毕**才能继续执行自己的代码。

举例：假设有一个任务调度器，调度器需要执行一些任务并在任务完成后执行回调函数。同步回调的情况下，任务完成后会立即调用回调函数，但是**调度器会等待回调函数执行完毕后才能继续调度下一个任务**。

```c
#include <stdio.h>

// 同步回调函数
void callback(int result) {
    printf("Callback executed with result: %d\n", result);
}

// 模拟任务执行并调用回调
void performTaskSync(int value, void (*cb)(int)) {
    printf("Task started with value: %d\n", value);
    // 模拟任务执行
    int result = value * 2;
    // 调用回调函数
    cb(result);
    printf("Task completed\n");
}

int main() {
    printf("Main started\n");
    performTaskSync(5, callback);
    printf("Main completed\n");
    return 0;
}
```

### 异步回调

**异步（Asynchronous）**： 异步操作是指**程序在发起一个操作后，不会等待该操作完成就继续执行后续的操作。**在异步模式下，程序可以继续执行其他任务，而不必等待当前操作完成。当操作完成时，通常会通过回调函数、事件或轮询等方式来通知程序。这种方式可以提高程序的响应速度和效率，特别适用于需要处理多个并发操作的情况。A

异步回调指在函数调用过程中，**被调用的函数启动后会立即返回**，不会等待被调用函数执行完毕。**调用方可以继续执行其他操作**，被调用的函数在完成后会通过一定机制（如回调函数或者事件通知）来通知调用方。

举例：假设有一个网络请求的情景，在异步回调中，发起网络请求后不会阻塞主线程，而是在网络请求完成后通过回调函数通知结果。

```c
#include <stdio.h>

// 异步回调函数
void asyncCallback(int result) {
    printf("Async callback executed with result: %d\n", result);
}

// 模拟异步操作，假设这里是网络请求
void performAsyncTask(int value, void (*cb)(int)) {
    printf("Async task started with value: %d\n", value);
    // 模拟异步操作
    // ...（假设异步操作需要一段时间）
    // 实际中可能是通过线程、定时器等实现异步操作
    int result = value + 10;
    // 异步操作完成后调用回调函数通知结果
    cb(result);
}

int main() {
    printf("Main started\n");
    performAsyncTask(8, asyncCallback);
    printf("Main continues while waiting for async task to complete\n");
    // 这里可以继续执行其他操作，不必等待异步操作完成
    printf("Main completed\n");
    return 0;
}

```

`pthread_create()`是一个典型的执行异步回调的中间函数。

## 作用

### 功能的灵活实现



### 模块解耦

## Reference

1. [C++ Callback Solution](http://www.partow.net/programming/templatecallback/index.html)
2. [Implement callback routines in Java](https://web.archive.org/web/20080916192721/http://www.javaworld.com/javaworld/javatips/jw-javatip10.html)
3. [Interfacing C++ member functions with C libraries](https://web.archive.org/web/20110706132209/http://www.comp.ua.ac.be/publications/files/Adapter-Para04.pdf)

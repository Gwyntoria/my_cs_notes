# FreeRTOS

## Introduction

FreeRTOS is a **real-time operating system** kernel for embedded devices.

[FreeRTOS official site](https://www.freertos.org/)

## Process management

FreeRTOS provides methods for **multiple threads** or **tasks**, **mutexes**, **semaphores** and **software timers**.

FreeRTOS can be thought of as a **thread library** rather than an operating system, although command line interface and POSIX-like input/output (I/O) abstraction are available.

FreeRTOS implements multiple threads by having the host program call a thread tick method at regular short intervals.

## Main Functions

1. **任务管理**：FreeRTOS允许创建多个任务，每个任务都可以有不同的优先级和周期。它使用任务调度算法来管理任务之间的切换，以确保高优先级任务得到及时执行。
2. **内存管理**：FreeRTOS提供了用于动态内存分配和管理的函数。它允许任务在运行时请求和释放内存，以满足动态内存需求。
3. **通信和同步**：FreeRTOS支持多种通信和同步机制，如信号量、消息队列和互斥量。这些机制允许任务之间进行通信和协作，确保资源的正确共享和同步。
4. **中断处理**：FreeRTOS提供了中断处理机制，使得在中断服务程序（ISR）中可以使用RTOS功能。它允许在中断上下文中创建任务、发送消息等。
5. **定时器**：FreeRTOS包含一个软件定时器，可以用于定期执行任务或触发事件。定时器可以根据需要进行配置，以满足实时应用程序的需求。
6. **低功耗支持**：FreeRTOS具有优化的低功耗功能，可用于嵌入式系统中对电源的要求较高的应用。它提供了节能模式和睡眠模式等功能，以最大程度地降低功耗。

需要注意的是，引入FreeRTOS并不是适用于所有嵌入式系统的必要条件。如果你的系统*仅有简单的任务需求*，*或者对实时性要求不高*，*或者有其他特定的操作系统需求*，可能并不需要使用FreeRTOS。因此，在引入FreeRTOS之前，需要对你的嵌入式系统的需求进行仔细评估和分析。

## Quick Start

1. 下载、安装：
    - 访问FreeRTOS官方网站并下载最新版本的FreeRTOS内核代码。
    - 解压下载的文件并将其添加到你的项目目录中。
2. 配置内核：
    - 打开FreeRTOS文件夹中的`Source`子文件夹，你将看到一些不同的内核端口文件夹。
    - 根据你的目标平台选择一个内核端口文件夹，并将其复制到你的项目中。
    - 在所选内核端口文件夹中，根据你的需求进行配置。主要的配置文件是`FreeRTOSConfig.h`，你可以根据你的系统要求进行相应的修改，如任务堆栈大小、优先级等。
3. 创建任务：
    - 在你的应用程序中，创建任务的函数。一个任务是一个独立的代码单元，可以并发地运行。
    - 使用FreeRTOS提供的API函数创建任务。常用的API函数有`xTaskCreate()`和`xTaskCreateStatic()`，它们用于**动态创建任务**和**静态创建任务**。
    - 在任务函数中编写你的任务代码。
4. 启动调度器：
    - 在你的应用程序的入口点，添加调度器的启动代码。
    - 调用`vTaskStartScheduler()`函数，它将开始任务的调度并运行你的应用程序。
5. 使用其他FreeRTOS功能：
    - FreeRTOS提供了许多其他功能，如信号量、消息队列、定时器等。
    - 你可以使用这些功能来实现任务之间的通信、同步和定时控制。
    - 了解这些功能并使用适当的API函数进行配置和操作。
6. 编译和调试：
    - 使用你的编译器和开发环境将FreeRTOS集成到你的项目中。
    - 确保正确设置编译器选项，并将FreeRTOS的源文件和你的应用程序文件一起编译。
    - 使用调试工具进行调试，并根据需要进行迭代和优化。

## Multitasking vs Multithreading

### Similarities

1. 并发执行：无论是多任务还是多线程，都**允许多个任务或线程并发地执行**，提高系统的吞吐量和响应性。
2. 分时调度：多任务和多线程都需要通过调度器或操作系统来进行任务或线程的调度，确定任务或线程的执行顺序和时间片。
3. 共享资源：多任务和多线程都可能需要访问共享的资源，需要使用同步机制（如互斥量、信号量）来保护共享资源，以防止竞态条件和数据损坏。
4. 并行性：在某些情况下，多任务和多线程可以在多个处理器核心上并行执行，以进一步提高系统的性能。

### Differences

1. 上下文切换：多任务在切换任务之间需要保存和恢复任务的完整上下文，包括寄存器值和堆栈。多线程则在切换线程时只需保存和恢复线程的部分上下文，因为它们通常在同一进程中共享相同的地址空间。
2. 调度策略：多任务和多线程的调度策略可能不同。多任务通常使用抢占式调度，其中任务按照优先级进行调度，具有更高优先级的任务可以打断正在执行的低优先级任务。多线程的调度策略可以是抢占式或协作式，协作式调度依赖于线程主动释放CPU的控制权。
3. 系统开销：多线程通常具有较低的系统开销，因为线程之间切换的开销相对较小。相比之下，多任务在任务之间切换时需要更多的系统开销，因为需要保存和恢复更多的上下文信息。
4. 实时性能：多任务通常用于实时嵌入式系统，提供精确的任务调度和响应时间保证。多线程通常在通用操作系统中使用，实时性能可能相对较差。

## Example of FreeRTOS usage process

```c
#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h"

// 任务句柄
TaskHandle_t xTask1Handle, xTask2Handle;

// 任务1
void vTask1(void *pvParameters)
{
    while (1)
    {
        printf("Task 1 is running\n");
        vTaskDelay(pdMS_TO_TICKS(1000));  // 延时1秒
    }
}

// 任务2
void vTask2(void *pvParameters)
{
    while (1)
    {
        printf("Task 2 is running\n");
        vTaskDelay(pdMS_TO_TICKS(500));  // 延时500毫秒
    }
}

int main(void)
{
    // FreeRTOS初始化
    BaseType_t status = xTaskCreate(vTask1, "Task 1", configMINIMAL_STACK_SIZE, NULL, 1, &xTask1Handle);
    if (status != pdPASS)
    {
        printf("Failed to create Task 1\n");
        return -1;
    }

    status = xTaskCreate(vTask2, "Task 2", configMINIMAL_STACK_SIZE, NULL, 1, &xTask2Handle);
    if (status != pdPASS)
    {
        printf("Failed to create Task 2\n");
        return -1;
    }

    // 启动调度器
    vTaskStartScheduler();

    // 如果调度器启动失败，则会执行到这里
    printf("Failed to start FreeRTOS scheduler\n");

    return -1;
}

// 空闲任务钩子函数
void vApplicationIdleHook(void)
{
    // 空闲任务钩子函数
}

// 硬件定时器中断服务例程
void vApplicationTickHook(void)
{
    // 定时器中断服务例程
}

// 硬件异常中断服务例程
void vApplicationStackOverflowHook(TaskHandle_t xTask, char *pcTaskName)
{
    // 栈溢出处理
}
```

以上示例包含两个简单的任务（Task 1和Task 2），每个任务在循环中打印一条消息，并通过调用`vTaskDelay()`函数实现不同的延时。

在`main()`函数中，首先使用`xTaskCreate()`函数创建两个任务，并指定任务的*处理函数*、*任务名*、*堆栈大小*、*优先级*和*任务句柄*。然后，通过调用`vTaskStartScheduler()`函数启动FreeRTOS调度器。

在调度器启动后，任务将按照其优先级进行调度，`vTask1()`和`vTask2()`将交替执行。

此外，示例中还包含了几个可选的FreeRTOS钩子函数，例如`vApplicationIdleHook()`、`vApplicationTickHook()`和`vApplicationStackOverflowHook()`。这些钩子函数*提供了额外的功能扩展和错误处理机制*。

请注意，以上示例仅提供了基本的使用流程，具体的应用场景和硬件平台可能需要进一步的适配和配置。在实际开发中，您还需要包含适当的FreeRTOS头文件，并根据实际需求进行更多的配置和任务管理。

## Reference

1. [Mastering the FreeRTOS Real Time Kernel - a Hands On Tutorial Guide](https://www.freertos.org/fr-content-src/uploads/2018/07/161204_Mastering_the_FreeRTOS_Real_Time_Kernel-A_Hands-On_Tutorial_Guide.pdf)
2. [FreeRTOS V10.0.0 Reference Manual](https://www.freertos.org/fr-content-src/uploads/2018/07/FreeRTOS_Reference_Manual_V10.0.0.pdf)
3. [Wiki-FreeRTOS](https://en.wikipedia.org/wiki/FreeRTOS)
4. [FreeRTOS 内核基础知识](https://docs.aws.amazon.com/zh_cn/freertos/latest/userguide/dev-guide-freertos-kernel.html)
5. [FreeRTOS基础篇教程目录汇总](https://www.cnblogs.com/yangguang-it/p/7233591.html)
6. [野火-FreeRTOS视频教学](https://www.bilibili.com/video/av57449565/?vd_source=234174c1ff815dc17ba5ea7ee11a6e81)

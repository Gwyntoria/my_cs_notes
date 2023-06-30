# FreeRTOS

| Version | Date      | Description     |
| :------ | :-------- | :---------      |
| 1.0     | 2023-6-27 | Initial release |
| 1.1     | 2023-6-29 | 1. 调整目录结构<br />2. 新增堆栈分配和时间片调度的介绍 |

## Introduction

FreeRTOS is a **real-time operating system** kernel for embedded devices.

[FreeRTOS official site](https://www.freertos.org/)

## Process Management

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

需要注意的是，引入FreeRTOS并不是适用于所有嵌入式系统的必要条件。如果系统*仅有简单的任务需求*，*或者对实时性要求不高*，*或者有其他特定的操作系统需求*，可能并不需要使用FreeRTOS。因此，在引入FreeRTOS之前，需要对嵌入式系统的需求进行仔细评估和分析。

## Quick Start

1. 下载、安装：
    - 访问FreeRTOS官方网站并下载最新版本的FreeRTOS内核代码。
    - 解压下载的文件并将其添加到项目目录中。
2. 配置内核：
    - 打开FreeRTOS文件夹中的`Source`子文件夹，你将看到一些不同的内核端口文件夹。
    - 根据目标平台选择一个内核端口文件夹，并将其复制到项目中。
    - 在所选内核端口文件夹中，根据需求进行配置。主要的配置文件是`FreeRTOSConfig.h`，你可以根据系统要求进行相应的修改，如任务堆栈大小、优先级等。
3. 创建任务：
    - 在应用程序中，创建任务的函数。一个任务是一个独立的代码单元，可以并发地运行。
    - 使用FreeRTOS提供的API函数创建任务。常用的API函数有`xTaskCreate()`和`xTaskCreateStatic()`，它们用于**动态创建任务**和**静态创建任务**。
    - 在任务函数中编写任务代码。
4. 启动调度器：
    - 在应用程序的入口点，添加调度器的启动代码。
    - 调用`vTaskStartScheduler()`函数，它将开始任务的调度并运行应用程序。
5. 使用其他FreeRTOS功能：
    - FreeRTOS提供了许多其他功能，如信号量、消息队列、定时器等。
    - 你可以使用这些功能来实现任务之间的通信、同步和定时控制。
    - 了解这些功能并使用适当的API函数进行配置和操作。
6. 编译和调试：
    - 使用编译器和开发环境将FreeRTOS集成到项目中。
    - 确保正确设置编译器选项，并将FreeRTOS的源文件和应用程序文件一起编译。
    - 使用调试工具进行调试，并根据需要进行迭代和优化。

### Sample Code

```c
#include <FreeRTOS.h>
#include <task.h>

// 任务句柄
TaskHandle_t taskHandle1;
TaskHandle_t taskHandle2;

// 任务1
void task1(void *pvParameters) {
  while (1) {
    // 任务1的代码
    vTaskDelay(pdMS_TO_TICKS(1000));  // 延迟1秒
  }
}

// 任务2
void task2(void *pvParameters) {
  while (1) {
    // 任务2的代码
    vTaskDelay(pdMS_TO_TICKS(500));  // 延迟500毫秒
  }
}

void setup() {
  // 初始化FreeRTOS内核
  // 在这里进行内核的配置，例如堆栈分配器、时间片调度器等

  // 创建任务1
  xTaskCreate(task1, "Task 1", configMINIMAL_STACK_SIZE, NULL, 1, &taskHandle1);

  // 创建任务2
  xTaskCreate(task2, "Task 2", configMINIMAL_STACK_SIZE, NULL, 2, &taskHandle2);

  // 启动调度器，开始任务调度
  vTaskStartScheduler();
}

void loop() {
  // 此处的代码不会被执行，因为任务调度器已经在启动时接管了控制权
}

// 删除任务
void deleteTasks() {
  vTaskDelete(taskHandle1);
  vTaskDelete(taskHandle2);
}

int main() {
  setup();

  while (1) {
    // 主循环中可以进行其他操作
    // 例如检查输入、处理中断等

    // 当满足某些条件时，删除任务
    if (condition) {
      deleteTasks();
    }
  }
}

```

本实例中使用了两个简单的任务：task1 和 task2。任务函数中的代码可以根据需求进行编写。在示例中，每个任务都在一个无限循环中执行，并使用 `vTaskDelay` 函数添加了延迟。

在 `setup` 函数中，进行了FreeRTOS内核的初始化，并使用 `xTaskCreate` 函数创建了任务1和任务2。创建任务时，我们指定了*任务函数*、*任务名称*、*堆栈大小*、*传递给任务函数的参数*、*任务优先级（优先级数值越高表示优先级越高，最大优先级为 configMAX_PRIORITIES - 1）*和*任务句柄*。

然后，调用 `vTaskStartScheduler` 函数**启动调度器**，开始任务调度。一旦调度器启动，它将根据任务的优先级和调度算法来决定任务的执行顺序。

在 `main` 函数中，我们在一个主循环中执行其他操作，例如检查输入或处理中断。根据某些条件，我们可以调用 `deleteTasks` 函数来删除任务。

`deleteTasks` 函数使用 `vTaskDelete` 函数来删除任务，通过传递任务句柄作为参数。

**NOTES：** 实际的应用程序需要更多的配置和任务，需要根据特定的需求进行修改和扩展。

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

## Stack Allocation

- 在FreeRTOS中，默认情况下使用的是**静态堆栈分配**。这意味着在编译时为每个任务分配固定大小的堆栈空间。
- 你可以在 `FreeRTOSConfig.h` 文件中进行堆栈大小的配置。通过修改 `configMINIMAL_STACK_SIZE` 宏定义，可以设置堆栈的最小大小。还可以根据需要修改其他堆栈相关的宏定义，如 `configTOTAL_HEAP_SIZE` 来设置总的堆大小。

示例：

```c
// FreeRTOSConfig.h

#define configMINIMAL_STACK_SIZE    (128)  // 堆栈的最小大小
#define configTOTAL_HEAP_SIZE       (4096) // 总的堆大小
```

## Time Slice Scheduling

- FreeRTOS中的时间片调度是**基于优先级的抢占式调度**。较高优先级的任务将抢占较低优先级的任务，以确保优先级更高的任务能够及时执行。
- 默认情况下，FreeRTOS使用抢占式调度算法，任务的优先级越高，调度器给予的执行时间越多。
- 如果要进行时间片调度的配置，可以在 `FreeRTOSConfig.h` 文件中修改 `configUSE_TIME_SLICING` 宏定义。

示例：

```c
// FreeRTOSConfig.h

#define configUSE_TIME_SLICING    1  // 启用时间片调度
```

**NOTES:** 堆栈分配和时间片调度的配置需要在 `FreeRTOSConfig.h` 文件中进行修改，并在编译时生效。

## Reference

1. [Wikipedia-FreeRTOS](https://en.wikipedia.org/wiki/FreeRTOS)
2. [Mastering the FreeRTOS Real Time Kernel - a Hands On Tutorial Guide](https://www.freertos.org/fr-content-src/uploads/2018/07/161204_Mastering_the_FreeRTOS_Real_Time_Kernel-A_Hands-On_Tutorial_Guide.pdf)
3. [FreeRTOS V10.0.0 Reference Manual](https://www.freertos.org/fr-content-src/uploads/2018/07/FreeRTOS_Reference_Manual_V10.0.0.pdf)
4. [FreeRTOS 内核基础知识](https://docs.aws.amazon.com/zh_cn/freertos/latest/userguide/dev-guide-freertos-kernel.html)
5. [FreeRTOS基础篇教程目录汇总](https://www.cnblogs.com/yangguang-it/p/7233591.html)
6. [野火-FreeRTOS视频教学](https://www.bilibili.com/video/av57449565/?vd_source=234174c1ff815dc17ba5ea7ee11a6e81)

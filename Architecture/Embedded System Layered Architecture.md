# 嵌入式系统分层架构设计

## 问题核心

嵌入式系统分层的重点不是固定分成几层，而是让每一层都对应真实的系统边界。好的分层应该隔离变化来源、失败模型和语义差异：硬件会变，芯片会变，业务策略会变，外部接口也会变。如果这些变化都挤在同一层，代码很快会变成只能靠经验维护的工程。

工程上更关心下面几个问题：

- 下层实现替换后，上层是否不用改。
- 接口是否表达稳定能力，而不是暴露某个实现细节。
- 错误、超时、资源耗尽和硬件异常是否能在合适的层被处理。
- 时序、功耗、中断和并发约束是否被当成接口的一部分。
- 测试时能否 mock 掉硬件、设备或系统能力。

## 推荐分层模型

一个较完整的嵌入式软件可以先按一条主依赖链组织：

```text
[Application / API (Application Programming Interface)]
        |
[Service]
        |
[Device Driver]
        |
[Platform / BSP (Board Support Package) / HAL (Hardware Abstraction Layer)]
        |
[Hardware]
```

`System Runtime / Middleware` 不适合固定画在这条纵向链路里。它更像横向基础设施，给 service、device driver 或 platform layer 提供 RTOS (Real-Time Operating System)、日志、时间、存储、网络、升级和诊断等运行时能力。

```text
Application/API -> Service -> Device Driver -> Platform/BSP/HAL -> Hardware
                         |          |                    |
                         v          v                    v
                 System Runtime / Middleware
```

这不是要求所有项目都必须分成固定层数，而是提供一个职责参考。小项目可以合并部分层，大项目可以进一步拆分。判断标准不是目录数量，而是边界是否清楚、依赖是否单向、接口是否稳定。

## 每一层的职责边界

> 下表中常见缩写包括：MCU (Microcontroller Unit)、SoC (System on Chip)、pinmux (pin multiplexing)、DMA (Direct Memory Access)、I2C (Inter-Integrated Circuit)、SPI (Serial Peripheral Interface)、UART (Universal Asynchronous Receiver-Transmitter)、GPIO (General-Purpose Input/Output)、ADC (Analog-to-Digital Converter)、CLI (Command-Line Interface)、RPC (Remote Procedure Call)、HTTP (Hypertext Transfer Protocol) 和 UI (User Interface)。

| 层级 | 系统边界 | 主要职责 | 不应该做的事 |
| :--- | :--- | :--- | :--- |
| Hardware | 真实硬件 | 决定时序、功耗、中断模型、带宽和电气约束 | 写软件逻辑 |
| Platform / BSP / HAL | 板级和 MCU/SoC 能力 | 初始化时钟、pinmux、外设、DMA 和中断，抽象 I2C、SPI、UART、GPIO、Timer、ADC 等能力 | 写业务逻辑、理解具体外部芯片语义、包含传感器逻辑 |
| Device Driver | 具体器件 | 按 datasheet 操作设备、解析原始数据、维护简单设备状态 | 写业务策略、直接访问 MCU 寄存器 |
| System Runtime / Middleware | 横向运行时能力 | 提供 RTOS、文件系统、网络、日志、时间、内存和配置管理 | 绑定具体业务流程、强迫所有模块依赖复杂 runtime |
| Service | 系统行为 | 实现状态机、控制逻辑、数据融合、多设备协同和故障恢复 | 直接操作寄存器或通信总线细节 |
| Application / API | 系统外部接口 | 提供 CLI、RPC、HTTP、UI、配置入口和参数校验 | 绕过 service 访问底层模块 |

### Hardware：约束来自硬件

Hardware 不是软件层，但它决定软件边界。MCU/SoC、片上外设、外部 sensor、Flash、PMIC (Power Management Integrated Circuit)、codec (coder-decoder)、无线模组都会引入约束，包括启动时序、供电顺序、采样频率、总线带宽、中断触发方式、低功耗状态和恢复时间。

做架构设计时，不能把硬件当成一个抽象黑盒。比如一个 sensor 的数据就绪中断是否可靠、I2C 总线上是否有多个慢设备、Flash 擦写是否会阻塞关键任务，这些都会影响上层 service 的状态机和错误恢复策略。

### Platform / BSP / HAL：抽象平台能力

Platform / BSP / HAL 层的边界是板级和 MCU/SoC 能力。它负责初始化时钟、pinmux、电源域、UART、SPI、I2C、ADC、Timer、GPIO、DMA 等外设，处理 ISR (Interrupt Service Routine)，并把这些能力封装成上层可以使用的稳定接口。

典型代码类似：

```c
void bsp_uart1_init(uint32_t baudrate)
{
    rcc_enable_clock(RCC_USART1);
    rcc_enable_clock(RCC_GPIOA);

    gpio_config_alt(GPIOA, GPIO_PIN_9, GPIO_AF_USART1_TX);
    gpio_config_alt(GPIOA, GPIO_PIN_10, GPIO_AF_USART1_RX);

    USART1->BRR = uart_calc_brr(SystemCoreClock, baudrate);
    USART1->CR1 = USART_CR1_TE | USART_CR1_RE | USART_CR1_RXNEIE;
    USART1->CR1 |= USART_CR1_UE;

    nvic_enable_irq(USART1_IRQn, IRQ_PRIO_UART);
}

void USART1_IRQHandler(void)
{
    if ((USART1->SR & USART_SR_RXNE) != 0U) {
        uint8_t byte = (uint8_t)USART1->DR;
        ring_buffer_push(&uart1_rx_buffer, byte);
    }
}

int hal_uart_write(uart_port_t port, const uint8_t *buf, size_t len)
{
    USART_TypeDef *uart = uart_get_instance(port);

    for (size_t i = 0; i < len; ++i) {
        while ((uart->SR & USART_SR_TXE) == 0U) {
        }
        uart->DR = buf[i];
    }

    return 0;
}
```

典型接口类似：

```c
int i2c_read(uint8_t addr, uint8_t reg, uint8_t *buf, size_t len);
int gpio_write(gpio_pin_t pin, bool level);
int timer_start(timer_id_t id, uint32_t timeout_ms);
```

这一层内部可以继续拆成 `Peripheral Driver / LL (Low-Level)`和 `HAL / BSP`，但这通常是实现细节，不一定要在架构图里强行分成两层。只有在需要支持多个 MCU、多个 board、多个 SDK (Software Development Kit)，或者需要大量 mock 底层能力时，才值得把寄存器级 driver 和平台抽象接口分开。

Platform / HAL 的关键是可替换和可测试。Device Driver 依赖 HAL 后，测试时可以用 fake I2C 或 mock SPI 替代真实硬件；平台迁移时，也可以保留上层 device 和 service，只替换 HAL 实现。

HAL 最常见的问题是被具体设备污染。比如 `hal_i2c_read_temp()` 看起来方便，但它已经把温度传感器语义放进了 HAL。更好的做法是 HAL 只提供 `i2c_read()`，温度寄存器和温度换算留给温度传感器的 device driver。

### Device Driver：描述具体器件

Device Driver 层的边界是具体器件。它根据 datasheet 操作设备寄存器，完成设备初始化、模式切换、数据读取、原始数据解析和简单状态维护。

典型接口类似：

```c
int imu_init(const imu_config_t *config);
int imu_read_accel(imu_accel_t *out);
int flash_read(uint32_t addr, void *buf, size_t len);
```

这一层依赖 HAL，不关心 I2C、SPI 或 GPIO 背后由哪个 MCU 外设实现。比如 IMU (Inertial Measurement Unit) driver 只知道自己通过一个 bus 接口读写寄存器，不应该直接写 `I2C1->DR`。

Device Driver 可以做 raw data 到物理量的转换，比如把加速度计原始值转换成 `m/s^2`。但它不应该做姿态融合、运动识别、佩戴判断或控制策略。这些属于 service 层，因为它们不是单个设备的属性，而是系统行为。

### System Runtime / Middleware：提供通用运行时能力

System Runtime / Middleware 提供业务无关的基础设施，包括 RTOS、任务调度、互斥锁、消息队列、文件系统、网络协议栈、日志系统、时间系统、内存池、配置存储、升级框架和诊断能力。

这一层的职责是让 service 能用稳定方式运行，而不是把业务写进基础设施。比如日志模块可以定义日志等级、输出后端和缓冲策略，但不应该知道某个业务状态是否代表设备故障。文件系统可以提供读写和磨损均衡能力，但不应该知道健康数据的业务字段含义。

System Runtime / Middleware 不是所有模块的必经上层。Service 通常会使用 RTOS、日志、时间和存储能力；Device Driver 也可能使用 delay、锁或日志；文件系统、网络协议栈和升级框架还可能反过来依赖具体 device。它的重点是提供横向能力，而不是夹在 device 和 service 中间。

System Runtime / Middleware 还要明确阻塞语义。一个存储 API 是否可能擦除 Flash、一次网络发送是否可能等待重连、一个日志写入是否可能占用互斥锁，这些都应该被接口表达出来，否则 service 层无法正确设计任务优先级和超时策略。

### Service：实现系统行为

Service 层的边界是系统行为。它组合多个 device 和 system runtime 能力，负责状态机、控制逻辑、数据融合、任务编排、错误恢复、限流降级和一致性策略。

典型接口类似：

```c
int motion_service_update(void);
int motor_control_set_target(int32_t rpm);
int health_sample_service_start(void);
```

Service 是嵌入式项目最容易膨胀的层，因此要特别注意职责划分。单个 service 应该围绕一个稳定的业务能力组织，比如 motor control、data collection、connectivity、power management。跨 service 协作可以通过事件、消息队列或明确的同步接口完成，不要互相偷读内部状态。

Service 不应该直接访问 platform driver 或寄存器，也不应该关心某个 sensor 是通过 I2C 还是 SPI 连接。它关心的是设备能力、系统状态和业务约束，例如采样周期、控制目标、故障恢复次数、低功耗进入条件。

### Application / API：对外表达系统能力

Application / API 层的边界是系统外部。它把 service 暴露给用户、上位机、云端、手机 App、CLI、RPC、HTTP 或 UI。

这一层负责协议适配、权限控制、错误码映射和输出格式。参数校验可以分两段：API 层处理格式、范围和权限等外部输入问题，Service 层处理业务语义和系统状态约束。API 不应该绕过 service 直接访问 device，更不应该为了实现一个调试命令直接改寄存器。如果确实需要底层诊断能力，应通过受控的 diagnostic service 暴露，并限制权限和影响范围。

API 层通常是最稳定的层，因为它一旦被外部依赖，修改成本会很高。对外协议、命令格式、错误码和兼容策略都应该单独记录。

## 依赖方向和接口规则

分层架构的基本规则是*依赖单向流动*：**上层可以依赖下层提供的接口，下层不能反向依赖上层业务**。常见依赖关系如下：

```text
Application/API -> Service -> Device Driver -> Platform/BSP/HAL -> Hardware
                         |          |                    |
                         v          v                    v
                 System Runtime / Middleware
```

System Runtime / Middleware 是横向基础设施。Service 会使用 RTOS、日志、时间和存储能力；Device Driver 也可能使用延时、锁或日志，但要避免让 device 被复杂 runtime 强绑定。资源受限项目里，device driver 尽量保持轻量，复杂并发和恢复策略放到 service。

接口设计时需要明确：

- 参数所有权：调用方还是被调用方负责 buffer 生命周期。
- 阻塞语义：接口是否阻塞，最长可能阻塞多久。
- 超时策略：超时由调用方传入，还是模块内部固定。
- 错误分类：硬件故障、协议错误、参数错误、资源不足不能混成同一种返回值。
- 线程安全：接口能否在多任务中调用，能否在 ISR 中调用。
- 资源成本：栈、堆、DMA buffer、队列长度和最坏情况耗时。

## 常见错误

**Service 跨层访问寄存器**，比如在业务逻辑里直接写 `USART1->DR = x;`。这会让 service 和具体 MCU 绑定，后续换芯片、换串口或做单元测试都会被卡住。

**HAL 被设备语义污染**，比如在 HAL 里写 `hal_i2c_read_temp()`。HAL 应该表达 I2C 能力，温度寄存器和温度换算属于温度传感器的 device driver。

**Device Driver 写业务策略**，比如 IMU driver 里直接做姿态融合、跌倒检测或佩戴判断。Device Driver 可以提供加速度、角速度和状态寄存器信息，融合算法和判断策略应放到 service。

**System Runtime / Middleware 吞掉错误**，比如文件系统写失败只返回一个 `false`，不区分空间不足、擦写失败、校验失败和参数错误。错误信息丢失后，service 就无法做正确恢复。

**API 绕过业务层**，比如 CLI 命令直接调用 sensor 读写接口改变设备状态。这样会绕过 service 的状态机，导致系统状态和真实硬件状态不一致。

## 目录结构示例

一个中等规模固件可以按下面结构组织：

```text
firmware/
  board/
    board_init.c
    pinmux.c
  drivers/
    uart_ll.c
    i2c_ll.c
    spi_ll.c
    gpio_ll.c
  hal/
    hal_i2c.c
    hal_spi.c
    hal_gpio.c
    hal_timer.c
  devices/
    imu/
      imu.c
      imu_regs.h
    flash/
      flash.c
      flash_regs.h
  system/
    os_port.c
    event_dispatcher.c
    log.c
    timebase.c
    storage.c
  services/
    motion_service.c
    motion_event_handler.c
    power_service.c
    data_service.c
  app/
    cli.c
    rpc.c
    main.c
```

目录只是结果，不是目的。`board/`、`drivers/` 和 `hal/` 可以共同视为 platform layer 的实现拆分；如果项目很小，可以直接合并成一个 `platform/` 目录。`system/` 是横向基础设施，放在 `services/` 旁边即可，不需要在目录结构里体现成 service 的下层。

事件分发器通常属于 `system/`，前提是它只提供通用 event queue、publish/subscribe、handler registration、优先级和线程上下文切换等机制，不理解业务含义。事件处理器则按语义归属：处理运动状态、功耗策略或数据采集事件的 handler 放在 `services/`；处理 CLI、RPC、HTTP 或 MQTT (Message Queuing Telemetry Transport) 输入事件的 handler 放在 `app/`；处理中断和外设事件的 handler 放在 `board/`、`drivers/` 或 `hal/`；处理具体器件 data-ready、fault、mode-change 的 handler 放在 `devices/`。

## 项目规模与裁剪策略

小项目建议保留 3 到 4 层：platform、device、service、app。比如一个简单传感器采集项目，不需要过早拆出复杂 middleware，也不需要强行拆 `drivers/` 和 `hal/`，只要保证业务不直接碰寄存器即可。

中等项目建议明确拆出 device 层。只要系统里出现多个 sensor、外部 Flash、电源管理芯片、无线模组或执行器，device driver 就能显著降低 service 的复杂度。

大项目建议拆出完整 system runtime / middleware，并把日志、配置、存储、网络、升级、诊断、时间系统做成稳定基础设施。此时 service 更像一组业务状态机，重点是并发、错误恢复和模块协作。需要多平台移植时，再把 platform layer 内部拆成 `Peripheral Driver / LL`、`BSP` 和 `HAL`。

## 分层自检清单

设计或评审时，可以逐层问下面几个问题：

- 换 MCU、SDK 或 board 时，是否主要只需要改 platform layer。
- 换 sensor 型号时，是否主要只影响 device driver。
- 修改业务策略时，是否不需要改 platform 和 device driver。
- 修改外部协议时，是否不需要改 service 的核心状态机。
- 单元测试时，service 是否能用 mock device 和 fake system 运行。
- 每个接口是否写清楚超时、错误码、线程安全和 buffer 所有权。
- ISR、任务上下文和低功耗恢复路径是否有明确边界。
- 日志和诊断信息是否保留了足够的失败原因。

如果一个修改需要同时改 platform、device、service 和 API，通常说明边界设计有问题，或者这个变化本身跨越了多个系统边界，需要单独记录设计决策。

## 总结

嵌入式分层的本质，是把不同失败模型、变化来源和语义边界隔离开。层数可以裁剪，但平台能力、具体器件、运行时基础设施、业务行为和外部接口不应该互相泄漏。

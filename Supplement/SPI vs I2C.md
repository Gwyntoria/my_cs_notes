# SPI vs I2C

## SPI

SPI（Serial Peripheral Interface，串行外设接口）是一种常见的**串行通信协议**，主要应用于单片机系统中，用于在集成电路（Integrated Circuit, IC）之间进行数据传输。它是一种同步、**全双工**的通信方式，通常用于连接**微控制器或主处理器**与**外围设备（如传感器、存储器、显示屏等）**之间的通信。

### SPI接口定义

通过四根信号线进行通信：

- **时钟线（Serial Clock, SCLK）**：主设备生成的时钟信号，用于同步数据传输。时钟信号的频率由主设备控制，可根据应用需求进行设置。
- **数据输入线（Main In Sub Out, MISO）**：从设备向主设备传输数据的线路。从设备通过此线路将数据发送给主设备。
- **数据输出线（Main Out Sub In MOSI）**：主设备向从设备传输数据的线路。主设备通过此线路将数据发送给从设备。
- **片选线（Chip Select, CS）**：主设备用于选择要进行通信的特定从设备的线路。通过使相应的片选线低电平，主设备选择与之连接的从设备进行通信。

### SPI工作流程

1. 主设备*选择*与要之通信的从设备，将相应的片选线拉低。
2. 主设备产生时钟信号，控制数据的传输速率。
3. 主设备向从设备发送数据，通过数据输出线（MOSI）传输。
4. 从设备接收到数据后，通过数据输入线（MISO）回复数据给主设备。
5. 主设备继续产生时钟信号，进行下一位的数据传输。
6. 通信完成后，主设备将片选线拉高，结束与从设备的通信。

### SPI的优点

- **高速传输**：SPI可以支持高速数据传输，适用于需要快速数据交换的应用。
- **全双工通信**：SPI允许主设备和从设备同时发送和接收数据，实现全双工通信，提高通信效率。
- **简单硬件结构**：SPI只需要四根信号线，连接简单，适用于资源有限的系统。
- **灵活性**：SPI可以连接多个从设备，每个从设备都有独立的片选线，实现灵活的设备选择。

### SPI的限制

- **引脚数量**：由于每个从设备都需要独立的片选线，连接大量从设备时可能需要较多的引脚。
- **线路长度限制**：SPI的通信距离受到线路长度和信号衰减的限制。
- **设备兼容性**：由于SPI没有统一的标准，不同设备的SPI实现可能略有差异，需要根据具体设备的要求进行配置。

### SPI示例

#### C

```c
#include <linux/spi/spidev.h>
#include <fcntl.h>
#include <sys/ioctl.h>

static int spi_fd;

int spi_init() {
    // 打开SPI设备文件
    spi_fd = open("/dev/spidev0.0", O_RDWR);
    if (spi_fd < 0) {
        perror("Failed to open SPI device");
        return 1;
    }

    return 0;
}

int spi_deinit() {
    if (close(spi_fd) < 0) {
        perror("Failed to close SPI device");
        return 1;
    }

    return 0;
}

int spi_read() {
    unsigned char buf[2];
    struct spi_ioc_transfer transfer;
    int ret;

    // 初始化传输结构体
    memset(&transfer, 0, sizeof(struct spi_ioc_transfer));
    transfer.tx_buf = 0;
    transfer.rx_buf = buf;
    transfer.len = 2;

    // 进行SPI数据传输
    ret = ioctl(spi_fd, SPI_IOC_MESSAGE(1), &transfer);
    if (ret < 0) {
        perror("SPI transfer failed");
        return 1;
    }

    // 处理读取的数据
    // ...

}

int spi_write() {
    int ret;
    unsigned char buf[2];
    struct spi_ioc_transfer transfer;

    // 填充写入数据
    buf[0] = 0x01;
    buf[1] = 0xAB;

    // 初始化传输结构体
    memset(&transfer, 0, sizeof(struct spi_ioc_transfer));
    transfer.tx_buf = (unsigned long)buf;
    transfer.rx_buf = 0;
    transfer.len = 2;

    // 进行SPI数据传输
    ret = ioctl(spi_fd, SPI_IOC_MESSAGE(1), &transfer);
    if (ret < 0) {
        perror("SPI transfer failed");
        return 1;
    }

    // 写入数据成功

    return 0;

}

```

上述示例代码是基于Linux系统下的SPI设备文件（如/dev/spidev0.0），而具体的设备文件路径和SPI设备编号可能会有所不同，需要根据实际情况进行调整。

`struct spi_ioc_transfer` 结构体基本介绍：

```c
struct spi_ioc_transfer {
    __u64 tx_buf;                   // 发送数据缓冲区的用户空间地址或内核空间地址
    __u64 rx_buf;                   // 接收数据缓冲区的用户空间地址或内核空间地址
    __u32 len;                      // 数据传输的字节数
    __u32 speed_hz;                 // SPI总线的时钟频率
    __u16 delay_usecs;              // 传输完成后的延迟时间（微秒）
    __u8 bits_per_word;             // 每个字的位数
    __u8 cs_change;                 // 传输完成后是否改变片选信号
    __u32 pad;                      // 预留字段，保持对齐
};

```

下面是 `struct spi_ioc_transfer` 结构体中的一些重要成员：

1. `tx_buf`：发送数据缓冲区的用户空间地址或内核空间地址。如果不需要发送数据，可以设置为0。
2. `rx_buf`：接收数据缓冲区的用户空间地址或内核空间地址。如果不需要接收数据，可以设置为0。
3. `len`：数据传输的字节数。
4. `speed_hz`：SPI总线的时钟频率，以赫兹（Hz）为单位。
5. `delay_usecs`：传输完成后的延迟时间，以微秒（μs）为单位。
6. `bits_per_word`：每个字的位数。
7. `cs_change`：传输完成后是否改变片选信号。

`struct spi_ioc_transfer` 结构体的具体成员和字段的含义*可能会有所不同*，具体取决于所使用的硬件平台和设备驱动程序。因此，*建议查阅相关文档和示例代码以了解所使用的平台和设备的特定要求和配置*。

## I2C

I2C（Inter-Integrated Circuit）是一种常见的串行通信协议，用于在集成电路（IC）之间进行数据传输。它是一种同步、**半双工**的通信方式，通常用于连接多个设备（如传感器、存储器、转换器等）到同一总线上进行通信。

### I2C接口定义

- **串行数据线（Serial Data Line, SDA）**：用于传输数据位的线路。主设备和从设备都可以在该线上发送和接收数据。
- **串行时钟线（Serial Clock Line, SCL）**：由主设备产生的时钟信号。时钟信号用于同步数据的传输，控制数据位的传输速率。

### I2C工作流程

1. 主设备发起通信，向总线上发送一个起始信号（Start）。
2. 主设备发送一个地址字节，包括从设备的地址和读/写位。地址字节指定了要进行通信的特定从设备。
3. 从设备检测到自己的地址与主设备发送的地址匹配后，发送应答信号（Acknowledge）。
4. 主设备或从设备通过时钟线控制数据的传输。每个数据位在时钟的上升沿或下降沿进行传输。
5. 主设备发送数据位到从设备，或从设备发送数据位到主设备。**
6. 数据传输完成后，主设备或从设备发送应答信号（Acknowledge）确认接收。
7. 如果需要继续传输更多的数据位，重复步骤5-6。
8. 当传输完成时，主设备发送停止信号（Stop）来结束通信。

### I2C的优点

- **简单的硬件结构**：I2C通信只需要两根信号线，简化了硬件连接和布局。
- **多主设备支持**：I2C允许多个主设备连接到同一总线上，*通过地址选择不同的从设备进行通信*。
- **灵活的设备连接**：从设备可以动态加入或移除总线，使系统更加灵活和可扩展。

### I2C的限制

- **通信速率限制**：由于I2C使用的是半双工通信，其数据传输速率相对较低，不适合高速数据传输的应用。
- **线路长度限制**：I2C通信距离受到线路长度和信号衰减的限制。
- **引脚共享**：多个设备共享同一条总线时，需要确保设备之间没有冲突，避免数据干扰。

### I2C示例

#### C

```c
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>

static int i2c_fd;

int i2c_init() {
    // Open I2C device file
    i2c_fd = open("/dev/i2c-1", O_RDWR);
    if (i2c_fd < 0) {
        perror("Failed to open I2C device");
        return 1;
    }

    // Setting the I2C device address
    if (ioctl(i2c_fd, I2C_SLAVE, 0x50) < 0) {
        perror("Failed to set I2C device address");
        return 1;
    }

    return 0;
}

int i2c_deinit() {
    int ret;

    ret = close(i2c_fd);
    if (ret != 0) {
        perror("Failed to close I2C device");
        return 1;
    }

    return 0;
}

int i2c_read() {
    int ret;
    unsigned char buf[2];

    // Read data from I2C devices
    ret = read(i2c_fd, buf, 2);
    if (ret != 2) {
        perror("Failed to read from I2C device");
        return 1;
    }

    // 处理读取的数据
    // ...

    return 0;
}


int i2c_write() {
    int ret;
    unsigned char buf[2];

    // 填充写入数据
    buf[0] = 0x01;
    buf[1] = 0xAB;

    // Write data to I2C device
    ret = write(i2c_fd, buf, 2);
    if (ret != 2) {
        perror("Failed to write to I2C device");
        return 1;
    }

    // 写入数据成功

    return 0;
}

```

上述示例代码是基于Linux系统下的**I2C设备文件**（如/dev/i2c-1），而具体的设备文件路径和I2C总线编号可能会有所不同，需要根据实际情况进行调整。

## SPI与I2C的异同

### 相同点

1. 串行通信：SPI和I2C都是串行通信协议，使用单一的传输线进行数据传输，逐位地传输数据。
2. 主从架构：SPI和I2C都基于主从架构，其中一个主设备控制通信并选择从设备进行通信。
3. 数据传输速率：SPI和I2C都支持可变的数据传输速率，可以根据应用的需求选择不同的速率。

### 不同点

1. 连接方式：SPI使用四根信号线（时钟、数据输入、数据输出和片选线）进行连接，可以支持全双工通信，主设备可以同时发送和接收数据。而I2C只需要两根信号线（串行数据线（SDA）和串行时钟线（SCL）），采用半双工通信方式，只能在一个方向上进行数据传输。
2. 地址寻址：在I2C中，**每个从设备都有唯一的7位或10位地址，主设备使用地址来选择特定的从设备进行通信**。而在SPI中，**每个从设备都有一个片选线，主设备通过片选线来选择与之通信的特定从设备**。
3. 电气特性：SPI通常使用较高的电压电平（例如5V），而I2C通常使用较低的电压电平（例如3.3V），以适应不同的应用场景和设备要求。
4. 设备数量：SPI支持较少数量的设备连接，通常是主设备与多个从设备之间的通信。而I2C可以连接更多的设备，支持多主设备和多从设备之间的通信。
5. 性能和复杂性：由于SPI的连接方式和通信协议相对简单，它通常具有较高的性能和较低的延迟。而I2C由于支持更多的设备和更复杂的通信协议，其性能和延迟可能会略有下降，但可以实现更灵活的系统架构。

## Reference

1. [序列周边接口](https://zh.wikipedia.org/zh-cn/%E5%BA%8F%E5%88%97%E5%91%A8%E9%82%8A%E4%BB%8B%E9%9D%A2)
2. [Better SPI Bus Design in 3 Steps](https://www.pjrc.com/better-spi-bus-design-in-3-steps/)
3. [I²C](https://zh.wikipedia.org/zh-cn/I%C2%B2C)
4. [I²C Spec](/Reference/Z_Spec/I2C%20Manual%20AN10216.pdf)

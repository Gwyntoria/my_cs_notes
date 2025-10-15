# Golang 面试问题

## 1. 如何在 Go 中实现 TCP 服务器？请编写一个简单的 TCP 服务器示例，并解释其中的关键点

在 Go 中，可以使用 net 包来实现 TCP 服务器。以下是一个简单的 TCP 服务器示例：

```go
package main

import (
    "bufio"
    "fmt"
    "net"
    "strings"
)

func handleConnection(conn net.Conn) {
    defer conn.Close()
    reader := bufio.NewReader(conn)
    for {
        message, err := reader.ReadString('\n')
        if err != nil {
            fmt.Println("Connection closed")
            return
        }
        fmt.Printf("Received: %s", message)
        conn.Write([]byte(strings.ToUpper(message)))
    }
}

func main() {
    ln, err := net.Listen("tcp", ":8080")
    if err != nil {
        panic(err)
    }
    fmt.Println("Server started on port 8080")
    for {
        conn, err := ln.Accept()
        if err != nil {
            fmt.Println("Error accepting connection:", err)
            continue
        }
        go handleConnection(conn)
    }
}
```

关键点：

- net.Listen() 用于监听指定的 TCP 地址。
- ln.Accept() 会阻塞，直到接收到新的连接。
- handleConnection() 使用 go 关键字启动 Goroutine，以处理多个客户端连接。

## 2. Go 中的 goroutine 和线程有什么区别？

- Goroutine： Go 语言中的轻量级线程，由 Go 运行时管理。它是协程的实现，使用 go 关键字启动，具有极低的内存开销（约 2KB），数万个 Goroutine 也不会导致系统资源耗尽。
- 线程： 由操作系统管理，分配内存较多（如 1MB）。线程切换开销大，并且上下文切换涉及到系统级别的资源分配。

区别：

- 内存开销： Goroutine 更小，线程更大。
- 调度方式： Goroutine 由 Go 运行时调度，线程由操作系统调度。
- 切换开销： Goroutine 的切换由 Go 运行时管理，开销更小。
- 并发数量： Goroutine 可达到数十万，而线程受系统限制。

## 3. 在 Go 中，如何实现带有缓冲区的 Channel？

Go 语言中的 channel 可以通过指定缓冲区大小来创建带缓冲区的 channel：

```go
package main

import (
    "fmt"
    "time"
)

func main() {
    ch := make(chan int, 3) // 带缓冲区的channel，容量为3

    ch <- 1
    ch <- 2
    ch <- 3

    // 此时channel已满，再发送将阻塞
    go func() {
        ch <- 4
        fmt.Println("Sent 4")
    }()

    time.Sleep(time.Second)
    for i := 0; i < 4; i++ {
        fmt.Println("Received:", <-ch)
    }
}
```

关键点：

- make(chan int, 3)：创建缓冲区为 3 的 channel。
- 缓冲区未满时，发送操作不会阻塞；当缓冲区满时，发送操作阻塞，直到有接收者读取数据。

## 4. Go 中的接口与空接口的区别是什么？

- 接口 (Interface)： 定义了方法集，实现了这些方法的类型可以赋值给接口类型变量。例如：

```go
type Printer interface {
    Print()
}

type Document struct{}

func (d Document) Print() {
    fmt.Println("Printing document")
}
```

- 空接口 (interface{})： 不定义任何方法，可以接收任何类型的值：

```go
var any interface{}
any = 42
any = "Hello"
any = Document{}
```

区别：

- 接口定义了方法集，而空接口不定义任何方法；
- 空接口可存储任意类型的数据，用于实现泛型和多态。

## 5. Go 中的 defer 关键字是如何工作的？请结合示例说明

defer 用于延迟执行函数或语句，直到包含 defer 的函数返回时才执行，按逆序执行。

```go
package main

import "fmt"

func main() {
    defer fmt.Println("First Deferred")
    defer fmt.Println("Second Deferred")
    fmt.Println("Main function")
}
```

输出：

```txt
Main function
Second Deferred
First Deferred
```

关键点：

- defer 会将语句推入堆栈，最后入栈的语句最先执行（LIFO）。
- 常用于资源清理、文件关闭等场景。

## 6. 如何在 Go 中实现 HTTP 服务器？请编写一个简单示例

Go 内置 net/http 包，可轻松构建 HTTP 服务器：

```go
package main

import (
    "fmt"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, %s!", r.URL.Path[1:])
}

func main() {
    http.HandleFunc("/", handler)
    fmt.Println("Server started on :8080")
    http.ListenAndServe(":8080", nil)
}
```

关键点：

- http.HandleFunc()：注册路由和处理函数；
- http.ListenAndServe()：监听指定端口并启动服务器。

## 7. Go 中的 context 包有什么作用？如何优雅地取消 Goroutine？

context 用于在 Goroutine 之间传递取消信号、截止时间和元数据。

```go
package main

import (
    "context"
    "fmt"
    "time"
)

func task(ctx context.Context) {
    select {
    case <-time.After(2 * time.Second):
        fmt.Println("Task completed")
    case <-ctx.Done():
        fmt.Println("Task cancelled:", ctx.Err())
    }
}

func main() {
    ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
    defer cancel()

    go task(ctx)
    time.Sleep(2 * time.Second)
}
```

关键点：

- context.WithTimeout()：在指定时间后自动取消；
- ctx.Done()：监听取消信号；
- 避免 Goroutine 泄露，确保 cancel()被调用。

## 8. Go 中的 sync 包提供了哪些并发控制原语？

sync 包提供了如下并发控制原语：

- sync.Mutex：互斥锁，用于保护共享资源；
- sync.RWMutex：读写锁，区分读锁和写锁；
- sync.WaitGroup：等待一组 Goroutine 完成；
- sync.Once：确保某个操作只执行一次；
- sync.Cond：条件变量，用于广播和通知。

示例：

```go
var mu sync.Mutex
var counter int

func increment() {
    mu.Lock()
    defer mu.Unlock()
    counter++
}
```

## 9. Go 中的 select 语句是如何工作的？请举例说明

select 用于在多个 channel 操作中进行选择：

```go
package main

import (
    "fmt"
    "time"
)

func main() {
    ch1 := make(chan string)
    ch2 := make(chan string)

    go func() {
        time.Sleep(1 * time.Second)
        ch1 <- "from ch1"
    }()

    go func() {
        time.Sleep(2 * time.Second)
        ch2 <- "from ch2"
    }()

    select {
    case msg1 := <-ch1:
        fmt.Println(msg1)
    case msg2 := <-ch2:
        fmt.Println(msg2)
    }
}
```

## 10. 如何在 Go 中实现 HTTP 请求的超时控制？

使用 http.Client 配置 Timeout 字段：

```go
client := &http.Client{
    Timeout: 2 * time.Second,
}

resp, err := client.Get("http://example.com")
if err != nil {
    fmt.Println("Request timed out:", err)
    return
}
```

这样可以避免请求阻塞，确保程序稳定性。

## 11. 什么是 channel？

在 Go 语言中，**channel** 是一种内建的数据类型，用于 **在不同的 goroutine 之间安全地传递数据**。它是 Go 实现并发通信的核心机制之一，遵循的是 **通信顺序进程（CSP）模型**。

---

### 一、Channel 的基本概念

- Channel 是一个类型化的管道，支持一个 goroutine 向其中发送值，另一个 goroutine 从中接收值。
- 所有的发送和接收操作都是阻塞的，直到另一端准备好，这种机制可以隐式地实现同步。

**基本语法：**

```go
ch := make(chan int) // 创建一个无缓冲 channel
```

- `chan T` 表示传递类型为 `T` 的 channel；
- `make` 函数用来创建 channel 实例。

---

### 二、Channel 的操作

- **发送数据：** `ch <- value`
- **接收数据：** `value := <-ch`
- **关闭通道：** `close(ch)`（只能由发送方关闭）

**示例：**

```go
package main

import "fmt"

func main() {
    ch := make(chan string)

    go func() {
        ch <- "Hello, Channel"
    }()

    msg := <-ch
    fmt.Println(msg)
}
```

---

### 三、缓冲与非缓冲 Channel

- **非缓冲 Channel（默认）：** 发送操作会阻塞，直到接收者接收数据。
- **缓冲 Channel：** 使用 `make(chan T, n)` 创建，最多缓冲 `n` 个元素，缓冲未满时发送不会阻塞。

```go
ch := make(chan int, 2)
ch <- 1
ch <- 2
```

---

### 四、Channel 的特性

| 特性         | 描述                                                  |
| ------------ | ----------------------------------------------------- |
| 类型安全     | channel 是类型化的，只能发送与接收指定类型的值        |
| 同步机制     | 非缓冲通道用于同步，只有发送和接收都准备好，才会继续  |
| 线程安全     | 多个 goroutine 同时操作 channel 是安全的              |
| 单向 channel | 可以定义为只读或只写，如 `chan<- int` 或 `<-chan int` |

---

### 五、select 与 Channel 组合

`select` 用于监听多个 channel 的通信事件：

```go
select {
case msg := <-ch1:
    fmt.Println("received", msg)
case ch2 <- "hello":
    fmt.Println("sent message")
default:
    fmt.Println("no communication")
}
```

---

### 六、Channel 的使用场景

- 多个 goroutine 之间的通信；
- 控制 goroutine 的生命周期；
- 限流与信号通知；
- 实现生产者-消费者模型。

---

### 七、使用注意事项

- 向已关闭的 channel 发送数据会引发 panic；
- 从关闭的 channel 接收数据不会 panic，但会返回零值和 `false`；
- 不关闭 channel 并不会导致内存泄漏，只有在明确无发送者的情况下才需关闭。

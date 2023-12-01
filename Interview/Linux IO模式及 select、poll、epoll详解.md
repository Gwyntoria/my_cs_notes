# Linux IO 模式及 select、poll、epoll 详解

| Version | Date       | Description                |
| :------ | :--------- | :------------------------- |
| v1.0    | 2023-11-30 | Initial release            |
| v1.1    | 2023-12-1  | 补充 select 函数的参数说明 |

在 socket 编程中，`accept`或者`recv`函数，系统默认使用阻塞调用。如果`recv`未能及时收到回复，或者对端没有发送数据，该线程将一直处在阻塞状态。

这种阻塞可以通过使用多线程来避免，但被阻塞线程该何时释放，多线程之间切换所造成的额外 cpu 资源消耗也成了新的问题。

通过使用非阻塞 I/O，并使用`select`函数处理多个客户端连接相比使用多线程，尤其是在处理大量并发连接时，可以减少系统资源的消耗。

`select` 使用一个文件描述符集合，通过系统调用来检查这个集合中的文件描述符是否准备好进行读、写或有异常。这意味着不需要为每个 socket 连接创建一个线程，从而减少了线程管理和上下文切换的开销。

## 1. I/O 模型

### 1.1. 缓存 I/O

缓存 I/O 又被称作**标准 I/O**，大多数文件系统的默认 I/O 操作都是缓存 I/O。在 Linux 的缓存 I/O 机制中，操作系统会将 I/O 的数据缓存在文件系统的页缓存（ page cache）中，也就是说，数据会先被拷贝到操作系统内核的缓冲区中，然后才会从操作系统内核的缓冲区拷贝到应用程序的地址空间。

缓存 I/O 的缺点在于，数据在传输过程中需要在应用程序地址空间和内核进行多次数据拷贝操作，这些数据拷贝操作所带来的 CPU 以及内存开销是非常大的。

### 1.2. I/O 模型分类

以进程输入(read)为例，一个进程的输入通常包括两个阶段：

- 等待数据准备(Waiting for the data to be ready)
- 将数据从内核空间拷贝到用户空间(Copying the data from the kernel to the process)

如，在 socket 通讯中，第一步为等待数据从网络中到达。当所等待数据到达时，它被复制到内核中的某个缓冲区。第二步就是把数据从内核缓冲区复制到应用进程缓冲区。

因为系统调用后，数据会经过内核缓冲区和应用进程缓冲区两个存储区域，不同的系统调用后的处理方式区分了不同的 I/O 模型。Linux 系统中常被区分为五种 I/O 模型：

- 阻塞式 I/O
- 非阻塞式 I/O
- I/O 复用（select, poll, epoll）
- 信号驱动式 I/O（SIGIO）
- 异步 I/O（AIO）

#### 1.2.1. 阻塞式 I/O

应用进程调用*阻塞式系统调用(blocking system call)*之后被阻塞，直到数据从内核缓冲区复制到应用进程缓冲区中才返回。

调用阻塞式`recvfrom`(blocking receive)，流程如下：

<img src="../assets/Linux%20IO%E6%A8%A1%E5%BC%8F%E5%8F%8A%20select%E3%80%81poll%E3%80%81epoll%E8%AF%A6%E8%A7%A3/1492928416812_4.png" alt="blocking io" />

#### 1.2.2. 非阻塞式 I/O

应用进程调用*非阻塞系统调用(nonblocking system call)*之后，内核返回一个错误码。应用进程可以继续执行，但是需要不断的执行该调用来获知 I/O 是否已经完成，这种方式称为轮询（polling）。

调用非阻塞式`recvfrom`(nonblocking receive)，流程如下：

![nonblocking io](../assets/Linux%20IO%E6%A8%A1%E5%BC%8F%E5%8F%8A%20select%E3%80%81poll%E3%80%81epoll%E8%AF%A6%E8%A7%A3/1492929000361_5.png)

非阻塞 IO 的特点是，用户进程需要不断的主动询问内核，数据是否处于 ready 状态，由于 CPU 需要处理更多的系统调用，因此这种模型的 CPU 利用率比较低。

#### 1.2.3. I/O 复用

使用 `select` 或者 `poll` 等待数据，并且可以等待多个套接字中的任何一个变为可读。这一过程会被阻塞，当某一个套接字可读时返回，之后再使用 `recvfrom` 把数据从内核复制到进程中。

它可以让单个进程具有处理多个 I/O 事件的能力。又被称为 `Event Driven I/O`，即*事件驱动 I/O*。

使用`select`之后的系统调用流程：

![io multiplexing](../assets/Linux%20IO%E6%A8%A1%E5%BC%8F%E5%8F%8A%20select%E3%80%81poll%E3%80%81epoll%E8%AF%A6%E8%A7%A3/1492929444818_6.png)

#### 1.2.4. 信号驱动 I/O

应用进程使用 sigaction 系统调用，内核立即返回，应用进程可以继续执行，也就是说等待数据阶段应用进程是非阻塞的。内核在数据到达时向应用进程发送 SIGIO 信号，应用进程收到之后在信号处理程序中调用 `recvfrom` 将数据从内核复制到应用进程中。

相比于非阻塞式 I/O 的轮询方式，信号驱动 I/O 的 CPU 利用率更高。

![sig io](../assets/Linux%20IO%E6%A8%A1%E5%BC%8F%E5%8F%8A%20select%E3%80%81poll%E3%80%81epoll%E8%AF%A6%E8%A7%A3/1492929553651_7.png)

#### 1.2.5. 异步 I/O (AIO)

应用进程执行`aio_read`系统调用会立即返回，应用进程可以继续执行，不会被阻塞，内核会在**所有操作完成之后**向应用进程发送信号。

异步 I/O 与信号驱动 I/O 的区别在于，异步 I/O 的信号是通知应用进程 I/O 完成，而信号驱动 I/O 的信号是通知应用进程可以开始 I/O。

![aio](../assets/Linux%20IO%E6%A8%A1%E5%BC%8F%E5%8F%8A%20select%E3%80%81poll%E3%80%81epoll%E8%AF%A6%E8%A7%A3/1492930243286_8.png)

## 2. I/O 复用

select，poll，epoll 都是 IO 多路复用的机制。I/O 多路复用就通过一种机制，可以监视多个文件描述符(File Descriptor)，一旦某个描述符就绪（一般是读就绪或者写就绪），能够通知程序进行相应的读写操作。**但 select，poll，epoll 本质上都是同步 I/O，因为他们都需要在读写事件就绪后自己负责进行读写，也就是说这个读写过程是阻塞的**，而异步 I/O 则无需自己负责进行读写，异步 I/O 的实现会负责把数据从内核拷贝到用户空间。

### 2.1. select

`select` 函数的作用是检测一组 socket 中某个或某几个是否有**事件**，这里的**事件**一般分为如下三类：

- 可读事件，一般意味着可以调用 `recv` 或 `read` 函数从该 socket 上读取数据；如果该 socket 是侦听 socket（即调用了 `bind` 函数绑定过 ip 地址和端口号，并调用了 `listen` 启动侦听的 socket），可读意味着此时可以有新的客户端连接到来，此时可调用 `accept` 函数接受新连接。
- 可写事件，一般意味着此时调用 `send` 或 `write` 函数可以将数据发出。
- 异常事件，某个 socket 出现异常。

函数签名如下：

```c
int select(int nfds,
           fd_set *readfds,
           fd_set *writefds,
           fd_set *exceptfds,
           struct timeval *timeout);
```

参数说明：

- 参数 nfds， Linux 下 socket 也称 fd，这个参数的值设置成所有需要使用 select 函数监听的 fd 中最大 fd 值加 1。
- 参数 readfds，需要监听可读事件的 fd 集合。
- 参数 writefds，需要监听可写事件的 fd 集合。
- 参数 exceptfds，需要监听异常事件 fd 集合。
- 参数 timeout，超时时间，即在这个参数设定的时间内检测这些 fd 的事件，超过这个时间后 select 函数将立即返回。如果 timeout 为 `NULL` 指针，select 调用将持续阻塞至 socket 或信息处于就绪状态。若要轮询套接字并立即返回，timeout 应为指向零值的 `timeval` 结构或 `timespec` 结构的非 `NULL` 指针。

成功调用返回结果大于 0，出错返回结果为 -1，超时返回结果为 0。

示例：

```c
fd_set fd_in, fd_out;
struct timeval tv;

// Reset the sets
FD_ZERO( &fd_in );
FD_ZERO( &fd_out );

// Monitor sock1 for input events
FD_SET( sock1, &fd_in );

// Monitor sock2 for output events
FD_SET( sock2, &fd_out );

// Find out which socket has the largest numeric value as select requires it
int largest_sock = sock1 > sock2 ? sock1 : sock2;

// Wait up to 10 seconds
tv.tv_sec = 10;
tv.tv_usec = 0;

// Call the select
int ret = select( largest_sock + 1, &fd_in, &fd_out, NULL, &tv );

// Check if select actually succeed
if ( ret == -1 )
    // report error and abort
else if ( ret == 0 )
    // timeout; no event detected
else
{
    if ( FD_ISSET( sock1, &fd_in ) )
        // input event on sock1

    if ( FD_ISSET( sock2, &fd_out ) )
        // output event on sock2
}
```

当用户进程调用了 select，那么整个进程会被阻塞，而同时，kernel 会监视所有 select 负责的 socket，当任何一个 socket 中的数据准备好了，select 就会返回。这个时候用户进程再调用 read 操作，将数据从 kernel 拷贝到用户进程。

#### 2.1.1. select 的缺点

1. 每次调用 select，都需要把 fd 集合从用户态拷贝到内核态，这个开销在 fd 很多时会很大
2. 同时每次调用 select 都需要在内核遍历传递进来的所有 fd，这个开销在 fd 很多时也很大
3. select 支持的文件描述符数量默认是 1024
4. select 会改变传入的 fd_set

### 2.2. poll

函数签名：

```c
int poll (struct pollfd *fds, unsigned int nfds, int timeout);
```

poll 的功能与 select 类似，也是等待一组描述符中的某一个成为就绪(ready)状态。

poll 中的描述符是 pollfd 类型的数组，pollfd 的定义如下：

```c
struct pollfd {
    int   fd;         /* file descriptor */
    short events;     /* requested events */
    short revents;    /* returned events */
};
```

示例：

```c
// The structure for two events
struct pollfd fds[2];

// Monitor sock1 for input
fds[0].fd = sock1;
fds[0].events = POLLIN;

// Monitor sock2 for output
fds[1].fd = sock2;
fds[1].events = POLLOUT;

// Wait 10 seconds
int ret = poll( &fds, 2, 10000 );
// Check if poll actually succeed
if ( ret == -1 )
    // report error and abort
else if ( ret == 0 )
    // timeout; no event detected
else
{
    // If we detect the event, zero it out so we can reuse the structure
    if ( fds[0].revents & POLLIN )
        fds[0].revents = 0;
        // input event on sock1

    if ( fds[1].revents & POLLOUT )
        fds[1].revents = 0;
        // output event on sock2
}
```

### 2.3. epoll

相关函数：

```c
int epoll_create(int size);
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event)；
int epoll_wait(int epfd, struct epoll_event * events, int maxevents, int timeout);
```

epoll_ctl 用于向内核注册新的描述符或者是改变某个文件描述符的状态。已注册的描述符在内核中会被维护在一棵红黑树上，通过回调函数内核会将 I/O 准备好的描述符加入到一个链表中管理，进程调用 epoll_wait 便可以得到事件完成的描述符。

从上面的描述可以看出，epoll 只需要将描述符从进程缓冲区向内核缓冲区拷贝一次，并且进程不需要通过轮询来获得事件完成的描述符。

epoll 比 select 和 poll 更加灵活而且没有描述符数量限制。

epoll 对多线程编程更有友好，一个线程调用了 epoll_wait 另一个线程关闭了同一个描述符也不会产生像 select 和 poll 的不确定情况。

示例：

```c
// Create the epoll descriptor. Only one is needed per app, and is used to monitor all sockets.
// The function argument is ignored (it was not before, but now it is), so put your favorite number here
int pollingfd = epoll_create( 0xCAFE );

if ( pollingfd < 0 )
 // report error

// Initialize the epoll structure in case more members are added in future
struct epoll_event ev = { 0 };

// Associate the connection class instance with the event. You can associate anything
// you want, epoll does not use this information. We store a connection class pointer, pConnection1
ev.data.ptr = pConnection1;

// Monitor for input, and do not automatically rearm the descriptor after the event
ev.events = EPOLLIN | EPOLLONESHOT;
// Add the descriptor into the monitoring list. We can do it even if another thread is
// waiting in epoll_wait - the descriptor will be properly added
if ( epoll_ctl( epollfd, EPOLL_CTL_ADD, pConnection1->getSocket(), &ev ) != 0 )
    // report error

// Wait for up to 20 events (assuming we have added maybe 200 sockets before that it may happen)
struct epoll_event pevents[ 20 ];

// Wait for 10 seconds, and retrieve less than 20 epoll_event and store them into epoll_event array
int ready = epoll_wait( pollingfd, pevents, 20, 10000 );
// Check if epoll actually succeed
if ( ret == -1 )
    // report error and abort
else if ( ret == 0 )
    // timeout; no event detected
else
{
    // Check if any events detected
    for ( int i = 0; i < ready; i++ )
    {
        if ( pevents[i].events & EPOLLIN )
        {
            // Get back our connection pointer
            Connection * c = (Connection*) pevents[i].data.ptr;
            c->handleReadEvent();
         }
    }
}
```

#### 2.3.1 epoll 工作模式

epoll 的描述符事件有两种触发模式：LT（level trigger）和 ET（edge trigger）。

##### 2.3.1.1. LT 模式

当 `epoll_wait` 检测到描述符事件到达时，将此事件通知进程，进程可以不立即处理该事件，下次调用 `epoll_wait` 会再次通知进程。是默认的一种模式，并且同时支持 Blocking 和 No-Blocking。

##### 2.3.1.2. ET 模式

和 LT 模式不同的是，通知之后进程必须立即处理事件，下次再调用 `epoll_wait` 时不会再得到事件到达的通知。

很大程度上减少了 epoll 事件被重复触发的次数，因此效率要比 LT 模式高。只支持 No-Blocking，以避免由于一个文件句柄的阻塞读/阻塞写操作把处理多个文件描述符的任务饿死

### 2.4. 应用场景

#### 2.4.1 select 应用场景

select 的 timeout 参数精度为微秒，而 poll 和 epoll 为毫秒，因此 select 更加适用于实时性要求比较高的场景。

同时需要处理的描述符量级小于 10^3。

select 可移植性更好，几乎被所有主流平台所支持。

#### 2.4.2 poll 应用场景

poll 没有最大描述符数量的限制，如果平台支持并且对实时性要求不高，应该使用 poll 而不是 select。

#### 2.4.3 epoll 应用场景

只需要运行在 Linux 平台上，有大量的描述符需要同时轮询，并且这些连接最好是长连接。

需要同时监控小于 1000 个描述符，就没有必要使用 epoll，因为这个应用场景下并不能体现 epoll 的优势。

需要监控的描述符状态变化多，而且都是非常短暂的，也没有必要使用 epoll。因为 epoll 中的所有描述符都存储在内核中，造成每次需要对描述符的状态改变都需要通过 epoll_ctl 进行系统调用，频繁系统调用降低效率。并且 epoll 的描述符存储在内核，不容易调试。

## 3. Reference

1. [select 实现分析](http://www.cnblogs.com/apprentice89/archive/2013/05/09/3070051.html)
2. [select、poll、epoll 使用小结](http://blog.csdn.net/kkxgx/article/details/7717125)
3. [怎样理解阻塞非阻塞与同步异步的区别？](https://www.zhihu.com/question/19732473)
4. [select 函数重难点解析](https://github.com/balloonwj/CppGuide/blob/master/articles/%E7%BD%91%E7%BB%9C%E7%BC%96%E7%A8%8B/select%E5%87%BD%E6%95%B0%E9%87%8D%E9%9A%BE%E7%82%B9%E8%A7%A3%E6%9E%90.md)

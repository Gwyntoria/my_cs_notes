# Socket

## 概述

Socket（套接字）是计算机网络编程中的一种抽象概念，它提供了一种通信机制，使得计算机程序能够通过网络进行数据交换。在应用层，Socket是一个应用程序和网络之间的接口，用于建立网络连接、传输数据和关闭连接。

Socket可以看作是一种端点，它包含了网络连接的相关信息，如IP地址、端口号、协议等，可以用来识别一个网络连接。通过Socket，可以在不同计算机之间建立连接，进行双向的数据传输。在网络编程中，Socket**通常使用TCP或UDP协议实现数据传输**。

Socket（套接字）是用于在计算机网络中进行进程间通信的一种机制。通常，Socket由一个端点（端口）和一个地址（IP地址）组成，它允许应用程序通过网络发送和接收数据。

## 服务器端和客户端

在一个基于Socket的通信系统中，有两种主要的角色：**服务器端**和**客户端**。

服务器端（Socket Server）是**在网络上等待连接请求并处理连接请求的进程**。服务器端通常运行在固定的计算机上，它可以提供一些服务（如Web服务、FTP服务等）给远程的客户端。

客户端（Socket Client）是**发起连接请求的进程**。它向指定的服务器端发送连接请求，并等待服务器端的响应。一旦连接建立成功，客户端和服务器端之间就可以进行数据交换。

因此，Socket服务器端和客户端的区别在于它们的角色和职责。服务器端负责等待连接请求并提供服务，而客户端负责向服务器端发送连接请求并接收服务器端提供的服务。

## SOCKET 编程原理

在实际应用中，Socket通常使用TCP或UDP协议实现数据传输。

### 基本原理

套接口有三种类型：**流式套接口**，**数据报套接口**及**原始套接口**

- 流式套接口定义了一种可靠的面向连接的服务，实现了无差错无重复的顺序数据传输。
- 数据报套接口定义了一种无连接的服务，数据通过相互独立的报文进行传输，是无序的，并且不保证可靠，无差错。
- 原始套接口允许对低层协议如IP或ICMP直接访问，主要用于新的网络协议实现的测试等。

### 基本流程

1. 建立连接：
   在Socket通信中，要进行数据传输，需要先建立连接。对于TCP协议来说，连接是一个可靠的双向通信链路，使用三次握手协议建立连接。对于UDP协议来说，连接是一次简单的单向通信，不需要建立连接。
2. 数据传输：
   建立连接后，就可以进行数据传输。对于TCP协议，数据传输是可靠的，数据在传输过程中会进行拆分和重组，以保证数据的完整性和可靠性。对于UDP协议，数据传输是不可靠的，数据包可能会在传输过程中丢失或重复。
3. 关闭连接：
   数据传输完成后，需要关闭连接以释放资源。对于TCP协议，需要使用四次挥手协议来关闭连接，保证数据传输的可靠性。对于UDP协议，不需要显式地关闭连接，因为它是一次简单的单向通信。

Socket编程的基本原理就是通过Socket API来进行网络通信，实现客户端和服务器之间的数据交换。在编程中，我们需要使用Socket API提供的函数和结构体，建立Socket连接、发送和接收数据，并在完成数据传输后关闭连接。通过Socket编程，我们可以实现各种网络应用程序，如网页浏览器、邮件客户端、文件传输工具等。

## 相关接口、结构、宏定义

### API

#### 1. `socket()` 函数：创建一个新的套接字

```c
int socket(int domain, int type, int protocol);
```

- `domain`: 指定协议族，如AF_INET表示IPv4协议族。
- `type`: 指定套接字类型，如`SOCK_STREAM`表示面向连接的TCP套接字。
- `protocol`: 指定协议类型，一般为0，表示自动选择协议。

#### 2. bind() 函数：将套接字绑定到指定的IP地址和端口号

```c
int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

- `sockfd`: 套接字描述符。
- `addr`: 指向包含IP地址和端口号的`sockaddr`结构体指针。
- `addrlen`: `addr`结构体的长度。

#### 3. `listen()` 函数：监听套接字上的连接请求

```c
int listen(int sockfd, int backlog);
```

- `sockfd`: 套接字描述符。
- `backlog`: 等待连接队列的最大长度。

#### 4. `accept()` 函数：接受客户端的连接请求

```c
int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
```

- `sockfd`: 套接字描述符。
- `addr`: 保存客户端地址信息的`sockaddr`结构体指针。
- `addrlen`: `addr`结构体的长度。

#### 5. `connect()` 函数：发起TCP连接

```c
int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

- `sockfd`: 套接字描述符。
- `addr`: 指向目标IP地址和端口号的`sockaddr`结构体指针。
- `addrlen`: `addr`结构体的长度。

#### 6. `send()` 函数：发送数据

```c
ssize_t send(int sockfd, const void *buf, size_t len, int flags);
```

- `sockfd`: 套接字描述符。
- `buf`: 发送数据的缓冲区指针。
- `len`: 发送数据的长度。
- `flags`: 操作标志。

#### 7. `recv()` 函数：接收数据

```c
ssize_t recv(int sockfd, void *buf, size_t len, int flags);
```

- `sockfd`: 套接字描述符。
- `buf`: 接收数据的缓冲区指针。
- `len`: 接收数据的长度。
- `flags`: 操作标志。

#### 8. `close()` 函数：关闭套接字

```c
int close(int sockfd);
```

- `sockfd`: 套接字描述符

**NOTES:** 在使用socket进行通信时，常用的函数包括`recv`和`send`，以及`read`和`write`。它们都可以**用于读写套接字(socket)**。它们的主要区别如下：

1. `recv`和`send`是**socket库函数**，而`read`和`write`是**标准C库函数**。虽然`recv`和`send`可以在Windows和Linux等平台上使用，但`read`和`write`是标准C库函数，可以在几乎所有支持C语言的平台上使用。
2. `recv`和`send`可以指定更多的选项，例如指定接收和发送的数据的长度，以及标志参数来控制函数的行为。相比之下，`read`和`write`的选项比较有限。
3. `recv`和`send`是面向连接的，适用于基于TCP的socket通信，因为TCP是面向连接的协议。而`read`和`write`是面向文件描述符的，适用于基于UDP的socket通信，因为UDP是无连接的协议。

综上所述，`recv`和`send`**更适合用于TCP连接**，而`read`和`write`**更适合用于UDP连接**。但是在实际开发中，为了兼容性和可移植性，也可以使用`recv`和`send`来进行UDP通信。

### struct

- `sockaddr`：用于存储网络地址和端口号信息。
- `sockaddr_in`：用于IPv4协议的套接字地址结构体，包括IP地址和端口号。
- `sockaddr_in6`：用于IPv6协议的套接字地址结构体，包括IP地址和端口号。

### macro

## 代码及解释

```c
#include <netinet/in.h>
#include <sys/socket.h>

// 创建 和 绑定
int sockfd = socket(AF_INET, SOCK_STREAM, 0); // 创建套接字
struct sockaddr_in addr;
memset(&addr, 0, sizeof(addr));
addr.sin_family = AF_INET;
addr.sin_port = htons(port); // 设置端口号
addr.sin_addr.s_addr = htonl(INADDR_ANY); // 绑定任意本地IP地址
int ret = bind(sockfd, (struct sockaddr*)&addr, sizeof(addr)); // 绑定套接字
```

`AF_INET`是一个常用的地址族（address family）常量，它在网络编程中用于指定套接字（socket）的地址类型，表示使用IPv4地址族。AF_INET是"Address Family - Internet"的缩写，表示Internet地址族，是TCP/IP协议族中的一部分。

`socket()`的第一个参数指定了地址族为`AF_INET`，第二个参数指定了套接字类型为`SOCK_STREAM`（流式套接字），第三个参数为0表示使用默认协议

在网络编程中，如果需要使用IPv6地址族，需要使用`AF_INET6`常量来指定地址族，同时使用`sockaddr_in6`结构体来定义IPv6地址和端口号的组合。

`sockaddr_in6`结构体定义如下：

```c
struct sockaddr_in6 {
    sa_family_t     sin6_family;   // 地址族，一般为AF_INET6
    in_port_t       sin6_port;     // 端口号，网络字节序
    uint32_t        sin6_flowinfo; // 流信息（Flow Information）
    struct in6_addr sin6_addr;     // IPv6地址
    uint32_t        sin6_scope_id; // 作用域标识（Scope ID）
};
```

其中，`sin6_family`、`sin6_port`和`sin6_addr`分别用于存储IPv6地址族、端口号和IPv6地址信息。

IPv6地址为128位，使用`in6_addr`结构体来表示，其定义如下：

```c
struct in6_addr {
    uint8_t s6_addr[16]; // IPv6地址，16字节
};
```

`AF_INET6`常量指定地址族为IPv6，使用`sockaddr_in6`结构体来定义IPv6地址和端口号的组合，其中IPv6地址可以通过`inet_pton()`函数将字符串转换为`in6_addr`类型。

```c
int sockfd = socket(AF_INET6, SOCK_STREAM, 0); // 创建IPv6套接字
struct sockaddr_in6 addr;
memset(&addr, 0, sizeof(addr));
addr.sin6_family = AF_INET6;
addr.sin6_port = htons(port); // 设置端口号，网络字节序
// 设置IPv6地址
struct in6_addr ipv6_addr;
inet_pton(AF_INET6, "2001:db8::1", &ipv6_addr);
addr.sin6_addr = ipv6_addr;
int ret = bind(sockfd, (struct sockaddr*)&addr, sizeof(addr)); // 绑定套接字
```

## Sample

### 1. 实现socket服务端

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 8080
#define BUFFER_SIZE 1024

int main() {
    int server_fd, new_socket, valread;
    struct sockaddr_in address;
    int opt = 1;
    int addrlen = sizeof(address);
    char buffer[BUFFER_SIZE] = {0};
    char *hello = "Hello from server";

    // 创建套接字
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    // 设置套接字选项
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))) {
        perror("setsockopt failed");
        exit(EXIT_FAILURE);
    }

    // 绑定地址和端口
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    // 监听连接
    if (listen(server_fd, 3) < 0) {
        perror("listen failed");
        exit(EXIT_FAILURE);
    }

    // 接受连接
    if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t *)&addrlen)) < 0) {
        perror("accept failed");
        exit(EXIT_FAILURE);
    }

    // 接收数据
    valread = recv(new_socket, buffer, BUFFER_SIZE);
    printf("%s\n", buffer);

    // 发送数据
    send(new_socket, hello, strlen(hello), 0);
    printf("Hello message sent\n");

    // 关闭套接字
    close(new_socket);
    close(server_fd);

    return 0;
}
```

### 2. 实现socket客户端

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#define PORT 8080
#define BUFFER_SIZE 1024

int main() {
    int sock = 0, valread;
    struct sockaddr_in serv_addr;
    char buffer[BUFFER_SIZE] = {0};
    char *hello = "Hello from client";

    // 创建套接字
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("\n Socket creation error \n");
        return -1;
    }

    // 配置服务器地址和端口
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);
    
    // 将IPv4地址从点分十进制转换为网络字节序
    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
        printf("\nInvalid address/ Address not supported \n");
        return -1;
    }

    // 连接服务器
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        printf("\nConnection Failed \n");
        return -1;
    }

    // 发送数据
    send(sock, hello, strlen(hello), 0);
    printf("Hello message sent\n");

    // 接收数据
    valread = recv(sock, buffer, BUFFER_SIZE);
    printf("%s\n", buffer);

    // 关闭套接字
    close(sock);

    return 0;
}
```

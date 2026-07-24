# TCP 窗口、MSS 与 Socket 缓冲区调优

TCP 性能调优里最容易混淆的三个量是接收窗口、拥塞窗口和 Socket 缓冲区。它们都以字节计量，也都会影响吞吐量，但处在不同位置：接收窗口保护接收端，拥塞窗口保护网络，Socket 缓冲区连接应用程序与内核。MSS 解决的是另一件事，它决定一段 TCP 数据如何切成适合路径传输的报文段。

这几个量没有脱离场景的最优值。可以用带宽时延积算出窗口和缓冲区的容量下限，再根据丢包、并发连接数、内存、排队延迟和应用读写行为做实验。

## 一条发送链路里有哪些限制

发送端应用写入 Socket 后，数据先进入发送缓冲区。TCP 按 MSS 分段，并受接收端通告窗口和本地拥塞窗口共同约束。数据到达对端后进入接收缓冲区，等待应用读取。

```text
发送应用
   ↓ write()/send()
发送缓冲区（SO_SNDBUF）
   ↓ TCP 可以保持多少未确认数据
min(cwnd, rwnd)
   ↓ 每个报文段装多少 TCP 数据
MSS / PMTU
   ↓
网络路径
   ↓
接收缓冲区（SO_RCVBUF）
   ↓ read()/recv()
接收应用
```

| 量 | 由谁控制 | 保护对象 | 直接回答的问题 |
| --- | --- | --- | --- |
| `rwnd`，接收窗口 | 接收端 TCP | 接收端缓冲区 | 对端还能发多少未确认数据 |
| `cwnd`，拥塞窗口 | 发送端拥塞控制算法 | 网络路径 | 当前网络允许多少数据在途 |
| `SO_RCVBUF` | 操作系统或应用 | 接收端内存 | 内核能为收到但未读取的数据留多少空间 |
| `SO_SNDBUF` | 操作系统或应用 | 发送端内存 | 内核能容纳多少待发送、已发送未确认的数据 |
| MSS | 双方在握手时通告，发送端结合路径调整 | IP 分片边界 | 一个 TCP 报文段最多承载多少数据 |
| MTU / PMTU | 链路与整条路径 | IP 包边界 | 一个 IP 包最多有多大 |

[RFC 5681](https://www.rfc-editor.org/rfc/rfc5681.html) 给出的基本约束是：未确认数据不能超过 `min(cwnd, rwnd)`。因此，单连接的窗口受限吞吐量近似满足：

$$
\text{Throughput}
\leq
\frac{\min(\text{cwnd},\text{rwnd})}{\text{RTT}}
$$

这个式子给出上界，不是吞吐预测器。发送缓冲区不足、应用写入太慢、接收应用读取太慢、丢包、重传、CPU、磁盘或限速器都可能让实际值更低。

## TCP window size 到底指什么

“TCP window size”在不同资料里可能指 `rwnd`、`cwnd`，也可能笼统地指可用在途数据量。调优前要确认上下文。

### 接收窗口 rwnd 用于流量控制

接收端通过 TCP 首部的 Window 字段告诉发送端，当前还能接收多少字节。应用读取慢、接收缓冲区逐渐占满时，`rwnd` 会缩小；缓冲区没有空间时可以变为零，发送端暂停发送并定期探测窗口。接收应用读走数据后，接收端再通告更大的窗口。

`rwnd` 与 `SO_RCVBUF` 关系紧密，但不完全相等。内核还要为报文元数据、乱序数据和内部结构留空间，实际通告窗口也受 TCP 实现的内存核算与窗口策略影响。Linux 中 `getsockopt(SO_RCVBUF)` 返回的数值还包含内核加倍计算的管理开销，不能直接当作抓包里看到的 `rwnd`。

### 拥塞窗口 cwnd 用于拥塞控制

`cwnd` 是发送端维护的动态状态。它根据确认、丢包、显式拥塞通知和所选拥塞控制算法变化。接收端不能通过增大 `SO_RCVBUF` 强迫发送端扩大 `cwnd`。

高带宽、高 RTT 路径需要很大的在途数据量。经典 Reno 在大带宽时延积链路上增长较慢，CUBIC 为这类路径采用不同的窗口增长函数。Linux 可以全局或按 Socket 选择拥塞控制算法，但算法选择应通过真实路径测试，不能只看名字。算法原理和适用边界可参考 [RFC 9438](https://www.rfc-editor.org/rfc/rfc9438.html)。

### Window Scale 让 rwnd 超过 65,535 字节

TCP 首部的 Window 字段只有 16 位，不扩展时最大值为 65,535。Window Scale 选项用一个左移位数扩展它：

$$
\text{实际接收窗口}
=
\text{Window 字段值}
\times
2^s
$$

其中 `s` 的范围是 0 到 14，最大可表达窗口约为 1 GiB。Window Scale 只在 SYN 中协商，每个方向各有自己的缩放因子，而且双方都要在握手中发送该选项才会启用。SYN 本身的 Window 字段不缩放。

若连接需要接收窗口 `W`，表达该窗口所需的最小缩放位数可以估算为：

$$
s
=
\left\lceil
\log_2\left(\frac{W}{65{,}535}\right)
\right\rceil
$$

结果小于 0 时取 0，大于 14 时说明单个 TCP 接收窗口已经超出 Window Scale 能表达的范围。现代操作系统通常按最大接收缓冲空间自动选择缩放因子。若应用要手动设置 `SO_RCVBUF`，应在 `connect()` 或 `listen()` 之前完成，否则握手时已经选定的缩放因子可能限制后续窗口。具体协商规则见 [RFC 7323](https://www.rfc-editor.org/rfc/rfc7323.html)。

## MSS 调整的是分段大小

最大报文段长度的英文是 Maximum Segment Size，简称 MSS。它只计算 TCP 数据，不包含 IP 首部和 TCP 首部。一端在 SYN 中通告的 MSS 表示“我最多愿意接收这么大的 TCP 数据段”，因此 A 通告的 MSS 限制 B 向 A 发送的报文段，不直接限制 A 自己的发送方向。

### MSS、MTU 与 PMTU 的关系

MTU 是单条链路可承载的最大 IP 包大小。路径 MTU 的英文是 Path MTU，简称 PMTU，它是整条路径所有链路 MTU 的最小值。没有隧道和额外选项时，可以用下式理解常见值：

$$
\text{MSS}
=
\text{MTU}
-
\text{固定 IP 首部}
-
\text{固定 TCP 首部}
$$

| 场景 | MTU | 固定 IP 首部 | 固定 TCP 首部 | 通常通告的 MSS |
| --- | ---: | ---: | ---: | ---: |
| IPv4 over Ethernet | 1500 | 20 | 20 | 1460 |
| IPv6 over Ethernet | 1500 | 40 | 20 | 1440 |

[RFC 6691](https://www.rfc-editor.org/rfc/rfc6691.html) 明确区分了“通告的 MSS”和“实际发送时的数据长度”。计算通告值时只扣固定 IP、TCP 首部，不预扣可变选项；发送端为某个包加入 TCP Timestamp 等选项时，再从该包的数据长度中扣除相应字节。IPv4、MTU 1500、通告 MSS 1460 的连接若每个数据包带 12 字节的 TCP Timestamp 与填充，实际常见数据长度是 1448 字节。

TCP 最终使用的有效发送 MSS 还要同时满足对端通告值和本地已知的路径限制。简化后可写成：

$$
\text{effective send MSS}
=
\min \{\text{peer MSS},\text{PMTU}-\text{本包全部首部}\}
$$

### MSS 变大或变小会发生什么

较大的 MSS 可以让相同数据使用更少的包，降低首部比例、每包处理开销和中断压力。它只有在整条路径支持相应 PMTU 时才有收益。大包超过 PMTU 后会被分片或丢弃，任一分片丢失都使整个 IP 数据报失效，性能可能明显下降。

较小的 MSS 能避开隧道、VPN、PPPoE 或错误防火墙造成的 PMTU 问题，但会增加包数、首部开销和 CPU 开销。MSS 还以“段”为单位影响初始拥塞窗口等算法的字节数，[RFC 6928](https://www.rfc-editor.org/rfc/rfc6928.html) 定义的现代初始窗口上限就是 `min(10 × MSS, max(2 × MSS, 14600))`。

通常不应把 `TCP_MAXSEG` 当作通用吞吐旋钮。操作系统的 PMTU Discovery 和 Packetization Layer PMTU Discovery，简称 PLPMTUD，更适合发现路径能承载的大小。传统 PMTU Discovery 依赖 ICMP“包太大”反馈，错误地屏蔽 ICMP 会产生 PMTU black hole：握手和小请求正常，大块传输开始后停滞。[RFC 2923](https://www.rfc-editor.org/rfc/rfc2923.html) 记录了这种现象，[RFC 4821](https://www.rfc-editor.org/rfc/rfc4821.html) 则给出不完全依赖 ICMP 的 TCP 探测方法。

手动降低 MSS 适合三个场景：已确认的 PMTU black hole 临时绕过；边界网关对经过隧道的 TCP SYN 做 MSS clamping；受控实验比较分段开销。长期方案应修复 PMTU、ICMP 或隧道配置。

## Socket buffer size 决定应用与 TCP 之间的容量

### 接收缓冲区太小

接收缓冲区容不下一个带宽时延积时，`rwnd` 可能限制发送端，链路尚有空闲带宽也无法继续发送。接收应用若处理不及时，也会占满缓冲区并产生零窗口。

接收缓冲区变大可以容纳更多在途和乱序数据，但不会修复慢消费程序。过大的缓冲区还会增加每连接内存上限，并可能让数据在应用看不到的位置排队更久。

### 发送缓冲区太小

发送端要同时容纳等待发送、已经交给网络但尚未确认的数据及相关开销。缓冲区太小或应用每次只写一点并频繁停顿时，TCP 无法持续填满窗口。非阻塞程序还会更早遇到 `EAGAIN` 或失去 `POLLOUT` 可写事件。

发送缓冲区很大也不等于在途数据会无限增加，`cwnd` 和 `rwnd` 仍会限制实际发送。它可能让应用提前排入很多尚未发送的数据，增加取消、切换请求或处理优先级时的延迟。Linux 的 `TCP_NOTSENT_LOWAT` 可以限制发送队列中尚未交给网络的数据量。

### Linux 自动调优与手动设置

Linux 默认启用 `tcp_moderate_rcvbuf`，按连接观察路径并自动扩大接收缓冲区，上限来自 `tcp_rmem[2]`。`tcp_wmem` 对发送缓冲区提供最小值、初始值和自动调优上限。Window Scale 默认也启用。实际默认值随内核版本和机器内存变化，应读取当前系统，不要照抄别人的数值。

```bash
sysctl net.ipv4.tcp_window_scaling
sysctl net.ipv4.tcp_moderate_rcvbuf
sysctl net.ipv4.tcp_rmem
sysctl net.ipv4.tcp_wmem
sysctl net.core.rmem_max
sysctl net.core.wmem_max
```

应用调用 `setsockopt(SO_RCVBUF)` 或 `setsockopt(SO_SNDBUF)` 后，会关闭对应 Socket 的自动调优。Linux 还会把应用请求的值加倍，为内核管理结构留空间，`getsockopt()` 返回的是加倍后的值。手动值受 `net.core.rmem_max` 或 `net.core.wmem_max` 限制。设置成功不代表 TCP 会把全部空间通告为接收窗口，也不代表这些内存立即全部分配。

默认策略可以归纳为：保留自动调优，只在观测到上限不足时提高全局上限；只有应用明确知道每条连接的路径和内存预算时，才固定单个 Socket 的缓冲区。固定值应在 `connect()` 或 `listen()` 前设置，并用 `getsockopt()`、`ss` 和抓包验证实际结果。Linux 的具体语义见 [IP sysctl 文档](https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html)、[`tcp(7)`](https://man7.org/linux/man-pages/man7/tcp.7.html) 和 [`socket(7)`](https://man7.org/linux/man-pages/man7/socket.7.html)。

## 用 BDP 计算容量下限

带宽时延积的英文是 Bandwidth-Delay Product，简称 BDP。它表示为了让链路持续繁忙，需要同时留在路径上的数据量：

$$
\text{BDP}_{bits}
=
\text{bottleneck bandwidth}_{bit/s}
\times
\text{RTT}_{s}
$$

$$
\text{BDP}_{bytes}
=
\frac{\text{bandwidth}_{bit/s}\times\text{RTT}_{s}}{8}
$$

窗口受限时，反过来也能估算单连接吞吐上限：

$$
\text{Throughput}_{bit/s}
\lesssim
\frac{\text{usable window}_{bytes}\times 8}{\text{RTT}_{s}}
$$

[RFC 6349](https://www.rfc-editor.org/rfc/rfc6349.html) 建议发送、接收 Socket 缓冲区至少能容纳完整 BDP，并留出实现开销。这个值是容量起点，不是最优值公式，原因包括：

- 可用带宽和 RTT 会随时间变化，拥塞后的 RTT 还包含排队延迟；
- `cwnd` 可能小于 BDP，增大 `rwnd` 和缓冲区不会绕过拥塞控制；
- 丢包会触发恢复或缩小 `cwnd`，不同拥塞控制算法的行为不同；
- 内核缓冲区需要保存元数据、乱序数据和未确认数据；
- 高并发服务要在单连接吞吐与总内存之间取舍；
- 交互业务更在意尾延迟，大缓冲区可能让旧数据排队。

工程上可以从“略高于一个 BDP、且不超过内存预算”的上限开始测试。若带宽或 RTT 波动很大，可以为观测到的高分位 BDP 留余量。最终值以单流吞吐、重传、RTT 增幅、零窗口、应用延迟和内存占用的共同结果为准。

### 算例：1 Gbit/s、RTT 80 ms

链路的 BDP 为：

$$
1{,}000{,}000{,}000
\times
0.08
\div
8
=
10{,}000{,}000\ \text{bytes}
\approx
9.54\ \text{MiB}
$$

单条 TCP 连接想接近 1 Gbit/s，发送端要能保持约 10 MB 未确认数据，接收端也要通告同等级别的窗口。可以把 16 MiB 作为第一轮测试上限，再根据测量结果调整。它不是所有 1 Gbit/s 链路的固定答案。

表达 10,000,000 字节接收窗口至少需要：

$$
s
=
\left\lceil
\log_2\left(\frac{10{,}000{,}000}{65{,}535}\right)
\right\rceil
=
8
$$

缩放因子 `2^8 = 256` 时，16 位 Window 字段最多表示 16,776,960 字节。不启用 Window Scale 时，这条链路的窗口上限只能支撑约：

$$
65{,}535
\div
0.08
\times
8
\approx
6.55\ \text{Mbit/s}
$$

若 IPv4 路径 MTU 为 1500，并使用 12 字节 TCP Timestamp 与填充，实际满载数据段常为 1448 字节。填满一个 BDP 大约需要：

$$
\left\lceil
\frac{10{,}000{,}000}{1448}
\right\rceil
=
6907\ \text{segments}
$$

这个数量说明窗口、拥塞控制和丢包恢复为什么会共同影响高 BDP 单流。它不意味着应用应该把一次 `write()` 切成 1448 字节，TCP、分段卸载和网卡会负责分段。

### 高并发时还要算内存预算

若有 `N` 条活跃连接，可以用下面的上界检查配置是否现实：

$$
\text{memory upper bound}
\approx
N
\times
(\text{send buffer cap}+\text{receive buffer cap})
$$

20,000 条连接若都允许 16 MiB 发送和 16 MiB 接收，上界达到 640,000 MiB，远超普通服务器内存。自动调优不会立刻为每条连接分配上限，但这个算例说明了为什么不能把全局默认值盲目设得很大。长连接数量、同时活跃比例和内存压力必须一起压测。

## Linux 上如何调优并验证

### 明确目标和测试方向

批量传输关注单流吞吐与 CPU 效率，RPC 和游戏关注尾延迟，大量长连接关注内存与调度开销。上下行不对称时要分别计算 BDP。下载方向主要检查服务端发送缓冲区、服务端 `cwnd`、客户端接收缓冲区和客户端 `rwnd`；上传方向相反。

### 建立路径基线

```bash
# 路由和接口 MTU
ip route get 203.0.113.10
ip link show

# 探测路径 MTU；不同系统的 tracepath 参数可能不同
tracepath 203.0.113.10

# 空闲时和负载时分别测 RTT
ping -c 20 203.0.113.10

# 单流测试，先不要用并行流掩盖单连接问题
iperf3 -c 203.0.113.10 -P 1 -t 30
```

RTT 应以业务路径为准，最好同时记录空闲基线和压测时的高分位值。带宽采用整条路径的瓶颈带宽，不是本机网卡标称速率。

### 查看握手和连接实时状态

```bash
# 查看窗口缩放、MSS、RTT、cwnd、重传和 Socket 内存
ss -tinm dst 203.0.113.10

# 查看 SYN 中的 MSS、Window Scale、SACK 与 Timestamp 选项
tcpdump -ni any 'tcp[tcpflags] & tcp-syn != 0'

# 查看 TCP 重传等累计计数
nstat -az TcpRetransSegs TcpExtTCPTimeouts
```

`ss -ti` 常见字段包括 `rtt`、`mss`、`cwnd`、`wscale`、`bytes_acked`、`bytes_received`、`delivery_rate` 和 `app_limited`，具体字段随内核版本变化。应用也可以读取 Linux `TCP_INFO`，把每条连接的 RTT、MSS、`cwnd`、未确认段数和重传暴露到监控系统。

在发送主机上抓包可能看到大于 MTU 的“TCP 包”，这常由 TSO、GSO 等卸载造成。内核把大块数据交给网卡后，网卡才切成线上报文。需要确认线上的 MSS 时，在接收端或中间点抓包，或者只在隔离实验中临时关闭卸载，不要因此直接修改 MSS。

### 判断谁在限制吞吐

| 观测 | 更可能的限制 | 下一步 |
| --- | --- | --- |
| `rwnd` 小、零窗口或接收队列持续满 | 接收缓冲区或接收应用 | 检查读取速度，再检查接收自动调优上限 |
| `cwnd` 小且有重传、ECN 或 RTT 上升 | 拥塞、丢包或排队 | 修复路径，比较拥塞控制与队列策略 |
| `cwnd`、`rwnd` 都有余量，但连接 `app_limited` | 应用、磁盘、CPU 或发送节奏 | 优化生产数据和写入流程 |
| 大块传输停滞，小请求正常 | PMTU black hole | 检查 ICMP、隧道 MTU、PLPMTUD 与 MSS clamping |
| 多并行流能跑满，单流跑不满 | 单流窗口、拥塞控制或丢包恢复 | 按 BDP 检查单连接状态 |
| 吞吐提高但 RTT 和尾延迟明显上升 | 队列过深或缓冲膨胀 | 检查主机与网络队列，不再继续增大缓冲区 |

### 只提高确认不足的上限

假设测得 BDP 接近 10 MB，而当前自动调优上限只有 4 MB，可以把 16 MiB 作为实验值。先记录现有三个值，只改变最大值，保留系统原有的最小值和初始值。下面命令只展示参数关系，不应直接复制到生产环境：

```bash
# 示例：临时修改，重启后通常失效
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
sysctl -w 'net.ipv4.tcp_rmem=4096 131072 16777216'
sysctl -w 'net.ipv4.tcp_wmem=4096 16384 16777216'
```

`tcp_rmem` 和 `tcp_wmem` 的三个值依次是最小值、初始值、自动调优最大值。Linux 文档指出 `tcp_wmem[2]` 不会覆盖 `net.core.wmem_max`；应用手动设置缓冲区时也受 `net.core.*mem_max` 限制。修改后要重新建立连接，因为旧连接的 Window Scale 已经在握手时确定。

每轮只改一组参数，重复相同的单流测试，同时记录吞吐、RTT、重传、`cwnd`、`rwnd`、Socket 内存、CPU 和业务尾延迟。达到目标后再做高并发与双向压测。收益不稳定、延迟恶化或内存超预算时回退。

## 网络编程还要考虑哪些参数

### 小消息延迟与批量发送

| 选项或机制 | 作用 | 适用场景 | 风险 |
| --- | --- | --- | --- |
| `TCP_NODELAY` | 关闭 Nagle，尽快发送小块数据 | 交互 RPC、请求响应、游戏指令 | 小包数量和协议开销上升 |
| `TCP_CORK` | 暂存不完整帧，解除后集中发送 | 先写首部再 `sendfile()`，Linux 批量输出 | 忘记解除会增加延迟，不可移植 |
| `MSG_MORE` | 告诉内核后面还有数据 | 一次消息由多次 `send()` 组成 | 错误使用会延迟发送 |
| `TCP_NOTSENT_LOWAT` | 限制发送队列中尚未发送的数据 | 非阻塞流式发送、降低应用排队延迟 | 太小会增加唤醒和系统调用 |
| `SO_RCVLOWAT` | 达到一定接收字节数才报告可读 | 固定帧或批量读取 | 可能增加小消息等待时间 |

`TCP_NODELAY` 与 `TCP_CORK` 解决相反方向的问题。协议若把一个逻辑消息拆成多次小写入，可以先用 `writev()` 或一次 `sendmsg()` 合并，再决定是否需要 Socket 选项。

### 连接存活与失败检测

| 参数 | 作用 | 调优依据 |
| --- | --- | --- |
| `SO_KEEPALIVE`、`TCP_KEEPIDLE`、`TCP_KEEPINTVL`、`TCP_KEEPCNT` | 探测长期空闲连接是否仍存活 | NAT 超时、故障发现时限、额外探测流量 |
| `TCP_USER_TIMEOUT` | 数据长期未确认或因零窗口无法发送时，连接最多保留多久 | 业务可接受的故障恢复时间 |
| `SO_RCVTIMEO`、`SO_SNDTIMEO` | 限制阻塞 Socket API 等待时间 | API 调用预算，不等于整个请求的端到端截止时间 |
| 应用层 deadline | 覆盖 DNS、连接、重试、读写和业务处理 | 业务 SLO，通常比单个 Socket 超时更完整 |

TCP keepalive 只在连接空闲时工作，不能代替应用心跳和请求 deadline。Linux 中 `TCP_USER_TIMEOUT` 会影响持续无确认时的连接关闭判断，但不会改变重传时刻。

### 服务端连接队列与负载分配

`listen(backlog)`、`net.core.somaxconn` 和 `net.ipv4.tcp_max_syn_backlog` 会影响突发建连能力。队列溢出时，应同时检查应用 `accept()` 速度、事件循环阻塞、文件描述符上限和 CPU，而不是只增大 backlog。Linux 文档警告不要把 `tcp_abort_on_overflow` 当作常规修复，它可能直接伤害客户端。

`SO_REUSEPORT` 可以让多个监听 Socket 分担同一地址的连接，适合多进程或每核事件循环。它是否均衡还取决于哈希、连接分布和程序架构。RSS、RPS、RFS、XPS 和中断亲和性负责把收发处理分配到 CPU，只有在确认单核软中断或队列成为限制后再调，参考 [Linux 网络扩展文档](https://www.kernel.org/doc/html/latest/networking/scaling.html)。

大量主动建连的客户端还会受到本地临时端口范围、四元组数量和 `TIME_WAIT` 状态限制。连接池、长连接和多源地址可以减少端口压力。`SO_REUSEADDR` 主要处理地址绑定与服务重启语义，不是提高吞吐的选项；缩短 `TIME_WAIT`、扩大临时端口范围或启用复用前，应先确认是端口耗尽，而不是连接泄漏或不必要的短连接。

### 拥塞控制、队列与 CPU 延迟

`TCP_CONGESTION` 可以按 Socket 选择内核允许的拥塞控制算法。算法要与路径、队列规则和业务目标一起测试。只更换算法不能修复随机丢包、过载接收端或错误限速。

`SO_BUSY_POLL` 用 CPU 忙轮询换取较低接收延迟，适合对微秒级延迟敏感并且有独占 CPU 预算的场景。Linux man page 明确提示它会增加 CPU 和功耗。普通服务应先优化事件循环、批处理、IRQ 与队列分布。

服务质量字段如 DSCP、IP_TOS 或 IPv6 Traffic Class 只有在整条网络都配置了相应策略时才有效，错误标记还可能被清除或限速。ECN 需要端点和路径共同支持。

### UDP 需要应用自己承担更多责任

UDP 没有 TCP 的流量控制、可靠传输和拥塞控制。应用需要明确处理消息边界、丢失、重复、乱序、重传、速率控制和接收缓冲区溢出。UDP 数据报不应超过 PMTU，否则分片丢失会使整个数据报失效；如果底层没有提供 PMTU 探测，应用层需要实现探测和确认机制。[RFC 8085](https://www.rfc-editor.org/rfc/rfc8085.html) 给出了 UDP 应用的完整约束，[RFC 8899](https://www.rfc-editor.org/rfc/rfc8899.html) 定义了数据报传输的 DPLPMTUD。

UDP 的 `SO_RCVBUF` 对突发流量尤其重要，但扩大它只能吸收短时突发，不能修复长期消费不足。Linux 可通过错误队列接收 PMTU 与 ICMP 信息，具体接口应结合 `ip(7)`、`udp(7)` 和协议设计使用。

## 常见误区

### 把 rwnd、cwnd 和 SO_RCVBUF 当成同一个数

`SO_RCVBUF` 是内存上限，`rwnd` 是接收端通告给对端的流量控制额度，`cwnd` 是发送端根据网络状态计算的拥塞额度。吞吐受最小限制项约束。

### 认为缓冲区越大越好

超过所需容量后，继续增大缓冲区通常不会提高吞吐，却会提高每连接内存上限和排队时间。大量并发连接还可能把局部优化变成系统级内存压力。

### 把 MSS 直接设置成 MTU

MSS 不包含 IP、TCP 首部。MTU 1500 的普通 IPv4 TCP 通告 MSS 通常是 1460，不是 1500。隧道和额外封装还会降低 PMTU。

### 为了 VPN 问题永久把所有 MSS 调小

降低 MSS 可以绕过 black hole，但会让所有连接持续承担更多小包开销。应查清隧道 MTU、ICMP 过滤和 PLPMTUD，再决定是否在边界做有范围的 MSS clamping。

### 设置 SO_RCVBUF 后以为自动调优还在工作

Linux 对手动设置缓冲区的 Socket 停止对应方向的自动调优。固定值还应在建连前设置，并通过 `getsockopt()` 和连接状态验证。

### 用多流跑满证明单流配置正确

多个并行连接有各自的 `cwnd` 和 `rwnd`，总吞吐可以掩盖单连接窗口不足。诊断时先测单流，再测业务实际并发。

### 只看吞吐，不看 RTT 与重传

大缓冲区或激进算法可能提高吞吐，同时增加排队和尾延迟。性能验收至少应同时包含吞吐、RTT 分布、重传率、CPU、内存和业务延迟。

## 调优检查表

1. 明确目标是单流吞吐、尾延迟、连接规模还是 CPU 效率。
2. 测量业务方向的瓶颈带宽、空闲 RTT 和负载 RTT，计算 BDP。
3. 检查接口 MTU、路径 MTU、隧道开销和 SYN 中的 MSS。
4. 确认 Window Scale 与 SACK 已协商，观察 `cwnd`、`rwnd` 和 Socket 内存。
5. 排除应用、磁盘、CPU、限速器和接收速度造成的 `app_limited`。
6. 只有自动调优上限低于所需 BDP 时，才逐步提高缓冲区上限。
7. 把单连接上限乘以活跃连接数，核对总内存预算。
8. 每次只改一类参数，重新建连并做同条件 A/B 测试。
9. 同时验收吞吐、RTT、重传、零窗口、CPU、内存和业务尾延迟。
10. 记录内核版本、网卡卸载、队列规则、参数原值与回退值。

## 进一步阅读

- [RFC 9293: Transmission Control Protocol](https://www.rfc-editor.org/rfc/rfc9293.html)，TCP 基础规范，MSS 和有效发送 MSS 的权威定义。
- [RFC 7323: TCP Extensions for High Performance](https://www.rfc-editor.org/rfc/rfc7323.html)，Window Scale 与 Timestamp 的协商和实现约束。
- [RFC 6349: Framework for TCP Throughput Testing](https://www.rfc-editor.org/rfc/rfc6349.html)，BDP、缓冲区容量与 TCP 吞吐测试方法。
- [RFC 6691: TCP Options and Maximum Segment Size](https://www.rfc-editor.org/rfc/rfc6691.html)，MSS 与可变首部选项的精确关系。
- [RFC 5681: TCP Congestion Control](https://www.rfc-editor.org/rfc/rfc5681.html)，`cwnd`、`rwnd`、慢启动与拥塞避免的基础模型。
- [RFC 9438: CUBIC for Fast and Long-Distance Networks](https://www.rfc-editor.org/rfc/rfc9438.html)，大 BDP 路径上 CUBIC 的设计与边界。
- [RFC 2018: TCP Selective Acknowledgment Options](https://www.rfc-editor.org/rfc/rfc2018.html)，SACK 如何改善多包丢失后的恢复。
- [RFC 6298: Computing TCP's Retransmission Timer](https://www.rfc-editor.org/rfc/rfc6298.html)，RTT、RTT 方差和重传超时的计算。
- [RFC 4821: Packetization Layer Path MTU Discovery](https://www.rfc-editor.org/rfc/rfc4821.html)，TCP 不完全依赖 ICMP 的路径 MTU 探测。
- [RFC 2923: TCP Problems with Path MTU Discovery](https://www.rfc-editor.org/rfc/rfc2923.html)，PMTU black hole、MSS 与实际故障表现。
- [Linux IP sysctl documentation](https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html)，`tcp_rmem`、`tcp_wmem`、自动调优、拥塞控制和监听队列参数。
- [`tcp(7)`](https://man7.org/linux/man-pages/man7/tcp.7.html)，Linux TCP Socket 选项和 `/proc` 参数。
- [`socket(7)`](https://man7.org/linux/man-pages/man7/socket.7.html)，通用 Socket 缓冲区、低水位、超时与忙轮询语义。
- [RFC 8085: UDP Usage Guidelines](https://www.rfc-editor.org/rfc/rfc8085.html)，UDP 应用的拥塞控制、PMTU、分片和健壮性要求。
- [RFC 8899: Datagram PLPMTUD](https://www.rfc-editor.org/rfc/rfc8899.html)，UDP、QUIC 等数据报传输的路径 MTU 探测框架。

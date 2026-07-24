# 最小 C 示例文件索引

这是《[异步模块设计](../../../异步模块设计.md)》附录 A 的多文件版本。代码模拟网络下发播放命令、音频驱动异步完成、播放器状态转换和领域事件发布。

| 文件 | 职责 |
| :--- | :--- |
| [message.h](message.h) | 定义命令、内部事件、领域事件和消息负载。 |
| [audio_port.h](audio_port.h) | 定义播放器依赖的音频驱动端口。 |
| [player.h](player.h) | 定义播放器状态和公开处理入口。 |
| [player.c](player.c) | 实现播放器状态机和状态转换。 |
| [event_loop.h](event_loop.h) | 定义固定容量消息队列和事件循环接口。 |
| [event_loop.c](event_loop.c) | 实现入队、路由和领域事件发布。 |
| [network.h](network.h) | 声明网络包适配入口。 |
| [network.c](network.c) | 将网络协议文本转为定向命令。 |
| [audio_sim.h](audio_sim.h) | 声明模拟音频驱动和其异步回调入口。 |
| [audio_sim.c](audio_sim.c) | 实现 AudioPort 和回调转内部事件。 |
| [main.c](main.c) | 组装模块并演示播放和停止流程。 |

## 依赖关系

```text
main.c -> network.c, audio_sim.c, event_loop.c, player.c
network.c -> event_loop.h, message.h
audio_sim.c -> audio_port.h, event_loop.h, message.h
event_loop.c -> event_loop.h, player.h
player.c -> player.h, event_loop.h, audio_port.h
```

## 编译和运行

```bash
cc -std=c11 -Wall -Wextra -Werror \
  event_loop.c player.c network.c audio_sim.c main.c \
  -o player_demo
./player_demo
```

预期输出：

```text
audio start: https://example.com/welcome.mp3, request=42
PlayerStarted, request=42
audio stop, request=42
PlayerStopped, request=42
```

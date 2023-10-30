# WebRTC 协议介绍及相关技术说明

| Version | Date    | Description     |
| :------ | :------ | :-------------- |
| 1.0     | 2023-10 | Initial release |

## 1. 简介

[WebRTC（Web Real-Time Communications）](https://en.wikipedia.org/wiki/WebRTC)是一项**实时通讯技术**，它允许网络应用或者站点，在不借助中间媒介的情况下，建立不同设备上的两个应用之间点对点（Peer-to-Peer）的连接，实现视频流和音频流，或者其他任意数据的传输。

## 2. 相关概念

### 2.1 交互式连接创建(Interactive Connectivity Establishment , ICE)

[ICE](https://en.wikipedia.org/wiki/Interactive_Connectivity_Establishment)是一个帮助两台计算设备在点对点网络(peer-to-peer networking)中尽可能建立直接通讯的协议框架。在实际的网络当中，有很多原因能导致简单的从 A 端到 B 端直连不能如愿完成。这需要绕过阻止建立连接的防火墙，给你的设备分配一个唯一可见的地址（通常情况下我们的大部分设备没有一个固定的公网地址），如果路由器不允许主机直连，还得通过一台服务器转发数据。ICE 通过使用以下几种技术完成上述工作。

## Reference

1. [WebRTC-wiki](https://en.wikipedia.org/wiki/WebRTC)
2. [Interactive Connectivity Establishment (ICE)-wiki](https://en.wikipedia.org/wiki/Interactive_Connectivity_Establishment)

# Fake IP

Fake IP 是代理内核使用的一种 DNS 映射机制。它不会隐藏或伪造用户的公网 IP，
而是给域名临时分配一个只在本机代理环境中有意义的“占位 IP”，以便代理内核从后续流量中还原域名并执行分流。

## 快速结论

- Fake IP 的核心作用是保留“这条连接原本访问哪个域名”。
- 应用看到的 `198.18.x.x` 通常不是目标网站的真实 IP，而是代理内核分配的占位地址。
- 占位地址必须与域名映射表、DNS 劫持和 TUN/透明代理配合使用；单独把 DNS 改成 Fake IP DNS 并不能工作。
- Fake IP 有利于域名规则分流，也能减少对协议嗅探的依赖，但它本身不等于防止 DNS 泄漏。
- 局域网服务、连通性检测或会校验 DNS 结果的应用可能不兼容，需要让相关域名返回真实 IP。

## 工作流程

以访问 `example.com` 为例：

1. 应用向 DNS 查询 `example.com`。
2. 代理内核接管查询，不立即把真实 IP 返回给应用，而是分配 `198.18.0.2`，并记录映射：

   ```text
   198.18.0.2 <-> example.com
   ```

3. 应用向 `198.18.0.2:443` 发起连接。
4. 系统路由将这条连接送入代理内核。内核查表，把目标还原成 `example.com`。
5. 内核用域名匹配分流规则，选出直连、代理或拒绝等策略。
6. 内核或所选出站按策略解析真实 IP，或者把域名交给远端代理解析，然后连接真正的服务器。

因此，Fake IP 只存在于应用与本机代理内核之间。数据包不能绕过代理直接发往这个地址，否则不会到达目标网站。

## 为什么要使用 Fake IP

### 稳定地执行域名分流

TUN 接收到的 IP 数据包通常只有目标 IP，没有原始域名。Fake IP 映射让内核无需从 TLS、HTTP 或 QUIC
流量中重新猜测域名，就能执行 `DOMAIN-SUFFIX`、`GEOSITE` 等域名规则。这对 UDP 流量、无法嗅探的协议和加密程度较高的流量尤其有用。

### 将真实解析留在代理控制范围内

应用会很快得到一个合成的 DNS 答案，真正的域名解析可以等到规则确定后再由合适的 DNS 或远端代理完成。
这有助于避免本地 DNS 污染，并让直连域名和代理域名使用不同的解析路径。不过，建立真实连接前仍可能需要解析，
所以 Fake IP 不保证每次连接都更快。

### 减少对域名嗅探的依赖

嗅探需要解析 HTTP Host、TLS SNI 或 QUIC 等协议字段，并非所有连接都能提供这些信息。
Fake IP 直接保留 DNS 阶段的域名；嗅探仍可作为应用绕过代理 DNS、直接连接真实 IP 时的补充手段。

## 与 Redir Host 的区别

| 比较项 | Fake IP | Redir Host |
| --- | --- | --- |
| 返回给应用的地址 | 合成的占位 IP | DNS 解析得到的真实 IP |
| 何时解析真实 IP | 通常在确定路由策略之后 | 回答应用 DNS 查询之前 |
| 内核识别域名 | 通过 Fake IP 映射直接还原 | 依赖 DNS 反向映射或协议嗅探 |
| 对特殊应用的兼容性 | 可能需要过滤例外 | 通常更接近普通网络行为 |
| 域名规则的稳定性 | 通常更好 | 取决于内核是否看到了 DNS 查询及能否嗅探 |

Mihomo 将两者称为 DNS 的 `enhanced-mode`。选择哪一种是兼容性与域名识别能力之间的取舍，
不是简单的“新模式一定比旧模式好”。

## 为什么常见 `198.18.x.x`

`198.18.0.0/15` 是 IANA 登记的网络设备基准测试专用地址段，不是普通公网地址，也不是 RFC 1918 私网地址。
它的 `Global` 属性为 false，因此代理内核常从中划出一部分作为本地占位地址池。Mihomo 文档示例使用
`198.18.0.1/16`，sing-box 文档示例使用 `198.18.0.0/15`。

这只是实现中的默认选择，并不是 Fake IP 必须使用的固定地址段。修改地址池时要避免与现有 VPN、实验网络或路由表冲突。

## 常见问题

### 开启 Fake IP 就不会泄漏 DNS 吗

不一定。只有应用的 DNS 查询被代理接管，且内核访问上游 DNS 的路径也按预期配置时，才能避免查询绕过代理。
应用自带 DoH、Android 私人 DNS、局域网 DNS 或错误的 TUN 路由都可能绕过普通的 53 端口劫持。

### 为什么 `ping` 出来的是 `198.18.x.x`

这是正常的合成 DNS 答案。`ping` 此地址不能可靠反映目标网站是否在线，也不能用它判断网站的真实机房位置。
应查看代理日志、连接面板，或临时让该域名返回真实 IP 后再诊断网络。

### 为什么重启代理后已有连接突然失败

应用或系统可能仍缓存旧的 Fake IP，而内核重启后已经丢失对应映射。启用映射持久化可降低这种问题：
Mihomo 使用 `profile.store-fake-ip`，sing-box 使用缓存文件中的 `store_fakeip`。

### 哪些域名适合加入过滤列表

需要发现局域网设备、返回私网地址或会校验 DNS 结果的服务可能要求真实 IP，例如 mDNS、打印机、路由器管理页、
部分游戏机和系统连通性检测。出现问题时应根据日志精确添加域名，不要直接维护一份来源不明的巨大例外列表。

### IP 规则还会生效吗

会，但内核需要在适当阶段解析真实目标 IP，才能判断 `IP-CIDR`、`GEOIP` 等规则。
这可能触发额外 DNS 查询；Mihomo 的目标 IP 规则可用 `no-resolve` 明确跳过这一步。

## Mihomo 最小配置示例

```yaml
profile:
  store-fake-ip: true

dns:
  enable: true
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter-mode: blacklist
  fake-ip-filter:
    - '*.lan'
    - '*.local'

tun:
  enable: true
  auto-route: true
  dns-hijack:
    - any:53
    - tcp://any:53
```

这段配置只展示组件之间的关系，并不是可直接套用的完整配置。上游 DNS、代理节点域名解析、IPv6、
路由排除项和客户端的配置合并方式仍需按实际环境设置。

## 排障清单

1. 确认应用查询到的是配置地址池中的 Fake IP。
2. 确认代理内核日志中存在该 Fake IP 对应的域名。
3. 确认 Fake IP 地址段确实被路由进 TUN，没有被其他 VPN 或静态路由抢走。
4. 确认 UDP 与 TCP DNS 都被接管，并检查应用是否使用了自带 DoH 或私人 DNS。
5. 只对故障域名临时返回真实 IP；若问题消失，再把它加入 `fake-ip-filter`。
6. 若重启后才出问题，检查映射持久化和系统 DNS 缓存。
7. 若域名规则正确但连接失败，继续检查真实 DNS、所选出站和 IPv6，而不是只盯着 Fake IP。

## References

1. [Mihomo：DNS configuration](https://wiki.metacubex.one/en/config/dns/)
2. [Mihomo：General configuration](https://wiki.metacubex.one/en/config/general/)
3. [Mihomo：TUN](https://wiki.metacubex.one/en/config/inbound/tun/)
4. [sing-box：FakeIP](https://sing-box.sagernet.org/configuration/dns/server/fakeip/)
5. [sing-box：Cache File](https://sing-box.sagernet.org/configuration/experimental/cache-file/)
6. [RFC 6890：Special-Purpose Address Registries](https://www.rfc-editor.org/rfc/rfc6890.html)

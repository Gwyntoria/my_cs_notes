# 添加tftp支持

`tftp-hpa` 工具包因安全原因已经不再新版本的 macOS 支持列表中，可以考虑使用 macOS 自带的 tftp 服务器，这样可以将你的 Mac 变成一个 tftp 服务器，允许其他设备通过 tftp 从 Mac 获取文件。

执行以下指令：

```sh
sudo launchctl load -F /System/Library/LaunchDaemons/tftp.plist
sudo launchctl start com.apple.tftpd
```

查看是否启动了 tftp 服务：

```sh
sudo launchctl list | grep tftp
```

load之后的结果：

```text
-   0   com.apple.tftpd
```

start之后的结果：

```text
-   1   com.apple.tftpd
```

关闭 tftp 服务：

```sh
sudo launchctl stop com.apple.tftpd
sudo launchctl unload /System/Library/LaunchDaemons/tftp.plist
```

## 关于`/System/Library/LaunchDaemons/tftp.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Disabled</key>
    <true/>
    <key>Label</key>
    <string>com.apple.tftpd</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/libexec/tftpd</string>
        <string>-i</string>
        <string>/private/tftpboot</string>
    </array>
    <key>inetdCompatibility</key>
    <dict>
        <key>Wait</key>
        <true/>
    </dict>
    <key>InitGroups</key>
    <true/>
    <key>Sockets</key>
    <dict>
        <key>Listeners</key>
        <dict>
            <key>SockServiceName</key>
            <string>tftp</string>
            <key>SockType</key>
            <string>dgram</string>
        </dict>
    </dict>
</dict>
</plist>
```

- `Disabled`: 表示 TFTP 守护进程是否禁用，设置为 <true/> 表示禁用。
- `Label`: 用于标识 TFTP 守护进程的标签，可以随意设置。
- `ProgramArguments`: 指定 TFTP 守护进程的执行命令和参数。
- `/usr/libexec/tftpd`: TFTP 守护进程的执行命令路径。
- `-i`: TFTP 守护进程的参数，表示允许上传文件。
- `/private/tftpboot`: TFTP 守护进程的根目录，这里设置为 /private/tftpboot。
- `inetdCompatibility`: 用于设置与 inetd 兼容性的配置项，<true/> 表示兼容 inetd。
- `InitGroups`: 表示是否使用 initgroups() 函数，设置为 <true/> 表示使用。
- `Sockets`: 指定 TFTP 守护进程监听的套接字配置。
- `Listeners`: 指定监听器的配置。
- `SockServiceName`: 指定监听的服务名称，这里设置为 tftp。
- `SockType`: 指定监听的套接字类型，这里设置为 dgram 表示使用数据报套接字。

这些配置项可以通过编辑配置文件来自定义 TFTP 守护进程的行为，例如修改根目录、禁用上传文件等。在修改完配置文件后，需要重新加载 TFTP 守护进程才能生效，可以使用 sudo launchctl unload 和 sudo launchctl load 命令来加载和卸载 TFTP 守护进程的配置文件。

## more info

2023/4/25测试，`tftpd`启动之后依然无法使用，局域网内的设备无法访问。之后修改`/private/tftp`的权限为`777`，关闭了firewall，并重启Mac后，`tftpd`可正常使用

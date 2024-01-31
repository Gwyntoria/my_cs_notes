# loto_rtmp 运行时框架

| Version | Date      | Description |
| :------ | :-------- | :---------- |
| 1.0     | 2024-1-31 | 初次发布    |

## 1. 运行时环境

`loto_rtmp`在运行时需要依赖部分 SDK 中的动态库和一些移植的外部库。关于静态 IP 和 MAC 地址也需要修改部分系统脚本进行配置。

相关配置脚本及依赖资源已被整理至相应仓库中的`rtmp_pack`目录下。

相关仓库如下：

1. [CamController_3516DV300](http://gitnas.loc:10086/embedded/camcontroller_tbj)
2. [webrtc_3516dv300](http://gitnas.loc:10086/embedded/webrtc_3516dv300)
3. [StreamController_402](http://gitnas.loc:10086/embedded/streamcontroller_402)

## 1.1. rtmp_pack

### 1.1.1. rtmp_pack 目录结构

```text
rtmp_pack/
├── install.sh                      # 安装`rtmp_pack`的脚本
├── kit
│   ├── bin
│   │   └── ntpdate                 # 用于时间同步的第三方ntp软件（现已不使用）
│   ├── etc
│   │   ├── init.d
│   │   │   ├── loto_conf.sh        # 系统环境配置，包含ko文件、网络信息等内容
│   │   │   └── rcS                 # 系统启动时将自动调用该脚本，内含MAC地址固定功能
│   │   ├── localtime               # 时区配置
│   │   └── resolv.conf             # 网关配置
│   ├── lib
│   │   ├── opus_lib                # opus音频编码库
│   │   └── rtmp_lib                # 主程序所依赖的环境库
│   ├── root
│   │   ├── loto_rtmp               # 推流主程序
│   │   ├── push.conf               # loto_rtmp 运行时读取的配置文件
│   │   ├── res                     # bitmap
│   │   ├── scripts
│   │   │   ├── check_process.sh    # 判断相应进程是否存在
│   │   │   ├── kill_process.sh     # kill loto_conf.sh和loto_rtmp
│   │   │   └── time_conf.sh        # 时间同步的脚本（现已不使用）
│   │   └── update.sh               # 使用tftp更新程序的脚本
│   └── spool.tgz                   # 原自启动相关配置（现已不使用）
└── README.md                       # 使用方法
```

> **NOTE:** 不同项目中，该目录中的内容略有区别，但结构大致相同

### 1.1.2. rtmp_pack 安装方法

将`rtmp_pack`压缩成`tgz`格式后，使用`tftp`传输至板端的`/root`目录下并解压，`cd`至`rtmp_pack`目录后执行`./install.sh`即可。

## 2. 修改环境配置脚本

### 2.1 rcS

```bash
macaddr=undefined
while read LINE
        do
                macaddr=$LINE
        done < /etc/macaddr

#echo $macaddr
if [ "$macaddr" = "undefined" ];then
        macaddr=C6:F4:7E:$(($RANDOM%100)):$(($RANDOM%100)):$(($RANDOM%100))
        echo $macaddr > /etc/macaddr
        chmod 766 /etc/macaddr
fi
ifconfig eth0 down
ifconfig eth0 hw ether $macaddr
ifconfig eth0 up
```

海思每次断电重启后都会被赋予一个随机的 MAC 地址，以上内容将在第一次执行时随机生成 MAC 地址，并保存在`/etc/macaddr`文件中，此后 MAC 地址都将读取该文件中的值。

第一次配置的机器，应当再将生成的 MAC 地址同步到钉钉的机器配置群中的《摄像头推流设备信息》表格中，以便将设备 MAC 地址同步给后端数据库进行相关配置，后续机器需要重烧系统时恢复特定设备的 MAC 地址。

```bash
cd /ko
./load3516dv300 -i -osmem 256 -total 1024
```

其中`osmem`的参数应参考 Uboot 的`bootargs`引导参数设定，`total`的参数应参考硬件设计。

> **NOTE:** `bootargs`的设定参考《hisi3516dv300 固件烧录指南》中“配置启动参数”小节。

### 2.2 loto_conf.sh

```bash
echo "########## Network Configuring ##########"
ifconfig eth0 10.0.0.80 netmask 255.255.252.0
route add default gw 10.0.1.1
```

修改此段配置以更改静态 IP 地址。

### 2.3 push.conf

```text
[device]
device_num=000 # 设备号

[push]
server_url=http://r.zhuagewawa.com/admin/room/register.pusher # 正式服请求地址
# server_url=http://t.zhuagewawa.com/admin/room/register.pusher # 测试服请求地址

server_token=dadq0(~@E#Q)DSD12E1@_2{[QWE]2125+_a)E_QISDJ8NC8281@njfsGj # 服务器验证 token

push_url=rtmp://10.12.1.9/live/w055     # 默认推流地址

requested_url=off       # 是否向服务器请求推流地址，请求推流地址后会覆盖先前读取的默认推流地址
# requested_url=on

resolution=1080         # 分辨率
# resolution=720

framerate=30            # 帧率
# framerate=50

video_state=on          # cover开关

video_encoder=h264      # 视频编码器选择
# video_encoder=h265

audio_state=on          # 音频开关
# audio_state=off

audio_encoder=aac       # 音频编码器选择
# audio_encoder=opus

[h264]
profile=high            # 视频编码参数
# profile=baseline

[h265]
profile=main
# profile=main_10
```

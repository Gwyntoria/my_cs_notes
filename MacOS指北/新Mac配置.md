# 新Mac配置

## 1. 提示

如果终端无法访问安装地址，需要在终端修改全局变量来支持代理。

```sh
export HTTP_PROXY=192.168.3.32:7890
export HTTPS_PROXY=192.168.3.32:7890
```

**补充：** 本地开启Clash的TUN Mode，并且开启Global后，多次测试后依然无法在终端连接到下载地址。本地Clash开启Alow LAN，并将终端代理服务器的IP地址指向本机IP后，多次尝试后也无法连接下载地址。

## 2. 终端网络连接失败解决方案

1. 另一台机器开启Clash的Alow LAN
2. Mac终端中设定代理服务器地址为开启Clash的机器的IP地址，端口设定为Clash指定端口（默认为7890）

## 3. 安装包管理工具Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 4. 安装zsh自动补全工具

### 4.1 安装`oh-my-zsh`

1. 使用包管理工具安装 `zsh` 的自动补全插件。有多种插件可供选择，例如 `oh-my-zsh`、`zsh-autosuggestions`、`zsh-completions`等。这里以 `oh-my-zsh` 插件为例进行说明。

    - 如果您尚未安装 oh-my-zsh，可以通过以下命令在终端中安装：

        ```sh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        ```

    - 安装完 oh-my-zsh 后，可以通过以下命令安装 zsh-autosuggestions 插件：

        ```sh
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
        ```

2. 配置 zsh 的自动补全插件。编辑 `~/.zshrc` 文件，在其中找到 `plugins` 配置项，并将需要使用的自动补全插件添加到其中。例如，如果您想启用 `zsh-autosuggestions` 插件，可以将其添加到 `plugins` 配置项中，如下所示：

    ```sh
    plugins=(zsh-autosuggestions)
    ```

3. 保存并关闭 ~/.zshrc 文件，然后执行以下命令使配置生效：

    ```sh
    source ~/.zshrc
    ```

## 5. 使用包管理工具 `Homebrew` 下载工具

```sh
# Python
brew install python

# Git
brew install git

# Java
brew tap adoptopenjdk/openjdk
brew install --cask adoptopenjdk11

# You-Get
brew install you-get

#Telnet
brew install telnet
```

## 6. 常用软件

1. vs code
2. iina (media player)
3. eudic
4. qBittorrent-v4.4.5
5. Chrome
6. Xcode
7. The Unarchiver

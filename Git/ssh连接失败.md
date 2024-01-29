# ssh 连接失败

原先可正常使用 ssh 进行 push 或 pull 的本地仓库，近期突然不再可以进行相关操作。在尝试 clone 一些新仓库时也会显示无法访问到 github.com。转用 HTTP 的请求时，大多情况下也无法拉取远程仓库。

根据 GitHub Docs 中的提示，执行`ssh -T git@github.com`进行 ssh 连接测试，依然显示连接失败。

## 启用通过 HTTPS 的 SSH 连接

GitHub Docs 中还提示可以使用 HTTPS 端口进行 ssh 连接，可以使用以下 ssh 命令进行端口测试：

```bash
ssh -T -p 443 git@ssh.github.com
```

> 注意：端口 443 的主机名为 `ssh.github.com`，而不是 `github.com`。

若显示如下内容，则表示连接成功：

```text
> Hi USERNAME! You've successfully authenticated, but GitHub does not provide shell access.
```

如果你能在端口 443 上通过 SSH 连接到 `git@ssh.github.com`，则可覆盖你的 SSH 设置来强制与 GitHub.com 的任何连接均通过该服务器和端口运行。

要在 SSH 配置文件中设置此行为，请在 `~/.ssh/config` 编辑该文件，并添加以下部分：

```text
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
```

之后可以再次使用`ssh -T git@github.com`进行连接测试。

## References

1. [在 HTTPS 端口使用 SSH](https://docs.github.com/zh/authentication/troubleshooting-ssh/using-ssh-over-the-https-port)
2. [SSH 故障排除](https://docs.github.com/zh/authentication/troubleshooting-ssh)

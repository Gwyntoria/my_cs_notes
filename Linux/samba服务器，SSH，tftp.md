# samba服务器，SSH，tftp

## samba

1. 安装samba的核心插件

```bash
sudo apt-get install samba
```

2. 修改`/etc/samba` 下的配置文件 `sam.conf`

```bash
sudo gedit /etc/samba/sam.conf
```

3. 在文件末尾添加配置信息

```bash
[karl] # karl --> usr_name
	comment=samba home directory
	path=/home/karl
	public=yes
	browseable=yes
	public=yes
	read only=no
	valid users=karl
	create mask=0777
	directory mask=0777
	force user=nobody
	force group=nogroup
	available=yes
```

4. 重启samba服务器

```bash
sudo /etc/init.d/samba restart
```

或者

```bash
sudo service smbd restart
```

5. 配置用户及密码

```bash
sudo smbpasswd -a karl
```

## SSH

1. 安装SSH服务器

```bash
sudo apt-get install openssh-server
```

2. 查看是否在运行

```bash
ps -A | grep ssh

# ps -A --> 所有的进程
# grep ssh --> 查找ssh
```




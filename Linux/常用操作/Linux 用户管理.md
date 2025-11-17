# Linux 用户基础及其管理详解

## 一、用户账户基础概念

### 1.1 用户类型分类

Linux系统中的用户主要分为三类：

#### **超级用户（root）**
- UID为0
- 拥有系统最高权限
- 可以执行任何操作

#### **系统用户**
- UID通常为1-999（不同发行版可能不同）
- 用于运行系统服务和守护进程
- 通常不允许登录

#### **普通用户**
- UID从1000开始
- 权限受限
- 日常工作使用的账户

### 1.2 用户标识

```bash
# 查看当前用户信息
id
# uid=1000(username) gid=1000(groupname) groups=1000(groupname),4(adm),27(sudo)

# 查看当前登录用户
whoami

# 查看所有登录用户
who
w
```

## 二、用户相关配置文件

### 2.1 /etc/passwd 文件

存储用户账户基本信息：

```
username:x:UID:GID:comment:home_directory:shell
```

示例：
```bash
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
john:x:1000:1000:John Doe:/home/john:/bin/bash
```

### 2.2 /etc/shadow 文件

存储用户密码信息（加密后）：

```
username:encrypted_password:last_change:min:max:warn:inactive:expire:reserved
```

### 2.3 /etc/group 文件

存储组信息：

```
groupname:x:GID:user_list
```

### 2.4 /etc/gshadow 文件

存储组密码信息

## 三、用户管理命令

### 3.1 创建用户

#### **useradd 命令**

```bash
# 基本用法
sudo useradd username

# 常用选项
sudo useradd -m username           # 创建家目录
sudo useradd -d /path/to/home username  # 指定家目录
sudo useradd -s /bin/bash username      # 指定shell
sudo useradd -g groupname username      # 指定主组
sudo useradd -G group1,group2 username  # 指定附加组
sudo useradd -u 1500 username          # 指定UID
sudo useradd -c "Full Name" username   # 添加注释

# 综合示例
sudo useradd -m -d /home/john -s /bin/bash -g users -G sudo,docker -c "John Doe" john
```

### 3.2 设置/修改密码

```bash
# 设置密码
sudo passwd username

# 强制用户下次登录修改密码
sudo passwd -e username

# 查看密码状态
sudo passwd -S username

# 锁定用户账户
sudo passwd -l username

# 解锁用户账户
sudo passwd -u username
```

### 3.3 修改用户

#### **usermod 命令**

```bash
# 修改用户家目录
sudo usermod -d /new/home/dir username

# 修改用户shell
sudo usermod -s /bin/zsh username

# 修改用户名
sudo usermod -l newname oldname

# 添加附加组
sudo usermod -aG groupname username

# 修改主组
sudo usermod -g newgroup username

# 锁定用户
sudo usermod -L username

# 解锁用户
sudo usermod -U username

# 设置账户过期时间
sudo usermod -e 2024-12-31 username
```

### 3.4 删除用户

```bash
# 删除用户（保留家目录）
sudo userdel username

# 删除用户及其家目录
sudo userdel -r username

# 强制删除（即使用户正在登录）
sudo userdel -f username
```

## 四、用户组管理

### 4.1 创建组

```bash
# 创建组
sudo groupadd groupname

# 指定GID
sudo groupadd -g 1500 groupname
```

### 4.2 修改组

```bash
# 修改组名
sudo groupmod -n newname oldname

# 修改GID
sudo groupmod -g 1600 groupname
```

### 4.3 删除组

```bash
sudo groupdel groupname
```

### 4.4 管理组成员

```bash
# 查看用户所属组
groups username

# 将用户添加到组
sudo gpasswd -a username groupname

# 从组中删除用户
sudo gpasswd -d username groupname

# 查看组成员
getent group groupname
```

## 五、用户权限管理

### 5.1 文件权限

```bash
# 查看权限
ls -l file.txt
# -rw-r--r-- 1 user group 1024 Jan 1 10:00 file.txt

# 修改权限
chmod 755 file.txt        # 数字方式
chmod u+x file.txt        # 符号方式
chmod g-w file.txt        # 移除组写权限
chmod o=r file.txt        # 设置其他用户只读

# 修改所有者
chown newuser file.txt
chown newuser:newgroup file.txt

# 修改所属组
chgrp newgroup file.txt
```

### 5.2 sudo 权限配置

编辑 `/etc/sudoers` 文件：

```bash
# 使用 visudo 命令安全编辑
sudo visudo

# 配置示例
username ALL=(ALL:ALL) ALL              # 完全权限
username ALL=(ALL) NOPASSWD: ALL        # 无需密码
username ALL=(ALL) /usr/bin/apt-get     # 仅特定命令

# 组配置
%groupname ALL=(ALL:ALL) ALL            # 组权限
```

## 六、实用管理技巧

### 6.1 批量创建用户

```bash
#!/bin/bash
# 批量创建用户脚本

for i in {1..10}
do
    username="user$i"
    sudo useradd -m -s /bin/bash $username
    echo "$username:password$i" | sudo chpasswd
    echo "Created user: $username"
done
```

### 6.2 用户信息查询

```bash
# 查看所有用户
cat /etc/passwd | cut -d: -f1

# 查看当前登录用户
users
who
w

# 查看用户登录历史
last
lastlog

# 查看用户详细信息
finger username
chage -l username    # 密码过期信息
```

### 6.3 用户环境配置

```bash
# 全局配置文件
/etc/profile           # 所有用户登录时执行
/etc/bash.bashrc      # 所有用户bash配置
/etc/environment      # 系统环境变量

# 用户配置文件
~/.profile            # 用户登录配置
~/.bashrc            # bash配置
~/.bash_profile      # bash登录配置
```

## 七、安全最佳实践

### 7.1 密码策略

```bash
# 安装密码复杂度检查工具
sudo apt-get install libpam-pwquality

# 配置 /etc/security/pwquality.conf
minlen = 12          # 最小长度
dcredit = -1        # 至少1个数字
ucredit = -1        # 至少1个大写
lcredit = -1        # 至少1个小写
ocredit = -1        # 至少1个特殊字符
```

### 7.2 账户安全

```bash
# 设置密码过期策略
sudo chage -M 90 username    # 90天后过期
sudo chage -m 7 username     # 最少7天才能改密码
sudo chage -W 14 username    # 14天前警告

# 限制 su 命令使用
# 编辑 /etc/pam.d/su
auth required pam_wheel.so use_uid
```

### 7.3 监控和审计

```bash
# 查看失败登录尝试
sudo faillog

# 查看最近登录
last -10

# 监控用户活动
sudo aureport --user      # 需要安装 auditd
```

## 八、常见问题处理

### 8.1 忘记密码

```bash
# 以root身份重置用户密码
sudo passwd username

# 忘记root密码时，通过单用户模式重置
# 1. 重启系统
# 2. 在GRUB菜单按'e'编辑
# 3. 在linux行末尾添加 init=/bin/bash
# 4. Ctrl+X 启动
# 5. mount -o remount,rw /
# 6. passwd root
```

### 8.2 用户无法登录

```bash
# 检查账户状态
sudo passwd -S username

# 检查shell设置
grep username /etc/passwd

# 检查家目录权限
ls -ld /home/username

# 检查SSH配置（如果是SSH登录）
grep AllowUsers /etc/ssh/sshd_config
```

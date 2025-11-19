# Linux 用户基础及其管理详解

## 一、用户账户基础概念

### 1.1 用户类型分类

Linux系统中的用户主要分为三类：

#### **超级用户（root）**
- UID为0
- 拥有系统最高权限
- 可以执行任何操作
- 建议：日常工作不要直接使用root账户，而是使用sudo

#### **系统用户**
- UID通常为1-999（RHEL/CentOS/Fedora）或1-499（Debian/Ubuntu旧版）
- 用于运行系统服务和守护进程
- 通常不允许登录（shell设置为/sbin/nologin或/bin/false）
- 例如：www-data、mysql、redis等

#### **普通用户**
- UID从1000开始（可在/etc/login.defs中配置）
- 权限受限
- 日常工作使用的账户

### 1.2 用户标识

```bash
# 查看当前用户信息
id
# uid=1000(username) gid=1000(groupname) groups=1000(groupname),4(adm),27(sudo)

# 查看指定用户信息
id username

# 查看当前登录用户
whoami

# 查看所有登录用户
who        # 简要信息
w          # 详细信息（包括负载和进程）
users      # 仅显示用户名

# 查看登录用户数
who | wc -l
```

### 1.3 UID和GID范围规划

```bash
# 查看系统UID/GID配置
cat /etc/login.defs | grep -E 'UID_MIN|UID_MAX|GID_MIN|GID_MAX'

# 典型配置
UID_MIN                  1000    # 普通用户最小UID
UID_MAX                 60000    # 普通用户最大UID
SYS_UID_MIN               201    # 系统用户最小UID
SYS_UID_MAX               999    # 系统用户最大UID
GID_MIN                  1000    # 普通组最小GID
GID_MAX                 60000    # 普通组最大GID
```

## 二、用户相关配置文件

### 2.1 /etc/passwd 文件

存储用户账户基本信息，每行7个字段：

```
username:x:UID:GID:comment:home_directory:shell
```

示例：
```bash
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
john:x:1000:1000:John Doe,Office 101,555-1234:/home/john:/bin/bash
```

**字段说明：**
1. 用户名
2. 密码占位符（x表示密码存储在/etc/shadow）
3. UID
4. 主组GID
5. 注释字段（GECOS，可包含全名、办公室、电话等）
6. home目录路径
7. 登录Shell

```bash
# 查看特定用户
getent passwd username

# 查看所有普通用户（UID>=1000）
awk -F: '$3>=1000 && $3<60000 {print $1}' /etc/passwd

# 查看系统用户
awk -F: '$3<1000 {print $1}' /etc/passwd
```

### 2.2 /etc/shadow 文件

存储用户密码信息（加密后），每行9个字段：

```
username:encrypted_password:last_change:min:max:warn:inactive:expire:reserved
```

示例：
```bash
john:$6$random$hashedpassword:19000:0:99999:7:30:19500:
```

**字段说明：**
1. 用户名
2. 加密密码（\$id\$salt$hashed格式）
   - $1$ = MD5
   - $5$ = SHA-256
   - $6$ = SHA-512
   - !! 或 * 表示账户被锁定
3. 上次修改密码的日期（从1970-01-01起的天数）
4. 密码最小使用天数
5. 密码最大使用天数
6. 密码过期前警告天数
7. 密码过期后宽限天数
8. 账户过期日期
9. 保留字段

```bash
# 查看shadow文件（需要root权限）
sudo cat /etc/shadow | grep username

# 查看密码算法
sudo grep '^ENCRYPT_METHOD' /etc/login.defs
```

### 2.3 /etc/group 文件

存储组信息，每行4个字段：

```
groupname:x:GID:user_list
```

示例：
```bash
sudo:x:27:john,alice
docker:x:999:john,bob
```

**字段说明：**
1. 组名
2. 组密码占位符（实际存储在/etc/gshadow）
3. GID
4. 附加成员列表（逗号分隔，不包含主组成员）

```bash
# 查看特定组
getent group groupname

# 查看用户所属的所有组
groups username

# 列出组的所有成员（包括主组和附加组）
getent group groupname | cut -d: -f4
lid -g groupname  # 如果安装了libuser
```

### 2.4 /etc/gshadow 文件

存储组密码和管理员信息：

```
groupname:encrypted_password:admins:members
```

### 2.5 用户默认配置

```bash
# /etc/default/useradd - useradd命令的默认值
cat /etc/default/useradd

# /etc/skel/ - 新用户家目录模板
ls -la /etc/skel/
# 创建用户时，该目录下的文件会被复制到新用户家目录

# /etc/login.defs - 登录相关的系统设置
cat /etc/login.defs
```

## 三、用户管理命令

### 3.1 创建用户

#### **useradd 命令**

```bash
# 基本用法（使用系统默认设置）
sudo useradd username

# 常用选项
sudo useradd -m username                    # 创建家目录
sudo useradd -d /path/to/home username     # 指定家目录
sudo useradd -s /bin/bash username         # 指定shell
sudo useradd -g groupname username         # 指定主组
sudo useradd -G group1,group2 username     # 指定附加组
sudo useradd -u 1500 username              # 指定UID
sudo useradd -c "Full Name" username       # 添加注释
sudo useradd -e 2024-12-31 username        # 设置账户过期日期
sudo useradd -f 30 username                # 密码过期后30天禁用账户
sudo useradd -k /etc/skel username         # 指定模板目录
sudo useradd -r username                   # 创建系统账户

# 综合示例
sudo useradd -m -d /home/john -s /bin/bash -g users -G sudo,docker -c "John Doe" john

# 查看useradd默认设置
useradd -D

# 修改useradd默认设置
sudo useradd -D -s /bin/bash              # 修改默认shell
sudo useradd -D -b /home                  # 修改默认家目录基础路径
```

#### **adduser 命令（Debian/Ubuntu交互式工具）**

```bash
# 交互式创建用户（会自动创建家目录、设置密码等）
sudo adduser username

# 添加用户到组
sudo adduser username groupname
```

### 3.2 设置/修改密码

```bash
# 交互式设置密码
sudo passwd username

# 非交互式设置密码
echo "username:newpassword" | sudo chpasswd

# 从标准输入设置密码
echo "newpassword" | sudo passwd --stdin username  # RHEL/CentOS

# 强制用户下次登录修改密码
sudo passwd -e username
sudo chage -d 0 username  # 另一种方法

# 查看密码状态
sudo passwd -S username
# 输出格式: username PS 2024-01-01 0 99999 7 -1
# PS = Password Set (有效密码)
# L  = Locked (已锁定)
# NP = No Password (无密码)

# 锁定用户账户（在密码前添加!）
sudo passwd -l username
sudo usermod -L username  # 同样效果

# 解锁用户账户
sudo passwd -u username
sudo usermod -U username  # 同样效果

# 删除用户密码（不安全，不推荐）
sudo passwd -d username

# 设置密码最小长度
sudo passwd -n 7 username  # 7天内不能修改密码
sudo passwd -x 90 username # 90天后必须修改密码
sudo passwd -w 14 username # 过期前14天警告
sudo passwd -i 30 username # 过期后30天禁用账户
```

### 3.3 修改用户

#### **usermod 命令**

```bash
# 修改用户家目录
sudo usermod -d /new/home/dir username
sudo usermod -d /new/home/dir -m username  # -m 移动旧家目录内容

# 修改用户shell
sudo usermod -s /bin/zsh username
sudo usermod -s /sbin/nologin username     # 禁止登录

# 修改用户名
sudo usermod -l newname oldname

# 修改用户UID
sudo usermod -u 1500 username

# 添加附加组（追加方式）
sudo usermod -aG groupname username
sudo usermod -aG group1,group2 username

# 设置附加组（覆盖方式）
sudo usermod -G group1,group2 username

# 修改主组
sudo usermod -g newgroup username

# 锁定用户（在密码前添加!）
sudo usermod -L username

# 解锁用户
sudo usermod -U username

# 设置账户过期时间
sudo usermod -e 2024-12-31 username
sudo usermod -e "" username  # 取消过期时间

# 修改注释
sudo usermod -c "New Comment" username

# 修改用户家目录并移动文件
sudo usermod -d /new/home -m username

# 将用户shell改为nologin（禁止登录但允许运行服务）
sudo usermod -s /usr/sbin/nologin username
```

#### **chage 命令（密码时效管理）**

```bash
# 查看密码时效信息
sudo chage -l username

# 设置密码最后修改日期
sudo chage -d 2024-01-01 username
sudo chage -d 0 username  # 强制下次登录修改密码

# 设置密码过期天数
sudo chage -M 90 username      # 90天后过期
sudo chage -M -1 username      # 永不过期

# 设置密码最小使用天数
sudo chage -m 7 username       # 7天后才能修改

# 设置密码过期前警告天数
sudo chage -W 14 username      # 14天前开始警告

# 设置密码过期后宽限天数
sudo chage -I 30 username      # 过期后30天内仍可登录

# 设置账户过期日期
sudo chage -E 2024-12-31 username
sudo chage -E -1 username      # 永不过期

# 交互式修改所有参数
sudo chage username
```

### 3.4 删除用户

```bash
# 删除用户（保留家目录和邮件）
sudo userdel username

# 删除用户及其家目录和邮件
sudo userdel -r username

# 强制删除（即使用户正在登录）
sudo userdel -f username

# 安全删除用户的完整流程
# 1. 先锁定账户
sudo usermod -L username
# 2. 终止用户进程
sudo pkill -u username
# 3. 备份用户数据
sudo tar -czf /backup/username_backup.tar.gz /home/username
# 4. 删除用户
sudo userdel -r username
# 5. 检查残留文件
sudo find / -user username 2>/dev/null
# 6. 检查定时任务
sudo crontab -u username -l
sudo crontab -u username -r
```

### 3.5 用户信息查询

```bash
# 查看用户详细信息
id username
finger username  # 需要安装finger包

# 查看用户最后登录时间
lastlog
lastlog -u username

# 查看用户登录历史
last username
last -n 10  # 最近10次登录

# 查看失败登录尝试
sudo lastb
sudo lastb username

# 查看当前登录用户详情
w
who -a

# 查看用户进程
ps -u username
pgrep -u username

# 查看用户文件
sudo find /home -user username
```

## 四、用户组管理

### 4.1 创建组

```bash
# 创建普通组
sudo groupadd groupname

# 创建系统组
sudo groupadd -r groupname

# 指定GID
sudo groupadd -g 1500 groupname

# 创建组时指定密码（不常用）
sudo groupadd -p encrypted_password groupname
```

### 4.2 修改组

```bash
# 修改组名
sudo groupmod -n newname oldname

# 修改GID
sudo groupmod -g 1600 groupname

# 修改组密码
sudo gpasswd groupname
```

### 4.3 删除组

```bash
# 删除组
sudo groupdel groupname

# 注意：如果组是某个用户的主组，无法删除
# 需要先修改用户的主组或删除用户

# 查找使用该组作为主组的用户
awk -F: -v gid="$(getent group groupname | cut -d: -f3)" '$4==gid {print $1}' /etc/passwd
```

### 4.4 管理组成员

```bash
# 查看用户所属组
groups username
id -Gn username

# 将用户添加到组（附加组）
sudo gpasswd -a username groupname
sudo usermod -aG groupname username

# 从组中删除用户
sudo gpasswd -d username groupname

# 设置组管理员
sudo gpasswd -A admin_user groupname

# 设置组成员（覆盖方式）
sudo gpasswd -M user1,user2,user3 groupname

# 查看组成员
getent group groupname
lid -g groupname
members groupname  # 需要安装members包

# 查看所有组
cat /etc/group
getent group

# 查看用户的主组
id -gn username

# 临时切换用户的主组
newgrp groupname  # 当前会话生效
```

### 4.5 组密码管理（不常用）

```bash
# 设置组密码
sudo gpasswd groupname

# 取消组密码
sudo gpasswd -r groupname

# 用户使用组密码加入组
newgrp groupname
# 输入组密码后临时加入该组
```

## 五、用户权限管理

### 5.1 文件权限基础

```bash
# 查看权限
ls -l file.txt
# -rw-r--r-- 1 user group 1024 Jan 1 10:00 file.txt
# 权限: 类型(1) 所有者(3) 组(3) 其他(3)

# 权限类型
# r (read)    = 4  读
# w (write)   = 2  写
# x (execute) = 1  执行
# - (none)    = 0  无权限

# 文件类型
# - 普通文件
# d 目录
# l 符号链接
# b 块设备
# c 字符设备
# s 套接字
# p 管道

# 修改权限（数字方式）
chmod 755 file.txt    # rwxr-xr-x
chmod 644 file.txt    # rw-r--r--
chmod 600 file.txt    # rw-------
chmod 777 file.txt    # rwxrwxrwx（不推荐）

# 修改权限（符号方式）
chmod u+x file.txt        # 所有者添加执行权限
chmod g-w file.txt        # 组移除写权限
chmod o=r file.txt        # 其他用户只读
chmod a+x file.txt        # 所有人添加执行权限
chmod u=rwx,g=rx,o=r file.txt  # 组合设置

# 递归修改权限
chmod -R 755 directory/

# 修改所有者
chown newuser file.txt
chown newuser:newgroup file.txt
chown -R newuser:newgroup directory/

# 修改所属组
chgrp newgroup file.txt
chgrp -R newgroup directory/

# 仅修改所有者，保持组不变
chown newuser: file.txt
```

### 5.2 特殊权限

```bash
# SUID (Set User ID) - 4000
# 文件执行时以文件所有者身份运行
chmod u+s file
chmod 4755 file
# 示例: /usr/bin/passwd

# SGID (Set Group ID) - 2000
# 文件: 执行时以文件所属组身份运行
# 目录: 在目录中创建的文件继承目录的组
chmod g+s file_or_dir
chmod 2755 file_or_dir

# Sticky Bit - 1000
# 目录: 只有文件所有者才能删除自己的文件
# 常用于 /tmp 目录
chmod +t directory
chmod 1777 directory
# 示例: drwxrwxrwt /tmp

# 查看特殊权限
ls -l /usr/bin/passwd
# -rwsr-xr-x (注意s位)

# 移除特殊权限
chmod u-s file  # 移除SUID
chmod g-s file  # 移除SGID
chmod -t dir    # 移除Sticky Bit
```

### 5.3 访问控制列表（ACL）

```bash
# 查看ACL权限
getfacl file.txt

# 设置用户ACL权限
setfacl -m u:username:rwx file.txt

# 设置组ACL权限
setfacl -m g:groupname:rw file.txt

# 设置默认ACL（目录）
setfacl -d -m u:username:rwx directory/

# 递归设置ACL
setfacl -R -m u:username:rwx directory/

# 删除特定ACL
setfacl -x u:username file.txt

# 删除所有ACL
setfacl -b file.txt

# 复制ACL
getfacl file1.txt | setfacl --set-file=- file2.txt

# ACL示例
# 允许特定用户读写，但不影响其他权限设置
setfacl -m u:alice:rw- /data/shared_file
setfacl -m u:bob:r-- /data/shared_file
```

### 5.4 sudo 权限配置

编辑 `/etc/sudoers` 文件：

```bash
# 使用 visudo 命令安全编辑（会检查语法）
sudo visudo

# 基本语法
# user host=(runas) commands

# 配置示例
username ALL=(ALL:ALL) ALL              # 完全权限
username ALL=(ALL) NOPASSWD: ALL        # 无需密码
username ALL=(ALL) NOPASSWD: /usr/bin/apt-get  # 仅特定命令
username ALL=(root) /usr/bin/systemctl  # 只能以root身份运行

# 组配置
%groupname ALL=(ALL:ALL) ALL            # 组权限
%sudo ALL=(ALL:ALL) ALL                 # sudo组成员

# 限制特定命令
username ALL=/usr/bin/systemctl restart nginx
username ALL=/usr/bin/apt-get update, /usr/bin/apt-get upgrade

# 命令别名
Cmnd_Alias NETWORKING = /sbin/route, /sbin/ifconfig, /bin/ping
username ALL=NETWORKING

# 用户别名
User_Alias ADMINS = john, alice, bob
ADMINS ALL=(ALL) ALL

# 主机别名
Host_Alias SERVERS = server1, server2
username SERVERS=(ALL) ALL

# 不需要密码的命令
username ALL=(ALL) NOPASSWD: /usr/bin/systemctl status *
username ALL=(ALL) PASSWD: /usr/bin/systemctl restart *

# 禁止特定命令
username ALL=(ALL) ALL, !/bin/su, !/usr/bin/passwd root

# 使用sudo配置文件（推荐）
# 在 /etc/sudoers.d/ 目录创建配置文件
sudo visudo -f /etc/sudoers.d/username
```

**sudo使用技巧：**

```bash
# 查看sudo权限
sudo -l

# 以特定用户身份执行
sudo -u username command

# 保持环境变量
sudo -E command

# 编辑文件（使用默认编辑器）
sudoedit /etc/config

# 切换到root shell
sudo -i    # 登录shell（加载root环境）
sudo -s    # 非登录shell（保持当前环境）

# 更新sudo时间戳
sudo -v

# 清除sudo时间戳
sudo -k

# 查看sudo日志
sudo cat /var/log/auth.log | grep sudo
sudo journalctl -u sudo
```

### 5.5 能力（Capabilities）

Linux能力机制允许细粒度地授予特权，而不需要完整的root权限：

```bash
# 查看文件能力
getcap /usr/bin/ping

# 设置能力
sudo setcap cap_net_raw+ep /usr/bin/ping

# 常用能力
# cap_net_raw      - 使用RAW和PACKET套接字
# cap_net_admin    - 网络管理操作
# cap_sys_admin    - 系统管理操作
# cap_dac_override - 忽略文件读写执行权限检查

# 移除能力
sudo setcap -r /usr/bin/ping

# 查看进程能力
cat /proc/$PID/status | grep Cap
getpcaps $PID
```

## 六、实用管理技巧

### 6.1 批量创建用户

```bash
#!/bin/bash
# 批量创建用户脚本

# 方法1: 简单循环
for i in {1..10}
do
    username="user$i"
    sudo useradd -m -s /bin/bash $username
    echo "$username:password$i" | sudo chpasswd
    echo "Created user: $username"
done

# 方法2: 从文件读取
# users.txt 格式: username:password:fullname
while IFS=: read -r username password fullname
do
    sudo useradd -m -c "$fullname" -s /bin/bash "$username"
    echo "$username:$password" | sudo chpasswd
    echo "Created user: $username"
done < users.txt

# 方法3: 使用newusers命令批量创建
# users.txt 格式符合 /etc/passwd 格式
sudo newusers users.txt

# 方法4: 生成随机密码
for i in {1..10}
do
    username="user$i"
    password=$(openssl rand -base64 12)
    sudo useradd -m -s /bin/bash $username
    echo "$username:$password" | sudo chpasswd
    echo "User: $username, Password: $password" >> user_credentials.txt
    echo "Created user: $username"
done
```

### 6.2 批量删除用户

```bash
#!/bin/bash
# 批量删除用户脚本

# 从文件读取用户列表
while read username
do
    if id "$username" &>/dev/null; then
        sudo userdel -r "$username"
        echo "Deleted user: $username"
    else
        echo "User $username does not exist"
    fi
done < users_to_delete.txt

# 删除特定范围的用户
for i in {1..10}
do
    username="user$i"
    sudo userdel -r "$username" 2>/dev/null && echo "Deleted: $username"
done

# 删除非活跃用户（超过90天未登录）
lastlog | awk '$NF ~ /Never/ || $NF ~ /\*\*Never/ {print $1}' | while read user
do
    if [ "$user" != "Username" ] && [ "$user" != "root" ]; then
        echo "Inactive user: $user"
        # sudo userdel -r "$user"  # 取消注释以执行删除
    fi
done
```

### 6.3 用户信息查询

```bash
# 查看所有普通用户
awk -F: '$3>=1000 && $3<60000 {print $1}' /etc/passwd

# 查看所有系统用户
awk -F: '$3>0 && $3<1000 {print $1}' /etc/passwd

# 查看有登录shell的用户
grep -v '/nologin\|/false' /etc/passwd | cut -d: -f1

# 查看当前登录用户
users
who
w

# 查看用户登录历史
last
last -10          # 最近10次
last username     # 特定用户
last -f /var/log/wtmp.1  # 查看旧日志

# 查看失败登录
sudo lastb
sudo lastb -10

# 查看用户最后登录时间
lastlog
lastlog -u username
lastlog -t 30    # 最近30天内登录的用户

# 查看用户详细信息
finger username  # 需要安装finger
chage -l username  # 密码过期信息
sudo passwd -S username  # 密码状态

# 查看用户占用磁盘空间
du -sh /home/username
sudo du -sh /home/* | sort -h

# 查看用户进程
ps -u username
pgrep -u username
top -u username

# 查看用户打开的文件
lsof -u username

# 统计用户数量
wc -l /etc/passwd
awk -F: '$3>=1000 && $3<60000' /etc/passwd | wc -l  # 普通用户数
```

### 6.4 用户环境配置

```bash
# ============ 全局配置文件 ============
/etc/profile           # 所有用户登录时执行（login shell）
/etc/bash.bashrc      # 所有用户bash配置（non-login shell）
/etc/bashrc           # RHEL/CentOS的bash配置
/etc/environment      # 系统环境变量（不是shell脚本）
/etc/profile.d/       # 自定义全局脚本目录

# ============ 用户配置文件 ============
~/.profile            # 用户登录配置（login shell）
~/.bash_profile       # bash登录配置（login shell，优先级高）
~/.bashrc            # bash配置（non-login、interactive shell）
~/.bash_logout       # 注销时执行
~/.bash_history      # 命令历史

# ============ 配置文件加载顺序 ============
# Login Shell (如SSH登录):
# /etc/profile → ~/.bash_profile → ~/.bash_login → ~/.profile

# Non-login Shell (如终端窗口):
# /etc/bash.bashrc → ~/.bashrc

# ============ 常用环境变量 ============
# 编辑 ~/.bashrc 或 ~/.profile

# 设置PATH
export PATH="$HOME/bin:$PATH"

# 设置别名
alias ll='ls -lah'
alias update='sudo apt update && sudo apt upgrade'

# 设置环境变量
export EDITOR=vim
export LANG=en_US.UTF-8
export HISTSIZE=10000
export HISTFILESIZE=20000

# 自定义提示符
export PS1='\u@\h:\w\$ '

# 应用配置（无需重新登录）
source ~/.bashrc
```

### 6.5 用户资源限制

```bash
# 查看当前限制
ulimit -a

# 编辑 /etc/security/limits.conf
sudo vim /etc/security/limits.conf

# 配置示例
# <domain> <type> <item> <value>
username soft nofile 4096        # 软限制：最大打开文件数
username hard nofile 8192        # 硬限制：最大打开文件数
username soft nproc 1024         # 最大进程数
username hard nproc 2048
@groupname soft cpu 60           # CPU时间限制（分钟）
@groupname hard cpu 120
* soft core 0                    # 禁用core dump
* hard rss 10000                 # 最大内存（KB）

# 常用限制项
# nofile   - 打开文件数
# nproc    - 进程数
# cpu      - CPU时间（分钟）
# maxlogins - 最大登录数
# priority  - 优先级
# locks    - 文件锁数量
# memlock  - 锁定内存大小
# rss      - 最大内存（KB）
# fsize    - 文件大小（KB）

# 查看特定用户限制
su - username -c "ulimit -a"

# 临时设置限制（当前shell）
ulimit -n 4096    # 设置打开文件数
ulimit -u 2048    # 设置最大进程数
ulimit -c unlimited  # 允许core dump

# 使用systemd设置服务资源限制
# 编辑 /etc/systemd/system/service.service.d/limits.conf
[Service]
LimitNOFILE=8192
LimitNPROC=4096
```

### 6.6 用户磁盘配额（Quota）

```bash
# ============ 安装配额工具 ============
sudo apt install quota quotatool  # Debian/Ubuntu
sudo yum install quota             # RHEL/CentOS

# ============ 启用文件系统配额支持 ============
# 编辑 /etc/fstab，添加 usrquota,grpquota
/dev/sda1 /home ext4 defaults,usrquota,grpquota 0 2

# 重新挂载文件系统
sudo mount -o remount /home

# 创建配额文件
sudo quotacheck -cugm /home
# -c: create 创建配额文件
# -u: user quota 用户配额
# -g: group quota 组配额  
# -m: 不重新挂载为只读

# 启用配额
sudo quotaon /home

# ============ 设置用户配额 ============
# 编辑用户配额
sudo edquota -u username

# 配额文件格式示例：
# Filesystem  blocks  soft    hard    inodes  soft  hard
# /dev/sda1   1000    900000  1000000 100     0     0
# blocks: 当前使用的块数（KB）
# soft: 软限制（可临时超过）
# hard: 硬限制（绝对不能超过）
# inodes: 文件数量

# 设置宽限期（grace period）
sudo edquota -t
# 用户可以在宽限期内超过软限制

# 快速设置配额
sudo setquota -u username 900000 1000000 0 0 /home
# 格式: setquota -u user block_soft block_hard inode_soft inode_hard filesystem

# 复制配额设置
sudo edquota -p template_user -u newuser

# ============ 设置组配额 ============
sudo edquota -g groupname
sudo setquota -g groupname 5000000 6000000 0 0 /home

# ============ 查看配额 ============
# 查看用户配额
quota -u username
sudo repquota -a         # 所有用户配额报告
sudo repquota -u /home   # 特定文件系统

# 查看组配额
quota -g groupname
sudo repquota -g /home

# 查看配额统计
sudo quotastats

# ============ 配额警告和通知 ============
# 编写配额检查脚本
#!/bin/bash
# quota_check.sh
for user in $(awk -F: '$3>=1000 && $3<60000 {print $1}' /etc/passwd)
do
    quota_info=$(quota -u $user 2>/dev/null)
    if echo "$quota_info" | grep -q "exceeded"; then
        echo "Warning: User $user has exceeded quota"
        # 发送邮件通知
        # mail -s "Quota Warning" $user@domain.com <<< "$quota_info"
    fi
done

# 定时执行（添加到crontab）
# 0 9 * * * /usr/local/bin/quota_check.sh

# ============ 禁用和关闭配额 ============
sudo quotaoff /home      # 关闭配额
sudo quotaoff -a         # 关闭所有配额
```

### 6.7 用户会话管理

```bash
# ============ 查看用户会话 ============
# 查看当前登录会话
who
w
who -a                   # 详细信息
users                    # 简单列表

# 查看登录详情
loginctl list-sessions   # systemd管理的会话
loginctl show-session SESSION_ID

# 查看用户所有会话
loginctl user-status username

# ============ 管理用户会话 ============
# 终止用户会话
sudo loginctl terminate-session SESSION_ID
sudo loginctl kill-session SESSION_ID

# 终止用户所有会话
sudo loginctl terminate-user username
sudo loginctl kill-user username

# 锁定用户会话
sudo loginctl lock-session SESSION_ID

# 解锁用户会话
sudo loginctl unlock-session SESSION_ID

# ============ 踢出在线用户 ============
# 方法1: 使用pkill
sudo pkill -u username
sudo pkill -KILL -u username  # 强制终止

# 方法2: 使用killall
sudo killall -u username

# 方法3: 终止特定终端
sudo pkill -t pts/0          # 终止pts/0终端

# 方法4: 使用skill命令
sudo skill -KILL -u username

# ============ 限制用户登录 ============
# 创建 /etc/nologin 文件阻止普通用户登录
sudo touch /etc/nologin
echo "System maintenance in progress" | sudo tee /etc/nologin

# 删除该文件恢复登录
sudo rm /etc/nologin

# 针对特定用户禁止登录
sudo usermod -s /usr/sbin/nologin username

# 使用pam_access限制登录
# 编辑 /etc/security/access.conf
-:username:ALL EXCEPT LOCAL    # 仅允许本地登录
-:username:ALL                  # 完全禁止登录
+:admin:ALL                     # 允许admin所有方式登录

# 限制SSH登录
# 编辑 /etc/ssh/sshd_config
DenyUsers username
AllowUsers admin user1 user2
DenyGroups groupname
AllowGroups sudo admin

# 重启SSH服务
sudo systemctl restart sshd

# ============ 会话超时设置 ============
# 设置shell超时（添加到/etc/profile或~/.bashrc）
export TMOUT=600    # 600秒(10分钟)无操作自动登出

# SSH会话超时（编辑/etc/ssh/sshd_config）
ClientAliveInterval 300      # 每300秒检查一次
ClientAliveCountMax 2        # 2次无响应断开连接
```

## 七、安全最佳实践

### 7.1 密码策略

```bash
# ============ 安装密码复杂度检查工具 ============
sudo apt-get install libpam-pwquality  # Debian/Ubuntu
sudo yum install libpwquality          # RHEL/CentOS

# ============ 配置密码复杂度 ============
# 编辑 /etc/security/pwquality.conf
minlen = 12          # 最小长度12个字符
minclass = 3         # 至少包含3种字符类型
dcredit = -1         # 至少1个数字 (负数表示至少)
ucredit = -1         # 至少1个大写字母
lcredit = -1         # 至少1个小写字母
ocredit = -1         # 至少1个特殊字符
maxrepeat = 3        # 最多3个连续相同字符
maxclassrepeat = 4   # 同类字符最多连续4个
gecoscheck = 1       # 检查密码是否包含GECOS字段
dictcheck = 1        # 检查字典单词
usercheck = 1        # 检查是否包含用户名
enforcing = 1        # 强制执行（1=是, 0=否）
retry = 3            # 允许重试次数

# ============ 配置PAM密码策略 ============
# 编辑 /etc/pam.d/common-password (Debian/Ubuntu)
# 或 /etc/pam.d/system-auth (RHEL/CentOS)

# 密码复杂度
password requisite pam_pwquality.so retry=3

# 密码历史（防止重用旧密码）
password required pam_unix.so remember=5 use_authtok sha512

# 密码最小使用天数
password required pam_unix.so mindays=1

# ============ 配置密码过期策略 ============
# 编辑 /etc/login.defs
PASS_MAX_DAYS   90       # 密码最长有效期90天
PASS_MIN_DAYS   7        # 密码最短使用期7天
PASS_MIN_LEN    12       # 密码最小长度
PASS_WARN_AGE   14       # 过期前14天警告

# 对现有用户应用密码策略
sudo chage -M 90 -m 7 -W 14 username

# 批量设置所有用户
for user in $(awk -F: '$3>=1000 && $3<60000 {print $1}' /etc/passwd)
do
    sudo chage -M 90 -m 7 -W 14 $user
done

# ============ 强制密码定期更改 ============
# 查看密码状态
sudo chage -l username

# 强制下次登录修改密码
sudo chage -d 0 username

# 设置密码永不过期（不推荐）
sudo chage -M -1 username

# ============ 生成强密码 ============
# 使用pwgen生成密码
pwgen -s 16 1            # 16位强密码

# 使用openssl生成密码
openssl rand -base64 16

# 使用/dev/urandom生成密码
tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 16
```

### 7.2 账户安全

```bash
# ============ 账户锁定策略 ============
# 配置登录失败锁定（编辑/etc/pam.d/common-auth）
auth required pam_faillock.so preauth silent audit deny=5 unlock_time=900
auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900
account required pam_faillock.so
# deny=5: 5次失败后锁定
# unlock_time=900: 900秒(15分钟)后自动解锁

# 查看失败登录记录
sudo faillock --user username

# 解锁用户
sudo faillock --user username --reset

# ============ 密码尝试延迟 ============
# 编辑 /etc/pam.d/common-auth
auth optional pam_faildelay.so delay=4000000
# 延迟4秒(4000000微秒)

# ============ 禁用空密码 ============
# 编辑 /etc/pam.d/common-auth，移除 nullok 选项
auth [success=1 default=ignore] pam_unix.so nullok_secure
# 改为:
auth [success=1 default=ignore] pam_unix.so

# ============ 限制su命令 ============
# 编辑 /etc/pam.d/su
auth required pam_wheel.so use_uid
# 只有wheel组成员可以使用su

# 将用户添加到wheel组
sudo usermod -aG wheel username

# ============ 账户过期管理 ============
# 设置账户过期日期
sudo chage -E 2024-12-31 username

# 设置密码过期后宽限期
sudo chage -I 30 username  # 30天宽限期

# 查看即将过期的账户
awk -F: '$3>=1000 && $3<60000 {print $1}' /etc/passwd | while read user
do
    expire_date=$(sudo chage -l $user | grep "Account expires" | cut -d: -f2)
    if [ "$expire_date" != " never" ]; then
        echo "User: $user, Expires: $expire_date"
    fi
done

# ============ 删除或禁用未使用的账户 ============
# 查找长期未登录的账户（超过90天）
lastlog -b 90 | tail -n +2 | awk '{print $1}'

# 锁定未使用账户
for user in $(lastlog -b 90 | tail -n +2 | awk '{print $1}')
do
    if [ "$user" != "root" ]; then
        sudo usermod -L $user
        echo "Locked inactive user: $user"
    fi
done

# ============ 双因素认证（2FA） ============
# 安装Google Authenticator
sudo apt install libpam-google-authenticator

# 用户配置2FA
google-authenticator
# 按提示操作，扫描二维码

# 配置PAM（编辑/etc/pam.d/sshd）
auth required pam_google_authenticator.so

# 配置SSH（编辑/etc/ssh/sshd_config）
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive

# 重启SSH
sudo systemctl restart sshd
```

### 7.3 SSH安全配置

```bash
# 编辑 /etc/ssh/sshd_config

# ============ 基本安全设置 ============
Port 2222                          # 修改默认端口
PermitRootLogin no                 # 禁止root登录
PasswordAuthentication no          # 禁用密码登录（推荐使用密钥）
PubkeyAuthentication yes          # 启用公钥认证
PermitEmptyPasswords no           # 禁止空密码
MaxAuthTries 3                    # 最多尝试3次
MaxSessions 3                     # 最多3个会话

# ============ 限制用户和组 ============
AllowUsers admin user1 user2      # 只允许特定用户
DenyUsers baduser                 # 禁止特定用户
AllowGroups sshusers admin        # 只允许特定组

# ============ 网络安全 ============
ListenAddress 192.168.1.10        # 仅监听特定IP
AddressFamily inet                # 仅IPv4（或inet6仅IPv6）

# ============ 会话超时 ============
ClientAliveInterval 300           # 5分钟检查一次
ClientAliveCountMax 2             # 2次无响应断开

# ============ 登录限制 ============
LoginGraceTime 60                 # 60秒内必须完成认证
MaxStartups 10:30:60              # 限制并发未认证连接

# ============ 其他安全选项 ============
X11Forwarding no                  # 禁用X11转发
AllowTcpForwarding no            # 禁用TCP转发
PermitTunnel no                   # 禁用隧道
GatewayPorts no                   # 禁用网关端口
PrintLastLog yes                  # 显示上次登录信息

# 重启SSH服务
sudo systemctl restart sshd

# ============ SSH密钥认证 ============
# 生成SSH密钥对
ssh-keygen -t ed25519 -C "user@host"
# 或使用RSA（4096位）
ssh-keygen -t rsa -b 4096 -C "user@host"

# 复制公钥到服务器
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server

# 手动添加公钥
cat ~/.ssh/id_ed25519.pub | ssh user@server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# 设置正确权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# ============ SSH登录通知 ============
# 创建登录通知脚本 /etc/profile.d/ssh-notify.sh
#!/bin/bash
if [ -n "$SSH_CLIENT" ]; then
    IP=$(echo $SSH_CLIENT | awk '{print $1}')
    TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "SSH login from $IP at $TIME" | mail -s "SSH Login Alert" admin@example.com
fi

# ============ fail2ban防护 ============
# 安装fail2ban
sudo apt install fail2ban

# 配置 /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3              # 3次失败后封禁
bantime = 3600            # 封禁1小时
findtime = 600            # 10分钟内

# 启动fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 查看fail2ban状态
sudo fail2ban-client status sshd

# 解封IP
sudo fail2ban-client set sshd unbanip 192.168.1.100
```

### 7.4 监控和审计

```bash
# ============ 审计系统（auditd） ============
# 安装auditd
sudo apt install auditd audispd-plugins

# 启动auditd
sudo systemctl enable auditd
sudo systemctl start auditd

# 监控用户账户变更
sudo auditctl -w /etc/passwd -p wa -k passwd_changes
sudo auditctl -w /etc/shadow -p wa -k shadow_changes
sudo auditctl -w /etc/group -p wa -k group_changes
sudo auditctl -w /etc/gshadow -p wa -k gshadow_changes

# 监控sudo使用
sudo auditctl -w /etc/sudoers -p wa -k sudoers_changes
sudo auditctl -w /var/log/sudo.log -p wa -k sudo_log_changes

# 监控用户登录
sudo auditctl -w /var/log/lastlog -p wa -k lastlog_changes

# 查看审计规则
sudo auditctl -l

# 搜索审计日志
sudo ausearch -k passwd_changes
sudo ausearch -ua username          # 特定用户
sudo ausearch -ts today -k sudo     # 今天的sudo活动

# 生成审计报告
sudo aureport --auth                # 认证报告
sudo aureport --login               # 登录报告
sudo aureport --user                # 用户报告
sudo aureport --failed              # 失败事件
sudo aureport -ts today --summary   # 今日摘要

# ============ 日志监控 ============
# 查看认证日志
sudo tail -f /var/log/auth.log      # Debian/Ubuntu
sudo tail -f /var/log/secure        # RHEL/CentOS

# 查看sudo日志
sudo grep sudo /var/log/auth.log

# 查看失败登录
sudo grep "Failed password" /var/log/auth.log

# 查看成功登录
sudo grep "Accepted" /var/log/auth.log

# 使用journalctl查看systemd日志
sudo journalctl -u sshd             # SSH日志
sudo journalctl -u sudo             # sudo日志
sudo journalctl --since "1 hour ago" | grep -i failed

# ============ 实时监控脚本 ============
#!/bin/bash
# security_monitor.sh - 实时安全监控

# 监控新用户创建
inotifywait -m /etc/passwd -e modify |
while read path action file; do
    echo "[$(date)] User account modified"
    tail -1 /etc/passwd | mail -s "New User Alert" admin@example.com
done &

# 监控失败登录
tail -f /var/log/auth.log | grep --line-buffered "Failed password" |
while read line; do
    echo "[$(date)] Failed login: $line"
    # 发送告警
done &

# 监控sudo使用
tail -f /var/log/auth.log | grep --line-buffered "sudo:" |
while read line; do
    echo "[$(date)] Sudo usage: $line"
done &

# ============ 定期安全检查脚本 ============
#!/bin/bash
# daily_security_check.sh

# 检查无密码账户
echo "=== Users without password ==="
sudo awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow

# 检查UID为0的账户（应该只有root）
echo "=== Users with UID 0 ==="
awk -F: '$3 == 0 {print $1}' /etc/passwd

# 检查空密码账户
echo "=== Empty password accounts ==="
sudo awk -F: '($2 == "") {print $1}' /etc/shadow

# 检查可登录的系统账户
echo "=== System accounts with login shell ==="
awk -F: '($3 < 1000 && $7 != "/sbin/nologin" && $7 != "/bin/false") {print $1, $7}' /etc/passwd

# 检查sudo权限
echo "=== Sudo access ==="
sudo grep -v '^#' /etc/sudoers | grep -v '^

# 检查最近的失败登录
echo "=== Recent failed logins ==="
sudo lastb -10

# 检查SUID/SGID文件
echo "=== SUID/SGID files (new ones) ==="
find / -type f \( -perm -4000 -o -perm -2000 \) -ls 2>/dev/null

# 添加到crontab每日执行
# 0 2 * * * /usr/local/bin/daily_security_check.sh | mail -s "Daily Security Report" admin@example.com
```

### 7.5 文件完整性监控

```bash
# ============ AIDE (Advanced Intrusion Detection Environment) ============
# 安装AIDE
sudo apt install aide

# 初始化数据库
sudo aideinit
sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# 检查文件完整性
sudo aide --check

# 更新数据库
sudo aide --update
sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# 配置AIDE（/etc/aide/aide.conf）
# 添加要监控的目录
/etc p+i+u+g+sha512
/bin p+i+u+g+sha512
/sbin p+i+u+g+sha512
/usr/bin p+i+u+g+sha512

# 定期检查（添加到crontab）
# 0 3 * * * /usr/bin/aide --check | mail -s "AIDE Report" admin@example.com

# ============ Tripwire替代方案 ============
# 使用inotify实时监控
sudo apt install inotify-tools

# 监控脚本
#!/bin/bash
inotifywait -m -r -e modify,create,delete,move /etc |
while read path action file; do
    echo "[$(date)] $action on $path$file" >> /var/log/file_monitor.log
done
```

## 八、常见问题处理

### 8.1 忘记密码

```bash
# ============ 以root身份重置用户密码 ============
sudo passwd username

# ============ 忘记root密码（单用户模式）============
# 方法1: GRUB启动（Ubuntu/Debian）
# 1. 重启系统
# 2. 在GRUB菜单按'e'编辑启动项
# 3. 找到以'linux'开头的行
# 4. 在行末添加: init=/bin/bash
# 或添加: single 或 1 或 s
# 5. 按Ctrl+X启动
# 6. 执行以下命令:
mount -o remount,rw /
passwd root
exec /sbin/init  # 或 reboot

# 方法2: 使用救援模式（CentOS/RHEL）
# 1. 重启系统按'e'编辑GRUB
# 2. 找到'linux'或'linux16'行
# 3. 将 'ro' 改为 'rw init=/sysroot/bin/bash'
# 4. 按Ctrl+X启动
# 5. 执行:
chroot /sysroot
passwd root
touch /.autorelabel  # SELinux系统需要
exit
reboot

# 方法3: 使用LiveCD/USB
# 1. 使用Live系统启动
# 2. 挂载根分区
sudo mkdir /mnt/root
sudo mount /dev/sda1 /mnt/root
# 3. chroot到系统
sudo chroot /mnt/root
# 4. 重置密码
passwd root
# 5. 退出并重启
exit
sudo umount /mnt/root
sudo reboot
```

### 8.2 用户无法登录

```bash
# ============ 诊断步骤 ============

# 1. 检查账户状态
sudo passwd -S username
# 输出: PS (正常), L (锁定), NP (无密码)

# 2. 检查账户是否过期
sudo chage -l username

# 3. 检查shell设置
grep username /etc/passwd
# 确认shell不是/sbin/nologin或/bin/false

# 4. 检查家目录
ls -ld /home/username
# 权限应该是 drwx------ username username

# 5. 修复家目录权限
sudo chown -R username:username /home/username
sudo chmod 700 /home/username
sudo chmod 644 /home/username/.bashrc

# 6. 检查PAM配置
cat /etc/pam.d/common-auth
cat /etc/pam.d/sshd

# 7. 检查SSH配置（如果是SSH登录）
sudo sshd -T | grep -i allowusers
sudo sshd -T | grep -i denyusers

# 8. 查看认证日志
sudo tail -50 /var/log/auth.log | grep username

# 9. 检查faillock状态
sudo faillock --user username
# 如果被锁定，解锁:
sudo faillock --user username --reset

# 10. 测试登录
sudo -u username -i
# 查看是否有错误信息

# ============ 常见问题修复 ============

# 账户被锁定
sudo usermod -U username
sudo passwd -u username

# 账户过期
sudo chage -E -1 username  # 永不过期

# 密码过期
sudo chage -M 99999 username  # 延长过期时间
sudo passwd -e username       # 强制下次登录修改

# Shell问题
sudo usermod -s /bin/bash username

# SSH密钥权限问题
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# SELinux导致问题（RHEL/CentOS）
sudo restorecon -R /home/username
sudo setenforce 0  # 临时禁用SELinux测试
```

### 8.3 用户权限问题

```bash
# ============ sudo权限不工作 ============

# 检查用户是否在sudo组
groups username
id username

# 添加用户到sudo组
sudo usermod -aG sudo username      # Debian/Ubuntu
sudo usermod -aG wheel username     # RHEL/CentOS

# 检查sudoers配置
sudo visudo
# 确认有以下行:
%sudo ALL=(ALL:ALL) ALL          # Debian/Ubuntu
%wheel ALL=(ALL) ALL             # RHEL/CentOS

# 检查sudoers语法
sudo visudo -c

# 查看用户sudo权限
sudo -l -U username

# ============ 文件权限问题 ============

# 修复用户家目录权限
sudo chown -R username:username /home/username
find /home/username -type d -exec chmod 755 {} \;
find /home/username -type f -exec chmod 644 {} \;

# 修复特殊权限
chmod 700 /home/username
chmod 600 /home/username/.ssh/authorized_keys
chmod 600 /home/username/.bash_history

# 检查文件所有权
find /home/username ! -user username

# 批量修复所有权
sudo find /home/username ! -user username -exec chown username:username {} \;

# ============ 组权限问题 ============

# 刷新用户组成员身份（无需重新登录）
newgrp groupname

# 或者重新登录
su - username

# 检查有效组
id
groups

# ============ ACL权限问题 ============

# 检查ACL
getfacl /path/to/file

# 删除所有ACL
setfacl -b /path/to/file

# 恢复默认权限
setfacl --remove-all /path/to/file
```

### 8.4 用户环境问题

```bash
# ============ PATH环境变量丢失 ============

# 临时修复
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# 永久修复（添加到~/.bashrc）
echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' >> ~/.bashrc
source ~/.bashrc

# ============ .bashrc或.profile损坏 ============

# 从模板恢复
cp /etc/skel/.bashrc ~/.bashrc
cp /etc/skel/.profile ~/.profile

# 或手动创建最小配置
cat > ~/.bashrc << 'EOF'
# Basic .bashrc
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PS1='\u@\h:\w\$ '
alias ls='ls --color=auto'
alias ll='ls -lah'
EOF

# ============ 终端显示异常 ============

# 重置终端
reset
tput reset

# 修复终端设置
export TERM=xterm-256color

# 清除终端
clear
Ctrl+L

# ============ 语言环境问题 ============

# 查看当前locale
locale

# 设置locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 永久设置（添加到~/.bashrc）
echo 'export LANG=en_US.UTF-8' >> ~/.bashrc

# 生成locale（如果缺失）
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

### 8.5 磁盘配额问题

```bash
# ============ 用户超出磁盘配额 ============

# 查看用户配额使用情况
quota -u username
sudo repquota -u /home

# 临时增加配额
sudo setquota -u username 1000000 1200000 0 0 /home

# 清理用户文件
sudo du -sh /home/username/*
sudo find /home/username -type f -size +100M

# ============ 配额数据库损坏 ============

# 关闭配额
sudo quotaoff -a

# 重建配额数据库
sudo quotacheck -cugm /home

# 启用配额
sudo quotaon /home

# ============ 配额未生效 ============

# 检查文件系统挂载选项
mount | grep home

# 确认包含 usrquota,grpquota
# 如果没有，编辑/etc/fstab并重新挂载
sudo mount -o remount /home
```

### 8.6 批量操作故障排除

```bash
# ============ 批量创建用户失败 ============

# 逐个检查创建日志
#!/bin/bash
LOG_FILE="/var/log/user_creation.log"

while IFS=: read -r username password fullname
do
    if id "$username" &>/dev/null; then
        echo "[SKIP] User $username already exists" | tee -a $LOG_FILE
    else
        if sudo useradd -m -c "$fullname" -s /bin/bash "$username" 2>>$LOG_FILE; then
            echo "$username:$password" | sudo chpasswd 2>>$LOG_FILE
            if [ $? -eq 0 ]; then
                echo "[OK] Created user: $username" | tee -a $LOG_FILE
            else
                echo "[ERROR] Failed to set password for: $username" | tee -a $LOG_FILE
            fi
        else
            echo "[ERROR] Failed to create user: $username" | tee -a $LOG_FILE
        fi
    fi
done < users.txt

# ============ 清理失败的用户创建 ============

# 查找没有家目录的用户
awk -F: '$3>=1000 && $3<60000 {print $1":"$6}' /etc/passwd | while IFS=: read user homedir
do
    if [ ! -d "$homedir" ]; then
        echo "Missing home: $user ($homedir)"
        # sudo userdel $user  # 取消注释以删除
    fi
done

# 查找孤立的家目录（用户不存在）
for homedir in /home/*
do
    username=$(basename $homedir)
    if ! id "$username" &>/dev/null; then
        echo "Orphaned home directory: $homedir"
        # sudo rm -rf $homedir  # 取消注释以删除
    fi
done
```


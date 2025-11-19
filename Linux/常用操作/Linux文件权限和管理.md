# Linux文件和目录权限完整指南

## 一、权限基础概念

### 1. 三种用户类型
```
Owner (u)   - 文件所有者
Group (g)   - 所属组
Others (o)  - 其他用户
```

### 2. 三种基本权限
```
Read (r)    - 读权限    - 数值 4
Write (w)   - 写权限    - 数值 2
Execute (x) - 执行权限  - 数值 1
```

### 3. 权限组合速查表
| 权限 | 符号 | 数值 | 含义 |
|------|------|------|------|
| 读 | r | 4 | 阅读文件或列出目录内容 |
| 写 | w | 2 | 修改文件或在目录中创建/删除文件 |
| 执行 | x | 1 | 执行文件或进入目录 |
| 无权限 | - | 0 | 没有任何权限 |

## 二、查看权限

### 使用 ls -l 命令

```bash
ls -l filename
```

**输出示例：**

```bash
-rw-r--r-- 1 user group 1024 Jan 1 10:00 file.txt
```

#### 各字段含义

| 字段        | 示例            | 说明                   |
| --------- | ------------- | -------------------- |
| 文件类型 + 权限 | `-rw-r--r--`  | 10 个字符（1个类型 + 9个权限位） |
| 硬链接数      | `1`           | 硬链接的数量               |
| 所有者       | `user`        | 文件拥有者                |
| 所属组       | `group`       | 文件所属的用户组             |
| 文件大小      | `1024`        | 字节数                  |
| 修改时间      | `Jan 1 10:00` | 最后修改日期和时间            |
| 文件名       | `file.txt`    | 文件名称                 |

---

### 权限位详解

```
 ┌─ 所有者权限（前3位）
 │  ┌─ 组权限（中3位）
 │  │  ┌─ 其他人权限（后3位）
-rw-r--r--
 └┬┘└┬┘└┬┘
  │  │  │
  │  │  └─ 其他人: r--(读，无写，无执行)
  │  └─────── 组: r--(读，无写，无执行)
  └──────────── 所有者: rw-(读，写，无执行)
```

---

### 文件类型标识（第一个字符）

|符号|类型|
|---|---|
|`-`|普通文件|
|`d`|目录|
|`l`|符号链接|
|`b`|块设备文件|
|`c`|字符设备文件|
|`s`|套接字文件|
|`p`|管道文件|

---

### 快速参考示例

| 权限          | 八进制 | 说明            |
| ----------- | --- | ------------- |
| `rwx------` | 700 | 仅所有者有完全权限     |
| `rwxr-xr-x` | 755 | 所有者全权，他人可读可执行 |
| `rw-r--r--` | 644 | 所有者可读写，他人只读   |
| `rwxrwxrwx` | 777 | 所有人有完全权限      |
## 三、权限详解

### 1. 文件权限含义
```bash
r (read)    - 可以读取文件内容
w (write)   - 可以修改文件内容
x (execute) - 可以执行文件（脚本或二进制程序）
```

### 2. 目录权限含义
```bash
r (read)    - 可以列出目录内容（ls）
w (write)   - 可以在目录中创建、删除、重命名文件
x (execute) - 可以进入目录（cd）并访问目录中的文件
```

注意：访问目录中的文件需要目录具有x权限。不同场景下目录权限的意义：

| 权限 | r | w | x | 说明 |
|------|---|---|---|------|
| r-- | ✓ | ✗ | ✗ | 只能列出目录内容，无法进入或修改 |
| -w- | ✗ | ✓ | ✗ | 无法进入或列出内容，也无法修改 |
| --x | ✗ | ✗ | ✓ | 可以进入目录，访问已知文件，但不能列出内容 |
| r-x | ✓ | ✗ | ✓ | 标准的只读目录权限 |
| rwx | ✓ | ✓ | ✓ | 完全权限 |

### 3. 权限示例对照

#### 文件权限示例
```bash
-rw-r--r--  # 644 - 所有者可读写，组和其他人只读（常见文件权限）
-rwxr-xr-x  # 755 - 所有者可读写执行，组和其他人可读执行（常见脚本权限）
-rw-------  # 600 - 只有所有者可读写（私密文件）
-r--r--r--  # 444 - 所有人只读（受保护文件）
-rwx------  # 700 - 只有所有者完全权限（私密脚本）
-rw-rw----  # 660 - 所有者和组可读写，其他人无权限
```

#### 目录权限示例
```bash
drwxr-xr-x  # 755 - 标准目录权限（所有者完全，组和其他人只读+执行）
drwx------  # 700 - 私有目录（只有所有者可访问）
drwxrwxrwx  # 777 - 完全开放的目录（不推荐生产环境使用）
drwxrwx---  # 770 - 所有者和组完全权限，其他人无权限
drwxr-x---  # 750 - 所有者完全，组可读执行，其他人无权限
```

## 四、权限管理命令

### 1. chmod - 修改权限

#### 符号模式
```bash
# 基本语法
chmod [ugoa][+-=][rwx] filename

# 参数说明：
# u - 所有者
# g - 组
# o - 其他人
# a - 所有用户（默认）
# + - 添加权限
# - - 移除权限
# = - 设置权限（覆盖现有权限）

# 示例
chmod u+x file.sh          # 给所有者添加执行权限
chmod g-w file.txt         # 移除组的写权限
chmod o=r file.txt         # 设置其他人只读
chmod a+r file.txt         # 给所有人添加读权限
chmod u+x,g+x file.sh      # 给所有者和组添加执行权限

# 复杂示例
chmod u=rwx,g=rx,o=r file  # 设置具体权限
chmod a= file              # 移除所有权限
chmod go= file             # 只保留所有者权限
```

#### 数字模式（推荐用于脚本）
```bash
# 权限数值计算法则：
# r=4, w=2, x=1
# 每位用户的权限数值 = 读权限 + 写权限 + 执行权限

# 单位数权限计算：
7 = 4+2+1 = rwx （所有权限）
6 = 4+2   = rw- （读写）
5 = 4+1   = r-x （读执行）
4 = 4     = r-- （只读）
3 = 2+1   = -wx （写执行）
2 = 2     = -w- （只写）
1 = 1     = --x （只执行）
0 = 0     = --- （无权限）

# 三位数权限示例
chmod 755 file.sh          # 所有者:rwx 组:r-x 其他:r-x
chmod 644 file.txt         # 所有者:rw- 组:r-- 其他:r--
chmod 600 private.txt      # 所有者:rw- 组:--- 其他:---
chmod 777 public.sh        # 所有者:rwx 组:rwx 其他:rwx (不推荐)
chmod 700 script.sh        # 所有者:rwx 组:--- 其他:---
chmod 750 config.sh        # 所有者:rwx 组:r-x 其他:---
chmod 440 readonly.txt     # 所有者:r-- 组:r-- 其他:---

# 递归修改
chmod -R 755 /path/to/dir  # 递归修改目录及其内容
chmod -R u+rwx,g-w /path   # 复杂递归修改

# 修改权限但保留执行权限
chmod a-x file && chmod u+x file  # 先移除所有执行权限，再给所有者添加
```

### 2. chown - 修改所有者和组

```bash
# 基本语法
chown [owner][:group] filename

# 修改所有者（需要root或sudo）
chown newowner file.txt

# 修改所有者和组
chown newowner:newgroup file.txt

# 只修改组（也可以用chgrp）
chown :newgroup file.txt

# 递归修改
chown -R user:group /path/to/dir

# 从其他文件复制权限
chown --reference=reference_file target_file

# 实际示例
chown www-data:www-data /var/www/html      # Web服务器文件
chown -R mysql:mysql /var/lib/mysql        # 数据库文件
chown root:root /etc/config.conf           # 系统配置文件
chown -R $(whoami):$(whoami) ~/project     # 改为当前用户
```

### 3. chgrp - 修改所属组

```bash
# 修改文件所属组
chgrp groupname file.txt

# 递归修改
chgrp -R groupname /path/to/dir

# 从其他文件复制组
chgrp --reference=reference_file target_file

# 示例
chgrp developers project.txt
chgrp -R developers /home/dev/project
```

### 4. umask - 默认权限设置

```bash
# 查看当前umask值
umask
# 输出: 0022

# 临时设置umask（仅当前会话）
umask 0027

# 永久设置umask（写入~/.bashrc或~/.bash_profile）
echo 'umask 0027' >> ~/.bashrc

# umask计算法则：
# 文件默认权限 = 666 - umask
# 目录默认权限 = 777 - umask

# 常见umask值
umask 0022  # 文件:644, 目录:755 （默认值，较开放）
umask 0027  # 文件:640, 目录:750 （推荐安全值）
umask 0077  # 文件:600, 目录:700 （最严格）
umask 0002  # 文件:664, 目录:775 （团队协作）

# umask详细计算示例
# umask 0022 时：
#   666(文件) - 022 = 644
#   777(目录) - 022 = 755

# umask 0027 时：
#   666(文件) - 027 = 640
#   777(目录) - 027 = 750
```

## 五、特殊权限（SUID、SGID、Sticky Bit）

### 1. SUID (Set User ID) - 4xxx

```bash
# 作用：
# 普通用户执行该文件时，以文件所有者（通常是root）的身份运行
# 可以让普通用户执行只有root才能执行的操作

# 标识：
# s 显示在所有者的执行权限位置（表示同时有执行权限和SUID）
# S 显示在所有者的执行权限位置（表示有SUID但无执行权限，不常见）

# 设置SUID
chmod u+s file              # 符号模式
chmod 4755 file             # 数字模式
chmod 4755 script.sh        # 4755 = SUID + rwxr-xr-x

# 移除SUID
chmod u-s file
chmod 755 file

# 查看SUID文件
ls -l /usr/bin/passwd       # 显示 -rwsr-xr-x
find / -perm /u+s -ls       # 查找所有SUID文件

# 典型应用
-rwsr-xr-x  # passwd命令允许普通用户修改自己的密码
-rwsr-xr-x  # sudo命令以root身份执行
-rwsr-xr-x  # ping命令可以发送网络包

# 安全风险
# SUID程序有安全隐患，应谨慎使用
# 定期检查SUID文件是否存在异常
```

### 2. SGID (Set Group ID) - 2xxx

```bash
# 作用：
# 文件：以文件所属组身份执行
# 目录：在该目录中创建的新文件会继承目录的所属组

# 标识：
# s 显示在组的执行权限位置
# S 表示有SGID但无执行权限

# 设置SGID
chmod g+s file_or_dir       # 符号模式
chmod 2755 dir              # 数字模式

# 移除SGID
chmod g-s file_or_dir
chmod 755 dir

# 文件上的SGID示例
-rwxr-sr-x  # 文件权限
# 普通用户执行时以所属组身份运行

# 目录上的SGID示例
drwxr-sr-x  # SGID位已设置

# 实际应用：共享目录
mkdir /shared
chmod 2775 /shared          # SGID + rwxrwxr-x
chgrp developers /shared    # 设置所属组

# 在该目录创建的文件自动属于developers组
# 即使创建文件的用户不是developers组成员

# 验证效果
cd /shared && touch test.txt
ls -l test.txt
# -rw-r--r-- 1 user developers ... test.txt （组为developers）
```

### 3. Sticky Bit（粘着位）- 1xxx

```bash
# 作用：
# 只有文件所有者和root可以删除或重命名文件
# 即使其他用户有目录的写权限也不能删除别人的文件

# 标识：
# t 显示在其他人的执行权限位置（表示同时有执行权限和粘着位）
# T 表示有粘着位但无执行权限

# 设置Sticky Bit
chmod +t directory          # 符号模式
chmod 1777 directory        # 数字模式

# 移除Sticky Bit
chmod -t directory
chmod 777 directory

# 目录示例
drwxrwxrwt  # Sticky bit已设置（1777）

# 典型应用：/tmp目录
ls -ld /tmp
# drwxrwxrwt 1 root root ... /tmp

# 作用机制
# /tmp目录权限为1777，所有用户都可以：
# - 读取目录内容
# - 写入（创建）文件
# - 执行（进入）目录
# 但只能删除自己创建的文件，不能删除别人的文件

# 实际场景应用
# 协作目录 - 多人可以写，但不能互相删除
mkdir /tmp/upload
chmod 1777 /tmp/upload
# 用户A可以删除自己的文件，但不能删除用户B的文件
```

### 4. 特殊权限组合参考表

```bash
# 4位数字权限表示：[特殊权限位][用户权限][组权限][其他权限]

# 常见组合
chmod 4755 file     # SUID + rwxr-xr-x (可执行程序，以所有者身份运行)
chmod 2755 dir      # SGID + rwxr-xr-x (创建的文件继承所属组)
chmod 1777 dir      # Sticky + rwxrwxrwx (共享目录，防止互删)
chmod 6755 file     # SUID+SGID + rwxr-xr-x (同时具有两个特殊权限)
chmod 7755 dir      # SUID+SGID+Sticky + rwxr-xr-x (所有特殊权限)
chmod 0755 file     # 无特殊权限 + rwxr-xr-x (普通权限设置)

# 验证特殊权限是否生效
ls -l file          # 查看权限位
stat file           # 查看详细信息
```

## 六、ACL访问控制列表

ACL（Access Control List）提供比传统rwx权限更细粒度的权限控制。

### 1. 查看ACL

```bash
# 查看文件ACL
getfacl filename

# 输出示例
# file: filename
# owner: user
# group: group
user::rw-           # 所有者权限
user:john:rw-       # 指定用户john的权限
group::r--          # 组权限
group:developers:rwx # 指定组developers的权限
mask::rw-           # 有效权限掩码
other::r--          # 其他人权限

# 递归查看
getfacl -R /path/to/dir

# 查看物理权限和ACL
ls -l filename      # 显示基本权限（带+号表示有ACL）
-rw-r--r--+ 1 user group ... filename
                    ^ 这个+号表示文件有ACL
```

### 2. 设置ACL

```bash
# 基本语法
setfacl -m (u|g):name:permissions file

# 给特定用户设置权限
setfacl -m u:john:rwx file          # john可读写执行
setfacl -m u:jane:rw file           # jane可读写
setfacl -m u:bob:r file             # bob只读

# 给特定组设置权限
setfacl -m g:developers:rwx dir     # developers组可读写执行
setfacl -m g:readers:r file         # readers组只读

# 递归设置ACL
setfacl -R -m u:john:rwx /path/to/dir

# 设置默认ACL（对新创建的文件生效）
setfacl -d -m u:john:rwx /path/to/dir

# 同时设置和默认ACL
setfacl -R -m u:john:rwx /shared
setfacl -R -d -m u:john:rwx /shared

# 删除特定ACL项
setfacl -x u:john file              # 删除john的ACL
setfacl -x g:developers dir         # 删除developers组的ACL

# 删除所有ACL
setfacl -b file                     # 移除文件的所有ACL
setfacl -R -b /path/to/dir          # 递归移除所有ACL

# 查看和修改掩码
getfacl file | head -5              # 查看掩码
setfacl -m m::rx file               # 设置掩码（限制最大权限）

# 复制ACL到其他文件
getfacl file1 | setfacl -f - file2

# 实际应用示例
# 项目协作
setfacl -R -m u:developer1:rwx /project
setfacl -R -m u:developer2:rwx /project
setfacl -R -d -m u:developer1:rwx /project
setfacl -R -d -m u:developer2:rwx /project
```

## 七、实用场景示例

### 1. Web服务器文件权限

```bash
# 标准Web目录结构权限设置
# 目录：755 (所有者完全，其他人只读)
# 文件：644 (所有者可读写，其他人只读)

# 方法一：使用find命令
find /var/www/html -type d -exec chmod 755 {} \;  # 目录755
find /var/www/html -type f -exec chmod 644 {} \;  # 文件644

# 方法二：一行命令
chmod -R u+rwX,g+rX,o+rX /var/www/html

# 设置所有者
chown -R www-data:www-data /var/www/html

# 可写目录（用户上传目录）
mkdir -p /var/www/html/uploads
chmod 775 /var/www/html/uploads           # 所有者和组可写
chown www-data:www-data /var/www/html/uploads

# 临时文件目录
mkdir -p /var/www/html/temp
chmod 1777 /var/www/html/temp             # Sticky bit防止互删

# 配置文件
chmod 640 /var/www/html/.env              # 只有所有者和组可读
chown www-data:www-data /var/www/html/.env
```

### 2. 共享目录设置

```bash
# 方案一：基础共享目录
mkdir -p /shared/project
chgrp developers /shared/project
chmod 2775 /shared/project                # SGID + rwxrwxr-x
# 效果：组成员可完全访问，新文件自动属于developers组

# 方案二：使用ACL精细控制
mkdir -p /shared/secure
chmod 700 /shared/secure
setfacl -m u:manager:rwx /shared/secure
setfacl -m g:developers:rx /shared/secure
setfacl -d -m g:developers:rx /shared/secure
# 效果：所有者完全权限，manager完全权限，developers只读

# 方案三：完全开放但防止互删
mkdir -p /shared/upload
chmod 1777 /shared/upload
# 任何人都可以读写，但只能删除自己的文件

# 验证权限
ls -lRd /shared                           # 查看目录权限
getfacl /shared/secure                    # 查看ACL
```

### 3. 脚本文件权限

```bash
# 创建脚本
cat > script.sh << 'EOF'
#!/bin/bash
echo "Hello World"
EOF

# 设置可执行权限
chmod 755 script.sh         # 所有人可执行
chmod u+x script.sh         # 仅所有者可执行
chmod 700 script.sh         # 仅所有者完全权限

# 验证
ls -l script.sh
# -rwxr-xr-x 1 user group ... script.sh

# 执行脚本
./script.sh                 # 执行脚本
bash script.sh              # 用bash执行（不需要x权限）

# 系统脚本权限建议
# 一般脚本：755
# 需要sudo运行的脚本：750 或 700
# 设置SUID的脚本：4755（需谨慎）
```

### 4. 安全的私有文件

```bash
# SSH密钥（最严格）
chmod 600 ~/.ssh/id_rsa     # 只有所有者可读
chmod 644 ~/.ssh/id_rsa.pub # 公钥可读
chmod 700 ~/.ssh            # 只有所有者可进入

# 验证SSH权限
ls -la ~/.ssh/
# drwx------ 2 user group ... .ssh/
# -rw------- 1 user group ... id_rsa
# -rw-r--r-- 1 user group ... id_rsa.pub

# 系统敏感配置文件
chmod 600 /etc/shadow       # 密码文件，仅root可读
chmod 644 /etc/passwd       # 用户信息，所有人可读
chmod 600 /etc/sudoers      # sudo配置，仅root可读
chmod 600 /root/.ssh/authorized_keys  # root的ssh密钥

# 数据库配置
chmod 600 /etc/mysql/my.cnf
chmod 600 /etc/postgresql/postgresql.conf

# 应用配置文件
chmod 640 /app/.env         # 应用可读，其他用户不可读
chown app:app /app/.env

# 日志文件
chmod 644 /var/log/app.log  # 一般可读
chmod 600 /var/log/secure.log # 敏感日志只有root可读
```

## 八、权限检查与排错

```bash
# 查看文件权限
ls -l file                  # 查看单个文件权限
ls -la directory            # 查看目录及隐藏文件权限

# 查看目录权限
ls -ld directory            # 仅显示目录本身权限，不显示内容

# 查看完整路径权限
namei -l /path/to/file      # 逐级显示路径各部分的权限
namei -l /var/www/html/index.html

# 输出示例：
# f: /var/www/html/index.html
# dr-xr-xr-x root root /
# drwxr-xr-x root root var
# drwxr-xr-x root root www
# drwxr-xr-x www-data www-data html
# -rw-r--r-- www-data www-data index.html

# 获取文件详细信息
stat file                   # 显示文件所有权限信息
stat -c "%a %n" file        # 仅显示权限数值和文件名

# 测试当前用户权限（模拟指定用户）
test -r file && echo "可读" || echo "不可读"
test -w file && echo "可写" || echo "不可写"
test -x file && echo "可执行" || echo "不可执行"

# 以特定用户身份测试权限
sudo -u username test -r file && echo "$username 可读"
sudo -u username test -w file && echo "$username 可写"

# 查找特定权限的文件
find / -perm 777           # 查找777权限的文件（不安全）
find / -perm -200          # 查找有写权限的文件（others）
find / -perm /u+s          # 查找SUID文件
find / -perm /g+s          # 查找SGID文件
find / -perm /+t           # 查找Sticky bit文件

# 查找权限过宽松的文件
find / -type f -perm /u+s -ls        # 列出所有SUID文件
find / -type f -perm 777             # 找出权限为777的文件
find /home -type f -perm /077 -ls    # 找出过度开放的家目录文件

# 检查文件所有者
find / -user root -ls               # 查找所有者为root的文件
find / -group www-data -ls          # 查找属于www-data组的文件
find / -nouser -ls                  # 查找没有所有者的文件（孤立文件）

# 权限排错常见问题

# 问题1：无法读取文件
ls -l problematic_file
# 检查当前用户是否有读权限
# 检查文件所在目录是否有x权限（进入权限）

# 问题2：无法进入目录
ls -ld problematic_dir
# 目录必须有x权限，才能进入和访问其中的文件
# 即使目录有r权限，没有x权限也无法进入

# 问题3：无法删除文件
ls -ld parent_directory
# 需要父目录的写权限
# 如果父目录设置了sticky bit，只能删除自己的文件

# 权限诊断脚本
#!/bin/bash
file=$1
echo "=== 权限信息 ==="
ls -l "$file"
echo "=== 详细信息 ==="
stat "$file"
echo "=== 路径权限 ==="
namei -l "$file"
```

## 九、权限安全最佳实践

### 1. 最小权限原则

```bash
# 正确做法：只给必要的最少权限
chmod 600 sensitive_data.txt        # 敏感数据只有所有者可读
chmod 755 public_script.sh          # 公开脚本所有人可执行
chmod 700 private_dir               # 私密目录只有所有者可访问

# 避免的做法：
chmod 777 file                      # ✗ 过度开放，安全隐患
chmod 666 file                      # ✗ 所有人都可写，容易被污染
```

### 2. 权限设置建议速查表

```bash
# 文件权限建议
755    # 可执行文件、脚本 - 所有人可执行
644    # 普通数据文件 - 仅所有者可写
640    # 半私密文件 - 组可读，其他不可读
600    # 私密文件 - 仅所有者可读写

# 目录权限建议
755    # 公开目录 - 所有人可进入查看
750    # 组私密目录 - 组成员可访问
700    # 完全私密目录 - 仅所有者可访问
770    # 团队目录 - 所有者和组成员完全权限

# 特殊情况
4755   # SUID可执行文件 - 以所有者身份运行（谨慎使用）
2755   # SGID目录 - 新文件继承目录组
1777   # Sticky bit - 共享目录防止互删
```

### 3. 文件分类与权限策略

```bash
# Web应用文件分类
/app
├── public/           # 公开文件
│   └── index.html    # 644 rwxr-xr-x (web可读)
├── config/
│   └── .env         # 640 -rw-r----- (仅app和dba可读)
├── logs/
│   └── app.log      # 644 -rw-r--r-- (app写，其他可读)
├── uploads/
│   └── user/        # 775 drwxrwxr-x (防止互删用2775)
└── scripts/
    └── deploy.sh   # 750 -rwxr-x--- (仅所有者可执行)

# 系统级文件分类
/etc/
├── passwd           # 644 (所有人可读)
├── shadow           # 600 (仅root可读)
├── sudoers          # 440 (仅root可读，不可写)
└── ssh/
    └── sshd_config  # 600 (仅root可读)

/home/
├── user1/
│   ├── .ssh/        # 700 (仅所有者可访问)
│   │   └── id_rsa   # 600 (仅所有者可读)
│   └── .bashrc      # 644 (可读配置)
```

### 4. 定期权限审计

```bash
# 查找不安全的权限

# 查找世界可写的文件（极其危险）
find / -type f -perm -002 -ls
find / -type d -perm -002 -ls

# 查找所有SUID文件（可能被恶意利用）
find / -type f -perm /u+s -ls
sudo find / -perm -4000 2>/dev/null

# 查找所有SGID文件
find / -type f -perm /g+s -ls
sudo find / -perm -2000 2>/dev/null

# 查找所有Sticky bit文件
find / -type d -perm /+t -ls
sudo find / -perm -1000 2>/dev/null

# 查找文件所有者为root但有世界可写权限
find / -user root -perm -002 -ls

# 查找没有所有者的文件（可能是恶意文件）
find / -nouser -ls
find / -nogroup -ls

# 定期权限检查脚本示例
#!/bin/bash
echo "=== 权限安全检查 ==="
echo "1. 检查777权限的文件"
find / -type f -perm 777 2>/dev/null | head -10
echo ""
echo "2. 检查SUID文件"
find / -type f -perm /u+s 2>/dev/null | head -10
echo ""
echo "3. 检查无所有者的文件"
find / -nouser -ls 2>/dev/null | head -10
```

### 5. 权限继承和默认值

```bash
# 理解权限继承

# umask影响新文件权限
umask 0022          # 默认值
touch new_file      # 权限为 644 (666-022)
mkdir new_dir       # 权限为 755 (777-022)

umask 0077          # 严格模式
touch secret_file   # 权限为 600 (666-077)
mkdir secret_dir    # 权限为 700 (777-077)

# 复制权限
chmod --reference=template.txt target.txt  # 从template复制权限到target

# 递归修改，但保留执行权限
chmod -R u+rwX,g+rX,o-rwx /path  # X表示只对目录添加x权限
```

### 6. 权限与访问控制

```bash
# 访问流程理解
# 要访问 /home/user/project/file.txt，需要：
# 1. / 目录的 x 权限（能进入根目录）
# 2. /home 目录的 x 权限（能进入home目录）
# 3. /home/user 目录的 x 权限（能进入user目录）
# 4. /home/user/project 目录的 x 权限（能进入project目录）
# 5. file.txt 文件的 r 权限（如果要读取）

# 常见访问问题排查
# 问题：Permission denied
ls -la /home/user/project/
namei -l /home/user/project/file.txt
# 查看完整路径上每个目录的权限

# 解决方案：确保路径上所有目录都有x权限
chmod u+x /home/user
chmod u+x /home/user/project
```

## 十、特殊情况处理

### 1. 符号链接权限

```bash
# 创建符号链接
ln -s /original/file /link/to/file

# 符号链接的权限（通常是lrwxrwxrwx）
ls -l link
# lrwxrwxrwx 1 user group ... link -> /original/file

# 重要：符号链接权限不重要，重要的是目标文件的权限
chmod 644 link      # 不影响符号链接，影响目标文件
# 使用 -h 参数只修改链接本身（大多数系统不支持）
chown -h user:group link  # -h 表示修改链接本身

# 检查符号链接
readlink link       # 显示链接指向的文件
ls -L file          # 显示链接指向文件的权限
```

### 2. 硬链接权限

```bash
# 创建硬链接
ln /original/file /hard/link

# 硬链接与原文件共享相同的inode和权限
ls -l /original/file /hard/link
# -rw-r--r-- 2 user group ... /original/file
# -rw-r--r-- 2 user group ... /hard/link

# 修改一个的权限会影响另一个
chmod 600 /original/file
ls -l /hard/link    # 权限也变为600

# 删除一个不影响另一个
rm /original/file
ls -l /hard/link    # 文件仍存在
```

### 3. 文件的特殊属性（Linux ext系列文件系统）

```bash
# 查看文件扩展属性
lsattr file
# 输出示例: ----e------- file

# 设置不可修改属性
sudo chattr +i file         # 即使是root也无法修改或删除
sudo lsattr file            # ----i------- file

# 移除不可修改属性
sudo chattr -i file

# 其他常用属性
sudo chattr +a file         # 只能追加写入，不能删除或修改
sudo chattr +d file         # 执行dump时跳过该文件

# 递归设置属性
sudo chattr -R +i /protected/dir
```

### 4. 文件系统挂载选项

```bash
# 使用noexec选项挂载（禁止执行）
mount -o noexec /dev/sdb1 /mnt/data
# 即使文件权限有x，也无法执行

# 使用nosuid选项挂载（禁止SUID/SGID）
mount -o nosuid /dev/sdb1 /mnt/data
# SUID和SGID位被忽略

# 使用nodev选项挂载（禁止块/字符设备）
mount -o nodev /dev/sdb1 /mnt/data

# 组合选项
mount -o noexec,nosuid,nodev /dev/sdb1 /mnt/data

# 查看挂载选项
mount | grep /mnt
df -l
```

## 十一、SELinux和AppArmor（高级安全）

### 1. SELinux基础

```bash
# 查看SELinux状态
getenforce              # 显示当前模式
# Enforcing - 强制执行
# Permissive - 警告模式
# Disabled - 禁用

# 查看SELinux政策
semanage user -l

# 查看文件SELinux上下文
ls -Z file
# -rw-r--r-- user group system_u:object_r:user_home_t:s0 file

# 设置文件类型上下文
chcon -t httpd_sys_rw_content_t /var/www/html/upload
restorecon -R /var/www/html    # 恢复默认上下文

# SELinux布尔值管理
getsebool -a                    # 列出所有布尔值
setsebool -P httpd_unified on   # 永久修改

# 生成SELinux策略
ausearch -m avc -ts recent | audit2allow -M mypolicy
semodule -i mypolicy.pp
```

### 2. AppArmor基础

```bash
# 查看AppArmor状态
sudo aa-status

# 加载配置文件
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.man

# 设置为投诉模式（警告，不拒绝）
sudo aa-complain /etc/apparmor.d/usr.bin.firefox

# 设置为强制模式
sudo aa-enforce /etc/apparmor.d/usr.bin.firefox

# 禁用配置
sudo rm /etc/apparmor.d/disable/usr.bin.firefox
sudo apparmor_parser -R /etc/apparmor.d/usr.bin.firefox
```

## 十二、权限管理脚本示例

### 1. 批量修改权限脚本

```bash
#!/bin/bash
# 脚本：批量设置Web目录权限

DIR="/var/www/html"
OWNER="www-data"
GROUP="www-data"

# 检查目录是否存在
if [ ! -d "$DIR" ]; then
    echo "错误：目录 $DIR 不存在"
    exit 1
fi

echo "开始设置权限..."

# 设置目录权限 755
find "$DIR" -type d -exec chmod 755 {} \;
echo "✓ 目录权限已设置为755"

# 设置文件权限 644
find "$DIR" -type f -exec chmod 644 {} \;
echo "✓ 文件权限已设置为644"

# 设置上传目录权限 775
find "$DIR/uploads" -type d -exec chmod 775 {} \; 2>/dev/null
find "$DIR/uploads" -type f -exec chmod 664 {} \; 2>/dev/null
echo "✓ 上传目录权限已设置"

# 设置所有者
chown -R "$OWNER:$GROUP" "$DIR"
echo "✓ 所有者已设置为 $OWNER:$GROUP"

echo "权限设置完成！"
```

### 2. 权限审计脚本

```bash
#!/bin/bash
# 脚本：权限安全审计

echo "========== 权限安全审计报告 =========="
echo "生成时间：$(date)"
echo ""

echo "1. 查找777权限的文件（极其危险）"
COUNT=$(find / -type f -perm 777 2>/dev/null | wc -l)
echo "   数量：$COUNT"
if [ $COUNT -gt 0 ]; then
    find / -type f -perm 777 2>/dev/null | head -5
fi
echo ""

echo "2. 查找SUID文件"
COUNT=$(find / -type f -perm /u+s 2>/dev/null | wc -l)
echo "   数量：$COUNT"
echo ""

echo "3. 查找SGID文件"
COUNT=$(find / -type f -perm /g+s 2>/dev/null | wc -l)
echo "   数量：$COUNT"
echo ""

echo "4. 查找无所有者的文件"
COUNT=$(find / -nouser 2>/dev/null | wc -l)
echo "   数量：$COUNT"
if [ $COUNT -gt 0 ]; then
    find / -nouser 2>/dev/null | head -5
fi
echo ""

echo "========== 审计完成 =========="
```

### 3. 权限恢复脚本

```bash
#!/bin/bash
# 脚本：恢复标准权限（谨慎使用）

DIR="${1:-.}"
OWNER="${2:-$(stat -c '%U:%G' "$DIR")}"

if [ ! -d "$DIR" ]; then
    echo "错误：$DIR 不是目录"
    exit 1
fi

read -p "确认要重置 $DIR 的权限吗？(y/N) " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo "开始恢复标准权限..."

# 恢复目录权限 755
find "$DIR" -type d -exec chmod 755 {} \;

# 恢复文件权限 644
find "$DIR" -type f -exec chmod 644 {} \;

# 恢复所有者
chown -R "$OWNER" "$DIR"

echo "✓ 权限已恢复"
```

## 十三、常见权限错误与解决方案

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| Permission denied | 用户无权限 | 检查文件权限，增加所需权限或更改所有者 |
| Cannot execute | 文件无执行权限 | chmod +x file |
| Cannot write | 文件无写权限 | chmod +w file 或 更改所有者 |
| Cannot enter directory | 目录无执行权限 | chmod u+x directory |
| Cannot delete file | 父目录无写权限或sticky bit | 增加目录写权限或以所有者身份删除 |
| File not found | 文件或路径权限不足 | 检查整个路径的x权限 |
| sudo password prompt | sudo权限配置 | 检查/etc/sudoers配置 |
| SSH Permission denied | SSH密钥权限错误 | chmod 600 ~/.ssh/id_rsa, chmod 700 ~/.ssh |

## 十四、权限设置检查清单

在部署应用或系统配置时使用此清单：

```
□ 验证目录权限是否为755或750
□ 验证配置文件权限是否为640
□ 验证SSH密钥权限是否为600
□ 验证脚本文件权限是否为755或750
□ 验证日志文件权限是否合理
□ 验证上传目录权限是否为775且有sticky bit
□ 验证敏感文件是否只有所有者可读
□ 检查是否有不必要的SUID/SGID文件
□ 验证所有者和组是否正确
□ 确认没有777权限的文件
□ 检查不同应用程序的文件是否有适当隔离
□ 验证数据库目录权限
□ 确认Web服务器可以访问需要的目录
```

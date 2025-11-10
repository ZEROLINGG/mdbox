# Linux ss 命令详解

## 一、命令概述

`ss`（Socket Statistics）是一个用于查看网络套接字（socket）信息的强大工具，是传统`netstat`命令的现代替代品。

### 主要优势
- **速度更快**：特别是在连接数很多时
- **信息更详细**：显示更多TCP和状态信息
- **功能更强大**：支持更多的过滤选项

## 二、基本语法

```bash
ss [选项] [过滤器]
```

## 三、常用选项详解

### 3.1 基础选项

| 选项   | 说明           | 示例      |
| ---- | ------------ | ------- |
| `-n` | 不解析服务名称，显示数字 | `ss -n` |
| `-a` | 显示所有套接字      | `ss -a` |
| `-l` | 显示监听状态的套接字   | `ss -l` |
| `-p` | 显示使用套接字的进程   | `ss -p` |
| `-s` | 显示套接字统计摘要    | `ss -s` |
| `-e` | 显示详细的套接字信息   | `ss -e` |
| `-m` | 显示套接字的内存使用   | `ss -m` |
| `-i` | 显示内部的TCP信息   | `ss -i` |

### 3.2 协议选项

| 选项   | 说明         |
| ---- | ---------- |
| `-t` | 显示TCP套接字   |
| `-u` | 显示UDP套接字   |
| `-d` | 显示DCCP套接字  |
| `-w` | 显示RAW套接字   |
| `-x` | 显示Unix域套接字 |
| `-4` | 显示IPv4套接字  |
| `-6` | 显示IPv6套接字  |

## 四、常用命令示例

### 4.1 基本查看

```bash
# 显示所有TCP连接
ss -t

# 显示所有监听的TCP端口
ss -tl

# 显示所有已建立的连接
ss -t state established

# 显示统计摘要
ss -s
```

### 4.2 端口和进程查看

```bash
# 显示所有监听端口及其进程
sudo ss -tlnp

# 查看特定端口的连接
ss -tan | grep :80

# 查看指定端口的详细信息
ss -tlnp | grep :22
```

### 4.3 高级过滤

```bash
# 显示所有状态为established的HTTP/HTTPS连接
ss -tan state established '( dport = :80 or dport = :443 )'

# 显示所有连接到指定IP的连接
ss -tan dst 192.168.1.100

# 显示特定网段的连接
ss -tan src 192.168.1.0/24
```

## 五、状态过滤

### 5.1 TCP状态

```bash
# 常见TCP状态
ss -tan state listening      # 监听状态
ss -tan state established    # 已建立连接
ss -tan state time-wait      # TIME_WAIT状态
ss -tan state close-wait     # CLOSE_WAIT状态
ss -tan state syn-sent       # SYN_SENT状态
ss -tan state syn-recv       # SYN_RECV状态
```

### 5.2 组合状态查询

```bash
# 显示所有非监听状态的连接
ss -tan state connected

# 显示所有已连接的套接字
ss state all
```

## 六、实用场景

### 6.1 性能监控

```bash
# 统计各种状态的连接数
ss -tan | awk '{print $1}' | sort | uniq -c

# 查看TIME_WAIT连接数
ss -tan state time-wait | wc -l

# 查看连接最多的IP地址
ss -tan | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head
```

### 6.2 安全检查

```bash
# 查看所有开放的端口
sudo ss -tulpn

# 查看异常的高端口监听
sudo ss -tlnp | grep -E ':[0-9]{5}'

# 查找特定进程的网络连接
sudo ss -tp | grep "process_name"
```

### 6.3 故障排查

```bash
# 查看端口占用情况
sudo ss -tlnp | grep :8080

# 查看连接队列信息
ss -tln

# 显示套接字内存使用
ss -tm
```

## 七、输出格式解读

### 7.1 基本输出格式

```
State    Recv-Q    Send-Q    Local Address:Port    Peer Address:Port
LISTEN   0         128       0.0.0.0:22            0.0.0.0:*
ESTAB    0         0         192.168.1.100:22      192.168.1.200:54321
```

| 字段 | 说明 |
|------|------|
| State | 套接字状态 |
| Recv-Q | 接收队列数据 |
| Send-Q | 发送队列数据 |
| Local Address:Port | 本地地址和端口 |
| Peer Address:Port | 远程地址和端口 |

### 7.2 详细信息解读

使用 `-e` 选项时的额外信息：
- `uid`：用户ID
- `ino`：inode号
- `sk`：套接字指针

## 八、过滤器语法

### 8.1 基本过滤器

```bash
# 源地址过滤
ss src 192.168.1.1

# 目标地址过滤  
ss dst 192.168.1.1

# 端口过滤
ss dport = :80
ss sport = :22

# 端口范围
ss dport \> :1024
ss sport \< :32000
```

### 8.2 复合过滤

```bash
# AND 操作
ss -tan '( dport = :80 or dport = :443 ) and src 192.168.1.0/24'

# 排除特定条件
ss -tan not dst 127.0.0.1
```

## 九、性能优化技巧

### 9.1 大量连接时的优化

```bash
# 使用数字格式，避免DNS解析
ss -tn

# 只显示摘要信息
ss -s

# 使用过滤器减少输出
ss -tan state established
```

### 9.2 脚本集成

```bash
#!/bin/bash
# 监控连接数变化
while true; do
    echo "$(date): $(ss -tan state established | wc -l) established connections"
    sleep 5
done
```

## 十、与netstat对比

| 功能 | netstat | ss |
|------|---------|-----|
| 速度 | 较慢 | 快 |
| 信息详细度 | 基本 | 详细 |
| 过滤功能 | 有限 | 强大 |
| TCP信息 | 基本 | 详细 |

### 命令对照

```bash
# netstat vs ss
netstat -tulpn    ↔    ss -tulpn
netstat -an       ↔    ss -an
netstat -s        ↔    ss -s
```

## 总结

`ss`命令是Linux系统中强大的网络诊断工具，特别适合：
- 快速查看网络连接状态
- 排查网络问题
- 监控系统性能
- 安全审计

# Hashcat 完整详细使用指南

## 一、基本介绍

Hashcat 是世界上最快的密码恢复工具，支持 CPU 和 GPU 加速。

### 特点
- 支持 300+ 种哈希算法
- 多平台支持（Windows/Linux/macOS）
- 支持分布式破解
- 高度优化的内核
- 支持实时进度保存和恢复

## 二、基本语法

```bash
hashcat [选项] 哈希文件 [字典文件/掩码]
```

```bash
# 自动识别hash
hashcat hash.txt wordlist.txt   

hashcat -m 0 -a 0 hash.txt wordlist.txt
```


## 三、攻击模式详解

### 1. **攻击模式类型 (-a)**

```bash
-a 0  # 字典攻击（Straight）
-a 1  # 组合攻击（Combination）
-a 3  # 掩码攻击（Brute-force）
-a 6  # 混合攻击（字典+掩码）
-a 7  # 混合攻击（掩码+字典）
-a 9  # 关联攻击（Association）
```

#### **模式 0：字典攻击**
```bash
# 最基本的字典攻击
hashcat -m 0 -a 0 hash.txt wordlist.txt

# 使用规则增强字典
hashcat -m 0 -a 0 hash.txt wordlist.txt -r rules/best64.rule

# 多个规则文件
hashcat -m 0 -a 0 hash.txt wordlist.txt -r rules/best64.rule -r rules/dive.rule
```

#### **模式 1：组合攻击**
```bash
# 将两个字典文件组合
hashcat -m 0 -a 1 hash.txt dict1.txt dict2.txt

# 示例：password + 123 = password123
```

#### **模式 3：掩码攻击**
```bash
# 8位纯数字
hashcat -m 0 -a 3 hash.txt ?d?d?d?d?d?d?d?d

# 自定义掩码：大写字母+4位数字
hashcat -m 0 -a 3 hash.txt ?u?u?u?u?d?d?d?d
```

#### **模式 6：字典+掩码**
```bash
# 字典词 + 数字后缀
hashcat -m 0 -a 6 hash.txt wordlist.txt ?d?d?d?d
```

#### **模式 7：掩码+字典**
```bash
# 数字前缀 + 字典词
hashcat -m 0 -a 7 hash.txt ?d?d?d?d wordlist.txt
```

#### **模式 9：关联攻击**
```bash
# 从字典中提取关键词进行关联
hashcat -m 0 -a 9 hash.txt wordlist.txt -j '$!'
```

## 四、哈希类型 (-m) 完整列表

### **基础哈希算法**

```bash
# MD5 系列
-m 0      # MD5
-m 10     # md5($pass.$salt)
-m 20     # md5($salt.$pass)
-m 3500   # md5($salt.md5($pass))
-m 4400   # md5(sha1($pass))

# SHA1 系列
-m 100    # SHA1
-m 110    # sha1($pass.$salt)
-m 120    # sha1($salt.$pass)
-m 4500   # sha1(sha1($pass))
-m 4700   # sha1(md5($pass))

# SHA256 系列
-m 1400   # SHA256
-m 1410   # sha256($pass.$salt)
-m 1420   # sha256($salt.$pass)
-m 1430   # sha256(sha256($pass))
-m 1440   # sha256(md5($pass))

# SHA512 系列
-m 1700   # SHA512
-m 1710   # sha512($pass.$salt)
-m 1720   # sha512($salt.$pass)
-m 1730   # sha512(sha512($pass))

# 其他基础哈希
-m 900    # MD4
-m 1000   # NTLM (Windows)
-m 1100   # Domain Cached Credentials
-m 1500   # descrypt
-m 3000   # LM (Windows)
```

### **加密和盐值哈希**

```bash
# bcrypt 系列
-m 3200   # bcrypt $2*$, Blowfish
-m 25600  # bcrypt(md5($pass))

# scrypt 系列
-m 8900   # scrypt
-m 9000   # Password Safe v3

# argon2 系列
-m 24500  # Argon2 (P and S)

# PBKDF2
-m 1421   # PBKDF2-HMAC-SHA256
-m 12001  # PBKDF2-HMAC-SHA1
-m 23200  # PBKDF2-HMAC-SHA512

# MD5 Crypt
-m 500    # md5crypt, MD5 (Unix), Cisco-IOS $1$ (MD5)
-m 3400   # md5crypt, MD5 (Unix), Cisco-IOS $1$ (MD5) salted

# SHA Crypt
-m 1800   # sha512crypt, SHA512 (Unix) $6$
-m 1600   # sha1crypt, SHA1 (Unix)
-m 7400   # sha256crypt, SHA256 (Unix) $5$
```

### **应用程序和框架哈希**

```bash
# PHP 相关
-m 400    # phpass, WordPress, phpBB3
-m 2611   # vBulletin < v3.8.5
-m 2711   # vBulletin >= v3.8.5
-m 2612   # vBulletin < v3.8.5 (md5 + salt)

# CMS 系统
-m 121    # SMF (Simple Machines Forum)
-m 6500   # Joomla
-m 1221   # Mediawiki B type
-m 3711   # MediaWiki B type

# 论坛和社区
-m 8400   # WP e-Signature
-m 2711   # vBulletin >= v3.8.5
-m 6000   # RipeMD-160
-m 6100   # Whirlpool

# 其他应用
-m 7800   # SAP CODVN B (MD5)
-m 7900   # SAP CODVN F/G (MD5)
-m 9100   # LOTUS NOTES/DOMINO 5
-m 9200   # LOTUS NOTES/DOMINO 6
-m 9300   # LOTUS NOTES/DOMINO 8
```

### **数据库哈希**

```bash
# PostgreSQL
-m 12     # PostgreSQL
-m 12100  # PostgreSQL MD5
-m 9700   # SAP SYBASE ASE

# MySQL
-m 200    # MySQL323
-m 300    # MySQL4.1 / MySQL5
-m 4800   # iSCSI CHAP authentication

# MSSQL
-m 131    # MSSQL (2000)
-m 132    # MSSQL (2005)
-m 1731   # MSSQL (2012, 2014)
-m 27900  # MSSQL (2016 and later)

# Oracle
-m 3100   # Oracle H: Type (Oracle 7+)
-m 112    # Oracle S: Type (Oracle 11+)
-m 12300  # Oracle T: Type (Oracle 12+)
-m 12400  # Oracle12C: Hash of a password

# 其他数据库
-m 1200   # Oracle S: Type (Oracle 11+)
-m 1211   # DNSSEC (NSEC3)
```

### **操作系统和认证**

```bash
# Windows
-m 1000   # NTLM (Windows)
-m 3000   # LM (Windows)
-m 1100   # Domain Cached Credentials (DCC)
-m 1100   # DCC (Domain Cached Credentials)
-m 5500   # NetNTLMv1 / NetNTLMv1+ESS
-m 5600   # NetNTLMv2
-m 27900  # WinRM Session Remote Management Hash

# Linux/Unix
-m 500    # md5crypt (Linux)
-m 1800   # sha512crypt (Linux)
-m 1600   # sh1crypt (Linux)
-m 7400   # sha256crypt (Linux)
-m 3200   # bcrypt (Linux)

# MAC OS
-m 7100   # macOS v10.4 - v10.6
-m 7200   # macOS v10.7+
-m 7300   # macOS v10.12+
-m 5600   # NetNTLMv2 (macOS)

# Cisco
-m 500    # Cisco-IOS $1$ (MD5)
-m 5700   # Cisco-IOS type 5
-m 9200   # Cisco-PIX MD5
-m 500    # Cisco-IOS enable secret
```

### **网络协议和认证**

```bash
# Kerberos
-m 7500   # Kerberos 5 AS-REQ Pre-Auth etype 23
-m 13100  # Kerberos 5 TGS-REP etype 23

# RADIUS
-m 2500   # RADIUS authentication

# CHAP
-m 4800   # iSCSI CHAP authentication
-m 4801   # iSCSI CHAP authentication CHAP_MD5

# 其他认证
-m 8500   # RACF
-m 7300   # IPMI2 RAKP HMAC-SHA1
-m 16100  # TACACS+
-m 5200   # SNMPv3 HMAC-MD5-96/HMAC-SHA-96
-m 5800   # Android PIN MD5
```

### **文档和压缩格式**

```bash
# Microsoft Office
-m 9400   # MS Office 2007
-m 9500   # MS Office 2010
-m 9600   # MS Office 2013
-m 9700   # MS Office 2016
-m 25300  # MS Office 365 (2016 - 2019)
-m 25400  # MS Office 365 (Subscription)

# PDF
-m 10400  # PDF 1.1 - 1.3 (Acrobat 2 - 4)
-m 10500  # PDF 1.4 - 1.6 (Acrobat 5 - 8)
-m 10600  # PDF 1.7 Level 3 (Acrobat 9)
-m 10700  # PDF 1.7 Level 8 (Acrobat 10 - 11)
-m 25700  # PDF Encrypted

# 压缩文件
-m 11600  # 7-Zip
-m 13600  # WinZip (PBKDF2 + AES)
-m 13700  # WinZip (Legacy)
-m 21600  # BinExtra
-m 20900  # PKZIP Master Key

# 其他文档
-m 15500  # JtR Encrypted Shadow
-m 16300  # Ethereum Pre-Sale Wallet
-m 21500  # SolarWinds Orion
```

### **VPN 和无线**

```bash
# WPA/WPA2/WPA3
-m 22000  # WPA-PBKDF2-PMKID+EAPOL (WiFi cracking)
-m 22001  # WPA-PMK-PMKID+EAPOL
-m 22002  # WPA-PBKDF2-PMKID
-m 22003  # WPA-PMK-PMKID

# OpenVPN
-m 16200  # Apple Secure Notes
-m 13100  # Kerberos 5 TGS-REP

# IPSec
-m 5300   # IKE-MD5
-m 5400   # IKE-SHA1
-m 10300  # SAP-CODVN H (MD5) salted and hashed
```

### **其他专用格式**

```bash
# 加密钱包
-m 12700  # Blockchain, My Wallet
-m 15200  # Citrix NetScaler
-m 16300  # Ethereum Pre-Sale Wallet
-m 18900  # Android Backup

# 系统特定
-m 27000  # RTLS (3DES)
-m 27100  # RTLS (AES)
-m 1001   # Lotus Notes/Domino 6 Salted
-m 24100  # SolarWinds Serv-U

# 其他
-m 13200  # AxCrypt
-m 13800  # Windows Phone PIN/Password
-m 14800  # iTunes backup file SHA256
```

## 五、掩码字符集

### **内置字符集**
```bash
?l  # 小写字母 a-z
?u  # 大写字母 A-Z
?d  # 数字 0-9
?h  # 十六进制 0-9a-f
?H  # 十六进制 0-9A-F
?s  # 特殊字符 !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~
?a  # 所有字符 ?l?u?d?s
?b  # 所有 0x00 - 0xff
```

### **自定义字符集**
```bash
# 定义自定义字符集
-1 ?l?d              # 自定义字符集1：小写字母+数字
-2 ?u?s              # 自定义字符集2：大写字母+特殊字符
-3 0123456789abc     # 自定义字符集3：指定字符
-4 @#$%              # 自定义字符集4：特定符号

# 使用自定义字符集
hashcat -m 0 -a 3 hash.txt -1 ?l?d ?1?1?1?1?1?1?1?1
```

### **掩码示例**
```bash
# 8位小写字母
?l?l?l?l?l?l?l?l

# Password + 2位数字
Password?d?d

# 2位大写 + 6位小写
?u?u?l?l?l?l?l?l

# 6位小写 + 2位数字 + 1位特殊字符
?l?l?l?l?l?l?d?d?s

# 使用自定义字符集
-1 ?l?u ?1?1?1?1?d?d?d?d

# 手机号码格式：138xxxxxxxx
-1 3-9 138?1?d?d?d?d?d?d?d

# 车牌号：京A12345
-1 A-Z -2 0-9 京A?1?2?2?2?2?2

# 11位 QQ 号
?d?d?d?d?d?d?d?d?d?d?d
```

## 六、重要选项详解

### **1. 设备选择和性能调优**

```bash
# 设备选择
-d 1              # 使用 GPU 1
-d 1,2            # 使用 GPU 1 和 2
-D 1              # 只使用 CPU
-D 2              # 只使用 GPU
-D 3              # 使用 CPU 和 GPU
-i                # 增量模式
--workload-profile # 工作负载配置

# 工作负载配置
-w 1              # 低负载（默认）
-w 2              # 经济模式
-w 3              # 高性能模式
-w 4              # 噩梦模式（最大性能）

# 内核优化
-O                # 优化内核（限制密码长度，速度更快）
--force           # 忽略警告（不推荐）
--workload-profile=4  # 自定义工作负载

# GPU 温度控制
--gpu-temp-abort=90    # GPU温度超过90°C停止
--gpu-temp-retain=80   # 保持GPU温度在80°C
--hwmon-disable        # 禁用硬件监控

# CPU 优化
--spin-damp=10    # CPU 自旋阻尼（降低 CPU 占用）
```

### **2. 会话管理**

```bash
# 创建和恢复会话
--session=mysession    # 创建会话
--restore             # 恢复会话
--restore-disable     # 禁用自动恢复
--session-unstable    # 不保存进度

# 示例
hashcat -m 0 -a 0 hash.txt wordlist.txt --session=crack1
# Ctrl+C 中断后
hashcat --session=crack1 --restore

# 查看所有会话
hashcat --session=list
```

### **3. 输出选项**

```bash
# 输出文件
-o output.txt             # 保存破解结果
--outfile-format=3        # 输出格式

# 输出格式选项：
# 1 = hash[:salt]
# 2 = plain
# 3 = hash[:salt]:plain
# 4 = hex_plain
# 5 = hash[:salt]:hex_plain
# 15 = username[:uid]:plain

# 查看已破解密码
--show                # 显示已破解的密码
--left                # 显示未破解的哈希
--show-potfile        # 显示所有缓存密码

# 用户名处理
--username            # 启用用户名解析
--remove              # 破解后从列表中移除
--remove-timer=60     # 每60秒删除一次破解的哈希

# 示例
hashcat -m 0 hash.txt --show
hashcat -m 0 hash.txt --show --outfile-format=2 -o cracked.txt
```

### **4. 规则引擎**

```bash
# 单个和多个规则文件
-r rules/best64.rule                      # 使用单个规则文件
-r rule1.rule -r rule2.rule               # 使用多个规则文件
-j '$!' -k '^@'                           # 进出规则（-j/-k）

# 常用规则文件
rules/best64.rule                    # 最佳64条规则（推荐）
rules/InsidePro-PasswordsPro.rule    # 专业级规则
rules/dive.rule                      # 深度挖掘规则（3994条）
rules/leetspeak.rule                 # 1337规则
rules/osint.rule                     # 开源情报规则
rules/T0XlCv23-d3ad0ne.rule          # 高级规则集

# 规则语法
:           # 不做任何修改
l           # 全部转小写
u           # 全部转大写
c           # 首字母大写
C           # 除首字母外全部大写
t           # 切换大小写
TN          # 切换位置N的大小写
$X          # 末尾追加字符X
^X          # 开头插入字符X
dX          # 删除位置X的字符
@X          # 删除所有字符X
/X          # 替换第一个字符为X
rN          # 反转N个字符
ZN          # 复制第N个字符到末尾
zN          # 在开头前添加第N个字符的副本
p           # 重复整个单词（password -> passwordpassword）
q           # 重复所有单词
D           # 删除重复字符
P           # 追加反转副本
V           # 删除连续的重复字符
'N         # 截断到第N个字符

# 规则链示例
# 将 password 转变为 P@ssw0rd
u c $@ $0 $r $d
```

### **5. 增量模式**

```bash
# 增量模式 - 逐步增加密码长度
--increment               # 启用增量模式
--increment-min=1         # 最小长度
--increment-max=8         # 最大长度

# 示例：从1位到8位尝试所有数字组合
hashcat -m 0 -a 3 hash.txt ?d --increment --increment-min=1 --increment-max=8

# 示例：1-6位字母数字组合
hashcat -m 0 -a 3 hash.txt -1 ?l?d ?1 --increment --increment-min=1 --increment-max=6
```

### **6. 限制和过滤**

```bash
# 密码长度限制
--pw-min=8            # 最小密码长度
--pw-max=12           # 最大密码长度

# 处理限制
-s 1000               # 跳过前1000个词
-l 5000               # 限制处理5000个词
--runtime=3600        # 运行1小时后停止
--limit=100           # 限制候选数量

# 字典处理
--remove              # 破解后从哈希列表中移除
--remove-timer=60     # 60秒后检查一次要移除的项
--potfile-disable     # 禁用 potfile（缓存文件）
--potfile-path        # 指定 potfile 路径

# 日志和调试
--logfile-disable     # 禁用日志
--logfile=output.log  # 指定日志文件
--machine-readable    # 机器可读格式
```

### **7. 监控和诊断**

```bash
# 状态显示
--status              # 自动显示状态
--status-timer=10     # 每10秒显示一次状态
--status-json         # JSON 格式状态

# 基准测试
-b                    # 基准测试模式
--benchmark           # 运行基准测试
--profile             # 显示分析数据

# 调试模式
--debug-mode=1        # 调试模式（1-4）
--debug-file=debug.log # 调试日志文件
--example-hashes      # 显示算法示例

# 列出支持的算法
hashcat --example-hashes | grep -i "md5"
```

## 七、哈希自动识别

### **1. Hashcat 内置识别**

```bash
# 自动识别hash破解
hashcat hash.txt $rockyou

# 查看特定算法
hashcat --example-hashes | grep -i "sha256"

# 显示哈希帮助信息
hashcat -m 0 -h
```

### **2. 使用 hash-identifier 工具**

```bash
# 安装
pip install hash-identifier

# 使用
hash-identifier
# 交互式输入要识别的哈希

# 或直接识别
hash-identifier "5f4dcc3b5aa765d61d8327deb882cf99"
```

### **3. 使用 hashid 工具**

```bash
# 安装
pip install hashid
# 或
git clone https://github.com/psypanda/hashID.git
cd hashID && python3 hashID.py

# 使用
hashid "5f4dcc3b5aa765d61d8327deb882cf99"

# 查看 hashcat 兼容的模式号
hashid -e "5f4dcc3b5aa765d61d8327deb882cf99"

# 从文件读取
hashid -f hashfile.txt
```

### **4. 使用在线识别工具**

```bash
# CyberChef
# https://cyberchef.boum.org/

# Name That Hash
# https://www.namethat.hash.gq/

# Online Hash Crack
# https://www.onlinehashcrack.com/
```

### **5. 快速识别脚本**

```bash
#!/bin/bash
# 快速识别并破解脚本

HASH=$1
WORDLIST=${2:-rockyou.txt}

echo "[*] 正在识别哈希类型..."
HASH_TYPE=$(hashid -e "$HASH" 2>/dev/null | grep -oP 'Hashcat mode: \K\d+' | head -1)

if [ -z "$HASH_TYPE" ]; then
    echo "[!] 无法识别哈希类型"
    exit 1
fi

echo "[+] 哈希类型: $HASH_TYPE"
echo "[*] 开始破解..."

hashcat -m "$HASH_TYPE" -a 0 "$HASH" "$WORDLIST"
```

## 八、实战示例

### **示例 1：破解 MD5**
```bash
# 准备哈希文件
echo "5f4dcc3b5aa765d61d8327deb882cf99" > hash.txt

# 字典攻击
hashcat -m 0 -a 0 hash.txt rockyou.txt

# 带规则的字典攻击
hashcat -m 0 -a 0 hash.txt rockyou.txt -r rules/best64.rule

# 查看结果
hashcat -m 0 hash.txt --show
```

### **示例 2：破解 NTLM（Windows）**
```bash
# NTLM 哈希破解
hashcat -m 1000 -a 0 ntlm.txt wordlist.txt -w 3

# 掩码攻击：8位数字
hashcat -m 1000 -a 3 ntlm.txt ?d?d?d?d?d?d?d?d

# 混合攻击：字典 + 数字后缀
hashcat -m 1000 -a 6 ntlm.txt words.txt ?d?d?d?d

# 带规则的破解
hashcat -m 1000 -a 0 ntlm.txt wordlist.txt -r rules/best64.rule -w 3
```

### **示例 3：破解 WPA/WPA2/WPA3**
```bash
# 首先使用 hcxtools 或 hashcat-utils 捕获握手包

# 使用 hcxpcaptool 转换
hcxpcaptool -z hash.hc22000 capture.pcapng

# 破解 WPA
hashcat -m 22000 hash.hc22000 wordlist.txt -w 3 -O

# 使用规则增强
hashcat -m 22000 hash.hc22000 wordlist.txt -r rules/best64.rule -w 3
```

### **示例 4：破解 ZIP 密码**
```bash
# 提取 ZIP 哈希
zip2john file.zip > hash.txt

# 转换为 hashcat 格式（需要处理）
# 或直接使用 hashcat

# 破解（PKZIP）
hashcat -m 20900 hash.txt -a 3 ?d?d?d?d?d?d

# 使用字典
hashcat -m 20900 hash.txt -a 0 wordlist.txt
```

### **示例 5：使用掩码破解已知模式**
```bash
# 已知：2个大写字母 + 用户名 + 4位数字
hashcat -m 0 -a 3 hash.txt ?u?uJohn?d?d?d?d

# 已知：admin + 特殊字符 + 4-6位数字
hashcat -m 0 -a 3 hash.txt admin?s?d?d?d?d --increment --increment-max=6

# 组合攻击：多个已知部分
hashcat -m 0 -a 1 hash.txt admin.txt pass.txt
```

### **示例 6：破解 Linux Shadow 文件**
```bash
# 提取 shadow 文件中的哈希
# 格式：username:$6$salt$hash:...

# SHA512 (bcrypt) 破解
hashcat -m 1800 shadow.txt wordlist.txt

# 带规则
hashcat -m 1800 shadow.txt wordlist.txt -r rules/best64.rule -w 3

# bcrypt 破解
hashcat -m 3200 shadow.txt wordlist.txt
```

### **示例 7：组合攻击**
```bash
# 创建两个字典
echo -e "password\nadmin\nuser" > dict1.txt
echo -e "123\n2023\n@123" > dict2.txt

# 组合攻击
hashcat -m 0 -a 1 hash.txt dict1.txt dict2.txt

# 结果：password123, password2023, password@123, admin123...
```

### **示例 8：批量破解多个哈希**
```bash
# 多个哈希放在同一文件中
cat > hashes.txt << EOF
5f4dcc3b5aa765d61d8327deb882cf99
098f6bcd4621d373cade4e832627b4f6
5e884898da28047151d0e56f8dc6292d
EOF

# 批量破解
hashcat -m 0 hashes.txt wordlist.txt

# 查看破解进度
hashcat -m 0 hashes.txt --status

# 显示已破解的密码
hashcat -m 0 hashes.txt --show
```

### **示例 9：高级掩码组合**
```bash
# 自定义字符集组合攻击
-1 ?u?l -2 ?d?s -3 ?u?l?d

# 组合使用
hashcat -m 0 -a 3 hash.txt -1 ?u?l -2 ?d -3 ?s ?1?1?2?2?3

# 扩展掩码：大小写混合
hashcat -m 0 -a 3 hash.txt -1 ?u?l ?1?1?1?1?d?d?d?d

# 特定格式：邮箱前缀
hashcat -m 0 -a 6 hash.txt names.txt @qq.com

# 多个特殊字符
-1 !@#$% hashcat -m 0 -a 3 hash.txt password?1?d?d?d?d
```

### **示例 10：使用 PRINCE 攻击**
```bash
# PRINCE（Probability Infinite Chained Elements）
# 需要编译 PRINCE

# 基本 PRINCE 攻击
hashcat -m 0 -a 0 hash.txt wordlist.txt --prince

# 指定最小/最大长度
hashcat -m 0 -a 0 hash.txt wordlist.txt --prince --pw-min=6 --pw-max=12

# PRINCE 生成候选
hashcat --stdout wordlist.txt --prince | head -100
```

### **示例 11：分布式破解**
```bash
# 方法 1：使用 skip 和 limit
# 服务器 1 - 处理前 50 亿组合
hashcat -m 0 hash.txt -a 3 ?a?a?a?a?a?a -s 0 -l 5000000000

# 服务器 2 - 处理第二个 50 亿
hashcat -m 0 hash.txt -a 3 ?a?a?a?a?a?a -s 5000000000 -l 5000000000

# 方法 2：使用增量分割
# GPU 1: 掩码 1-4 位
hashcat -m 0 hash.txt -a 3 ?d?d?d?d --increment --increment-max=4 -d 1

# GPU 2: 掩码 5-8 位
hashcat -m 0 hash.txt -a 3 ?d?d?d?d?d?d?d?d --increment --increment-min=5 --increment-max=8 -d 2
```

### **示例 12：针对特定网站的破解**
```bash
# Facebook/Instagram (bcrypt)
hashcat -m 3200 fb_hashes.txt wordlist.txt -r rules/best64.rule

# WordPress
hashcat -m 400 wp_hashes.txt wordlist.txt -w 3

# Joomla
hashcat -m 6500 joomla_hashes.txt wordlist.txt

# vBulletin
hashcat -m 2711 vb_hashes.txt wordlist.txt

# MySQL
hashcat -m 300 mysql_hashes.txt wordlist.txt

# PostgreSQL
hashcat -m 12100 postgres_hashes.txt wordlist.txt
```

### **示例 13：针对特定行业的字典+规则**
```bash
# 银行/金融（通常要求复杂密码）
hashcat -m 1800 bank.txt wordlist.txt -r rules/best64.rule -r rules/dive.rule -w 3

# 公司（常见公司名+日期）
hashcat -m 0 company.txt company_names.txt -j '$-2024' -j '$-2023' -j '$-2022'

# 游戏（常见游戏术语）
hashcat -m 0 game.txt gaming_terms.txt -r rules/leetspeak.rule

# 社交媒体（通常较弱）
hashcat -m 0 social.txt wordlist.txt --pw-max=16
```

## 九、高级技巧和优化

### **1. 统计分析和掩码生成**

```bash
# 从破解成功的密码生成掩码
# 使用 Hashcat-utils 中的 maskprocessor

# 生成所有可能的掩码
./maskprocessor -o masks.txt wordlist.txt

# 基于现有密码生成统计
hashcat --stdout rockyou.txt | wc -l

# 生成基于密码长度的掩码
# 分析已知密码中最常见的模式
for word in $(cat rockyou.txt); do
    echo "${#word}:$word"
done | sort | uniq | head -100
```

### **2. 字典优化**

```bash
# 删除重复和过短的单词
hashcat --stdout wordlist.txt | sort | uniq | awk 'length > 4' > clean_dict.txt

# 按长度排序字典
hashcat --stdout wordlist.txt | awk '{print length, $0}' | sort -n | cut -d' ' -f2- > sorted_dict.txt

# 合并多个字典并去重
cat dict1.txt dict2.txt dict3.txt | sort | uniq > merged_dict.txt

# 提取特定长度的单词
hashcat --stdout wordlist.txt | awk 'length==8' > 8_char_words.txt
```

### **3. 性能基准测试**

```bash
# 基准测试特定算法
hashcat -b -m 0      # MD5 基准
hashcat -b -m 1000   # NTLM 基准
hashcat -b -m 3200   # bcrypt 基准

# 测试不同工作负载
hashcat -b -m 0 -w 1  # 低负载基准
hashcat -b -m 0 -w 3  # 高性能基准
hashcat -b -m 0 -w 4  # 噩梦模式基准

# GPU 实时监控
watch -n 1 nvidia-smi    # NVIDIA
watch -n 1 rocm-smi      # AMD
watch -n 1 glxinfo       # Intel
```

### **4. Potfile 管理**

```bash
# potfile 位置
# Linux: ~/.hashcat/hashcat.potfile
# Windows: C:\Users\用户名\AppData\Local\hashcat\hashcat.potfile

# 查看 potfile 内容
cat ~/.hashcat/hashcat.potfile

# 提取已破解的密码
cut -d':' -f2 ~/.hashcat/hashcat.potfile > cracked_passwords.txt

# 查看特定哈希的结果
grep "5f4dcc3b5aa765d61d8327deb882cf99" ~/.hashcat/hashcat.potfile

# 清除 potfile
rm ~/.hashcat/hashcat.potfile

# 合并多个 potfiles
cat potfile1 potfile2 | sort | uniq > combined.potfile
```

### **5. 正则表达式和高级规则**

```bash
# 规则文件高级用法
# 组合多个转换

# 示例规则链：
# 首字母大写 + 末尾加四位数字
c $?d $?d $?d $?d

# 反转单词 + 末尾加特殊字符
r $!

# 所有转小写 + 在特定位置插入
l i0@ i2!

# 高级规则生成脚本
cat > advanced_rule.rule << 'EOF'
# Comment line
:
u
l
c
$1 $2 $3
^@ ^# 
/password/ replace
EOF

hashcat -m 0 -a 0 hash.txt wordlist.txt -r advanced_rule.rule
```

### **6. 会话优化和恢复**

```bash
# 创建多个并行会话
hashcat -m 0 -a 0 hash.txt wordlist.txt --session=session1 -s 0 -l 1000000
hashcat -m 0 -a 0 hash.txt wordlist.txt --session=session2 -s 1000000 -l 1000000

# 监控会话状态
hashcat --session=session1 -s 0

# 恢复所有中断的会话
for session in $(hashcat --session-list | grep -oP '\Ksession\w+'); do
    hashcat --session=$session --restore
done

# 合并会话结果
cat potfile1 potfile2 | sort -u > merged.potfile
```

### **7. GPU 优化技巧**

```bash
# NVIDIA GPU 优化
# 检查 GPU 信息
nvidia-smi -q

# 设置 GPU 性能模式
nvidia-smi -pm 1

# 手动设置 GPU 频率
nvidia-smi -lgc 1410    # 设置锁定时钟

# AMD GPU 优化
# 查看 GPU 信息
rocm-smi

# 设置性能模式
rocm-smi --setsclk 7    # 设置性能等级

# hashcat GPU 优化
hashcat -m 0 hash.txt wordlist.txt -w 4 -O -d 2 --workload-profile=4

# 禁用驱动程序过度扫描
export CUDA_DEVICE_ORDER=PCI_BUS_ID
hashcat -m 0 hash.txt wordlist.txt
```

### **8. CPU 优化**

```bash
# 降低 CPU 使用率
hashcat -m 0 hash.txt wordlist.txt --spin-damp=10

# 多线程配置
export OMP_NUM_THREADS=8
hashcat -m 0 hash.txt wordlist.txt -D 1

# CPU 基准
hashcat -b -m 0 -D 1

# 使用所有 CPU 核心
taskset -c 0-15 hashcat -m 0 hash.txt wordlist.txt
```

### **9. 内存优化**

```bash
# 检查内存使用
hashcat -m 0 hash.txt --status

# 限制内存使用（调整工作负载）
hashcat -m 3200 -w 1 hash.txt wordlist.txt  # bcrypt 低内存

# 使用字典文件流处理
# 对于超大字典：
head -n 1000000 huge_dict.txt | hashcat -m 0 hash.txt

# 分块处理大字典
split -l 1000000 huge_dict.txt dict_chunk_
for chunk in dict_chunk_*; do
    hashcat -m 0 hash.txt $chunk
done
```

### **10. 容错和错误处理**

```bash
# 设置错误恢复
hashcat -m 0 hash.txt wordlist.txt --potfile-disable

# 使用临时 potfile
hashcat -m 0 hash.txt wordlist.txt --potfile-path=/tmp/temp.potfile

# 验证破解结果
hashcat -m 0 hash.txt --show --remove

# 记录所有操作
hashcat -m 0 hash.txt wordlist.txt --logfile=hashcat.log

# 调试模式
hashcat -m 0 hash.txt wordlist.txt --debug-mode=1 --debug-file=debug.log
```

## 十、常见问题和解决方案

### **1. 哈希识别问题**

```bash
# 问题：无法识别哈希格式
# 解决方案 1：使用 hash-identifier
hash-identifier "your_hash"

# 解决方案 2：尝试多个模式
for mode in 0 100 1400 1700 3200 500; do
    echo "尝试模式 $mode"
    hashcat -m $mode -a 0 hash.txt wordlist.txt --potfile-disable
done

# 解决方案 3：检查哈希长度
echo -n "hash_string" | wc -c
# 32 chars = MD5/MD4
# 40 chars = SHA1
# 64 chars = SHA256/MD5(MD5(...))
# 128 chars = SHA512
```

### **2. 性能问题**

```bash
# 问题：破解速度慢
# 解决方案 1：增加工作负载
hashcat -m 0 hash.txt wordlist.txt -w 4 -O

# 解决方案 2：使用 GPU
hashcat -m 0 hash.txt wordlist.txt -d 2

# 解决方案 3：优化字典
grep -v '^.\{0,5\} wordlist.txt > optimized.txt

# 解决方案 4：使用更快的算法
# 避免 bcrypt/scrypt，使用 MD5/SHA1
```

### **3. GPU 不被识别**

```bash
# 问题：GPU 设备不显示
# 解决方案 1：检查驱动
nvidia-smi    # NVIDIA
rocm-smi      # AMD

# 解决方案 2：强制使用 CPU
hashcat -D 1 hash.txt wordlist.txt

# 解决方案 3：更新驱动和 hashcat
hashcat --version
# 更新到最新版本

# 解决方案 4：检查计算能力
nvidia-smi -L   # 查看 GPU 型号
```

### **4. 内存不足**

```bash
# 问题：Out of Memory 错误
# 解决方案 1：降低工作负载
hashcat -w 1 hash.txt wordlist.txt

# 解决方案 2：使用标准内核而非优化内核
hashcat hash.txt wordlist.txt  # 不使用 -O

# 解决方案 3：分批处理
split -l 100000 large_dict.txt dict_
for part in dict_*; do
    hashcat -m 0 hash.txt $part
done

# 解决方案 4：限制密码长度
hashcat --pw-max=12 hash.txt wordlist.txt
```

### **5. 破解进度丢失**

```bash
# 问题：重新启动后进度丢失
# 解决方案 1：使用会话
hashcat --session=mysession hash.txt wordlist.txt
# 中断后恢复
hashcat --session=mysession --restore

# 解决方案 2：备份 potfile
cp ~/.hashcat/hashcat.potfile ~/.hashcat/hashcat.potfile.bak

# 解决方案 3：保存进度信息
hashcat --status-json > status.json
```

### **6. 特定算法无法破解**

```bash
# bcrypt 太慢的解决方案
# 减少工作负载但增加迭代
hashcat -m 3200 -w 1 hash.txt wordlist.txt

# WPA 破解不成功
# 确保握手包完整
hashcat -m 22000 capture.hc22000 wordlist.txt --status-timer=1

# 加盐哈希无法识别格式
# 检查盐值位置：hash$salt 或 salt$hash
hashcat -m 10 hash.txt wordlist.txt  # md5($pass.$salt)
hashcat -m 20 hash.txt wordlist.txt  # md5($salt.$pass)
```

## 十一、安全和最佳实践

### **1. 合法性和伦理**

```bash
# 只在以下情况下使用 Hashcat：
# 1. 你有明确的授权和合法权利
# 2. 测试自己的系统
# 3. 安全审计和渗透测试（获得许可）
# 4. 学习和研究目的

# 保持审计日志
hashcat -m 0 hash.txt wordlist.txt --logfile=audit.log
```

### **2. 隐私保护**

```bash
# 处理破解结果时保护隐私
# 安全删除中间文件
shred -vfz -n 5 temp_dict.txt

# 加密敏感信息
gpg --encrypt cracked_passwords.txt

# 安全处理 potfile
chmod 600 ~/.hashcat/hashcat.potfile
```

### **3. 安全存储**

```bash
# 安全备份结果
tar czf results.tar.gz cracked/
gpg -c results.tar.gz

# 安全删除临时文件
find . -name "*.tmp" -exec shred -vfz {} \;

# 审计日志
hashcat -m 0 hash.txt wordlist.txt --logfile=hashcat_audit.log
```

## 十二、脚本和自动化

### **1. 自动识别和破解**

```bash
#!/bin/bash
# auto_crack.sh - 自动识别和破解脚本

HASH=$1
WORDLIST=${2:-rockyou.txt}
RULES=${3:-rules/best64.rule}

if [ -z "$HASH" ]; then
    echo "用法: $0 <哈希> [字典] [规则]"
    exit 1
fi

echo "[*] 正在识别哈希类型..."
HASHTYPE=$(hashid -e "$HASH" 2>/dev/null | grep -oP 'Hashcat mode: \K\d+' | head -1)

if [ -z "$HASHTYPE" ]; then
    echo "[!] 无法识别哈希类型"
    exit 1
fi

echo "[+] 识别的模式号: $HASHTYPE"
echo "[*] 开始破解..."

hashcat -m "$HASHTYPE" -a 0 "$HASH" "$WORDLIST" -r "$RULES" -w 3
```

### **2. 批量破解脚本**

```bash
#!/bin/bash
# batch_crack.sh - 批量破解脚本

HASHFILE=$1
WORDLIST=${2:-rockyou.txt}
MODE=${3:-0}

if [ ! -f "$HASHFILE" ]; then
    echo "哈希文件不存在"
    exit 1
fi

echo "[*] 开始批量破解..."
echo "[*] 哈希文件: $HASHFILE"
echo "[*] 字典: $WORDLIST"
echo "[*] 模式: $MODE"

hashcat -m "$MODE" -a 0 "$HASHFILE" "$WORDLIST" -o results.txt --outfile-format=3

echo "[+] 破解完成"
echo "[*] 查看结果:"
hashcat -m "$MODE" "$HASHFILE" --show
```

### **3. 性能监控脚本**

```bash
#!/bin/bash
# monitor_hashcat.sh - 实时监控脚本

while true; do
    clear
    echo "=== Hashcat 性能监控 ==="
    echo "时间: $(date)"
    echo ""
    
    # GPU 监控
    echo "--- GPU 状态 ---"
    nvidia-smi --query-gpu=name,utilization.gpu,utilization.memory,temperature.gpu --format=csv,noheader
    
    echo ""
    echo "--- Hashcat 状态 ---"
    
    # 查找正在运行的 hashcat 进程
    ps aux | grep hashcat | grep -v grep
    
    sleep 5
done
```

### **4. 字典生成脚本**

```bash
#!/bin/bash
# generate_dict.sh - 生成自定义字典

TARGET="$1"
OUTPUT="$2"

# 从目标生成相关词汇
echo "[*] 生成字典..."

# 基本信息
echo "$TARGET" > "$OUTPUT"
echo "${TARGET}1" >> "$OUTPUT"
echo "${TARGET}123" >> "$OUTPUT"
echo "${TARGET}2024" >> "$OUTPUT"
echo "${TARGET}!" >> "$OUTPUT"
echo "${TARGET}@" >> "$OUTPUT"

# 常见密码组合
echo "123456" >> "$OUTPUT"
echo "password" >> "$OUTPUT"
echo "admin" >> "$OUTPUT"
echo "qwerty" >> "$OUTPUT"

# 大小写变化
echo "$(echo $TARGET | tr '[:lower:]' '[:upper:]')" >> "$OUTPUT"
echo "$(echo $TARGET | sed 's/^./\U&/')" >> "$OUTPUT"

echo "[+] 字典已生成: $OUTPUT"
```

## 十三、参考资源

### **官方文档**
- Hashcat 官网: https://hashcat.net/
- Hashcat GitHub: https://github.com/hashcat/hashcat
- Hashcat 论坛: https://hashcat.net/forum/

### **工具和实用程序**
- John the Ripper: https://www.openwall.com/john/
- Hashid: https://github.com/psypanda/hashID
- Hash-Identifier: https://github.com/psypanda/hash-identifier
- Mask Processor: https://github.com/hashcat/maskprocessor

### **字典资源**
- RockYou: 常用字典
- SecLists: https://github.com/danielmiessler/SecLists
- Weakpass: https://weakpass.com/
- CrackStation: https://crackstation.net/

### **规则文件**
- best64.rule：推荐规则
- dive.rule：深度规则集
- InsidePro-PasswordsPro.rule：专业规则
- osint.rule：开源情报规则
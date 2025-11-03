# OpenSSL详细使用指南

## 一、OpenSSL简介

OpenSSL是一个强大的安全套接字层密码库，包含各种密码算法、常用的密钥和证书封装管理功能以及SSL协议。

### 安装OpenSSL
```bash
# Ubuntu/Debian
sudo apt-get install openssl

# CentOS/RHEL/Fedora
sudo yum install openssl

# 查看版本
openssl version
```

## 二、基础命令结构

```bash
openssl [command] [options] [arguments]
```

### 查看帮助
```bash
# 查看所有可用命令
openssl help

# 查看特定命令帮助
openssl enc -help
openssl rsa -help
```

## 三、常用功能模块

### 1. 对称加密/解密

#### AES加密文件
```bash
# 加密文件
openssl enc -aes-256-cbc -salt -in file.txt -out file.txt.enc -k password

# 使用base64编码输出
openssl enc -aes-256-cbc -salt -in file.txt -out file.txt.enc -k password -base64

# 解密文件
openssl enc -d -aes-256-cbc -in file.txt.enc -out file.txt -k password
```

#### 其他加密算法
```bash
# DES加密
openssl enc -des3 -salt -in file.txt -out file.txt.enc

# Blowfish加密
openssl enc -bf -salt -in file.txt -out file.txt.enc
```

### 2. 哈希/摘要操作

```bash
# MD5
openssl dgst -md5 file.txt
echo -n "hello" | openssl dgst -md5

# SHA系列
openssl dgst -sha1 file.txt
openssl dgst -sha256 file.txt
openssl dgst -sha512 file.txt

# 生成HMAC
openssl dgst -sha256 -hmac "secret_key" file.txt
```

### 3. Base64编码/解码

```bash
# 编码
echo "Hello World" | openssl base64
openssl base64 -in file.txt -out file.b64

# 解码
echo "SGVsbG8gV29ybGQ=" | openssl base64 -d
openssl base64 -d -in file.b64 -out file.txt
```

### 4. 生成随机数

```bash
# 生成随机数（十六进制）
openssl rand -hex 32

# 生成随机数（base64）
openssl rand -base64 32

# 生成随机密码
openssl rand -base64 12
```

### 5. RSA密钥操作

#### 生成RSA密钥对
```bash
# 生成私钥
openssl genrsa -out private.key 2048

# 生成加密的私钥
openssl genrsa -aes256 -out private.key 2048

# 从私钥生成公钥
openssl rsa -in private.key -pubout -out public.key

# 查看私钥信息
openssl rsa -in private.key -text -noout

# 验证私钥
openssl rsa -in private.key -check
```

#### RSA加密/解密
```bash
# 使用公钥加密
openssl rsautl -encrypt -inkey public.key -pubin -in file.txt -out file.enc

# 使用私钥解密
openssl rsautl -decrypt -inkey private.key -in file.enc -out file.txt
```

### 6. 数字签名

```bash
# 生成签名
openssl dgst -sha256 -sign private.key -out signature.bin file.txt

# 验证签名
openssl dgst -sha256 -verify public.key -signature signature.bin file.txt
```

## 四、证书操作

### 1. 生成自签名证书

```bash
# 一步生成私钥和自签名证书
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes

# 分步操作
# 1. 生成私钥
openssl genrsa -out server.key 2048

# 2. 生成证书请求
openssl req -new -key server.key -out server.csr

# 3. 生成自签名证书
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```

### 2. 查看证书信息

```bash
# 查看证书内容
openssl x509 -in cert.pem -text -noout

# 查看证书有效期
openssl x509 -in cert.pem -noout -dates

# 查看证书主题
openssl x509 -in cert.pem -noout -subject

# 查看证书指纹
openssl x509 -in cert.pem -noout -fingerprint -sha256
```

### 3. 证书格式转换

```bash
# PEM转DER
openssl x509 -in cert.pem -outform DER -out cert.der

# DER转PEM
openssl x509 -in cert.der -inform DER -out cert.pem

# PEM转PKCS#12
openssl pkcs12 -export -out cert.p12 -inkey key.pem -in cert.pem

# PKCS#12转PEM
openssl pkcs12 -in cert.p12 -out cert.pem -nodes
```

## 五、SSL/TLS连接测试

### 1. 测试HTTPS连接

```bash
# 连接到HTTPS服务器
openssl s_client -connect www.example.com:443

# 显示证书链
openssl s_client -connect www.example.com:443 -showcerts

# 指定协议版本
openssl s_client -connect www.example.com:443 -tls1_2

# 测试特定密码套件
openssl s_client -connect www.example.com:443 -cipher 'ECDHE-RSA-AES256-GCM-SHA384'
```

### 2. 获取服务器证书

```bash
# 下载服务器证书
echo | openssl s_client -connect www.example.com:443 2>/dev/null | \
  openssl x509 -out example.crt

# 获取证书信息
echo | openssl s_client -connect www.example.com:443 2>/dev/null | \
  openssl x509 -noout -text
```

## 六、实用脚本示例

### 1. 批量加密文件
```bash
#!/bin/bash
for file in *.txt; do
    openssl enc -aes-256-cbc -salt -in "$file" -out "$file.enc" -k mypassword
    rm "$file"
done
```

### 2. 生成SSL证书脚本
```bash
#!/bin/bash
# 生成SSL证书的自动化脚本

DOMAIN="example.com"
DAYS=365

# 生成私钥
openssl genrsa -out ${DOMAIN}.key 2048

# 生成CSR
openssl req -new -key ${DOMAIN}.key -out ${DOMAIN}.csr \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=Company/OU=IT/CN=${DOMAIN}"

# 生成证书
openssl x509 -req -days ${DAYS} -in ${DOMAIN}.csr \
    -signkey ${DOMAIN}.key -out ${DOMAIN}.crt
```

### 3. 文件完整性检查
```bash
#!/bin/bash
# 生成文件哈希值
find /important/directory -type f -exec openssl dgst -sha256 {} \; > checksums.txt

# 验证文件完整性
while IFS= read -r line; do
    file=$(echo $line | cut -d'=' -f1 | sed 's/SHA256(//' | sed 's/)//') 
    hash=$(echo $line | cut -d'=' -f2 | sed 's/ //')
    current_hash=$(openssl dgst -sha256 "$file" | cut -d'=' -f2 | sed 's/ //')
    if [ "$hash" != "$current_hash" ]; then
        echo "File changed: $file"
    fi
done < checksums.txt
```

## 七、性能测试

```bash
# 测试加密算法速度
openssl speed aes-256-cbc
openssl speed rsa2048
openssl speed sha256

# 测试所有算法
openssl speed
```

## 八、常见应用场景

### 1. 创建密码哈希
```bash
# 创建密码的SHA512哈希（适用于/etc/shadow）
openssl passwd -6 mypassword
```

### 2. 生成SSH密钥对
```bash
# 虽然通常使用ssh-keygen，但OpenSSL也可以
openssl genrsa -out ssh_key 2048
openssl rsa -in ssh_key -pubout > ssh_key.pub
```

### 3. 验证文件签名
```bash
# 创建签名
openssl dgst -sha256 -sign private.key -out file.sig file.txt

# 验证签名
openssl dgst -sha256 -verify public.key -signature file.sig file.txt
```


## 九、-help

### help
```
PS E:\home> openssl help
help:

Standard commands
asn1parse         ca                ciphers           cmp
cms               crl               crl2pkcs7         dgst
dhparam           dsa               dsaparam          ec
ecparam           enc               engine            errstr
fipsinstall       gendsa            genpkey           genrsa
help              info              kdf               list
mac               nseq              ocsp              passwd
pkcs12            pkcs7             pkcs8             pkey
pkeyparam         pkeyutl           prime             rand
rehash            req               rsa               rsautl
s_client          s_server          s_time            sess_id
skeyutl           smime             speed             spkac
srp               storeutl          ts                verify
version           x509

Message Digest commands (see the `dgst' command for more details)
blake2b512        blake2s256        md4               md5
mdc2              rmd160            sha1              sha224
sha256            sha3-224          sha3-256          sha3-384
sha3-512          sha384            sha512            sha512-224
sha512-256        shake128          shake256          sm3

Cipher commands (see the `enc' command for more details)
aes-128-cbc       aes-128-ecb       aes-192-cbc       aes-192-ecb
aes-256-cbc       aes-256-ecb       aria-128-cbc      aria-128-cfb
aria-128-cfb1     aria-128-cfb8     aria-128-ctr      aria-128-ecb
aria-128-ofb      aria-192-cbc      aria-192-cfb      aria-192-cfb1
aria-192-cfb8     aria-192-ctr      aria-192-ecb      aria-192-ofb
aria-256-cbc      aria-256-cfb      aria-256-cfb1     aria-256-cfb8
aria-256-ctr      aria-256-ecb      aria-256-ofb      base64
bf                bf-cbc            bf-cfb            bf-ecb
bf-ofb            camellia-128-cbc  camellia-128-ecb  camellia-192-cbc
camellia-192-ecb  camellia-256-cbc  camellia-256-ecb  cast
cast-cbc          cast5-cbc         cast5-cfb         cast5-ecb
cast5-ofb         des               des-cbc           des-cfb
des-ecb           des-ede           des-ede-cbc       des-ede-cfb
des-ede-ofb       des-ede3          des-ede3-cbc      des-ede3-cfb
des-ede3-ofb      des-ofb           des3              desx
idea              idea-cbc          idea-cfb          idea-ecb
idea-ofb          rc2               rc2-40-cbc        rc2-64-cbc
rc2-cbc           rc2-cfb           rc2-ecb           rc2-ofb
rc4               rc4-40            seed              seed-cbc
seed-cfb          seed-ecb          seed-ofb          sm4-cbc
sm4-cfb           sm4-ctr           sm4-ecb           sm4-ofb

PS E:\home>
```

### rsa

```
PS E:\home> openssl rsa -help
用法: rsa [选项]

通用选项:
 -help               显示此帮助信息
 -check              校验密钥一致性
 -*                  任意支持的加密算法
 -engine val         使用指定的引擎，可能是硬件设备

输入选项:
 -in val             输入文件
 -inform format      输入格式 (DER/PEM/P12/ENGINE)
 -pubin              输入文件中为公钥
 -RSAPublicKey_in    输入为 RSAPublicKey
 -passin val         输入文件的口令来源

输出选项:
 -out outfile        输出文件
 -outform format     输出格式，可选 DER PEM PVK
 -pubout             输出公钥
 -RSAPublicKey_out   输出为 RSAPublicKey
 -passout val        输出文件的口令来源
 -noout              不输出密钥
 -text               以文本方式打印密钥
 -modulus            打印 RSA 密钥的模数
 -traditional        使用传统格式输出私钥

PVK 选项:
 -pvk-strong         启用“强”PVK 编码级别（默认）
 -pvk-weak           启用“弱”PVK 编码级别
 -pvk-none           不强制使用 PVK 编码

Provider（提供程序）选项:
 -provider-path val  提供程序加载路径（如需使用，应在 'provider' 参数之前指定）
 -provider val       要加载的提供程序（可多次指定）
 -provparam val      设置提供程序键值参数
 -propquery val      获取算法时使用的属性查询
PS E:\home>

```

### rsautl

```
PS E:\home> openssl rsautl -help
命令 rsautl 在版本 3.0 中已被弃用。请使用 'pkeyutl' 替代。
用法: rsautl [选项]

通用选项:
 -help                    显示此帮助信息
 -sign                    使用私钥签名
 -verify                  使用公钥验证
 -encrypt                 使用公钥加密
 -decrypt                 使用私钥解密
 -engine val              使用指定的引擎，可能是硬件设备

输入选项:
 -in infile               输入文件
 -inkey val               输入密钥，默认是 RSA 私钥
 -keyform PEM|DER|ENGINE  私钥格式 (ENGINE，其他值将被忽略)
 -pubin                   输入密钥为 RSA 公钥
 -certin                  输入为包含 RSA 公钥的证书
 -rev                     反转输入缓冲区顺序
 -passin val              输入文件的口令来源

输出选项:
 -out outfile             输出文件
 -raw                     不使用填充
 -pkcs                    使用 PKCS#1 v1.5 填充（默认）
 -x931                    使用 ANSI X9.31 填充
 -oaep                    使用 PKCS#1 OAEP 填充
 -asn1parse               将输出通过 asn1parse 处理；与 -verify 搭配使用
 -hexdump                 十六进制输出

随机数状态选项:
 -rand val                将指定文件加载到随机数生成器
 -writerand outfile       将随机数据写入指定文件

提供程序选项:
 -provider-path val       提供程序加载路径（如需使用，应在 'provider' 参数之前指定）
 -provider val            要加载的提供程序（可多次指定）
 -provparam val           设置提供程序键值参数
 -propquery val           获取算法时使用的属性查询
PS E:\home>

```

### pkeyutl

```
PS E:\home> openssl pkeyutl -help
用法: pkeyutl [选项]

通用选项:
 -help                     显示此帮助信息
 -engine val               使用指定的引擎，可能是硬件设备
 -engine_impl              对加密操作也使用由 -engine 指定的引擎
 -sign                     使用私钥对输入数据进行签名
 -verify                   使用公钥进行验证
 -encrypt                  使用公钥加密输入数据
 -decrypt                  使用私钥解密输入数据
 -derive                   从自身与对方的 (EC)DH 密钥派生共享密钥
 -decap                    解封共享密钥
 -encap                    封装共享密钥
 -config infile            加载配置文件（可能会加载模块）

输入选项:
 -in infile                输入文件 - 默认 stdin
 -inkey val                输入密钥，默认为私钥
 -pubin                    输入密钥为公钥
 -passin val               输入文件的口令来源
 -peerkey val              密钥派生使用的对方密钥文件
 -peerform PEM|DER|ENGINE  对方密钥格式 (DER/PEM/P12/ENGINE)
 -certin                   输入为包含公钥的证书
 -rev                      反转输入缓冲区顺序
 -sigfile infile           签名文件（仅在验证操作中使用）
 -keyform PEM|DER|ENGINE   私钥格式（ENGINE，其他值将被忽略）

输出选项:
 -out outfile              输出文件 - 默认 stdout
 -secret outfile           封装操作存储共享密钥的文件
 -asn1parse                将输出解析为 ASN.1 数据，以检查其 DER 编码并打印错误
 -hexdump                  十六进制输出
 -verifyrecover            验证 RSA 签名，同时恢复原始签名输入数据

签名/派生/封装选项:
 -rawin                    指示签名/验证输入数据尚未哈希
 -digest val               对未哈希输入数据进行签名/验证时使用的摘要算法（隐含 -rawin）
 -pkeyopt val              公钥选项，格式为 opt:value
 -pkeyopt_passin val       公钥选项，以口令参数形式读取，格式为 opt:passphrase
 -kdf val                  使用的 KDF 算法
 -kdflen +int              KDF 输出长度
 -kemop val                与密钥算法相关的 KEM 操作

随机数状态选项:
 -rand val                 将指定文件加载到随机数生成器
 -writerand outfile        将随机数据写入指定文件

提供程序选项:
 -provider-path val        提供程序加载路径（如需使用，应在 'provider' 参数之前指定）
 -provider val             要加载的提供程序（可多次指定）
 -provparam val            设置提供程序键值参数
 -propquery val            获取算法时使用的属性查询
PS E:\home>

```

### enc

```
PS E:\home> openssl enc -help
用法: enc [选项]

通用选项:
 -help               显示此帮助信息
 -list               列出支持的加密算法
 -ciphers            等同于 -list
 -e                  加密
 -d                  解密
 -p                  打印 IV/密钥
 -P                  打印 IV/密钥后退出
 -engine val         使用指定的引擎，可能是硬件设备

输入选项:
 -in infile          输入文件
 -k val              口令
 -kfile infile       从文件读取口令

输出选项:
 -out outfile        输出文件
 -pass val           口令来源
 -v                  显示详细信息
 -a                  根据加密/解密标志进行 Base64 编码/解码
 -base64             等同于 -a
 -A                  与 -[base64|a] 搭配使用，将 Base64 缓冲区输出为单行

加密选项:
 -nopad              禁用标准块填充
 -salt               在密钥派生函数 (KDF) 中使用盐（默认）
 -nosalt             不在密钥派生函数中使用盐
 -debug              打印调试信息
 -bufsize val        缓冲区大小
 -K val              原始密钥，十六进制表示
 -S val              盐值，十六进制表示
 -iv val             初始化向量 (IV)，十六进制表示
 -md val             使用指定摘要算法从口令生成密钥
 -iter +int          指定迭代次数并强制使用 PBKDF2  
                     默认：10000
 -pbkdf2             使用基于口令的密钥派生函数 2 (PBKDF2)  
                     可通过 -iter 修改迭代次数（默认 10000）
 -none               不进行加密
 -saltlen +int       指定 PBKDF2 盐的长度（字节数）  
                     默认：16
 -skeyopt val        针对不透明对称密钥处理的键选项，格式为 opt:value
 -skeymgmt val       针对不透明对称密钥处理的对称密钥管理名称
 -*                  任意支持的加密算法

随机数状态选项:
 -rand val           将指定文件加载到随机数生成器
 -writerand outfile  将随机数据写入指定文件

提供程序选项:
 -provider-path val  提供程序加载路径（如需使用，应在 'provider' 参数之前指定）
 -provider val       要加载的提供程序（可多次指定）
 -provparam val      设置提供程序键值参数
 -propquery val      获取算法时使用的属性查询
PS E:\home>

```

### dgst

```
PS E:\home> openssl dgst -help
用法: dgst [选项] [文件...]

通用选项:
 -help               显示此帮助信息
 -list               列出支持的摘要算法
 -engine val         使用指定的引擎，可能是硬件设备
 -engine_impl        对摘要操作也使用由 -engine 指定的引擎
 -passin val         输入文件的口令来源

输出选项:
 -c                  以冒号分隔的形式打印摘要
 -r                  以 coreutils 格式打印摘要
 -out outfile        输出到指定文件，而非 stdout
 -keyform format     密钥文件格式（ENGINE，其他值将被忽略）
 -hex                以十六进制打印
 -binary             以二进制形式打印
 -xoflen +int        XOF 算法输出长度。若需获得最大安全强度，对于 SHAKE128 设置 32（或更大），对于 SHAKE256 设置 64（或更大）
 -d                  打印调试信息
 -debug              打印调试信息

签名选项:
 -sign val           使用私钥对摘要进行签名
 -verify val         使用公钥验证签名
 -prverify val       使用私钥验证签名
 -sigopt val         签名参数，格式为 n:v
 -signature infile   包含签名的文件，用于验证
 -hmac val           使用密钥生成哈希 MAC
 -mac val            生成 MAC（不一定是 HMAC）
 -macopt val         MAC 算法参数，格式为 n:v 或密钥
 -*                  任意支持的摘要算法
 -fips-fingerprint   使用 OpenSSL-FIPS 指纹的密钥计算 HMAC

随机数状态选项:
 -rand val           将指定文件加载到随机数生成器
 -writerand outfile  将随机数据写入指定文件

提供程序选项:
 -provider-path val  提供程序加载路径（如需使用，应在 'provider' 参数之前指定）
 -provider val       要加载的提供程序（可多次指定）
 -provparam val      设置提供程序键值参数
 -propquery val      获取算法时使用的属性查询

参数:
 file                待计算摘要的文件（可选，默认 stdin）
PS E:\home>

```
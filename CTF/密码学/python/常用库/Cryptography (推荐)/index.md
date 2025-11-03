## Python Cryptography库功能详解

Python的`cryptography`库是一个功能强大的密码学工具包，提供了现代密码学的各种实现。以下是其主要功能：

## 1. **对称加密（Symmetric Encryption）**

### 支持的算法
- **AES** (Advanced Encryption Standard)
- **3DES** (Triple DES)
- **Camellia**
- **CAST5**
- **SEED**
- **ChaCha20**
- **Blowfish**

### 加密模式
- CBC (Cipher Block Chaining)
- CTR (Counter)
- OFB (Output Feedback)
- CFB/CFB8 (Cipher Feedback)
- GCM (Galois/Counter Mode)
- XTS (XEX-based tweaked-codebook)
- ECB (Electronic Codebook)

```python
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
# 可以实现文件加密、数据加密、流加密等
```

## 2. **非对称加密（Asymmetric Encryption）**

### RSA加密
- 密钥生成（支持不同密钥长度）
- 加密/解密
- 签名/验证
- PKCS#1 v1.5和OAEP填充

### 椭圆曲线加密（ECC）
- ECDSA签名
- ECDH密钥交换
- 支持多种曲线（P-256, P-384, P-521, secp256k1等）

### DSA（数字签名算法）
- 密钥生成
- 签名生成和验证

### Diffie-Hellman密钥交换
- 密钥协商
- 参数生成

## 3. **哈希函数（Hash Functions）**

### 支持的算法
- **SHA系列**: SHA-1, SHA-224, SHA-256, SHA-384, SHA-512
- **SHA-3系列**: SHA3-224, SHA3-256, SHA3-384, SHA3-512
- **BLAKE2**: BLAKE2b, BLAKE2s
- **MD5** (不推荐用于安全场景)
- **SHAKE**: SHAKE128, SHAKE256

```python
from cryptography.hazmat.primitives import hashes
# 可用于数据完整性验证、密码存储、数字指纹等
```

## 4. **消息认证码（MAC）**

### HMAC
- 基于哈希的消息认证码
- 支持各种哈希算法

### CMAC
- 基于密码的消息认证码
- 支持AES和3DES

### Poly1305
- 高性能消息认证码

## 5. **密钥派生函数（KDF）**

### PBKDF2
- 基于密码的密钥派生
- 用于密码存储和验证

### scrypt
- 内存密集型KDF
- 抗ASIC攻击

### HKDF
- 基于HMAC的密钥派生函数
- 用于密钥扩展

### Argon2
- 最新的密码哈希竞赛获胜者
- 高度安全的密码存储

## 6. **X.509证书处理**

### 证书操作
- 生成证书签名请求（CSR）
- 创建自签名证书
- 证书链验证
- 证书撤销列表（CRL）处理

### 证书解析
- 读取证书信息
- 提取公钥
- 验证证书有效期
- 检查证书扩展

```python
from cryptography import x509
from cryptography.x509.oid import NameOID
# 可用于SSL/TLS证书管理、PKI基础设施等
```

## 7. **Fernet（高级对称加密）**

### 简化的加密API
- 自动处理密钥生成
- 包含时间戳
- 自动验证数据完整性
- URL安全的base64编码

```python
from cryptography.fernet import Fernet
# 适合快速实现安全的数据加密
```

## 8. **密码学原语（Primitives）**

### 随机数生成
- 加密安全的随机数
- 用于生成密钥、IV、盐值等

### 填充方案
- PKCS7
- ANSIX923
- ISO10126

### 密钥包装
- AES密钥包装
- RFC 3394实现

## 9. **实际应用场景**

### 数据保护
- 文件加密/解密
- 数据库字段加密
- 通信加密

### 身份认证
- 密码安全存储
- 令牌生成
- 双因素认证实现

### 数字签名
- 文档签名
- 代码签名
- 消息验证

### SSL/TLS
- 证书生成和管理
- 自定义TLS实现
- 证书固定（Certificate Pinning）

### 区块链和加密货币
- 地址生成
- 交易签名
- 密钥管理

## 10. **特殊功能**

### 一次性密码（OTP）
- TOTP（基于时间）
- HOTP（基于计数器）

### 密钥序列化
- PEM格式
- DER格式
- OpenSSH格式

### 危险材料层（Hazmat）
- 底层密码学原语访问
- 自定义密码学实现
- 高级用户定制功能

## 安装和使用示例

```python
# 安装
pip install cryptography

# 基础加密示例
from cryptography.fernet import Fernet

# 生成密钥
key = Fernet.generate_key()
f = Fernet(key)

# 加密
token = f.encrypt(b"Secret message")

# 解密
original = f.decrypt(token)
```

## 注意事项

1. **安全性**: 使用经过验证的算法和模式
2. **性能**: 某些操作（如scrypt）可能消耗大量资源
3. **兼容性**: 确保与其他系统的互操作性
4. **密钥管理**: 安全存储和传输密钥
5. **更新**: 定期更新库以获取安全补丁

`cryptography`库是Python中最全面、最安全的密码学解决方案，适用于从简单的数据加密到复杂的PKI系统的各种场景。
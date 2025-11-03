# AES加密完整指南

## 一、AES 核心概念

在使用 AES 之前，必须理解以下几个基本组件：

### 1. AES (Advanced Encryption Standard)

- 它是一种**块加密 (Block Cipher)** 算法
- 操作的数据单元是固定大小的**块 (Block)**
- 对于 AES，块大小始终是 **128位 (16字节)**
- AES 于 2001 年被美国国家标准与技术研究院(NIST)选为加密标准，取代了旧的 DES 算法

### 2. 密钥 (Key)

- 用于加密和解密的秘密
- AES 支持三种密钥长度：
    - **AES-128**: 128位 (16字节) - 快速，安全性足够应对大多数场景
    - **AES-192**: 192位 (24字节) - 中等强度
    - **AES-256**: 256位 (32字节) - 最高安全级别，政府机密文档常用
- 密钥**必须**通过安全的随机源生成，例如 `os.urandom()` 或 `secrets` 模块
- **密钥管理**是加密系统中最关键的环节，密钥泄露意味着整个系统崩溃

### 3. 加密模式 (Mode of Operation)

- AES 只能加密单个 16 字节的块，需要"配方"来处理任意长度的数据
- 不同的模式有不同的特性：
    - 对错误的处理方式
    - 是否可以并行计算
    - 是否提供完整性验证
- **这是使用块加密时最关键的选择之一**

### 4. 初始化向量 (IV) 或 Nonce

- 随机或伪随机数，确保相同明文+相同密钥产生不同密文
- **黄金规则：对于同一个密钥，绝不能重复使用相同的 IV/Nonce！**
- 重用会导致灾难性的安全后果（如密文可被分析破解）
- IV/Nonce 不需要保密，但必须与密文一起传输
- 大小通常为 12-16 字节，取决于模式

### 5. 填充 (Padding)

- 当明文长度不是 16 字节整数倍时需要填充
- **PKCS7** 是最常用的填充方案：
    - 如果需要填充 n 个字节，每个填充字节的值都是 n
    - 例如：需填充 5 字节，则填充 `0x05 0x05 0x05 0x05 0x05`
- 某些模式（CTR、GCM）不需要填充

### 6. 认证标签 (Authentication Tag)

- 在 **AEAD (Authenticated Encryption with Associated Data)** 模式中生成
- 用于验证密文的**完整性**和**真实性**
- 防止密文在传输中被篡改或伪造
- 现代密码学的核心特性

---

## 二、环境准备

### 安装依赖

```bash
pip install cryptography
```

### 导入模块

```python
import os
import secrets
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding, hashes, hmac
from cryptography.hazmat.backends import default_backend
from base64 import b64encode, b64decode

backend = default_backend()
```

### 密钥生成最佳实践

```python
# 方法 1: 使用 os.urandom()
key_256 = os.urandom(32)  # AES-256

# 方法 2: 使用 secrets 模块 (Python 3.6+，更推荐)
key_256 = secrets.token_bytes(32)

# 从密码派生密钥 (使用 PBKDF2)
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

password = b"user_password"
salt = os.urandom(16)  # 盐值必须存储，解密时需要

kdf = PBKDF2HMAC(
    algorithm=hashes.SHA256(),
    length=32,
    salt=salt,
    iterations=480000,  # OWASP 2023 推荐值
    backend=backend
)
derived_key = kdf.derive(password)
```

---

## 三、加密模式实战

### 准备测试数据

```python
# 准备密钥和明文
key = secrets.token_bytes(32)
plaintext = b"This is a top secret message for detailed AES explanation."
```

---

### 模式一：CBC (Cipher Block Chaining)

**特点**：经典模式，但需谨慎使用

**原理**：将前一个密文块与下一个明文块进行异或操作后再加密

**需要**：Key + IV + Padding

⚠️ **安全警告**：

- CBC **不提供完整性验证**
- 容易遭受**填充预言攻击 (Padding Oracle Attack)**
- 如果使用 CBC，必须配合 HMAC 等 MAC 算法

#### 加密过程

```python
# 1. 生成随机 IV (16 字节)
iv = os.urandom(16)

# 2. 创建 Cipher 对象
cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=backend)
encryptor = cipher.encryptor()

# 3. PKCS7 填充
padder = padding.PKCS7(algorithms.AES.block_size).padder()
padded_data = padder.update(plaintext) + padder.finalize()

# 4. 加密
ciphertext = encryptor.update(padded_data) + encryptor.finalize()

print(f"CBC - IV (hex): {iv.hex()}")
print(f"CBC - Ciphertext (hex): {ciphertext.hex()}")

# 存储格式: IV + Ciphertext (方便传输)
stored_data = iv + ciphertext
```

#### 解密过程

```python
# 1. 提取 IV 和密文
iv = stored_data[:16]
ciphertext = stored_data[16:]

# 2. 创建解密器
decrypt_cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=backend)
decryptor = decrypt_cipher.decryptor()

# 3. 解密
padded_decrypted_data = decryptor.update(ciphertext) + decryptor.finalize()

# 4. 去除填充
unpadder = padding.PKCS7(algorithms.AES.block_size).unpadder()
decrypted_data = unpadder.update(padded_decrypted_data) + unpadder.finalize()

print(f"CBC - Decrypted: {decrypted_data}")
assert plaintext == decrypted_data
```

#### CBC + HMAC 组合（安全实现）

```python
def encrypt_cbc_hmac(key_enc, key_mac, plaintext):
    """CBC 加密 + HMAC 完整性保护"""
    # 1. CBC 加密
    iv = os.urandom(16)
    cipher = Cipher(algorithms.AES(key_enc), modes.CBC(iv), backend=backend)
    encryptor = cipher.encryptor()
    
    padder = padding.PKCS7(128).padder()
    padded = padder.update(plaintext) + padder.finalize()
    ciphertext = encryptor.update(padded) + encryptor.finalize()
    
    # 2. 计算 HMAC (认证 IV + 密文)
    h = hmac.HMAC(key_mac, hashes.SHA256(), backend=backend)
    h.update(iv + ciphertext)
    mac_tag = h.finalize()
    
    # 3. 返回: IV + Ciphertext + MAC
    return iv + ciphertext + mac_tag

def decrypt_cbc_hmac(key_enc, key_mac, data):
    """验证 HMAC 后解密"""
    # 1. 提取各部分
    iv = data[:16]
    mac_tag = data[-32:]  # SHA256 输出 32 字节
    ciphertext = data[16:-32]
    
    # 2. 验证 HMAC
    h = hmac.HMAC(key_mac, hashes.SHA256(), backend=backend)
    h.update(iv + ciphertext)
    try:
        h.verify(mac_tag)
    except:
        raise ValueError("HMAC 验证失败！数据可能被篡改")
    
    # 3. 解密
    cipher = Cipher(algorithms.AES(key_enc), modes.CBC(iv), backend=backend)
    decryptor = cipher.decryptor()
    padded = decryptor.update(ciphertext) + decryptor.finalize()
    
    unpadder = padding.PKCS7(128).unpadder()
    return unpadder.update(padded) + unpadder.finalize()

# 使用示例
key_enc = secrets.token_bytes(32)
key_mac = secrets.token_bytes(32)  # 加密和 MAC 必须使用不同的密钥

encrypted = encrypt_cbc_hmac(key_enc, key_mac, plaintext)
decrypted = decrypt_cbc_hmac(key_enc, key_mac, encrypted)
print(f"CBC+HMAC 解密: {decrypted}")
```

---

### 模式二：CTR (Counter Mode)

**特点**：灵活的流加密模式

**原理**：加密递增的计数器生成密钥流，与明文异或

**需要**：Key + Nonce

**优点**：

- 不需要填充
- 可以并行加密/解密
- 随机访问（可解密任意位置）
- 加密和解密操作相同

⚠️ **致命威胁**：**Nonce 重用是灾难性的！**

- 相同 Key+Nonce 加密两条消息，攻击者可轻易破解
- CTR 不提供完整性验证

#### 加密过程

```python
# 1. 生成随机 Nonce (16 字节)
nonce_ctr = os.urandom(16)

# 2. 创建 Cipher 对象
cipher_ctr = Cipher(algorithms.AES(key), modes.CTR(nonce_ctr), backend=backend)
encryptor_ctr = cipher_ctr.encryptor()

# 3. 加密 (无需填充)
ciphertext_ctr = encryptor_ctr.update(plaintext) + encryptor_ctr.finalize()

print(f"\nCTR - Nonce (hex): {nonce_ctr.hex()}")
print(f"CTR - Ciphertext (hex): {ciphertext_ctr.hex()}")
```

#### 解密过程

```python
# 解密和加密是完全相同的操作
decrypt_cipher_ctr = Cipher(algorithms.AES(key), modes.CTR(nonce_ctr), backend=backend)
decryptor_ctr = decrypt_cipher_ctr.decryptor()

decrypted_data_ctr = decryptor_ctr.update(ciphertext_ctr) + decryptor_ctr.finalize()

print(f"CTR - Decrypted: {decrypted_data_ctr}")
assert plaintext == decrypted_data_ctr
```

#### CTR 的 Nonce 管理策略

```python
import struct

# 策略 1: 完全随机 (简单但需记录所有用过的 Nonce)
nonce_random = os.urandom(16)

# 策略 2: 计数器 (适合大量消息，需持久化计数器)
counter = 1  # 从数据库或文件中读取
nonce_counter = struct.pack('>Q', counter).rjust(16, b'\x00')
counter += 1  # 使用后递增并保存

# 策略 3: 时间戳 + 随机数 (平衡方案)
import time
timestamp = int(time.time())
random_part = os.urandom(8)
nonce_mixed = struct.pack('>Q', timestamp) + random_part
```

---

### 模式三：GCM (Galois/Counter Mode) ⭐ 强烈推荐

**特点**：现代标准，AEAD 模式的典范

**原理**：CTR 模式 + GMAC 认证

**需要**：Key + Nonce + (可选) Associated Data

**优点**：

- ✅ **同时提供保密性、完整性和真实性**
- ✅ 不需要填充
- ✅ 性能优秀（硬件加速支持广泛）
- ✅ TLS 1.3、HTTPS、VPN 等协议的首选

**关联数据 (AAD)** 是什么？ 不加密但需要认证的数据，例如：

- 网络包头（IP、端口）
- 数据库记录的元信息
- API 请求的 HTTP 头

#### 加密过程

```python
# 1. 生成 Nonce (推荐 12 字节)
nonce_gcm = os.urandom(12)

# 2. (可选) 准备关联数据
associated_data = b"metadata that is not encrypted but is authenticated"

# 3. 创建 Cipher 对象
encryptor_gcm = Cipher(
    algorithms.AES(key), 
    modes.GCM(nonce_gcm), 
    backend=backend
).encryptor()

# 4. 添加关联数据
encryptor_gcm.authenticate_additional_data(associated_data)

# 5. 加密
ciphertext_gcm = encryptor_gcm.update(plaintext) + encryptor_gcm.finalize()

# 6. 获取认证标签 (16 字节)
tag = encryptor_gcm.tag

print(f"\nGCM - Nonce (hex): {nonce_gcm.hex()}")
print(f"GCM - Ciphertext (hex): {ciphertext_gcm.hex()}")
print(f"GCM - Tag (hex): {tag.hex()}")

# 存储格式: Nonce + Ciphertext + Tag
stored_gcm = nonce_gcm + ciphertext_gcm + tag
```

#### 解密过程

```python
# 1. 提取各部分
nonce = stored_gcm[:12]
tag = stored_gcm[-16:]
ciphertext = stored_gcm[12:-16]

# 2. 创建解密器 (需要提供 tag)
decryptor_gcm = Cipher(
    algorithms.AES(key), 
    modes.GCM(nonce, tag), 
    backend=backend
).decryptor()

# 3. 添加关联数据 (必须与加密时一致)
decryptor_gcm.authenticate_additional_data(associated_data)

# 4. 解密并验证
try:
    decrypted_data_gcm = decryptor_gcm.update(ciphertext) + decryptor_gcm.finalize()
    print(f"GCM - 解密成功!")
    print(f"GCM - Decrypted: {decrypted_data_gcm}")
    assert plaintext == decrypted_data_gcm
except Exception as e:
    # InvalidTag 异常表示数据被篡改
    print(f"GCM - 解密失败！数据可能被篡改。错误: {e}")
```

#### 演示篡改检测

```python
# 篡改密文
tampered_ciphertext = ciphertext_gcm[:-1] + b'X'

decryptor_tampered = Cipher(
    algorithms.AES(key), 
    modes.GCM(nonce_gcm, tag), 
    backend=backend
).decryptor()
decryptor_tampered.authenticate_additional_data(associated_data)

try:
    decryptor_tampered.update(tampered_ciphertext) + decryptor_tampered.finalize()
except Exception as e:
    print(f"\n篡改检测演示:")
    print(f"预期的失败：{type(e).__name__}")  # InvalidTag
```

#### GCM 的 Nonce 管理

```python
# GCM 的 Nonce 长度影响：
# - 12 字节 (96 bit): 推荐，性能最佳，可用 2^32 次
# - 16 字节 (128 bit): 更高安全边界，但性能稍差

# 安全方案 1: 随机 Nonce (每个密钥最多 2^32 条消息)
nonce = os.urandom(12)

# 安全方案 2: 递增计数器 (需要可靠的持久化)
import struct
message_counter = 1  # 从存储中加载
nonce = struct.pack('>Q', message_counter).rjust(12, b'\x00')
# 加密后递增并保存 counter
```

---

## 四、完整工具类封装

```python
class AESCipher:
    """AES-GCM 加密工具类（生产就绪）"""
    
    def __init__(self, key: bytes):
        if len(key) not in [16, 24, 32]:
            raise ValueError("密钥长度必须是 16、24 或 32 字节")
        self.key = key
    
    def encrypt(self, plaintext: bytes, associated_data: bytes = b"") -> bytes:
        """加密并返回 Nonce + Ciphertext + Tag"""
        nonce = os.urandom(12)
        encryptor = Cipher(
            algorithms.AES(self.key),
            modes.GCM(nonce),
            backend=backend
        ).encryptor()
        
        if associated_data:
            encryptor.authenticate_additional_data(associated_data)
        
        ciphertext = encryptor.update(plaintext) + encryptor.finalize()
        return nonce + ciphertext + encryptor.tag
    
    def decrypt(self, data: bytes, associated_data: bytes = b"") -> bytes:
        """解密并验证完整性"""
        if len(data) < 28:  # 12 (nonce) + 0 (ciphertext) + 16 (tag)
            raise ValueError("数据格式错误")
        
        nonce = data[:12]
        tag = data[-16:]
        ciphertext = data[12:-16]
        
        decryptor = Cipher(
            algorithms.AES(self.key),
            modes.GCM(nonce, tag),
            backend=backend
        ).decryptor()
        
        if associated_data:
            decryptor.authenticate_additional_data(associated_data)
        
        return decryptor.update(ciphertext) + decryptor.finalize()

# 使用示例
cipher = AESCipher(secrets.token_bytes(32))
encrypted = cipher.encrypt(b"Hello, World!", associated_data=b"user_id:12345")
decrypted = cipher.decrypt(encrypted, associated_data=b"user_id:12345")
print(f"工具类测试: {decrypted}")
```

---

## 五、常见应用场景

### 1. 文件加密

```python
def encrypt_file(input_path, output_path, key):
    """使用 AES-GCM 加密文件"""
    with open(input_path, 'rb') as f:
        plaintext = f.read()
    
    cipher = AESCipher(key)
    ciphertext = cipher.encrypt(plaintext)
    
    with open(output_path, 'wb') as f:
        f.write(ciphertext)

def decrypt_file(input_path, output_path, key):
    """解密文件"""
    with open(input_path, 'rb') as f:
        ciphertext = f.read()
    
    cipher = AESCipher(key)
    plaintext = cipher.decrypt(ciphertext)
    
    with open(output_path, 'wb') as f:
        f.write(plaintext)
```

### 2. 数据库字段加密

```python
import json

def encrypt_json(data: dict, key: bytes) -> str:
    """加密 JSON 数据并返回 Base64"""
    plaintext = json.dumps(data).encode('utf-8')
    cipher = AESCipher(key)
    ciphertext = cipher.encrypt(plaintext)
    return b64encode(ciphertext).decode('utf-8')

def decrypt_json(encrypted: str, key: bytes) -> dict:
    """解密 Base64 编码的数据"""
    ciphertext = b64decode(encrypted.encode('utf-8'))
    cipher = AESCipher(key)
    plaintext = cipher.decrypt(ciphertext)
    return json.loads(plaintext.decode('utf-8'))

# 使用
sensitive_data = {"credit_card": "1234-5678-9012-3456", "cvv": "123"}
encrypted_str = encrypt_json(sensitive_data, key)
print(f"加密后: {encrypted_str}")
decrypted_data = decrypt_json(encrypted_str, key)
print(f"解密后: {decrypted_data}")
```

### 3. 网络传输加密

```python
class SecureChannel:
    """安全通信通道"""
    def __init__(self, shared_key: bytes):
        self.cipher = AESCipher(shared_key)
    
    def send(self, message: str, metadata: dict = None) -> bytes:
        """发送加密消息"""
        aad = json.dumps(metadata or {}).encode('utf-8')
        return self.cipher.encrypt(message.encode('utf-8'), aad)
    
    def receive(self, encrypted: bytes, metadata: dict = None) -> str:
        """接收并解密消息"""
        aad = json.dumps(metadata or {}).encode('utf-8')
        plaintext = self.cipher.decrypt(encrypted, aad)
        return plaintext.decode('utf-8')

# 使用
channel = SecureChannel(key)
encrypted_msg = channel.send("Secret message", {"timestamp": 1234567890})
decrypted_msg = channel.receive(encrypted_msg, {"timestamp": 1234567890})
print(f"接收到: {decrypted_msg}")
```

---

## 六、安全最佳实践

### ✅ 务必遵守

1. **始终使用 GCM 或其他 AEAD 模式**（如 ChaCha20-Poly1305）
2. **绝不重用 Nonce/IV**：每次加密都生成新的随机值
3. **使用强随机源**：`os.urandom()` 或 `secrets` 模块
4. **密钥派生**：从密码派生密钥时使用 PBKDF2/Argon2，迭代次数足够高
5. **密钥轮换**：定期更换密钥（如每年或每百万次操作）
6. **密钥分离**：加密和 MAC 使用不同的密钥
7. **密钥存储**：使用 HSM、密钥管理服务（KMS）或安全的环境变量

### ❌ 绝对禁止

1. ❌ 硬编码密钥在代码中
2. ❌ 使用 ECB 模式（极度不安全）
3. ❌ 自己实现加密算法
4. ❌ 使用弱密码直接作为密钥
5. ❌ 在不同应用间共享密钥
6. ❌ 忽略异常（尤其是 InvalidTag）

---

## 七、性能对比

|模式|加密速度|解密速度|内存占用|并行性|硬件加速|
|---|---|---|---|---|---|
|GCM|⚡⚡⚡|⚡⚡⚡|低|✅|✅|
|CTR|⚡⚡⚡|⚡⚡⚡|低|✅|✅|
|CBC|⚡⚡|⚡⚡⚡|低|部分|✅|

**结论**：GCM 在各方面都最优，是现代应用的默认选择。

---

## 八、调试技巧

```python
import logging

logging.basicConfig(level=logging.DEBUG)

def debug_encryption(key, plaintext):
    """调试加密过程"""
    logging.debug(f"密钥长度: {len(key)} 字节")
    logging.debug(f"明文长度: {len(plaintext)} 字节")
    logging.debug(f"明文内容: {plaintext[:50]}...")
    
    cipher = AESCipher(key)
    encrypted = cipher.encrypt(plaintext)
    
    logging.debug(f"密文长度: {len(encrypted)} 字节")
    logging.debug(f"Nonce: {encrypted[:12].hex()}")
    logging.debug(f"Tag: {encrypted[-16:].hex()}")
    
    decrypted = cipher.decrypt(encrypted)
    assert plaintext == decrypted
    logging.info("✅ 加密/解密验证通过")
```

---

## 九、模式选择决策树

```
需要加密数据？
├─ 是 → 需要完整性验证？
│      ├─ 是 → 使用 GCM ⭐ (首选)
│      └─ 否 → 为什么不需要？
│             ├─ 性能原因 → 使用 CTR + HMAC
│             └─ 遗留系统 → 使用 CBC + HMAC
└─ 否 → 只需要完整性？
       └─ 使用 HMAC 或数字签名
```

---

## 十、总结对比表

|模式|提供认证?|需要填充?|推荐度|关键要点|
|:--|:--|:--|:--|:--|
|**GCM**|**是 (AEAD)**|否|**⭐⭐⭐⭐⭐**|现代、安全、高效。同时保证机密性和完整性。TLS 1.3 首选|
|**CTR**|否|否|**⭐⭐⭐**|灵活快速，**绝对不能重用 Nonce**，需自行实现认证|
|**CBC**|否|是|**⭐**|传统模式，易受填充预言攻击，**强烈不推荐用于新项目**，必须配合 MAC|
|**ECB**|否|是|**🚫 禁用**|极度不安全，相同明文产生相同密文，**永远不要使用**|

---

## 十一、延伸阅读

- [NIST SP 800-38D](https://csrc.nist.gov/publications/detail/sp/800-38d/final): GCM 官方规范
- [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
- [Cryptography Python 官方文档](https://cryptography.io/)
- RFC 5116: An Interface and Algorithms for Authenticated Encryption
- 《Applied Cryptography》 - Bruce Schneier

---

**最后提醒**：加密只是安全系统的一部分。完整的安全方案还需要：

- 访问控制
- 安全的密钥管理
- 日志审计
- 定期安全评估
- 威胁建模

**密码学格言**："不要自己造轮子，使用经过验证的库和标准算法。
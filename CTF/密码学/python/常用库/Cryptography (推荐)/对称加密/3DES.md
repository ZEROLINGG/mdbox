# 3DES 加密完整指南

## 一、3DES 核心概念

在使用 3DES 之前，必须理解以下几个基本组件：

### 1. 3DES (Triple Data Encryption Standard)

- 它是 **DES 的增强版本**，通过三次 DES 操作提升安全性
- 也是一种**块加密 (Block Cipher)** 算法
- 操作的数据单元是固定大小的**块 (Block)**
- 对于 3DES，块大小始终是 **64位 (8字节)**
- 工作原理：**加密-解密-加密** (EDE: Encrypt-Decrypt-Encrypt)

⚠️ **重要警告**：
- 3DES 已被 NIST 在 2023 年**正式弃用**
- 性能比 AES 慢约 **3-5 倍**
- 仅用于**维护遗留系统**或**合规性要求**
- **新项目强烈推荐使用 AES-256**

### 2. 密钥 (Key)

3DES 的密钥结构比较特殊：

#### 两种密钥长度：
- **16 字节 (128位)**：实际有效密钥为 **112位**
  - 使用两个独立的 8 字节密钥：K1, K2, K1
  - 操作：E(K1) → D(K2) → E(K1)
  - 安全性：中等（不足以抵御现代攻击）

- **24 字节 (192位)**：实际有效密钥为 **168位** ⭐ 推荐
  - 使用三个独立的 8 字节密钥：K1, K2, K3
  - 操作：E(K1) → D(K2) → E(K3)
  - 安全性：较高（但仍不如 AES-128）

#### 密钥奇偶校验：
- DES/3DES 使用 **奇偶校验位**
- 每个字节的最低位用于校验（实际密钥位数略少）
- 大多数现代库会自动处理

⚠️ **关键警告**：
- 避免使用相同的密钥（K1=K2=K3 退化为单 DES，极度不安全）
- 密钥必须通过安全的随机源生成

### 3. 加密模式 (Mode of Operation)

3DES 与 AES 相同，需要模式来处理任意长度数据：

| 模式 | 需要IV | 需要填充 | 推荐度 | 说明 |
|------|--------|----------|--------|------|
| **CBC** | ✅ | ✅ | ⭐⭐⭐ | 最常用，需配合 MAC |
| **ECB** | ❌ | ✅ | 🚫 | 极度不安全，禁用 |
| **CFB** | ✅ | ❌ | ⭐⭐ | 流模式，错误传播 |
| **OFB** | ✅ | ❌ | ⭐⭐ | 流模式，不传播错误 |
| **CTR** | ✅ | ❌ | ⭐⭐⭐ | 可并行，但无内置认证 |

### 4. 初始化向量 (IV)

- 对于 3DES，IV 长度**固定为 8 字节**（64位）
- **黄金规则：对于同一个密钥，绝不能重复使用相同的 IV！**
- IV 不需要保密，但必须随机且与密文一起传输
- 重用 IV 会导致模式识别攻击

### 5. 填充 (Padding)

- 3DES 块大小为 8 字节，明文必须是 8 的倍数
- **PKCS7/PKCS5** 是最常用的填充方案：
  - 填充值为需要填充的字节数
  - 例如：需填充 3 字节，则填充 `0x03 0x03 0x03`
  - 即使明文已是 8 的倍数，也要添加完整的 8 字节填充块
- 流模式（CFB、OFB、CTR）不需要填充

### 6. 认证和完整性

⚠️ **严重警告**：
- 3DES **本身不提供完整性验证**
- 必须配合 **HMAC** 或其他 MAC 算法
- 推荐使用 **Encrypt-then-MAC** 模式
- 或直接升级到 AES-GCM（内置认证）

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
import struct

backend = default_backend()
```

### 密钥生成最佳实践

```python
# ============ 方法 1: 生成随机密钥 (推荐) ============
# 生成 24 字节密钥（168位有效强度）
key_168 = secrets.token_bytes(24)

# 生成 16 字节密钥（112位有效强度）
key_112 = os.urandom(16)

print(f"24字节密钥: {key_168.hex()}")
print(f"16字节密钥: {key_112.hex()}")

# ============ 方法 2: 从密码派生密钥 ============
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

def derive_3des_key(password: str, salt: bytes = None, key_length: int = 24) -> tuple:
    """
    从密码派生 3DES 密钥
    
    参数:
        password: 用户密码
        salt: 盐值（16字节），如果为 None 则生成新盐值
        key_length: 密钥长度（16 或 24 字节）
    
    返回:
        (密钥, 盐值)
    """
    if key_length not in [16, 24]:
        raise ValueError("3DES 密钥长度必须是 16 或 24 字节")
    
    if salt is None:
        salt = os.urandom(16)
    
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=key_length,
        salt=salt,
        iterations=480000,  # OWASP 2023 推荐值
        backend=backend
    )
    
    derived_key = kdf.derive(password.encode('utf-8'))
    return derived_key, salt

# 使用示例
password = "MySecurePassword123!"
key, salt = derive_3des_key(password, key_length=24)
print(f"\n从密码派生的密钥: {key.hex()}")
print(f"盐值 (必须保存): {salt.hex()}")

# 验证：使用相同密码和盐值可以重新生成相同密钥
key_verify, _ = derive_3des_key(password, salt=salt, key_length=24)
assert key == key_verify, "密钥派生验证失败"
print("✅ 密钥派生验证成功")

# ============ 方法 3: 从十六进制字符串 (用于配置文件) ============
hex_key = "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
key_from_hex = bytes.fromhex(hex_key)
print(f"\n从十六进制加载: {len(key_from_hex)} 字节")

# ============ 错误示例（不要这样做）============
# ❌ 密钥太短
# weak_key = b"12345678"  # 只有 8 字节，会退化为单 DES

# ❌ 使用相同的密钥块
# weak_key = b"ABCDEFGH" * 3  # K1=K2=K3，不安全

# ❌ 直接使用密码作为密钥
# bad_key = "password123".encode()  # 缺乏随机性
```

---

## 三、加密模式实战

### 准备测试数据

```python
# 准备密钥和明文
key = secrets.token_bytes(24)  # 24字节密钥
plaintext = b"This is a TOP SECRET message for detailed 3DES explanation!"

print(f"密钥长度: {len(key)} 字节")
print(f"明文长度: {len(plaintext)} 字节")
print(f"明文内容: {plaintext}\n")
```

---

### 模式一：CBC (Cipher Block Chaining) ⭐ 推荐

**特点**：3DES 最常用的模式

**原理**：
- 每个明文块先与前一个密文块进行 XOR 操作
- 第一个块与 IV 进行 XOR
- 提供了密文的扩散性

**需要**：Key + IV (8字节) + Padding

**优点**：
- ✅ 相同明文块会产生不同密文
- ✅ 广泛支持，兼容性好
- ✅ 密文块相互依赖，提供一定的完整性指示

**缺点**：
- ❌ 不提供完整性验证（需配合 HMAC）
- ❌ 无法并行加密
- ❌ 容易遭受填充预言攻击

#### 加密过程详解

```python
def encrypt_3des_cbc(key: bytes, plaintext: bytes) -> bytes:
    """
    3DES-CBC 加密
    
    返回格式: IV (8字节) + Ciphertext
    """
    # 步骤 1: 生成随机 IV（8 字节）
    iv = os.urandom(8)
    print(f"[加密] 生成 IV: {iv.hex()}")
    
    # 步骤 2: 创建 Cipher 对象
    cipher = Cipher(
        algorithms.TripleDES(key),
        modes.CBC(iv),
        backend=backend
    )
    encryptor = cipher.encryptor()
    
    # 步骤 3: PKCS7 填充（块大小 64位 = 8字节）
    padder = padding.PKCS7(algorithms.TripleDES.block_size).padder()
    padded_data = padder.update(plaintext) + padder.finalize()
    
    padding_length = len(padded_data) - len(plaintext)
    print(f"[加密] 原始长度: {len(plaintext)} 字节")
    print(f"[加密] 填充后长度: {len(padded_data)} 字节 (填充了 {padding_length} 字节)")
    print(f"[加密] 填充内容: {padded_data[-padding_length:].hex()}")
    
    # 步骤 4: 加密
    ciphertext = encryptor.update(padded_data) + encryptor.finalize()
    print(f"[加密] 密文长度: {len(ciphertext)} 字节")
    print(f"[加密] 密文: {ciphertext.hex()}\n")
    
    # 步骤 5: 返回 IV + Ciphertext
    return iv + ciphertext

# 执行加密
encrypted_cbc = encrypt_3des_cbc(key, plaintext)
print(f"完整加密数据 (IV+密文): {encrypted_cbc.hex()[:80]}...\n")
```

#### 解密过程详解

```python
def decrypt_3des_cbc(key: bytes, encrypted_data: bytes) -> bytes:
    """
    3DES-CBC 解密
    
    参数:
        encrypted_data: IV + Ciphertext
    """
    # 步骤 1: 提取 IV 和密文
    if len(encrypted_data) < 16:  # 至少需要 IV(8) + 一个块(8)
        raise ValueError("加密数据太短，格式错误")
    
    iv = encrypted_data[:8]
    ciphertext = encrypted_data[8:]
    
    print(f"[解密] 提取 IV: {iv.hex()}")
    print(f"[解密] 密文长度: {len(ciphertext)} 字节")
    
    # 步骤 2: 创建解密器
    cipher = Cipher(
        algorithms.TripleDES(key),
        modes.CBC(iv),
        backend=backend
    )
    decryptor = cipher.decryptor()
    
    # 步骤 3: 解密
    padded_plaintext = decryptor.update(ciphertext) + decryptor.finalize()
    print(f"[解密] 解密后长度 (含填充): {len(padded_plaintext)} 字节")
    
    # 步骤 4: 去除填充
    unpadder = padding.PKCS7(algorithms.TripleDES.block_size).unpadder()
    plaintext = unpadder.update(padded_plaintext) + unpadder.finalize()
    
    print(f"[解密] 去除填充后长度: {len(plaintext)} 字节")
    print(f"[解密] 明文: {plaintext}\n")
    
    return plaintext

# 执行解密
decrypted_cbc = decrypt_3des_cbc(key, encrypted_cbc)

# 验证
assert plaintext == decrypted_cbc, "解密失败！"
print("✅ CBC 模式加密/解密验证成功\n")
```

#### CBC + HMAC 组合（生产环境推荐）

```python
def encrypt_3des_cbc_hmac(key_enc: bytes, key_mac: bytes, plaintext: bytes) -> bytes:
    """
    3DES-CBC 加密 + HMAC-SHA256 认证
    
    安全模式: Encrypt-then-MAC
    
    返回格式: IV + Ciphertext + HMAC (32字节)
    """
    # 1. CBC 加密
    iv = os.urandom(8)
    cipher = Cipher(algorithms.TripleDES(key_enc), modes.CBC(iv), backend=backend)
    encryptor = cipher.encryptor()
    
    padder = padding.PKCS7(64).padder()
    padded = padder.update(plaintext) + padder.finalize()
    ciphertext = encryptor.update(padded) + encryptor.finalize()
    
    # 2. 计算 HMAC（认证 IV + 密文）
    h = hmac.HMAC(key_mac, hashes.SHA256(), backend=backend)
    h.update(iv + ciphertext)
    mac_tag = h.finalize()
    
    print(f"[CBC+HMAC] IV: {iv.hex()}")
    print(f"[CBC+HMAC] 密文长度: {len(ciphertext)} 字节")
    print(f"[CBC+HMAC] HMAC 标签: {mac_tag.hex()}\n")
    
    # 3. 返回: IV + Ciphertext + MAC
    return iv + ciphertext + mac_tag

def decrypt_3des_cbc_hmac(key_enc: bytes, key_mac: bytes, data: bytes) -> bytes:
    """
    验证 HMAC 后解密
    
    参数:
        data: IV + Ciphertext + HMAC
    """
    if len(data) < 48:  # IV(8) + 至少1块(8) + HMAC(32)
        raise ValueError("数据格式错误")
    
    # 1. 提取各部分
    iv = data[:8]
    mac_tag = data[-32:]  # SHA256 输出 32 字节
    ciphertext = data[8:-32]
    
    print(f"[CBC+HMAC 解密] 验证 HMAC...")
    
    # 2. 验证 HMAC（先验证，后解密）
    h = hmac.HMAC(key_mac, hashes.SHA256(), backend=backend)
    h.update(iv + ciphertext)
    try:
        h.verify(mac_tag)
        print(f"[CBC+HMAC 解密] ✅ HMAC 验证通过")
    except Exception as e:
        raise ValueError("❌ HMAC 验证失败！数据可能被篡改") from e
    
    # 3. 解密
    cipher = Cipher(algorithms.TripleDES(key_enc), modes.CBC(iv), backend=backend)
    decryptor = cipher.decryptor()
    padded = decryptor.update(ciphertext) + decryptor.finalize()
    
    # 4. 去除填充
    unpadder = padding.PKCS7(64).unpadder()
    plaintext = unpadder.update(padded) + unpadder.finalize()
    
    print(f"[CBC+HMAC 解密] 解密成功\n")
    return plaintext

# 使用示例
key_enc = secrets.token_bytes(24)  # 加密密钥
key_mac = secrets.token_bytes(32)  # MAC 密钥（必须不同！）

encrypted_secure = encrypt_3des_cbc_hmac(key_enc, key_mac, plaintext)
decrypted_secure = decrypt_3des_cbc_hmac(key_enc, key_mac, encrypted_secure)

assert plaintext == decrypted_secure
print("✅ CBC+HMAC 模式验证成功")

# 演示篡改检测
print("\n[安全测试] 篡改密文...")
tampered_data = encrypted_secure[:-33] + b'X' + encrypted_secure[-32:]
try:
    decrypt_3des_cbc_hmac(key_enc, key_mac, tampered_data)
except ValueError as e:
    print(f"✅ 成功检测到篡改: {e}\n")
```

---

### 模式二：ECB (Electronic Codebook) 🚫 禁止使用

**特点**：最不安全的模式

**原理**：
- 每个明文块独立加密
- 相同的明文块产生相同的密文块
- 不使用 IV

**致命缺陷**：
- ❌ 暴露数据模式（著名的 ECB 企鹅问题）
- ❌ 不提供完整性
- ❌ 容易被分析攻击

⚠️ **仅用于教学演示，绝不应在生产环境使用！**

#### 演示 ECB 的不安全性

```python
def encrypt_3des_ecb(key: bytes, plaintext: bytes) -> bytes:
    """ECB 模式加密（仅供演示，不要使用）"""
    cipher = Cipher(algorithms.TripleDES(key), modes.ECB(), backend=backend)
    encryptor = cipher.encryptor()
    
    padder = padding.PKCS7(64).padder()
    padded = padder.update(plaintext) + padder.finalize()
    
    ciphertext = encryptor.update(padded) + encryptor.finalize()
    return ciphertext

def decrypt_3des_ecb(key: bytes, ciphertext: bytes) -> bytes:
    """ECB 模式解密"""
    cipher = Cipher(algorithms.TripleDES(key), modes.ECB(), backend=backend)
    decryptor = cipher.decryptor()
    
    padded = decryptor.update(ciphertext) + decryptor.finalize()
    
    unpadder = padding.PKCS7(64).unpadder()
    return unpadder.update(padded) + unpadder.finalize()

# 演示 ECB 的模式泄露问题
repeated_plaintext = b"AAAAAAAA" * 3  # 重复的 8 字节块
ciphertext_ecb = encrypt_3des_ecb(key, repeated_plaintext)

print("🚫 ECB 模式安全问题演示:")
print(f"明文 (重复模式): {repeated_plaintext}")
print(f"密文 (hex): {ciphertext_ecb.hex()}")

# 将密文分成 8 字节块
blocks = [ciphertext_ecb[i:i+8].hex() for i in range(0, len(ciphertext_ecb), 8)]
print(f"密文块: {blocks}")
print(f"⚠️  注意: 前三个块是相同的！这会泄露明文的重复模式\n")

# 验证解密
decrypted_ecb = decrypt_3des_ecb(key, ciphertext_ecb)
assert repeated_plaintext == decrypted_ecb
```

---

### 模式三：CFB (Cipher Feedback) 

**特点**：将块加密转换为流加密

**原理**：
- 加密 IV 或前一个密文块，然后与明文 XOR
- 自同步：错误会在几个块后恢复
- 不需要填充

**需要**：Key + IV (8字节)

**优缺点**：
- ✅ 不需要填充
- ✅ 错误不会无限传播
- ❌ 不提供完整性验证
- ❌ 性能较 CBC 差

#### 完整实现

```python
def encrypt_3des_cfb(key: bytes, plaintext: bytes) -> bytes:
    """
    3DES-CFB 加密（流模式）
    
    返回: IV + Ciphertext
    """
    iv = os.urandom(8)
    
    cipher = Cipher(
        algorithms.TripleDES(key),
        modes.CFB(iv),
        backend=backend
    )
    encryptor = cipher.encryptor()
    
    # CFB 不需要填充
    ciphertext = encryptor.update(plaintext) + encryptor.finalize()
    
    print(f"[CFB] IV: {iv.hex()}")
    print(f"[CFB] 明文长度: {len(plaintext)} 字节")
    print(f"[CFB] 密文长度: {len(ciphertext)} 字节 (无填充)")
    
    return iv + ciphertext

def decrypt_3des_cfb(key: bytes, encrypted_data: bytes) -> bytes:
    """3DES-CFB 解密"""
    iv = encrypted_data[:8]
    ciphertext = encrypted_data[8:]
    
    cipher = Cipher(
        algorithms.TripleDES(key),
        modes.CFB(iv),
        backend=backend
    )
    decryptor = cipher.decryptor()
    
    # CFB 不需要去除填充
    plaintext = decryptor.update(ciphertext) + decryptor.finalize()
    return plaintext

# 使用示例
test_plaintext = b"CFB mode test with arbitrary length!"  # 任意长度
encrypted_cfb = encrypt_3des_cfb(key, test_plaintext)
decrypted_cfb = decrypt_3des_cfb(key, encrypted_cfb)

print(f"[CFB] 解密结果: {decrypted_cfb}\n")
assert test_plaintext == decrypted_cfb
print("✅ CFB 模式验证成功\n")
```

---

### 模式四：OFB (Output Feedback)

**特点**：另一种流模式

**原理**：
- 加密 IV，生成密钥流
- 密钥流与明文 XOR
- 不会传播错误

**需要**：Key + IV (8字节)

**优缺点**：
- ✅ 位错误不传播（适合有噪声的通道）
- ✅ 可以预先生成密钥流
- ❌ 对 IV 重用极其敏感
- ❌ 不提供完整性验证

```python
def encrypt_3des_ofb(key: bytes, plaintext: bytes) -> bytes:
    """3DES-OFB 加密"""
    iv = os.urandom(8)
    
    cipher = Cipher(
        algorithms.TripleDES(key),
        modes.OFB(iv),
        backend=backend
    )
    encryptor = cipher.encryptor()
    
    ciphertext = encryptor.update(plaintext) + encryptor.finalize()
    
    print(f"[OFB] IV: {iv.hex()}")
    print(f"[OFB] 密文长度: {len(ciphertext)} 字节 (无填充)\n")
    
    return iv + ciphertext

def decrypt_3des_ofb(key: bytes, encrypted_data: bytes) -> bytes:
    """3DES-OFB 解密"""
    iv = encrypted_data[:8]
    ciphertext = encrypted_data[8:]
    
    cipher = Cipher(
        algorithms.TripleDES(key),
        modes.OFB(iv),
        backend=backend
    )
    decryptor = cipher.decryptor()
    
    return decryptor.update(ciphertext) + decryptor.finalize()

# 使用示例
encrypted_ofb = encrypt_3des_ofb(key, plaintext)
decrypted_ofb = decrypt_3des_ofb(key, encrypted_ofb)

assert plaintext == decrypted_ofb
print("✅ OFB 模式验证成功\n")
```

---

### 模式五：CTR (Counter)

**特点**：现代流模式

**原理**：
- 加密递增的计数器
- 生成的密钥流与明文 XOR
- 可并行处理

**需要**：Key + Nonce/Counter (8字节)

**优缺点**：
- ✅ 可并行加密/解密
- ✅ 随机访问
- ✅ 加密和解密操作相同
- ❌ Nonce 绝不能重用

```python
def encrypt_3des_ctr(key: bytes, plaintext: bytes) -> bytes:
    """3DES-CTR 加密"""
    nonce = os.urandom(8)
    
    cipher = Cipher(
        algorithms.TripleDES(key),
        modes.CTR(nonce),
        backend=backend
    )
    encryptor = cipher.encryptor()
    
    ciphertext = encryptor.update(plaintext) + encryptor.finalize()
    
    print(f"[CTR] Nonce: {nonce.hex()}")
    print(f"[CTR] 密文长度: {len(ciphertext)} 字节\n")
    
    return nonce + ciphertext

def decrypt_3des_ctr(key: bytes, encrypted_data: bytes) -> bytes:
    """3DES-CTR 解密（与加密操作相同）"""
    nonce = encrypted_data[:8]
    ciphertext = encrypted_data[8:]
    
    cipher = Cipher(
        algorithms.TripleDES(key),
        modes.CTR(nonce),
        backend=backend
    )
    decryptor = cipher.decryptor()
    
    return decryptor.update(ciphertext) + decryptor.finalize()

# 使用示例
encrypted_ctr = encrypt_3des_ctr(key, plaintext)
decrypted_ctr = decrypt_3des_ctr(key, encrypted_ctr)

assert plaintext == decrypted_ctr
print("✅ CTR 模式验证成功\n")
```

---

## 四、完整工具类封装

```python
from typing import Literal, Optional
from enum import Enum

class TripleDESMode(Enum):
    """3DES 加密模式枚举"""
    CBC = "CBC"
    CFB = "CFB"
    OFB = "OFB"
    CTR = "CTR"
    ECB = "ECB"  # 不推荐

class TripleDESCipher:
    """
    3DES 加密工具类（生产就绪版本）
    
    特性:
    - 支持多种加密模式
    - 自动处理 IV/Nonce
    - 可选的 HMAC 完整性保护
    - Base64/Hex 编码支持
    """
    
    def __init__(
        self, 
        key: bytes, 
        mode: TripleDESMode = TripleDESMode.CBC,
        use_hmac: bool = True,
        mac_key: Optional[bytes] = None
    ):
        """
        初始化 3DES 加密器
        
        参数:
            key: 加密密钥（16 或 24 字节）
            mode: 加密模式
            use_hmac: 是否使用 HMAC（仅适用于 CBC/CFB/OFB/CTR）
            mac_key: HMAC 密钥（如果为 None 且 use_hmac=True，则自动生成）
        """
        if len(key) not in [16, 24]:
            raise ValueError("3DES 密钥长度必须是 16 或 24 字节")
        
        self.key = key
        self.mode = mode
        self.use_hmac = use_hmac and mode != TripleDESMode.ECB
        
        if self.use_hmac:
            if mac_key is None:
                # 从加密密钥派生 MAC 密钥（实际应该独立管理）
                from cryptography.hazmat.primitives.kdf.hkdf import HKDF
                hkdf = HKDF(
                    algorithm=hashes.SHA256(),
                    length=32,
                    salt=None,
                    info=b'mac-key',
                    backend=backend
                )
                self.mac_key = hkdf.derive(key)
            else:
                self.mac_key = mac_key
    
    def encrypt(self, plaintext: bytes, output_format: str = 'bytes') -> bytes | str:
        """
        加密数据
        
        参数:
            plaintext: 明文
            output_format: 输出格式 ('bytes', 'base64', 'hex')
        
        返回:
            加密后的数据 (格式: IV/Nonce + Ciphertext [+ HMAC])
        """
        if isinstance(plaintext, str):
            plaintext = plaintext.encode('utf-8')
        
        # 生成 IV/Nonce
        iv_nonce = os.urandom(8)
        
        # 创建加密器
        if self.mode == TripleDESMode.CBC:
            cipher = Cipher(algorithms.TripleDES(self.key), modes.CBC(iv_nonce), backend=backend)
            needs_padding = True
        elif self.mode == TripleDESMode.CFB:
            cipher = Cipher(algorithms.TripleDES(self.key), modes.CFB(iv_nonce), backend=backend)
            needs_padding = False
        elif self.mode == TripleDESMode.OFB:
            cipher = Cipher(algorithms.TripleDES(self.key), modes.OFB(iv_nonce), backend=backend)
            needs_padding = False
        elif self.mode == TripleDESMode.CTR:
            cipher = Cipher(algorithms.TripleDES(self.key), modes.CTR(iv_nonce), backend=backend)
            needs_padding = False
        elif self.mode == TripleDESMode.ECB:
            cipher = Cipher(algorithms.TripleDES(self.key), modes.ECB(), backend=backend)
            needs_padding = True
            iv_nonce = b''  # ECB 不使用 IV
        else:
            raise ValueError(f"不支持的模式: {self.mode}")
        
        encryptor = cipher.encryptor()
        
        # 填充（如果需要）
        if needs_padding:
            padder = padding.PKCS7(64).padder()
            plaintext = padder.update(plaintext) + padder.finalize()
        
        # 加密
        ciphertext = encryptor.update(plaintext) + encryptor.finalize()
        
        # 组合数据
        result = iv_nonce + ciphertext
        
        # 计算 HMAC（如果启用）
        if self.use_hmac:
            h = hmac.HMAC(self.mac_key, hashes.SHA256(), backend=backend)
            h.update(result)
            mac_tag = h.finalize()
            result = result + mac_tag
        
        # 格式化输出
        if output_format == 'base64':
            return b64encode(result).decode('ascii')
        elif output_format == 'hex':
            return result.hex()
        else:
            return result
    
    def decrypt(self, encrypted_data: bytes | str, input_format: str = 'bytes') -> bytes:
        """
        解密数据
        
        参数:
            encrypted_data: 加密数据
            input_format: 输入格式 ('bytes', 'base64', 'hex')
        
        返回:
            明文
        """
        # 解析输入
        if input_format == 'base64':
            encrypted_data = b64decode(encrypted_data)
        elif input_format == 'hex':
            encrypted_data = bytes.fromhex(encrypted_data)
        
        # 验证 HMAC（如果启用）
        if self.use_hmac:
            if len(encrypted_data) < 40:  # IV(8) + 至少1块(8) + HMAC(32)
                raise ValueError("数据格式错误")
            
            mac_tag = encrypted_data[-32:]
            data_to_verify = encrypted_data[:-32]
            
            h = hmac.HMAC(self.mac_key, hashes.SHA256(), backend=backend)
            h.update(data_to_verify)
            try:
                h.verify(mac_tag)
            except Exception as e:
                raise ValueError("HMAC 验证失败！数据可能被篡改") from e
            
            encrypted_data = data_to_verify
        
        # 提取 IV/Nonce 和密文
        if self.mode == TripleDESMode.ECB:
            iv_nonce = None
            ciphertext = encrypted_data
        else:
            if len(encrypted_data) < 16:
                raise ValueError("数据太短")
            iv_nonce = encrypted_data[:8]
            ciphertext = encrypted_data[8:]
        
        # 创建解密器
        if self.mode == TripleDESMode.CBC:
            cipher = Cipher(algorithms.TripleDES(self.key), modes.CBC(iv_nonce), backend=backend)
            needs_unpadding = True
        elif self.mode == TripleDESMode.CFB:
            cipher = Cipher(algorithms.TripleDES(self.key), modes.CFB(iv_nonce), backend=backend)
            needs_unpadding = False
        elif self.mode == TripleDESMode.OFB:
            cipher = Cipher(algorithms.TripleDES(self.key), modes.OFB(iv_nonce), backend=backend)
            needs_unpadding = False
        elif self.mode == TripleDESMode.CTR:
            cipher = Cipher(algorithms.TripleDES(self.key), modes.CTR(iv_nonce), backend=backend)
            needs_unpadding = False
        elif self.mode == TripleDESMode.ECB:
            cipher = Cipher(algorithms.TripleDES(self.key), modes.ECB(), backend=backend)
            needs_unpadding = True
        else:
            raise ValueError(f"不支持的模式: {self.mode}")
        
        decryptor = cipher.decryptor()
        
        # 解密
        plaintext = decryptor.update(ciphertext) + decryptor.finalize()
        
        # 去除填充（如果需要）
        if needs_unpadding:
            unpadder = padding.PKCS7(64).unpadder()
            plaintext = unpadder.update(plaintext) + unpadder.finalize()
        
        return plaintext

# ============ 使用示例 ============

print("=" * 60)
print("完整工具类测试")
print("=" * 60)

# 测试不同模式
test_message = b"Hello, 3DES! This is a test message."

for mode in [TripleDESMode.CBC, TripleDESMode.CTR, TripleDESMode.CFB]:
    print(f"\n测试模式: {mode.value}")
    
    cipher = TripleDESCipher(
        key=secrets.token_bytes(24),
        mode=mode,
        use_hmac=True
    )
    
    # Base64 格式
    encrypted_b64 = cipher.encrypt(test_message, output_format='base64')
    print(f"加密 (Base64): {encrypted_b64[:60]}...")
    
    decrypted = cipher.decrypt(encrypted_b64, input_format='base64')
    print(f"解密成功: {decrypted == test_message}")
    
    # Hex 格式
    encrypted_hex = cipher.encrypt(test_message, output_format='hex')
    print(f"加密 (Hex): {encrypted_hex[:60]}...")
    
    decrypted_hex = cipher.decrypt(encrypted_hex, input_format='hex')
    assert test_message == decrypted_hex
    
    print("✅ 验证通过")

print("\n" + "=" * 60)
```

---

## 五、常见应用场景

### 1. 遗留系统兼容

```python
class LegacySystemCrypto:
    """
    与遗留系统的加密兼容层
    
    场景: 需要与使用 3DES 的旧系统通信
    """
    
    def __init__(self, hex_key: str):
        """从十六进制密钥初始化"""
        self.cipher = TripleDESCipher(
            key=bytes.fromhex(hex_key),
            mode=TripleDESMode.CBC,
            use_hmac=False  # 旧系统可能不使用 HMAC
        )
    
    def encrypt_for_legacy(self, data: dict) -> str:
        """加密数据用于传输给旧系统"""
        import json
        json_str = json.dumps(data)
        encrypted = self.cipher.encrypt(json_str.encode(), output_format='base64')
        return encrypted
    
    def decrypt_from_legacy(self, encrypted_b64: str) -> dict:
        """解密来自旧系统的数据"""
        import json
        decrypted = self.cipher.decrypt(encrypted_b64, input_format='base64')
        return json.loads(decrypted.decode('utf-8'))

# 使用示例
legacy_key = "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
legacy_crypto = LegacySystemCrypto(legacy_key)

data_to_send = {"user_id": 12345, "amount": 99.99}
encrypted_data = legacy_crypto.encrypt_for_legacy(data_to_send)
print(f"发送给遗留系统: {encrypted_data[:50]}...")

received_data = legacy_crypto.decrypt_from_legacy(encrypted_data)
print(f"从遗留系统接收: {received_data}")
```

### 2. 文件加密（兼容旧格式）

```python
import os
from pathlib import Path

def encrypt_file_3des(input_path: str, output_path: str, password: str):
    """
    使用 3DES 加密文件
    
    适用场景: 需要与旧加密文件格式兼容
    """
    # 从密码派生密钥
    key, salt = derive_3des_key(password, key_length=24)
    
    # 读取文件
    with open(input_path, 'rb') as f:
        plaintext = f.read()
    
    # 加密
    cipher = TripleDESCipher(key, mode=TripleDESMode.CBC, use_hmac=True)
    ciphertext = cipher.encrypt(plaintext, output_format='bytes')
    
    # 写入文件: Salt + 加密数据
    with open(output_path, 'wb') as f:
        f.write(salt)  # 前 16 字节为盐值
        f.write(ciphertext)
    
    print(f"✅ 文件已加密: {output_path}")
    print(f"   原始大小: {len(plaintext)} 字节")
    print(f"   加密后大小: {len(salt) + len(ciphertext)} 字节")

def decrypt_file_3des(input_path: str, output_path: str, password: str):
    """解密 3DES 加密的文件"""
    # 读取文件
    with open(input_path, 'rb') as f:
        data = f.read()
    
    # 提取盐值和密文
    salt = data[:16]
    ciphertext = data[16:]
    
    # 从密码派生密钥
    key, _ = derive_3des_key(password, salt=salt, key_length=24)
    
    # 解密
    cipher = TripleDESCipher(key, mode=TripleDESMode.CBC, use_hmac=True)
    plaintext = cipher.decrypt(ciphertext, input_format='bytes')
    
    # 写入解密文件
    with open(output_path, 'wb') as f:
        f.write(plaintext)
    
    print(f"✅ 文件已解密: {output_path}")

# 使用示例
test_file = "test.txt"
encrypted_file = "test.txt.3des"
decrypted_file = "test_decrypted.txt"

# 创建测试文件
with open(test_file, 'w') as f:
    f.write("This is a test file for 3DES encryption.\n" * 10)

# 加密文件
encrypt_file_3des(test_file, encrypted_file, "MySecurePassword123!")

# 解密文件
decrypt_file_3des(encrypted_file, decrypted_file, "MySecurePassword123!")

# 验证
with open(test_file, 'rb') as f1, open(decrypted_file, 'rb') as f2:
    assert f1.read() == f2.read()
    print("✅ 文件加密/解密验证成功")

# 清理
for f in [test_file, encrypted_file, decrypted_file]:
    if os.path.exists(f):
        os.remove(f)
```

### 3. 数据库字段加密（PCI DSS 合规）

```python
class DatabaseFieldEncryption:
    """
    数据库敏感字段加密
    
    场景: PCI DSS 要求对信用卡数据使用 3DES 或更强的加密
    (注: PCI DSS 4.0 已弃用 3DES，建议升级到 AES)
    """
    
    def __init__(self, master_key: bytes):
        self.cipher = TripleDESCipher(
            key=master_key,
            mode=TripleDESMode.CBC,
            use_hmac=True
        )
    
    def encrypt_credit_card(self, card_number: str) -> str:
        """加密信用卡号"""
        # 移除空格和破折号
        card_number = card_number.replace(' ', '').replace('-', '')
        
        # 验证格式（简单检查）
        if not card_number.isdigit() or len(card_number) not in [13, 14, 15, 16]:
            raise ValueError("无效的信用卡号格式")
        
        encrypted = self.cipher.encrypt(card_number.encode(), output_format='base64')
        return encrypted
    
    def decrypt_credit_card(self, encrypted: str) -> str:
        """解密信用卡号"""
        decrypted = self.cipher.decrypt(encrypted, input_format='base64')
        return decrypted.decode('utf-8')
    
    def get_masked_card(self, encrypted: str) -> str:
        """获取掩码后的卡号（用于显示）"""
        card_number = self.decrypt_credit_card(encrypted)
        # 只显示最后4位
        return '*' * (len(card_number) - 4) + card_number[-4:]

# 使用示例
master_key = secrets.token_bytes(24)
db_crypto = DatabaseFieldEncryption(master_key)

# 模拟数据库操作
credit_cards = [
    "4532-1234-5678-9010",
    "5425-2334-3010-9903",
    "3782-822463-10005"
]

print("模拟数据库加密存储:")
encrypted_records = []
for card in credit_cards:
    encrypted = db_crypto.encrypt_credit_card(card)
    masked = db_crypto.get_masked_card(encrypted)
    encrypted_records.append(encrypted)
    print(f"原始: {card} -> 掩码: {masked}")
    print(f"  存储: {encrypted[:40]}...")

# 验证解密
print("\n验证解密:")
for i, encrypted in enumerate(encrypted_records):
    decrypted = db_crypto.decrypt_credit_card(encrypted)
    original = credit_cards[i].replace('-', '')
    assert decrypted == original
    print(f"✅ 卡片 {i+1} 验证成功")
```

### 4. 配置文件加密

```python
import json
from typing import Any

class ConfigFileEncryption:
    """加密配置文件中的敏感信息"""
    
    def __init__(self, config_key: bytes):
        self.cipher = TripleDESCipher(
            key=config_key,
            mode=TripleDESMode.CBC,
            use_hmac=True
        )
    
    def encrypt_config(self, config: dict, output_file: str):
        """加密配置并保存"""
        json_str = json.dumps(config, indent=2)
        encrypted = self.cipher.encrypt(json_str.encode(), output_format='base64')
        
        with open(output_file, 'w') as f:
            f.write(encrypted)
        
        print(f"✅ 配置已加密保存到: {output_file}")
    
    def decrypt_config(self, input_file: str) -> dict:
        """从加密文件读取配置"""
        with open(input_file, 'r') as f:
            encrypted = f.read()
        
        decrypted = self.cipher.decrypt(encrypted, input_format='base64')
        return json.loads(decrypted.decode('utf-8'))

# 使用示例
config_key = secrets.token_bytes(24)
config_crypto = ConfigFileEncryption(config_key)

# 敏感配置
sensitive_config = {
    "database": {
        "host": "db.example.com",
        "port": 5432,
        "username": "admin",
        "password": "SuperSecret123!"
    },
    "api_keys": {
        "stripe": "sk_live_xxxxxxxxxxxx",
        "aws": "AKIAIOSFODNN7EXAMPLE"
    }
}

# 加密保存
config_crypto.encrypt_config(sensitive_config, "config.encrypted")

# 读取解密
loaded_config = config_crypto.decrypt_config("config.encrypted")
print("\n解密的配置:")
print(json.dumps(loaded_config, indent=2))

# 验证
assert sensitive_config == loaded_config
print("\n✅ 配置加密/解密验证成功")

# 清理
if os.path.exists("config.encrypted"):
    os.remove("config.encrypted")
```

---

## 六、安全最佳实践

### ✅ 务必遵守的规则

```python
# ✅ 1. 使用足够长的密钥
good_key = secrets.token_bytes(24)  # 24 字节 = 168位有效

# ✅ 2. 每次加密生成新的随机 IV
def encrypt_with_random_iv(key, plaintext):
    iv = os.urandom(8)  # 每次都不同
    # ... 加密过程

# ✅ 3. 使用 HMAC 保证完整性
cipher = TripleDESCipher(key, mode=TripleDESMode.CBC, use_hmac=True)

# ✅ 4. 从密码派生密钥时使用足够的迭代次数
key, salt = derive_3des_key("password", key_length=24)  # 480000 次迭代

# ✅ 5. 密钥轮换
def rotate_key_annually():
    """每年更换密钥"""
    new_key = secrets.token_bytes(24)
    # 重新加密所有数据
    return new_key

# ✅ 6. 安全存储密钥
from cryptography.fernet import Fernet

def store_key_securely(key: bytes, master_password: str):
    """使用主密码保护密钥"""
    # 实际应用应使用 HSM 或 KMS
    master_key, salt = derive_3des_key(master_password, key_length=32)
    f = Fernet(b64encode(master_key))
    encrypted_key = f.encrypt(key)
    return encrypted_key, salt

# ✅ 7. 使用 Encrypt-then-MAC
def secure_encrypt(key_enc, key_mac, plaintext):
    """先加密后认证"""
    # 1. 加密
    cipher = TripleDESCipher(key_enc, use_hmac=False)
    ciphertext = cipher.encrypt(plaintext)
    
    # 2. 计算 MAC
    h = hmac.HMAC(key_mac, hashes.SHA256(), backend=backend)
    h.update(ciphertext)
    mac = h.finalize()
    
    return ciphertext + mac
```

### ❌ 绝对禁止的操作

```python
# ❌ 1. 硬编码密钥
BAD_KEY = b"hardcoded_key_123"  # 极度危险

# ❌ 2. 重用 IV
iv = b"12345678"  # 固定 IV
# 多次使用同一个 IV 加密不同数据 -> 安全灾难

# ❌ 3. 使用 ECB 模式
# cipher = TripleDESCipher(key, mode=TripleDESMode.ECB)  # 禁止

# ❌ 4. 使用弱密钥
weak_key = b"12345678" * 3  # K1=K2=K3，退化为单 DES

# ❌ 5. 忽略异常
try:
    decrypt()
except:
    pass  # 绝不能忽略解密失败

# ❌ 6. 不验证完整性
# 只加密不认证 -> 容易被篡改

# ❌ 7. 在新项目中使用 3DES
# 应该使用 AES-256-GCM
```

### 🔒 安全检查清单

```python
def security_checklist():
    """3DES 使用安全检查清单"""
    checklist = {
        "密钥管理": [
            "☐ 密钥长度至少 24 字节",
            "☐ 使用安全随机源生成密钥",
            "☐ 密钥独立存储（不在代码中）",
            "☐ 加密密钥和 MAC 密钥分离",
            "☐ 实施密钥轮换策略",
            "☐ 考虑使用 HSM 或 KMS"
        ],
        "加密操作": [
            "☐ 每次加密生成新 IV/Nonce",
            "☐ 使用 CBC + HMAC 或更好的模式",
            "☐ 绝不使用 ECB 模式",
            "☐ 正确处理填充",
            "☐ IV 与密文一起传输"
        ],
        "完整性": [
            "☐ 使用 HMAC-SHA256 或更强",
            "☐ 采用 Encrypt-then-MAC",
            "☐ 验证 MAC 失败时拒绝解密",
            "☐ 防止时序攻击"
        ],
        "架构": [
            "☐ 评估是否可以迁移到 AES",
            "☐ 记录使用 3DES 的原因（合规/遗留）",
            "☐ 制定迁移计划",
            "☐ 定期安全审计"
        ]
    }
    
    for category, items in checklist.items():
        print(f"\n【{category}】")
        for item in items:
            print(f"  {item}")

security_checklist()
```

---

## 七、性能对比

### 性能测试代码

```python
import time

def performance_benchmark():
    """3DES 性能基准测试"""
    
    # 测试数据
    data_sizes = [1024, 10240, 102400]  # 1KB, 10KB, 100KB
    iterations = 1000
    
    key = secrets.token_bytes(24)
    
    results = []
    
    for size in data_sizes:
        plaintext = os.urandom(size)
        
        # 测试 CBC 模式
        cipher_cbc = TripleDESCipher(key, mode=TripleDESMode.CBC, use_hmac=False)
        
        start = time.time()
        for _ in range(iterations):
            encrypted = cipher_cbc.encrypt(plaintext)
        encrypt_time_cbc = time.time() - start
        
        start = time.time()
        for _ in range(iterations):
            decrypted = cipher_cbc.decrypt(encrypted)
        decrypt_time_cbc = time.time() - start
        
        # 测试 CTR 模式
        cipher_ctr = TripleDESCipher(key, mode=TripleDESMode.CTR, use_hmac=False)
        
        start = time.time()
        for _ in range(iterations):
            encrypted = cipher_ctr.encrypt(plaintext)
        encrypt_time_ctr = time.time() - start
        
        start = time.time()
        for _ in range(iterations):
            decrypted = cipher_ctr.decrypt(encrypted)
        decrypt_time_ctr = time.time() - start
        
        results.append({
            'size': size,
            'cbc_encrypt': encrypt_time_cbc,
            'cbc_decrypt': decrypt_time_cbc,
            'ctr_encrypt': encrypt_time_ctr,
            'ctr_decrypt': decrypt_time_ctr
        })
    
    # 打印结果
    print("\n" + "=" * 70)
    print("3DES 性能测试 (1000 次迭代)")
    print("=" * 70)
    
    for r in results:
        print(f"\n数据大小: {r['size']} 字节 ({r['size']/1024:.1f} KB)")
        print(f"{'模式':<10} {'加密时间':<15} {'解密时间':<15} {'吞吐量 (MB/s)':<20}")
        print("-" * 70)
        
        # CBC
        throughput_enc = (r['size'] * iterations / r['cbc_encrypt']) / (1024 * 1024)
        throughput_dec = (r['size'] * iterations / r['cbc_decrypt']) / (1024 * 1024)
        print(f"{'CBC':<10} {r['cbc_encrypt']:>6.3f}s        {r['cbc_decrypt']:>6.3f}s        加密:{throughput_enc:>6.2f} 解密:{throughput_dec:>6.2f}")
        
        # CTR
        throughput_enc = (r['size'] * iterations / r['ctr_encrypt']) / (1024 * 1024)
        throughput_dec = (r['size'] * iterations / r['ctr_decrypt']) / (1024 * 1024)
        print(f"{'CTR':<10} {r['ctr_encrypt']:>6.3f}s        {r['ctr_decrypt']:>6.3f}s        加密:{throughput_enc:>6.2f} 解密:{throughput_dec:>6.2f}")

performance_benchmark()
```

### 与 AES 对比

| 算法 | 块大小 | 密钥长度 | 相对性能 | 安全等级 | 推荐度 |
|------|--------|----------|----------|----------|--------|
| **3DES** | 64位 (8字节) | 112/168位 | 基准 (1x) | 中等 | ⭐ (遗留) |
| **AES-128** | 128位 (16字节) | 128位 | ~5x 更快 | 高 | ⭐⭐⭐⭐⭐ |
| **AES-256** | 128位 (16字节) | 256位 | ~4x 更快 | 非常高 | ⭐⭐⭐⭐⭐ |

**关键发现**：
- AES 比 3DES 快 **4-5 倍**
- 3DES 受限于 64 位块大小（生日攻击风险）
- 硬件加速对 AES 支持更好

---

## 八、调试技巧

### 1. 调试工具函数

```python
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class Debug3DES:
    """3DES 调试工具"""
    
    @staticmethod
    def analyze_encryption(key: bytes, plaintext: bytes, mode: TripleDESMode):
        """详细分析加密过程"""
        logging.info("=" * 60)
        logging.info(f"开始加密分析 - 模式: {mode.value}")
        logging.info("=" * 60)
        
        # 密钥信息
        logging.debug(f"密钥长度: {len(key)} 字节 ({len(key)*8} 位)")
        logging.debug(f"密钥 (hex): {key.hex()}")
        
        # 明文信息
        logging.debug(f"明文长度: {len(plaintext)} 字节")
        logging.debug(f"明文 (前50字节): {plaintext[:50]}")
        logging.debug(f"明文 (hex): {plaintext.hex()[:100]}...")
        
        # 填充分析
        block_size = 8
        padding_needed = (block_size - len(plaintext) % block_size) % block_size
        if padding_needed == 0 and mode in [TripleDESMode.CBC, TripleDESMode.ECB]:
            padding_needed = block_size
        logging.debug(f"需要填充: {padding_needed} 字节")
        
        # 加密
        cipher = TripleDESCipher(key, mode=mode, use_hmac=True)
        encrypted = cipher.encrypt(plaintext, output_format='bytes')
        
        # 分析加密结果
        if mode != TripleDESMode.ECB:
            iv = encrypted[:8]
            logging.debug(f"IV: {iv.hex()}")
            ciphertext = encrypted[8:-32]  # 去掉 HMAC
        else:
            ciphertext = encrypted[:-32]
        
        logging.debug(f"密文长度: {len(ciphertext)} 字节")
        logging.debug(f"密文块数: {len(ciphertext) // 8}")
        
        # HMAC
        mac = encrypted[-32:]
        logging.debug(f"HMAC: {mac.hex()}")
        
        # 验证解密
        decrypted = cipher.decrypt(encrypted)
        if plaintext == decrypted:
            logging.info("✅ 加密/解密验证成功")
        else:
            logging.error("❌ 加密/解密验证失败")
        
        return encrypted
    
    @staticmethod
    def compare_modes(key: bytes, plaintext: bytes):
        """比较不同模式的输出"""
        print("\n" + "=" * 60)
        print("模式对比测试")
        print("=" * 60)
        
        modes = [
            TripleDESMode.CBC,
            TripleDESMode.CFB,
            TripleDESMode.OFB,
            TripleDESMode.CTR
        ]
        
        results = {}
        
        for mode in modes:
            cipher = TripleDESCipher(key, mode=mode, use_hmac=False)
            encrypted = cipher.encrypt(plaintext)
            
            results[mode.value] = {
                'length': len(encrypted),
                'hex': encrypted.hex()[:60] + '...'
            }
        
        for mode_name, data in results.items():
            print(f"\n{mode_name}:")
            print(f"  长度: {data['length']} 字节")
            print(f"  密文: {data['hex']}")
    
    @staticmethod
    def test_iv_reuse_danger(key: bytes):
        """演示 IV 重用的危险性"""
        print("\n" + "=" * 60)
        print("⚠️  IV 重用危险演示")
        print("=" * 60)
        
        # 固定 IV（错误做法）
        fixed_iv = b'\x00' * 8
        
        plaintext1 = b"Message One!"
        plaintext2 = b"Message Two!"
        
        # 使用相同 IV 加密两条消息
        cipher_cbc = Cipher(algorithms.TripleDES(key), modes.CBC(fixed_iv), backend=backend)
        
        # 加密消息1
        enc1 = cipher_cbc.encryptor()
        padder1 = padding.PKCS7(64).padder()
        padded1 = padder1.update(plaintext1) + padder1.finalize()
        ciphertext1 = enc1.update(padded1) + enc1.finalize()
        
        # 加密消息2 (重用 IV - 错误!)
        enc2 = Cipher(algorithms.TripleDES(key), modes.CBC(fixed_iv), backend=backend).encryptor()
        padder2 = padding.PKCS7(64).padder()
        padded2 = padder2.update(plaintext2) + padder2.finalize()
        ciphertext2 = enc2.update(padded2) + enc2.finalize()
        
        print(f"使用相同 IV: {fixed_iv.hex()}")
        print(f"\n明文1: {plaintext1}")
        print(f"密文1 (前16字节): {ciphertext1[:16].hex()}")
        print(f"\n明文2: {plaintext2}")
        print(f"密文2 (前16字节): {ciphertext2[:16].hex()}")
        
        # 分析第一个块
        if ciphertext1[:8] == ciphertext2[:8]:
            print("\n⚠️  警告: 前 8 字节相同！这泄露了信息！")
        
        print("\n正确做法: 每次加密使用新的随机 IV")

# 使用调试工具
key = secrets.token_bytes(24)
test_data = b"This is sensitive data that needs encryption!"

# 1. 详细分析
Debug3DES.analyze_encryption(key, test_data, TripleDESMode.CBC)

# 2. 模式对比
Debug3DES.compare_modes(key, test_data)

# 3. IV 重用危险演示
Debug3DES.test_iv_reuse_danger(key)
```

### 2. 常见错误诊断

```python
def diagnose_common_errors():
    """诊断常见错误"""
    
    print("\n" + "=" * 60)
    print("常见错误诊断指南")
    print("=" * 60)
    
    errors = {
        "ValueError: Incorrect AES key length": {
            "原因": "密钥长度不是 16 或 24 字节",
            "解决": "使用 secrets.token_bytes(24) 生成正确长度的密钥"
        },
        "ValueError: Invalid padding bytes": {
            "原因": "1) 密钥错误 2) 数据被篡改 3) IV 不匹配",
            "解决": "检查密钥和 IV 是否正确，验证数据完整性"
        },
        "cryptography.exceptions.InvalidTag": {
            "原因": "HMAC 验证失败，数据可能被篡改",
            "解决": "检查数据完整性，确认密钥正确"
        },
        "数据长度不是 8 的倍数": {
            "原因": "ECB/CBC 模式需要填充",
            "解决": "使用 PKCS7 填充或切换到流模式 (CFB/OFB/CTR)"
        }
    }
    
    for error, info in errors.items():
        print(f"\n错误: {error}")
        print(f"  原因: {info['原因']}")
        print(f"  解决: {info['解决']}")
```

---

## 九、迁移指南：从 3DES 到 AES

### 为什么要迁移？

```python
def why_migrate():
    """迁移到 AES 的理由"""
    
    reasons = {
        "安全性": [
            "3DES 的 64 位块大小存在生日攻击风险",
            "Sweet32 攻击 (CVE-2016-2183)",
            "NIST 在 2023 年底正式弃用",
            "PCI DSS 4.0 不再接受 3DES"
        ],
        "性能": [
            "AES 比 3DES 快 4-5 倍",
            "更好的硬件加速支持 (AES-NI)",
            "更低的能耗"
        ],
        "功能": [
            "AES-GCM 提供内置的认证加密",
            "更大的块大小 (128位 vs 64位)",
            "更灵活的密钥长度选择"
        ]
    }
    
    print("\n" + "=" * 60)
    print("迁移到 AES 的理由")
    print("=" * 60)
    
    for category, items in reasons.items():
        print(f"\n【{category}】")
        for item in items:
            print(f"  • {item}")
```

### 迁移策略

```python
class CryptoMigration:
    """3DES 到 AES 的迁移工具"""
    
    def __init__(self, old_3des_key: bytes, new_aes_key: bytes):
        """
        初始化迁移工具
        
        参数:
            old_3des_key: 现有的 3DES 密钥
            new_aes_key: 新的 AES 密钥 (32 字节)
        """
        self.cipher_3des = TripleDESCipher(old_3des_key, mode=TripleDESMode.CBC, use_hmac=True)
        
        # 使用 AES-256-GCM
        from cryptography.hazmat.primitives.ciphers.aead import AESGCM
        self.aes_gcm = AESGCM(new_aes_key)
    
    def migrate_data(self, encrypted_3des: bytes) -> bytes:
        """
        迁移单条数据：3DES -> AES
        
        步骤:
        1. 使用 3DES 解密
        2. 使用 AES-GCM 重新加密
        """
        # 1. 3DES 解密
        plaintext = self.cipher_3des.decrypt(encrypted_3des)
        
        # 2. AES-GCM 加密
        nonce = os.urandom(12)
        ciphertext = self.aes_gcm.encrypt(nonce, plaintext, None)
        
        # 返回: Nonce + Ciphertext (AES-GCM 格式)
        return nonce + ciphertext
    
    def migrate_database(self, db_records: list) -> list:
        """
        批量迁移数据库记录
        
        参数:
            db_records: [(id, encrypted_3des), ...]
        
        返回:
            [(id, encrypted_aes), ...]
        """
        migrated = []
        failed = []
        
        for record_id, encrypted_data in db_records:
            try:
                new_encrypted = self.migrate_data(encrypted_data)
                migrated.append((record_id, new_encrypted))
            except Exception as e:
                failed.append((record_id, str(e)))
                logging.error(f"迁移失败 - ID: {record_id}, 错误: {e}")
        
        print(f"\n迁移统计:")
        print(f"  成功: {len(migrated)}")
        print(f"  失败: {len(failed)}")
        
        return migrated

# 使用示例
print("\n" + "=" * 60)
print("数据迁移示例：3DES -> AES")
print("=" * 60)

# 旧系统的 3DES 密钥
old_key = secrets.token_bytes(24)

# 新系统的 AES 密钥
new_key = secrets.token_bytes(32)

# 创建迁移工具
migration = CryptoMigration(old_key, new_key)

# 模拟旧数据
old_cipher = TripleDESCipher(old_key, mode=TripleDESMode.CBC, use_hmac=True)
test_records = [
    (1, old_cipher.encrypt(b"User data 1")),
    (2, old_cipher.encrypt(b"User data 2")),
    (3, old_cipher.encrypt(b"User data 3"))
]

# 执行迁移
migrated_records = migration.migrate_database(test_records)

print(f"\n迁移后数据示例:")
for record_id, encrypted in migrated_records[:1]:
    print(f"  ID {record_id}: {encrypted.hex()[:60]}...")
```

### 双重加密过渡方案

```python
class DualEncryptionSupport:
    """
    支持 3DES 和 AES 的过渡方案
    
    适用场景:
    - 逐步迁移，不中断服务
    - 向后兼容旧客户端
    """
    
    VERSION_3DES = b'\x01'
    VERSION_AES = b'\x02'
    
    def __init__(self, key_3des: bytes, key_aes: bytes):
        self.cipher_3des = TripleDESCipher(key_3des, mode=TripleDESMode.CBC, use_hmac=True)
        
        from cryptography.hazmat.primitives.ciphers.aead import AESGCM
        self.aes_gcm = AESGCM(key_aes)
    
    def encrypt_new(self, plaintext: bytes) -> bytes:
        """新数据使用 AES 加密"""
        nonce = os.urandom(12)
        ciphertext = self.aes_gcm.encrypt(nonce, plaintext, None)
        
        # 格式: VERSION + Nonce + Ciphertext
        return self.VERSION_AES + nonce + ciphertext
    
    def decrypt_auto(self, encrypted: bytes) -> bytes:
        """自动检测版本并解密"""
        version = encrypted[:1]
        data = encrypted[1:]
        
        if version == self.VERSION_3DES:
            print("  检测到 3DES 加密数据")
            return self.cipher_3des.decrypt(data)
        elif version == self.VERSION_AES:
            print("  检测到 AES 加密数据")
            nonce = data[:12]
            ciphertext = data[12:]
            return self.aes_gcm.decrypt(nonce, ciphertext, None)
        else:
            raise ValueError(f"未知的加密版本: {version.hex()}")

# 使用示例
print("\n" + "=" * 60)
print("双重加密过渡方案")
print("=" * 60)

dual_crypto = DualEncryptionSupport(
    key_3des=secrets.token_bytes(24),
    key_aes=secrets.token_bytes(32)
)

# 旧数据 (3DES)
old_data = dual_crypto.VERSION_3DES + dual_crypto.cipher_3des.encrypt(b"Legacy data")

# 新数据 (AES)
new_data = dual_crypto.encrypt_new(b"Modern data")

# 自动解密
print("\n解密旧数据:")
decrypted_old = dual_crypto.decrypt_auto(old_data)
print(f"  结果: {decrypted_old}")

print("\n解密新数据:")
decrypted_new = dual_crypto.decrypt_auto(new_data)
print(f"  结果: {decrypted_new}")
```

---

## 十、决策树

```
需要使用 3DES？
│
├─ 新项目？
│  └─ ❌ 不要使用 3DES
│     └─ ✅ 使用 AES-256-GCM
│
├─ 遗留系统兼容？
│  ├─ 可以修改对方系统？
│  │  └─ ✅ 升级到 AES
│  └─ 无法修改？
│     └─ ⚠️  使用 3DES-CBC + HMAC
│        └─ 制定迁移计划
│
├─ 合规要求（PCI DSS < 4.0）？
│  └─ ⚠️  暂时使用，尽快升级
│     └─ 密钥长度必须 24 字节
│
└─ 性能敏感？
   └─ ❌ 3DES 很慢
      └─ ✅ 使用 AES-NI 加速的 AES
```

### 模式选择决策树

```
选择 3DES 模式？
│
├─ 需要完整性验证？
│  ├─ 是
│  │  └─ 使用 CBC + HMAC
│  └─ 否
│     └─ ⚠️  为什么不需要？
│        └─ 重新考虑需求
│
├─ 需要随机访问？
│  └─ 是
│     └─ 使用 CTR 模式
│        └─ 配合 HMAC
│
├─ 数据有噪声？
│  └─ 是
│     └─ 使用 OFB 模式
│        └─ 错误不传播
│
└─ 默认选择
   └─ CBC + HMAC
```

---

## 十一、总结对比表

### 3DES 模式对比

| 模式      | 需要IV    | 需要填充 | 并行性   | 错误传播 | 完整性 | 推荐度 | 适用场景       |
| :------ | :------ | :--- | :---- | :--- | :-- | :-- | :--------- |
| **CBC** | ✅ (8字节) | ✅    | 解密可并行 | 一个块  | ❌   | ⭐⭐⭐ | 通用，需配合HMAC |
| **ECB** | ❌       | ✅    | 完全并行  | 不传播  | ❌   | 🚫  | **禁用**     |
| **CFB** | ✅ (8字节) | ❌    | 解密可并行 | 一个块  | ❌   | ⭐⭐  | 错误恢复需求     |
| **OFB** | ✅ (8字节) | ❌    | 可预计算  | 不传播  | ❌   | ⭐⭐  | 有噪声的通道     |
| **CTR** | ✅ (8字节) | ❌    | 完全并行  | 不传播  | ❌   | ⭐⭐⭐ | 随机访问需求     |

### 3DES vs AES

| 特性 | 3DES | AES-256 |
|:-----|:-----|:--------|
| **块大小** | 64 位 (8 字节) | 128 位 (16 字节) |
| **密钥长度** | 168 位 (24 字节) | 256 位 (32 字节) |
| **安全性** | 中等 (Sweet32 漏洞) | 非常高 |
| **速度** | 慢 (基准) | 快 (~5x) |
| **硬件加速** | 有限 | 广泛 (AES-NI) |
| **标准状态** | 已弃用 (2023) | 推荐 |
| **推荐使用** | ❌ (仅遗留系统) | ✅ (所有新项目) |

### 关键建议

| 场景 | 推荐方案 | 原因 |
|:-----|:---------|:-----|
| **新项目** | AES-256-GCM | 安全、快速、内置认证 |
| **遗留系统** | 3DES-CBC + HMAC | 兼容性 + 制定迁移计划 |
| **文件加密** | AES-256-GCM | 性能和安全 |
| **数据库字段** | AES-256-GCM | PCI DSS 4.0 合规 |
| **API 传输** | TLS 1.3 (AES-GCM) | 标准协议 |

---

## 十二、延伸阅读

### 官方文档

- [NIST SP 800-67 Rev. 2](https://csrc.nist.gov/publications/detail/sp/800-67/rev-2/final): 3DES 官方规范
- [NIST 弃用声明](https://csrc.nist.gov/news/2023): 2023 年 3DES 退役公告
- [Cryptography Python 文档](https://cryptography.io/): 官方 API 文档

### 安全公告

- [Sweet32](https://sweet32.info/): 64 位块加密的生日攻击
- [CVE-2016-2183](https://nvd.nist.gov/vuln/detail/CVE-2016-2183): 3DES 碰撞攻击
- [PCI DSS 4.0](https://www.pcisecuritystandards.org/): 支付卡行业数据安全标准

### 推荐资源

- 《Applied Cryptography》 - Bruce Schneier
- 《Cryptography Engineering》 - Ferguson, Schneier, Kohno
- [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)

---

## 最后的忠告

```python
def final_advice():
    """最后的建议"""
    
    print("\n" + "=" * 60)
    print("🔐 3DES 使用最后建议")
    print("=" * 60)
    
    advice = [
        "1. ⚠️  3DES 已被弃用，仅用于遗留系统维护",
        "2. ✅ 所有新项目必须使用 AES-256-GCM",
        "3. 📅 制定明确的迁移时间表（建议 6-12 个月内）",
        "4. 🔑 密钥管理是整个系统的核心，不可忽视",
        "5. 🔒 永远使用 Encrypt-then-MAC 模式",
        "6. 🚫 绝对禁止使用 ECB 模式",
        "7. 🎲 IV/Nonce 必须随机且不重用",
        "8. 📊 定期进行安全审计",
        "9. 📚 持续学习最新的密码学最佳实践",
        "10. 🏢 考虑使用 HSM 或云 KMS 管理密钥"
    ]
    
    for item in advice:
        print(f"  {item}")
    
    print("\n" + "=" * 60)
    print("记住：密码学很难，不要自己发明算法！")
    print("使用经过验证的库和标准实现。")
    print("=" * 60)

final_advice()
```

---

**总结**：3DES 是一个过渡性的加密标准，虽然曾经广泛使用，但现在已经被更安全、更快速的 AES 取代。如果你正在维护使用 3DES 的遗留系统，请务必：

1. 使用本指南提供的安全实践
2. 配合 HMAC 提供完整性保护
3. 尽快制定迁移到 AES 的计划

**新项目请直接使用 AES-256-GCM！**
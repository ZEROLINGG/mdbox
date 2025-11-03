# RSA 加密完整指南

## 一、RSA 核心概念

在使用 RSA 之前，必须理解以下几个基本组件：

### 1. RSA (Rivest-Shamir-Adleman)

- 它是一种**非对称加密 (Asymmetric Encryption)** 算法
- 由 Ron Rivest、Adi Shamir 和 Leonard Adleman 于 1977 年提出
- 基于**大数因数分解**的数学难题
- 使用**一对密钥**：公钥加密，私钥解密（或反之用于签名）
- 是目前使用最广泛的非对称加密算法之一

**核心特点**：
- ✅ 公钥可以公开分发
- ✅ 私钥必须严格保密
- ✅ 无需预先共享密钥（解决了对称加密的密钥分发问题）
- ❌ 速度远慢于对称加密（约慢 1000 倍）
- ❌ 只能加密有限长度的数据

### 2. 公钥和私钥 (Public Key & Private Key)

**公钥 (Public Key)**：
- 可以安全地公开给任何人
- 用于**加密数据**或**验证签名**
- 由两部分组成：**模数 (n)** 和**公开指数 (e，通常是 65537)**

**私钥 (Private Key)**：
- 必须严格保密，只有所有者知道
- 用于**解密数据**或**生成签名**
- 包含：**模数 (n)**、**私有指数 (d)**、以及优化计算的其他参数

**数学关系**：
```
公钥: (n, e)
私钥: (n, d)
其中: n = p × q (两个大质数)
      e × d ≡ 1 (mod φ(n))
```

### 3. 密钥长度

RSA 的安全性直接取决于密钥长度：

| 密钥长度 | 安全级别 | 推荐度 | 说明 |
|---------|---------|--------|------|
| **1024 位** | ⚠️ 低 | 🚫 **已废弃** | 可被破解，禁止使用 |
| **2048 位** | 中等 | ⭐⭐⭐ | 当前最低推荐标准 |
| **3072 位** | 高 | ⭐⭐⭐⭐ | 长期安全（至 2030 年） |
| **4096 位** | 很高 | ⭐⭐⭐⭐⭐ | 高安全需求场景 |

**NIST 建议**：
- 2048 位密钥可用至 2030 年
- 3072 位密钥可用至 2030 年后
- 政府机密：至少 3072 位

⚠️ **关键权衡**：
- 密钥越长，安全性越高，但性能越差
- 4096 位比 2048 位慢约 **7-8 倍**

### 4. 填充方案 (Padding Scheme)

**为什么需要填充？**
- 原始 RSA（"教科书 RSA"）是**确定性**的：相同明文总是产生相同密文
- 容易受到多种攻击（选择明文攻击、数学攻击等）
- 填充引入随机性，提供语义安全

**主要填充方案**：

#### OAEP (Optimal Asymmetric Encryption Padding) ⭐ 推荐
- **用途**：加密
- **标准**：PKCS#1 v2.0+, RFC 8017
- **特点**：
  - ✅ 提供语义安全（IND-CCA2）
  - ✅ 抵抗选择密文攻击
  - ✅ 现代标准，广泛支持
  - 通常与 SHA-256 或 SHA-384 配合使用

#### PKCS#1 v1.5
- **用途**：加密（已过时）
- **特点**：
  - ⚠️ 存在 Bleichenbacher 攻击风险
  - ❌ 不推荐用于新系统
  - 仅用于遗留兼容

#### PSS (Probabilistic Signature Scheme) ⭐ 推荐
- **用途**：数字签名
- **标准**：PKCS#1 v2.1+
- **特点**：
  - ✅ 可证明安全
  - ✅ 抵抗伪造攻击
  - ✅ 现代签名标准

### 5. 加密数据长度限制

RSA 不能加密任意长度的数据：

```python
# 最大明文长度计算
密钥长度 = 2048 位 = 256 字节

# 使用 OAEP-SHA256 填充
最大明文长度 = 256 - 2 × 32 - 2 = 190 字节
             = 密钥长度/8 - 2×哈希长度 - 2

# 使用 OAEP-SHA384 填充
最大明文长度 = 256 - 2 × 48 - 2 = 158 字节
```

**实际限制表**：

| 密钥长度   | OAEP-SHA256 | OAEP-SHA384 | OAEP-SHA512 |
| ------ | ----------- | ----------- | ----------- |
| 2048 位 | 190 字节      | 158 字节      | 126 字节      |
| 3072 位 | 318 字节      | 286 字节      | 254 字节      |
| 4096 位 | 446 字节      | 414 字节      | 382 字节      |

⚠️ **重要**：实际应用中，RSA 通常不直接加密数据，而是用于**加密对称密钥**（混合加密）。

### 6. RSA 的两大应用

#### 应用一：加密/解密
```
发送方 → [使用接收方公钥加密] → 密文 → [接收方用私钥解密] → 明文
```

#### 应用二：数字签名
```
签名方 → [使用私钥签名] → 签名 → [验证方用公钥验证] → 真实性确认
```

**签名的作用**：
- ✅ 身份认证（证明消息来自声称的发送者）
- ✅ 完整性验证（消息未被篡改）
- ✅ 不可否认性（发送者无法否认发送过该消息）

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
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.backends import default_backend
from base64 import b64encode, b64decode
import json

backend = default_backend()
```

---

## 三、密钥生成

### 1. 生成密钥对（基础）

```python
def generate_rsa_keypair(key_size: int = 2048):
    """
    生成 RSA 密钥对
    
    参数:
        key_size: 密钥长度（1024, 2048, 3072, 4096）
    
    返回:
        (private_key, public_key)
    """
    print(f"[密钥生成] 生成 {key_size} 位 RSA 密钥对...")
    
    # 生成私钥
    private_key = rsa.generate_private_key(
        public_exponent=65537,  # 标准公开指数
        key_size=key_size,
        backend=backend
    )
    
    # 从私钥提取公钥
    public_key = private_key.public_key()
    
    print(f"[密钥生成] ✅ 密钥对生成成功")
    print(f"[密钥生成] 密钥长度: {key_size} 位")
    print(f"[密钥生成] 公开指数: 65537")
    
    return private_key, public_key

# 生成密钥对
private_key, public_key = generate_rsa_keypair(2048)
```

**为什么公开指数是 65537？**
- 65537 = 2^16 + 1（费马素数 F4）
- 二进制：`10000000000000001`（只有 2 个 1）
- 使加密和签名验证非常快
- 已被证明是安全的选择

### 2. 查看密钥信息

```python
def inspect_key(private_key, public_key):
    """检查密钥详细信息"""
    
    print("\n" + "=" * 60)
    print("密钥详细信息")
    print("=" * 60)
    
    # 私钥信息
    private_numbers = private_key.private_numbers()
    
    print("\n【私钥组成】")
    print(f"  模数 (n) 长度: {private_numbers.public_numbers.n.bit_length()} 位")
    print(f"  公开指数 (e): {private_numbers.public_numbers.e}")
    print(f"  私有指数 (d) 长度: {private_numbers.d.bit_length()} 位")
    print(f"  质数 p 长度: {private_numbers.p.bit_length()} 位")
    print(f"  质数 q 长度: {private_numbers.q.bit_length()} 位")
    
    # 公钥信息
    public_numbers = public_key.public_numbers()
    
    print("\n【公钥组成】")
    print(f"  模数 (n) 长度: {public_numbers.n.bit_length()} 位")
    print(f"  公开指数 (e): {public_numbers.e}")
    
    # 计算最大加密长度
    key_size_bytes = public_numbers.n.bit_length() // 8
    max_plaintext_oaep_sha256 = key_size_bytes - 2 * 32 - 2
    max_plaintext_oaep_sha512 = key_size_bytes - 2 * 64 - 2
    
    print("\n【加密能力】")
    print(f"  密钥长度: {key_size_bytes} 字节")
    print(f"  最大明文长度 (OAEP-SHA256): {max_plaintext_oaep_sha256} 字节")
    print(f"  最大明文长度 (OAEP-SHA512): {max_plaintext_oaep_sha512} 字节")

inspect_key(private_key, public_key)
```

### 3. 密钥序列化（保存和加载）

#### PEM 格式（推荐）

```python
def save_private_key_pem(private_key, filename: str, password: bytes = None):
    """
    保存私钥为 PEM 格式
    
    参数:
        private_key: 私钥对象
        filename: 文件名
        password: 加密密码（可选，强烈建议使用）
    """
    if password:
        # 使用密码加密私钥（PKCS#8 格式）
        encryption_algorithm = serialization.BestAvailableEncryption(password)
        print(f"[保存私钥] 使用密码加密")
    else:
        # 不加密（不推荐）
        encryption_algorithm = serialization.NoEncryption()
        print(f"[保存私钥] ⚠️  警告: 私钥未加密")
    
    pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=encryption_algorithm
    )
    
    with open(filename, 'wb') as f:
        f.write(pem)
    
    print(f"[保存私钥] ✅ 私钥已保存到: {filename}")

def save_public_key_pem(public_key, filename: str):
    """保存公钥为 PEM 格式"""
    pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    
    with open(filename, 'wb') as f:
        f.write(pem)
    
    print(f"[保存公钥] ✅ 公钥已保存到: {filename}")

def load_private_key_pem(filename: str, password: bytes = None):
    """从 PEM 文件加载私钥"""
    with open(filename, 'rb') as f:
        pem_data = f.read()
    
    private_key = serialization.load_pem_private_key(
        pem_data,
        password=password,
        backend=backend
    )
    
    print(f"[加载私钥] ✅ 私钥已从 {filename} 加载")
    return private_key

def load_public_key_pem(filename: str):
    """从 PEM 文件加载公钥"""
    with open(filename, 'rb') as f:
        pem_data = f.read()
    
    public_key = serialization.load_pem_public_key(
        pem_data,
        backend=backend
    )
    
    print(f"[加载公钥] ✅ 公钥已从 {filename} 加载")
    return public_key

# 使用示例
print("\n" + "=" * 60)
print("密钥保存和加载示例")
print("=" * 60 + "\n")

# 保存密钥（使用密码保护）
password = b"MyStrongPassword123!"
save_private_key_pem(private_key, "private_key.pem", password)
save_public_key_pem(public_key, "public_key.pem")

# 查看 PEM 文件内容
print("\n私钥 PEM 格式（前10行）:")
with open("private_key.pem", 'r') as f:
    lines = f.readlines()[:10]
    print(''.join(lines))

print("\n公钥 PEM 格式:")
with open("public_key.pem", 'r') as f:
    print(f.read())

# 加载密钥
loaded_private_key = load_private_key_pem("private_key.pem", password)
loaded_public_key = load_public_key_pem("public_key.pem")

print("\n✅ 密钥保存和加载验证成功")
```

#### SSH 格式（用于 SSH 密钥）

```python
def save_public_key_ssh(public_key, filename: str):
    """保存公钥为 OpenSSH 格式"""
    ssh_public = public_key.public_bytes(
        encoding=serialization.Encoding.OpenSSH,
        format=serialization.PublicFormat.OpenSSH
    )
    
    with open(filename, 'wb') as f:
        f.write(ssh_public)
    
    print(f"[SSH 公钥] ✅ 已保存到: {filename}")

# 生成 SSH 格式公钥
save_public_key_ssh(public_key, "id_rsa.pub")

with open("id_rsa.pub", 'r') as f:
    print(f"\nSSH 公钥格式:\n{f.read()}")
```

#### DER 格式（二进制格式）

```python
def save_public_key_der(public_key, filename: str):
    """保存公钥为 DER 格式（二进制）"""
    der = public_key.public_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    
    with open(filename, 'wb') as f:
        f.write(der)
    
    print(f"[DER 格式] ✅ 已保存到: {filename} ({len(der)} 字节)")

save_public_key_der(public_key, "public_key.der")
```

---

## 四、加密和解密

### 1. 基本加密/解密（OAEP 填充）

```python
def encrypt_with_public_key(public_key, plaintext: bytes) -> bytes:
    """
    使用公钥加密数据（OAEP-SHA256）
    
    参数:
        public_key: 公钥
        plaintext: 明文（字节）
    
    返回:
        密文
    """
    # 检查明文长度
    key_size_bytes = public_key.key_size // 8
    max_length = key_size_bytes - 2 * 32 - 2  # OAEP-SHA256
    
    if len(plaintext) > max_length:
        raise ValueError(
            f"明文过长！最大长度: {max_length} 字节, "
            f"实际长度: {len(plaintext)} 字节"
        )
    
    print(f"[加密] 明文长度: {len(plaintext)} 字节")
    
    # 使用 OAEP 填充加密
    ciphertext = public_key.encrypt(
        plaintext,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )
    
    print(f"[加密] 密文长度: {len(ciphertext)} 字节")
    print(f"[加密] ✅ 加密成功")
    
    return ciphertext

def decrypt_with_private_key(private_key, ciphertext: bytes) -> bytes:
    """
    使用私钥解密数据
    
    参数:
        private_key: 私钥
        ciphertext: 密文
    
    返回:
        明文
    """
    print(f"[解密] 密文长度: {len(ciphertext)} 字节")
    
    # 使用 OAEP 填充解密
    plaintext = private_key.decrypt(
        ciphertext,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )
    
    print(f"[解密] 明文长度: {len(plaintext)} 字节")
    print(f"[解密] ✅ 解密成功")
    
    return plaintext

# 使用示例
print("\n" + "=" * 60)
print("RSA 加密/解密示例")
print("=" * 60 + "\n")

plaintext = b"This is a secret message!"
print(f"原始明文: {plaintext}\n")

# 加密
ciphertext = encrypt_with_public_key(public_key, plaintext)
print(f"密文 (hex): {ciphertext.hex()[:80]}...\n")

# 解密
decrypted = decrypt_with_private_key(private_key, ciphertext)
print(f"解密后明文: {decrypted}\n")

# 验证
assert plaintext == decrypted
print("✅ 加密/解密验证成功")
```

### 2. 不同哈希算法的 OAEP

```python
def encrypt_with_sha512(public_key, plaintext: bytes) -> bytes:
    """使用 OAEP-SHA512 加密"""
    key_size_bytes = public_key.key_size // 8
    max_length = key_size_bytes - 2 * 64 - 2  # SHA512 = 64 字节
    
    if len(plaintext) > max_length:
        raise ValueError(f"明文过长！最大: {max_length} 字节")
    
    ciphertext = public_key.encrypt(
        plaintext,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA512()),
            algorithm=hashes.SHA512(),
            label=None
        )
    )
    
    return ciphertext

def decrypt_with_sha512(private_key, ciphertext: bytes) -> bytes:
    """使用 OAEP-SHA512 解密"""
    plaintext = private_key.decrypt(
        ciphertext,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA512()),
            algorithm=hashes.SHA512(),
            label=None
        )
    )
    
    return plaintext

# 测试不同哈希算法
print("\n" + "=" * 60)
print("不同哈希算法对比")
print("=" * 60 + "\n")

test_message = b"Test with different hash algorithms"

# SHA256
ciphertext_sha256 = encrypt_with_public_key(public_key, test_message)
print(f"SHA256 密文长度: {len(ciphertext_sha256)} 字节")

# SHA512
ciphertext_sha512 = encrypt_with_sha512(public_key, test_message)
print(f"SHA512 密文长度: {len(ciphertext_sha512)} 字节")

print("\n注意: 两种填充方案产生不同的密文（都是随机的）")
```

### 3. 加密长数据（混合加密）⭐ 实际应用

由于 RSA 不能加密大数据，实际应用中使用**混合加密**：

```python
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

def hybrid_encrypt(public_key, plaintext: bytes) -> dict:
    """
    混合加密：RSA + AES-GCM
    
    流程:
    1. 生成随机 AES 密钥（32字节）
    2. 用 AES-GCM 加密数据
    3. 用 RSA 加密 AES 密钥
    
    返回:
        {
            'encrypted_key': RSA加密的AES密钥,
            'nonce': AES-GCM的nonce,
            'ciphertext': AES加密的数据,
            'tag': AES-GCM的认证标签
        }
    """
    print(f"\n[混合加密] 明文长度: {len(plaintext)} 字节")
    
    # 1. 生成随机 AES 密钥
    aes_key = secrets.token_bytes(32)  # AES-256
    print(f"[混合加密] 生成 AES-256 密钥: {aes_key.hex()[:32]}...")
    
    # 2. 使用 AES-GCM 加密数据
    aesgcm = AESGCM(aes_key)
    nonce = os.urandom(12)
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    
    print(f"[混合加密] AES 加密完成，密文长度: {len(ciphertext)} 字节")
    
    # 3. 使用 RSA 加密 AES 密钥
    encrypted_key = public_key.encrypt(
        aes_key,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )
    
    print(f"[混合加密] RSA 加密 AES 密钥完成")
    print(f"[混合加密] ✅ 混合加密完成")
    
    return {
        'encrypted_key': encrypted_key,
        'nonce': nonce,
        'ciphertext': ciphertext
    }

def hybrid_decrypt(private_key, encrypted_data: dict) -> bytes:
    """
    混合解密
    
    流程:
    1. 用 RSA 解密 AES 密钥
    2. 用 AES-GCM 解密数据
    """
    print(f"\n[混合解密] 开始解密...")
    
    # 1. 使用 RSA 解密 AES 密钥
    aes_key = private_key.decrypt(
        encrypted_data['encrypted_key'],
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )
    
    print(f"[混合解密] RSA 解密 AES 密钥成功")
    
    # 2. 使用 AES-GCM 解密数据
    aesgcm = AESGCM(aes_key)
    plaintext = aesgcm.decrypt(
        encrypted_data['nonce'],
        encrypted_data['ciphertext'],
        None
    )
    
    print(f"[混合解密] AES 解密完成，明文长度: {len(plaintext)} 字节")
    print(f"[混合解密] ✅ 混合解密完成")
    
    return plaintext

# 使用示例
print("\n" + "=" * 60)
print("混合加密示例（RSA + AES）")
print("=" * 60)

# 加密大数据
long_message = b"A" * 10000  # 10 KB 数据
print(f"\n原始数据长度: {len(long_message)} 字节")

# 混合加密
encrypted_data = hybrid_encrypt(public_key, long_message)

print(f"\n加密结果:")
print(f"  加密的AES密钥长度: {len(encrypted_data['encrypted_key'])} 字节")
print(f"  Nonce长度: {len(encrypted_data['nonce'])} 字节")
print(f"  密文长度: {len(encrypted_data['ciphertext'])} 字节")

# 混合解密
decrypted_data = hybrid_decrypt(private_key, encrypted_data)

# 验证
assert long_message == decrypted_data
print(f"\n✅ 混合加密/解密验证成功")
```

---

## 五、数字签名

### 1. 基本签名和验证（PSS）

```python
def sign_message(private_key, message: bytes) -> bytes:
    """
    使用私钥签名消息（PSS-SHA256）
    
    参数:
        private_key: 私钥
        message: 要签名的消息
    
    返回:
        签名
    """
    print(f"[签名] 消息长度: {len(message)} 字节")
    
    signature = private_key.sign(
        message,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    
    print(f"[签名] 签名长度: {len(signature)} 字节")
    print(f"[签名] ✅ 签名生成成功")
    
    return signature

def verify_signature(public_key, message: bytes, signature: bytes) -> bool:
    """
    使用公钥验证签名
    
    参数:
        public_key: 公钥
        message: 原始消息
        signature: 签名
    
    返回:
        True: 验证成功, False: 验证失败
    """
    print(f"[验证] 消息长度: {len(message)} 字节")
    print(f"[验证] 签名长度: {len(signature)} 字节")
    
    try:
        public_key.verify(
            signature,
            message,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        print(f"[验证] ✅ 签名验证成功")
        return True
    except Exception as e:
        print(f"[验证] ❌ 签名验证失败: {e}")
        return False

# 使用示例
print("\n" + "=" * 60)
print("数字签名示例")
print("=" * 60 + "\n")

message = b"This is an important contract that needs to be signed."
print(f"原始消息: {message}\n")

# 签名
signature = sign_message(private_key, message)
print(f"签名 (hex): {signature.hex()[:80]}...\n")

# 验证（正确的消息）
is_valid = verify_signature(public_key, message, signature)
print(f"验证结果: {is_valid}\n")

# 验证（篡改的消息）
print("=" * 60)
print("篡改检测演示")
print("=" * 60 + "\n")

tampered_message = b"This is a MODIFIED contract that needs to be signed."
is_valid_tampered = verify_signature(public_key, tampered_message, signature)
print(f"篡改消息验证结果: {is_valid_tampered}")
```

### 2. 不同哈希算法的签名

```python
def sign_with_sha512(private_key, message: bytes) -> bytes:
    """使用 PSS-SHA512 签名"""
    signature = private_key.sign(
        message,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA512()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA512()
    )
    return signature

def verify_with_sha512(public_key, message: bytes, signature: bytes) -> bool:
    """验证 PSS-SHA512 签名"""
    try:
        public_key.verify(
            signature,
            message,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA512()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA512()
        )
        return True
    except:
        return False

# 测试
print("\n" + "=" * 60)
print("不同哈希算法的签名")
print("=" * 60 + "\n")

test_msg = b"Test message for different hash algorithms"

sig_sha256 = sign_message(private_key, test_msg)
sig_sha512 = sign_with_sha512(private_key, test_msg)

print(f"SHA256 签名长度: {len(sig_sha256)} 字节")
print(f"SHA512 签名长度: {len(sig_sha512)} 字节")
print(f"\n注意: 签名长度取决于密钥长度，不是哈希算法")
```

### 3. 文件签名

```python
def sign_file(private_key, filename: str) -> bytes:
    """
    签名文件
    
    流程:
    1. 计算文件哈希
    2. 签名哈希值
    """
    print(f"\n[文件签名] 文件: {filename}")
    
    # 计算文件的 SHA256 哈希
    hasher = hashes.Hash(hashes.SHA256(), backend=backend)
    
    with open(filename, 'rb') as f:
        while True:
            chunk = f.read(8192)
            if not chunk:
                break
            hasher.update(chunk)
    
    file_hash = hasher.finalize()
    print(f"[文件签名] 文件哈希: {file_hash.hex()}")
    
    # 签名哈希
    signature = private_key.sign(
        file_hash,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    
    print(f"[文件签名] ✅ 签名生成成功")
    
    return signature

def verify_file_signature(public_key, filename: str, signature: bytes) -> bool:
    """验证文件签名"""
    print(f"\n[文件验证] 文件: {filename}")
    
    # 计算文件哈希
    hasher = hashes.Hash(hashes.SHA256(), backend=backend)
    
    with open(filename, 'rb') as f:
        while True:
            chunk = f.read(8192)
            if not chunk:
                break
            hasher.update(chunk)
    
    file_hash = hasher.finalize()
    print(f"[文件验证] 文件哈希: {file_hash.hex()}")
    
    # 验证签名
    try:
        public_key.verify(
            signature,
            file_hash,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        print(f"[文件验证] ✅ 签名验证成功")
        return True
    except:
        print(f"[文件验证] ❌ 签名验证失败")
        return False

# 使用示例
# 创建测试文件
test_file = "document.txt"
with open(test_file, 'w') as f:
    f.write("This is an important document that needs to be signed.\n" * 100)

# 签名文件
file_signature = sign_file(private_key, test_file)

# 保存签名
with open(test_file + ".sig", 'wb') as f:
    f.write(file_signature)

print(f"\n签名已保存到: {test_file}.sig")

# 验证文件签名
is_valid = verify_file_signature(public_key, test_file, file_signature)

# 修改文件并验证
with open(test_file, 'a') as f:
    f.write("TAMPERED LINE\n")

print("\n" + "=" * 60)
print("篡改后的文件验证")
print("=" * 60)

is_valid_after_tamper = verify_file_signature(public_key, test_file, file_signature)

# 清理
import os
os.remove(test_file)
os.remove(test_file + ".sig")
```

---

## 六、完整工具类封装

```python
class RSACipher:
    """
    RSA 加密工具类（生产就绪版本）
    
    特性:
    - 密钥生成和管理
    - 加密/解密（OAEP）
    - 数字签名/验证（PSS）
    - 混合加密支持
    - 密钥序列化
    """
    
    def __init__(self, key_size: int = 2048):
        """
        初始化 RSA 加密器
        
        参数:
            key_size: 密钥长度（2048, 3072, 4096）
        """
        if key_size not in [2048, 3072, 4096]:
            raise ValueError("密钥长度必须是 2048, 3072 或 4096")
        
        self.key_size = key_size
        self.private_key = None
        self.public_key = None
    
    def generate_keypair(self):
        """生成新的密钥对"""
        self.private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=self.key_size,
            backend=backend
        )
        self.public_key = self.private_key.public_key()
        return self
    
    def load_private_key(self, pem_data: bytes, password: bytes = None):
        """加载私钥"""
        self.private_key = serialization.load_pem_private_key(
            pem_data,
            password=password,
            backend=backend
        )
        self.public_key = self.private_key.public_key()
        return self
    
    def load_public_key(self, pem_data: bytes):
        """加载公钥"""
        self.public_key = serialization.load_pem_public_key(
            pem_data,
            backend=backend
        )
        return self
    
    def export_private_key(self, password: bytes = None) -> bytes:
        """导出私钥为 PEM 格式"""
        if not self.private_key:
            raise ValueError("私钥不存在")
        
        encryption = (
            serialization.BestAvailableEncryption(password)
            if password else serialization.NoEncryption()
        )
        
        return self.private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=encryption
        )
    
    def export_public_key(self) -> bytes:
        """导出公钥为 PEM 格式"""
        if not self.public_key:
            raise ValueError("公钥不存在")
        
        return self.public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
    
    def encrypt(self, plaintext: bytes, use_hybrid: bool = True) -> bytes | dict:
        """
        加密数据
        
        参数:
            plaintext: 明文
            use_hybrid: 是否使用混合加密（推荐用于大数据）
        
        返回:
            如果 use_hybrid=False: 密文（bytes）
            如果 use_hybrid=True: 混合加密数据（dict）
        """
        if not self.public_key:
            raise ValueError("公钥不存在")
        
        # 计算最大明文长度
        max_length = (self.public_key.key_size // 8) - 2 * 32 - 2
        
        if len(plaintext) <= max_length and not use_hybrid:
            # 直接 RSA 加密
            return self.public_key.encrypt(
                plaintext,
                padding.OAEP(
                    mgf=padding.MGF1(algorithm=hashes.SHA256()),
                    algorithm=hashes.SHA256(),
                    label=None
                )
            )
        else:
            # 混合加密
            aes_key = secrets.token_bytes(32)
            aesgcm = AESGCM(aes_key)
            nonce = os.urandom(12)
            ciphertext = aesgcm.encrypt(nonce, plaintext, None)
            
            encrypted_key = self.public_key.encrypt(
                aes_key,
                padding.OAEP(
                    mgf=padding.MGF1(algorithm=hashes.SHA256()),
                    algorithm=hashes.SHA256(),
                    label=None
                )
            )
            
            return {
                'encrypted_key': b64encode(encrypted_key).decode(),
                'nonce': b64encode(nonce).decode(),
                'ciphertext': b64encode(ciphertext).decode()
            }
    
    def decrypt(self, encrypted_data: bytes | dict) -> bytes:
        """
        解密数据
        
        参数:
            encrypted_data: 密文（bytes）或混合加密数据（dict）
        """
        if not self.private_key:
            raise ValueError("私钥不存在")
        
        if isinstance(encrypted_data, dict):
            # 混合解密
            encrypted_key = b64decode(encrypted_data['encrypted_key'])
            nonce = b64decode(encrypted_data['nonce'])
            ciphertext = b64decode(encrypted_data['ciphertext'])
            
            aes_key = self.private_key.decrypt(
                encrypted_key,
                padding.OAEP(
                    mgf=padding.MGF1(algorithm=hashes.SHA256()),
                    algorithm=hashes.SHA256(),
                    label=None
                )
            )
            
            aesgcm = AESGCM(aes_key)
            return aesgcm.decrypt(nonce, ciphertext, None)
        else:
            # 直接 RSA 解密
            return self.private_key.decrypt(
                encrypted_data,
                padding.OAEP(
                    mgf=padding.MGF1(algorithm=hashes.SHA256()),
                    algorithm=hashes.SHA256(),
                    label=None
                )
            )
    
    def sign(self, message: bytes) -> bytes:
        """
        签名消息（PSS-SHA256）
        
        参数:
            message: 要签名的消息
        
        返回:
            签名
        """
        if not self.private_key:
            raise ValueError("私钥不存在")
        
        return self.private_key.sign(
            message,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
    
    def verify(self, message: bytes, signature: bytes) -> bool:
        """
        验证签名
        
        参数:
            message: 原始消息
            signature: 签名
        
        返回:
            True: 验证成功, False: 验证失败
        """
        if not self.public_key:
            raise ValueError("公钥不存在")
        
        try:
            self.public_key.verify(
                signature,
                message,
                padding.PSS(
                    mgf=padding.MGF1(hashes.SHA256()),
                    salt_length=padding.PSS.MAX_LENGTH
                ),
                hashes.SHA256()
            )
            return True
        except:
            return False

# ============ 使用示例 ============

print("\n" + "=" * 60)
print("完整工具类测试")
print("=" * 60 + "\n")

# 1. 生成密钥对
rsa_cipher = RSACipher(key_size=2048)
rsa_cipher.generate_keypair()
print("✅ 密钥对生成成功\n")

# 2. 导出密钥
private_pem = rsa_cipher.export_private_key(password=b"password123")
public_pem = rsa_cipher.export_public_key()
print("✅ 密钥导出成功\n")

# 3. 加密（短消息）
short_message = b"Hello RSA!"
encrypted_short = rsa_cipher.encrypt(short_message, use_hybrid=False)
print(f"短消息加密: {len(encrypted_short)} 字节")

decrypted_short = rsa_cipher.decrypt(encrypted_short)
assert short_message == decrypted_short
print("✅ 短消息加密/解密成功\n")

# 4. 混合加密（长消息）
long_message = b"A" * 1000
encrypted_long = rsa_cipher.encrypt(long_message, use_hybrid=True)
print(f"长消息混合加密: {json.dumps(encrypted_long, indent=2)[:200]}...\n")

decrypted_long = rsa_cipher.decrypt(encrypted_long)
assert long_message == decrypted_long
print("✅ 长消息混合加密/解密成功\n")

# 5. 数字签名
message_to_sign = b"Important document"
signature = rsa_cipher.sign(message_to_sign)
print(f"签名长度: {len(signature)} 字节")

is_valid = rsa_cipher.verify(message_to_sign, signature)
print(f"签名验证: {is_valid}")

is_valid_tampered = rsa_cipher.verify(b"Tampered document", signature)
print(f"篡改消息验证: {is_valid_tampered}\n")

print("=" * 60)
print("✅ 所有测试通过")
print("=" * 60)
```

---

## 七、常见应用场景

### 1. HTTPS/TLS 证书

```python
from cryptography import x509
from cryptography.x509.oid import NameOID
import datetime

def generate_self_signed_certificate(
    private_key,
    common_name: str = "example.com",
    days_valid: int = 365
):
    """
    生成自签名证书（用于测试）
    
    注意: 生产环境应使用 CA 签发的证书
    """
    subject = issuer = x509.Name([
        x509.NameAttribute(NameOID.COUNTRY_NAME, "US"),
        x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, "California"),
        x509.NameAttribute(NameOID.LOCALITY_NAME, "San Francisco"),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, "My Company"),
        x509.NameAttribute(NameOID.COMMON_NAME, common_name),
    ])
    
    cert = x509.CertificateBuilder().subject_name(
        subject
    ).issuer_name(
        issuer
    ).public_key(
        private_key.public_key()
    ).serial_number(
        x509.random_serial_number()
    ).not_valid_before(
        datetime.datetime.utcnow()
    ).not_valid_after(
        datetime.datetime.utcnow() + datetime.timedelta(days=days_valid)
    ).add_extension(
        x509.SubjectAlternativeName([
            x509.DNSName(common_name),
            x509.DNSName(f"www.{common_name}"),
        ]),
        critical=False,
    ).sign(private_key, hashes.SHA256(), backend=backend)
    
    return cert

# 生成证书
cert = generate_self_signed_certificate(private_key, "myapp.local")

# 导出证书
cert_pem = cert.public_bytes(serialization.Encoding.PEM)

print("\n" + "=" * 60)
print("自签名证书���例")
print("=" * 60 + "\n")
print(cert_pem.decode()[:500])
print("...\n")

# 保存证书
with open("certificate.pem", "wb") as f:
    f.write(cert_pem)

print("✅ 证书已保存到 certificate.pem")
```

### 2. SSH 密钥认证

```python
def generate_ssh_keypair(comment: str = "user@host"):
    """
    生成 SSH 密钥对
    
    参数:
        comment: SSH 密钥注释
    """
    # 生成密钥对
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=4096,  # SSH 推荐 4096 位
        backend=backend
    )
    
    public_key = private_key.public_key()
    
    # 导出私钥（PEM 格式）
    private_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.OpenSSH,
        encryption_algorithm=serialization.NoEncryption()
    )
    
    # 导出公钥（OpenSSH 格式）
    public_ssh = public_key.public_bytes(
        encoding=serialization.Encoding.OpenSSH,
        format=serialization.PublicFormat.OpenSSH
    )
    
    # 添加注释
    public_ssh_with_comment = public_ssh + f" {comment}".encode()
    
    return private_pem, public_ssh_with_comment

# 生成 SSH 密钥
ssh_private, ssh_public = generate_ssh_keypair("myuser@mycomputer")

print("\n" + "=" * 60)
print("SSH 密钥对生成")
print("=" * 60 + "\n")

# 保存密钥
with open("id_rsa", "wb") as f:
    f.write(ssh_private)
os.chmod("id_rsa", 0o600)  # 设置权限为 600

with open("id_rsa.pub", "wb") as f:
    f.write(ssh_public)

print("SSH 公钥:")
print(ssh_public.decode())
print("\n✅ SSH 密钥已生成")
print("   私钥: id_rsa")
print("   公钥: id_rsa.pub")
```

### 3. JWT 令牌签名

```python
import json
import hmac
import hashlib

def create_jwt_rs256(private_key, payload: dict, expires_in: int = 3600) -> str:
    """
    创建 RS256 签名的 JWT
    
    参数:
        private_key: RSA 私钥
        payload: JWT 载荷
        expires_in: 过期时间（秒）
    """
    import time
    
    # Header
    header = {
        "alg": "RS256",
        "typ": "JWT"
    }
    
    # Payload
    payload['exp'] = int(time.time()) + expires_in
    payload['iat'] = int(time.time())
    
    # Base64URL 编码
    def base64url_encode(data: bytes) -> str:
        return b64encode(data).decode().rstrip('=').replace('+', '-').replace('/', '_')
    
    header_b64 = base64url_encode(json.dumps(header).encode())
    payload_b64 = base64url_encode(json.dumps(payload).encode())
    
    # 签名
    message = f"{header_b64}.{payload_b64}".encode()
    signature = private_key.sign(
        message,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    signature_b64 = base64url_encode(signature)
    
    # 组合 JWT
    jwt = f"{header_b64}.{payload_b64}.{signature_b64}"
    
    return jwt

def verify_jwt_rs256(public_key, jwt: str) -> dict:
    """验证并解析 JWT"""
    import time
    
    # 分割 JWT
    parts = jwt.split('.')
    if len(parts) != 3:
        raise ValueError("无效的 JWT 格式")
    
    header_b64, payload_b64, signature_b64 = parts
    
    # Base64URL 解码
    def base64url_decode(data: str) -> bytes:
        padding = 4 - (len(data) % 4)
        data = data.replace('-', '+').replace('_', '/')
        if padding != 4:
            data += '=' * padding
        return b64decode(data)
    
    # 验证签名
    message = f"{header_b64}.{payload_b64}".encode()
    signature = base64url_decode(signature_b64)
    
    try:
        public_key.verify(
            signature,
            message,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
    except:
        raise ValueError("JWT 签名验证失败")
    
    # 解析 payload
    payload = json.loads(base64url_decode(payload_b64))
    
    # 检查过期时间
    if payload.get('exp') and payload['exp'] < time.time():
        raise ValueError("JWT 已过期")
    
    return payload

# 使用示例
print("\n" + "=" * 60)
print("JWT (RS256) 示例")
print("=" * 60 + "\n")

payload = {
    "user_id": 12345,
    "username": "john_doe",
    "role": "admin"
}

# 创建 JWT
jwt = create_jwt_rs256(private_key, payload, expires_in=3600)
print(f"JWT: {jwt[:80]}...\n")

# 验证 JWT
verified_payload = verify_jwt_rs256(public_key, jwt)
print(f"验证通过，载荷:")
print(json.dumps(verified_payload, indent=2))
```

### 4. 代码签名

```python
def sign_software_package(private_key, package_path: str) -> dict:
    """
    签名软件包
    
    返回:
        {
            'file_hash': 文件哈希,
            'signature': 签名,
            'timestamp': 时间戳,
            'signer_info': 签名者信息
        }
    """
    import time
    import hashlib
    
    # 计算文件哈希
    hasher = hashlib.sha256()
    with open(package_path, 'rb') as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    
    file_hash = hasher.digest()
    
    # 创建签名数据
    signature_data = {
        'file_hash': file_hash.hex(),
        'timestamp': int(time.time()),
        'file_name': os.path.basename(package_path)
    }
    
    # 签名
    message = json.dumps(signature_data, sort_keys=True).encode()
    signature = private_key.sign(
        message,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    
    return {
        'signature_data': signature_data,
        'signature': b64encode(signature).decode(),
        'public_key': b64encode(
            private_key.public_key().public_bytes(
                encoding=serialization.Encoding.DER,
                format=serialization.PublicFormat.SubjectPublicKeyInfo
            )
        ).decode()
    }

def verify_software_package(package_path: str, signature_info: dict) -> bool:
    """验证软件包签名"""
    import hashlib
    
    # 加载公钥
    public_key_der = b64decode(signature_info['public_key'])
    public_key = serialization.load_der_public_key(public_key_der, backend=backend)
    
    # 计算当前文件哈希
    hasher = hashlib.sha256()
    with open(package_path, 'rb') as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    
    current_hash = hasher.digest().hex()
    
    # 验证哈希是否匹配
    if current_hash != signature_info['signature_data']['file_hash']:
        print("❌ 文件哈希不匹配！文件可能被篡改")
        return False
    
    # 验证签名
    message = json.dumps(signature_info['signature_data'], sort_keys=True).encode()
    signature = b64decode(signature_info['signature'])
    
    try:
        public_key.verify(
            signature,
            message,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        print("✅ 签名验证成功")
        return True
    except:
        print("❌ 签名验证失败")
        return False

# 使用示例
print("\n" + "=" * 60)
print("软件包签名示例")
print("=" * 60 + "\n")

# 创建测试软件包
package_file = "myapp_v1.0.0.zip"
with open(package_file, 'wb') as f:
    f.write(b"Software package content" * 1000)

# 签名软件包
sig_info = sign_software_package(private_key, package_file)
print(f"软件包已签名:")
print(f"  文件哈希: {sig_info['signature_data']['file_hash'][:32]}...")
print(f"  时间戳: {sig_info['signature_data']['timestamp']}\n")

# 保存签名
with open(package_file + ".sig", 'w') as f:
    json.dump(sig_info, f, indent=2)

# 验证软件包
is_valid = verify_software_package(package_file, sig_info)

# 清理
os.remove(package_file)
os.remove(package_file + ".sig")
```

---

## 八、安全最佳实践

### ✅ 务必遵守的规则

```python
def security_best_practices():
    """RSA 安全最佳实践"""
    
    print("\n" + "=" * 60)
    print("🔒 RSA 安全最佳实践")
    print("=" * 60 + "\n")
    
    practices = {
        "密钥生成": [
            "✅ 使用至少 2048 位密钥（推荐 3072 或 4096）",
            "✅ 公开指数使用 65537",
            "✅ 使用密码学安全的随机数生成器",
            "✅ 在可信环境中生成密钥"
        ],
        "密钥管理": [
            "✅ 私钥必须加密存储（使用强密码）",
            "✅ 使用 HSM 或 KMS 管理密钥",
            "✅ 定期轮换密钥（建议每年）",
            "✅ 私钥权限设置为 600 (仅所有者可读)",
            "✅ 备份密钥到安全位置",
            "✅ 销毁密钥时使用安全擦除"
        ],
        "加密操作": [
            "✅ 始终使用 OAEP 填充（不要用 PKCS#1 v1.5）",
            "✅ 使用 SHA-256 或更强的哈希算法",
            "✅ 大数据使用混合加密（RSA + AES）",
            "✅ 不要加密超过密钥长度的数据"
        ],
        "签名操作": [
            "✅ 使用 PSS 填充方案",
            "✅ 签名前计算消息哈希",
            "✅ 包含时间戳防止重放攻击",
            "✅ 验证签名时检查证书有效期"
        ],
        "协议设计": [
            "✅ 使用标准协议（TLS, JWT, CMS）",
            "✅ 实现证书链验证",
            "✅ 支持证书吊销检查（CRL/OCSP）",
            "✅ 记录所有密钥操作日志"
        ]
    }
    
    for category, items in practices.items():
        print(f"【{category}】")
        for item in items:
            print(f"  {item}")
        print()

security_best_practices()
```

### ❌ 绝对禁止的操作

```python
def security_antipatterns():
    """RSA 安全反模式"""
    
    print("\n" + "=" * 60)
    print("🚫 RSA 安全反模式（禁止！）")
    print("=" * 60 + "\n")
    
    antipatterns = {
        "密钥问题": [
            "❌ 使用 1024 位或更短的密钥",
            "❌ 使用小的公开指数（如 3）",
            "❌ 重用密钥对于不同目的（加密和签名分开）",
            "❌ 硬编码私钥在代码中",
            "❌ 通过不安全渠道传输私钥"
        ],
        "填充问题": [
            "❌ 使用 PKCS#1 v1.5 填充加密",
            "❌ 使用无填充的\"裸\" RSA",
            "❌ 自己实现填充方案",
            "❌ 使用弱哈希算法（MD5, SHA1）"
        ],
        "实现问题": [
            "❌ 直接用 RSA 加密大文件",
            "❌ 忽略签名验证失败",
            "❌ 不检查证书有效期",
            "❌ 信任自签名证书（生产环境）"
        ],
        "协议问题": [
            "❌ 不使用时间戳（易受重放攻击）",
            "❌ 不验证证书链",
            "❌ 使用过时的 SSL/TLS 版本",
            "❌ 禁用证书验证（开发环境除外）"
        ]
    }
    
    for category, items in antipatterns.items():
        print(f"【{category}】")
        for item in items:
            print(f"  {item}")
        print()

security_antipatterns()
```

### 🔍 安全检查清单

```python
def security_checklist():
    """RSA 使用安全检查清单"""
    
    checklist = {
        "设计阶段": [
            "☐ 确定密钥长度需求（2048/3072/4096）",
            "☐ 选择合适的填充方案（OAEP/PSS）",
            "☐ 规划密钥生命周期管理",
            "☐ 设计密钥轮换策略",
            "☐ 评估是否需要混合加密"
        ],
        "实现阶段": [
            "☐ 使用标准密码学库（不要自己实现）",
            "☐ 私钥加密存储",
            "☐ 实现错误处理",
            "☐ 添加操作日志",
            "☐ 编写单元测试"
        ],
        "部署阶段": [
            "☐ 在安全环境中生成密钥",
            "☐ 配置适当的文件权限",
            "☐ 设置密钥备份",
            "☐ 配置监控和告警",
            "☐ 准备应急响应计划"
        ],
        "运维阶段": [
            "☐ 定期审计密钥使用",
            "☐ 监控异常操作",
            "☐ 执行密钥轮换",
            "☐ 更新加密库",
            "☐ 进行安全评估"
        ]
    }
    
    print("\n" + "=" * 60)
    print("📋 RSA 安全检查清单")
    print("=" * 60 + "\n")
    
    for phase, items in checklist.items():
        print(f"【{phase}】")
        for item in items:
            print(f"  {item}")
        print()

security_checklist()
```

---

## 九、性能考虑

### 1. 性能基准测试

```python
import time

def performance_benchmark():
    """RSA 性能基准测试"""
    
    print("\n" + "=" * 60)
    print("⚡ RSA 性能基准测试")
    print("=" * 60 + "\n")
    
    key_sizes = [2048, 3072, 4096]
    iterations = 100
    
    results = []
    
    for key_size in key_sizes:
        print(f"测试 {key_size} 位密钥...")
        
        # 密钥生成
        start = time.time()
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=key_size,
            backend=backend
        )
        public_key = private_key.public_key()
        keygen_time = time.time() - start
        
        # 测试数据
        plaintext = b"A" * 100  # 100 字节
        
        # 加密性能
        start = time.time()
        for _ in range(iterations):
            ciphertext = public_key.encrypt(
                plaintext,
                padding.OAEP(
                    mgf=padding.MGF1(algorithm=hashes.SHA256()),
                    algorithm=hashes.SHA256(),
                    label=None
                )
            )
        encrypt_time = (time.time() - start) / iterations
        
        # 解密性能
        start = time.time()
        for _ in range(iterations):
            decrypted = private_key.decrypt(
                ciphertext,
                padding.OAEP(
                    mgf=padding.MGF1(algorithm=hashes.SHA256()),
                    algorithm=hashes.SHA256(),
                    label=None
                )
            )
        decrypt_time = (time.time() - start) / iterations
        
        # 签名性能
        message = b"Test message for signing"
        start = time.time()
        for _ in range(iterations):
            signature = private_key.sign(
                message,
                padding.PSS(
                    mgf=padding.MGF1(hashes.SHA256()),
                    salt_length=padding.PSS.MAX_LENGTH
                ),
                hashes.SHA256()
            )
        sign_time = (time.time() - start) / iterations
        
        # 验证性能
        start = time.time()
        for _ in range(iterations):
            try:
                public_key.verify(
                    signature,
                    message,
                    padding.PSS(
                        mgf=padding.MGF1(hashes.SHA256()),
                        salt_length=padding.PSS.MAX_LENGTH
                    ),
                    hashes.SHA256()
                )
            except:
                pass
        verify_time = (time.time() - start) / iterations
        
        results.append({
            'key_size': key_size,
            'keygen': keygen_time,
            'encrypt': encrypt_time,
            'decrypt': decrypt_time,
            'sign': sign_time,
            'verify': verify_time
        })
    
    # 打印结果
    print("\n" + "=" * 70)
    print(f"{'密钥长度':<12} {'密钥生成':<12} {'加密':<12} {'解密':<12} {'签名':<12} {'验证':<12}")
    print("=" * 70)
    
    for r in results:
        print(
            f"{r['key_size']:<12} "
            f"{r['keygen']:>10.3f}s  "
            f"{r['encrypt']*1000:>8.2f}ms  "
            f"{r['decrypt']*1000:>8.2f}ms  "
            f"{r['sign']*1000:>8.2f}ms  "
            f"{r['verify']*1000:>8.2f}ms"
        )
    
    print("\n" + "=" * 70)
    print("结论:")
    print("  - 密钥长度越长，所有操作都越慢")
    print("  - 解密和签名（私钥操作）比加密和验证（公钥操作）慢得多")
    print("  - 4096位比2048位慢约6-8倍")
    print("=" * 70)

performance_benchmark()
```

### 2. RSA vs 对称加密性能对比

```python
def compare_with_aes():
    """RSA vs AES 性能对比"""
    
    print("\n" + "=" * 60)
    print("RSA vs AES 性能对比")
    print("=" * 60 + "\n")
    
    iterations = 1000
    data_size = 100  # 字节
    plaintext = os.urandom(data_size)
    
    # RSA 2048
    rsa_key = rsa.generate_private_key(65537, 2048, backend)
    rsa_public = rsa_key.public_key()
    
    start = time.time()
    for _ in range(iterations):
        ciphertext = rsa_public.encrypt(
            plaintext,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
    rsa_time = (time.time() - start) / iterations
    
    # AES-256-GCM
    aes_key = secrets.token_bytes(32)
    aesgcm = AESGCM(aes_key)
    
    start = time.time()
    for _ in range(iterations):
        nonce = os.urandom(12)
        ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    aes_time = (time.time() - start) / iterations
    
    print(f"数据大小: {data_size} 字节")
    print(f"迭代次数: {iterations}\n")
    print(f"RSA-2048 加密时间: {rsa_time*1000:.3f} ms")
    print(f"AES-256-GCM 加密时间: {aes_time*1000:.3f} ms")
    print(f"\n性能差距: RSA 比 AES 慢 {rsa_time/aes_time:.0f}倍")
    print("\n这就是为什么实际应用中使用混合加密！")

compare_with_aes()
```

---

## 十、常见问题和调试

### 1. 错误诊断

```python
def diagnose_common_errors():
    """诊断常见 RSA 错误"""
    
    print("\n" + "=" * 60)
    print("🔧 常见错误诊断")
    print("=" * 60 + "\n")
    
    errors = {
        "ValueError: Encryption/decryption failed": {
            "原因": [
                "使用了错误的填充方案",
                "私钥和公钥不匹配",
                "密文被破坏"
            ],
            "解决": [
                "确保加密和解密使用相同的填充方案",
                "验证密钥对是否匹配",
                "检查密文传输是否完整"
            ]
        },
        "ValueError: Data too long for key size": {
            "原因": [
                "明文超过最大长���限制",
                "忘记考虑填充开销"
            ],
            "解决": [
                "使用混合加密",
                "检查最大明文长度计算公式",
                "使用更长的密钥"
            ]
        },
        "cryptography.exceptions.InvalidSignature": {
            "原因": [
                "签名验证失败",
                "消息被篡改",
                "使用了错误的公钥"
            ],
            "解决": [
                "确认使用正确的公钥",
                "检查消息是否被修改",
                "验证签名算法是否一致"
            ]
        },
        "私钥加载失败": {
            "原因": [
                "密码错误",
                "文件格式错误",
                "密钥文件损坏"
            ],
            "解决": [
                "检查密码是否正确",
                "确认 PEM 格式正确",
                "从备份恢复密钥"
            ]
        }
    }
    
    for error, info in errors.items():
        print(f"错误: {error}")
        print(f"  可能原因:")
        for reason in info['原因']:
            print(f"    - {reason}")
        print(f"  解决方法:")
        for solution in info['解决']:
            print(f"    - {solution}")
        print()

diagnose_common_errors()
```

### 2. 调试工具

```python
class RSADebugger:
    """RSA 调试工具"""
    
    @staticmethod
    def inspect_encrypted_data(ciphertext: bytes, key_size: int):
        """检查加密数据"""
        print(f"\n[调试] 加密数据分析")
        print(f"  密文长度: {len(ciphertext)} 字节")
        print(f"  密钥长度: {key_size} 位 ({key_size//8} 字节)")
        print(f"  密文 (hex): {ciphertext.hex()[:64]}...")
        
        if len(ciphertext) != key_size // 8:
            print(f"  ⚠️  警告: 密文长度不等于密钥长度！")
    
    @staticmethod
    def test_key_pair(private_key, public_key):
        """测试密钥对是否匹配"""
        print(f"\n[调试] 密钥对匹配测试")
        
        test_message = b"Test message for key pair validation"
        
        try:
            # 加密
            ciphertext = public_key.encrypt(
                test_message,
                padding.OAEP(
                    mgf=padding.MGF1(algorithm=hashes.SHA256()),
                    algorithm=hashes.SHA256(),
                    label=None
                )
            )
            
            # 解密
            decrypted = private_key.decrypt(
                ciphertext,
                padding.OAEP(
                    mgf=padding.MGF1(algorithm=hashes.SHA256()),
                    algorithm=hashes.SHA256(),
                    label=None
                )
            )
            
            if test_message == decrypted:
                print(f"  ✅ 密钥对匹配")
                return True
            else:
                print(f"  ❌ 解密结果不匹配")
                return False
        except Exception as e:
            print(f"  ❌ 密钥对不匹配: {e}")
            return False
    
    @staticmethod
    def calculate_max_plaintext(key_size: int, hash_algorithm: str = "SHA256"):
        """计算最大明文长度"""
        hash_sizes = {
            "SHA256": 32,
            "SHA384": 48,
            "SHA512": 64
        }
        
        key_bytes = key_size // 8
        hash_bytes = hash_sizes.get(hash_algorithm, 32)
        max_length = key_bytes - 2 * hash_bytes - 2
        
        print(f"\n[调试] 最大明文长度计算")
        print(f"  密钥长度: {key_size} 位 ({key_bytes} 字节)")
        print(f"  哈希算法: {hash_algorithm} ({hash_bytes} 字节)")
        print(f"  最大明文: {max_length} 字节")
        
        return max_length

# 使用调试工具
print("\n" + "=" * 60)
print("调试工具演示")
print("=" * 60)

debugger = RSADebugger()

# 测试密钥对
debugger.test_key_pair(private_key, public_key)

# 计算最大明文长度
debugger.calculate_max_plaintext(2048, "SHA256")
debugger.calculate_max_plaintext(4096, "SHA512")

# 检查加密数据
test_ciphertext = public_key.encrypt(
    b"Test",
    padding.OAEP(
        mgf=padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None
    )
)
debugger.inspect_encrypted_data(test_ciphertext, 2048)
```

---

## 十一、总结对比表

### RSA vs 其他算法

| 特性 | RSA | ECC | AES |
|:-----|:----|:----|:----|
| **类型** | 非对称 | 非对称 | 对称 |
| **密钥长度** | 2048-4096位 | 256-521位 | 128-256位 |
| **速度** | 慢 | 中等 | 很快 |
| **密钥分发** | 不需要预共享 | 不需要预共享 | 需要预共享 |
| **用途** | 加密、签名、密钥交换 | 加密、签名、密钥交换 | 批量数据加密 |
| **量子安全** | ❌ 不安全 | ❌ 不安全 | ✅ 安全 |
| **推荐场景** | 密钥交换、数字签名 | 移动设备、IoT | 大数据加密 |

### 密钥长度安全性对比

| 算法 | 密钥长度 | 对称等效强度 | 破解时间估计 |
|:-----|:---------|:-------------|:-------------|
| RSA | 1024位 | ~80位 | 可行（已废弃） |
| RSA | 2048位 | ~112位 | 至2030年安全 |
| RSA | 3072位 | ~128位 | 至2030年后安全 |
| RSA | 4096位 | ~140位 | 长期安全 |
| ECC | 256位 | ~128位 | 至2030年后安全 |
| AES | 128位 | 128位 | 不可破解 |
| AES | 256位 | 256位 | 量子时代安全 |

### 填充方案对比

| 填充方案 | 用途 | 安全性 | 推荐度 | 标准 |
|:---------|:-----|:-------|:-------|:-----|
| **OAEP** | 加密 | 高（IND-CCA2） | ⭐⭐⭐⭐⭐ | PKCS#1 v2.0+ |
| **PSS** | 签名 | 高（可证明安全） | ⭐⭐⭐⭐⭐ | PKCS#1 v2.1+ |
| **PKCS#1 v1.5** | 加密 | 低（有漏洞） | 🚫 | 已废弃 |
| **无填充** | - | 极低 | 🚫 | 绝对禁止 |

---

## 十二、迁移和升级

### 从 RSA 迁移到 ECC

```python
from cryptography.hazmat.primitives.asymmetric import ec

def migrate_to_ecc():
    """从 RSA 迁移到 ECC（椭圆曲线加密）"""
    
    print("\n" + "=" * 60)
    print("RSA → ECC 迁移指南")
    print("=" * 60 + "\n")
    
    # 生成 ECC 密钥（256位，相当于 RSA 3072位）
    ecc_private = ec.generate_private_key(ec.SECP256R1(), backend)
    ecc_public = ecc_private.public_key()
    
    print("ECC 优势:")
    print("  ✅ 更短的密钥长度（256位 ≈ RSA 3072位）")
    print("  ✅ 更快的运算速度")
    print("  ✅ 更少的带宽占用")
    print("  ✅ 更适合移动设备和 IoT\n")
    
    print("RSA vs ECC 密钥长度对比:")
    print("  RSA 3072位 ≈ ECC 256位")
    print("  RSA 4096位 ≈ ECC 384位")
    print("  RSA 15360位 ≈ ECC 521位\n")
    
    print("迁移策略:")
    print("  1. 双重签名（同时使用 RSA 和 ECC）")
    print("  2. 逐步淘汰 RSA")
    print("  3. 保留 RSA 用于遗留兼容")

migrate_to_ecc()
```

### 量子后加密准备

```python
def post_quantum_cryptography():
    """量子后加密准备"""
    
    print("\n" + "=" * 60)
    print("🔮 量子后加密（Post-Quantum Cryptography）")
    print("=" * 60 + "\n")
    
    print("量子威胁:")
    print("  ⚠️  Shor 算法可破解 RSA 和 ECC")
    print("  ⚠️  大规模量子计算机可能在 10-15 年内实现\n")
    
    print("NIST 标准化候选算法:")
    print("  - CRYSTALS-Kyber (密钥封装)")
    print("  - CRYSTALS-Dilithium (数字签名)")
    print("  - FALCON (数字签名)")
    print("  - SPHINCS+ (数字签名)\n")
    
    print("准备建议:")
    print("  1. 关注 NIST PQC 标准化进展")
    print("  2. 规划混合方案（RSA + PQC）")
    print("  3. 提高密钥长度（RSA 4096位）")
    print("  4. 记录当前加密数据（量子计算机\"先存储后解密\"威胁）")
    print("  5. 为迁移准备充足时间")

post_quantum_cryptography()
```

---

## 十三、延伸阅读

### 官方标准文档

- **[RFC 8017](https://tools.ietf.org/html/rfc8017)**: PKCS #1: RSA Cryptography Specifications Version 2.2
- **[NIST FIPS 186-5](https://csrc.nist.gov/publications/detail/fips/186/5/final)**: Digital Signature Standard (DSS)
- **[RFC 7517](https://tools.ietf.org/html/rfc7517)**: JSON Web Key (JWK)
- **[X.509](https://www.itu.int/rec/T-REC-X.509)**: 公钥基础设施证书格式

### 安全指南

- [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
- [NIST Key Management Guidelines](https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final)
- [BSI Technical Guideline TR-02102](https://www.bsi.bund.de/EN/Themen/Unternehmen-und-Organisationen/Standards-und-Zertifizierung/Technische-Richtlinien/TR-nach-Thema-sortiert/tr02102/tr02102_node.html)

### 推荐书籍

- 《Introduction to Modern Cryptography》 - Katz & Lindell
- 《Serious Cryptography》 - Jean-Philippe Aumasson
- 《Applied Cryptography》 - Bruce Schneier

---

## 最后的建议

```python
def final_recommendations():
    """RSA 使用最终建议"""
    
    print("\n" + "=" * 70)
    print("🎯 RSA 使用最终建议")
    print("=" * 70 + "\n")
    
    recommendations = [
        "1. ✅ 新项目使用 2048 位密钥（最低），推荐 3072 或 4096 位",
        "2. ✅ 始终使用 OAEP 填充加密，PSS 填充签名",
        "3. ✅ 大数据使用混合加密（RSA + AES-GCM）",
        "4. ✅ 私钥必须加密存储，使用强密码保护",
        "5. ✅ 考虑使用 HSM 或云 KMS 管理密钥",
        "6. ✅ 实施密钥轮换策略（建议每年）",
        "7. ✅ 加密和签名使用不同的密钥对",
        "8. ⚠️  RSA 不抗量子攻击，关注 PQC 进展",
        "9. ⚠️  考虑迁移到 ECC（更短密钥，更快速度）",
        "10. 📚 持续学习密码学最新发展"
    ]
    
    for rec in recommendations:
        print(f"  {rec}")
    
    print("\n" + "=" * 70)
    print("记住：")
    print("  - RSA 用于密钥交换和数字签名")
    print("  - AES 用于批量数据加密")
    print("  - 永远不要自己实现加密算法")
    print("  - 使用经过验证的标准库")
    print("=" * 70)

final_recommendations()
```

---

**总结**：

RSA 是非对称加密的基石，在现代密码学中扮演着关键角色：

- **密钥交换**：TLS/SSL 握手
- **数字签名**：证书、代码签名、JWT
- **身份认证**：SSH、数字证书

虽然 RSA 比对称加密慢得多，但它解决了密钥分发的根本问题。实际应用中，RSA 与 AES 配合使用（混合加密）发挥各自优势。

随着量子计算的发展，RSA 面临挑战，但在量子后加密标准成熟之前，使用足够长的密钥（3072/4096位）仍然是安全的。

**关键要点**：
1. 使用标准库，不要自己实现
2. 密钥长度至少 2048 位
3. 使用现代填充方案（OAEP/PSS）
4. 大数据使用混合加密
5. 妥善管理私钥

# ECC (椭圆曲线加密) 完整指南

## 一、ECC 核心概念

在使用 ECC 之前，必须理解以下几个基本组件：

### 1. ECC (Elliptic Curve Cryptography)

- 它是一种**非对称加密 (Asymmetric Encryption)** 算法
- 基于**椭圆曲线离散对数问题 (ECDLP)** 的数学难题
- 由 Neal Koblitz 和 Victor Miller 在 1985 年独立提出
- 是 RSA 的现代替代方案，提供**相同安全性但密钥更短**

**核心数学概念**：

椭圆曲线的定义（Weierstrass 方程）：
```
y² = x³ + ax + b (mod p)
```

**点加法运算**：
- 曲线上的两个点可以"相加"得到第三个点
- 这种运算满足交换律、结合律
- 存在单位元（无穷远点 O）

**标量乘法**：
```
Q = d × G
其中：
- G 是基点（Generator Point）
- d 是私钥（标量）
- Q 是公钥（曲线上的点）
```

⚠️ **关键安全性**：
- 已知 Q 和 G，计算 d 是困难的（离散对数问题）
- 这就是 ECC 安全性的基础

### 2. 公钥和私钥

**私钥 (Private Key)**：
- 一个**随机大整数** d
- 范围：1 < d < n（n 是曲线的阶）
- 必须严格保密
- 通常 256 位（32 字节）

**公钥 (Public Key)**：
- 曲线上的一个**点** Q = (x, y)
- 通过私钥计算：Q = d × G
- 可以公开分发
- 非压缩格式：64 字节（x 和 y 各 32 字节）
- 压缩格式：33 字节（x 坐标 + 1 字节前缀）

**示例**：
```python
私钥 d = 0x1234...ABCD  # 256 位随机数
公钥 Q = d × G          # 曲线上的点
      = (x, y)
```

### 3. 椭圆曲线选择

主流曲线类型：

#### NIST 标准曲线（SECP 系列）

| 曲线名称 | 密钥长度 | 安全等级 | RSA 等效 | 推荐度 |
|---------|---------|---------|----------|--------|
| **SECP256R1** (P-256) | 256 位 | 128 位 | RSA 3072 | ⭐⭐⭐⭐ |
| **SECP384R1** (P-384) | 384 位 | 192 位 | RSA 7680 | ⭐⭐⭐⭐⭐ |
| **SECP521R1** (P-521) | 521 位 | 256 位 | RSA 15360 | ⭐⭐⭐⭐⭐ |

**特点**：
- ✅ 广泛支持（TLS, X.509 证书）
- ✅ 硬件加速支持
- ⚠️ NIST 曲线存在争议（可能有后门，但未被证实）

#### Edwards 曲线（推荐）

| 曲线名称 | 密钥长度 | 安全等级 | 特点 | 推荐度 |
|---------|---------|---------|------|--------|
| **Ed25519** | 256 位 | ~128 位 | 高性能、抗时序攻击 | ⭐⭐⭐⭐⭐ |
| **Ed448** | 448 位 | ~224 位 | 更高安全性 | ⭐⭐⭐⭐ |

**特点**：
- ✅ 设计更安全（无魔法常数）
- ✅ 性能优异
- ✅ 抗侧信道攻击
- ✅ 签名确定性（相同消息+私钥=相同签名）
- 用于：SSH Ed25519 密钥、Signal Protocol、Tor

#### 其他重要曲线

| 曲线名称 | 用途 | 特点 |
|---------|------|------|
| **SECP256K1** | Bitcoin/以太坊 | 高效验证，Koblitz 曲线 |
| **Curve25519** | 密钥交换（X25519） | 蒙哥马利曲线，性能优异 |
| **Curve448** | 密钥交换（X448） | 更高安全性 |

### 4. ECC 的三大应用

#### 应用一：密钥交换 (ECDH)
```
Alice                          Bob
私钥: dA                       私钥: dB
公钥: QA = dA × G              公钥: QB = dB × G

共享密钥计算:
Alice: S = dA × QB            Bob: S = dB × QA
     = dA × (dB × G)               = dB × (dA × G)
     = (dA × dB) × G               = (dA × dB) × G

结果: Alice 和 Bob 得到相同的共享密钥 S
```

**用途**：TLS 握手、Signal 双棘轮、VPN

#### 应用二：数字签名 (ECDSA/EdDSA)
```
签名生成:
1. 计算消息哈希: h = Hash(message)
2. 生成随机数 k
3. 计算签名: (r, s) = Sign(h, 私钥, k)

签名验证:
1. 计算消息哈希: h = Hash(message)
2. 验证: Verify(h, 公钥, (r, s))
```

**用途**：JWT、代码签名、区块链交易

#### 应用三：加密/解密 (ECIES)
```
加密流程:
1. 生成临时密钥对 (d_temp, Q_temp)
2. 计算共享密钥: S = d_temp × Q_recipient
3. 派生对称密钥: K = KDF(S)
4. 使用 K 加密数据: C = AES(plaintext, K)
5. 发送: (Q_temp, C, MAC)

解密流程:
1. 使用接收方私钥计算: S = d_recipient × Q_temp
2. 派生对称密钥: K = KDF(S)
3. 解密: plaintext = AES.decrypt(C, K)
```

**用途**：PGP、端到端加密

### 5. ECC vs RSA

| 特性 | ECC | RSA |
|:-----|:----|:----|
| **密钥长度** | 256-521 位 | 2048-4096 位 |
| **安全性** | 256 位 ≈ AES-128 | 3072 位 ≈ AES-128 |
| **公钥大小** | ~32-66 字节 | ~256-512 字节 |
| **签名大小** | ~64 字节 | ~256-512 字节 |
| **密钥生成速度** | 快 | 慢 |
| **签名速度** | 快 | 很慢 |
| **验证速度** | 中等 | 快 |
| **带宽占用** | 低 | 高 |
| **量子安全** | ❌ | ❌ |
| **适用场景** | 移动设备、IoT、区块链 | 传统 PKI |

**关键优势**：
- ✅ ECC 256 位 = RSA 3072 位的安全性
- ✅ 更小的密钥和签名
- ✅ 更快的运算速度
- ✅ 更低的功耗

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
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.backends import default_backend
from base64 import b64encode, b64decode
import json
import hashlib

backend = default_backend()
```

---

## 三、密钥生成

### 1. 生成密钥对（不同曲线）

```python
def generate_ecc_keypair(curve_name: str = "SECP256R1"):
    """
    生成 ECC 密钥对
    
    参数:
        curve_name: 曲线名称
            - "SECP256R1" (P-256): 推荐，广泛支持
            - "SECP384R1" (P-384): 高安全性
            - "SECP521R1" (P-521): 最高安全性
            - "SECP256K1": Bitcoin/以太坊
    
    返回:
        (private_key, public_key)
    """
    curve_map = {
        "SECP256R1": ec.SECP256R1(),  # NIST P-256
        "SECP384R1": ec.SECP384R1(),  # NIST P-384
        "SECP521R1": ec.SECP521R1(),  # NIST P-521
        "SECP256K1": ec.SECP256K1(),  # Bitcoin
    }
    
    if curve_name not in curve_map:
        raise ValueError(f"不支持的曲线: {curve_name}")
    
    print(f"[密钥生成] 生成 {curve_name} 密钥对...")
    
    # 生成私钥
    private_key = ec.generate_private_key(
        curve_map[curve_name],
        backend=backend
    )
    
    # 从私钥提取公钥
    public_key = private_key.public_key()
    
    print(f"[密钥生成] ✅ 密钥对生成成功")
    print(f"[密钥生成] 曲线: {curve_name}")
    print(f"[密钥生成] 密钥大小: {private_key.curve.key_size} 位")
    
    return private_key, public_key

# 生成不同曲线的密钥对
print("=" * 60)
print("生成不同曲线的密钥对")
print("=" * 60 + "\n")

private_p256, public_p256 = generate_ecc_keypair("SECP256R1")
private_p384, public_p384 = generate_ecc_keypair("SECP384R1")
private_p521, public_p521 = generate_ecc_keypair("SECP521R1")
```

### 2. Ed25519 密钥生成（推荐）

```python
from cryptography.hazmat.primitives.asymmetric import ed25519

def generate_ed25519_keypair():
    """
    生成 Ed25519 密钥对
    
    Ed25519 特点:
    - 高性能（比 ECDSA 快）
    - 抗侧信道攻击
    - 签名确定性
    - 用于 SSH、Signal、Tor
    """
    print(f"\n[Ed25519] 生成密钥对...")
    
    # 生成私钥
    private_key = ed25519.Ed25519PrivateKey.generate()
    
    # 提取公钥
    public_key = private_key.public_key()
    
    print(f"[Ed25519] ✅ 密钥对生成成功")
    print(f"[Ed25519] 私钥长度: 32 字节")
    print(f"[Ed25519] 公钥长度: 32 字节")
    
    return private_key, public_key

# 生成 Ed25519 密钥对
ed_private, ed_public = generate_ed25519_keypair()
```

### 3. 查看密钥详细信息

```python
def inspect_ecc_key(private_key, public_key):
    """检查 ECC 密钥详细信息"""
    
    print("\n" + "=" * 60)
    print("ECC 密钥详细信息")
    print("=" * 60)
    
    # 曲线信息
    curve_name = private_key.curve.name
    key_size = private_key.curve.key_size
    
    print(f"\n【曲线信息】")
    print(f"  名称: {curve_name}")
    print(f"  密钥长度: {key_size} 位")
    
    # 私钥信息
    private_numbers = private_key.private_numbers()
    private_value = private_numbers.private_value
    
    print(f"\n【私钥】")
    print(f"  私钥 (d): {hex(private_value)[:50]}...")
    print(f"  私钥长度: {private_value.bit_length()} 位")
    
    # 公钥信息
    public_numbers = public_key.public_numbers()
    
    print(f"\n【公钥】")
    print(f"  x 坐标: {hex(public_numbers.x)[:50]}...")
    print(f"  y 坐标: {hex(public_numbers.y)[:50]}...")
    print(f"  x 长度: {public_numbers.x.bit_length()} 位")
    print(f"  y 长度: {public_numbers.y.bit_length()} 位")
    
    # 序列化大小
    public_der = public_key.public_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    
    public_uncompressed = public_key.public_bytes(
        encoding=serialization.Encoding.X962,
        format=serialization.PublicFormat.UncompressedPoint
    )
    
    public_compressed = public_key.public_bytes(
        encoding=serialization.Encoding.X962,
        format=serialization.PublicFormat.CompressedPoint
    )
    
    print(f"\n【序列化大小】")
    print(f"  DER 格式: {len(public_der)} 字节")
    print(f"  非压缩格式 (0x04 || x || y): {len(public_uncompressed)} 字节")
    print(f"  压缩格式 (0x02/0x03 || x): {len(public_compressed)} 字节")
    
    # 安全级别
    security_bits = key_size // 2  # ECC 安全位数约为密钥长度的一半
    print(f"\n【安全性】")
    print(f"  安全位数: ~{security_bits} 位")
    print(f"  相当于 RSA: ~{security_bits * 2 * 6} 位")

inspect_ecc_key(private_p256, public_p256)
```

### 4. 密钥序列化（保存和加载）

```python
def save_ecc_private_key(private_key, filename: str, password: bytes = None):
    """
    保存 ECC 私钥为 PEM 格式
    
    参数:
        private_key: 私钥对象
        filename: 文件名
        password: 加密密码（强烈建议使用）
    """
    if password:
        encryption = serialization.BestAvailableEncryption(password)
        print(f"[保存私钥] 使用密码加密")
    else:
        encryption = serialization.NoEncryption()
        print(f"[保存私钥] ⚠️  警告: 私钥未加密")
    
    pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=encryption
    )
    
    with open(filename, 'wb') as f:
        f.write(pem)
    
    print(f"[保存私钥] ✅ 私钥已保存到: {filename}")

def save_ecc_public_key(public_key, filename: str):
    """保存 ECC 公钥为 PEM 格式"""
    pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    
    with open(filename, 'wb') as f:
        f.write(pem)
    
    print(f"[保存公钥] ✅ 公钥已保存到: {filename}")

def load_ecc_private_key(filename: str, password: bytes = None):
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

def load_ecc_public_key(filename: str):
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

# 保存密钥
password = b"MyStrongPassword123!"
save_ecc_private_key(private_p256, "ecc_private.pem", password)
save_ecc_public_key(public_p256, "ecc_public.pem")

# 查看 PEM 文件
print("\n私钥 PEM 格式:")
with open("ecc_private.pem", 'r') as f:
    print(f.read())

print("\n公钥 PEM 格式:")
with open("ecc_public.pem", 'r') as f:
    print(f.read())

# 加载密钥
loaded_private = load_ecc_private_key("ecc_private.pem", password)
loaded_public = load_ecc_public_key("ecc_public.pem")

print("\n✅ 密钥保存和加载验证成功")
```

### 5. 不同格式的序列化

```python
def demonstrate_serialization_formats(public_key):
    """演示不同的公钥序列化格式"""
    
    print("\n" + "=" * 60)
    print("公钥序列化格式对比")
    print("=" * 60 + "\n")
    
    formats = {
        "PEM (SubjectPublicKeyInfo)": (
            serialization.Encoding.PEM,
            serialization.PublicFormat.SubjectPublicKeyInfo
        ),
        "DER (SubjectPublicKeyInfo)": (
            serialization.Encoding.DER,
            serialization.PublicFormat.SubjectPublicKeyInfo
        ),
        "非压缩点格式 (X9.62)": (
            serialization.Encoding.X962,
            serialization.PublicFormat.UncompressedPoint
        ),
        "压缩点格式 (X9.62)": (
            serialization.Encoding.X962,
            serialization.PublicFormat.CompressedPoint
        ),
    }
    
    for name, (encoding, fmt) in formats.items():
        try:
            data = public_key.public_bytes(encoding=encoding, format=fmt)
            
            if encoding == serialization.Encoding.PEM:
                print(f"{name}:")
                print(data.decode()[:200] + "...")
            else:
                print(f"{name}:")
                print(f"  大小: {len(data)} 字节")
                print(f"  数据: {data.hex()[:80]}...")
            print()
        except Exception as e:
            print(f"{name}: 不支持 ({e})\n")

demonstrate_serialization_formats(public_p256)
```

---

## 四、数字签名 (ECDSA)

### 1. 基本签名和验证

```python
def ecdsa_sign(private_key, message: bytes) -> bytes:
    """
    使用 ECDSA 签名消息
    
    参数:
        private_key: ECC 私钥
        message: 要签名的消息
    
    返回:
        签名（DER 编码）
    """
    print(f"[ECDSA 签名] 消息长度: {len(message)} 字节")
    
    # 使用 SHA-256 哈希
    signature = private_key.sign(
        message,
        ec.ECDSA(hashes.SHA256())
    )
    
    print(f"[ECDSA 签名] 签名长度: {len(signature)} 字节")
    print(f"[ECDSA 签名] ✅ 签名生成成功")
    
    return signature

def ecdsa_verify(public_key, message: bytes, signature: bytes) -> bool:
    """
    验证 ECDSA 签名
    
    参数:
        public_key: ECC 公钥
        message: 原始消息
        signature: 签名
    
    返回:
        True: 验证成功, False: 验证失败
    """
    print(f"[ECDSA 验证] 消息长度: {len(message)} 字节")
    print(f"[ECDSA 验证] 签名长度: {len(signature)} 字节")
    
    try:
        public_key.verify(
            signature,
            message,
            ec.ECDSA(hashes.SHA256())
        )
        print(f"[ECDSA 验证] ✅ 签名验证成功")
        return True
    except Exception as e:
        print(f"[ECDSA 验证] ❌ 签名验证失败: {e}")
        return False

# 使用示例
print("\n" + "=" * 60)
print("ECDSA 数字签名示例")
print("=" * 60 + "\n")

message = b"This is an important message that needs to be signed."
print(f"原始消息: {message}\n")

# 签名
signature = ecdsa_sign(private_p256, message)
print(f"签名 (hex): {signature.hex()[:80]}...\n")

# 验证（正确的消息）
is_valid = ecdsa_verify(public_p256, message, signature)
print(f"验证结果: {is_valid}\n")

# 验证（篡改的消息）
print("=" * 60)
print("篡改检测演示")
print("=" * 60 + "\n")

tampered_message = b"This is a MODIFIED message that needs to be signed."
is_valid_tampered = ecdsa_verify(public_p256, tampered_message, signature)
print(f"篡改消息验证结果: {is_valid_tampered}\n")
```

### 2. 不同哈希算法的签名

```python
def ecdsa_sign_with_hash(private_key, message: bytes, hash_algorithm) -> bytes:
    """使用指定哈希算法签名"""
    signature = private_key.sign(
        message,
        ec.ECDSA(hash_algorithm)
    )
    return signature

def ecdsa_verify_with_hash(public_key, message: bytes, signature: bytes, hash_algorithm) -> bool:
    """验证使用指定哈希算法的签名"""
    try:
        public_key.verify(
            signature,
            message,
            ec.ECDSA(hash_algorithm)
        )
        return True
    except:
        return False

# 测试不同哈希算法
print("\n" + "=" * 60)
print("不同哈希算法的 ECDSA 签名")
print("=" * 60 + "\n")

test_message = b"Test message for different hash algorithms"

hash_algorithms = {
    "SHA-256": hashes.SHA256(),
    "SHA-384": hashes.SHA384(),
    "SHA-512": hashes.SHA512(),
}

for name, algo in hash_algorithms.items():
    sig = ecdsa_sign_with_hash(private_p256, test_message, algo)
    is_valid = ecdsa_verify_with_hash(public_p256, test_message, sig, algo)
    print(f"{name}: 签名长度={len(sig)} 字节, 验证={is_valid}")
```

### 3. Ed25519 签名（推荐）

```python
def ed25519_sign(private_key, message: bytes) -> bytes:
    """
    使用 Ed25519 签名
    
    Ed25519 特点:
    - 确定性签名（相同消息+私钥=相同签名）
    - 更快的签名和验证速度
    - 固定的签名大小（64 字节）
    - 抗侧信道攻击
    """
    print(f"[Ed25519 签名] 消息长度: {len(message)} 字节")
    
    signature = private_key.sign(message)
    
    print(f"[Ed25519 签名] 签名长度: {len(signature)} 字节 (固定)")
    print(f"[Ed25519 签名] ✅ 签名生成成功")
    
    return signature

def ed25519_verify(public_key, message: bytes, signature: bytes) -> bool:
    """验证 Ed25519 签名"""
    print(f"[Ed25519 验证] 消息长度: {len(message)} 字节")
    print(f"[Ed25519 验证] 签名长度: {len(signature)} 字节")
    
    try:
        public_key.verify(signature, message)
        print(f"[Ed25519 验证] ✅ 签名验证成功")
        return True
    except Exception as e:
        print(f"[Ed25519 验证] ❌ 签名验证失败: {e}")
        return False

# 使用示例
print("\n" + "=" * 60)
print("Ed25519 签名示例")
print("=" * 60 + "\n")

ed_message = b"Ed25519 is faster and more secure!"
print(f"原始消息: {ed_message}\n")

# 签名
ed_signature = ed25519_sign(ed_private, ed_message)
print(f"签名 (hex): {ed_signature.hex()}\n")

# 验证
ed_valid = ed25519_verify(ed_public, ed_message, ed_signature)

# 测试确定性
print("\n测试 Ed25519 确定性签名:")
ed_signature2 = ed25519_sign(ed_private, ed_message)
print(f"两次签名是否相同: {ed_signature == ed_signature2}")
```

### 4. 文件签名

```python
def sign_file_ecdsa(private_key, filename: str) -> bytes:
    """
    使用 ECDSA 签名文件
    
    流程:
    1. 计算文件 SHA-256 哈希
    2. 签名哈希值
    """
    print(f"\n[文件签名] 文件: {filename}")
    
    # 计算文件哈希
    hasher = hashlib.sha256()
    
    with open(filename, 'rb') as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    
    file_hash = hasher.digest()
    print(f"[文件签名] 文件哈希: {file_hash.hex()}")
    
    # 签名
    signature = private_key.sign(
        file_hash,
        ec.ECDSA(hashes.SHA256())
    )
    
    print(f"[文件签名] ✅ 签名生成成功")
    
    return signature

def verify_file_signature_ecdsa(public_key, filename: str, signature: bytes) -> bool:
    """验证文件签名"""
    print(f"\n[文件验证] 文件: {filename}")
    
    # 计算文件哈希
    hasher = hashlib.sha256()
    
    with open(filename, 'rb') as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    
    file_hash = hasher.digest()
    print(f"[文件验证] 文件哈希: {file_hash.hex()}")
    
    # 验证签名
    try:
        public_key.verify(
            signature,
            file_hash,
            ec.ECDSA(hashes.SHA256())
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
    f.write("This is an important document.\n" * 100)

# 签名文件
file_sig = sign_file_ecdsa(private_p256, test_file)

# 保存签名
with open(test_file + ".sig", 'wb') as f:
    f.write(file_sig)

# 验证文件
is_valid = verify_file_signature_ecdsa(public_p256, test_file, file_sig)

# 修改文件并验证
with open(test_file, 'a') as f:
    f.write("TAMPERED\n")

print("\n" + "=" * 60)
print("篡改后的文件验证")
print("=" * 60)

is_valid_after = verify_file_signature_ecdsa(public_p256, test_file, file_sig)

# 清理
import os
os.remove(test_file)
os.remove(test_file + ".sig")
```

---

## 五、密钥交换 (ECDH)

### 1. 基本 ECDH 密钥交换

```python
def ecdh_key_exchange_demo():
    """
    演示 ECDH 密钥交换
    
    场景: Alice 和 Bob 需要建立共享密钥
    """
    print("\n" + "=" * 60)
    print("ECDH 密钥交换演示")
    print("=" * 60 + "\n")
    
    # Alice 生成密钥对
    print("【Alice】")
    alice_private = ec.generate_private_key(ec.SECP256R1(), backend)
    alice_public = alice_private.public_key()
    print(f"  生成密钥对")
    print(f"  公钥 (发送给 Bob): {alice_public.public_bytes(serialization.Encoding.X962, serialization.PublicFormat.UncompressedPoint).hex()[:60]}...")
    
    # Bob 生成密钥对
    print("\n【Bob】")
    bob_private = ec.generate_private_key(ec.SECP256R1(), backend)
    bob_public = bob_private.public_key()
    print(f"  生成密钥对")
    print(f"  公钥 (发送给 Alice): {bob_public.public_bytes(serialization.Encoding.X962, serialization.PublicFormat.UncompressedPoint).hex()[:60]}...")
    
    # Alice 计算共享密钥
    print("\n【Alice 计算共享密钥】")
    alice_shared_key = alice_private.exchange(ec.ECDH(), bob_public)
    print(f"  共享密钥: {alice_shared_key.hex()}")
    
    # Bob 计算共享密钥
    print("\n【Bob 计算共享密钥】")
    bob_shared_key = bob_private.exchange(ec.ECDH(), alice_public)
    print(f"  共享密钥: {bob_shared_key.hex()}")
    
    # 验证共享密钥相同
    print("\n【验证】")
    if alice_shared_key == bob_shared_key:
        print(f"  ✅ Alice 和 Bob 得到了相同的共享密钥！")
        print(f"  共享密钥长度: {len(alice_shared_key)} 字节")
    else:
        print(f"  ❌ 共享密钥不匹配！")
    
    return alice_shared_key

shared_key = ecdh_key_exchange_demo()
```

### 2. 从共享密钥派生对称密钥

```python
def derive_keys_from_shared_secret(shared_secret: bytes, salt: bytes = None) -> dict:
    """
    从 ECDH 共享密钥派生对称密钥
    
    使用 HKDF (HMAC-based Key Derivation Function)
    
    返回:
        {
            'encryption_key': AES 加密密钥 (32字节),
            'mac_key': HMAC 密钥 (32字节),
            'salt': 盐值
        }
    """
    if salt is None:
        salt = os.urandom(16)
    
    print(f"\n[密钥派生] 从共享密钥派生对称密钥...")
    print(f"[密钥派生] 共享密钥长度: {len(shared_secret)} 字节")
    print(f"[密钥派生] 盐值: {salt.hex()}")
    
    # 派生加密密钥
    hkdf_enc = HKDF(
        algorithm=hashes.SHA256(),
        length=32,  # AES-256 密钥
        salt=salt,
        info=b'encryption',
        backend=backend
    )
    encryption_key = hkdf_enc.derive(shared_secret)
    
    # 派生 MAC 密钥
    hkdf_mac = HKDF(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        info=b'authentication',
        backend=backend
    )
    mac_key = hkdf_mac.derive(shared_secret)
    
    print(f"[密钥派生] ✅ 派生完成")
    print(f"[密钥派生] 加密密钥: {encryption_key.hex()[:40]}...")
    print(f"[密钥派生] MAC 密钥: {mac_key.hex()[:40]}...")
    
    return {
        'encryption_key': encryption_key,
        'mac_key': mac_key,
        'salt': salt
    }

# 使用示例
derived_keys = derive_keys_from_shared_secret(shared_key)
```

### 3. X25519 密钥交换（推荐）

```python
from cryptography.hazmat.primitives.asymmetric import x25519

def x25519_key_exchange_demo():
    """
    X25519 密钥交换演示
    
    X25519 特点:
    - 基于 Curve25519
    - 性能优异
    - 抗侧信道攻击
    - 用于 Signal、WireGuard、TLS 1.3
    """
    print("\n" + "=" * 60)
    print("X25519 密钥交换演示")
    print("=" * 60 + "\n")
    
    # Alice 生成密钥对
    print("【Alice】")
    alice_private = x25519.X25519PrivateKey.generate()
    alice_public = alice_private.public_key()
    alice_public_bytes = alice_public.public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw
    )
    print(f"  生成 X25519 密钥对")
    print(f"  公钥 (32字节): {alice_public_bytes.hex()}")
    
    # Bob 生成密钥对
    print("\n【Bob】")
    bob_private = x25519.X25519PrivateKey.generate()
    bob_public = bob_private.public_key()
    bob_public_bytes = bob_public.public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw
    )
    print(f"  生成 X25519 密钥对")
    print(f"  公钥 (32字节): {bob_public_bytes.hex()}")
    
    # Alice 计算共享密钥
    print("\n【Alice 计算共享密钥】")
    alice_shared = alice_private.exchange(bob_public)
    print(f"  共享密钥 (32字节): {alice_shared.hex()}")
    
    # Bob 计算共享密钥
    print("\n【Bob 计算共享密钥】")
    bob_shared = bob_private.exchange(alice_public)
    print(f"  共享密钥 (32字节): {bob_shared.hex()}")
    
    # 验证
    print("\n【验证】")
    if alice_shared == bob_shared:
        print(f"  ✅ 共享密钥匹配！")
        print(f"  X25519 性能优于 ECDH (SECP256R1)")
    
    return alice_shared

x25519_shared = x25519_key_exchange_demo()
```

---

## 六、加密和解密 (ECIES)

### 1. ECIES 实现

```python
class ECIES:
    """
    ECIES (Elliptic Curve Integrated Encryption Scheme)
    
    加密流程:
    1. 生成临时密钥对 (ephemeral key)
    2. 使用 ECDH 计算共享密钥
    3. 使用 HKDF 派生对称密钥
    4. 使用 AES-GCM 加密数据
    5. 返回: 临时公钥 + 密文 + 认证标签
    
    解密流程:
    6. 使用接收方私钥和临时公钥计算共享密钥
    7. 派生对称密钥
    8. 解密并验证数据
    """
    
    def __init__(self, curve=ec.SECP256R1()):
        self.curve = curve
    
    def encrypt(self, recipient_public_key, plaintext: bytes) -> dict:
        """
        使用 ECIES 加密
        
        参数:
            recipient_public_key: 接收方的公钥
            plaintext: 明文
        
        返回:
            {
                'ephemeral_public_key': 临时公钥,
                'nonce': AES-GCM nonce,
                'ciphertext': 密文,
                'tag': 认证标签
            }
        """
        print(f"\n[ECIES 加密] 明文长度: {len(plaintext)} 字节")
        
        # 1. 生成临时密钥对
        ephemeral_private = ec.generate_private_key(self.curve, backend)
        ephemeral_public = ephemeral_private.public_key()
        
        print(f"[ECIES 加密] 生成临时密钥对")
        
        # 2. ECDH 密钥交换
        shared_secret = ephemeral_private.exchange(ec.ECDH(), recipient_public_key)
        print(f"[ECIES 加密] ECDH 共享密钥: {shared_secret.hex()[:40]}...")
        
        # 3. 派生对称密钥
        hkdf = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=b'ecies-encryption',
            backend=backend
        )
        symmetric_key = hkdf.derive(shared_secret)
        print(f"[ECIES 加密] 派生 AES 密钥")
        
        # 4. AES-GCM 加密
        aesgcm = AESGCM(symmetric_key)
        nonce = os.urandom(12)
        ciphertext = aesgcm.encrypt(nonce, plaintext, None)
        
        print(f"[ECIES 加密] 密文长度: {len(ciphertext)} 字节")
        print(f"[ECIES 加密] ✅ 加密完成")
        
        # 5. 序列化临时公钥
        ephemeral_public_bytes = ephemeral_public.public_bytes(
            encoding=serialization.Encoding.X962,
            format=serialization.PublicFormat.UncompressedPoint
        )
        
        return {
            'ephemeral_public_key': ephemeral_public_bytes,
            'nonce': nonce,
            'ciphertext': ciphertext
        }
    
    def decrypt(self, recipient_private_key, encrypted_data: dict) -> bytes:
        """
        使用 ECIES 解密
        
        参数:
            recipient_private_key: 接收方的私钥
            encrypted_data: 加密数据字典
        
        返回:
            明文
        """
        print(f"\n[ECIES 解密] 开始解密...")
        
        # 1. 加载临时公钥
        ephemeral_public_bytes = encrypted_data['ephemeral_public_key']
        ephemeral_public = ec.EllipticCurvePublicKey.from_encoded_point(
            self.curve,
            ephemeral_public_bytes
        )
        
        print(f"[ECIES 解密] 加载临时公钥")
        
        # 2. ECDH 密钥交换
        shared_secret = recipient_private_key.exchange(ec.ECDH(), ephemeral_public)
        print(f"[ECIES 解密] ECDH 共享密钥: {shared_secret.hex()[:40]}...")
        
        # 3. 派生对称密钥
        hkdf = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=b'ecies-encryption',
            backend=backend
        )
        symmetric_key = hkdf.derive(shared_secret)
        print(f"[ECIES 解密] 派生 AES 密钥")
        
        # 4. AES-GCM 解密
        aesgcm = AESGCM(symmetric_key)
        plaintext = aesgcm.decrypt(
            encrypted_data['nonce'],
            encrypted_data['ciphertext'],
            None
        )
        
        print(f"[ECIES 解密] 明文长度: {len(plaintext)} 字节")
        print(f"[ECIES 解密] ✅ 解密完成")
        
        return plaintext

# 使用示例
print("\n" + "=" * 60)
print("ECIES 加密/解密示例")
print("=" * 60)

# 初始化 ECIES
ecies = ECIES(curve=ec.SECP256R1())

# 准备数据
plaintext = b"This is a secret message encrypted with ECIES!"
print(f"\n原始明文: {plaintext}")

# 加密
encrypted = ecies.encrypt(public_p256, plaintext)

print(f"\n加密结果:")
print(f"  临时公钥长度: {len(encrypted['ephemeral_public_key'])} 字节")
print(f"  Nonce: {encrypted['nonce'].hex()}")
print(f"  密文长度: {len(encrypted['ciphertext'])} 字节")

# 解密
decrypted = ecies.decrypt(private_p256, encrypted)

print(f"\n解密结果: {decrypted}")

# 验证
assert plaintext == decrypted
print(f"\n✅ ECIES 加密/解密验证成功")
```

### 2. ECIES 序列化

```python
def serialize_ecies_data(encrypted_data: dict) -> bytes:
    """
    序列化 ECIES 加密数据
    
    格式: 临时公钥长度(2字节) + 临时公钥 + Nonce(12字节) + 密文
    """
    ephemeral_key = encrypted_data['ephemeral_public_key']
    nonce = encrypted_data['nonce']
    ciphertext = encrypted_data['ciphertext']
    
    # 打包
    key_length = len(ephemeral_key).to_bytes(2, 'big')
    
    serialized = key_length + ephemeral_key + nonce + ciphertext
    
    print(f"\n[序列化] 总大小: {len(serialized)} 字节")
    print(f"  - 长度字段: 2 字节")
    print(f"  - 临时公钥: {len(ephemeral_key)} 字节")
    print(f"  - Nonce: {len(nonce)} 字节")
    print(f"  - 密文: {len(ciphertext)} 字节")
    
    return serialized

def deserialize_ecies_data(serialized: bytes) -> dict:
    """反序列化 ECIES 加密数据"""
    # 解析长度
    key_length = int.from_bytes(serialized[0:2], 'big')
    
    # 提取各部分
    offset = 2
    ephemeral_key = serialized[offset:offset+key_length]
    offset += key_length
    
    nonce = serialized[offset:offset+12]
    offset += 12
    
    ciphertext = serialized[offset:]
    
    return {
        'ephemeral_public_key': ephemeral_key,
        'nonce': nonce,
        'ciphertext': ciphertext
    }

# 使用示例
serialized = serialize_ecies_data(encrypted)
print(f"\n序列化数据 (hex): {serialized.hex()[:80]}...")

# Base64 编码
b64_encoded = b64encode(serialized).decode()
print(f"\nBase64 编码: {b64_encoded[:80]}...")

# 反序列化
deserialized = deserialize_ecies_data(serialized)
decrypted2 = ecies.decrypt(private_p256, deserialized)

assert plaintext == decrypted2
print(f"\n✅ 序列化/反序列化验证成功")
```

---

## 七、完整工具类封装

```python
class ECCCipher:
    """
    ECC 加密工具类（生产就绪版本）
    
    特性:
    - 密钥生成和管理
    - ECDSA 数字签名
    - ECDH 密钥交换
    - ECIES 加密/解密
    - 支持多种曲线
    """
    
    def __init__(self, curve_name: str = "SECP256R1"):
        """
        初始化 ECC 加密器
        
        参数:
            curve_name: 曲线名称
                - "SECP256R1" (P-256): 推荐
                - "SECP384R1" (P-384): 高安全性
                - "SECP521R1" (P-521): 最高安全性
        """
        curve_map = {
            "SECP256R1": ec.SECP256R1(),
            "SECP384R1": ec.SECP384R1(),
            "SECP521R1": ec.SECP521R1(),
            "SECP256K1": ec.SECP256K1(),
        }
        
        if curve_name not in curve_map:
            raise ValueError(f"不支持的曲线: {curve_name}")
        
        self.curve = curve_map[curve_name]
        self.curve_name = curve_name
        self.private_key = None
        self.public_key = None
    
    def generate_keypair(self):
        """生成新的密钥对"""
        self.private_key = ec.generate_private_key(self.curve, backend)
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
    
    def sign(self, message: bytes, hash_algorithm=hashes.SHA256()) -> bytes:
        """
        ECDSA 签名
        
        参数:
            message: 要签名的消息
            hash_algorithm: 哈希算法
        
        返回:
            签名
        """
        if not self.private_key:
            raise ValueError("私钥不存在")
        
        return self.private_key.sign(
            message,
            ec.ECDSA(hash_algorithm)
        )
    
    def verify(self, message: bytes, signature: bytes, hash_algorithm=hashes.SHA256()) -> bool:
        """
        验证 ECDSA 签名
        
        参数:
            message: 原始消息
            signature: 签名
            hash_algorithm: 哈希算法
        
        返回:
            True: 验证成功, False: 验证失败
        """
        if not self.public_key:
            raise ValueError("公钥不存在")
        
        try:
            self.public_key.verify(
                signature,
                message,
                ec.ECDSA(hash_algorithm)
            )
            return True
        except:
            return False
    
    def exchange(self, peer_public_key) -> bytes:
        """
        ECDH 密钥交换
        
        参数:
            peer_public_key: 对方的公钥
        
        返回:
            共享密钥
        """
        if not self.private_key:
            raise ValueError("私钥不存在")
        
        return self.private_key.exchange(ec.ECDH(), peer_public_key)
    
    def encrypt(self, plaintext: bytes, recipient_public_key=None) -> str:
        """
        ECIES 加密
        
        参数:
            plaintext: 明文
            recipient_public_key: 接收方公钥（默认使用自己的公钥）
        
        返回:
            Base64 编码的加密数据
        """
        if recipient_public_key is None:
            recipient_public_key = self.public_key
        
        if not recipient_public_key:
            raise ValueError("公钥不存在")
        
        # 生成临时密钥对
        ephemeral_private = ec.generate_private_key(self.curve, backend)
        ephemeral_public = ephemeral_private.public_key()
        
        # ECDH
        shared_secret = ephemeral_private.exchange(ec.ECDH(), recipient_public_key)
        
        # 派生密钥
        hkdf = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=b'ecies-encryption',
            backend=backend
        )
        symmetric_key = hkdf.derive(shared_secret)
        
        # AES-GCM 加密
        aesgcm = AESGCM(symmetric_key)
        nonce = os.urandom(12)
        ciphertext = aesgcm.encrypt(nonce, plaintext, None)
        
        # 序列化
        ephemeral_public_bytes = ephemeral_public.public_bytes(
            encoding=serialization.Encoding.X962,
            format=serialization.PublicFormat.UncompressedPoint
        )
        
        key_length = len(ephemeral_public_bytes).to_bytes(2, 'big')
        serialized = key_length + ephemeral_public_bytes + nonce + ciphertext
        
        return b64encode(serialized).decode()
    
    def decrypt(self, encrypted_b64: str) -> bytes:
        """
        ECIES 解密
        
        参数:
            encrypted_b64: Base64 编码的加密数据
        
        返回:
            明文
        """
        if not self.private_key:
            raise ValueError("私钥不存在")
        
        # 反序列化
        serialized = b64decode(encrypted_b64)
        
        key_length = int.from_bytes(serialized[0:2], 'big')
        offset = 2
        
        ephemeral_public_bytes = serialized[offset:offset+key_length]
        offset += key_length
        
        nonce = serialized[offset:offset+12]
        offset += 12
        
        ciphertext = serialized[offset:]
        
        # 加载临时公钥
        ephemeral_public = ec.EllipticCurvePublicKey.from_encoded_point(
            self.curve,
            ephemeral_public_bytes
        )
        
        # ECDH
        shared_secret = self.private_key.exchange(ec.ECDH(), ephemeral_public)
        
        # 派生密钥
        hkdf = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=b'ecies-encryption',
            backend=backend
        )
        symmetric_key = hkdf.derive(shared_secret)
        
        # AES-GCM 解密
        aesgcm = AESGCM(symmetric_key)
        plaintext = aesgcm.decrypt(nonce, ciphertext, None)
        
        return plaintext

# ============ 使用示例 ============

print("\n" + "=" * 60)
print("完整工具类测试")
print("=" * 60 + "\n")

# 1. 生成密钥对
ecc = ECCCipher(curve_name="SECP256R1")
ecc.generate_keypair()
print("✅ 密钥对生成成功\n")

# 2. 数字签名
test_message = b"Important contract"
signature = ecc.sign(test_message)
print(f"签名长度: {len(signature)} 字节")

is_valid = ecc.verify(test_message, signature)
print(f"签名验证: {is_valid}\n")

# 3. ECIES 加密
plaintext = b"This is a confidential message!"
encrypted_b64 = ecc.encrypt(plaintext)
print(f"加密数据 (Base64): {encrypted_b64[:60]}...\n")

decrypted = ecc.decrypt(encrypted_b64)
print(f"解密结果: {decrypted}")

assert plaintext == decrypted
print(f"✅ 加密/解密验证成功\n")

# 4. 密钥交换
ecc2 = ECCCipher(curve_name="SECP256R1")
ecc2.generate_keypair()

shared1 = ecc.exchange(ecc2.public_key)
shared2 = ecc2.exchange(ecc.public_key)

print(f"密钥交换:")
print(f"  共享密钥1: {shared1.hex()[:40]}...")
print(f"  共享密钥2: {shared2.hex()[:40]}...")
print(f"  匹配: {shared1 == shared2}\n")

print("=" * 60)
print("✅ 所有测试通过")
print("=" * 60)
```

---

## 八、常见应用场景

### 1. TLS/SSL 证书

```python
from cryptography import x509
from cryptography.x509.oid import NameOID, ExtensionOID
import datetime

def generate_ecc_certificate(
    private_key,
    common_name: str = "example.com",
    days_valid: int = 365
):
    """
    生成 ECC 自签名证书
    
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
    ).add_extension(
        x509.KeyUsage(
            digital_signature=True,
            key_encipherment=False,
            content_commitment=False,
            data_encipherment=False,
            key_agreement=True,
            key_cert_sign=False,
            crl_sign=False,
            encipher_only=False,
            decipher_only=False,
        ),
        critical=True,
    ).sign(private_key, hashes.SHA256(), backend=backend)
    
    return cert

# 生成 ECC 证书
cert = generate_ecc_certificate(private_p256, "myapp.local")

# 导出证书
cert_pem = cert.public_bytes(serialization.Encoding.PEM)

print("\n" + "=" * 60)
print("ECC 证书示例")
print("=" * 60 + "\n")
print(cert_pem.decode()[:600])
print("...")

# 查看证书信息
print(f"\n证书信息:")
print(f"  主题: {cert.subject}")
print(f"  颁发者: {cert.issuer}")
print(f"  有效期: {cert.not_valid_before} 至 {cert.not_valid_after}")
print(f"  签名算法: {cert.signature_algorithm_oid._name}")

# 保存证书
with open("ecc_certificate.pem", "wb") as f:
    f.write(cert_pem)

print(f"\n✅ 证书已保存到 ecc_certificate.pem")
```

### 2. SSH Ed25519 密钥

```python
def generate_ssh_ed25519_keypair(comment: str = "user@host"):
    """
    生成 SSH Ed25519 密钥对
    
    Ed25519 是 SSH 推荐的密钥类型
    """
    # 生成密钥对
    private_key = ed25519.Ed25519PrivateKey.generate()
    public_key = private_key.public_key()
    
    # 导出私钥（OpenSSH 格式）
    private_openssh = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.OpenSSH,
        encryption_algorithm=serialization.NoEncryption()
    )
    
    # 导出公钥（OpenSSH 格式）
    public_openssh = public_key.public_bytes(
        encoding=serialization.Encoding.OpenSSH,
        format=serialization.PublicFormat.OpenSSH
    )
    
    # 添加注释
    public_openssh_with_comment = public_openssh + f" {comment}".encode()
    
    return private_openssh, public_openssh_with_comment

# 生成 SSH 密钥
ssh_private, ssh_public = generate_ssh_ed25519_keypair("myuser@mycomputer")

print("\n" + "=" * 60)
print("SSH Ed25519 密钥对生成")
print("=" * 60 + "\n")

# 保存密钥
with open("id_ed25519", "wb") as f:
    f.write(ssh_private)
os.chmod("id_ed25519", 0o600)

with open("id_ed25519.pub", "wb") as f:
    f.write(ssh_public)

print("SSH 公钥:")
print(ssh_public.decode())

print("\n私钥 (前5行):")
print('\n'.join(ssh_private.decode().split('\n')[:5]))

print(f"\n✅ SSH 密钥已生成")
print(f"   私钥: id_ed25519")
print(f"   公钥: id_ed25519.pub")

# 清理
os.remove("id_ed25519")
os.remove("id_ed25519.pub")
```

### 3. Bitcoin/以太坊地址生成

```python
def generate_bitcoin_address(compressed: bool = True):
    """
    生成 Bitcoin 地址（SECP256K1）
    
    注意: 这是简化示例，实际应用需要更多步骤
    """
    # 生成 SECP256K1 私钥
    private_key = ec.generate_private_key(ec.SECP256K1(), backend)
    public_key = private_key.public_key()
    
    # 获取公钥坐标
    public_numbers = public_key.public_numbers()
    x = public_numbers.x
    y = public_numbers.y
    
    # 序列化公钥
    if compressed:
        # 压缩格式: 0x02/0x03 + x
        prefix = b'\x02' if y % 2 == 0 else b'\x03'
        public_key_bytes = prefix + x.to_bytes(32, 'big')
    else:
        # 非压缩格式: 0x04 + x + y
        public_key_bytes = b'\x04' + x.to_bytes(32, 'big') + y.to_bytes(32, 'big')
    
    # SHA-256
    sha256_hash = hashlib.sha256(public_key_bytes).digest()
    
    # RIPEMD-160
    import hashlib
    ripemd160 = hashlib.new('ripemd160')
    ripemd160.update(sha256_hash)
    public_key_hash = ripemd160.digest()
    
    # 添加版本字节 (0x00 for mainnet)
    versioned_payload = b'\x00' + public_key_hash
    
    # 双 SHA-256 校验和
    checksum = hashlib.sha256(hashlib.sha256(versioned_payload).digest()).digest()[:4]
    
    # Base58 编码 (简化版本，实际需要完整的 Base58 实现)
    address_bytes = versioned_payload + checksum
    
    print(f"\n[Bitcoin 地址生成]")
    print(f"  私钥 (hex): {private_key.private_numbers().private_value.to_bytes(32, 'big').hex()}")
    print(f"  公钥 ({'压缩' if compressed else '非压缩'}): {public_key_bytes.hex()}")
    print(f"  公钥哈希: {public_key_hash.hex()}")
    print(f"  地址字节: {address_bytes.hex()}")
    
    return private_key, public_key_bytes, address_bytes

# 生成 Bitcoin 密钥对
btc_private, btc_public, btc_address = generate_bitcoin_address(compressed=True)
```

### 4. Signal Protocol (Double Ratchet)

```python
class SignalProtocolDemo:
    """
    Signal Protocol 简化演示
    
    使用 X25519 和 Ed25519
    """
    
    def __init__(self):
        # 身份密钥对 (长期)
        self.identity_private = ed25519.Ed25519PrivateKey.generate()
        self.identity_public = self.identity_private.public_key()
        
        # 预密钥对 (用于初始密钥交换)
        self.prekey_private = x25519.X25519PrivateKey.generate()
        self.prekey_public = self.prekey_private.public_key()
        
        print(f"[Signal] 生成身份密钥对 (Ed25519)")
        print(f"[Signal] 生成预密钥对 (X25519)")
    
    def initiate_session(self, peer_identity_public, peer_prekey_public):
        """发起会话"""
        # 生成临时密钥对
        ephemeral_private = x25519.X25519PrivateKey.generate()
        ephemeral_public = ephemeral_private.public_key()
        
        print(f"\n[Signal] 发起会话")
        print(f"[Signal] 生成临时密钥对")
        
        # 多重 ECDH
        dh1 = ephemeral_private.exchange(peer_prekey_public)
        
        # 组合共享密钥
        shared_secret = dh1  # 简化版本
        
        print(f"[Signal] ECDH 完成")
        print(f"[Signal] 共享密钥: {shared_secret.hex()[:40]}...")
        
        return ephemeral_public, shared_secret
    
    def respond_session(self, peer_ephemeral_public):
        """响应会话"""
        print(f"\n[Signal] 响应会话")
        
        # 使用预密钥计算共享密钥
        shared_secret = self.prekey_private.exchange(peer_ephemeral_public)
        
        print(f"[Signal] ECDH 完成")
        print(f"[Signal] 共享密钥: {shared_secret.hex()[:40]}...")
        
        return shared_secret

# 演示
print("\n" + "=" * 60)
print("Signal Protocol 演示")
print("=" * 60 + "\n")

alice = SignalProtocolDemo()
bob = SignalProtocolDemo()

# Alice 发起会话
alice_ephemeral, alice_shared = alice.initiate_session(
    bob.identity_public,
    bob.prekey_public
)

# Bob 响应会话
bob_shared = bob.respond_session(alice_ephemeral)

# 验证共享密钥
print(f"\n[验证]")
print(f"  共享密钥匹配: {alice_shared == bob_shared}")
```

---

## 九、安全最佳实践

### ✅ 务必遵守的规则

```python
def ecc_security_best_practices():
    """ECC 安全最佳实践"""
    
    print("\n" + "=" * 60)
    print("🔒 ECC 安全最佳实践")
    print("=" * 60 + "\n")
    
    practices = {
        "曲线选择": [
            "✅ 优先使用 Ed25519/Ed448 (Edwards 曲线)",
            "✅ 或使用 SECP256R1/384R1/521R1 (NIST 曲线)",
            "✅ 避免使用自定义曲线",
            "✅ 密钥长度至少 256 位"
        ],
        "密钥生成": [
            "✅ 使用密码学安全的随机数生成器",
            "✅ 私钥必须严格保密",
            "✅ 在可信环境中生成密钥",
            "✅ 验证生成的密钥有效性"
        ],
        "密钥管理": [
            "✅ 私钥加密存储（使用强密码）",
            "✅ 使用 HSM 或 KMS 管理密钥",
            "✅ 定期轮换密钥",
            "✅ 加密和签名使用不同密钥对",
            "✅ 安全删除废弃密钥"
        ],
        "签名操作": [
            "✅ 使用 SHA-256 或更强的哈希算法",
            "✅ ECDSA 使用随机 k 值（防止 nonce 重用）",
            "✅ 或使用确定性签名 (RFC 6979)",
            "✅ 优先使用 Ed25519 (确定性且安全)",
            "✅ 验证签名时检查有效期"
        ],
        "密钥交换": [
            "✅ 使用临时密钥对 (Perfect Forward Secrecy)",
            "✅ 验证对方公钥的真实性",
            "✅ 使用 HKDF 派生对称密钥",
            "✅ 配合消息认证码 (MAC)"
        ],
        "实现安全": [
            "✅ 使用常量时间比较",
            "✅ 防止侧信道攻击",
            "✅ 不要泄露私钥信息",
            "✅ 验证所有输入参数",
            "✅ 使用经过审计的库"
        ]
    }
    
    for category, items in practices.items():
        print(f"【{category}】")
        for item in items:
            print(f"  {item}")
        print()

ecc_security_best_practices()
```

### ❌ 绝对禁止的操作

```python
def ecc_security_antipatterns():
    """ECC 安全反模式"""
    
    print("\n" + "=" * 60)
    print("🚫 ECC 安全反模式（禁止！）")
    print("=" * 60 + "\n")
    
    antipatterns = {
        "曲线问题": [
            "❌ 使用弱曲线或非标准曲线",
            "❌ 密钥长度小于 256 位",
            "❌ 自己设计椭圆曲线参数",
            "❌ 使用已知存在漏洞的曲线"
        ],
        "密钥问题": [
            "❌ 硬编码私钥在代码中",
            "❌ 通过不安全渠道传输私钥",
            "❌ 使用可预测的随机数生成器",
            "❌ 重用密钥对于不同目的",
            "❌ 不加密存储私钥"
        ],
        "签名问题": [
            "❌ ECDSA 重用 nonce (k 值)",
            "❌ 使用弱哈希算法 (MD5, SHA1)",
            "❌ 不验证签名就信任数据",
            "❌ 忽略签名验证失败"
        ],
        "实现问题": [
            "❌ 自己实现椭圆曲线运算",
            "❌ 使用不安全的比较函数",
            "❌ 不处理点在无穷远的情况",
            "❌ 不验证点是否在曲线上"
        ],
        "协议问题": [
            "❌ 不验证对方公钥",
            "❌ 密钥交换不使用临时密钥",
            "❌ 不实现前向保密 (PFS)",
            "❌ 直接使用 ECDH 共享密钥加密"
        ]
    }
    
    for category, items in antipatterns.items():
        print(f"【{category}】")
        for item in items:
            print(f"  {item}")
        print()

ecc_security_antipatterns()
```

### ⚠️ ECDSA Nonce 重用攻击演示

```python
def demonstrate_nonce_reuse_attack():
    """
    演示 ECDSA nonce 重用的危险性
    
    ⚠️ 这是教育性演示，说明为什么不能重用 nonce
    """
    print("\n" + "=" * 60)
    print("⚠️  ECDSA Nonce 重用攻击演示")
    print("=" * 60 + "\n")
    
    print("背景:")
    print("  - ECDSA 签名使用随机 nonce (k)")
    print("  - 如果两次签名使用相同的 k，攻击者可以计算出私钥！")
    print("  - 真实案例: Sony PS3 (2010), Android Bitcoin 钱包 (2013)\n")
    
    print("签名算法:")
    print("  r = (k × G).x")
    print("  s = k⁻¹ × (hash + d × r) mod n")
    print("  其中 d 是私钥\n")
    
    print("攻击:")
    print("  如果 k 重用:")
    print("    s₁ = k⁻¹ × (h₁ + d × r)")
    print("    s₂ = k⁻¹ × (h₂ + d × r)")
    print("  攻击者可以计算:")
    print("    k = (h₁ - h₂) / (s₁ - s₂)")
    print("    d = (s₁ × k - h₁) / r\n")
    
    print("防护措施:")
    print("  ✅ 使用确定性签名 (RFC 6979)")
    print("  ✅ 使用 Ed25519 (内置确定性)")
    print("  ✅ 使用经过验证的密码学库")
    print("  ✅ 绝不自己实现 ECDSA\n")

demonstrate_nonce_reuse_attack()
```

---

## 十、性能对比

### 1. ECC vs RSA 性能测试

```python
import time

def performance_benchmark_ecc_vs_rsa():
    """ECC vs RSA 性能对比"""
    
    print("\n" + "=" * 60)
    print("⚡ ECC vs RSA 性能对比")
    print("=" * 60 + "\n")
    
    iterations = 100
    
    # ========== ECC (SECP256R1) ==========
    print("【ECC SECP256R1 (256位)】")
    
    # 密钥生成
    start = time.time()
    for _ in range(iterations):
        ecc_private = ec.generate_private_key(ec.SECP256R1(), backend)
    ecc_keygen_time = (time.time() - start) / iterations
    
    ecc_public = ecc_private.public_key()
    
    # 签名
    message = b"Test message" * 10
    start = time.time()
    for _ in range(iterations):
        signature = ecc_private.sign(message, ec.ECDSA(hashes.SHA256()))
    ecc_sign_time = (time.time() - start) / iterations
    
    # 验证
    start = time.time()
    for _ in range(iterations):
        try:
            ecc_public.verify(signature, message, ec.ECDSA(hashes.SHA256()))
        except:
            pass
    ecc_verify_time = (time.time() - start) / iterations
    
    # 密钥交换
    ecc_private2 = ec.generate_private_key(ec.SECP256R1(), backend)
    ecc_public2 = ecc_private2.public_key()
    
    start = time.time()
    for _ in range(iterations):
        shared = ecc_private.exchange(ec.ECDH(), ecc_public2)
    ecc_ecdh_time = (time.time() - start) / iterations
    
    print(f"  密钥生成: {ecc_keygen_time*1000:.3f} ms")
    print(f"  签名:     {ecc_sign_time*1000:.3f} ms")
    print(f"  验证:     {ecc_verify_time*1000:.3f} ms")
    print(f"  密钥交换: {ecc_ecdh_time*1000:.3f} ms")
    
    # 公钥大小
    ecc_pub_bytes = ecc_public.public_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    print(f"  公钥大小: {len(ecc_pub_bytes)} 字节")
    print(f"  签名大小: {len(signature)} 字节\n")
    
    # ========== RSA (2048位) ==========
    print("【RSA 2048位】")
    
    from cryptography.hazmat.primitives.asymmetric import rsa, padding
    
    # 密钥生成
    start = time.time()
    for _ in range(10):  # RSA 慢，减少迭代
        rsa_private = rsa.generate_private_key(65537, 2048, backend)
    rsa_keygen_time = (time.time() - start) / 10
    
    rsa_public = rsa_private.public_key()
    
    # 签名
    start = time.time()
    for _ in range(iterations):
        rsa_signature = rsa_private.sign(
            message,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
    rsa_sign_time = (time.time() - start) / iterations
    
    # 验证
    start = time.time()
    for _ in range(iterations):
        try:
            rsa_public.verify(
                rsa_signature,
                message,
                padding.PSS(
                    mgf=padding.MGF1(hashes.SHA256()),
                    salt_length=padding.PSS.MAX_LENGTH
                ),
                hashes.SHA256()
            )
        except:
            pass
    rsa_verify_time = (time.time() - start) / iterations
    
    print(f"  密钥生成: {rsa_keygen_time*1000:.3f} ms")
    print(f"  签名:     {rsa_sign_time*1000:.3f} ms")
    print(f"  验证:     {rsa_verify_time*1000:.3f} ms")
    
    # 公钥大小
    rsa_pub_bytes = rsa_public.public_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    print(f"  公钥大小: {len(rsa_pub_bytes)} 字节")
    print(f"  签名大小: {len(rsa_signature)} 字节\n")
    
    # ========== 对比总结 ==========
    print("=" * 60)
    print("对比总结 (ECC 256位 vs RSA 2048位)")
    print("=" * 60)
    print(f"  密钥生成: ECC 快 {rsa_keygen_time/ecc_keygen_time:.1f}倍")
    print(f"  签名速度: ECC 快 {rsa_sign_time/ecc_sign_time:.1f}倍")
    print(f"  验证速度: RSA 快 {ecc_verify_time/rsa_verify_time:.1f}倍")
    print(f"  公钥大小: ECC 小 {len(rsa_pub_bytes)/len(ecc_pub_bytes):.1f}倍")
    print(f"  签名大小: ECC 小 {len(rsa_signature)/len(signature):.1f}倍")
    print("\n  结论: ECC 在大多数方面优于 RSA")

performance_benchmark_ecc_vs_rsa()
```

### 2. 不同 ECC 曲线性能对比

```python
def compare_ecc_curves():
    """对比不同 ECC 曲线的性能"""
    
    print("\n" + "=" * 60)
    print("不同 ECC 曲线性能对比")
    print("=" * 60 + "\n")
    
    iterations = 100
    message = b"Test message"
    
    curves = {
        "SECP256R1": ec.SECP256R1(),
        "SECP384R1": ec.SECP384R1(),
        "SECP521R1": ec.SECP521R1(),
    }
    
    results = []
    
    for name, curve in curves.items():
        # 密钥生成
        start = time.time()
        for _ in range(iterations):
            private = ec.generate_private_key(curve, backend)
        keygen_time = (time.time() - start) / iterations
        
        public = private.public_key()
        
        # 签名
        start = time.time()
        for _ in range(iterations):
            sig = private.sign(message, ec.ECDSA(hashes.SHA256()))
        sign_time = (time.time() - start) / iterations
        
        # 验证
        start = time.time()
        for _ in range(iterations):
            try:
                public.verify(sig, message, ec.ECDSA(hashes.SHA256()))
            except:
                pass
        verify_time = (time.time() - start) / iterations
        
        # 大小
        pub_bytes = public.public_bytes(
            encoding=serialization.Encoding.DER,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        
        results.append({
            'name': name,
            'keygen': keygen_time,
            'sign': sign_time,
            'verify': verify_time,
            'pub_size': len(pub_bytes),
            'sig_size': len(sig)
        })
    
    # Ed25519
    start = time.time()
    for _ in range(iterations):
        ed_private = ed25519.Ed25519PrivateKey.generate()
    ed_keygen_time = (time.time() - start) / iterations
    
    ed_public = ed_private.public_key()
    
    start = time.time()
    for _ in range(iterations):
        ed_sig = ed_private.sign(message)
    ed_sign_time = (time.time() - start) / iterations
    
    start = time.time()
    for _ in range(iterations):
        try:
            ed_public.verify(ed_sig, message)
        except:
            pass
    ed_verify_time = (time.time() - start) / iterations
    
    ed_pub_bytes = ed_public.public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw
    )
    
    results.append({
        'name': 'Ed25519',
        'keygen': ed_keygen_time,
        'sign': ed_sign_time,
        'verify': ed_verify_time,
        'pub_size': len(ed_pub_bytes),
        'sig_size': len(ed_sig)
    })
    
    # 打印结果
    print(f"{'曲线':<12} {'密钥生成':<12} {'签名':<12} {'验证':<12} {'公钥':<8} {'签名':<8}")
    print("=" * 70)
    
    for r in results:
        print(
            f"{r['name']:<12} "
            f"{r['keygen']*1000:>8.3f}ms  "
            f"{r['sign']*1000:>8.3f}ms  "
            f"{r['verify']*1000:>8.3f}ms  "
            f"{r['pub_size']:>5}B  "
            f"{r['sig_size']:>5}B"
        )
    
    print("\n结论:")
    print("  - Ed25519 在所有操作上都是最快的")
    print("  - 安全级别越高，性能越慢")
    print("  - Ed25519 的签名是确定性的且固定大小（64字节）")

compare_ecc_curves()
```

---

## 十一、调试和故障排除

### 1. 常见错误诊断

```python
def diagnose_ecc_errors():
    """ECC 常见错误诊断"""
    
    print("\n" + "=" * 60)
    print("🔧 ECC 常见错误诊断")
    print("=" * 60 + "\n")
    
    errors = {
        "ValueError: Invalid point": {
            "原因": [
                "公钥数据损坏",
                "点不在曲线上",
                "使用了错误的曲线参数"
            ],
            "解决": [
                "验证公钥数据完整性",
                "确认使用正确的���线",
                "重新生成密钥对"
            ]
        },
        "cryptography.exceptions.InvalidSignature": {
            "原因": [
                "签名被篡改",
                "使用了错误的公钥",
                "消息被修改",
                "哈希算法不匹配"
            ],
            "解决": [
                "确认使用正确的公钥",
                "检查消息完整性",
                "验证签名和验证使用相同哈希算法"
            ]
        },
        "UnsupportedAlgorithm: X25519 is not supported": {
            "原因": [
                "cryptography 版本过旧",
                "后端不支持该曲线"
            ],
            "解决": [
                "升级 cryptography: pip install --upgrade cryptography",
                "使用 SECP256R1 等传统曲线"
            ]
        },
        "密钥加载失败": {
            "原因": [
                "PEM 格式错误",
                "密码错误",
                "曲线类型不匹配"
            ],
            "解决": [
                "检查 PEM 文件格式",
                "确认密码正确",
                "验证密钥是否为 ECC 密钥"
            ]
        },
        "ECDH 共享密钥不匹配": {
            "原因": [
                "使用了不同的曲线",
                "公钥错误",
                "实现错误"
            ],
            "解决": [
                "确保双方使用相同曲线",
                "验证公钥交换正确",
                "使用标准库实现"
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

diagnose_ecc_errors()
```

### 2. 调试工具

```python
class ECCDebugger:
    """ECC 调试工具"""
    
    @staticmethod
    def verify_key_pair(private_key, public_key):
        """验证密钥对是否匹配"""
        print(f"\n[调试] 密钥对匹配测试")
        
        try:
            # 从私钥提取公钥
            derived_public = private_key.public_key()
            
            # 比较公钥
            derived_bytes = derived_public.public_bytes(
                encoding=serialization.Encoding.DER,
                format=serialization.PublicFormat.SubjectPublicKeyInfo
            )
            
            provided_bytes = public_key.public_bytes(
                encoding=serialization.Encoding.DER,
                format=serialization.PublicFormat.SubjectPublicKeyInfo
            )
            
            if derived_bytes == provided_bytes:
                print(f"  ✅ 密钥对匹配")
                return True
            else:
                print(f"  ❌ 密钥对不匹配")
                return False
        except Exception as e:
            print(f"  ❌ 验证失败: {e}")
            return False
    
    @staticmethod
    def verify_point_on_curve(public_key):
        """验证点是否在曲线上"""
        print(f"\n[调试] 验证点是否在曲线上")
        
        try:
            # 获取坐标
            numbers = public_key.public_numbers()
            x = numbers.x
            y = numbers.y
            curve = numbers.curve
            
            print(f"  曲线: {curve.name}")
            print(f"  x: {hex(x)[:50]}...")
            print(f"  y: {hex(y)[:50]}...")
            
            # 简化验证（实际验证更复杂）
            print(f"  ✅ 点在曲线上（由库验证）")
            return True
        except Exception as e:
            print(f"  ❌ 点不在曲线上: {e}")
            return False
    
    @staticmethod
    def inspect_signature(signature: bytes, curve_name: str):
        """检查签名格式"""
        print(f"\n[调试] 签名分析")
        print(f"  签名长度: {len(signature)} 字节")
        print(f"  签名 (hex): {signature.hex()[:80]}...")
        
        # ECDSA 签名是 DER 编码的 (r, s)
        # 简化解析
        if signature[0] == 0x30:
            print(f"  格式: DER 编码 (ECDSA)")
        else:
            print(f"  格式: 原始格式或其他")
    
    @staticmethod
    def test_ecdh(private1, private2):
        """测试 ECDH 密钥交换"""
        print(f"\n[调试] ECDH 测试")
        
        public1 = private1.public_key()
        public2 = private2.public_key()
        
        shared1 = private1.exchange(ec.ECDH(), public2)
        shared2 = private2.exchange(ec.ECDH(), public1)
        
        print(f"  共享密钥1: {shared1.hex()}")
        print(f"  共享密钥2: {shared2.hex()}")
        
        if shared1 == shared2:
            print(f"  ✅ ECDH 成功，共享密钥匹配")
        else:
            print(f"  ❌ ECDH 失败，共享密钥不匹配")

# 使用调试工具
print("\n" + "=" * 60)
print("调试工具演示")
print("=" * 60)

debugger = ECCDebugger()

# 1. 验证密钥对
debugger.verify_key_pair(private_p256, public_p256)

# 2. 验证点在曲线上
debugger.verify_point_on_curve(public_p256)

# 3. 检查签名
test_sig = private_p256.sign(b"test", ec.ECDSA(hashes.SHA256()))
debugger.inspect_signature(test_sig, "SECP256R1")

# 4. 测试 ECDH
test_private1 = ec.generate_private_key(ec.SECP256R1(), backend)
test_private2 = ec.generate_private_key(ec.SECP256R1(), backend)
debugger.test_ecdh(test_private1, test_private2)
```

---

## 十二、总结对比表

### ECC 曲线对比

| 曲线 | 类型 | 密钥长度 | 安全级别 | 性能 | 推荐场景 |
|:-----|:-----|:---------|:---------|:-----|:---------|
| **SECP256R1** | Weierstrass | 256位 | ~128位 | 快 | TLS, 证书 |
| **SECP384R1** | Weierstrass | 384位 | ~192位 | 中等 | 高安全需求 |
| **SECP521R1** | Weierstrass | 521位 | ~256位 | 慢 | 最高安全 |
| **SECP256K1** | Weierstrass | 256位 | ~128位 | 快 | Bitcoin, 以太坊 |
| **Ed25519** | Edwards | 256位 | ~128位 | 很快 | SSH, Signal, Tor |
| **Ed448** | Edwards | 448位 | ~224位 | 快 | 高安全SSH |
| **X25519** | Montgomery | 256位 | ~128位 | 很快 | 密钥交换 |

### ECC vs RSA 详细对比

| 特性 | ECC 256位 | RSA 2048位 | RSA 3072位 |
|:-----|:----------|:-----------|:-----------|
| **安全级别** | ~128位 | ~112位 | ~128位 |
| **密钥生成** | 0.1-1 ms | 50-100 ms | 200-500 ms |
| **签名速度** | 0.3-0.5 ms | 5-10 ms | 15-30 ms |
| **验证速度** | 0.5-1 ms | 0.2-0.3 ms | 0.3-0.5 ms |
| **公钥大小** | 64-91 字节 | 294 字节 | 422 字节 |
| **签名大小** | 64-72 字节 | 256 字节 | 384 字节 |
| **带宽占用** | 低 | 高 | 很高 |
| **能耗** | 低 | 高 | 很高 |
| **量子安全** | ❌ | ❌ | ❌ |

### 应用场景推荐

| 场景 | 推荐算法 | 原因 |
|:-----|:---------|:-----|
| **TLS 1.3** | SECP256R1 或 X25519 | 标准支持，性能好 |
| **SSH** | Ed25519 | 快速，安全，密钥短 |
| **代码签名** | SECP384R1 或 Ed25519 | 高安全性 |
| **区块链** | SECP256K1 | 行业标准 |
| **IoT/嵌入式** | Ed25519 或 SECP256R1 | 低功耗，资源占用少 |
| **端到端加密** | X25519 + Ed25519 | Signal 方案 |
| **VPN** | X25519 | WireGuard 使用 |
| **证书** | SECP256R1 或 SECP384R1 | 广泛支持 |

---

## 十三、量子后时代准备

### 量子威胁和应对

```python
def post_quantum_readiness():
    """量子后加密准备"""
    
    print("\n" + "=" * 60)
    print("🔮 量子后加密（Post-Quantum Cryptography）")
    print("=" * 60 + "\n")
    
    print("【量子威胁】")
    print("  ⚠️  Shor 算法可在多项式时间内破解:")
    print("     - RSA")
    print("     - ECC (所有基于 ECDLP 的系统)")
    print("     - DSA, ECDSA, ECDH\n")
    
    print("  ⚠️  Grover 算法可将对称加密安全性减半:")
    print("     - AES-128 → 64 位有效安全性")
    print("     - AES-256 → 128 位有效安全性\n")
    
    print("【时间表】")
    print("  - 2023: NIST 发布首批 PQC 标准")
    print("  - 2024-2025: 标准化完成")
    print("  - 2030: 可能出现实用量子计算机")
    print("  - 2035: 强制迁移到 PQC\n")
    
    print("【NIST PQC 标准算法】")
    print("  密钥封装 (KEM):")
    print("    - CRYSTALS-Kyber (主选)")
    print("  数字签名:")
    print("    - CRYSTALS-Dilithium (主选)")
    print("    - FALCON")
    print("    - SPHINCS+ (备选，基于哈希)\n")
    
    print("【混合方案（推荐）】")
    print("  在过渡期使用混合加密:")
    print("    - ECC + PQC 密钥交换")
    print("    - ECDSA + PQC 签名")
    print("  优点:")
    print("    - 向后兼容")
    print("    - 双重保护")
    print("    - 逐步迁移\n")
    
    print("【行动建议】")
    print("  1. ✅ 立即: 使用 AES-256 (量子时代仍安全)")
    print("  2. ✅ 短期: 提高 ECC 密钥长度 (384/521 位)")
    print("  3. ✅ 中期: 实施混合加密方案")
    print("  4. ✅ 长期: 完全迁移到 PQC")
    print("  5. ✅ 持续: 关注 NIST PQC 标准化进展")
    print("  6. ⚠️  警惕: \"先存储后解密\" 攻击 (现在收集，未来解密)\n")
    
    print("【密钥长度建议（量子时代）】")
    print("  对称加密: AES-256")
    print("  哈希函数: SHA-384 或 SHA-512")
    print("  ECC (过渡期): SECP384R1 或 SECP521R1")
    print("  PQC: 遵循 NIST 标准\n")

post_quantum_readiness()
```

---

## 十四、最后的建议

```python
def final_ecc_recommendations():
    """ECC 使用最终建议"""
    
    print("\n" + "=" * 70)
    print("🎯 ECC 使用最终建议")
    print("=" * 70 + "\n")
    
    recommendations = [
        "1. ✅ 新项目优先使用 Ed25519 (签名) 和 X25519 (密钥交换)",
        "2. ✅ TLS/证书使用 SECP256R1 或 SECP384R1",
        "3. ✅ 密钥长度至少 256 位，推荐 384 位",
        "4. ✅ 使用 SHA-256 或更强的哈希算法",
        "5. ✅ ECDSA 必须使用确定性 nonce (RFC 6979) 或直接用 Ed25519",
        "6. ✅ 私钥加密存储，使用 HSM/KMS 管理",
        "7. ✅ ECDH 使用临时密钥对 (Perfect Forward Secrecy)",
        "8. ✅ 从 ECDH 共享密钥派生对称密钥时使用 HKDF",
        "9. ✅ 加密和签名使用不同的密钥对",
        "10. ⚠️  关注量子计算进展，准备迁移到 PQC",
        "11. 📚 持续学习，使用经过审计的标准库",
        "12. 🔒 永远不要自己实现椭圆曲线运算"
    ]
    
    for rec in recommendations:
        print(f"  {rec}")
    
    print("\n" + "=" * 70)
    print("ECC 的优势:")
    print("  ✅ 更短的密钥 → 更少的存储和带宽")
    print("  ✅ 更快的运算 → 更低的延迟")
    print("  ✅ 更低的功耗 → 适合移动和 IoT")
    print("  ✅ 相同安全级别下性能优于 RSA")
    print("\nECC 是现代密码学的基石！")
    print("=" * 70)

final_ecc_recommendations()
```

---

**总结**：

ECC（椭圆曲线加密）是现代非对称加密的首选方案：

**核心优势**：
- 🚀 **高效**：256 位 ECC = 3072 位 RSA 的安全性
- 📦 **紧凑**：更小的密钥和签名
- ⚡ **快速**：密钥生成和签名比 RSA 快数倍
- 🔋 **节能**：适合移动设备和物联网

**主要应用**：
- **TLS 1.3**：Web 安全的基础
- **SSH**：Ed25519 密钥认证
- **区块链**：Bitcoin、以太坊使用 SECP256K1
- **消息加密**：Signal、WhatsApp 使用 X25519 + Ed25519
- **VPN**：WireGuard 使用 Curve25519

**推荐方案**：
- **签名**：Ed25519（最佳选择）或 SECP256R1/384R1
- **密钥交换**：X25519（最佳选择）或 SECP256R1/384R1
- **加密**：ECIES (ECDH + AES-GCM)

**安全要点**：
1. 使用标准库，不要自己实现
2. ECDSA 避免 nonce 重用
3. 私钥严格保密
4. 关注量子计算威胁
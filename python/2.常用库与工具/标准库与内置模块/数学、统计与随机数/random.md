## 一、模块概述

1. **简介**

- `random` 模块基于梅森旋转算法（Mersenne Twister）实现了伪随机数生成器（PRNG），它在多数应用场景下提供速度快且统计学性质良好的伪随机数，适用于模拟、蒙特卡洛方法、游戏、抽样等。
- 该模块生成的随机数不是“真随机”，而是通过确定性的算法依据内部状态输出；若需加密安全的随机，请使用 `random.SystemRandom` 或 `secrets` 模块。

2. **高层 API 与设计目标**

- 提供一系列函数，涵盖从生成基本伪随机浮点、整数，到针对各种统计分布（均匀、正态、指数、几何等）生成样本，以及从序列中抽样、打乱顺序、生成随机排列等操作。
- 采用“全局访问”模式：`random.random()`、`random.randint()` 等直接调用全局的 `Random()` 实例，方便快捷；也允许创建独立的 `Random` 对象，以便维护各自的状态与种子。

3. **模块导入**

```python
import random

# 或者只取常用函数
from random import random, randrange, shuffle
```

4. **版本与兼容性**

- Python 自 2.3 以来即内置 `random`；算法自 Python 3.2 起统一为 C 语言实现，速度显著提升。
- 默认 PRNG 为基于 C 的 Mersenne Twister，周期为 2⁻⁶¹⁹⁹³⁷−1，足够应对绝大多数仿真与模拟场景。

---

## 二、核心伪随机数生成器与状态管理

### 1. `Random` 类与内部状态

1. `**Random**` **类**

- `random` 模块中核心类型是 `random.Random`，其内部包含一个 624 长度的 32 位整数数组、索引指针等，共计 624×32 ≈ 20 kilobits 状态空间。
- 默认全局模块函数（如 `random.random()`）调用的是单例全局 `Random()` 实例；如果需要并行或隔离的随机流，可显式创建独立实例：

```python
import random
r1 = random.Random()      # 全新实例，使用系统时间作为默认种子
r2 = random.Random(12345) # 指定种子
```

2. **种子（Seed）与可重复性**

- 调用 `random.seed(a=None, version=2)` 初始化或重置 PRNG 的内部状态；若 `a` 为 `None`（默认），则基于系统时间以及操作系统提供的随机源自动生成种子。
- 支持种子类型：任何可哈希的对象（如整数、字符串、字节串、`bytearray` 等）；这些对象先被哈希或转换成整数形式，再用于初始化状态。
- 示例：

```python
import random

random.seed(42)      # 使用固定种子，输出可重复
print(random.random())  # 例如：0.6394267984578837
random.seed("hello")    # 字符串做种子，也可
print(random.random())
```

3. **内部状态导出与恢复**

- 方法 `getstate()` 返回一个可序列化的内部状态对象；可用于在不同程序或运行点间保存与恢复状态，保证接下来的随机序列一致。
- 方法 `setstate(state)` 将先前保存的状态载回，接下来输出的随机数将从该状态继续生成。
- 示例：

```python
import random, pickle

r = random.Random(123)
seq1 = [r.random() for _ in range(3)]
state = r.getstate()

# 生成更多数后，再恢复
extra = [r.random() for _ in range(2)]
r.setstate(state)
seq2 = [r.random() for _ in range(2)]
# seq2 == extra
```

**要点提示**

- **种子控制**：在科研实验、测试中，可通过固定种子保证随机性可复现；
- **独立实例**：若在多线程/多任务中需要不同的随机序列，避免使用同一个全局实例，可为每个任务新建独立的 `Random()`；
- **状态保存**：`getstate()`/`setstate()` 适用于需要在中途暂停、迁移或分布式多节点中保证随机性一致的场景；

---

## 三、生成随机数与序列操作

### 1. 生成基本随机浮点数与整数

|   |   |
|---|---|
|函数／方法|说明|
|`random.random()`|返回 [0.0, 1.0) 区间的均匀分布浮点数。|
|`random.uniform(a, b)`|返回 [a, b] 区间的均匀分布浮点；如果 a > b，则区间实际上为 [b, a]。|
|`random.randint(a, b)`|返回 [a, b] 间的整数（包括 a 和 b）。|
|`random.randrange(start, stop[, step])`|返回在 range(start, stop, step) 中均匀随机选取的整数，stop 不包含在内。|
|`random.choice(seq)`|从非空序列（列表、元组、字符串）中随机选取一个元素；|
|`random.choices(population, weights=None, *, cum_weights=None, k=1)`|有放回重复抽样，从 `population`<br><br>中根据权重选出 k 个元素，返回列表；|

示例：

```python
import random

# 随机浮点
print(random.random())         # 例如 0.719483...
print(random.uniform(1.5, 3.5))  # 例如 2.847302...

# 随机整数
print(random.randint(1, 10))    # 1 到 10 之间的整数
print(random.randrange(0, 10, 2))  # 0,2,4,6,8 中随机选一个

# 从序列中选取
seq = ['apple', 'banana', 'cherry']
print(random.choice(seq))  # 可能 'banana'

# 带权重的抽样
items = ['red', 'green', 'blue']
weights = [10, 1, 1]  # 选择 'red' 的概率较大
print(random.choices(items, weights=weights, k=5))  # 可能 ['red','red','blue','red','green']
```

**要点提示**

- `**random()**` 的精度约为 53 位二进制有效数字，对下游算法（如接入 `normalvariate()`）足够；
- `**uniform(a, b)**` 包含端点；如果需要 [a, b) 或 (a, b) 区间，可自行处理：如 `a + (b - a) * random.random()`；
- `**randint(a, b)**` 等价于 `randrange(a, b+1)`；
- `**choices()**` 返回列表，可指定 `weights` 或 `cum_weights`；如果想要无放回抽样，请使用 `random.sample()`。

### 2. 序列打乱与无放回抽样

|   |   |
|---|---|
|函数／方法|说明|
|`random.shuffle(x[, random])`|就地打乱可变序列 `x`<br><br>（列表），返回 `None`<br><br>；|
|`random.sample(population, k)`|从总体 `population`<br><br>中无放回选取 k 个独立元素，返回列表；|

示例：

```python
import random

# 打乱列表
data = [1, 2, 3, 4, 5]
random.shuffle(data)
print(data)  # 例如 [3,1,5,2,4]

# 无放回抽样
population = list(range(100))
sampled = random.sample(population, 10)  # 随机挑 10 个
print(sampled)  # 列表中无重复元素

# 对字符串打乱：需要先转为列表再 join
s = "abcdef"
lst = list(s)
random.shuffle(lst)
print("".join(lst))  # 例如 'cadfeb'
```

**要点提示**

- `**shuffle()**` 只能作用于可变序列（如列表），并在原列表上修改顺序，返回 `None`；
- 若想生成一个打乱后的新列表，而不影响原序列，可先复制：`shuffled = random.sample(original, len(original))`；
- `**sample()**` 支持任何序列或集合，但若 `population` 是可迭代对象（如生成器），元素会被先转为列表后再抽样，注意内存消耗；

---

## 四、生成各种概率分布的随机数

### 1. 均匀分布与三角分布

|   |   |
|---|---|
|函数／方法|说明|
|`random.random()`|[0.0, 1.0) 的均匀实数；|
|`random.uniform(a, b)`|[a, b] 的均匀实数；|
|`random.triangular(low, high, mode)`|三角分布实数：以 `low`<br><br>、`high`<br><br>、`mode`<br><br>（峰值）三点定义；|

示例：

```python
import random

# 均匀分布
u = random.uniform(10, 20)
print(u)  # 10 到 20 之间均匀随机

# 三角分布
# 如果 mode 留空，则默认为 (low + high) / 2
t = random.triangular(0, 10, mode=3)
print(t)  # 大概率靠近 3
```

### 2. 正态（高斯）分布

|   |   |
|---|---|
|函数／方法|说明|
|`random.gauss(mu, sigma)`|正态分布样本，均值 `mu`<br><br>，标准差 `sigma`<br><br>；|
|`random.normalvariate(mu, sigma)`|同上；|
|`random.betavariate(alpha, beta)`|Beta 分布样本，α、β > 0；|
|`random.lognormvariate(mu, sigma)`|对数正态分布样本，底层先对数再正态；返回实数 > 0；|
|`random.vonmisesvariate(mu, kappa)`|冯·米塞斯分布（环形正态），`mu`<br><br>为平均角度，`kappa`<br><br>为“集中参数”；|

示例：

```python
import random

# 均值 0，标准差 1 的正态分布
for _ in range(5):
    print(random.gauss(0, 1))

# beta 分布
b = random.betavariate(2, 5)  # α=2, β=5
print(b)  # 值在 (0,1) 之间，更多倾向于 0 端

# 对数正态分布
ln = random.lognormvariate(0, 1)  # ln(x) ~ N(0,1)，x>0
print(ln)

# 冯·米塞斯分布
vm = random.vonmisesvariate(0, 1)  # 平均角 0 弧度，集中度 1
print(vm)  # 返回弧度值在 (-π, π]
```

**要点提示**

- `gauss()` 与 `normalvariate()` 在算法实现上等价，可互换；底层使用 Box–Muller 或 Marsaglia 极坐标法；
- `lognormvariate(mu, sigma)` 中，`mu` 和 `sigma` 分别是对数空间中的参数，若要得到期望为 m、方差为 v 的对数正态分布，可先将 m、v 转换为相应的 mu、sigma；
- `vonmisesvariate()` 用于生成圆形统计（如风向、角度）数据；

### 3. 离散分布与计数分布

|   |   |
|---|---|
|函数／方法|说明|
|`random.expovariate(lambd)`|指数分布样本，λ > 0；均值 = 1/λ；|
|`random.paretovariate(alpha)`|帕累托分布样本，α > 0；|
|`random.weibullvariate(alpha, beta)`|威布尔分布样本，参数 α（形状）、β（尺度）；|
|`random.gauss()`<br><br>（近似）|对于二项分布或泊松分布等大样本，可将正态分布作近似；|
|`random.choice()`<br><br>+ 频率|可通过加权选择近似任意离散分布；|

示例：

```python
import random

# 指数分布（排队论常用）
for _ in range(5):
    print(random.expovariate(0.5))  # λ=0.5 → 平均间隔 2

# 帕累托分布
for _ in range(3):
    print(random.paretovariate(2.5))  # α=2.5

# 威布尔分布
for _ in range(3):
    print(random.weibullvariate(1.5, 2.0))  # α=1.5, β=2.0
```

**要点提示**

- `expovariate()` 适合模拟 Poisson 过程间隔；
- `paretovariate()` 生成幂律分布尾，适用于经济学、地震学、人类活动等领域；
- `weibullvariate()` 广泛用于寿命分析、可靠性工程等；
- 若需离散概率分布（如二项、泊松、几何、超几何等），可使用第三方库 `numpy.random` 或手工实现；

---

## 五、密码学安全随机数

### 1. `SystemRandom` 类

1. **用途与实现**

- `random.SystemRandom` 是基于操作系统提供的 CSPRNG（如 Linux `/dev/urandom`、Windows CryptGenRandom）实现，调用系统底层采集的随机熵，适用于密码学场景。
- 其方法与 `Random` 类相同，但底层不使用 Mersenne Twister，而是直接调用 `os.urandom()`。

2. **示例用法**

```python
import random

sysrand = random.SystemRandom()

# 生成 [0.0, 1.0) 的浮点
print(sysrand.random())

# 生成安全随机整数
print(sysrand.randint(1, 100))

# 从列表中安全随机选一个
secrets = ['alpha', 'bravo', 'charlie']
print(sysrand.choice(secrets))

# 打乱列表顺序
data = [1, 2, 3, 4, 5]
sysrand.shuffle(data)
print(data)
```

3. **与** `**secrets**` **模块的比较**

- Python 3.6+ 引入了 `secrets` 模块，专门用于生成密码学安全随机数、令牌或密钥。
- `secrets` 的接口更简洁：`secrets.choice()`、`secrets.randbelow(n)`、`secrets.token_bytes(n)`、`secrets.token_hex(n)` 等。
- 若只需“密码级别随机”，优先考虑 `secrets`，如：

```python
import secrets

# 随机选一个安全密码字符
alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789'
pwd = ''.join(secrets.choice(alphabet) for _ in range(12))
print(pwd)

# 随机生成字节令牌
token = secrets.token_bytes(16)  # 16 字节
print(token.hex())
```

**要点提示**

- **不要将默认的** `**random.random()**` **用于任何安全或加密场景**，因为它是可预测的；
- **若在密码学场景下需要分布函数（如正态分布）且要求安全随机，可将系统随机生成的位流转换为浮点后再自行实现分布采样，但通常推荐使用** `**secrets**` **生成密钥/令牌，用** `**cryptography**` **等库做更高级安全运算；**

---

## 六、可重复实验与种子控制

### 1. 固定种子保证可重复

- 若要在实验、仿真、单元测试等场景中获取可重复的随机序列，应在每次运行时初始阶段调用 `random.seed(some_constant)`。
- 示例：

```python
import random

def simulate(n):
    random.seed(2025)  # 固定种子
    data = [random.random() for _ in range(n)]
    return data

print(simulate(5))  # 每次运行都会输出相同的 5 个浮点数
```

### 2. 独立子实例与并行随机

- 对于多线程或多进程场景，可为每个线程/进程创建独立的 `Random()` 实例，并使用不同的种子，确保并行之间无交叉。

```python
import random, threading

def worker(seed):
    r = random.Random(seed)
    print(f"Thread {seed}: {r.random()}")

threads = []
for i in range(3):
    t = threading.Thread(target=worker, args=(i+1,))
    threads.append(t)
    t.start()
for t in threads:
    t.join()
```

- 在多进程场景下，一般在 `fork` 后各进程会继承父进程同一状态，需要重新 `seed()`。推荐在子进程启动后以独立值（如进程 ID、时间戳）为种子。

**要点提示**

- **始终在多线程/多进程环境中避免共享同一个** `**Random()**` **实例以防止竞态；**
- **对子实例使用与父实例不同的种子或状态，以确保并行之间没有关联；**
- **若需要更高级的并行随机生成，可使用第三方库** `**numpy.random.Generator**` **配合 PCG 或 Philox 算法；**

---

## 七、注意事项与最佳实践

1. **避免对伪随机数期待过高**

- Mersenne Twister 的周期极长、统计性质良好，但它并非“真随机”。对安全敏感场景不要使用。
- 小规模 Monte Carlo 或模拟可放心使用，但若要对抗攻击者或猜测，请使用 `SystemRandom` 或 `secrets`。

2. **浮点均匀分布精度**

- `random.random()` 生成的浮点在 [0.0, 1.0) 之间，精度约 53 位二进制。对于 [a, b] 区间，`uniform(a, b)` 内部实现是 `a + (b - a) * random.random()`，当 `b - a` 很小时会受浮点精度限制；对于极端场景，需考虑自定义采样方法。

3. **组合分布函数谨慎使用**

- 用 `gauss()` 近似二项分布或泊松分布时，当参数较小时效果差异明显；若需要精确模拟，请使用 `numpy.random.binomial()`、`numpy.random.poisson()` 等或自行实现离散采样。

4. **调用顺序与 thread-safety**

- `Random()` 对象的方法本身在单线程中是安全的；但全局模块函数共享同一个实例，若在多线程中并发调用全局函数可能导致数据竞争。最佳做法是每个线程维护独立实例。

5. **状态保存与恢复注意序列化格式**

- `getstate()` 返回的数据结构包含大整数数组与指针，直接通过 `pickle` 序列化保存是可行的；但请谨慎保存跨 Python 版本之间的 state，可能因内部实现变化而无法兼容。

6. **性能成本**

- 对于大量随机数生成任务，`random` 模块的 Python 层调用略慢于纯 C 实现，如 `numpy.random`。如果要批量生成百万级随机数，建议使用 `numpy`。
- 小规模（几千、几万）或对第三方库依赖较敏感的场景中，`random` 性能足够。

---

## 八、综合示例

以下示例将演示一个蒙特卡洛积分估计问题，即估计单位圆面积近似值 π。

```python
import random
import math

def estimate_pi(num_samples, seed=None):
    """
    使用蒙特卡洛方法估计圆面积（进而估计 π）。
    在单位正方形 [0,1]×[0,1] 中随机撒点，统计落在 x^2 + y^2 <= 1 的比例。
    """
    r = random.Random(seed)  # 如果 seed 提供可重复
    count_inside = 0
    for _ in range(num_samples):
        x = r.random()
        y = r.random()
        if x*x + y*y <= 1.0:
            count_inside += 1
    # 落在四分之一圆内的概率 ≈ π/4，故 π ≈ 4 * count_inside / num_samples
    return 4 * count_inside / num_samples

# 测试
for n in [1000, 10000, 100000, 1000000]:
    pi_est = estimate_pi(n, seed=123)
    print(f"样本数 {n:8d} → π 估计值 = {pi_est:.6f}, 误差 = {abs(pi_est - math.pi):.6f}")
```

输出示例：

```yaml
样本数     1000 → π 估计值 = 3.160000, 误差 = 0.018407
样本数    10000 → π 估计值 = 3.142800, 误差 = 0.000207
样本数   100000 → π 估计值 = 3.141680, 误差 = 0.000087
样本数  1000000 → π 估计值 = 3.141460, 误差 = 0.000133
```

**要点提示**

- **通过指定固定种子，可保证每次运行得到相同的估计值；**
- **独立使用** `**random.Random(seed)**` **创建隔离实例，避免与全局随机状态冲突；**
- **对于蒙特卡洛类算法，采样量越大，估计越接近真实值，但也要留意计算成本；**

---

## 九、总结

- `**random**` **模块** 为 Python 提供了基于 Mersenne Twister 的高效伪随机数生成与分布采样，适合模拟、抽样、游戏、统计、测试等场景。
- **核心功能**：

1. **基本伪随机**：均匀浮点 `random()`、整数 `randint()`、区间取值 `randrange()`；
2. **序列操作**：`choice()`、`shuffle()`、`sample()` 与多次有放回抽样 `choices()`；
3. **各种分布**：均匀 `uniform()`、三角 `triangular()`、正态 `gauss()`/`normalvariate()`、对数正态、Beta、帕累托、指数、威布尔、冯·米塞斯等；
4. **离散数学**：无放回采样 `sample()`、打乱顺序 `shuffle()`；
5. **可重复性**：`seed()`、`getstate()`、`setstate()`；
6. **密码安全**：`SystemRandom` 类与 `secrets` 模块；

- **最佳实践要点**：

1. 在可复现实验中固定种子或使用单独 `Random()` 实例；
2. 在多线程/多进程环境中避免共享全局实例，或使用独立实例并手动加锁；
3. 对于安全需求使用 `SystemRandom` 或 `secrets`；
4. 在统计采样中尽可能使用专门的分布函数而非手写近似；
5. 对于大规模随机数生成任务，考虑使用 `numpy.random` 以提高性能。

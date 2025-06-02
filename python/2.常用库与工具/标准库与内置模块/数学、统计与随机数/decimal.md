## 1. `decimal` 模块概述

- `decimal` 模块旨在提供 **十进制浮点运算**，弥补内置二进制浮点（`float`）在极端精度或金融场景中的不足。
- 核心类为 `Decimal`，它可以表示任意精度的十进制数，并可通过上下文（`Context`）灵活控制精度、四舍五入方式、溢出处理等。
- 适用场景：

- 金融计算（如货币换算、利息计算），需要避免二进制浮点的舍入误差。
- 需要确定精度和可预测舍入行为的科学计算。
- 任意精度运算：当 `float` 不足以表达非常大或非常小的数时，可使用 `Decimal`。

- `decimal` 模块遵循 IEEE 854-1987 标准（为 IEEE 754 的先驱），并在此基础上增加了若干 Python 友好的功能。

使用时通常写到：

```python
from decimal import Decimal, getcontext, localcontext
```

---

## 2. Decimal 类及其初始化

### 2.1 创建 `Decimal` 对象

`Decimal` 可通过以下方式初始化：

1. **字符串** 初始化（推荐）

```python
from decimal import Decimal
a = Decimal('3.14159')
b = Decimal('-0.01')
```

- 直接从字符串创建时，能够精确表示十进制数值，不会出现二进制浮点的舍入误差。

2. **整数** 初始化

```python
c = Decimal(12345)
```

- 从整数构造无需考虑精度问题，结果与 `int` 精确对应。

3. **元组** 初始化（不常用）

```python
t = (0, (1, 2, 3, 4), -2)  # 表示 1234 × 10⁻² = 12.34
d = Decimal(t)
```

- 元组格式为 `(sign, digits, exponent)`，其中 `sign` 为 0（正）或 1（负），`digits` 为整型序列（每个元素 0–9），`exponent` 为十进制指数（整数）。
- 这对于从外部解析好的数值构建 `Decimal` 可能有用，但日常编码多使用字符串或整数。

4. **浮点数** 初始化（谨慎）

```python
x = Decimal(1.1)
print(x)  # 可能显示 1.100000000000000088817841970012523233890533447265625
```

- **不推荐** 从 `float` 构造，因为这样会保留二进制浮点的不精确位。若已有 `float`，应先使用 `format` 或者 `str` 使其定点：

```python
x = Decimal(str(1.1))  # 更安全，得到 Decimal('1.1')
```

### 2.2 `Decimal` 的内部表示

`Decimal` 内部使用一个“带符号的整数 + 指数”模型：

- value=(±)integer_mantissa×10exponent \text{value} = (\pm) \text{integer\_mantissa} \times 10^{\text{exponent}}value=(±)integer_mantissa×10exponent
- 每个 `Decimal` 对象都携带：

- **sign**（符号位）：0 表示正，1 表示负；
- **digits**（系数数组）：一个 0–9 的数字元组，保存有效数字；
- **exponent**：整数，表示小数点相对于系数的位置。

例如，`Decimal('12.345')` 内部等价于 `(sign=0, digits=(1,2,3,4,5), exponent=-3)`。

### 2.3 inspect：查看 Decimal 内部结构

```python
from decimal import Decimal

d = Decimal('12.345')
print(d.as_tuple())
# 输出：DecimalTuple(sign=0, digits=(1, 2, 3, 4, 5), exponent=-3)
```

- `Decimal.as_tuple()` 返回 `DecimalTuple(sign, digits, exponent)`，方便调试或做自定义运算时查看底层数据。

---

## 3. 四则运算与精度控制

### 3.1 基本运算

`Decimal` 支持以下常用运算符，与内置数值类型类似：

- 加法：`+`
- 减法：`-`
- 乘法：`*`
- 除法：`/`
- 整除：`//`（向 下 整 除）
- 取余：`%`
- 幂运算：`**`

示例：

```python
from decimal import Decimal

a = Decimal('2.5')
b = Decimal('1.3')

print(a + b)   # Decimal('3.8')
print(a - b)   # Decimal('1.2')
print(a * b)   # Decimal('3.25')
print(a / b)   # 结果根据当前上下文精度而定
print(a // b)  # 向下取整
print(a % b)   # 取余
print(a ** 2)  # Decimal('6.25')
```

### 3.2 精度（Precision）与上下文（Context）

- `Decimal` 的运算受限于 **上下文（Context）** 中设置的 **精度（precision）**，即最多保留多少位有效数字。
- 默认上下文 (`getcontext()`) 的 `precision` 通常为 28 位。如果运算结果超过上下文精度，模块会根据四舍五入模式（`rounding`）截断或抛出异常。

示例：

```python
from decimal import Decimal, getcontext

# 默认精度通常是 28
ctx = getcontext()
print(ctx.prec)  # 28

# 将精度改为 5
ctx.prec = 5

x = Decimal('1') / Decimal('3')
print(x)  # Decimal('0.33333')，5 位有效数字

# 再改成 10
ctx.prec = 10
print(Decimal('1') / Decimal('3'))  # Decimal('0.3333333333')
```

- 如果除法无穷循环且超出精度，会根据 `rounding` 截断余下部分，并且上下文中的 `Inexact`、`Rounded` 信号会被置位（参见第 9 节）。

---

## 4. Context（上下文）与全局配置

### 4.1 获取与设置全局上下文

```python
from decimal import getcontext

ctx = getcontext()  
# getcontext() 返回当前线程的全局 Context 对象（Context 实例）
```

- 一个 `Context` 对象包含以下核心属性（部分常用列举）：

- `prec`：精度（最大有效数字位数）。
- `rounding`：四舍五入模式（参考第 5 节）。
- `Emin` / `Emax`：可表示的最小/最大指数范围，超出会触发下溢或上溢。
- `capitals`：当输出科学计数法时，指数部分 `E` 是否大写（0/1）。
- `clamp`：是否对指数做截断，使其在一定规则内；一般不常改。
- `flags`：记录上一次运算过程中触发的所有信号（如 `Inexact`, `Overflow` 等）。
- `traps`：哪些信号要作为异常抛出。

示例：

```python
from decimal import getcontext, InvalidOperation

ctx = getcontext()
ctx.prec = 10
ctx.rounding = 'ROUND_HALF_UP'
ctx.Emin = -999999
ctx.Emax = 999999
# 打印当前所有设置
print(ctx)
```

### 4.2 设置全局上下文的影响

- 修改 `getcontext()` 返回的上下文后，后续所有使用 `Decimal` 进行的运算都会遵循该配置。
- 在多线程环境下，每个线程都有独立的上下文，不会相互干扰。

---

## 5. 四舍五入（Rounding）模式

`decimal` 模块提供了多种舍入策略，可通过上下文 `rounding` 属性选择。常见值有：

|   |   |
|---|---|
|模式名称|含义|
|`ROUND_HALF_UP`|四舍五入，即：小数部分 ≥ 0.5 向上，否则向下。|
|`ROUND_HALF_EVEN`<br><br>（默认）|银行家舍入：当尾数正好为 0.5 时，向最近的偶数舍入。|
|`ROUND_DOWN`<br><br>（截断）|直接截断小数部分（向 0 方向靠拢）。|
|`ROUND_UP`|绝对值方向“进位”，即不管小数大小，都向更大绝对值方向舍入。|
|`ROUND_CEILING`<br><br>（向正无穷大舍入）|如果值为正，小数部分非零则向上；负值则向下（绝对值减小）。|
|`ROUND_FLOOR`<br><br>（向负无穷大舍入）|如果值为正，小数部分非零则向下；负值则向上（绝对值增大）。|
|`ROUND_05UP`|如果最后一位数字 ≤ 4，则舍入到较近的整数（相当于 `ROUND_DOWN`<br><br>）；如果最后一位数字 ≥ 5，则向远离零方向舍入一个单位。|

示例演示不同舍入策略在除法计算中的表现：

```python
from decimal import Decimal, getcontext

nums = (Decimal('1'), Decimal('6'))
dividend, divisor = nums

for mode in ['ROUND_HALF_UP', 'ROUND_HALF_EVEN', 'ROUND_DOWN', 'ROUND_UP', 'ROUND_CEILING', 'ROUND_FLOOR', 'ROUND_05UP']:
    ctx = getcontext().copy()
    ctx.prec = 3
    ctx.rounding = mode
    result = dividend.__truediv__(divisor, context=ctx)
    print(f"{mode:15} → {result}")
```

可能输出：

```nginx
ROUND_HALF_UP   → 0.167
ROUND_HALF_EVEN → 0.167
ROUND_DOWN      → 0.166
ROUND_UP        → 0.167
ROUND_CEILING   → 0.167
ROUND_FLOOR     → 0.166
ROUND_05UP      → 0.167
```

- 上例中 `1/6 ≈ 0.166666…`，在 3 位精度下，尾数第 4 位为 6；多数模式都将 0.1666… 舍入为 0.167，唯有 `ROUND_DOWN` 和 `ROUND_FLOOR` 取 0.166。

---

## 6. 精确控制：Quantize 与 Normalize

有时需要将一个 `Decimal` 强制调整为某个固定小数位数。典型用例：货币值保留两位小数。

### 6.1 `quantize` 方法

```python
d = Decimal('3.1415926')
# 保留两位小数，一般用 ROUND_HALF_UP (四舍五入)
result = d.quantize(Decimal('0.01'), rounding='ROUND_HALF_UP')
print(result)  # 3.14
```

- `quantize(self, exp, rounding=None, context=None)`：

- `exp`：为一个 `Decimal`，其指数部分表明目标小数位数。例如：

- `Decimal('0.01')` → 保留到小数点后 2 位；
- `Decimal('1e-3')` 等价于 `Decimal('0.001')`，保留到小数点后 3 位；
- `Decimal('1')` → 向整数舍入；
- `Decimal('10')` → 以 10 为单位舍入（如 `Decimal('27').quantize(Decimal('10')) = 30`）。

- `rounding`：可选舍入模式，若不指定则使用当前上下文。

注意：

- 如果目标精度（`exp`）比当前数值本身 “更精细” 但上下文精度不足，可能会触发 `Inexact` 信号或引发异常（若上下文 `traps` 设置了 `Inexact`）。
- `quantize` 会强行调整指数，因此可能会改变数值长度和格式。

### 6.2 `normalize` 方法

```python
d1 = Decimal('3.14000')
print(d1.normalize())  # 3.14

d2 = Decimal('0E+3')
print(d2.normalize())  # Decimal('0E+3')，规范化后仍保持指数形式
```

- `normalize()` 可去掉尾部无意义的零，使表示更紧凑。
- 如果结果为零，则指数会保持为原始幂次，以便区分 “0” 与 “0E-5” 等含义。

---

## 7. 特殊值（NaN、Infinity）

`Decimal` 支持以下特殊值，与 IEEE 754 浮点类似：

1. **正/负无限（Infinity）**

```python
from decimal import Decimal
inf = Decimal('Infinity')
neg_inf = Decimal('-Infinity')
```

2. **非数（NaN, Not a Number）**

```python
nan = Decimal('NaN')
```

3. **带标识符的 NaN（常用于调试或携带元信息）**

```python
nan_q = Decimal('sNaN123')    # 带符号的信号 NaN（quiet NaN）
nan_s = Decimal('NaNpayload') # 带 payload 的 NaN
```

4. **同样存在 ±0 的区分**

- `Decimal('0')` 与 `Decimal('-0')` 是不同的，符号位不同，但在数值上同等。
- `Decimal('-0')` 可通过 `is_signed()` 方法判断：

```python
z1 = Decimal('0')
z2 = Decimal('-0')
print(z1 == z2)         # True
print(z2.is_signed())   # True
print(z1.is_signed())   # False
```

### 7.1 特殊值参与运算的规则

- 任何数与 `NaN` 运算结果一般为 `NaN`，但部分函数或上下文信号可能会触发异常。
- 与 `Infinity` 运算遵循数学规则：

- `x + Infinity = Infinity`，`x * Infinity` 需视 `x` 符号；
- `Infinity - Infinity = NaN`；
- `0 * Infinity = NaN`；

- 可以使用 `is_nan()`、`is_infinite()`、`is_finite()` 等方法判断特殊值：

```python
d = Decimal('NaN')
print(d.is_nan())       # True
print(d.is_normal())    # False
print(d.is_finite())    # False
```

---

## 8. 本地上下文管理（localcontext）

在某些场景下，希望针对某段代码临时修改精度或舍入模式，而不影响全局上下文。此时可以使用 `localcontext()`。

```python
from decimal import Decimal, getcontext, localcontext

# 全局上下文
print(getcontext().prec)  # 假设 28

a = Decimal('1') / Decimal('7')
print(a)  # 按默认 28 位精度显示

# 临时修改上下文
with localcontext() as ctx:
    ctx.prec = 5
    ctx.rounding = 'ROUND_DOWN'
    b = Decimal('1') / Decimal('7')
    print(b)  # 保留 5 位小数且向下截断

# 上下文恢复全局设置
c = Decimal('1') / Decimal('7')
print(c)  # 仍按 28 位精度
```

- `localcontext()` 返回一个新的上下文拷贝，进入 `with` 块后对其修改只在块内生效，块结束后自动恢复上一级上下文。
- 若需要跨多个函数或模块共享临时上下文，也可以手动将 `localcontext()` 的返回值赋给变量，并显式 `copy()`。

---

## 9. 信号与异常（Signals & Exceptions）

### 9.1 Context 中的 `flags` 与 `traps`

- 当 `Decimal` 运算过程中发生以下情况时，会“发出”相应的信号（`Signal`），并将上下文中的 `flags[signal_name]` 置为 `True`。
- 如果上下文中的 `traps[signal_name]` 设置为 `True`，则该信号会转变为 `DecimalException` 并抛出。否则，仅在 `flags` 中记录。

常见信号（及含义）：

1. `**InvalidOperation**`：非法操作，例如 `0 / 0`、`Infinity - Infinity`。
2. `**DivisionByZero**`：除以零操作，例如 `Decimal('1') / Decimal('0')`。
3. `**Overflow**`：结果指数或数字超出了上下文的 `Emax`/`prec` 能力。
4. `**Underflow**`：结果指数低于 `Emin` 且不等于 0，引起小于最小可表示数。
5. `**Inexact**`：计算结果不是精确的十进制数，需要舍入时置位。
6. `**Rounded**`：执行舍入操作时置位（通常与 `Inexact` 同时出现）。
7. `**Subnormal**`（又称 Denormal）：结果指数虽然在范围内，但系数不能填满上下文精度，表示次正规数。

示例：观察信号发生与捕获

```python
from decimal import Decimal, getcontext, DivisionByZero, InvalidOperation

ctx = getcontext().copy()
ctx.prec = 5
ctx.traps[DivisionByZero] = True   # 把除零作为异常触发
ctx.traps[InvalidOperation] = False

# 捕获除以零
try:
    result = Decimal('1') / Decimal('0')
except DivisionByZero as e:
    print("捕获到除零异常：", e)

# 如果是无效操作（0/0），因为 trap=False，则不会抛异常，但 flags 会被置位
res = ctx.divide(Decimal('0'), Decimal('0'))  # 0/0
print("InvalidOperation 信号置位：", ctx.flags[InvalidOperation])
```

- `flags` 会在发生信号后持久保持，直到手动重置（`ctx.clear_flags()`）。
- `traps` 列表决定了哪些信号会抛出对应异常。

### 9.2 常见异常类型

- `DecimalException`：`decimal` 模块所有异常的基类。
- `DivisionByZero`：除以零时抛出（若 trap=True）。
- `InvalidOperation`：无效运算时抛出（如 `sqrt(-1)`、`log(0)`、`0/0` 等）。
- `Overflow`：数值太大溢出上限时抛出（若 trap=True）。
- `Underflow`：数值太小引起下溢时抛出（若 trap=True）。
- `Subnormal`：次正规数警告时抛出（极少使用）。
- `Rounded`、`Inexact`：仅在 trap=True 时抛出，否则仅置位信号。

示例：

```python
from decimal import getcontext, Decimal, Overflow

ctx = getcontext().copy()
ctx.prec = 2
ctx.rounding = 'ROUND_HALF_UP'
ctx.traps[Overflow] = True

# 构造一个可能溢出的运算
large = Decimal('9.9e+99')
try:
    res = large * large
except Overflow as e:
    print("溢出异常：", e)
```

- 将 `traps[Overflow]` 设置为 `False` 时，运算结果为 `Infinity`，不会抛异常，但 `ctx.flags[Overflow]` 会变为 `True`。

---

## 10. 用途与性能注意

### 10.1 典型应用场景

1. **金融与货币计算**

- 需要 100% 确定小数位且不允许二进制浮点误差。
- 例如：银行利息计算、汇率转换、会计报表等。
- 常配合 `quantize(Decimal('0.01'))` 保持两位小数。

2. **科学计算（对精度严格要求的场合）**

- 当需要确定小数点后若干位的高精度运算时，`Decimal` 可满足较长尾数需求。
- 例如：天文计算、物理模拟中某些极端参数。

3. **自定义舍入规则**

- 不同场景（会计、金融、统计）常有不同舍入规范。`Decimal` 支持灵活设置 `rounding`。

4. **财务报表输出**

- 生成报表前进行汇总、换算等运算时，可以保持精度一致。

### 10.2 性能对比与注意点

- 与内置 `float` 相比，`Decimal` 运算速度显著较慢，原因在于它是基于 Python 对象和高精度算法实现的。
- 在不需要绝对精度且对性能有严格要求时，尽量使用 `float` 或者 `fractions.Fraction`（但 `Fraction` 适合整除与分数运算，非浮点）。
- 建议：只在必要的地方对关键数据使用 `Decimal`，其他部分可以暂用 `float`。
- 若需对大量数据做十进制运算，可考虑：

- 缩小上下文精度（`prec`）到刚好满足需求，不要过度浪费；
- 避免在循环中频繁修改上下文；
- 预先初始化所有 `Decimal` 实例，减少运行时重复构造。

---

## 11. 综合示例

下面给出若干常见场景的综合示例，帮助你加深对 `decimal` 模块的理解。

### 11.1 货币计算：累加、汇率换算

```python
from decimal import Decimal, getcontext, ROUND_HALF_UP

# 全局上下文（假设银行对小数位数要求严格）
ctx = getcontext()
ctx.prec = 10
ctx.rounding = ROUND_HALF_UP

# 假设有若干笔交易，需要汇总并转换为人民币（CNY）
transactions = [
    ('USD', Decimal('123.45')),
    ('EUR', Decimal('78.90')),
    ('USD', Decimal('10.00')),
    ('JPY', Decimal('5000')),
]

# 汇率（示例）：1 USD = 6.5 CNY；1 EUR = 7.8 CNY；1 JPY = 0.06 CNY
rates = {
    'USD': Decimal('6.5'),
    'EUR': Decimal('7.8'),
    'JPY': Decimal('0.06'),
}

total_cny = Decimal('0')
for currency, amount in transactions:
    cny_amount = (amount * rates[currency]).quantize(Decimal('0.01'))
    print(f"{currency} {amount} → CNY {cny_amount}")
    total_cny += cny_amount

print(f"总计人民币：CNY {total_cny.quantize(Decimal('0.01'))}")
```

**解析：**

- 首先设置上下文 `prec=10`、`rounding=ROUND_HALF_UP`，保证后续四则运算符合财务要求。
- 用 `quantize(Decimal('0.01'))` 保持两位小数，每次汇率换算后立即四舍五入到分。
- 最后累加所有结果，并再次四舍五入到分。

### 11.2 科学计算：高精度圆周率与幂运算

```python
from decimal import Decimal, getcontext, ROUND_FLOOR

# 计算高精度的圆周率 π（使用 20 位小数）——使用“莱布尼茨级数”（速度较慢，仅示例）
def compute_pi(n_terms):
    getcontext().prec = 25
    getcontext().rounding = ROUND_FLOOR
    pi = Decimal(0)
    one = Decimal(1)
    for k in range(n_terms):
        term = (one / (Decimal(2) * Decimal(k) + one)) * ((-one) ** k)
        pi += term
    return pi * Decimal(4)

pi_approx = compute_pi(100000)
print("π ≈", pi_approx)
```

- 本例用“莱布尼茨级数”近似计算 π，由于收敛速度极慢，仅供演示高精度 `Decimal` 用法。
- 先设置 `prec=25`，保持 25 位有效数字，再将每次加法按 `ROUND_FLOOR` 向下取整。

### 11.3 本地上下文：不同运算段使用不同精度

```python
from decimal import Decimal, getcontext, localcontext

# 全局上下文：普通精度
getcontext().prec = 6
a = Decimal('1.23456789') + Decimal('2.34567891')
print("全局环境下 a =", a)  # 按 6 位精度计算，存在舍入

# 某段需要极高精度
with localcontext() as ctx:
    ctx.prec = 20
    b = Decimal('1.23456789') + Decimal('2.34567891')
    print("局部高精度下 b =", b)  # 按 20 位精度计算

# 离开 localcontext，恢复全局设置
c = Decimal('1.23456789') + Decimal('2.34567891')
print("恢复全局下 c =", c)
```

- 通过 `localcontext()` 创建临时上下文，各段运算精度互不干扰。

### 11.4 信号捕获：检测除法是否精确

```python
from decimal import Decimal, getcontext, Inexact, Rounded

ctx = getcontext().copy()
ctx.prec = 5
ctx.traps[Inexact] = False
ctx.traps[Rounded] = False

# 每次运算后，检查 flags
def safe_div(a, b):
    ctx.clear_flags()
    result = ctx.divide(a, b)
    inexact = ctx.flags[Inexact]
    rounded = ctx.flags[Rounded]
    return result, inexact or rounded

nums = [
    (Decimal('1'), Decimal('2')),   # 1/2 = 0.5，精确
    (Decimal('1'), Decimal('3')),   # 1/3，结果 0.33333…，舍入
]

for a, b in nums:
    res, is_approx = safe_div(a, b)
    if is_approx:
        print(f"{a}/{b} 结果 {res}（非精确，需要舍入）")
    else:
        print(f"{a}/{b} 精确结果 {res}")
```

**解析：**

- 将 `Inexact`、`Rounded` 信号的 `trap` 都设置为 `False`，这样不会抛出异常，但会在 `flags` 中记录何时发生舍入或不精确。
- 通过 `ctx.flags[...]` 可以获知计算结果是否精确或经过舍入。

---

## 小结

1. `**Decimal**` **的设计目标**：实现高精度十进制浮点运算，避免二进制浮点的舍入误差，满足金融计算与精密科学计算需求。
2. **初始化方式**：

- **首选字符串** 形式 `Decimal('123.456')`；
- 也可用整数、元组；**不推荐**直接用 `float` 构造。

3. **Context（上下文）**：

- 控制 **精度（precision）**、**舍入模式（rounding）**、**指数范围（Emin/Emax）**、**信号与 trap** 等；
- `getcontext()` 返回全局上下文；`localcontext()` 可创建局部副本。

4. **四舍五入模式**：

- 常见的 `ROUND_HALF_UP`、`ROUND_HALF_EVEN`、`ROUND_DOWN`、`ROUND_UP` 等，适配不同场景需求。

5. **精确控制**：

- `quantize` 可强制按指定指数格式舍入；
- `normalize` 可去除无用尾零。

6. **特殊值**：支持 `NaN`、`Infinity`、`−0`，与 IEEE 754 行为保持一致。
7. **信号与异常**：运算过程中可通过 `flags` 查看信号，若在 `traps` 中设置则抛出相应异常。
8. **用例与性能**：

- 金融、货币、利率等场景优先使用；
- 由于性能较慢，请避免对海量数据全过程使用；可视情况切换到 `float` 或分段使用 `Decimal`。

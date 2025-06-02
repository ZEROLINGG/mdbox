## 一、模块概述

1. **简介**

- `math` 模块是 Python 标准库中专门提供基础数学运算的模块，使用 C 语言实现，直接调用底层的高效数学函数。它只针对实数（非复数）进行操作，因此不能处理负数开方等复数运算；若需要复数数学，应使用 `cmath` 模块。
- 相较于内置算术运算符和某些内置函数（如 `abs()`、`pow()`），`math` 提供了更多特殊函数、更高精度的浮点累计（`fsum()`）以及组合数学（`factorial()`、`comb()` 等）等功能，适合科学计算、统计学、工程计算等需要。

2. **导入方法**

```python
import math
# 或者只导入特定函数
from math import sin, pi
```

3. **性能与精度**

- 大多数 `math` 函数在 C 层调用 libc 的数学库（libm），性能接近原生 C。
- 可以处理 IEEE-754 浮点数并返回尽可能精确的结果；对于累计求和等场景，提供了 `fsum()` 用于减小舍入误差。
- 由于浮点数本身的局限，某些运算结果可能会出现极小的舍入误差，使用时需酌情判断（如 `math.isclose()` 辅助比较近似相等）。

---

## 二、核心常量

`math` 模块定义了一些常用的数学常量，以下是其中最常用的几项：

|   |   |
|---|---|
|常量|含义|
|`math.pi`|圆周率 π，精确到浮点数能表示的极限；约 3.141592653589793|
|`math.e`|自然常数 e，约 2.718281828459045|
|`math.tau`|圆周率的两倍，即 2π，约 6.283185307179586|
|`math.inf`|正无穷大 (∞)，可用于标识极大值。|
|`-math.inf`|负无穷大 (-∞)。|
|`math.nan`|“非数字”（NaN）值，用于标识未定义或不可表示的浮点结果。|

```python
import math

print(math.pi)       # 3.141592653589793
print(math.e)        # 2.718281828459045
print(math.tau)      # 6.283185307179586
print(math.inf)      # inf
print(math.nan)      # nan
```

**要点提示**

- `math.inf` 与 `float('inf')` 等价，常用于初始化最小/最大值，或在取极限时表示“没有上界”。
- `math.nan` 代表一种特殊的浮点值：与它自身都不相等（`math.nan != math.nan`），可用 `math.isnan(x)` 来检测。

---

## 三、主要函数分类

下面从不同功能维度对 `math` 模块的函数进行分类讲解。

### 1. 基本算术与数值测试

|                    |                                                 |
| ------------------ | ----------------------------------------------- |
| 函数                 | 说明                                              |
| `math.ceil(x)`     | 向上取整，返回最小的整数 ≥ x；                               |
| `math.floor(x)`    | 向下取整，返回最大的整数 ≤ x；                               |
| `math.trunc(x)`    | 截断小数部分，返回整数部分，等价于 `int(x)`<br><br>（但对负数表现相同）；   |
| `math.fabs(x)`     | 绝对值，返回浮点形式的                                     |
| `math.isfinite(x)` | 判断 x 是否为有限数（不是 `inf`<br><br>也不是 `nan`<br><br>）。 |
| `math.isinf(x)`    | 判断 x 是否为正/负无穷。                                  |
| `math.isnan(x)`    | 判断 x 是否为 NaN。                                   |

示例：

```python
import math

values = [3.7, -2.3, math.inf, -math.inf, math.nan]
for v in values:
    print(f"x={v:6}  ceil={math.ceil(v) if math.isfinite(v) else 'NA'}  floor={math.floor(v) if math.isfinite(v) else 'NA'}  trunc={math.trunc(v) if math.isfinite(v) else 'NA'}  fabs={math.fabs(v)}  isfinite={math.isfinite(v)}  isinf={math.isinf(v)}  isnan={math.isnan(v)}")
```

输出示例：

```matlab
x=   3.7  ceil=4  floor=3  trunc=3  fabs=3.7       isfinite=True  isinf=False  isnan=False
x=  -2.3  ceil=-2 floor=-3 trunc=-2 fabs=2.3       isfinite=True  isinf=False  isnan=False
x=   inf  ceil=NA floor=NA trunc=NA fabs=inf       isfinite=False isinf=True   isnan=False
x=  -inf  ceil=NA floor=NA trunc=NA fabs=inf       isfinite=False isinf=True   isnan=False
x=   nan  ceil=NA floor=NA trunc=NA fabs=nan       isfinite=False isinf=False  isnan=True
```

**要点提示**

- `ceil()` 与 `floor()` 分别向上、向下取整，返回值为 `int` 类型，输入可以是任意浮点；
- `trunc()` 直接截断小数部分（对负数向 0 方向截断）；
- `fabs()` 返回浮点的绝对值；相比内置 `abs()`，它对整数和浮点都返回浮点；
- `isfinite()`、`isinf()`、`isnan()` 用于对特殊浮点情况进行检测。

---

### 2. 幂运算与平方根

|                             |                                                               |
| --------------------------- | ------------------------------------------------------------- |
| 函数                          | 说明                                                            |
| `math.sqrt(x)`              | 平方根，返回 √x；x 必须 ≥ 0，否则抛出 `ValueError`<br><br>；                 |
| `math.pow(x, y)`            | 幂运算，返回 x**y（浮点形式）；推荐使用内置 `x**y`<br><br>或 `pow(x, y)`<br><br>； |
| `x**y`<br><br>/ `pow(x, y)` | Python 内置运算符/函数，支持整型幂运算（返回 `int`<br><br>）、浮点幂运算。              |
| `math.exp(x)`               | 指数函数 eˣ；                                                      |
| `math.expm1(x)`             | 返回 eˣ−1，避免 x 很小（如 0.000001）时直接计算 `exp(x)-1`<br><br>造成的浮点精度损失； |

示例：

```python
import math

# 平方根
print(math.sqrt(16))    # 4.0
# 当 x 为负数时会抛出异常
# math.sqrt(-1)  # ValueError: math domain error

# 幂运算
print(math.pow(2, 10))      # 1024.0
print(2**10, pow(2, 10))    # 1024 1024

# 指数函数
print(math.exp(1))          # 2.718281828459045 (~e)
print(math.exp(3))          # e^3 ≈ 20.085536923187668

# expm1 在 x 很小时更精确
x_small = 1e-6
print(math.exp(x_small) - 1)  # 1.0000005000000417e-06（误差较大）
print(math.expm1(x_small))    # 1.0000000000004998e-06（更精确）
```

**要点提示**

- 对于幂运算，若要精确处理大整数的幂，优先使用 `x**y` 或内置 `pow(x, y)`（对整型返回整型）；`math.pow()` 总是返回浮点，且对于大整数可能会丢失精度。
- `expm1(x)` 在 x 接近 0 时更能减少浮点舍入误差；在编写统计学或微分运算时尤其有用。

---

### 3. 对数函数

|   |   |
|---|---|
|函数|说明|
|`math.log(x[, base])`|自然对数 ln(x)；若给定 `base`<br><br>，则返回以该底的对数：log₍base₎(x)；|
|`math.log2(x)`|以 2 为底的对数 log₂(x)；|
|`math.log10(x)`|以 10 为底的对数 log₁₀(x)；|
|`math.log1p(x)`|返回 ln(1 + x)，当 x 很小时更精确；|

示例：

```python
import math

# 自然对数
print(math.log(math.e))    # 1.0
print(math.log(10))        # ln(10) ≈ 2.302585092994046

# 指定底
print(math.log(8, 2))      # 3.0  （log₂(8)）
print(math.log(100, 10))   # 2.0

# 专门函数
print(math.log2(16))       # 4.0
print(math.log10(100))     # 2.0

# log1p 在 x 很小时更精确
x_small = 1e-8
print(math.log(1 + x_small))  # 9.99999993922529e-09（精度有限）
print(math.log1p(x_small))    # 9.999999995e-09（更精确）
```

**要点提示**

- 在要处理概率、累积乘积、数值极小变化等场景时，`log1p(x)` 更能避免 `x` 极小时 `1 + x` 变成 1 导致损失精度。
- 如果需要计算对数密度或信息熵相关公式，优先选用 `log1p()` 或 `expm1()` 以获取更高精度。

---

### 4. 三角函数与角度变换

|   |   |
|---|---|
|函数|说明|
|`math.sin(x)`|正弦函数 sin(x)，x 以弧度（radians）为单位；|
|`math.cos(x)`|余弦函数 cos(x)，x 以弧度为单位；|
|`math.tan(x)`|正切函数 tan(x)，x 以弧度为单位；|
|`math.asin(x)`|反正弦 arcsin(x)，返回值在 [−π/2, π/2]；|
|`math.acos(x)`|反余弦 arccos(x)，返回值在 [0, π]；|
|`math.atan(x)`|反正切 arctan(x)，返回值在 [−π/2, π/2]；|
|`math.atan2(y, x)`|二元反正切 atan2(y, x)，返回坐标 (x, y) 对应的角度，值域 (−π, π]；|
|`math.degrees(x)`|将弧度转换为角度：x * (180/π)；|
|`math.radians(x)`|将角度转换为弧度：x * (π/180)；|
|`math.hypot(x, y)`|计算 √(x² + y²)，常用于二维或多维空间距离；|

示例：

```python
import math

angle_deg = 45
angle_rad = math.radians(angle_deg)  # 0.7853981633974483

# 三角函数
print(f"sin({angle_deg}°) = {math.sin(angle_rad)}")  # ≈ 0.7071067811865475
print(f"cos({angle_deg}°) = {math.cos(angle_rad)}")  # ≈ 0.7071067811865476
print(f"tan({angle_deg}°) = {math.tan(angle_rad)}")  # ≈ 0.9999999999999999

# 反三角函数（输入值在 [-1, 1]）
x = 0.5
print(f"arcsin({x}) = {math.degrees(math.asin(x))}°")  # ≈ 30°
print(f"arccos({x}) = {math.degrees(math.acos(x))}°")  # ≈ 60°
print(f"arctan({x}) = {math.degrees(math.atan(x))}°")  # ≈ 26.565°

# atan2 用于双参数反正切
y, x = 1, 1
print(math.atan2(y, x), math.degrees(math.atan2(y, x)))  # 0.785398..., 45°

# 计算 2D 或 N 维欧几里得距离
print(math.hypot(3, 4))      # 5.0
# Python 3.8+ 支持多维，例如 hypot(x, y, z)
print(math.hypot(1, 2, 2))   # √(1² + 2² + 2²) = 3.0
```

**要点提示**

- 所有三角函数的参数均以“弧度”输入，若使用“角度”可先调用 `radians()`；或结果需要“角度”时再调用 `degrees()`；
- `atan2(y, x)` 用于求( x, y )坐标对应的极角，可正确处理象限；
- `hypot()` 在底层做了防溢出/防下溢处理，比直接写 `math.sqrt(x*x + y*y)` 更稳健；

---

### 5. 双曲函数与反双曲函数

|   |   |
|---|---|
|函数|说明|
|`math.sinh(x)`|双曲正弦 sinh(x) = (eˣ − e⁻ˣ)/2；|
|`math.cosh(x)`|双曲余弦 cosh(x) = (eˣ + e⁻ˣ)/2；|
|`math.tanh(x)`|双曲正切 tanh(x) = sinh(x)/cosh(x)；|
|`math.asinh(x)`|反双曲正弦 arcsinh(x)；|
|`math.acosh(x)`|反双曲余弦 arccosh(x)，x ≥ 1；|
|`math.atanh(x)`|反双曲正切 arctanh(x)，|

示例：

```python
import math

x = 1.0
print(f"sinh({x}) = {math.sinh(x)}")   # ≈ 1.1752011936438014
print(f"cosh({x}) = {math.cosh(x)}")   # ≈ 1.5430806348152437
print(f"tanh({x}) = {math.tanh(x)}")   # ≈ 0.7615941559557649

# 反双曲函数
y = math.sinh(x)
print(f"asinh({y}) = {math.asinh(y)}")  # ≈ 1.0

z = math.cosh(x)
print(f"acosh({z}) = {math.acosh(z)}")  # ≈ 1.0

t = math.tanh(x)
print(f"atanh({t}) = {math.atanh(t)}")  # ≈ 1.0
```

**要点提示**

- 双曲函数常用于信号处理、统计学中的高斯函数、工程中的链线曲线等场景；
- `acosh(x)` 要求 x ≥ 1，`atanh(x)` 要求 |x| < 1，否则抛出 `ValueError`；

---

### 6. 特殊函数

1. **伽马函数与贝塔函数**

|   |   |
|---|---|
|函数|说明|
|`math.gamma(x)`|伽马函数 Γ(x)，对 x>0 等价于 (x−1)! ；|
|`math.lgamma(x)`|返回 ln|

示例：

```python
import math

# 伽马函数
print(math.gamma(5))    # Γ(5) = 4! = 24.0
print(math.gamma(0.5))  # Γ(0.5) = √π ≈ 1.7724538509055159

# 伽马函数对数
print(math.lgamma(5))   # ln(24) ≈ 3.1780538303479458
print(math.lgamma(0.5)) # ln(√π) ≈ 0.5723649429247001
```

2. **组合数学（阶乘、组合数、排列数）**

|   |   |
|---|---|
|函数|说明|
|`math.factorial(n)`|阶乘 n!，n 必须是非负整数，否则抛出 `ValueError`<br><br>；|
|`math.comb(n, k)`|组合数 C(n, k) = n! / (k!(n−k)!)，Python 3.8+ 引入；|
|`math.perm(n, k=None)`|排列数 P(n, k) = n! / (n−k)!；若 k 省略则返回 n!；|

示例：

```python
import math

# 阶乘
print(math.factorial(5))   # 120
# 如果输入为负数或非整数，则抛出 ValueError
# math.factorial(-1)      # ValueError

# 组合数
print(math.comb(10, 3))    # C(10,3) = 120
print(math.comb(5, 0))     # 1
print(math.comb(5, 5))     # 1

# 排列数
print(math.perm(5, 2))     # P(5,2) = 5 * 4 = 20
print(math.perm(5))        # 默认 k=None，等于 factorial(5) = 120
```

3. **最大公约数与最小公倍数**

|   |   |
|---|---|
|函数|说明|
|`math.gcd(a, b[, *args])`|返回多个整数的最大公约数（Greatest Common Divisor）；|
|`math.lcm(a, b[, *args])`|返回多个整数的最小公倍数（Least Common Multiple），Python 3.9+ 引入；|

示例：

```python
import math

print(math.gcd(12, 18))       # 6
print(math.gcd(12, 18, 24))   # 6

print(math.lcm(4, 6))         # 12
print(math.lcm(4, 6, 10))     # 60
```

4. **浮点数分解与重构**

|   |   |
|---|---|
|函数|说明|
|`math.frexp(x)`|将浮点数 x 分解为 (m, e)，满足 x = m * 2**e，且 0.5 ≤|
|`math.ldexp(m, e)`|与 `frexp()`<br><br>反向，将 m * 2**e 重构为浮点数；|
|`math.modf(x)`|返回 (frac, intpart)，x 的小数部分与整数部分（均为浮点）；|

示例：

```python
import math

# frexp 与 ldexp
x = 20.5
m, e = math.frexp(x)
print(m, e)            # m ≈ 0.640625, e = 5，因为 0.640625 * 2**5 = 20.5
print(math.ldexp(m, e))  # 恢复为 20.5

# modf
frac, integer = math.modf(3.14159)
print(frac, integer)  # 0.14159000000000012  3.0
```

5. **符号与舍入**

|   |   |
|---|---|
|函数|说明|
|`math.copysign(x, y)`|返回带有 y 符号的 x 的绝对值，如 `copysign(3, -2)`<br><br>→ -3.0；|
|`math.fmod(x, y)`|浮点数取模，返回 x − n * y，其中 n 是最靠近 x / y 且与 x / y 同号的整数；|
|`math.remainder(x, y)`|IEEE 754 风格的余数，返回最接近 x / y 的整数 n 后余数：x − n * y；Python 3.7+；|

示例：

```python
import math

print(math.copysign(3, -2))  # -3.0
print(math.copysign(-3, 2))  # 3.0

# fmod 与 Python 内置 % 可能有所不同
print(math.fmod(8.3, 2.1))   # 8.3 - 3*2.1 = 2.0
print(8.3 % 2.1)             # 2.0（对于正数，两者相同）

# remainder
print(math.remainder(8.3, 2.1))  # 8.3 - 4*2.1 = 0.0
print(math.remainder(7.5, 2))    # 7.5 - 4*2 = -0.5，因为 4 是最接近 3.75 的整数
```

**要点提示**

- `frexp()` / `ldexp()` 用于底层浮点操作、二进制拆解与精度控制；
- `modf()` 便捷地将浮点拆成整数与小数；
- `copysign()` 在处理物理量时经常用来保留符号、改变数值；
- `fmod()` 与 `%` 表现相似，但对负数符号处理不同；一般建议用 `%` 做日常取模，若需要 IEEE 754 精确语义可用 `remainder()`（Python 3.7+）。

---

### 7. 累积求和与数值精度

|   |   |
|---|---|
|函数|说明|
|`math.fsum(iterable)`|精确累积求和，避免普通浮点求和的舍入误差。|

示例：

```python
import math

# 普通内置 sum 可能累积误差
values = [0.1] * 10  # 理论和为 1.0
print(sum(values))   # 0.9999999999999999

# fsum 可以更精确
print(math.fsum(values))  # 1.0
```

**要点提示**

- 对于包含大量浮点相加的场景，使用 `fsum()` 可显著减小舍入误差；
- `fsum()` 内部使用“分块求和”算法（类似 Kahan 求和），比简单累加更稳健；

---

## 四、使用示例集锦

下面通过整合上述函数，举几个常见应用场景的示例。

### 1. 统计学中的正态分布概率密度函数（PDF）

正态分布 PDF：

f(x)=1σ2πexp⁡(−(x−μ)22σ2)f(x) = \frac{1}{\sigma \sqrt{2\pi}} \exp\Bigl(-\,\frac{(x-\mu)^2}{2\sigma^2}\Bigr)f(x)=σ2π1exp(−2σ2(x−μ)2)

```python
import math

def normal_pdf(x, mu=0.0, sigma=1.0):
    coeff = 1.0 / (sigma * math.sqrt(2 * math.pi))
    exponent = -((x - mu) ** 2) / (2 * sigma * sigma)
    return coeff * math.exp(exponent)

# 测试
for x in (-2, -1, 0, 1, 2):
    print(f"x={x}: PDF={normal_pdf(x, mu=0, sigma=1)}")
```

### 2. 计算多边形顶点坐标中心至各顶点的最远距离

假设一个多边形由一系列坐标点 `(x_i, y_i)` 给定，计算其几何中心（centroid）与所有顶点之间的最远欧氏距离。

```python
import math

points = [(0,0), (4,0), (4,3), (0,3)]  # 矩形 4×3
# 1. 先计算几何中心
cx = sum(x for x, _ in points) / len(points)
cy = sum(y for _, y in points) / len(points)

# 2. 用 hypot 计算到各点的距离
distances = [math.hypot(x - cx, y - cy) for x, y in points]
max_dist = max(distances)

print(f"Center = ({cx:.2f}, {cy:.2f}), max distance = {max_dist:.2f}")
```

### 3. 大整数阶乘与组合数计算

```python
import math

n = 50
k = 5

# 50! 相当大，用 factorial
fact_50 = math.factorial(n)
print(f"50! = {fact_50}")

# 组合数 C(50, 5)
comb_50_5 = math.comb(n, k)
print(f"C(50, 5) = {comb_50_5}")
```

### 4. 二进制浮点拆分与重构

```python
import math

x = 123.456
mantissa, exponent = math.frexp(x)
print("frexp:", mantissa, exponent)
# 验证使用 ldexp 恢复
restored = math.ldexp(mantissa, exponent)
print("restored:", restored)

# 再演示 modf
fractional, integer = math.modf(x)
print("modf:", fractional, integer)
```

---

## 五、注意事项与最佳实践

1. **浮点精度与舍入误差**

- 由于 IEEE-754 规范，某些十进制数无法精确表示为二进制浮点。尽量使用 `math.fsum()` 累加、`math.expm1()`、`math.log1p()` 等“误差更小”的函数。
- 对于数值比较，避免直接使用 `==`，可用 `math.isclose(a, b, rel_tol=..., abs_tol=...)` 判断近似相等。

2. **整数与浮点混用**

- `math.factorial()`、`math.comb()`、`math.perm()` 等接受并返回整型。其他大多数函数都返回浮点，输入即使是整数也会先转换为浮点再运算。注意可能的类型变化。
- 在需要整数精度时，避免用 `math.pow()`，因为它返回浮点。直接用 `**` 或 `pow()`。

3. **输入范围与异常**

- 大多数函数如果输入不在定义域，会抛出 `ValueError: math domain error`。例如 `math.sqrt(-1)`、`math.log(-5)`、`math.acos(2)` 等。处理前要先用 `math.isfinite(x)`、比较大小等方法进行校验。
- 当输入非常大时，某些函数可能会返回 `inf` 或 `OverflowError`。例如 `math.exp(1000)` 会直接返回 `inf`（并可能伴随警告）。可提前判断输入范围或使用 `math.isfinite()` 做保护。

4. **三角函数精度**

- 使用三角函数时先将度数转换为弧度，避免使用近似转换写死系数。
- 对于要求高精度循环三角计算，可使用 `math.sin(x)`、`math.cos(x)` 的多次叠加会累积误差；在高精度数值方法中可用“差分”或“Cordic 算法”实现。

5. **组合数学的大数计算**

- `factorial(n)` 对 n 较大时会产生巨大的整数，占用大量内存与时间；可在需要概率密度或对数概率时使用 `math.lgamma()` 或 `math.log()`/`math.comb()` 的组合搭配来避免超大整数。
- 例如要计算概率 `C(n, k) * p^k * (1−p)^(n−k)`，更稳健的写法是用 `math.comb()` 与浮点指数，而不是先算 `factorial()`。

6. **尽量使用标准库函数**

- 遇到累加、对数、指数、阶乘等常见需求时，优先考虑 `math` 中对应函数，不要手动实现循环或近似算法。这样既能提高可读性，又能利用底层 C 实现获得更高性能与精度。

---

## 六、总结

- `**math**` **模块** 是 Python 中进行数值计算、科学计算时最基础的工具，涵盖了从基础的算术、幂与对数、三角与双曲函数，到组合数学、浮点数拆分与重构、数值精度累加等内容。
- 本文系统地梳理了：

1. **核心常量**：π、e、τ、inf、nan；
2. **基本算术与数值测试**：`ceil()`、`floor()`、`trunc()`、`fabs()`、`isfinite()`、`isinf()`、`isnan()`；
3. **幂运算与平方根**：`sqrt()`、`exp()`、`pow()`、`expm1()`；
4. **对数系列**：`log()`、`log2()`、`log10()`、`log1p()`；
5. **三角函数与角度转换**：`sin()`、`cos()`、`tan()`、`asin()`、`acos()`、`atan()`、`atan2()`、`hypot()`、`degrees()`、`radians()`；
6. **双曲与反双曲**：`sinh()`、`cosh()`、`tanh()`、`asinh()`、`acosh()`、`atanh()`；
7. **特殊函数**：`gamma()`、`lgamma()`、`factorial()`、`comb()`、`perm()`、`gcd()`、`lcm()`；
8. **浮点数分解与重构**：`frexp()`、`ldexp()`、`modf()`；
9. **符号与取模**：`copysign()`、`fmod()`、`remainder()`；
10. **数值累加**：`fsum()`；
11. **使用示例**：概率密度、欧氏距离、多边形几何中心、大整数阶乘与组合、浮点拆分、数值精度演示。

- **最佳实践要点**：

1. 对于需要高精度浮点累加，使用 `fsum()`；
2. 避免直接用浮点做 `exp(x) - 1` 或 `log(1 + x)`，使用 `expm1()` 与 `log1p()`；
3. 幂运算优先用 `**` 或 `pow()` 而非 `math.pow()`；
4. 组合数学函数适合大整数情形，但要注意避免溢出；可用 `lgamma()` 计算对数形式。
5. 三角函数参数一律以“弧度”为单位；如需“角度”，用 `radians()`/`degrees()` 辅助转换；
6. 取模时若需要 IEEE 754 语义，用 `remainder()`；否则一般用 `%`。

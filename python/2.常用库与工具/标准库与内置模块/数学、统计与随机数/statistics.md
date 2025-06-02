## 1. statistics 模块概述

- `statistics` 模块自 Python 3.4 起成为标准库，用于执行基本的统计学运算。
- 主要针对一维数据样本（sequence 或 iterable），提供“描述性统计”与“部分推断统计”功能，涵盖：

- 各种均值（算术均值、几何均值、调和均值）
- 中位数与众数
- 方差、标准差（包括总体与样本之分）
- 分位数（quantiles）、四分位数（quartiles）
- 协方差与相关系数
- 线性回归估计（`linear_regression`）
- 基于正态分布的 `NormalDist` 类

- 几乎所有函数都接受 **可迭代对象**（`iterable`）作为输入，也可以直接传入一系列数值参数。
- 若数据不符合预期，或运算失败，会抛出 `StatisticsError` 异常，需要用 `try…except` 捕获。

---

## 2. 均值（Mean）相关函数

### 2.1 算术均值：`mean(data)`

```python
import statistics

data = [10, 20, 30, 40]
print(statistics.mean(data))  # 输出 25
```

- **定义**：把所有数值相加后除以样本数量。
- **参数**：`data` 可以是任意可迭代的数值序列（列表、元组、生成器等），或直接传入一系列数：

```python
statistics.mean(1, 2, 3, 4)  # 允许这种写法，结果为 2.5
```

- 如果输入为空序列，会抛出 `StatisticsError: mean requires at least one data point`。

### 2.2 几何均值：`geometric_mean(data)`

```python
import statistics

data = [1, 4, 9, 16]
print(statistics.geometric_mean(data))  # 输出 4.0（即 (1*4*9*16)**(1/4) ）
```

- **定义**：将所有数值连乘后开 n 次方（n 为样本数量）。
- **用途**：常用于增长率、投资收益率等需要使用“乘积”指标的场景。
- 如果序列中出现非正数（如 0 或负数），会抛出 `StatisticsError`。

### 2.3 调和均值：`harmonic_mean(data)`

```python
import statistics

data = [2, 4, 4]
print(statistics.harmonic_mean(data))  # 输出 3.2（即 3 / (1/2 + 1/4 + 1/4) ）
```

- **定义**：调和均值 = 样本数 ÷（各数倒数之和）。
- **用途**：常用于计算速率（如平均速度、单位成本等）。
- 如果序列中包含 0 或负值，会抛出 `StatisticsError`。

---

## 3. 中位数（Median）与众数（Mode）

### 3.1 中位数：`median(data)`

```python
import statistics

data1 = [1, 3, 5]
data2 = [1, 3, 5, 7]

print(statistics.median(data1))  # 输出 3
print(statistics.median(data2))  # 输出 (3 + 5) / 2 = 4.0
```

- **定义**：将数据从小到大排序后，取中间位置的值；若元素个数为偶数，则取“中间两个数的平均”。
- **输入**：可迭代对象；可以直接传入数字序列。
- 如果输入为空序列，会抛出 `StatisticsError: no median for empty data`。

### 3.2 中位数变体：`median_low(data)` 与 `median_high(data)`

- 当数据长度为偶数时：

- `median_low` 返回排序后靠左那个中位数（较小值）。
- `median_high` 返回排序后靠右那个中位数（较大值）。

- 例如：

```python
import statistics

data = [1, 3, 5, 7]
print(statistics.median_low(data))   # 输出 3
print(statistics.median_high(data))  # 输出 5
```

### 3.3 四分位数：`median_grouped(data, interval=1)`

- **用途**：当数据被分组到等长区间（组距）中时，按“插值法”估算中位数。
- **参数**：

- `data`：可迭代对象，最小长度应 ≥ 3；
- `interval`：分组宽度（默认为 1）。

- **注意**：真实应用中多用于频数分布表，而非直接对原始数据使用。

### 3.4 众数：`mode(data)`

```python
import statistics

data = [1, 2, 2, 3, 3, 3, 4]
print(statistics.mode(data))  # 输出 3，因为 3 出现次数最多
```

- **定义**：返回出现频率最高的那个元素。
- **限制**：

- 如果有多个值并列最高，会抛出 `StatisticsError: no unique mode; found 2 equally common values`。
- 如果序列为空，也会抛出 `StatisticsError`。

- 如果希望同时获取所有众数，可以使用 `multimode(data)`，它会返回一个列表，包含所有并列最高频率的元素。例如：

```python
import statistics

data = [1, 2, 2, 3, 3]
print(statistics.multimode(data))  # 输出 [2, 3]
```

---

## 4. 变异性（Variance）与标准差（Standard Deviation）

注意：`statistics` 模块区分“总体（population）”与“样本（sample）”的计算公式。总体和样本在分母上有所不同。

### 4.1 总体方差与标准差

- **总体方差（Population Variance）**：

```python
statistics.pvariance(data)
```

定义为：

σ2=1N∑i=1N(xi−μ)2 \sigma^2 = \frac{1}{N} \sum_{i=1}^N (x_i - \mu)^2σ2=N1i=1∑N(xi−μ)2

其中 μ=\mu =μ= 总体均值，NNN 为总体大小（样本个数）。

- **总体标准差（Population Standard Deviation）**：

```python
statistics.pstdev(data)
```

定义为总体方差的平方根：

σ=σ2 \sigma = \sqrt{\sigma^2}σ=σ2

- 示例：

```python
import statistics

data = [10, 20, 30, 40]
print(statistics.pvariance(data))  # 输出 125.0
print(statistics.pstdev(data))     # 输出 11.180339887498949
```

### 4.2 样本方差与标准差

- **样本方差（Sample Variance）**：

```python
statistics.variance(data)
```

定义为：

s2=1n−1∑i=1n(xi−xˉ)2 s^2 = \frac{1}{n-1} \sum_{i=1}^n (x_i - \bar x)^2s2=n−11i=1∑n(xi−xˉ)2

其中 xˉ\bar xxˉ 为样本均值，nnn 为样本大小。注意分母是 n−1n-1n−1。

- **样本标准差（Sample Standard Deviation）**：

```python
statistics.stdev(data)
```

定义为样本方差的平方根：

s=s2 s = \sqrt{s^2}s=s2

- 示例：

```python
import statistics

data = [10, 20, 30, 40]
print(statistics.variance(data))  # 输出 166.66666666666666
print(statistics.stdev(data))     # 输出 12.909944487358056
```

- 注意：当样本长度 `len(data)` < 2 时，`variance`/`stdev` 会抛出 `StatisticsError: variance requires at least two data points`。

---

## 5. 分位数（Quantiles）与四分位数（Quartiles）

### 5.1 分位数：`quantiles(data, n=4, method='exclusive')`

- **功能**：将数据按照指定分位（`n`）切分，返回切分点的列表（不包含最小值和最大值）。
- **参数解释**：

- `data`：可迭代数值序列。
- `n`：将数据分成 `n` 等份（默认 `n=4`，即四分位）。
- `method`：插值方法，可选：

- `'exclusive'`（默认）：适用于较大样本，参考统计学上的 PERCENTILE.EXC 方法。
- `'inclusive'`：与 PERCENTILE.INC 方法对应。
- `'nearest'`、`'high'`、`'low'`、`'midpoint'`：不同插值策略，详见官方文档。

- **返回值**：

- 长度为 `n-1` 的列表，依次是第 1/ n 分位数、第 2/ n 分位数（中位数）、…、第 (n−1)/ n 分位数。

- 示例：计算四分位（`n=4`）：

```python
import statistics

data = [1, 2, 3, 4, 5, 6, 7, 8]
q = statistics.quantiles(data, n=4, method='inclusive')
print(q)  # 输出 [2.75, 4.5, 6.25]，分别对应第 25%、50%、75% 分位数。
```

### 5.2 特殊函数：`quantiles(data, n=4)` 等同于计算四分位数；如果只需要某几个分位，可以用 `method='nearest'` 再自行索引。

---

## 6. 协方差（Covariance）与相关系数（Correlation Coefficient）

### 6.1 协方差：`covariance(x, y)`

```python
import statistics

x = [1, 2, 3, 4]
y = [2, 4, 6, 8]
print(statistics.covariance(x, y))  # 输出 1.6666666666666667
```

**定义**：  
对于两个同样长度为 n 的样本集合 {xi}\{x_i\}{xi} 与 {yi}\{y_i\}{yi}，

- cov(x,y)=1n−1∑i=1n(xi−xˉ)(yi−yˉ) \mathrm{cov}(x, y) = \frac{1}{n-1} \sum_{i=1}^n (x_i - \bar x)(y_i - \bar y)cov(x,y)=n−11i=1∑n(xi−xˉ)(yi−yˉ)

- 分母使用 `n-1`，即样本协方差。

- **限制**：当 `len(x)` < 2 或者 `len(x) != len(y)` 时，会抛出 `StatisticsError`。

### 6.2 相关系数：`correlation(x, y)`

```python
import statistics

x = [1, 2, 3, 4]
y = [2, 4, 6, 8]
print(statistics.correlation(x, y))  # 输出 1.0（完全正相关）
```

**定义**：

- r=cov(x,y)sx⋅sy r = \frac{\mathrm{cov}(x,y)}{s_x \cdot s_y}r=sx⋅sycov(x,y)

其中 sxs_xsx、sys_ysy 分别为样本 x、y 的标准差。

- **取值范围**：−1≤r≤1-1 \le r \le 1−1≤r≤1。
- **限制**：当某个序列的标准差为 0（即所有元素相等）时，会抛出 `StatisticsError`。

---

## 7. 其他实用函数

### 7.1 线性回归（简单线性拟合）：`linear_regression(x, y)`

```python
import statistics

x = [1, 2, 3, 4]
y = [2, 3, 5, 7]
slope, intercept = statistics.linear_regression(x, y)
print(slope, intercept)  # 例如会输出 1.7 -1.5，表示 y ≈ 1.7 x - 1.5
```

- **功能**：对给定的点集 `(x_i, y_i)` 进行最小二乘法线性拟合，返回 `(slope, intercept)`。

**内部实现**：与 `covariance`、`stdev` 等配合，计算方式：

- slope=∑(xi−xˉ)(yi−yˉ)∑(xi−xˉ)2 \text{slope} = \frac{\sum (x_i - \bar x)(y_i - \bar y)}{\sum (x_i - \bar x)^2}slope=∑(xi−xˉ)2∑(xi−xˉ)(yi−yˉ)intercept=yˉ−slope×xˉ \text{intercept} = \bar y - \text{slope} \times \bar xintercept=yˉ−slope×xˉ
- **限制**：`x`、`y` 长度需相同且 ≥ 2，否则抛出 `StatisticsError` 或 `ValueError`。

### 7.2 正态分布工具：`NormalDist`

```python
from statistics import NormalDist

# 构造一个标准正态分布
nd = NormalDist(mu=0, sigma=1)

# 计算在 x=1.96 时的累积分布函数值（约 0.975）
print(nd.cdf(1.96))  

# 计算概率密度函数值
print(nd.pdf(0))    # 在 x=0 处为 ~0.3989

# 两个正态分布的距离（Wasserstein 距离）
nd2 = NormalDist(mu=1, sigma=2)
print(nd.dist(normdist2))
```

- `NormalDist(mu, sigma)` 创建一个正态分布实例。
- **常用方法**：

- `cdf(x)`：计算累积分布函数 P(X≤x)P(X \le x)P(X≤x)。
- `pdf(x)`：概率密度函数值。
- `inv_cdf(p)`：给定概率 ppp，返回对应的分位点 xxx。
- `dist(other)`：与另一个 `NormalDist` 实例计算 Wasserstein 距离（或 2-范数距离）。

- 如果 `sigma <= 0`，会抛出 `StatisticsError`。

### 7.3 对样本集中最大/最小值位置做插值：`mode()` 已在第 3 节介绍，`multimode()` 同样已说明。

---

## 8. 异常类型与注意事项

### 8.1 `StatisticsError`

- `statistics` 模块中，所有输入不符合要求时都会抛出 `statistics.StatisticsError`。
- 常见触发场景：

- 计算均值时传入空序列。
- 计算 `variance` 或 `stdev` 时样本数量 < 2。
- 计算 `mode` 时没有唯一众数。
- 输入中存在无法转换为数字的元素（如传入字符串）。
- `geometric_mean` / `harmonic_mean` 中含非正数。
- `covariance` / `correlation` 时两组数据长度不同或长度 < 2。
- `linear_regression` 时两组数据长度不同或长度 < 2。
- `NormalDist` 构造时 `sigma <= 0`。

### 8.2 总体 vs 样本

- **总体（Population）**：当你认为手头的整个数据集就是整体时，使用 `pvariance`、`pstdev`。
- **样本（Sample）**：当你认为手头的数据是从更大总体中抽样得到时，使用 `variance`、`stdev`。
- 公式上的区别在于分母：总体使用 NNN，样本使用 n−1n-1n−1。

### 8.3 数据类型与精度

- 如果输入序列中包含整数和浮点数，输出结果类型通常为浮点数。
- 当数值非常大或方差计算时，可能出现浮点舍入误差，需要酌情使用高精度算术库或先做中心化（`xi - mean`）。

---

## 9. 综合示例

下面给出一个包含多种 `statistics` 功能的综合示例，演示从数据生成、描述性统计到基本推断统计的完整流程。

```python
import statistics
from statistics import NormalDist

# 假设有一组学生考试成绩
scores = [88, 92, 79, 93, 85, 90, 78, 94, 88, 91]

# 1. 描述性统计：均值、中位数、众数
mean_score = statistics.mean(scores)
median_score = statistics.median(scores)
try:
    mode_score = statistics.mode(scores)
except statistics.StatisticsError:
    mode_score = statistics.multimode(scores)  # 多众数情形

print("均值（Mean）：", mean_score)
print("中位数（Median）：", median_score)
print("众数（Mode）：", mode_score)

# 2. 变异性测量：总体与样本方差、标准差
pop_var = statistics.pvariance(scores)
pop_std = statistics.pstdev(scores)
samp_var = statistics.variance(scores)
samp_std = statistics.stdev(scores)

print(f"总体方差（pvariance）：{pop_var:.2f}")
print(f"总体标准差（pstdev）：{pop_std:.2f}")
print(f"样本方差（variance）：{samp_var:.2f}")
print(f"样本标准差（stdev）：{samp_std:.2f}")

# 3. 分位数计算：四分位数
q1, q2, q3 = statistics.quantiles(scores, n=4, method='inclusive')
print("25% 分位数：", q1)
print("50% 分位数（中位数）：", q2)
print("75% 分位数：", q3)

# 4. 协方差与相关系数
# 假设有另一组自习时长（小时）数据，与成绩作相关性分析
hours = [2, 3, 1.5, 3.5, 2.5, 3, 1, 4, 2.5, 3]

cov = statistics.covariance(scores, hours)
corr = statistics.correlation(scores, hours)
print(f"成绩与自习时长的协方差：{cov:.2f}")
print(f"成绩与自习时长的相关系数：{corr:.2f}")

# 5. 线性回归：拟合成绩与自习时长的关系
slope, intercept = statistics.linear_regression(hours, scores)
print(f"拟合直线：score = {slope:.2f} * hours + {intercept:.2f}")

# 6. 假设成绩近似正态分布，用 NormalDist 估算概率
# 以样本均值和样本标准差近似总体分布
nd = NormalDist(mu=mean_score, sigma=samp_std)
# 估算某位学生得分 ≥ 95 的概率
p_above_95 = 1 - nd.cdf(95)
print(f"得分 ≥ 95 的近似概率：{p_above_95:.4f}")

# 7. 几何与调和均值示例
rates = [1.05, 1.02, 1.03, 1.07]  # 假设 4 年的复合增长率
print("几何均值（年度复合增长率平均）：",
      statistics.geometric_mean(rates))

speeds = [60, 80, 100]  # 3 段旅程速度
print("调和均值（总平均速度）：",
      statistics.harmonic_mean(speeds))
```

**解释：**

1. **均值/中位数/众数**：快速了解成绩分布的中心趋势。
2. **总体 vs 样本 方差/标准差**：如果认为这 10 个数据就是全体学生成绩，就用总体；若认为这是大群体的样本，就用样本。
3. **分位数**：四分位数可以看出成绩的分布情况（下四分位、中位、上四分位）。
4. **协方差 & 相关系数**：分析成绩与自习时长之间是否存在线性关系。
5. **线性回归**：进一步得到“每增加 1 小时自习，成绩大致上升多少点”。
6. **NormalDist**：假设成绩近似正态分布，可估算极端值出现的概率。
7. **几何 & 调和均值**：分别用于计算复合增长率和平均速度。

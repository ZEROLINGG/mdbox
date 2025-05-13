# Lambda 表达式与高阶函数

在 Python 编程中，Lambda 表达式与高阶函数是函数式编程（Functional Programming）的核心组成部分。它们可以使代码更加简洁、灵活，尤其适用于将函数作为参数或返回值的场景，如数据处理、回调函数、事件驱动等。

---

## 一、Lambda 表达式

### 1. 概念

Lambda 是 Python 提供的一种**匿名函数**的语法形式，也称为 Lambda 表达式。用于创建临时的、简洁的函数对象，通常在不需要重复使用函数名的情况下使用。

### 2. 基本语法

```
lambda 参数1, 参数2, ... : 表达式
```

等价于：

```
def 函数名(参数1, 参数2, ...):
    return 表达式
```

### 3. 示例

```
# 普通函数
def add(x, y):
    return x + y

# Lambda 表达式
add_lambda = lambda x, y: x + y

print(add(3, 4))         # 输出 7
print(add_lambda(3, 4))  # 输出 7
```

### 4. 使用场景

Lambda 表达式通常用于**临时使用函数**且不需要命名的场合，包括但不限于：

- 与高阶函数（如 `map()`、`filter()`、`sorted()` 等）结合使用；
- GUI 编程中的事件回调；
- 某些简洁的函数计算逻辑，嵌入表达式内部。

---

## 二、高阶函数（Higher-Order Function）

### 1. 概念

高阶函数是指**接收函数作为参数**，或**返回函数作为结果**的函数。它使函数在程序中成为“一级公民”，提高代码的抽象能力和复用性。

Python 中常用的高阶函数包括：

- `map()`
- `filter()`
- `reduce()`（需导入 `functools` 模块）
- `sorted()`（通过 `key` 参数指定排序依据）

---

### 2. 常见高阶函数详解

#### 2.1 `map(func, iterable)`

对可迭代对象的每个元素执行 `func` 操作，并返回一个新的迭代器。

```
nums = [1, 2, 3, 4]
squared = list(map(lambda x: x**2, nums))
print(squared)  # 输出 [1, 4, 9, 16]
```

#### 2.2 `filter(func, iterable)`

对可迭代对象进行过滤，仅保留 `func` 返回 `True` 的元素。

```
nums = [1, 2, 3, 4, 5]
even = list(filter(lambda x: x % 2 == 0, nums))
print(even)  # 输出 [2, 4]
```

#### 2.3 `reduce(func, iterable)`

对 `iterable` 中的元素进行累积操作。使用前需导入 `functools` 模块。

```
from functools import reduce

nums = [1, 2, 3, 4]
product = reduce(lambda x, y: x * y, nums)
print(product)  # 输出 24（即 1*2*3*4）
```

#### 2.4 `sorted(iterable, key=func, reverse=False)`

对序列进行排序。可通过 `key` 指定排序依据，通过 `reverse` 指定是否反转排序结果。

```
data = ['abc', 'a', 'abcd']
sorted_data = sorted(data, key=lambda x: len(x))
print(sorted_data)  # 输出 ['a', 'abc', 'abcd']
```

---

## 三、Lambda 与高阶函数结合示例

以下示例展示了如何结合使用 Lambda 表达式与高阶函数来进行数据排序：

```
students = [
    {'name': 'Alice', 'score': 88},
    {'name': 'Bob', 'score': 95},
    {'name': 'Charlie', 'score': 70}
]

# 按成绩从高到低排序
sorted_students = sorted(students, key=lambda s: s['score'], reverse=True)

for s in sorted_students:
    print(s['name'], s['score'])
```

**输出：**

```
Bob 95  
Alice 88  
Charlie 70
```

---

## 四、小结

|   |   |   |
|---|---|---|
|术语|含义|典型用途|
|Lambda 表达式|一种用于定义匿名函数的简洁语法方式|临时函数、函数式编程|
|高阶函数|接收函数作为参数或返回值的函数|map/filter/reduce/sorted 等操作|

Lambda 表达式与高阶函数在数据处理、快速原型开发、事件驱动编程中均有广泛应用，是 Python 编程人员应掌握的重要技能。
# `sys` 模块详解笔记

`sys` 模块是 Python 标准库中的一个核心模块，提供了与 Python 解释器密切相关的一些变量和函数。主要用于访问和操作 Python 运行时环境的底层信息，例如命令行参数、模块搜索路径、解释器版本、标准流重定向等。

---

## 一、基本导入方式

```python
import sys
```

---

## 二、常用属性与函数详解

### 1. `sys.argv`：命令行参数列表

- 类型：`list`
- 描述：包含执行 Python 脚本时传入的命令行参数。
- `sys.argv[0]` 通常是脚本文件名，后续为实际参数。

**示例**：

```python
# 运行命令：python script.py arg1 arg2
import sys
print(sys.argv)  # 输出：['script.py', 'arg1', 'arg2']
```

---

### 2. `sys.exit([arg])`：退出程序

- 用于中止当前程序的执行。
- `arg` 可为整数（表示状态码）或字符串（会打印到 stderr）。

- `0` 表示正常退出；
- 非零表示异常退出。

**示例**：

```python
import sys
sys.exit(0)  # 正常退出
# sys.exit("发生错误")  # 异常退出并输出错误信息
```

---

### 3. `sys.path`：模块搜索路径列表

- 类型：`list`
- 描述：Python 导入模块时搜索的路径列表。
- 可动态添加自定义模块路径，支持运行时扩展。

**示例**：

```python
import sys
print(sys.path)  # 输出当前模块查找路径列表
sys.path.append('/my/custom/path')  # 添加自定义路径
```

---

### 4. `sys.platform`：当前平台标识符

- 类型：`str`
- 描述：用于判断操作系统类型，常用于跨平台代码中。

**常见值**：

- `'win32'`：Windows
- `'linux'`：Linux
- `'darwin'`：macOS

**示例**：

```python
import sys
print(sys.platform)
```

---

### 5. `sys.version` / `sys.version_info`：Python 版本信息

- `sys.version`：返回完整版本字符串（含构建信息）。
- `sys.version_info`：返回结构化版本元组，可用于条件判断。

**示例**：

```python
import sys
print(sys.version)         # 例如：'3.10.12 (tags/v3.10.12:...)'
print(sys.version_info)    # 例如：(3, 10, 12, 'final', 0)
```

---

### 6. `sys.stdin` / `sys.stdout` / `sys.stderr`：标准输入输出流

- 描述：表示标准输入、标准输出和标准错误输出流，支持重定向或替换。
- 常用于命令行交互、日志输出捕获等场景。

**示例**：

```python
import sys
sys.stdout.write("Hello\n")  # 输出到标准输出
data = sys.stdin.readline()  # 从标准输入读取一行
```

---

### 7. `sys.modules`：已加载模块字典

- 类型：`dict`
- 描述：当前已导入模块的缓存，键为模块名，值为模块对象。
- 可用于动态模块管理，如替换、卸载模块。

**示例**：

```python
import sys
print(list(sys.modules.keys()))  # 打印当前加载的模块名列表
```

---

### 8. `sys.getsizeof(obj)`：获取对象内存占用大小

- 类型：`function`
- 描述：返回对象在内存中的字节大小（包括基本开销）。

**示例**：

```python
import sys
print(sys.getsizeof("hello"))  # 输出字符串占用的内存大小
```

---

### 9. `sys.maxsize`：整数支持的最大值

- 描述：表示 Python `int` 类型支持的最大值，间接反映平台位数。
- 在 64 位系统上，通常为 `2**63 - 1`。

**示例**：

```python
import sys
print(sys.maxsize)
```

---

### 10. `sys.executable`：Python 解释器路径

- 描述：返回当前正在运行的 Python 解释器的完整路径。

**示例**：

```python
import sys
print(sys.executable)
```

---

### 11. `sys.getrecursionlimit()` / `sys.setrecursionlimit(limit)`：获取/设置递归深度

- Python 默认递归限制约为 1000 层。
- 设置过高可能导致栈溢出，应谨慎使用。

**示例**：

```python
import sys
print(sys.getrecursionlimit())  # 输出当前最大递归深度
sys.setrecursionlimit(2000)     # 设置新的递归深度上限
```

---

## 三、典型使用场景汇总

|   |   |
|---|---|
|功能需求|对应 `sys`<br><br>成员|
|命令行参数处理|`sys.argv`|
|程序终止控制|`sys.exit()`|
|动态模块路径管理|`sys.path`|
|操作系统判断|`sys.platform`|
|版本信息获取|`sys.version`<br><br>, `sys.version_info`|
|内存使用分析|`sys.getsizeof()`|
|输入输出流控制|`sys.stdin`<br><br>/ `sys.stdout`<br><br>/ `sys.stderr`|
|模块缓存管理|`sys.modules`|
|获取最大整数值|`sys.maxsize`|
|获取解释器路径|`sys.executable`|
|控制递归深度|`sys.setrecursionlimit()`|

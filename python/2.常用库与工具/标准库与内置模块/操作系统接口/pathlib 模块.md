# `pathlib` 模块详解（Python 3.4+）

`pathlib` 是 Python 3.4 引入的标准库模块，提供了面向对象的文件系统路径操作方式，是对传统 `os.path` 模块的现代替代。其主要优势包括：

- 更直观的路径拼接方式（使用 `/` 运算符）；
- 更高的可读性与可维护性；
- 跨平台兼容性（自动适配 Windows 和 POSIX）；
- 丰富的 API 支持常见的文件与目录操作。

---

## 一、基本概念与核心类

### 1. `pathlib.Path` 类（或 `PosixPath` / `WindowsPath`）

- `Path` 是 `pathlib` 模块的核心类，实际在不同平台上会返回 `PosixPath`（Unix-like 系统）或 `WindowsPath`（Windows 系统）的实例；
- `Path` 对象可表示文件路径或目录路径，无需路径实际存在；
- 路径操作通过重载运算符（如 `/`）或调用对象方法完成。

**示例：**

```python
from pathlib import Path

p1 = Path('/home/user/file.txt')            # Unix 系统
p2 = Path('C:/Users/user/file.txt')         # Windows 系统
```

---

## 二、路径操作示例

### 1. 路径拼接（推荐方式）

```python
p = Path('/home/user')
new_path = p / 'documents' / 'file.txt'
print(new_path)  # /home/user/documents/file.txt
```

相较于 `os.path.join()`，使用 `/` 运算符更简洁直观。

### 2. 获取路径的组成部分

```python
p = Path('/home/user/file.txt')

print(p.name)     # 'file.txt'
print(p.stem)     # 'file'
print(p.suffix)   # '.txt'
print(p.parent)   # '/home/user'
print(p.parts)    # ('/', 'home', 'user', 'file.txt')
```

---

## 三、文件与目录操作

### 1. 判断路径状态

```python
p = Path('example.txt')

p.exists()    # 是否存在
p.is_file()   # 是否为文件
p.is_dir()    # 是否为目录
```

### 2. 创建文件 / 目录

```python
Path('mydir').mkdir()                               # 创建单级目录
Path('a/b/c').mkdir(parents=True, exist_ok=True)    # 创建多级目录，若存在不报错
Path('empty.txt').touch()                           # 创建空文件
```

### 3. 删除文件 / 空目录

```python
Path('empty.txt').unlink()   # 删除文件
Path('a/b/c').rmdir()        # 删除空目录（非递归）
```

---

## 四、遍历文件系统

### 1. 遍历目录内容（非递归）

```python
for child in Path('.').iterdir():
    print(child)
```

### 2. 匹配特定模式

```python
# 匹配当前目录下所有 .txt 文件
for file in Path('.').glob('*.txt'):
    print(file)

# 递归匹配所有 .py 文件
for file in Path('.').rglob('*.py'):
    print(file)
```

---

## 五、读取与写入文件内容

虽然 `Path` 对象不是文件对象，但提供了便捷方法处理文件内容：

```python
# 写入文本
Path('note.txt').write_text('Hello, world!', encoding='utf-8')

# 读取文本
content = Path('note.txt').read_text(encoding='utf-8')

# 写入二进制
Path('data.bin').write_bytes(b'\x00\x01')

# 读取二进制
data = Path('data.bin').read_bytes()
```

---

## 六、路径解析与转换

### 1. 规范化与解析绝对路径

```python
Path('a/b/../c').resolve()  # 返回绝对路径并消除 ".."
```

### 2. 转换为字符串（用于与旧函数兼容）

```python
str(Path('file.txt'))  # 返回 'file.txt' 字符串
```

---

## 七、平台无关性与兼容性

`Path` 会自动适配当前系统，统一路径风格：

```python
from pathlib import Path

p = Path('folder') / 'file.txt'
print(p)  # Windows: folder\file.txt；Unix: folder/file.txt
```

---

## 八、常用技巧与辅助功能

### 1. 获取当前工作目录

```python
Path.cwd()  # 相当于 os.getcwd()
```

### 2. 获取当前脚本所在目录

```python
Path(__file__).parent
```

### 3. 获取系统临时目录（需配合 `tempfile` 模块）

```python
import tempfile
temp_dir = Path(tempfile.gettempdir())
```

---

## 九、与 `os.path` 模块的对比

|   |   |   |
|---|---|---|
|功能|`os.path`<br><br>示例|`pathlib`<br><br>示例|
|拼接路径|`os.path.join(a, b)`|`Path(a) / b`|
|判断是否为文件|`os.path.isfile(p)`|`Path(p).is_file()`|
|获取扩展名|`os.path.splitext(p)[1]`|`Path(p).suffix`|
|遍历目录|`os.listdir(p)`|`Path(p).iterdir()`|
|读取文件内容|`open(p).read()`|`Path(p).read_text()`|
|获取绝对路径|`os.path.abspath(p)`|`Path(p).resolve()`|

---

## 十、总结

`pathlib` 提供了更清晰、更现代化的路径操作方式，推荐在现代 Python 项目中优先使用 `pathlib` 取代传统的 `os.path` 模块。它不仅提高了代码的可读性，还增强了平台兼容性与编程体验。

`os` 模块是 Python 标准库中的一个重要模块，用于与操作系统进行交互。它提供了丰富的方法用于文件和目录的操作、环境变量管理、进程控制、路径处理等，具有跨平台特性。以下将从模块功能分类、常用函数及示例三个方面进行详细讲解。

---

## 一、模块导入

```python
import os
```

---

## 二、功能分类与常用方法

### 1. **文件与目录操作**

#### 1.1 当前工作目录

```python
os.getcwd()  # 获取当前工作目录
os.chdir(path)  # 改变当前工作目录
```

#### 1.2 创建和删除目录

```python
os.mkdir(path)  # 创建单层目录
os.makedirs(path)  # 递归创建多层目录
os.rmdir(path)  # 删除单层目录（目录必须为空）
os.removedirs(path)  # 递归删除空目录
```

#### 1.3 文件操作

```python
os.remove(path)  # 删除文件
os.rename(src, dst)  # 重命名文件或目录
os.replace(src, dst)  # 同 rename，但目标存在时会替换
```

#### 1.4 遍历目录

```python
os.listdir(path)  # 返回指定路径下的文件和目录列表
os.walk(top)  # 递归遍历目录树，返回生成器 (dirpath, dirnames, filenames)
```

---

### 2. **路径操作（推荐与 os.path 联用）**

```python
os.path.abspath(path)  # 获取绝对路径
os.path.basename(path)  # 获取文件名部分
os.path.dirname(path)  # 获取目录部分
os.path.join(path, *paths)  # 路径拼接（自动加/）
os.path.exists(path)  # 判断路径是否存在
os.path.isfile(path)  # 判断是否为文件
os.path.isdir(path)  # 判断是否为目录
os.path.getsize(path)  # 获取文件大小（单位：字节）
os.path.split(path)  # 拆分为 (目录, 文件)
```

---

### 3. **环境变量**

```python
os.environ  # 获取所有环境变量（字典形式）
os.environ.get('PATH')  # 获取某个环境变量
os.putenv('NAME', 'value')  # 设置环境变量（不推荐）
```

---

### 4. **系统信息**

```python
os.name  # 返回操作系统类型（'posix'、'nt'等）
os.uname()  # 返回系统信息（仅限 Unix 系统）
os.getlogin()  # 获取当前登录用户名（某些环境可能失败）
```

---

### 5. **进程管理**

```python
os.system('command')  # 执行系统命令（阻塞）
os.startfile(path)  # 打开文件（仅 Windows）
os.getpid()  # 获取当前进程 PID
os.getppid()  # 获取父进程 PID
```

---

## 三、综合示例

```python
import os

# 1. 切换到用户主目录
home_dir = os.path.expanduser("~")
os.chdir(home_dir)

# 2. 创建一个测试目录
test_dir = os.path.join(home_dir, "test_dir")
if not os.path.exists(test_dir):
    os.makedirs(test_dir)

# 3. 创建一个文件
file_path = os.path.join(test_dir, "example.txt")
with open(file_path, "w") as f:
    f.write("Hello, os module!")

# 4. 输出目录内容
print("目录内容：", os.listdir(test_dir))

# 5. 删除文件和目录
os.remove(file_path)
os.rmdir(test_dir)
```

---

## 四、补充说明

- `os.path` 是 `os` 的子模块，专门用于路径处理。
- 在进行跨平台开发时，推荐使用 `os.path.join()` 而非手动拼接路径，以避免路径分隔符问题。
- 若需高级文件操作（如复制文件），推荐配合 `shutil` 模块使用。

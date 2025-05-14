# `shutil` 模块详解笔记

`shutil` 模块是 Python 标准库中的一个高级文件操作模块，建立在 `os` 模块之上，提供了更强大、更方便的文件和目录复制、移动、删除、压缩、解压、磁盘使用情况查询等功能，适合执行文件系统的批处理任务，常用于备份、部署、清理等场景。

---

## 一、模块导入

```python
import shutil
```

---

## 二、功能分类与常用方法详解

### 1. 文件和目录的复制

#### 1.1 `shutil.copy(src, dst)`

- 复制文件内容，但**不保留元数据**（如权限、修改时间）。
- 如果 `dst` 是目录，则会在该目录下创建一个与 `src` 同名的文件。

```python
shutil.copy("a.txt", "backup/")
```

#### 1.2 `shutil.copy2(src, dst)`

- 与 `copy` 类似，但**保留文件的元数据**，推荐用于备份。

```python
shutil.copy2("a.txt", "backup/")
```

#### 1.3 `shutil.copyfile(src, dst)`

- 仅复制文件内容，**要求目标路径** `**dst**` **必须是一个文件名**，不能是目录。

```python
shutil.copyfile("a.txt", "b.txt")
```

#### 1.4 `shutil.copytree(src, dst, dirs_exist_ok=False)`

- 递归复制整个目录树，类似于命令 `cp -r`。
- `dirs_exist_ok=True` 表示目标目录存在时仍可继续复制（Python 3.8+）。

```python
shutil.copytree("project/", "project_backup/", dirs_exist_ok=True)
```

---

### 2. 移动和重命名

#### `shutil.move(src, dst)`

- 移动文件或目录到新位置。
- 如果 `dst` 为文件名，相当于重命名；如果为目录，则移动到该目录下。

```python
shutil.move("a.txt", "archive/")      # 移动到目录
shutil.move("a.txt", "b.txt")         # 重命名
```

---

### 3. 删除操作

#### `shutil.rmtree(path)`

- **递归删除整个目录树**，即使该目录非空。
- 操作不可恢复，建议在实际使用中添加确认或日志机制。

```python
shutil.rmtree("temp_folder")
```

⚠️ 高风险操作，需慎用。

---

### 4. 文件权限和属性操作

#### 4.1 `shutil.chown(path, user=None, group=None)`

- 更改文件或目录的所有者，仅适用于类 Unix 系统。

```python
shutil.chown("log.txt", user="admin", group="staff")
```

#### 4.2 `shutil.copystat(src, dst)`

- 复制 `src` 的**权限、时间戳等元数据**到 `dst`，不包括内容。

```python
shutil.copystat("a.txt", "b.txt")
```

---

### 5. 压缩与解压

#### 5.1 `shutil.make_archive(base_name, format, root_dir)`

- 创建压缩包。
- `format` 可选值包括：`zip`、`tar`、`gztar`、`bztar`、`xztar`。

```python
shutil.make_archive("backup", "zip", root_dir="project/")
# 生成 backup.zip
```

#### 5.2 `shutil.unpack_archive(filename, extract_dir)`

- 解压压缩文件，自动识别格式。

```python
shutil.unpack_archive("backup.zip", "extracted/")
```

---

### 6. 磁盘使用情况

#### `shutil.disk_usage(path)`

- 返回 `(total, used, free)` 的命名元组，单位为字节。

```python
usage = shutil.disk_usage("/")
print(f"总空间: {usage.total // (1024**3)} GB")
print(f"已使用: {usage.used // (1024**3)} GB")
print(f"可用: {usage.free // (1024**3)} GB")
```

---

### 7. 临时文件操作（结合 `tempfile` 模块）

虽然 `shutil` 本身不支持创建临时文件或目录，但常与 `tempfile` 搭配使用：

```python
import tempfile

with tempfile.TemporaryDirectory() as tmpdirname:
    print("创建的临时目录：", tmpdirname)
    shutil.copy("a.txt", tmpdirname)
```

---

## 三、综合示例

```python
import shutil
import os

# 1. 创建备份目录
os.makedirs("backup", exist_ok=True)

# 2. 复制文件并保留元数据
shutil.copy2("data.txt", "backup/data.txt")

# 3. 复制整个目录树
shutil.copytree("logs", "backup/logs", dirs_exist_ok=True)

# 4. 创建 ZIP 压缩包
shutil.make_archive("project_backup", "zip", root_dir="project")

# 5. 查看磁盘使用情况
usage = shutil.disk_usage("/")
print(f"Disk Free: {usage.free / (1024**3):.2f} GB")
```

---

## 四、总结对照表

|   |   |   |
|---|---|---|
|功能分类|方法名|说明|
|文件复制|`copy`<br><br>, `copy2`<br><br>, `copyfile`|`copy2`<br><br>可保留元数据|
|目录复制|`copytree`|可递归复制整个目录树|
|移动与重命名|`move`|支持跨目录移动或文件重命名|
|删除目录|`rmtree`|强制递归删除整个目录|
|压缩与解压|`make_archive`<br><br>, `unpack_archive`|支持多种压缩格式|
|空间查询|`disk_usage`|查询总空间、已用空间与可用空间|
|权限与元数据|`copystat`<br><br>, `chown`|多用于类 Unix 系统下的权限控制|
|临时目录|`tempfile`<br><br>（需配合 `shutil`<br><br>使用）|适用于测试、缓存、中间结果的隔离性操作|

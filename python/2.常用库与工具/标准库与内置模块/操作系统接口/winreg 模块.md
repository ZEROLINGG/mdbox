# `winreg` 模块详解

## 一、模块概述

`winreg` 是 Python 标准库中的模块，仅适用于 Windows 操作系统，用于以编程方式访问和操作 Windows 注册表。注册表是一个分层的数据库，用于存储操作系统和应用程序的配置信息。`winreg` 提供对注册表的读写、创建、删除、备份等功能。

在 Python 2.x 中，该模块名为 `_winreg`，Python 3.x 统一为 `winreg`。

---

## 二、注册表结构

注册表采用树状结构，包含若干根键（Root Keys），由若干子键（Subkeys）和键值（Values）组成。

常用根键（常量名）包括：

|   |   |
|---|---|
|根键常量|说明|
|`HKEY_CLASSES_ROOT`|文件类型关联信息、COM 对象注册表项等。|
|`HKEY_CURRENT_USER`|当前登录用户的配置信息。|
|`HKEY_LOCAL_MACHINE`|整个系统（所有用户）的硬件和软件配置信息。|
|`HKEY_USERS`|所有用户的配置文件集合。|
|`HKEY_CURRENT_CONFIG`|当前硬件配置文件信息。|

键值的数据类型示例：

|   |   |
|---|---|
|类型常量|含义|
|`REG_SZ`|字符串|
|`REG_DWORD`|32 位整数|
|`REG_BINARY`|原始二进制数据|
|`REG_MULTI_SZ`|多字符串列表（以空字符分隔）|
|`REG_EXPAND_SZ`|含变量引用的字符串|

---

## 三、核心函数详解

### 1. 打开与关闭注册表键

```python
import winreg

# 打开注册表键
key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft")

# 使用后关闭
winreg.CloseKey(key)
```

- `**OpenKey(key, sub_key, reserved=0, access=KEY_READ)**`打开一个现有的注册表键。返回一个 `PyHKEY` 对象。
- `**CloseKey(hkey)**`  
    显式释放已打开的键资源。

---

### 2. 创建与删除键

```python
# 创建键
key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, r"Software\MyApp")
winreg.CloseKey(key)

# 删除键（必须为空键）
winreg.DeleteKey(winreg.HKEY_CURRENT_USER, r"Software\MyApp")
```

- `**CreateKey(key, sub_key)**` **/** `**CreateKeyEx(...)**`  
    创建或打开一个子键（若已存在则打开）。
- `**DeleteKey(key, sub_key)**` **/** `**DeleteKeyEx(...)**`  
    删除指定的子键（子键必须为空，否则抛出异常）。

---

### 3. 读取与设置键值

```python
# 读取默认值
value = winreg.QueryValue(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows\CurrentVersion")
print(value)

# 读取指定键值
key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\MyApp")
val, typ = winreg.QueryValueEx(key, "Version")
print(val, typ)
winreg.CloseKey(key)

# 设置键值
key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, r"Software\MyApp")
winreg.SetValueEx(key, "Version", 0, winreg.REG_SZ, "1.0")
winreg.CloseKey(key)

# 删除键值
key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\MyApp", 0, winreg.KEY_SET_VALUE)
winreg.DeleteValue(key, "Version")
winreg.CloseKey(key)
```

---

### 4. 枚举子键与键值

```python
# 枚举子键
key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE")
i = 0
while True:
    try:
        print(winreg.EnumKey(key, i))
        i += 1
    except OSError:
        break
winreg.CloseKey(key)

# 枚举键值
key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\MyApp")
i = 0
while True:
    try:
        name, value, typ = winreg.EnumValue(key, i)
        print(name, value, typ)
        i += 1
    except OSError:
        break
winreg.CloseKey(key)
```

---

### 5. 注册表备份与恢复

```python
# 保存注册表项（需要管理员权限）
key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\MyApp")
winreg.SaveKey(key, r"C:\backup.reg")
winreg.CloseKey(key)

# 加载注册表文件为子键
winreg.LoadKey(winreg.HKEY_LOCAL_MACHINE, r"TempKey", r"C:\backup.reg")

# 强制写入注册表（可选）
winreg.FlushKey(key)
```

---

## 四、使用注意事项

### 1. 权限管理

- 某些注册表项（特别是 `HKEY_LOCAL_MACHINE`）需要管理员权限。
- 运行脚本前请右键“以管理员身份运行” Python 解释器。
- 使用 `KEY_WOW64_32KEY` / `KEY_WOW64_64KEY` 可指定访问注册表的 32/64 位视图。

### 2. 错误处理建议

操作注册表易出错，应配合 `try-except` 块处理：

```python
try:
    key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\NonExist")
except FileNotFoundError:
    print("键不存在")
except PermissionError:
    print("权限不足")
```

### 3. 推荐使用上下文管理器（Python 3.2+）

```python
with winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\MyApp") as key:
    value, typ = winreg.QueryValueEx(key, "Version")
    print(value)
```

---

## 五、参考用途示例

1. 检查软件是否安装；
2. 设置开机自启项（如写入 `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run`）；
3. 读取系统配置，如桌面路径、关机策略等；
4. 制作注册表清理工具；
5. 编写自动化脚本调整系统参数。

---

## 六、结语

`winreg` 模块为开发者提供了强大的工具，可以直接操控 Windows 系统底层配置。但也正因为其能力强大，操作不当可能导致系统不稳定，建议务必做好备份并谨慎使用，尤其在执行删除和修改操作时。

如需进行更复杂的注册表操作（如遍历递归子键、跨平台处理等），可考虑将其与其他模块（如 `ctypes` 或 `subprocess` 调用 reg 命令）配合使用。

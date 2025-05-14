# `subprocess` 模块详解笔记（完整版）

`subprocess` 模块是 Python 标准库中用于创建和管理子进程的核心模块，旨在替代传统的 `os.system()`、`os.spawn*()`、`os.popen*()` 等过时接口，提供了更强大、灵活和安全的方式来执行外部命令、进行进程间通信和捕获输出结果。

---

## 一、核心函数与类介绍

### 1. `subprocess.run()`

**用途：**  
执行命令，等待命令执行结束，返回结果。适用于大多数简单的命令执行场景。

**示例代码：**

```python
import subprocess

result = subprocess.run(['ls', '-l'], capture_output=True, text=True)
print(result.stdout)
```

**常用参数：**

- `args`: 指定命令及参数，**建议使用列表形式**，防止命令注入。
- `shell`: 若为 `True`，通过 shell 解析执行命令（支持管道、重定向等复杂命令）。
- `capture_output`: 若为 `True`，等价于 `stdout=subprocess.PIPE` 和 `stderr=subprocess.PIPE`。
- `text` / `universal_newlines`: 为 `True` 时将输入输出以字符串处理（默认是字节流）。
- `input`: 传入标准输入的字符串或字节流。
- `timeout`: 设置超时时间（秒）。
- `check`: 若为 `True` 且命令返回码非 0，将抛出 `CalledProcessError`。

**返回对象：**`CompletedProcess`

- `args`: 实际执行的命令参数列表。
- `returncode`: 子进程的退出状态码。
- `stdout`: 标准输出（如启用 `capture_output`）。
- `stderr`: 标准错误输出（如启用 `capture_output`）。

---

### 2. `subprocess.Popen()`

**用途：**  
提供最灵活的进程控制接口，适用于需要实时交互、流式处理、管道连接等复杂场景。

**示例代码：**

```python
p = subprocess.Popen(['grep', 'foo'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
output, _ = p.communicate(input='foo\nbar\nfoo bar\n')
print(output)
```

**常用参数：**

- `stdin`, `stdout`, `stderr`: 可设为 `subprocess.PIPE`、`subprocess.DEVNULL`、文件对象等。
- `shell`: 与 `run()` 相同。
- `text`: 字符串模式；若为 `False`，则读写为字节。
- `bufsize`: 缓冲策略（`0`: 无缓冲，`1`: 行缓冲，`-1`: 默认缓冲）。

**常用方法：**

- `communicate(input=None)`: 发送输入并接收输出，等待子进程终止。
- `wait(timeout=None)`: 阻塞等待子进程结束。
- `poll()`: 检查子进程是否终止（不阻塞）。
- `kill() / terminate()`: 杀死或终止子进程。

---

### 3. `subprocess.call()`

**用途：**执行命令并返回退出码。可看作 `run(...).returncode` 的快捷方式。

**示例代码：**

```python
code = subprocess.call(['ls', '-l'])
```

---

### 4. `subprocess.check_call()` / `subprocess.check_output()`

**check_call():**

- 功能与 `call()` 类似，但如果退出码非零，会抛出 `CalledProcessError` 异常。

**check_output():**

- 执行命令并返回标准输出结果。
- 若命令失败，会抛出 `CalledProcessError`，异常对象中包含 `output`。

**示例：**

```python
output = subprocess.check_output(['echo', 'hello'], text=True)
print(output)
```

---

## 二、shell 模式与安全性

### 1. `shell=True` 的作用

使用 shell 解析执行命令字符串（例如：支持 `"ls -l | grep txt"`、重定向等复杂表达式），等价于将命令传递给 shell 解析（如 Linux 的 `/bin/sh`，Windows 的 `cmd.exe`）。

### 2. 安全风险

- 若命令中包含用户输入，**切勿直接拼接字符串再传给 shell**，极易造成命令注入。
- 推荐使用 **列表传参 + shell=False** 的方式来避免此类风险。

**不安全示例：**

```python
subprocess.run(f"rm -rf {user_input}", shell=True)
```

**安全示例：**

```python
subprocess.run(["rm", "-rf", user_input])
```

---

## 三、标准输入输出与错误控制

### 捕获标准输出与错误：

```python
result = subprocess.run(['ls', '-l'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
print("输出：", result.stdout)
print("错误：", result.stderr)
```

### 传递标准输入：

```python
result = subprocess.run(['python3'], input='print("Hello")', text=True, stdout=subprocess.PIPE)
print(result.stdout)
```

### 忽略输出：

- 使用 `stdout=subprocess.DEVNULL` 屏蔽输出

```python
subprocess.run(['ls'], stdout=subprocess.DEVNULL)
```

---

## 四、典型应用场景示例

### 1. 管道命令（如 `ls | grep py`）

```python
p1 = subprocess.Popen(['ls'], stdout=subprocess.PIPE)
p2 = subprocess.Popen(['grep', 'py'], stdin=p1.stdout, stdout=subprocess.PIPE, text=True)
p1.stdout.close()  # 避免死锁
output = p2.communicate()[0]
print(output)
```

### 2. 设置命令超时：

```python
try:
    subprocess.run(['sleep', '10'], timeout=5)
except subprocess.TimeoutExpired:
    print("命令超时！")
```

### 3. 动态构建命令：

```python
cmd = ['ffmpeg', '-i', 'input.mp4', '-vn', 'output.mp3']
subprocess.run(cmd)
```

---

## 五、异常处理机制

### 常见异常类型：

|   |   |
|---|---|
|异常类型|触发条件|
|`subprocess.CalledProcessError`|当 `check=True`<br><br>且命令返回码非 0 时触发|
|`subprocess.TimeoutExpired`|超过 `timeout`<br><br>参数指定时间仍未完成执行|
|`OSError`|系统层面错误，如命令不存在或权限不足等|

### 示例：

```python
try:
    subprocess.run(['false'], check=True)
except subprocess.CalledProcessError as e:
    print("命令执行失败，返回码：", e.returncode)
```

---

## 六、函数用法对比小结

|   |   |   |
|---|---|---|
|函数|功能描述|推荐使用场景|
|`subprocess.run()`|执行命令并等待完成，支持超时、捕获输出、传入输入等|**推荐首选**|
|`subprocess.Popen()`|最底层接口，支持流式交互与复杂控制|子进程交互、管道、长时任务等场景|
|`subprocess.call()`|执行命令，返回状态码|仅需退出码，不关心输出时|
|`subprocess.check_call()`|类似 `call()`<br><br>，但失败抛异常|需要明确检测命令是否成功时|
|`subprocess.check_output()`|执行命令并返回输出，失败抛异常|需要获取输出内容时|

---

## 七、实用建议与注意事项

1. **避免使用 shell=True 处理用户输入**

- 安全风险极高，应使用列表方式传参。

2. **尽可能捕获输出并设置超时**

- 防止子进程阻塞主程序。

3. **了解子进程资源管理**

- 使用 `p1.stdout.close()` 等避免管道阻塞。

4. **跨平台兼容性**

- Windows 和 Linux 的 shell 行为、命令格式差异需留意。

5. **处理非 UTF-8 编码**

- 可设置 `encoding='gbk'` 等参数以兼容特定系统编码（如 Windows）。

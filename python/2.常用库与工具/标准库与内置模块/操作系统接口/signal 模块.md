**signal 模块是 Python 提供的一个用于处理异步事件的标准模块，主要用于设置信号处理器（signal handler），使程序能在收到系统信号时做出自定义响应。常用于处理诸如 Ctrl+C 中断、子进程退出、定时器等。**

### 一、信号（Signal）简介

信号是操作系统用于通知进程发生了异步事件的一种机制。常见的信号包括：

|   |   |   |
|---|---|---|
|信号名|数值|含义|
|SIGINT|2|用户中断（通常是 Ctrl+C）|
|SIGTERM|15|请求终止程序（kill 默认）|
|SIGKILL|9|强制终止程序（不可捕获）|
|SIGALRM|14|定时器信号|
|SIGHUP|1|终端关闭|
|SIGCHLD|17|子进程退出|

### 二、signal 模块常用函数

#### 1. `signal.signal(signalnum, handler)`

设置信号处理器：

- `signalnum`：信号编号，例如 `signal.SIGINT`。
- `handler`：

- `signal.SIG_IGN`：忽略信号。
- `signal.SIG_DFL`：使用默认处理器。
- 自定义函数：接受两个参数 `(signum, frame)`，分别表示信号编号和当前堆栈帧。

📌 只能在主线程中使用。

**示例：**

```python
import signal
import time

def handler(signum, frame):
    print(f"接收到信号: {signum}")

# 设置 SIGINT 信号处理器
signal.signal(signal.SIGINT, handler)

while True:
    print("运行中... 按 Ctrl+C 发送 SIGINT")
    time.sleep(2)
```

#### 2. `signal.alarm(seconds)`

在指定秒数后发送 `SIGALRM` 信号，仅在 Unix 系统中可用。

**示例：**

```python
import signal
import time

def timeout_handler(signum, frame):
    print("超时！")

signal.signal(signal.SIGALRM, timeout_handler)
signal.alarm(5)  # 5 秒后触发

print("开始等待...")
time.sleep(10)
print("结束")
```

#### 3. `signal.pause()`

挂起进程直到接收到信号。常与定时器、异步控制联合使用。

**示例：**

```python
import signal

def handler(signum, frame):
    print("收到信号，继续执行")

signal.signal(signal.SIGUSR1, handler)
print("等待信号 SIGUSR1...")
signal.pause()
print("继续执行程序")
```

#### 4. `signal.getsignal(signalnum)`

获取当前指定信号的处理器。

### 三、与子进程相关的信号

- **SIGCHLD**：子进程结束后发送，常用于编写守护进程。

处理 `SIGCHLD` 后，可以使用 `os.wait()` 或 `os.waitpid()` 获取子进程的退出状态。

### 四、注意事项

- **Windows 支持的信号较少，仅支持**：

- `SIGINT`
- `SIGTERM`
- `SIGABRT`
- `SIGBREAK`

- **仅主线程可以设置信号处理器，否则抛出** `**ValueError**`**。**
- **SIGKILL 和 SIGSTOP** 不可被捕获或忽略。

### 五、实际应用场景

#### 1. 优雅终止程序

在接收到终止信号时执行资源清理工作，并正常退出程序。

```python
import signal
import sys

def cleanup(signum, frame):
    print("清理资源...")
    sys.exit(0)

signal.signal(signal.SIGTERM, cleanup)
signal.signal(signal.SIGINT, cleanup)
```

#### 2. 超时控制

在执行某些阻塞操作前设置信号定时器，避免程序永久挂起。

```python
import signal
import time

def timeout_handler(signum, frame):
    print("操作超时")

signal.signal(signal.SIGALRM, timeout_handler)
signal.alarm(5)  # 设置超时为 5 秒

try:
    print("开始执行操作...")
    time.sleep(10)  # 模拟长时间阻塞操作
except Exception as e:
    print(e)
```

#### 3. 写守护进程

使用 `SIGCHLD` 监控子进程生命周期，常用于守护进程的编写。

```python
import signal
import os
import time

def child_handler(signum, frame):
    pid, status = os.wait()  # 等待子进程退出
    print(f"子进程 {pid} 已退出，状态：{status}")

signal.signal(signal.SIGCHLD, child_handler)

# 创建子进程示例
pid = os.fork()
if pid == 0:
    print("子进程开始执行...")
    time.sleep(2)
    os._exit(0)
else:
    print("父进程等待子进程退出...")
    time.sleep(3)
```

### 六、信号编号列表

```python
import signal

for name in dir(signal):
    if name.startswith("SIG") and not name.startswith("SIG_"):
        print(f"{name}: {getattr(signal, name)}")
```

此代码将输出所有信号编号和其对应的值。

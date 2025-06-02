## 概述

Python 的 `time` 模块是与操作系统交互的底层时间接口，提供了访问系统时钟、时间戳、休眠、格式化/解析时间字符串等功能。相比于更高级的 `datetime` 模块，`time` 更接近操作系统层面，主要以 UNIX 时间戳（自 1970 年 1 月 1 日 00:00:00 UTC 起的秒数）和 `struct_time` 结构为基础，适合进行更原始、轻量级的时间测量与转换。下面将从模块结构、核心常量与函数、`struct_time` 结构、系统时钟、格式化与解析、休眠与性能计时等方面，进行详细讲解，并辅以示例代码。

---

## 1. 模块常量与数据结构

### 1.1 常量

- `time.timezone`：表示本地时区与 UTC 时区之间的偏移（以秒为单位）。如果在夏令时期间，需结合 `time.altzone` 使用。
- `time.altzone`：夏令时（DST）时，本地时区与 UTC 之间的偏移（以秒）。
- `time.daylight`：如果系统支持夏令时，并且当前日期属于夏令时，则值为 1，否则为 0。
- `time.tzname`：长度为 2 的元组，分别表示非夏令时和夏令时下的时区名称，例如 `('CST', 'CDT')`。
- `time.CLOCK_REALTIME`、`time.CLOCK_MONOTONIC`、`time.CLOCK_PROCESS_CPUTIME_ID`、`time.CLOCK_THREAD_CPUTIME_ID` 等：在支持的系统上，可用于调用更底层的 `time.clock_gettime()` 函数，获取不同类型的时钟。并非所有平台都支持所有钟源，要根据实际环境查看。

### 1.2 `struct_time` 结构

许多 `time` 函数会返回或接收一个 `struct_time` 对象，这是一个类似命名元组的结构，包含 9 个字段，分别表示：

|     |            |                              |                  |
| --- | ---------- | ---------------------------- | ---------------- |
| 索引  | 属性名        | 含义                           | 取值范围             |
| 0   | `tm_year`  | 年份                           | ≥ 1900           |
| 1   | `tm_mon`   | 月（1–12）                      | 1–12             |
| 2   | `tm_mday`  | 今日在月份中的天数                    | 1–31             |
| 3   | `tm_hour`  | 小时（0–23）                     | 0–23             |
| 4   | `tm_min`   | 分（0–59）                      | 0–59             |
| 5   | `tm_sec`   | 秒（0–61）                      | 0–61（包括闰秒）       |
| 6   | `tm_wday`  | 星期几（周一–周日）                   | 0–6（其中 0 代表周一）   |
| 7   | `tm_yday`  | 年内第几天                        | 1–366            |
| 8   | `tm_isdst` | 是否为夏令时（Daylight Saving Time） | 0（否）、1（是）、-1（未知） |

`struct_time` 在打印时会以类似如下形式呈现：

```python
time.struct_time(tm_year=2025, tm_mon=6, tm_mday=2, tm_hour=14, tm_min=30, tm_sec=15, tm_wday=0, tm_yday=153, tm_isdst=0)
```

---

## 2. 时间戳与系统时钟

### 2.1 `time.time()`

- **功能**：返回当前系统时间的“Unix 时间戳”（浮点数），从 1970-01-01 00:00:00 UTC 起所经过的秒数。
- **精度**：根据系统不同，通常精度到微秒（浮点数的小数部分），但底层调用可能因平台而异。

```python
import time

ts = time.time()
print("当前时间戳：", ts)   # 类似 173,056,3415.123456
```

- **常用场景**：

- 计算代码执行时间：记录前后时间戳之差。
- 生成代表当前时间的唯一 ID（结合毫秒、随机数等）。
- 与其他系统（如 Unix）交换时间数据。

### 2.2 `time.perf_counter()`

- **功能**：返回一个高精度、低延迟的计时器值，适合测量短时间内的时间间隔。它包括了系统睡眠时间，但不一定以 UTC 为基准。
- **特点**：时钟单调上升（monotonic），不会因系统时间调整（如 NTP 校准）而倒退。
- **典型用法**：

```python
import time

start = time.perf_counter()
# 执行某段耗时操作
time.sleep(1.5)
end = time.perf_counter()
print("耗时：", end - start, "秒")  # 接近 1.5
```

### 2.3 `time.process_time()`

- **功能**：返回当前进程在 CPU 上所消耗的时间，精度高，适合测量 CPU 计算消耗，而不包括进程睡眠或等待 I/O 的时间。
- **特点**：同样单调递增，但只计入进程运行的 CPU 时间，不受系统时钟调整影响。
- **场景**：当你只关心代码对 CPU 的占用，比如在性能分析时，用来衡量算法的纯计算开销。

```python
import time

start_cpu = time.process_time()
# 执行纯计算任务
for _ in range(10**6):
    pass
end_cpu = time.process_time()
print("CPU 消耗时间：", end_cpu - start_cpu, "秒")
```

### 2.4 `time.monotonic()`

- **功能**：返回操作系统提供的单调递增的时钟值，用于测量绝对时间间隔。与 `perf_counter()` 类似，但不一定包含睡眠时间。这两者可根据平台差异选择。
- **特点**：同样保证单调性，不会因系统时间回拨而影响，非常适合做超时判断或测量间隔。

```python
import time

start = time.monotonic()
time.sleep(0.2)
end = time.monotonic()
print("单调时钟间隔：", end - start)
```

### 2.5 `time.clock_gettime()` / `time.clock_settime()`

- 这两个函数允许你以指定时钟源读取或设置系统时钟。典型用法（Linux/Unix 系统）：

```python
import time

# 读取 CLOCK_REALTIME（系统实时时钟）
now_realtime = time.clock_gettime(time.CLOCK_REALTIME)
print("系统实时时钟：", now_realtime)

# 读取 CLOCK_MONOTONIC（单调时钟）
now_mono = time.clock_gettime(time.CLOCK_MONOTONIC)
print("单调时钟：", now_mono)
```

- **注意**：并非所有操作系统都支持所有时钟源，需要捕获 `AttributeError` 或查阅平台说明。

---

## 3. 时间转换与格式化

`time` 模块提供了一组将“时间戳 ↔ `struct_time` ↔ 字符串”相互转换的函数。主要包括以下几类：

### 3.1 时间戳 ↔ `struct_time`

- `time.gmtime([secs])`：将以秒数表示的时间戳（默认当前时间）转换为 UTC（格林尼治标准时间）的 `struct_time`。
- `time.localtime([secs])`：将时间戳转换为本地时区下的 `struct_time`。
- `time.mktime(t)`：将本地时区下的 `struct_time`（或元组）转换回时间戳。

示例：

```python
import time

# 获取当前时间的 UTC struct_time
utc_tm = time.gmtime()
print("UTC struct_time:", utc_tm)

# 获取当前时间的本地 struct_time
loc_tm = time.localtime()
print("Local struct_time:", loc_tm)

# 将自定义的 struct_time 转回时间戳
custom = time.struct_time((2025, 6, 2, 14, 30, 0, 0, 0, -1))
ts = time.mktime(custom)  # 注意 mktime 默认认为 t 为本地时间
print("自定义 struct_time 对应的本地时间戳：", ts)
```

- **注意**：`time.mktime()` 期望输入的 `struct_time` 是本地时区下的时间，如果输入一个在 DST 状态改变时刻的 `struct_time`，会导致 `tm_isdst` 冲突，此时 `mktime` 会根据 `tm_isdst` 决定输出。

### 3.2 `strftime(format, t)`：格式化

- **功能**：将一个 `struct_time`（或当前时间）格式化为字符串，格式由 `format` 参数指定，常用格式化符号与 `datetime.strftime` 相同。
- **签名**：`time.strftime(format[, t])`

- 如果不提供 `t` 参数，则默认使用当前本地时间（等同于 `time.localtime()`）。

```python
import time

# 当前本地时间格式化
s1 = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
print("当前本地时间：", s1)

# 指定 GMT 时间格式化
s2 = time.strftime("%a, %d %b %Y %H:%M:%S +0000", time.gmtime())
# 类似 "Mon, 02 Jun 2025 14:30:00 +0000"
print("当前 UTC 时间：", s2)
```

常用格式化符号（与 `datetime` 基本一致）：

- `%Y`：四位数年份（例如 `2025`）
- `%m`：两位数月份（`01–12`）
- `%d`：两位数日（`01–31`）
- `%H`：24 小时小时（`00–23`）
- `%I`：12 小时制小时（`01–12`）
- `%M`：分钟（`00–59`）
- `%S`：秒（`00–59`）
- `%f`：微秒（仅 Python 3.6+，需要使用 `datetime` 模块来获取微秒部分）
- `%a` / `%A`：本地化星期缩写 / 全称
- `%b` / `%B`：本地化月份缩写 / 全称
- `%p`：本地化的 AM/PM 标识
- `%z` / `%Z`：时区偏移 / 时区名称
- `%j`：年内第几天（`001–366`）
- `%U` / `%W`：年内第几周（分别以周日 / 周一 作为一周的第一天）

### 3.3 `strptime(string, format)`：解析

- **功能**：将符合指定格式的时间字符串解析为 `struct_time`。
- **签名**：`time.strptime(string, format)`

```python
import time

s = "2025-06-02 14:30:15"
tm = time.strptime(s, "%Y-%m-%d %H:%M:%S")
print("解析后的 struct_time：", tm)
# 若需转换为时间戳：
ts = time.mktime(tm)
print("对应本地时间戳：", ts)
```

- **注意事项**：

- 如果字符串与格式不完全匹配，会抛出 `ValueError`。
- `strptime` 仅解析到秒级别，不能直接得到微秒。
- 解析后的 `tm_isdst` 字段会根据当前时区与日期自动填充（0/1/-1）；如果要强制指定，可在字符串中加入 `%z` 来解析时区偏移（如 `+0800`），但在某些平台上可能有限制。

---

## 4. 休眠与暂停

### 4.1 `time.sleep(secs)`

- **功能**：让当前线程/进程暂停运行至少 `secs` 秒（可以是浮点数），秒数作为睡眠时长。
- **签名**：`time.sleep(secs)`

```python
import time

print("开始休眠")
time.sleep(2.5)   # 暂停 2.5 秒
print("休眠结束")
```

- **注意**：

- 如果在多线程环境下，`sleep` 只会暂停当前线程，不会影响其他线程运行。
- 如果在子进程中使用，会暂停该子进程对应的线程。
- `sleep` 的精度受操作系统调度和 Python GIL 影响，实际可能略大于指定的秒数。

---

## 5. 时区与本地化

虽然 `time` 模块没有像 `datetime` 那样提供完整的时区类，但也可以通过以下属性与函数来查询系统时区信息并进行简单转换。

### 5.1 时区常量

- `time.timezone`：在非夏令时（`tm_isdst == 0`）情况下，本地时间与 UTC 时间之间的偏移秒数（通常为负值，表示 UTC 落后本地）。
- `time.altzone`：在夏令时（`tm_isdst == 1`）情况下，本地时间与 UTC 之间的偏移秒数。
- `time.daylight`：系统是否支持夏令时（1 表示支持，0 表示不支持）。
- `time.tzname`：一个包含两个字符串的元组，分别对应非夏令时和夏令时下的本地时区名称，如 `('CST', 'CDT')`。

```python
import time

print("time.timezone:", time.timezone)   # 例如  -21600，表示 UTC-6 小时（美国中部标准时）
print("time.altzone:", time.altzone)     # 例如  -18000，表示夏令时 UTC-5
print("time.daylight:", time.daylight)   # 1 表示支持夏令时
print("time.tzname:", time.tzname)       # ('CST', 'CDT')
```

- **理解偏移值**：

- 如果本地时区是 UTC-6（北美中部标准时，CST），则 `time.timezone == 6 * 3600 = 21600`。在 Python 中返回的是“与 UTC 的差值”，即 `-21600`（因为本地时间 = UTC 时间 − 6 小时）。
- 当进入夏令时时段，偏移会变为 `-18000`（UTC-5），对应 `time.altzone`。

### 5.2 `time.tzset()`

- **功能**：仅在 Unix/Linux 系统上可用。根据环境变量 `TZ`（时区）重新初始化时区设置，使得 `time.localtime()`、`time.gmtime()`、`time.timezone` 等常量依据新的 `TZ` 生效。
- **示例**：

```python
import os, time

# 假设系统默认为本地时区，美国中部时区
print("原始时区名称：", time.tzname)

# 临时切换到东京时区（UTC+9）
os.environ['TZ'] = 'Asia/Tokyo'
time.tzset()
print("切换后时区名称：", time.tzname)
print("当地时间：", time.localtime())

# 恢复原时区
os.environ.pop('TZ', None)
time.tzset()
print("恢复时区名称：", time.tzname)
```

- **注意**：

- Windows 平台没有 `tzset()`，在 Windows 上修改时区需通过系统设置或使用其他库（如 `dateutil`、`pytz`）。

---

## 6. 进程/线程 CPU 时间与用户/系统 CPU 时间

### 6.1 `time.process_time()`

（已在 2.3 节介绍）衡量当前进程在 CPU 上消耗的时间。分为用户态和内核态总和，不包括睡眠与 I/O 等等待时间，无法单独获取用户态与内核态。

### 6.2 `time.thread_time()`（Python 3.7+）

- **功能**：返回当前线程占用的 CPU 时间，仅包括本线程使用的 CPU 资源，不包括其他线程。与 `process_time()` 类似，但细粒度到线程。
- **示例**：

```python
import time

start_thread = time.thread_time()
# 在当前线程内运行一些逻辑
for _ in range(10**6):
    pass
end_thread = time.thread_time()
print("当前线程 CPU 时间：", end_thread - start_thread, "秒")
```

- **注意**：只有在支持的操作系统与 Python 版本中可用，否则会抛出 `AttributeError`。

---

## 7. 其他实用函数

### 7.1 `time.ctime([secs])`

- **功能**：将给定的时间戳（秒）转换成一个可读的字符串形式，格式类似 `"Mon Jun 2 14:30:15 2025"`。如果不提供参数 `secs`，则使用当前时间戳。
- **示例**：

```python
import time

print(time.ctime())            # 当前时间的可读字符串
print(time.ctime(0))           # "Thu Jan  1 00:00:00 1970"（UTC/GMT）
```

### 7.2 `time.asctime([t])`

- **功能**：将给定的 `struct_time` 转换成易读字符串，等效于 `ctime(mktime(t))`，如果不传 `t` 则使用 `localtime()`。
- **示例**：

```python
import time

t = time.localtime()
print(time.asctime(t))  # "Mon Jun  2 14:30:15 2025"
```

### 7.3 `time.tzname`、`time.daylight`、`time.timezone`、`time.altzone`

（已在 5.1 节详细说明）

---

## 8. 综合示例

下面展示一个小示例，集成多个 `time` 模块功能，演示如何获取当前时间、格式化、休眠、以及测量函数执行时间。

```python
import time

def demo_time_module():
    # 1. 获取当前本地时间戳与 UTC 时间戳
    ts_local = time.time()
    print("当前本地时间戳：", ts_local)

    # 2. 将时间戳转换为 struct_time（本地与 UTC）
    local_tm = time.localtime(ts_local)
    utc_tm = time.gmtime(ts_local)
    print("本地 struct_time：", local_tm)
    print("UTC struct_time：", utc_tm)

    # 3. 格式化为易读字符串
    s1 = time.strftime("%Y-%m-%d %H:%M:%S", local_tm)
    s2 = time.strftime("%a, %d %b %Y %H:%M:%S +0000", utc_tm)
    print("本地格式化时间：", s1)
    print("UTC 格式化时间：", s2)

    # 4. 计算某段函数执行时间（使用 perf_counter）
    start = time.perf_counter()
    time.sleep(1.2)  # 模拟耗时操作
    elapsed = time.perf_counter() - start
    print(f"模拟操作耗时：{elapsed:.5f} 秒")

    # 5. 测量当前进程 CPU 占用（非常短，主要演示用法）
    start_cpu = time.process_time()
    # 一些 CPU 计算
    _ = sum(i*i for i in range(1000000))
    cpu_used = time.process_time() - start_cpu
    print(f"CPU 占用时间：{cpu_used:.5f} 秒")

    # 6. 演示 struct_time ↔ 时间戳 ↔ 字符串 ↔ mktime
    t_str = "2025-06-02 18:45:00"
    # 6.1 解析字符串到 struct_time
    tm_parsed = time.strptime(t_str, "%Y-%m-%d %H:%M:%S")
    # 6.2 struct_time 转 时间戳（本地时区）
    ts_parsed = time.mktime(tm_parsed)
    print(f"字符串“{t_str}”对应本地时间戳：{ts_parsed}")

    # 6.3 再转回 struct_time（本地）
    tm_back = time.localtime(ts_parsed)
    print("转回 struct_time：", tm_back)

    # 6.4 asctime / ctime 演示
    print("asctime：", time.asctime(tm_back))
    print("ctime：", time.ctime(ts_parsed))

    # 7. 时区信息
    print("当前时区名称：", time.tzname)
    print("是否启用夏令时：", bool(time.daylight))
    offset = -time.timezone if time.localtime().tm_isdst == 0 else -time.altzone
    # 计算当前偏移小时数
    print("当前与 UTC 偏移：", offset / 3600, "小时")

if __name__ == "__main__":
    demo_time_module()
```

**说明：**

1. 通过 `time.time()` 获取当前时间戳。
2. 使用 `localtime()` 和 `gmtime()` 分别获得本地和 UTC 对应的 `struct_time`。
3. `strftime` 用于将 `struct_time` 格式化成字符串。
4. `perf_counter()` 测量真实经过时间，包括 `sleep` 等休眠时长，适合作精准的代码段耗时统计。
5. `process_time()` 测量 CPU 时间，仅关注代码在 CPU 上实际运行的时间。
6. 解析字符串 `time.strptime()`，再用 `time.mktime()` 得到本地时间戳，最后验证转换无误。
7. `time.tzname`、`time.daylight`、`time.timezone`/`time.altzone` 用于查询当前系统时区信息，并计算与 UTC 的偏移小时数。

---

## 9. 注意事项与最佳实践

1. **秒级 vs. 高精度计时**

- 如果只需获取当前时间戳或进行基本转换，使用 `time.time()` 即可。
- 若要做性能测试或计算耗时，建议使用 `time.perf_counter()` 或 `time.monotonic()`，避免系统时钟调整造成干扰。
- 如果关心的是当前进程或线程的 CPU 占用时间，使用 `time.process_time()` 或 `time.thread_time()`。

2. `**sleep()**` **精度**

- `time.sleep()` 会让当前线程暂停至少指定时长，实际精度受操作系统调度影响，有可能比指定时长稍长。对于高精度定时任务，可以结合 `monotonic()` 循环判断。

3. `**struct_time**` **与时区**

- `time.localtime()` 返回的 `struct_time` 带有 `tm_isdst` 字段，可以反映当前是否处于夏令时；但如果自己手动构造 `struct_time`，应合理设置 `tm_isdst`，否则在 `mktime()` 转换时可能得到意外结果。
- Windows 平台不支持 `time.tzset()`，若需要跨平台的时区转换，建议使用 `datetime` 和第三方库 `pytz`/`dateutil`。

4. `**strptime**` **性能**

- `time.strptime` 每次都会重新编译格式化字符串，在需要大量解析的场景下会较慢。可以考虑先用 `datetime.strptime` 然后转换，或缓存编译好的格式化对象，或使用第三方库（如 `ciso8601`）加速。

5. **跨平台兼容**

- 并非所有 Python 版本或操作系统都支持 `clock_gettime`、`thread_time` 等函数，编写可移植代码时应先 `hasattr(time, 'XXX')` 判断可用性，再使用。
- Python 3.10+ 对 `time` 模块功能进行了进一步强化和优化，若使用旧版本，请参阅对应版本文档。

---

## 小结

- **核心用途**：

- 获取当前时间戳：`time.time()`
- 将时间戳转换为可读结构或字符串：`localtime()`、`gmtime()`、`strftime()`、`asctime()`、`ctime()`
- 将字符串解析或结构转换为时间戳：`strptime()`、`mktime()`
- 线程暂停：`sleep()`
- 精准计时：`perf_counter()`、`monotonic()`、`process_time()`、`thread_time()`
- 查询时区与夏令时信息：`timezone`、`altzone`、`daylight`、`tzname`、`tzset()`（Unix）

- **适用场景**：

- 需要与操作系统底层时钟交互、生成 UNIX 时间戳、在多线程环境下短暂暂停、对代码性能做微秒级或毫秒级测量时，使用 `time` 模块更为直接高效。
- 对于更高级的日期与时间处理（如日期算术、时区转换、格式化大量日期、微秒级别操作），则推荐使用 `datetime` 模块结合第三方库。

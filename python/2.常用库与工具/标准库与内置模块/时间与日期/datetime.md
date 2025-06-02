## 概述

Python 中的 `datetime` 模块是用于处理日期（date）和时间（time）的标准库，提供了一系列类和函数，帮助我们方便地进行日期和时间的表示、计算、解析、格式化以及时区（timezone）管理。与早期的 `time` 模块相比，`datetime` 模块更为面向对象、易于阅读和维护，并且统一了日期与时间的概念，使得相关操作更加直观。

下面我们按照模块的组成部分、核心类及常用功能，逐步进行详细讲解，并配合示例代码以加深理解。

---

## 模块结构概览

`datetime` 模块的核心类主要包括：

- `date`：表示**年月日**（年、月、日）的类。
- `time`：表示**时分秒微秒**（时、分、秒、微秒）的类，不含日期部分。
- `datetime`：结合了 `date` 和 `time`，可以完整地表示某个时刻（年月日时分秒微秒）。
- `timedelta`：表示两个日期/时间之间的时差（duration），可以进行加减运算。
- `tzinfo`（抽象基类）和 `timezone`（实现类）：用于处理时区信息，`timezone` 是 `tzinfo` 的子类，表示固定偏移的时区。
- `strptime()` 与 `strftime()`：提供将**字符串** **↔** **日期/时间对象**之间相互转换的函数。

除此以外，还有一些辅助的常量和函数，如 `MINYEAR`、`MAXYEAR`（支持的最小/最大年份），以及 `date.today()`、`datetime.now()` 等方便调用的类方法/函数。

---

## 1. `date` 类

### 1.1 定义与初始化

```python
from datetime import date

# 创建一个 date 对象
d = date(2025, 6, 2)   # 年：2025，月：6，日：2
```

- `date(year, month, day)`：构造一个日期对象，年必须在 MINYEAR（1）和 MAXYEAR（9999）之间，月为 1–12，日根据对应月份决定（1–28/29/30/31）。

### 1.2 常用属性

假设有 `d = date(2025, 6, 2)`，则：

- `d.year`：年份（2025）
- `d.month`：月份（6）
- `d.day`：日（2）
- `d.weekday()`：返回星期几，Monday=0, …, Sunday=6。示例：`date(2025, 6, 2).weekday()` → 0（星期一）。
- `d.isoweekday()`：返回 ISO 标准下的星期几，Monday=1, …, Sunday=7。示例：`date(2025, 6, 2).isoweekday()` → 1。
- `d.isoformat()`：以字符串 `"YYYY-MM-DD"` 形式输出，比如 `"2025-06-02"`。

### 1.3 类方法

- `date.today()`：获取当前本地日期（不含时间部分）。

```python
today = date.today()
```

- `date.fromtimestamp(timestamp)`：通过 Unix 时间戳（秒数）构造对应本地时间的日期部分。

```python
import time
ts = time.time()             # 当前时间戳
d = date.fromtimestamp(ts)   # 对应的本地日期
```

- `date.fromordinal(ordinal)`：将格里高利历（Gregorian calendar）的序数（从 1 年 1 月 1 日算起的天数编号）转换为对应的 date 对象。

```python
d = date.fromordinal(737052)  # 对应 2025-06-02
```

### 1.4 实例方法

- `replace(year=?, month=?, day=?)`：返回一个修改了指定年月日后的新 date 对象。

```python
d = date(2025, 6, 2)
d2 = d.replace(year=2024, month=12)  # 2024-12-02
```

- `timetuple()`：将 date 转为类似 `time.struct_time` 的对象，常用于与老式的 `time` 模块配合。
- `toordinal()`：将 date 转成序数（从 1 年 1 月 1 日起的天数），方便与 `fromordinal()` 互转。
- `ctime()`：返回类似 `"Mon Jun 2 00:00:00 2025"` 的简易字符串，时间部分全部为 0。

### 1.5 示例

```python
from datetime import date

# 创建
d = date(2025, 6, 2)
print(d.year, d.month, d.day)         # 2025 6 2
print(d.weekday(), d.isoweekday())     # 0 1

# 今天的日期
today = date.today()
print(today)                           # 例如 2025-06-02

# 日期替换
d2 = d.replace(day=15)
print(d2)                              # 2025-06-15

# 与 timedelta 相加
from datetime import timedelta
d3 = d + timedelta(days=10)
print(d3)                              # 2025-06-12

# 序数与 ordinal
ord_val = d.toordinal()
print(ord_val)                         # 737052
d_from_ord = date.fromordinal(ord_val)
print(d_from_ord)                      # 2025-06-02
```

---

## 2. `time` 类

`time` 类用于表示一天当中的时间，不包含日期部分。常见场景是需要单独存储时、分、秒、微秒，或与 `datetime` 组合。

### 2.1 定义与初始化

```python
from datetime import time

# 创建 time 对象
t = time(14, 30, 15, 123456)  # 14:30:15.123456
```

- 构造函数签名：`time(hour, minute, second, microsecond, tzinfo=None, fold=0)`。
- `hour`：0–23，`minute`：0–59，`second`：0–59，`microsecond`：0–999999。
- 可选 `tzinfo` 用于指定时区信息（参见后文时区部分），`fold` 用于处理夏令时切换等歧义时刻。

### 2.2 常用属性

假设 `t = time(14, 30, 15, 123456)`：

- `t.hour`：获取小时（14）
- `t.minute`：获取分钟（30）
- `t.second`：获取秒（15）
- `t.microsecond`：获取微秒（123456）
- `t.tzinfo`：与之关联的时区信息，若未指定则为 `None`。
- `t.isoformat()`：字符串形式 `"HH:MM:SS.mmmmmm"`，例如 `"14:30:15.123456"`。
- `t.replace(hour=?, minute=?, second=?, microsecond=? ...)`：返回新的 `time` 对象，替换指定字段。

### 2.3 注意事项

- 由于 `time` 对象不含日期，因此不能直接与 `timedelta` 相加。若需要在某个日期基础上加减时间，需要先组合为 `datetime` 对象。

### 2.4 示例

```python
from datetime import time

t1 = time(9, 0)           # 09:00:00
t2 = time(18, 45, 30)     # 18:45:30
print(t1, t2)             # 09:00:00 18:45:30

# 带微秒
t3 = time(23, 59, 59, 999999)
print(t3.isoformat())     # "23:59:59.999999"

# 替换部分字段
t4 = t2.replace(hour=19, minute=0)
print(t4)                 # 19:00:30
```

---

## 3. `datetime` 类

`datetime` 类同时包含日期和时间，是日常开发中最常用的类。它支持完整的“年-月-日 时:分:秒.微秒”表示，并且可与 `timedelta`、时区结合使用。

### 3.1 定义与初始化

```python
from datetime import datetime

dt = datetime(2025, 6, 2, 14, 30, 15, 123456)
```

- 构造函数签名：`datetime(year, month, day, hour=0, minute=0, second=0, microsecond=0, tzinfo=None, fold=0)`。
- 如果只传前三个参数，则时间部分默认都是 0，对应某天的“0 点 0 分 0 秒”。

### 3.2 获取当前时间

- `datetime.now(tz=None)`：获取当前本地日期与时间（若提供 `tz`，则为对应时区下的当前时间）。

```python
dt1 = datetime.now()               # 本地时区，含年月日时分秒
dt2 = datetime.now(tz=timezone.utc)  # UTC 时间
```

- `datetime.utcnow()`：获取当前 UTC 时间的 `datetime` 对象（相当于 `now(timezone.utc)`，但 `tzinfo` 为 `None`，需注意时区歧义）。
- `datetime.today()`：等价于 `datetime.now()`，但更侧重于返回“本地时间”的语义。

### 3.3 常用属性

假设有 `dt = datetime(2025, 6, 2, 14, 30, 15, 123456)`：

- 与 `date` 共享属性：

- `dt.year`、`dt.month`、`dt.day`
- `dt.weekday()`、`dt.isoweekday()`、`dt.isoformat()`

- 与 `time` 共享属性：

- `dt.hour`、`dt.minute`、`dt.second`、`dt.microsecond`
- `dt.time()`：返回对应的 `time` 对象（即 `time(14, 30, 15, 123456)`）。

- `dt.date()`：返回对应的 `date` 对象（即 `date(2025, 6, 2)`）。
- `dt.tzinfo`：关联的时区信息，若为 `None` 表示“天真时间”（naive datetime）。
- `dt.fold`：用于解决重叠时段（如夏令时倒退时刻）的问题，一般情况下不需要手动设置。
- `dt.utcoffset()` / `dt.dst()` / `dt.tzname()`：与时区相关的方法，返回与 UTC 的偏移（timedelta）、夏令时偏移以及时区名称。

### 3.4 类方法

- `datetime.fromtimestamp(timestamp, tz=None)`：通过 Unix 时间戳（秒）创建 `datetime` 对象。若指定 `tz`，则返回该时区下对应的本地时间；否则返回本地时区对应的“天真时间”。

```python
import time
ts = time.time()
dt_local = datetime.fromtimestamp(ts)                   # 本地时区
dt_utc = datetime.fromtimestamp(ts, tz=timezone.utc)    # UTC
```

- `datetime.fromordinal(ordinal)`：与 `date.fromordinal` 类似，但返回的时间部分默认为 0。
- `datetime.strptime(date_string, format)`：将字符串解析为 `datetime` 对象，常用于将文本日期转换成可操作的对象。

```python
dt = datetime.strptime("2025-06-02 14:30:15", "%Y-%m-%d %H:%M:%S")
```

- `datetime.combine(date_obj, time_obj, tzinfo=None)`：由已存在的 `date` 与 `time` 组合成一个 `datetime` 对象。

```python
from datetime import date, time, datetime
d = date(2025, 6, 2)
t = time(8, 0, 0)
dt = datetime.combine(d, t)   # 2025-06-02 08:00:00
```

### 3.5 实例方法

- `replace(...)`：类似于 `date.replace`，可替换其中的任意字段，返回新对象。

```python
dt = datetime(2025, 6, 2, 14, 30)
dt2 = dt.replace(hour=9, minute=0)  # 2025-06-02 09:00:00
```

- `astimezone(tz)`：将该 `datetime`（必须是带 `tzinfo` 的“智慧”时间）转换到另一个时区下。

```python
from datetime import datetime, timezone, timedelta
dt_utc = datetime(2025, 6, 2, 12, 0, tzinfo=timezone.utc)
tz_shanghai = timezone(timedelta(hours=8))
dt_sh = dt_utc.astimezone(tz_shanghai)  # 2025-06-02 20:00:00+08:00
```

- `timestamp()`：返回一个浮点数，表示从 Unix 纪元（1970-01-01 00:00:00 UTC）到该时间点的秒数（可用于与 `fromtimestamp` 互转）。**注意**：若 `datetime` 是“天真”时间，则会先假设它是本地时间再换算到 UTC。
- `timetuple()`、`utctimetuple()`：类似于 `date.timetuple()`，生成 `time.struct_time` 可与老式 `time` 模块结合。

### 3.6 格式化与解析

- **格式化（**`**strftime**`**）**将 `datetime` 对象转换为字符串，常用格式符号：

```perl
%Y  四位数年份
%m  两位数月份（01–12）
%d  两位数日期（01–31）
%H  24 小时制小时（00–23）
%I  12 小时制小时（01–12）
%M  两位数分钟（00–59）
%S  两位数秒（00–59）
%f  微秒（000000–999999）
%a  本地化后的星期缩写（如 Mon）
%A  本地化后的星期全称（如 Monday）
%b  本地化后的月份缩写（如 Jun）
%B  本地化后的月份全称（如 June）
%p  AM/PM 标识
%z  时区偏移（如 +0800）
%Z  时区名称（如 CST）
%j  年内第几天（001–366）
%U  年内第几个星期（周日作为一周开始）（00–53）
%W  年内第几个星期（周一作为一周开始）（00–53）
```

例如：

```python
from datetime import datetime
dt = datetime(2025, 6, 2, 14, 30, 15)
formatted = dt.strftime("%Y-%m-%d %H:%M:%S")
# formatted == "2025-06-02 14:30:15"
```

- **解析（**`**strptime**`**）**将满足给定格式的字符串解析回 `datetime` 对象，需要保证字符串与格式完全匹配，否则会抛出 `ValueError`。

```python
from datetime import datetime
s = "2025-06-02 14:30:15"
dt = datetime.strptime(s, "%Y-%m-%d %H:%M:%S")
```

- **注意**：`strptime` 会产生“天真”时间，若需要解析带时区标识（如 `+08:00`），在 Python 3.7+ 可以使用格式符 `%z`。例如：

```python
s2 = "2025-06-02 14:30:15+0800"
dt2 = datetime.strptime(s2, "%Y-%m-%d %H:%M:%S%z")
# dt2.tzinfo == datetime.timezone(timedelta(hours=8))
```

---

## 4. `timedelta` 类

### 4.1 定义与初始化

`timedelta` 表示两个日期/时间之间的“持续时长”。可用于与 `date`、`datetime` 做加减运算。

```python
from datetime import timedelta

# 创建一个时长对象
td1 = timedelta(days=5, hours=3, minutes=30, seconds=10)
```

- 构造函数签名：`timedelta(days=0, seconds=0, microseconds=0, milliseconds=0, minutes=0, hours=0, weeks=0)`，各参数可叠加，最终内部会统一转换为天数、秒数和微秒数等表示。

### 4.2 基本运算

假设有 `d = date(2025, 6, 2)`，则：

- `d + timedelta(days=10)` → `date(2025, 6, 12)`
- `d - timedelta(weeks=1)` → `date(2025, 5, 26)`

对于 `datetime` 对象：

```python
from datetime import datetime, timedelta

dt = datetime(2025, 6, 2, 14, 30)
dt2 = dt + timedelta(hours=2, minutes=15)
# dt2 == datetime(2025, 6, 2, 16, 45)
```

- 两个 `datetime` 相减，得到一个 `timedelta`：

```python
dt1 = datetime(2025, 6, 10, 0, 0)
dt2 = datetime(2025, 6, 2, 12, 0)
diff = dt1 - dt2   # diff 是 timedelta(days=7, hours=12)
```

### 4.3 属性与方法

对于一个 `timedelta` 对象 `td = timedelta(days=2, hours=5, minutes=10)`：

- `td.days`：天数部分（2）
- `td.seconds`：剩余的秒数（5 小时 + 10 分钟 = 5_3600 + 10_60 = 18600 秒）
- `td.microseconds`：微秒部分
- `td.total_seconds()`：将整个 `timedelta` 转换为以秒为单位的浮点数（2 天 + 5 小时 + 10 分钟 → (2_86400 + 5_3600 + 10*60) = 189,000 秒）。

### 4.4 注意事项

- `timedelta` 不支持“月”或“年”的概念，因为它们并非固定时长（闰年、闰月等）。如需加减“一个月”或“一年”，需要结合业务逻辑手动处理，比如用 `date.replace` 或第三方库（如 `dateutil.relativedelta`）。

---

## 5. 时区相关：`tzinfo` 与 `timezone`

默认情况下，`date`、`time`、`datetime` 对象都属于“天真时间”（naive），即不含任何时区信息。若涉及时区（如从一个时区转换到另一个时区，或者表示 UTC 时间），就要添加 `tzinfo`。

### 5.1 `tzinfo` 抽象基类

`tzinfo` 是一个抽象基类，用于自定义时区。一般情况下，不需要直接继承它，而是使用内置的 `timezone` 或第三方库（如 `pytz`、`dateutil`）来获得更强大的时区支持。

### 5.2 内置 `timezone`

从 Python 3.2 开始，标准库提供了 `datetime.timezone` 类，用于表示**固定偏移**的时区（例如 UTC+8、UTC-5）。它继承自 `tzinfo`，主要用法如下：

```python
from datetime import datetime, timezone, timedelta

# 定义一个 UTC+8 的时区
tz_shanghai = timezone(timedelta(hours=8))

# 创建一个带时区的 datetime
dt = datetime(2025, 6, 2, 14, 30, tzinfo=tz_shanghai)

# 打印
print(dt)                  # 2025-06-02 14:30:00+08:00

# 将带时区的时间转换到另一个时区（如 UTC）
dt_utc = dt.astimezone(timezone.utc)
print(dt_utc)             # 2025-06-02 06:30:00+00:00
```

- `timezone.utc`：相当于 `timezone(timedelta(0))`，表示 UTC 时区。
- `astimezone()`：将“智慧时间”（aware datetime）从当前时区转换到目标时区。注意，只有带时区信息的 `datetime` 才能调用，否则会抛错。

### 5.3 生成带时区的当前时间

- `datetime.now(timezone.utc)`：获取当前 UTC 时间，tzinfo 为 `UTC`。
- `datetime.now(tz=timezone(timedelta(hours=8)))`：获取当前 UTC+8 时间（比如北京时间/上海时间）。
- `datetime.utcnow()`：仅获取当前 UTC 时间，但**不带** tzinfo（天真时间），需小心使用；若想要带 tzinfo，应该使用 `now(timezone.utc)`。

### 5.4 时区夏令时与第三方库

`datetime.timezone` 只能表示固定偏移，不会自动处理夏令时（DST）切换。如果需要处理复杂的时区（如美国各州的夏令时规则），建议使用第三方库：

- `**pytz**`（需单独安装）：提供了全量 IANA 时区数据库，且有 `.localize()`、`.normalize()` 等方法来处理 DST。
- `**dateutil**`（`python-dateutil`，需安装）：通过 `dateutil.tz` 提供的 `gettz()` 来获取本地或指定时区，也能自动调整夏令时。

示例（以 `dateutil` 为例）：

```python
from datetime import datetime
from dateutil import tz

# 获取“America/New_York”时区对象
tz_ny = tz.gettz("America/New_York")

# 生成带时区的 datetime
dt_ny = datetime(2025, 3, 9, 2, 30, tzinfo=tz_ny)
# 2025 年 3 月 9 日凌晨 2:30 是美国开始夏令时的时刻，dateutil 会自动调整为 3:30

print(dt_ny)
```

---

## 6. 常用操作与示例

下面以一些具体场景示例来巩固对 `datetime` 模块的理解。

### 6.1 获取当前日期和时间

```python
from datetime import date, datetime, timezone

# 当前本地日期
today = date.today()
print("Today:", today)               # 2025-06-02

# 当前本地时间（天真时间）
now_local = datetime.now()
print("Now Local:", now_local)       # 2025-06-02 14:30:15.123456

# 当前 UTC 时间（带 tzinfo）
now_utc = datetime.now(timezone.utc)
print("Now UTC:", now_utc)           # 2025-06-02 08:30:15.123456+00:00
```

### 6.2 日期/时间算术

```python
from datetime import datetime, timedelta

dt = datetime(2025, 6, 2, 14, 30)

# 加 3 天 5 小时
delta = timedelta(days=3, hours=5)
dt_new = dt + delta
print(dt_new)    # 2025-06-05 19:30

# 计算两个 datetime 之间的差值
dt1 = datetime(2025, 7, 1, 0, 0)
dt2 = datetime(2025, 6, 2, 14, 30)
diff = dt1 - dt2
print(diff)      # e.g., 28 days, 9:30:00  （具体视时差而定）
print("Days:", diff.days)            # 28
print("Seconds:", diff.seconds)      # 34200  (9*3600 + 30*60)
```

### 6.3 格式化（输出为字符串）

```python
from datetime import datetime

dt = datetime(2025, 12, 31, 23, 59, 59)

# 标准格式
s1 = dt.strftime("%Y-%m-%d %H:%M:%S")
print(s1)       # "2025-12-31 23:59:59"

# 自定义格式
s2 = dt.strftime("今天是 %Y 年 %m 月 %d 日，时间：%I:%M %p")
# 例如 “今天是 2025 年 12 月 31 日，时间：11:59 PM”
print(s2)
```

### 6.4 解析（将字符串转成 datetime）

```python
from datetime import datetime

s = "2025/06/02 14-30-15"
# 注意格式要与字符串完全匹配
dt_parsed = datetime.strptime(s, "%Y/%m/%d %H-%M-%S")
print(dt_parsed)  # 2025-06-02 14:30:15
```

### 6.5 时区转换示例

```python
from datetime import datetime, timedelta, timezone

# 定义时区：UTC+8
tz_sh = timezone(timedelta(hours=8))
# 定义时区：UTC-4
tz_ny = timezone(timedelta(hours=-4))

# 本地化：创建一个带时区的 datetime（假定时间即为对应时区时间）
dt_sh = datetime(2025, 6, 2, 12, 0, tzinfo=tz_sh)
print("Shanghai time:", dt_sh)  # 2025-06-02 12:00:00+08:00

# 转换到纽约时间
dt_ny = dt_sh.astimezone(tz_ny)
print("New York time:", dt_ny) # 2025-06-02 00:00:00-04:00

# 将纽约时间转换回 UTC
dt_utc = dt_ny.astimezone(timezone.utc)
print("UTC time:", dt_utc)     # 2025-06-02 04:00:00+00:00
```

### 6.6 结合 `dateutil` 处理夏令时

如果不想手动维护各地时区、夏令时切换规则，可使用 `python-dateutil`：

```python
from datetime import datetime
from dateutil import tz

# 指定时区
tz_ny = tz.gettz("America/New_York")

# 创建一个“天真时间”并赋予 tzinfo
dt_ny = datetime(2025, 11, 2, 1, 30)  # 注意：11 月初有可能正是夏令时切换的时段
dt_ny = dt_ny.replace(tzinfo=tz_ny)

print(dt_ny)  
# 如果 2025-11-02 1:30 对应的时间是夏令时向标准时切换时，dateutil 会自动判断 fold=1 或 fold=0。
```

---

## 7. 常见注意事项与最佳实践

1. **天真时间（Naive） vs. 智慧时间（Aware）**

- **天真时间（naive datetime）**：没有 `tzinfo`，只能做本地（或假定统一）时间计算，无法安全地进行跨时区运算。
- **智慧时间（aware datetime）**：包含 `tzinfo`，可进行不同时区之间的准确转换。
- **建议**：在涉及时区或跨时区业务时，尽量使用“智慧时间”；若只是本地简单应用，也可保留“天真时间”。

2. **不要直接手动构造夏令时切换时刻**

- 当构造某个处于夏令时切换边界的时间时，若只用 `timezone(timedelta(...))`，无法检测夏令时；如需准确转换，使用 `pytz` 或 `dateutil`。

3. **避免随意使用** `**datetime.utcnow()**`

- `datetime.utcnow()` 返回“天真”的 UTC 时间，如果随后与本地时间做比较，容易引起混淆。推荐使用 `datetime.now(timezone.utc)`，返回带 tzinfo 的 UTC 时间。

4. **在解析/格式化时，保证格式字符串与实际字符串完全匹配**

- `strptime` 对格式十分严格，一旦有多余空格或符号不同，就会报错。

5. **留意** `**timedelta**` **的范围**

- `timedelta` 支持的最大天数是 `999999999`（即大约 2.7 亿年），但在业务中更常见的“年”和“月”概念，需要自行处理或依赖第三方库。

---

## 8. 小结与示例演练

下面给出一个综合示例：

**需求**：读取一个用户输入的本地时间字符串，格式为 `"YYYY-MM-DD HH:MM"`，假定它是中国上海时间，然后将其转换为对应的 UTC 时间，并输出两种格式：`"YYYY/MM/DD HH:MM:SS UTC"` 以及 ISO 8601（带时区偏移）。

```python
from datetime import datetime, timezone, timedelta

# 1. 用户输入的字符串
input_str = "2025-06-02 20:45"

# 2. 解析为天真时间
dt_naive = datetime.strptime(input_str, "%Y-%m-%d %H:%M")
# 3. 假设这是上海时间（UTC+8），将 tzinfo 设为 UTC+8
tz_sh = timezone(timedelta(hours=8))
dt_sh = dt_naive.replace(tzinfo=tz_sh)
# 4. 转换为 UTC
dt_utc = dt_sh.astimezone(timezone.utc)

# 5. 格式化输出
# 5.1 格式一： "YYYY/MM/DD HH:MM:SS UTC"
s1 = dt_utc.strftime("%Y/%m/%d %H:%M:%S UTC")
print(s1)  # 如 "2025/06/02 12:45:00 UTC"

# 5.2 ISO 8601 格式（datetime.isoformat() 会自动加上时区偏移）
s2 = dt_sh.isoformat()  # e.g. "2025-06-02T20:45:00+08:00"
print(s2)
```

运行效果示例：

```yaml
2025/06/02 12:45:00 UTC
2025-06-02T20:45:00+08:00
```

这个示例展示了从字符串解析到时区标记、再到 UTC 转换、最后格式化输出的完整流程。在实际应用中，类似的操作非常常见，比如日志文件时间统一、跨时区事件调度等。

---

## 9. 额外扩展：与老式 `time` 模块的区别

- `time.time()` 返回自 Unix 纪元（1970-01-01 00:00:00 UTC）以来的秒数（浮点数）；而对应的 `datetime.fromtimestamp()` 则可将其转为更易读的 `datetime` 对象。
- `time.localtime()`、`time.gmtime()` 返回 `struct_time`，而 `datetime` 能直接提供面向对象的操作方式。
- 若需要高性能计算时间戳，常保留 `time` 模块做底层调用；但对于日常业务逻辑，推荐使用 `datetime` 的方法。

---

### 10. 小结

1. **核心类**：`date`、`time`、`datetime`、`timedelta`、`tzinfo`/`timezone`。
2. **常见算术**：使用 `timedelta` 来加减 `date`/`datetime`。
3. **格式化与解析**：`strftime` 输出为字符串，`strptime` 将字符串解析为对象，格式符号需严格匹配。
4. **时区管理**：内置 `timezone` 可处理固定偏移；对复杂时区需求，建议借助 `pytz` 或 `dateutil`。
5. **注意**：区分“天真时间”（naive）与“智慧时间”（aware），尽量避免混用，尤其在跨时区场景下。

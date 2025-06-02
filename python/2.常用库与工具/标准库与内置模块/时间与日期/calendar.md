## 概述

Python 内置的 `calendar` 模块提供了一系列与日历计算、格式化和显示相关的工具函数与类。相比于更底层的 `time` 或 `datetime`，`calendar` 专注于“日历视图”——以星期排列的月份、年份以及与闰年、月份长度相关的算法。使用 `calendar` 模块，可以方便地：

- 判断某年是否为闰年、计算闰年之间的天数差
- 生成某个月或某年的“月视图”，即一个以嵌套列表或字符串表示的表格
- 支持不同的星期起始日（如周一或周日）
- 输出文本（日历）或 HTML 格式的日历
- 根据区域设置（locale）输出本地化的星期和月份名称

下面我们从模块的常量、函数、主要类与用法示例等方面，逐步展开讲解。

---

## 一、常量与数据结构

### 1.1 星期与月份常量

- **星期相关常量**（均为整数，范围 0–6）：

- `calendar.MONDAY == 0`
- `calendar.TUESDAY == 1`
- `calendar.WEDNESDAY == 2`
- `calendar.THURSDAY == 3`
- `calendar.FRIDAY == 4`
- `calendar.SATURDAY == 5`
- `calendar.SUNDAY == 6`

用于指定“每周从哪一天开始”，例如在生成日历时，是从 “周一” 还是 “周日” 开始。

- **月份相关常量**（均为 1–12）：

- `calendar.JANUARY == 1`
- `calendar.FEBRUARY == 2`
- …
- `calendar.DECEMBER == 12`

虽然在大多数函数中直接用整数代表月份即可，但使用这些常量能让代码可读性更高。

### 1.2 本地化名称

- `calendar.month_name`：长度为 13 的序列，索引从 1 到 12 分别是各个月份的全称，第 0 项为空字符串。例如：

```python
import calendar
print(calendar.month_name[6])  # 输出 "June"（在默认英语环境中）
```

- `calendar.month_abbr`：长度为 13 的序列，索引 0 为空，1–12 为各月缩写（“Jan”, “Feb”, …）。
- `calendar.day_name`：长度为 7 的序列，0–6 分别对应星期一到星期日的全称，例如 “Monday”, “Tuesday” …
- `calendar.day_abbr`：长度为 7 的序列，索引为星期的缩写（“Mon”, “Tue”, …）。

这些名称会随操作系统或 Python 本地化设置（`locale`）而变化，便于生成本地化日历。

---

## 二、闰年相关函数

### 2.1 `calendar.isleap(year)`：判断是否为闰年

```python
import calendar

print(calendar.isleap(2024))  # True（2024 年是闰年）
print(calendar.isleap(2100))  # False（2100 虽可被 4 整除，但为世纪年且不可被 400 整除，不是闰年）
```

闰年规则：

1. 年份能被 4 整除且不能被 100 整除 ⇒ 闰年
2. 或能被 400 整除 ⇒ 闰年  
    其他情况均非闰年。

### 2.2 `calendar.leapdays(y1, y2)`：计算两年之间闰年数

- **签名**：`leapdays(y1, y2)` 返回从 `y1`（含）到 `y2`（不含）之间的闰年个数。

```python
import calendar

# 计算从 2000 年（含）到 2025 年（不含）之间有多少个闰年
print(calendar.leapdays(2000, 2025))  # 输出 6，分别是 2000、2004、2008、2012、2016、2020
```

注意：参数区间是 **左闭右开**，`y1 ≤ year < y2`。

---

## 三、基本函数

### 3.1 `calendar.monthrange(year, month)`：获取某年某月第一天是星期几，以及该月共有多少天

- **签名**：`monthrange(year, month)` 返回一个二元组 `(first_weekday, days_in_month)`

- `first_weekday`：0–6 的整数，表示该月的第一天在一周中的索引。默认一周以周一为索引 0，周日为索引 6。
- `days_in_month`：该月总共包含的天数（28–31）。

```python
import calendar

# 例如 2025 年 6 月
first_weekday, days = calendar.monthrange(2025, 6)
print(first_weekday, days)
# 输出 (6, 30)，表示 2025-06-01 是星期日（索引 6），该月有 30 天
```

### 3.2 `calendar.monthcalendar(year, month)`：生成月视图的矩阵（嵌套列表）

- **签名**：`monthcalendar(year, month)` 返回一个由周列表组成的列表。每个子列表长度为 7，代表该周从周一到周日对应的日期数字，若该格不属于当月则填 0。

例如，我们查看 2025 年 6 月的“月视图”：

```python
import calendar

mc = calendar.monthcalendar(2025, 6)
for week in mc:
    print(week)
```

输出：

```csharp
[0, 0, 0, 0, 0, 0, 1]
[2, 3, 4, 5, 6, 7, 8]
[9, 10, 11, 12, 13, 14, 15]
[16, 17, 18, 19, 20, 21, 22]
[23, 24, 25, 26, 27, 28, 29]
[30, 0, 0, 0, 0, 0, 0]
```

- 第一行 0–5 都是 0，表示 6 月的前几天不属于本月；最后一个元素是 1（2025-06-01 是星期日）。
- 最后一行只有第一个元素 30 表示 6 月 30 日，后面是 0 填充。

这种结构非常适合用于文本或图形化地绘制“月历表”。

### 3.3 `calendar.weekday(year, month, day)`：获取某个日期对应的星期索引

- **签名**：`weekday(year, month, day)` 返回 0–6 的整数，表示该日期是周几（周一=0，…，周日=6）。

```python
import calendar

print(calendar.weekday(2025, 6, 2))  # 输出 0，表示 2025-06-02 是星期一
```

### 3.4 `calendar.calendar(year, w=2, l=1, c=6, m=3)`：生成整年日历的文本表示

- **签名**：

```python
calendar.calendar(year, w=2, l=1, c=6, m=3)
```

- `year`：年份
- `w`：每个日期字段的宽度（最少字符数，默认 2）
- `l`：每个月日历的行距（行与行之间的空行数，默认 1）
- `c`：每个月日历之间的列间距（默认 6 个空格）
- `m`：每行展示的月份数量（默认 3，即一年分为 4 行，每行 3 个月）

- 返回值：一个多行的字符串，每行包含若干个月份并排的“文本日历”。

示例打印 2025 年整年日历（文本形式）：

```python
import calendar

print(calendar.calendar(2025))
```

输出示例（节选）：

```css
                              2025

      January                   February                   March
Mo Tu We Th Fr Sa Su      Mo Tu We Th Fr Sa Su      Mo Tu We Th Fr Sa Su
       1  2  3  4  5                        1  2      1  2  3  4  5  6  7
 6  7  8  9 10 11 12       3  4  5  6  7  8  9       8  9 10 11 12 13 14
...
```

### 3.5 `calendar.prmonth(year, month, w=2, l=1)` 和 `calendar.prcal(year)`：直接打印而非返回字符串

- `prmonth(year, month, w=2, l=1)`：与 `month(year, month)` 类似，但直接向标准输出打印格式化后的当月日历（无返回值）。
- `prcal(year)`：向标准输出打印整年日历（无返回值）。

示例：

```python
import calendar

# 打印 2025 年 6 月的文本日历
calendar.prmonth(2025, 6)
```

输出：

```css
     June 2025
Mo Tu We Th Fr Sa Su
                   1
 2  3  4  5  6  7  8
 9 10 11 12 13 14 15
16 17 18 19 20 21 22
23 24 25 26 27 28 29
30
```

---

## 四、高级类：`Calendar`、`TextCalendar`、`HTMLCalendar`

要对日历做更灵活的处理，比如自定义星期起始日、按某种顺序迭代日期、生成 HTML 格式日历等，可以使用以下类。

### 4.1 `calendar.Calendar`：基础日历迭代器

- **签名**：`Calendar(firstweekday=0)`

- `firstweekday`：一周从哪天开始，默认为 0（周一）。可用上述常量如 `calendar.SUNDAY`、`calendar.MONDAY` 等。

#### 4.1.1 方法

1. `**itermonthdays(year, month)**`

- 返回一个迭代器，依次产生当月日历格子中的“日期数字”或 0。与 `monthcalendar()` 类似，但不会分行，只会输出一维序列。
- 例如：

```python
from calendar import Calendar

cal = Calendar(firstweekday=calendar.SUNDAY)
days = list(cal.itermonthdays(2025, 6))
print(days)
```

如果 `firstweekday=SUNDAY`，则 2025 年 6 月第一个格子是周日，序列可能类似：

```bash
[1, 2, 3, 4, 5, 6, 7,    # 从第一个周日开始
 8, 9, 10, ... 30,
 0, 0, 0, 0, 0, 0]
```

末尾的 0 补足了完整的六周日历格。

2. `**itermonthdays2(year, month)**`

- 类似于 `itermonthdays`，但每个元素都是 `(day, weekday_index)` 的二元组。如果该格不属于当月，则 `day = 0`。
- 示例：

```python
for day, wd in Calendar().itermonthdays2(2025, 6):
    print(day, wd)
# 例如 (0, 0) 表示某行的第一个格（周一）不属于当月；(1, 6) 表示 1 日是周日。
```

3. `**itermonthdates(year, month)**`

- 返回一个迭代器，依次产生当月网格中每一格对应的完整 `datetime.date` 对象。注意：如果格子不属于当月，`date().month` 可能是前一个月或下一个月。
- 示例：

```python
from datetime import date
for d in Calendar().itermonthdates(2025, 6):
    print(d, d.month)
# 一旦 d.month != 6，就表示该格属于临近的上一月或下一月。
```

4. `**itermonthweeks(year, month)**`

- 生成 6 个子列表（每周一个列表），每个列表包含 7 个 `(day, weekday_index)` 元组，与 `monthdays2calendar` 相似，适合分行处理。

5. `**monthdayscalendar(year, month)**`**、**`**monthdays2calendar(year, month)**`**、**`**monthdatescalendar(year, month)**`

- 这三个方法分别返回：

- `monthdayscalendar`：与 `monthcalendar()` 等价，返回嵌套列表，每项是 0 或日期数字。
- `monthdays2calendar`：返回分行的列表，每个子列表元素为 `(day, weekday_index)`。
- `monthdatescalendar`：返回分行的列表，每个子列表元素为对应的 `date` 对象。

#### 4.1.2 示例

```python
from calendar import Calendar
from datetime import date

cal = Calendar(firstweekday=calendar.MONDAY)

# itermonthdays2 示例：打印 6 月各格日期与星期索引
for day, wd in cal.itermonthdays2(2025, 6):
    if day == 0:
        continue  # 跳过非当月格子
    print(f"2025-06-{day:02d} 是星期 {wd}（周一=0）")

# itermonthdates 示例：打印 6 月完整网格日期
for d in cal.itermonthdates(2025, 6):
    print(d, end=" ")
# 输出样例：2025-05-26 2025-05-27 ... 2025-06-30 2025-07-01 ...
```

### 4.2 `calendar.TextCalendar`：生成纯文本格式的月历或年历

- **签名**：`TextCalendar(firstweekday=0)`

- 同样可指定 `firstweekday`，但方法返回的是已格式化的字符串。

#### 4.2.1 方法

1. `**formatmonth(year, month, w=0, l=0)**`

- 返回一个字符串，表示该年该月的纯文本日历，行宽 `w`（数字字段宽度，默认与系统当前宽度匹配）和行间距 `l`（月份标题与日期表之间的空行数，默认 0）。
- 示例：

```python
from calendar import TextCalendar

tc = TextCalendar()
s = tc.formatmonth(2025, 6)
print(s)
```

输出（默认 `w=2, l=1`）：

```css
   June 2025
Mo Tu We Th Fr Sa Su
              1
 2  3  4  5  6  7  8
 9 10 11 12 13 14 15
16 17 18 19 20 21 22
23 24 25 26 27 28 29
30
```

2. `**formatyear(year, w=2, l=1, c=6, m=3)**`

- 返回一个字符串，表示整年日历的纯文本表示，与 `calendar(year, w, l, c, m)` 类似，但由类方法生成。
- 示例：

```python
from calendar import TextCalendar
yc = TextCalendar(firstweekday=calendar.SUNDAY)
print(yc.formatyear(2025))
```

会展示从周日开始的一年 12 个月分布。

3. `**prmonth(year, month, w=0, l=0)**`**、**`**pryear(year, w=2, l=1, c=6, m=3)**`

- 与 `formatmonth`、`formatyear` 类似，但直接打印到标准输出，无返回值。

### 4.3 `calendar.HTMLCalendar`：生成 HTML 格式的日历

- **签名**：`HTMLCalendar(firstweekday=0)`

- 用于生成网页中可嵌入的 HTML `<table>` 结构日历。

#### 4.3.1 方法

1. `**formatmonth(year, month, withyear=True)**`

- 返回一个字符串，即完整的 HTML `<table>` 标签，包含当月日历。
- 例子：

```python
from calendar import HTMLCalendar
hc = HTMLCalendar()
html = hc.formatmonth(2025, 6)
print(html)
```

输出类似：

```html
<table border="0" cellpadding="0" cellspacing="0" class="month">
<tr><th colspan="7" class="month">June 2025</th></tr>
<tr><th class="mon">Mon</th><th class="tue">Tue</th> ... <th class="sun">Sun</th></tr>
<tr><td class="noday">&nbsp;</td> ... <td class="day">1</td></tr>
...
</table>
```

- 可以通过 CSS 为类名（如 `.month`, `.day`, `.noday`）添加样式，实现网页日历的定制外观。

2. `**formatyear(year, width=3)**`

- 返回完整 HTML 表格，将一年的 12 个月按 `width` 列排列，每个月用一个小表格。
- 例如 `hc.formatyear(2025, width=4)` 会按四列三行排列各个月。

3. `**formatweekday(i)**`**、**`**formatweekheader()**`**、**`**formatweek(week)**` 等底层方法，用于自定义单个星期格的 HTML 结构。如果要扩展，覆写这些方法即可。

### 4.4 `calendar.LocaleTextCalendar` 与 `calendar.LocaleHTMLCalendar`：本地化日历

- **签名**：

```python
LocaleTextCalendar(firstweekday=0, locale=None)
LocaleHTMLCalendar(firstweekday=0, locale=None)
```

- `locale` 参数为字符串，如 `'zh_CN.UTF-8'`、`'de_DE'` 或 None。
- 当指定 `locale`，会使用相应的本地化设置，自动输出相应语言的月份名称与星期名称。

示例（假设系统支持中文）：

```python
import locale
from calendar import LocaleTextCalendar

# 切换到中文环境（需要系统安装相应 locale）
locale.setlocale(locale.LC_TIME, 'zh_CN.UTF-8')

ctc = LocaleTextCalendar(firstweekday=calendar.MONDAY, locale='zh_CN.UTF-8')
print(ctc.formatmonth(2025, 6))
```

输出示例：

```markdown
      2025年6月
周一 周二 周三 周四 周五 周六 周日
                   1
 2   3   4   5   6   7   8
 9  10  11  12  13  14  15
16  17  18  19  20  21  22
23  24  25  26  27  28  29
30
```

---

## 五、区域设置（Locale）与本地化

`calendar` 模块的本地化主要依赖于 Python 的 `locale` 模块。通过修改进程级别的区域设置，可以让 `calendar` 输出符合本地语言和文化习惯的月份、星期名称。

### 5.1 使用 `locale` 模块

```python
import locale
from calendar import TextCalendar, LocaleTextCalendar

# 查询当前区域设置
print(locale.getdefaultlocale())  # e.g., ('en_US', 'UTF-8')

# 设置为中文（简体，UTF-8 编码）
locale.setlocale(locale.LC_TIME, 'zh_CN.UTF-8')

# 直接用 TextCalendar 也会受到 SYSTEM LOCALE 的影响
tc = TextCalendar(firstweekday=calendar.MONDAY)
print(tc.formatmonth(2025, 6))

# 或者显式指定 LocaleTextCalendar
ctc = LocaleTextCalendar(firstweekday=calendar.SUNDAY, locale='zh_CN.UTF-8')
print(ctc.formatyear(2025))
```

注意事项：

- 在不同操作系统上，可用的 locale 名称不同。Linux/Unix 系统通常有完整的 `xx_XX.UTF-8` 列表；Windows 可能需要 `'Chinese_People's Republic of China.936'` 等形式。
- 切换 `locale` 会影响整个 Python 进程对日期、时间、数字的格式化行为，务必谨慎。

---

## 六、常见示例与应用场景

### 6.1 判断当月天数与第一天星期

```python
import calendar

def get_month_info(year, month):
    first_wd, days = calendar.monthrange(year, month)
    # 将 weekday 索引转换成字符串
    weekday_name = calendar.day_name[first_wd]
    return first_wd, weekday_name, days

fw, wname, d = get_month_info(2025, 6)
print(f"2025年6月第一天是星期 {fw}（{wname}），本月共有 {d} 天。")
```

输出：

```yaml
2025年6月第一天是星期 6（Sunday），本月共有 30 天。
```

### 6.2 以嵌套列表形式获取某月日期布局

```python
import calendar

year, month = 2025, 6
mc = calendar.monthcalendar(year, month)
print(f"{year}年{month}月的月视图（0 表示空格）：")
for week in mc:
    print(week)
```

输出：

```csharp
2025年6月的月视图（0 表示空格）：
[0, 0, 0, 0, 0, 0, 1]
[2, 3, 4, 5, 6, 7, 8]
[9, 10, 11, 12, 13, 14, 15]
[16, 17, 18, 19, 20, 21, 22]
[23, 24, 25, 26, 27, 28, 29]
[30, 0, 0, 0, 0, 0, 0]
```

### 6.3 生成 HTML 日历并嵌入网页

假设需要将 2025 年 6 月的日历以 HTML 表格形式嵌入网页，可使用 `HTMLCalendar`：

```python
from calendar import HTMLCalendar

hc = HTMLCalendar(firstweekday=calendar.MONDAY)
html_calendar = hc.formatmonth(2025, 6)

# 将 html_calendar 写入文件，或嵌入到 Web 框架模板中
with open('jun_2025_calendar.html', 'w', encoding='utf-8') as f:
    f.write(f"""
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
      <meta charset="UTF-8">
      <title>2025年6月日历</title>
      <style>
        table {{ border-collapse: collapse; }}
        .month {{ background-color: #f2f2f2; font-weight: bold; }}
        .day {{ text-align: center; padding: 5px; border: 1px solid #ddd; }}
        .noday {{ text-align: center; padding: 5px; border: 1px solid #ddd; background-color: #eaeaea; }}
      </style>
    </head>
    <body>
      {html_calendar}
    </body>
    </html>
    """)
print("HTML 日历已生成：jun_2025_calendar.html")
```

打开生成的文件即可看到美化后的月历。

### 6.4 计算两日期之间的工作日数量

`calendar` 模块并没有直接提供计算两个日期之间工作日数量的函数，但可以利用 `Calendar.itermonthdates()` 或 `monthcalendar()` 再结合 `datetime` 来实现。示例：

```python
import calendar
from datetime import date

def workday_count(start_date, end_date, weekdays=(0,1,2,3,4)):
    """
    计算从 start_date（含）到 end_date（含）之间，星期一(0)到星期五(4)这几个工作日的总数。
    """
    if start_date > end_date:
        start_date, end_date = end_date, start_date

    total = 0
    curr = start_date
    while curr <= end_date:
        if curr.weekday() in weekdays:
            total += 1
        curr = curr.fromordinal(curr.toordinal() + 1)
    return total

# 示例：2025-06-01 至 2025-06-30 之间的工作日数
cnt = workday_count(date(2025, 6, 1), date(2025, 6, 30))
print(f"2025-06-01 到 2025-06-30 之间共有 {cnt} 个工作日。")
```

当然，如果要跨越多个月或更灵活，可以按月分批调用 `monthcalendar()`，根据每一周的列表判断哪些格子属于当月且 `weekday_index<5`。

---

## 七、常见注意事项与最佳实践

1. `**monthcalendar()**` **的零填充**

- `monthcalendar(year, month)` 返回的列表中，若某个格子不属于当月会以 0 表示。使用时需过滤掉 0，否则在与实际日期做运算、显示时需判断。

2. `**firstweekday**` **的选择**

- 默认一周从“星期一”开始（索引 0），但很多国家更习惯从“星期日”。可通过 `calendar.setfirstweekday(calendar.SUNDAY)` 改变全局设置，或在类实例化时显式指定。

3. `**LocaleTextCalendar**` **依赖系统** `**locale**`

- 如果你的系统没有安装对应的语言或区域设置，初始化会失败。可以先通过 `locale.setlocale(locale.LC_TIME, 'zh_CN.UTF-8')` 等在代码中切换，或者安装相应的 `locale`。

4. **HTML 日历的定制**

- `HTMLCalendar` 生成的 HTML `<table>` 中使用了默认的 CSS 类名（`.month`, `.day`, `.noday`, `.weekday` 等）。如果要定制样式，只需在外部 CSS 中针对这些类名进行定义即可。

5. **跨年和多月计算时要注意年/月边界**

- 例如，用 `itermonthdates()` 会把前一月或下一月的日期也包含进来，需要用 `date.month == target_month` 来过滤。

---

## 八、小结

- **模块核心**：主要包含与“闰年判断”（`isleap`、`leapdays`）和“日历生成/格式化”相关的函数与类。
- **重要函数**：

- `isleap(year)`、`leapdays(y1, y2)` → 闰年计算
- `monthrange(year, month)` → 当月的第一天是周几、共多少天
- `monthcalendar(year, month)` → 嵌套列表表示当月的日历布局
- `weekday(year, month, day)` → 返回某日对应星期索引
- `calendar(year, w, l, c, m)` / `prmonth` / `prcal` → 文本日历输出

- **主要类**：

- `Calendar`, `TextCalendar`, `HTMLCalendar` → 可按需自定义一周起始日、得到结构化数据或生成文本/HTML 格式
- `LocaleTextCalendar`, `LocaleHTMLCalendar` → 本地化日历输出

- **常见场景**：

- 需要在命令行或日志中打印一个月/一年的“图形化”日历
- 在网页中嵌入日历控件或展示
- 做报表时生成包含日期网格的表格
- 判断闰年、计算跨年跨度的天数

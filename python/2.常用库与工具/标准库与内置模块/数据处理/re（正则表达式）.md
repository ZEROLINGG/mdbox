## 一、`re` 模块概述

- `re` 模块提供对正则表达式（Regular Expression）的支持，用于在字符串中进行模式匹配、搜索、替换、切分等操作。
- 正则表达式是一种描述字符模式的语言，能够用一行“式子”表示复杂的匹配逻辑，适用于验证、提取和改写文本内容。
- 在 Python 中，`re` 模块封装了 C 语言层面的正则引擎，因此性能较好，API 也相对完整。

---

## 二、编译与匹配流程

1. **编译（Compiling）**

- Python 中的正则表达式在首次使用时会被编译成内部表示（字节码），并缓存以供后续重复使用（最多缓存 512 个模式）。
- 通过 `re.compile(pattern, flags=0)` 可以显式地把模式字符串编译成一个正则对象（`Pattern`），这样在循环或重复匹配时可以提高性能。
- 如果直接使用 `re.search()`、`re.match()` 等顶级函数，底层也会隐式地调用编译和缓存机制。

```python
import re

# 显式编译
pat = re.compile(r'\d{3}-\d{4}')    # 匹配“xxx-xxxx”格式的简易电话号码
m = pat.search("联系：010-1234 或 021-5678")
if m:
    print(m.group())   # 输出：010-1234
```

2. **匹配流程（Matching）**

- `**Pattern**` **对象**：由 `compile()` 返回，包含了可复用的匹配方法，如 `search()`、`match()`、`findall()`、`finditer()`、`split()`、`sub()` 等。
- `**Match**` **对象**：调用匹配方法（如 `search()`、`match()` 等）后返回。`Match` 对象封装了匹配位置、分组信息，可通过 `group()`、`groups()`、`start()`、`end()`、`span()` 等方法获取具体结果。
- **缓存机制**：如果多次使用相同 pattern 而未显式编译，Python 会自动缓存并复用，节省反复编译的开销。

---

## 三、正则表达式语法与常用用法

### 1. 字符匹配基础

- **普通字符**：如英文字母、数字等，直接与文本中的字符一一对应。
- **点号（**`**.**`**）**：匹配除换行符（`\n`）之外的任意单个字符。若启用 `DOTALL` 标志，则可匹配包括换行在内的所有字符。
- **转义字符（**`**\**`**）**：用于引用特殊字符或表示元字符。例如，`\d` 表示数字（等价于 `[0-9]`），`\w` 表示字母/数字/下划线（等价于 `[A-Za-z0-9_]`），`\s` 表示空白字符（包含空格、制表符、换行等）。要匹配普通符号或元字符本身，需要在它们前面加 `\`，如 `\.` 表示匹配“点号本身”。

#### 常见预定义字符类别

|      |                                                               |
| ---- | ------------------------------------------------------------- |
| 语法   | 含义                                                            |
| `\d` | 匹配一个数字字符，等价于 `[0-9]`                                          |
| `\D` | 匹配一个非数字字符，等价于 `[^0-9]`                                        |
| `\w` | 匹配一个字母、数字或下划线字符，等价于 `[A-Za-z0-9_]`                            |
| `\W` | 匹配一个非字母数字下划线字符，等价于 `[^A-Za-z0-9_]`                            |
| `\s` | 匹配一个空白字符（空格、制表符、换行、回车等），等价于 `[ \t\n\r\f\v]`                   |
| `\S` | 匹配一个非空白字符                                                     |
| `.`  | 匹配除换行符 `\n`<br><br>之外的任意字符（若启用 `DOTALL`<br><br>，则匹配任何字符，包括换行） |

### 2. 量词（Quantifiers）：重复次数的控制

量词用于指定前一个原子（单个字符、字符类或分组）的重复次数。默认情况下，量词为“贪婪”（greedy），尽可能多地匹配。

|         |                                       |                                                              |
| ------- | ------------------------------------- | ------------------------------------------------------------ |
| 量词      | 含义                                    | 示例                                                           |
| `*`     | 匹配前一个原子 0 次或多次（相当于 `{0,}`<br><br>）    | `a*`<br><br>匹配 `''`<br><br>, `'a'`<br><br>, `'aaaa'`         |
| `+`     | 匹配前一个原子 1 次或多次（相当于 `{1,}`<br><br>）    | `a+`<br><br>匹配 `'a'`<br><br>, `'aaaa'`<br><br>，但不匹配 `''`     |
| `?`     | 匹配前一个原子 0 次或 1 次（相当于 `{0,1}`<br><br>） | `a?`<br><br>匹配 `''`<br><br>或 `'a'`                           |
| `{m}`   | 精确匹配前一个原子 m 次                         | `a{3}`<br><br>匹配 `'aaa'`                                     |
| `{m,n}` | 匹配前一个原子至少 m 次，最多 n 次                  | `a{2,4}`<br><br>匹配 `'aa'`<br><br>, `'aaa'`<br><br>, `'aaaa'` |
| `{m,}`  | 匹配前一个原子至少 m 次                         | `a{2,}`<br><br>匹配 `'aa'`<br><br>, `'aaa'`<br><br>等           |

#### 贪婪 vs 非贪婪

- 默认量词为**贪婪**：尽可能多地匹配，再回溯以满足整个表达式。
- 在量词后面加 `?`，即可变为**非贪婪**（reluctant/`lazy`），尽可能少地匹配。例如：

- `a.*b`：从第一个 `a` 开始，匹配到最后一个 `b`（若原文中有多个），范围最大。
- `a.*?b`：从第一个 `a` 开始，匹配到最靠近的第一个 `b`，范围最小。

实际对比：

```python
import re

text = "a123b456b"
print(re.search(r'a.*b', text).group())    # 匹配 'a123b456b'
print(re.search(r'a.*?b', text).group())   # 匹配 'a123b'
```

### 3. 边界（Anchors）与位置匹配

- `^`：匹配字符串的开始（若启用 `MULTILINE`，也匹配每行开头）。
- `$`：匹配字符串的结束（若启用 `MULTILINE`，也匹配每行结尾，注意在末尾 `\n` 前匹配）。
- `\b`：匹配“单词边界”（word boundary），即字母、数字或下划线与非字母数字下划线之间的位置。
- `\B`：匹配非单词边界。

示例：

```python
import re

s = "Hello world\nabc def"
print(re.findall(r'^abc', s))     # []，因为 'abc' 并非整个字符串开头
print(re.findall(r'^abc', s, re.MULTILINE))  # ['abc']，匹配第二行行首
print(re.findall(r'world$', s))   # []，因为末尾有换行
print(re.findall(r'world$', s, re.MULTILINE))  # ['world']
```

### 4. 分组（Grouping）与捕获（Capturing）／非捕获（Non-capturing）

#### 捕获分组

- 使用圆括号 `()` 把子模式“捕获”起来，可通过 `Match.group()` 或 `Match.groups()` 获取各分组对应的匹配内容。
- 分组编号是根据左括号出现的顺序，从 1 开始依次递增。

```python
import re

text = "姓名：张三， 电话：123-4567"
m = re.search(r'姓名：(.+?)，\s*电话：(\d{3}-\d{4})', text)
if m:
    print(m.group(0))   # 完整匹配：'姓名：张三， 电话：123-4567'
    print(m.group(1))   # 第一个分组：'张三'
    print(m.group(2))   # 第二个分组：'123-4567'
    print(m.groups())   # 返回 ('张三', '123-4567')
```

#### 非捕获分组

- 如果只想对子模式进行“分组”或添加量词，但不想捕获内容，可使用 `(?:...)`。
- 这不会出现在 `groups()` 返回值中，也不会占用分组编号。

```python
import re

# 如果不想捕获国旗前缀“+86-”，只想提取手机号主体
m = re.search(r'(?:\+86-)?(\d{3}-\d{4})', "联系电话：+86-123-4567")
print(m.group(1))   # '123-4567'，没有将“+86-”作为分组返回
```

#### 命名分组

- 使用 `(?P<name>...)` 可以对分组命名，后续可通过分组名取值，也可在正则内部使用反向引用 `(?P=name)`。

```python
import re

text = "用户：alice，邮箱：alice@example.com"
pattern = r'用户：(?P<username>\w+)，邮箱：(?P<email>[\w.@]+)'
m = re.search(pattern, text)
if m:
    print(m.group('username'))   # 'alice'
    print(m.group('email'))      # 'alice@example.com'
```

- 反向引用示例（匹配 XML/HTML 样式标签，要求开标签和闭标签名字一致）：

```python
import re

text = "<div>内容</div> <span>忽略</div>"
pattern = r'<(?P<tag>\w+)>(.*?)</(?P=tag)>'
print(re.findall(pattern, text))  # 仅匹配 '<div>内容</div>'，不匹配不对称的 '</div>'
```

### 5. 字符类（Character Classes）与集合

- **方括号** `**[]**` 用于定义字符集合，匹配其中任何一个字符：

- `[abc]`：匹配 `a`、`b` 或 `c`。
- `[a-z]`：匹配任意小写字母。
- `[A-Za-z0-9_]`：等价于 `\w`。
- `[^0-9]`：匹配任何非数字字符。

```python
import re

print(re.findall(r'[0-9]', "a1b2c3"))        # ['1', '2', '3']
print(re.findall(r'[A-Za-z]+', "Hello123"))  # ['Hello']
print(re.findall(rA-Za-z0-9]+', "Hello, 123!"))  # [', ', '!']
```

- **POSIX 风格**（并非所有 `'re'` 实现都支持，但 Python 中支持）：

- `[:digit:]` 等价于 `\d`，例如 `[[:digit:]]` 与 `\d` 相同。不过在 Python 标准 `re` 中并不推荐使用 POSIX 内置字符类，直接使用 `\d`、`\w` 等更为常见。

### 6. 模式修饰符（Flags / Modifiers）

可以在编译正则或直接在顶级函数中通过 `flags=` 参数，或在模式字符串开头插入 `(?iLmsux)` 形式来改变匹配行为。常用选项包括：

|   |   |
|---|---|
|标志|描述|
|`re.IGNORECASE`<br><br>/ `re.I`|忽略大小写匹配|
|`re.MULTILINE`<br><br>/ `re.M`|使 `^`<br><br>匹配行首，`$`<br><br>匹配行尾（而不仅仅是整个字符串的首尾）|
|`re.DOTALL`<br><br>/ `re.S`|使 `.`<br><br>匹配包括换行符在内的所有字符|
|`re.VERBOSE`<br><br>/ `re.X`|允许在正则里写注释并使用空白字符增强可读性（会忽略未转义的空格、换行，并可插入 `#`<br><br>注释）|
|`re.ASCII`<br><br>/ `re.A`|使 `\w`<br><br>, `\W`<br><br>, `\b`<br><br>, `\B`<br><br>, `\d`<br><br>, `\D`<br><br>, `\s`<br><br>, `\S`<br><br>等只匹配 ASCII 范围内的字符|
|`re.DEBUG`<br><br>/ `re.U`|调试模式，会打印正则解析过程的中间信息|

示例（多行忽略大小写匹配）：

```python
import re

text = "Hello\nWorld\nHELLO\nworld"
pattern = re.compile(r'^hello', re.IGNORECASE | re.MULTILINE)
print(re.findall(pattern, text))  # ['Hello', 'HELLO']
```

### 7. 常用顶级函数

除了通过 `re.compile()` 得到 `Pattern` 对象后调用其方法，也可以直接使用顶级函数，这些函数会自动调用缓存中预编译的模式。

#### 7.1 `re.match(pattern, string, flags=0)`

- 从字符串开头开始匹配，如果开头不符合模式，则返回 `None`；否则返回一个 `Match` 对象。
- 只匹配第一个位置，不会在其他位置搜索。
- 等价于 `re.compile(pattern, flags).match(string)`。

```python
import re

print(re.match(r'\d+', "123abc").group())   # '123'
print(re.match(r'\d+', "abc123"))           # None
```

#### 7.2 `re.search(pattern, string, flags=0)`

- 在整个字符串中搜索第一个符合模式的位置，找到则返回 `Match` 对象，否则返回 `None`。
- 等价于 `re.compile(pattern, flags).search(string)`。

```python
import re

print(re.search(r'\d+', "abc123def").group())  # '123'
```

#### 7.3 `re.findall(pattern, string, flags=0)`

- 返回字符串中所有非重叠匹配（以列表形式），如果模式包含捕获分组，则返回分组内容组成的元组列表。
- 等价于：对于每次 `search()`，将匹配到的内容添加到列表中，直到搜索完毕。

```python
import re

print(re.findall(r'\d+', "a1b2c3"))  # ['1', '2', '3']
# 含分组时：
print(re.findall(r'(\d)([A-Za-z])', "1a2b3c"))  # [('1','a'),('2','b'),('3','c')]
```

#### 7.4 `re.finditer(pattern, string, flags=0)`

- 与 `findall()` 类似，但返回一个迭代器，迭代器的每个元素都是一个 `Match` 对象，可获取更多详细信息（如起始位置、分组位置等）。

```python
import re

for m in re.finditer(r'\d+', "a1b22c333"):
    print(f"{m.group()} 在位置 {m.span()}")
# 输出：
# 1 在位置 (1, 2)
# 22 在位置 (3, 5)
# 333 在位置 (5, 8)
```

#### 7.5 `re.split(pattern, string, maxsplit=0, flags=0)`

- 按照能够匹配的子串将字符串切割成列表，默认不限制切割次数 (`maxsplit=0` 表示无上限)。
- 如果模式中有捕获分组，那么这些组匹配的内容也会出现在结果列表中。

```python
import re

print(re.split(r'\s+', "Hello   world  Python"))  # ['Hello', 'world', 'Python']
print(re.split(r'(\d+)', "a1b22c"))  # ['a', '1', 'b', '22', 'c']
```

#### 7.6 `re.sub(pattern, repl, string, count=0, flags=0)`

- 在 `string` 中，将所有匹配 `pattern` 的子串替换为 `repl`，返回替换后的新字符串。
- `repl` 可以是普通字符串，也可以是一个回调函数 `func(match_obj)`，返回要替换的内容。
- `count` 参数限制最多替换次数，默认 `0` 表示替换所有。

```python
import re

# 用星号替换所有数字
print(re.sub(r'\d+', '*', "a1b22c3"))  # 'a*b*c*'

# 使用回调函数，给所有数字加上括号
def wrap_digits(m):
    return f"[{m.group()}]"

print(re.sub(r'\d+', wrap_digits, "a1b22c3"))  # 'a[1]b[22]c[3]'
```

#### 7.7 `re.subn(pattern, repl, string, count=0, flags=0)`

- 与 `sub()` 功能相同，但返回值为 `(new_string, 替换次数)` 二元组。

```python
import re

res, num = re.subn(r'\d+', '#', "a1b22c3")
print(res, num)  # 'a#b#c#' 3
```

#### 7.8 `re.escape(string)`

- 对传入字符串中所有可能被解释为正则元字符的字符自动加上反斜杠 `\`，将其按字面意义进行匹配。
- 常用于根据用户输入动态构建正则表达式，避免特殊字符被误解析。

```python
import re

user_input = "a.b*c+?"
escaped = re.escape(user_input)  # 'a\.b\*c\+\?'
pattern = re.compile(escaped)
print(bool(pattern.search("这是 a.b*c+? 例子")))  # True
```

---

## 四、常见实用示例

### 1. 验证电子邮件地址

一个相对简单的邮箱正则示例（并非覆盖所有情况，仅供演示）：

```python
import re

email_pattern = re.compile(
    r'^[A-Za-z0-9._%+-]+@'      # 用户名部分：字母、数字、点、下划线、百分号、加号、减号等
    r'(?:[A-Za-z0-9-]+\.)+'      # 域名：多个“子域.”，如 “example.”、“subdomain.”
    r'[A-Za-z]{2,}$'             # 顶级域名：至少两个字母
)

tests = ["alice@example.com", "bob.smith@sub.dom.com", "invalid@.com", "name@domain.c"]
for e in tests:
    print(e, bool(email_pattern.match(e)))
# 输出：
# alice@example.com True
# bob.smith@sub.dom.com True
# invalid@.com False
# name@domain.c False
```

### 2. 提取 HTML 标签内容

虽然不建议用正则解析复杂的 HTML，但简单场景可以：

```python
import re

html = "<div>第一行内容</div><span>第二行</span>"
pattern = re.compile(r'<(\w+)>(.*?)</\1>', re.DOTALL)  
# (\w+) 捕获标签名，\1 反向引用，(.*?) 非贪婪匹配内容，DOTALL 让 . 匹配换行

for m in pattern.finditer(html):
    tag, content = m.group(1), m.group(2)
    print(tag, "=>", content)
# 输出：
# div => 第一行内容
# span => 第二行
```

### 3. 将文本按多个分隔符切分

假设要将字符串按逗号、分号、空格等多种分隔符切分：

```python
import re

text = "apple,pear;banana grape\torange"
parts = re.split(r'[,\s;]+', text)
print(parts)  # ['apple', 'pear', 'banana', 'grape', 'orange']
```

### 4. 验证手机号（示例：国内 11 位手机号）

```python
import re

phone_pattern = re.compile(r'^1[3-9]\d{9}$')
tests = ["13812345678", "12345678901", "159abc67890"]
for p in tests:
    print(p, bool(phone_pattern.match(p)))
# 输出：
# 13812345678 True
# 12345678901 False
# 159abc67890 False
```

### 5. 替换文本中特定关键词

将文本中的敏感词（如“色情”、“赌博”）替换为“***”：

```python
import re

text = "请不要参与赌博或传播色情内容。"
pattern = re.compile(r'赌博|色情')
cleaned = pattern.sub("***", text)
print(cleaned)  # '请不要参与***或传播***内容。'
```

---

## 五、进阶技巧

### 1. 使用 `(?P<name>...)` 与 `(?P=name)` 处理嵌套与反向引用

- 命名分组结合反向引用可用于匹配成对出现的内容，如括号、引号等。
- 示例：匹配同时成对的单引号或双引号字符串内容。

```python
import re

text = "他说：'这是单引号'，她说：\"这是双引号\"，还有 '不闭合 但不匹配"
pattern = re.compile(r'(?P<quote>["\'])(.*?)\1')  
# (?P<quote>["\'])：捕获一个引号（单或双），命名为 quote；\1 代表与之相同的引号
for m in pattern.finditer(text):
    print("引号类型：", m.group('quote'), "内容：", m.group(2))
# 输出：
# 引号类型： ' 内容： 这是单引号
# 引号类型： " 内容： 这是双引号
```

### 2. 零宽断言（Lookahead / Lookbehind）

零宽断言用于在不消耗字符的前提下，检查某位置前后是否满足某种条件。分为前瞻（lookahead）和后顾（lookbehind）两类。

#### 前瞻（Lookahead）

- `(?=...)`：正向前瞻——当前位置后面必须匹配 `...` 才算成功，但不消耗字符。
- `(?!...)`：负向前瞻——当前位置后面不能匹配 `...`。

示例：匹配后面跟着“USD”的数字，但不包含“USD”：

```python
import re

text = "100USD or 200 EUR, 300USD"
pattern = re.compile(r'\d+(?=USD)')
print(re.findall(pattern, text))  # ['100', '300']
```

#### 后顾（Lookbehind）

- `(?<=...)`：正向后顾——当前位置前面必须匹配 `...`，但不消耗字符。
- `(?<!...)`：负向后顾——当前位置前面不能匹配 `...`。

示例：匹配以“USD”结尾且前面有数字的金额（只取数字部分）：

```python
import re

text = "100USD or 200 EUR, 300USD"
pattern = re.compile(r'(?<=USD)\d+')   # 这其实倒过来，不符合常见需求；更常见的是：(?<= )\d+(?=USD)
# 更常见：匹配前面是数字，后面跟着 USD 的数字
pattern = re.compile(r'(?<=\b)\d+(?=USD)')
print(re.findall(pattern, text))  # ['100', '300']
```

后顾断言要注意：在 Python 正则中，后顾断言的子模式长度必须固定（即无法写可变长度的后顾，如 `(?<=\d+)` 会报错）。

### 3. 使用 `re.VERBOSE`（`re.X`）增强可读性

在复杂模式中，可借助此标志插入空格或注释，使表达式更易维护。例如：

```python
import re

# 匹配 IPv4 地址
ipv4_pattern = re.compile(r'''
    ^
    (?:25[0-5]|2[0-4]\d|[01]?\d?\d)   # 第一段：0-255
    \.
    (?:25[0-5]|2[0-4]\d|[01]?\d?\d)   # 第二段
    \.
    (?:25[0-5]|2[0-4]\d|[01]?\d?\d)   # 第三段
    \.
    (?:25[0-5]|2[0-4]\d|[01]?\d?\d)   # 第四段
    $
''', re.VERBOSE)

tests = ["192.168.0.1", "255.255.255.255", "256.100.0.1"]
for ip in tests:
    print(ip, bool(ipv4_pattern.match(ip)))
# 输出：
# 192.168.0.1 True
# 255.255.255.255 True
# 256.100.0.1 False
```

在 `re.VERBOSE` 模式下，正则内部的空白（非转义的空格、换行）会被忽略，`#` 后的内容到行末算注释。

### 4. 预编译与缓存策略

- 在需要频繁多次使用同一模式进行匹配时，**显式**调用 `re.compile()` 并复用返回的 `Pattern` 对象，可以明显减少自动编译带来的开销。
- 顶级函数如 `re.search()`、`re.match()` 会隐式调用编译并缓存，可用于少量简单场景，但不建议在极端性能敏感的循环中反复使用同字符串模式的顶级函数。

---

## 六、性能与注意事项

1. **回溯与效率**

- 设计不当的正则可能导致“回溯爆炸（catastrophic backtracking）”，即在大量文本上递归尝试不同匹配分支时耗费巨大时间，甚至造成程序假死。
- 常见导致回溯爆炸的模式有：嵌套的多种重复（如 `(a+)+`、`(.*)(.*)`）等。
- 避免过度依赖“贪婪”量词，必要时可使用非贪婪（`?`）或限定范围的量词（如 `{m,n}`）。

2. **精确性与可维护性**

- 正则表达式一旦变得冗长复杂，可读性会显著下降，可考虑拆分为多个子表达式，或者写成多行并使用 `re.VERBOSE`。
- 对于非常结构化或复杂的文本（如 HTML、XML、JSON 等），尽量使用专门的解析库（如 BeautifulSoup、ElementTree、json 模块）而不是正则，以提高可靠性。

3. **字符编码与 Unicode**

- Python 3 默认使用 Unicode 字符串，正则 `\w`、`\d`、`\s` 等在默认状态下已经支持 Unicode 类别，如果想限制为 ASCII，则可加 `re.ASCII` 标志。
- 在处理多字节语言（如中文、日文、韩文）时，注意字符范围是否包含在自定义的字符类（如 `[a-z]` 只能匹配 ASCII，而不能匹配中文）。

4. **线程安全**

- `re` 缓存机制是线程安全的，但如果在多线程中大量编译/反复正则，建议显式编译并在各线程内复用 `Pattern` 对象，以减少锁竞争。

5. **替代方案与第三方库**

- 标准库的 `re` 在大多数场景下足够使用，但如果需要更高级的 Unicode 支持（如递归模式、条件模式分支、子例程调用等）可考虑第三方库 `regex`（PyPI 包名 `regex`），其功能更丰富，性能相近。

---

## 七、常见问题与实用技巧

### 1. 如何在正则里匹配中文字符？

- 可以使用 Unicode 范围：`[\u4e00-\u9fa5]`（仅限常用汉字区段），也可以直接使用 `\w`（但 `\w` 同时匹配字母、数字、下划线等）或显式罗列。
- 示例：匹配由 2～4 个汉字组成的人名：

```python
import re

name_pattern = re.compile(r'^[\u4e00-\u9fa5]{2,4}$')
for n in ["张三", "李小龙", "王", "王小二"]:
    print(n, bool(name_pattern.match(n)))
# 输出：
# 张三 True
# 李小龙 True
# 王 False
# 王小二 True
```

### 2. 在多行字符串中提取所有符合特定模式的行

- 若想对每一行分别进行匹配，可结合 `re.MULTILINE` 标志和 `^...$` 锚点。
- 示例：从日志中提取所有包含 “ERROR” 的行：

```python
import re

log = """INFO Starting service
DEBUG Initialized
ERROR Connection failed
INFO Retrying
ERROR Timeout
"""
errors = re.findall(r'^ERROR.*$', log, re.MULTILINE)
print(errors)  # ['ERROR Connection failed', 'ERROR Timeout']
```

### 3. 匹配浮点数、整数、科学计数法

可使用如下示例模式匹配多种数字格式：

```python
import re

number_pattern = re.compile(
    r'''
    [-+]?                   # 可选符号
    (?:\d+\.\d*|\.\d+|\d+)  # 匹配浮点或整数： 123.45 | .67 | 89
    (?:[eE][-+]?\d+)?       # 可选科学计数法部分： e-10、E+5 等
    ''', re.VERBOSE)

tests = ["123", "-123.45", ".678", "+0.5e-10", "3E+8", "abc", "12.3.4"]
for x in tests:
    print(x, bool(number_pattern.fullmatch(x)))
# 输出：
# 123 True
# -123.45 True
# .678 True
# +0.5e-10 True
# 3E+8 True
# abc False
# 12.3.4 False
```

### 4. 替换时使用函数动态生成结果

- 有时替换内容依赖于匹配结果自身，可在 `re.sub()` 中传入回调函数。示例：将文本中的所有数字加 1 后再替换回去。

```python
import re

def add_one(m):
    val = int(m.group())
    return str(val + 1)

text = "a=1, b=42, c=100"
result = re.sub(r'\d+', add_one, text)
print(result)  # 'a=2, b=43, c=101'
```

### 5. 使用原始字符串（Raw String）避免多重转义

- 在 Python 中，正则字符串往往会包含大量的反斜杠 `\`。为了避免 Python 先对反斜杠进行转义，习惯上将正则模式写成原始字符串（以 `r'...'` 或 `r"..."`），这样可以直接把 `\n`、`\t` 等保留给正则引擎解释，而不被 Python 字面值处理。
- 例如，要匹配一个反斜杠 `\` 本身，则可以写成 `r'\\'`；如果不加 `r` 前缀，就需要写成 `'\\\\'`。

---

## 八、总结

1. **核心对象**

- `Pattern`：通过 `re.compile(pattern, flags)` 构造，提供匹配、搜索、替换、切分等多种方法。
- `Match`：匹配成功时返回，通过 `group()`、`span()`、`groups()` 等方法获取匹配信息。

2. **常用顶级函数**

- `re.match()`：从字符串开头匹配。
- `re.search()`：在字符串任意位置寻找第一个符合的子串。
- `re.findall()`：返回所有符合的子串（列表形式）。
- `re.finditer()`：返回所有符合的子串（迭代器形式，元素为 `Match` 对象）。
- `re.split()`：按照匹配内容切分字符串。
- `re.sub()` / `re.subn()`：替换所有匹配子串。

3. **语法要点**

- 熟练使用量词（`*`, `+`, `?`, `{m,n}`）控制重复。
- 掌握贪婪与非贪婪量词（`.*` vs `.*?`）的区别。
- 了解锚点（`^`, `$`, `\b`）及其在多行模式下的变化。
- 掌握分组与捕获（`()`、`(?:...)`、`(?P<name>...)`）以及反向引用。
- 运用零宽断言（`(?=...)`, `(?<=...)`, `(?!...)`, `(?<!...)`）实现复杂位置判断。

4. **进阶与优化**

- 使用 `re.VERBOSE` 提高可读性；用 `re.IGNORECASE`、`re.MULTILINE`、`re.DOTALL` 等标志灵活控制匹配行为。
- 避免复杂的回溯模式，防止“回溯爆炸”，保持表达式简洁明了。
- 在高频匹配场景下显式编译正则并复用 `Pattern` 对象，以减少编译开销。
# Python re模块详细讲解

## 一、re模块简介

re模块是Python的标准库，提供了正则表达式的支持。正则表达式是一种强大的文本模式匹配工具。

```python
import re
```

## 二、常用元字符

### 1. 基础元字符

```python
# . 匹配任意单个字符（除换行符）
pattern = r'a.b'
print(re.findall(pattern, 'acb adb a\nb a*b'))  # ['acb', 'adb', 'a*b']

# ^ 匹配字符串开头
pattern = r'^hello'
print(re.match(pattern, 'hello world'))  # 匹配成功

# $ 匹配字符串结尾
pattern = r'world$'
print(re.search(pattern, 'hello world'))  # 匹配成功

# * 匹配前面的字符0次或多次
pattern = r'ab*'
print(re.findall(pattern, 'a ab abb abbb'))  # ['a', 'ab', 'abb', 'abbb']

# + 匹配前面的字符1次或多次
pattern = r'ab+'
print(re.findall(pattern, 'a ab abb abbb'))  # ['ab', 'abb', 'abbb']

# ? 匹配前面的字符0次或1次
pattern = r'ab?'
print(re.findall(pattern, 'a ab abb'))  # ['a', 'ab', 'ab']

# {n,m} 匹配前面的字符n到m次
pattern = r'a{2,4}'
print(re.findall(pattern, 'a aa aaa aaaa aaaaa'))  # ['aa', 'aaa', 'aaaa', 'aaaa']
```

### 2. 字符类

```python
# [] 字符集，匹配其中任意一个字符
pattern = r'[abc]'
print(re.findall(pattern, 'apple banana cherry'))  # ['a', 'b', 'a', 'a', 'a', 'c']

# [^] 否定字符集
pattern = r'[^abc]'
print(re.findall(pattern, 'apple'))  # ['p', 'p', 'l', 'e']

# 预定义字符类
# \d 数字 [0-9]
# \D 非数字 [^0-9]
# \w 字母数字下划线 [a-zA-Z0-9_]
# \W 非字母数字下划线
# \s 空白字符（空格、制表符、换行符等）
# \S 非空白字符

text = "Hello123 World_456!"
print(re.findall(r'\d+', text))  # ['123', '456']
print(re.findall(r'\w+', text))  # ['Hello123', 'World_456']
print(re.findall(r'\s', text))   # [' ']
```

## 三、主要函数详解

### 1. re.match() - 从字符串开头匹配

```python
# 基本用法
pattern = r'hello'
text = 'hello world'
result = re.match(pattern, text)

if result:
    print(result.group())  # hello
    print(result.span())   # (0, 5)
    print(result.start())  # 0
    print(result.end())    # 5

# match只匹配开头
print(re.match(r'world', 'hello world'))  # None
```

### 2. re.search() - 搜索整个字符串

```python
# 搜索第一个匹配
text = 'hello world, hello python'
result = re.search(r'hello', text)
print(result.group())  # hello (只返回第一个)

# 搜索中间的内容
result = re.search(r'world', text)
print(result.group())  # world
```

### 3. re.findall() - 查找所有匹配

```python
text = 'hello world, hello python, hello re'
results = re.findall(r'hello', text)
print(results)  # ['hello', 'hello', 'hello']

# 提取所有数字
text = 'I have 3 apples and 5 oranges, total 8 fruits'
numbers = re.findall(r'\d+', text)
print(numbers)  # ['3', '5', '8']
```

### 4. re.finditer() - 返回迭代器

```python
text = 'hello world, hello python'
results = re.finditer(r'hello', text)

for match in results:
    print(f"Found: {match.group()} at position {match.span()}")
# Found: hello at position (0, 5)
# Found: hello at position (13, 18)
```

### 5. re.sub() - 替换匹配内容

```python
# 基本替换
text = 'hello world'
new_text = re.sub(r'world', 'Python', text)
print(new_text)  # hello Python

# 替换多个
text = 'apple apple apple'
new_text = re.sub(r'apple', 'orange', text, count=2)  # 只替换前2个
print(new_text)  # orange orange apple

# 使用函数进行替换
def double_number(match):
    return str(int(match.group()) * 2)

text = 'I have 3 apples and 5 oranges'
new_text = re.sub(r'\d+', double_number, text)
print(new_text)  # I have 6 apples and 10 oranges
```

### 6. re.split() - 分割字符串

```python
# 基本分割
text = 'apple,banana;orange|grape'
result = re.split(r'[,;|]', text)
print(result)  # ['apple', 'banana', 'orange', 'grape']

# 限制分割次数
result = re.split(r'[,;|]', text, maxsplit=2)
print(result)  # ['apple', 'banana', 'orange|grape']
```

## 四、分组和捕获

### 1. 基本分组

```python
# 使用括号创建分组
pattern = r'(\d{4})-(\d{2})-(\d{2})'
text = 'Today is 2024-03-15'
match = re.search(pattern, text)

if match:
    print(match.group())   # 2024-03-15 (完整匹配)
    print(match.group(1))  # 2024 (第一组)
    print(match.group(2))  # 03 (第二组)
    print(match.group(3))  # 15 (第三组)
    print(match.groups())  # ('2024', '03', '15')
```

### 2. 命名分组

```python
# 使用 (?P<name>) 创建命名分组
pattern = r'(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})'
text = 'Today is 2024-03-15'
match = re.search(pattern, text)

if match:
    print(match.group('year'))   # 2024
    print(match.group('month'))  # 03
    print(match.group('day'))    # 15
    print(match.groupdict())     # {'year': '2024', 'month': '03', 'day': '15'}
```

### 3. 非捕获分组

```python
# 使用 (?:) 创建非捕获分组
pattern = r'(?:hello|hi) (\w+)'
text = 'hello world'
match = re.search(pattern, text)

if match:
    print(match.groups())  # ('world',) 只有一个捕获组
```

## 五、贪婪与非贪婪匹配

```python
# 贪婪匹配（默认）
text = '<div>Hello</div><div>World</div>'
pattern = r'<div>.*</div>'
print(re.findall(pattern, text))  # ['<div>Hello</div><div>World</div>']

# 非贪婪匹配（加?）
pattern = r'<div>.*?</div>'
print(re.findall(pattern, text))  # ['<div>Hello</div>', '<div>World</div>']

# 其他量词的非贪婪形式
# *? 匹配0次或多次（非贪婪）
# +? 匹配1次或多次（非贪婪）
# ?? 匹配0次或1次（非贪婪）
# {n,m}? 匹配n到m次（非贪婪）
```

## 六、断言

### 1. 前向断言

```python
# 正向前向断言 (?=...)
# 匹配后面跟着特定内容的位置
pattern = r'\d+(?=元)'
text = '价格是100元，重量是50公斤'
print(re.findall(pattern, text))  # ['100']

# 负向前向断言 (?!...)
# 匹配后面不跟着特定内容的位置
pattern = r'\d+(?!元)'
text = '价格是100元，重量是50公斤'
print(re.findall(pattern, text))  # ['10', '50']
```

### 2. 后向断言

```python
# 正向后向断言 (?<=...)
pattern = r'(?<=￥)\d+'
text = '￥100 $200'
print(re.findall(pattern, text))  # ['100']

# 负向后向断言 (?<!...)
pattern = r'(?<!￥)\d+'
text = '￥100 200'
print(re.findall(pattern, text))  # ['00', '200']
```

## 七、编译正则表达式

```python
# 编译正则表达式以提高性能
pattern = re.compile(r'\d+')

# 使用编译后的对象
text = 'I have 3 apples and 5 oranges'
print(pattern.findall(text))  # ['3', '5']

# 编译时设置标志
pattern = re.compile(r'hello', re.IGNORECASE)
print(pattern.findall('Hello HELLO hello'))  # ['Hello', 'HELLO', 'hello']
```

## 八、标志参数

```python
# re.IGNORECASE 或 re.I - 忽略大小写
pattern = r'hello'
text = 'Hello HELLO hello'
print(re.findall(pattern, text, re.I))  # ['Hello', 'HELLO', 'hello']

# re.MULTILINE 或 re.M - 多行模式
text = """first line
second line
third line"""
pattern = r'^.*line$'
print(re.findall(pattern, text, re.M))  # ['first line', 'second line', 'third line']

# re.DOTALL 或 re.S - 让.匹配包括换行符
text = 'hello\nworld'
pattern = r'hello.*world'
print(re.search(pattern, text, re.S).group())  # hello\nworld

# re.VERBOSE 或 re.X - 允许注释和空白
pattern = r'''
    \d+     # 匹配数字
    \.      # 匹配小数点
    \d+     # 匹配小数部分
'''
print(re.findall(pattern, '3.14 2.71', re.X))  # ['3.14', '2.71']
```

## 九、实用示例

### 1. 验证邮箱

```python
def validate_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

print(validate_email('user@example.com'))  # True
print(validate_email('invalid.email'))     # False
```

### 2. 提取URL

```python
text = 'Visit https://www.example.com or http://test.org for more info'
pattern = r'https?://[^\s]+'
urls = re.findall(pattern, text)
print(urls)  # ['https://www.example.com', 'http://test.org']
```

### 3. 清理HTML标签

```python
html = '<p>This is <b>bold</b> and <i>italic</i> text</p>'
clean_text = re.sub(r'<[^>]+>', '', html)
print(clean_text)  # This is bold and italic text
```

### 4. 提取和格式化电话号码

```python
def format_phone(phone):
    pattern = r'(\d{3})[-.\s]?(\d{3})[-.\s]?(\d{4})'
    match = re.search(pattern, phone)
    if match:
        return f"({match.group(1)}) {match.group(2)}-{match.group(3)}"
    return None

print(format_phone('123-456-7890'))  # (123) 456-7890
print(format_phone('123.456.7890'))  # (123) 456-7890
print(format_phone('1234567890'))    # (123) 456-7890
```

## 十、性能优化建议

1. **预编译正则表达式**：对于重复使用的模式，使用`re.compile()`
2. **使用原始字符串**：使用`r''`避免转义问题
3. **避免过度回溯**：合理使用非贪婪匹配
4. **使用非捕获组**：当不需要捕获时使用`(?:)`
5. **选择合适的函数**：如只需要判断是否匹配，使用`search()`而不是`findall()`

这个教程涵盖了re模块的主要功能和用法。通过实践这些例子，你可以掌握Python中正则表达式的使用。
## 1. csv 模块概述

- `csv` 模块是 Python 标准库之一，用于读取和写入以逗号或其他分隔符分隔的文本文件。
- 本质上，它并不是简单地按逗号拆分字符串，而是提供了“方言（dialect）”机制，根据不同格式规范（如 Excel CSV、Unix CSV 等）灵活处理分隔符、引用符、转义字符等细节。
- 主要接口：

- `csv.reader`：创建一个迭代器，每次返回一行分割后的列表（list of strings）。
- `csv.writer`：返回一个写入器，通过 `writer.writerow()` 或 `writer.writerows()` 写入条目。
- `csv.DictReader`：将每行转换为字典，键由文件头（header）决定。
- `csv.DictWriter`：以字典形式写入，每个字段对应一个键。
- `csv.register_dialect` / `csv.get_dialect` / `csv.unregister_dialect`：用于自定义方言。

---

## 2. 如何读取（Reader）CSV 文件

### 2.1 最简单的读取示例

```python
import csv

with open('data.csv', mode='r', encoding='utf-8', newline='') as f:
    reader = csv.reader(f)     # 默认方言为 'excel'
    for row in reader:
        # row 是一个列表，比如 ['Alice', '30', 'Beijing']
        print(row)
```

- `mode='r'`：以只读模式打开文件。
- `encoding='utf-8'`：指定编码，避免中文乱码。
- `newline=''`：推荐在 Python 3 中写法，避免在 Windows 平台出现多余换行。
- `csv.reader(f)`：返回一个 reader 对象，逐行读取并根据逗号分隔。

### 2.2 自定义分隔符和引用字符

假设文件使用制表符（`\t`）作为分隔符，且用单引号（`'`）作为引用（quoted）字符：

```python
import csv

with open('data_tab.csv', mode='r', encoding='utf-8', newline='') as f:
    reader = csv.reader(f, delimiter='\t', quotechar="'")
    for row in reader:
        print(row)
```

- `delimiter='\t'`：指定制表符为字段分隔符。
- `quotechar="'"`：指定单引号为引用符，用于包含带有分隔符的字段。

### 2.3 跳过文件头（Header）

如果 CSV 文件第一行是表头（列名），我们想跳过它，可以先读一行：

```python
import csv

with open('data.csv', mode='r', encoding='utf-8', newline='') as f:
    reader = csv.reader(f)
    header = next(reader)     # 读走表头行
    print("Headers:", header)
    for row in reader:
        print(row)
```

---

## 3. 如何写入（Writer）CSV 文件

### 3.1 最简单的写入示例

```python
import csv

rows = [
    ['姓名', '年龄', '城市'],
    ['Alice', 30, 'Beijing'],
    ['Bob', 25, 'Shanghai'],
    ['Charlie', 22, 'Guangzhou'],
]

with open('out.csv', mode='w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)   # 默认方言 'excel'
    for row in rows:
        writer.writerow(row)
```

- `mode='w'`：写模式，会覆盖已存在文件。
- `newline=''`：避免每行之间出现空行。
- `writer.writerow(row)`：传入一个列表，写入一行。

### 3.2 一次写入多行

```python
with open('out2.csv', mode='w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    writer.writerows(rows)   # 传入列表的列表，一次写入多行
```

### 3.3 自定义分隔符、引用符、转义符

```python
import csv

rows = [
    ['Name', 'Comment'],
    ['Alice', 'Hello, world!'],
    ['Bob', 'He said "Hi".'],
]

with open('out_custom.csv', mode='w', encoding='utf-8', newline='') as f:
    writer = csv.writer(
        f,
        delimiter=';',          # 分号分隔字段
        quotechar="'",          # 单引号作为引用符
        quoting=csv.QUOTE_MINIMAL,  # 只在必要时引用
        escapechar='\\'         # 转义字符
    )
    writer.writerows(rows)
```

- `delimiter=';'`：将分隔符设为分号。
- `quotechar="'"`：将引用符设为单引号。
- `quoting=csv.QUOTE_MINIMAL`（默认值）：如果字段中包含分隔符、引号或换行符，才添加引用符。
- `escapechar='\\'`：用于转义 quotechar 或者 delimiter 本身。

常见的 `quoting` 参数值：

- `csv.QUOTE_MINIMAL`：只有在必要时（如字段含有分隔符、换行符或 quotechar）才加引号。
- `csv.QUOTE_ALL`：所有字段都加引号。
- `csv.QUOTE_NONNUMERIC`：数字字段不加引号，其他字段加引号；读取时会把没有引用符的字段当作浮点数。
- `csv.QUOTE_NONE`：不加引用符，此时必须提供 `escapechar` 来转义字段中的分隔符。

---

## 4. Dialect 与方言定制

### 4.1 什么是 Dialect

`Dialect`（方言）用于集中定义一系列参数（如 `delimiter`、`quotechar`、`quoting`、`skipinitialspace`、`lineterminator` 等）。有助于在多个地方复用同一组格式配置。标准库自带几种方言：

- `'excel'`（默认）：以逗号分隔，双引号引用，`lineterminator='\r\n'`（Windows 风格）。
- `'excel-tab'`：以制表符 `\t` 分隔，其他同 `'excel'`。

### 4.2 自定义方言

```python
import csv

# 定义一个新方言
csv.register_dialect(
    'mydialect',
    delimiter='|',
    quotechar='"',
    quoting=csv.QUOTE_MINIMAL,
    skipinitialspace=True,
    lineterminator='\n'
)

# 使用自定义方言读取
with open('pipe_delimited.csv', mode='r', encoding='utf-8', newline='') as f:
    reader = csv.reader(f, dialect='mydialect')
    for row in reader:
        print(row)

# 使用自定义方言写入
with open('out_pipe.csv', mode='w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f, dialect='mydialect')
    writer.writerow(['field1', 'field2', 'field3'])
```

- `csv.register_dialect(name, **kwargs)`：注册新方言，`name` 为标识符。
- 常用参数：

- `delimiter`：字段分隔符。
- `quotechar`：字段引用符。
- `quoting`：引用策略（见前文）。
- `skipinitialspace`（布尔）：是否跳过字段分隔符后首个空格。
- `lineterminator`：行结束符（如 `'\n'`、`'\r\n'` 等）。
- `doublequote`（布尔）：当字段中出现 `quotechar` 时是否重复 `quotechar` 以表示转义（Excel 默认行为）。
- `escapechar`：用于当 `doublequote=False` 时，转义 `quotechar`。

### 4.3 查询与注销方言

```python
import csv

# 查询某个方言的配置信息
dialect = csv.get_dialect('excel')
print("Excel 方言的分隔符：", dialect.delimiter)

# 注销自定义方言
csv.unregister_dialect('mydialect')
```

---

## 5. DictReader 与 DictWriter 的应用

当 CSV 有表头字段时，通常更方便使用字典（`dict`）方式读取和写入。

### 5.1 使用 DictReader 读取为字典

```python
import csv

with open('data_with_header.csv', mode='r', encoding='utf-8', newline='') as f:
    reader = csv.DictReader(f)  # 自动把第一行当作字段名
    for row in reader:
        # row 是一个字典，例如 {'Name': 'Alice', 'Age': '30', 'City': 'Beijing'}
        print(row['Name'], row['Age'], row['City'])
```

- `csv.DictReader(f, fieldnames=None, restkey=None, restval=None, dialect='excel', *args, **kwargs)`：

- 如果不指定 `fieldnames`，则默认使用文件的第一行作为字段名。
- `restkey`：当某一行字段数多于 `fieldnames`，多余的部分会放在同名列表下，键为 `restkey` 对应的字符串。
- `restval`：当某一行字段数少于 `fieldnames`，缺失字段会填充为 `restval`。
- 其他参数如同 `reader`，可通过 `delimiter`、`quotechar` 等定制。

### 5.2 使用 DictWriter 以字典方式写入

```python
import csv

fieldnames = ['Name', 'Age', 'City']
rows = [
    {'Name': 'Alice', 'Age': 30, 'City': 'Beijing'},
    {'Name': 'Bob', 'Age': 25, 'City': 'Shanghai'},
    {'Name': 'Charlie', 'Age': 22, 'City': 'Guangzhou'},
]

with open('out_dict.csv', mode='w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()           # 写入表头
    for data in rows:
        writer.writerow(data)
```

- `csv.DictWriter(f, fieldnames, restval='', extrasaction='raise', dialect='excel', *args, **kwargs)`：

- `fieldnames`：必须提供写入时的字段名列表，决定字典中哪些键会写入。
- `writeheader()`：自动写入字段名作为第一行。
- `extrasaction`：对于字典中出现但 `fieldnames` 中不存在的键，可选择 `'raise'`（抛错）或 `'ignore'`（忽略）。
- `restval`：当字典缺少某些字段时，用此值填充。

---

## 6. 常见参数说明

下表汇总了 `csv.reader`/`csv.writer`/`DictReader`/`DictWriter` 中常用参数及其含义：

|   |   |   |
|---|---|---|
|参数名|作用|适用场景|
|`delimiter`|指定字段分隔符，默认为逗号 `','`|使用非逗号分隔时需要指定|
|`quotechar`|指定引用符，默认为双引号 `'"'`|需要处理包含分隔符的字段|
|`quoting`|引用策略，共有 4 个取值：  <br>`csv.QUOTE_MINIMAL`<br><br>（默认）  <br>`csv.QUOTE_ALL`<br><br>  <br>`csv.QUOTE_NONNUMERIC`<br><br>  <br>`csv.QUOTE_NONE`|控制何时添加/识别引号|
|`escapechar`|指定转义符，仅在 `quoting=csv.QUOTE_NONE`<br><br>或 `doublequote=False`<br><br>时有效|字段内出现分隔符或引用符需转义时|
|`doublequote`|布尔值，表示当字段中出现 `quotechar`<br><br>时，是否通过重复 `quotechar`<br><br>进行转义（`True`<br><br>）还是使用 `escapechar`<br><br>（需先设定）|控制引号转义方式|
|`skipinitialspace`|布尔值，表示在遇到分隔符后，是否跳过紧跟的空格，默认为 `False`|字段分隔符后出现多余空格时|
|`lineterminator`|写入文件时使用的行终止符，默认为 OS 相关（Windows 下为 `'\r\n'`<br><br>，Linux 下为 `'\n'`<br><br>）|控制输出文件的换行格式|
|`fieldnames`<br><br>（仅 Dict）|字段名列表，用于 `DictReader`<br><br>或 `DictWriter`<br><br>的初始化|以字典方式读写时必须指定|
|`restkey`<br><br>（仅 Dict）|当某行字段数多于 `fieldnames`<br><br>时，多余字段存放到 `row[restkey]`<br><br>的列表中|处理不规整、列数不一致的文件|
|`restval`<br><br>（仅 Dict）|当某行字段数少于 `fieldnames`<br><br>时，缺失字段使用此值填充|同上|
|`extrasaction`<br><br>（仅 Dict）|当字典中出现不在 `fieldnames`<br><br>中的键时，选择 `'raise'`<br><br>（报错）或 `'ignore'`<br><br>（忽略）|写入时字典与字段名不一致时|

---

## 7. Python 3 下的字符编码与换行注意事项

1. **打开文件时指定** `**newline=''**`

- Python 3 官方文档建议读取或写入 CSV 文件时，一定要用 `open(..., newline='')`，否则在 Windows 平台会出现读到空行或写入文件每行后多出空行的问题。
- 原因：`csv` 模块自己处理了换行符，如果让 Python 再做一次换行转换，容易出现混乱。

2. **字符编码（encoding）**

- 默认情况下，Python 会以系统默认编码打开文件（Windows 通常是 `cp936`，Linux 通常是 `UTF-8`）。
- 为保证跨平台、跨编辑环境的一致性，建议显式指定 `encoding='utf-8'`（如果文件是 UTF-8 编码）。
- 如果文件含有 BOM（Byte Order Mark），可使用 `encoding='utf-8-sig'` 来自动去除 BOM。

3. **二进制模式 vs 文本模式**

- 在 Python 2 中，推荐使用二进制模式 `mode='rb'` / `mode='wb'`；但在 Python 3 中，只需使用文本模式并加 `newline=''`。

---

## 8. 示例汇总与实战场景

### 8.1 将 CSV 转换为 JSON

很多场景需要把 CSV 转为 JSON。可以结合 `DictReader` 和 `json` 模块：

```python
import csv
import json

csv_file = 'employees.csv'
json_file = 'employees.json'

with open(csv_file, mode='r', encoding='utf-8', newline='') as f_csv, \
     open(json_file, mode='w', encoding='utf-8') as f_json:

    reader = csv.DictReader(f_csv)
    data_list = [row for row in reader]  # 每行是字典
    json.dump(data_list, f_json, ensure_ascii=False, indent=4)

print(f"已将 {csv_file} 转换为 {json_file}")
```

### 8.2 从列表写入包含嵌入逗号的字段

当字段本身包含逗号时，`csv` 模块会自动为该字段加上引号。例如：

```python
import csv

rows = [
    ['Name', 'Address'],
    ['Alice', '123 Main St, Apt 4'],
    ['Bob', '456 Oak St'],
]

with open('address.csv', mode='w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    writer.writerows(rows)
```

生成的 `address.csv` 内容会像：

```css
Name,Address
Alice,"123 Main St, Apt 4"
Bob,456 Oak St
```

这样确保下次读取时，`"123 Main St, Apt 4"` 会被识别为一个字段。

### 8.3 处理不同分隔符、多余空格、缺失字段

假设一行中字段数不一致，且有多余空格，我们可以结合 `skipinitialspace`、`restval`、`restkey` 等参数：

```python
import csv

# 示例文件 lines.txt 内容：
# Name | Age | City
# Alice | 30  | Beijing
# Bob |  | Shanghai
# Charlie | 22 | Guangzhou | ExtraField1 | ExtraField2

with open('lines.txt', mode='r', encoding='utf-8', newline='') as f:
    reader = csv.DictReader(
        f,
        fieldnames=['Name', 'Age', 'City'],
        delimiter='|',
        skipinitialspace=True,     # 跳过分隔符后面的空格
        restkey='Others',          # 多余字段放到 row['Others']
        restval='N/A'              # 缺失字段填充 'N/A'
    )
    for row in reader:
        print(row)
```

**输出示例：**

```bash
{'Name': 'Name', 'Age': 'Age', 'City': 'City'}  
{'Name': 'Alice', 'Age': '30', 'City': 'Beijing'}  
{'Name': 'Bob', 'Age': '', 'City': 'Shanghai'}  
{'Name': 'Charlie', 'Age': '22', 'City': 'Guangzhou', 'Others': ['ExtraField1', 'ExtraField2']}
```

- 第一行是标题行，因为我们显式指定了 `fieldnames`，不过它也被当作数据行一起读入。
- 第二行的 `Age` 字段有值，正常读取。
- 第三行的 `Age` 缺失，被设为 `''`（空字符串）；如果想让其显示为 `'N/A'`，可在写入时再进行检查或直接在这里对其进行填充。
- 第四行多出两个字段，通过 `restkey='Others'` 收集，它们会形成一个列表。

### 8.4 在 Pandas 与 csv 互转时的注意

虽然 Pandas `read_csv` / `to_csv` 更强大，但在某些轻量场景下，只需用内置的 `csv` 模块即可。例如，我们要处理大文件，一边读取一边处理，就可用 `csv.reader` 节省内存；而不是一次性把整个文件加载到 DataFrame 中。

---

## 9. 总结

1. `**csv.reader**` **与** `**csv.writer**`：最常用。逐行读取/写入列表形式。
2. `**csv.DictReader**` **与** `**csv.DictWriter**`：当 CSV 有表头且希望以「列名→值」方式操作时更简洁。
3. **方言（Dialect）**：通过 `register_dialect`、`get_dialect`、`unregister_dialect` 定制并复用一组参数。
4. **常见参数**：

- `delimiter`：自定义分隔符（如 `','`、`\t`、`'|'` 等）。
- `quotechar`、`quoting`、`escapechar`：处理字段中包含分隔符或引号时的转义和引用策略。
- `skipinitialspace`：跳过分隔符后可能出现的空格。
- `lineterminator`：写文件时行结束符。
- `restkey` / `restval` / `extrasaction`：用于不规整 CSV（列数不一致、字典写入时多余或缺失字段）。

5. **编码与换行**：

- Python 3 中，打开文件时统一使用 `encoding='utf-8'`（或根据实际编码），并确保加上 `newline=''`。
- 如果遇到带 BOM 的文件，请用 `encoding='utf-8-sig'` 自动去除 BOM。

6. **实战技巧**：

- 如果文件很大，不要一次性 `readlines()`，而用 `for row in reader:` 按行处理。
- 若需要把 CSV 转为 JSON，可先用 `DictReader` 读入列表，再用 `json.dump` 输出。
- 当字段中会包含分隔符或换行符时，务必保证设置正确的 `quotechar` / `quoting`。

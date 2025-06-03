## 一、基本概念与用途

1. **JSON 格式概述**

- JSON 本质上是一种文本格式，表示对象（dictionary）和数组（list）等数据结构。
- 在 JSON 中，数据结构映射如下：

```pgsql
JSON 值          ↔︎   Python 对象
---------------------------------
object            ↔   dict
array             ↔   list
string            ↔   str
number(int/float) ↔   int 或 float
true              ↔   True
false             ↔   False
null              ↔   None
```

- 典型的 JSON 示例：

```json
{
  "name": "Alice",
  "age": 30,
  "is_student": false,
  "scores": [85, 92, 78],
  "address": {
    "city": "Beijing",
    "zip": "100000"
  }
}
```

2. **模块用途**

- **序列化**（Python → JSON）：将 Python 对象转换为 JSON 格式的字符串或写入文件。
- **反序列化**（JSON → Python）：将 JSON 格式的字符串或文件内容转换回对应的 Python 对象。

具体使用场景包括但不限于：

- 将 Python 中的数据结构发送给前端（AJAX 请求、HTTP API）。
- 从外部读取 JSON 配置文件，将其解析成字典/列表供程序使用。
- 将计算结果保存为 JSON 格式供其他语言或系统读取。

---

## 二、主要函数和参数

### 1. `json.loads()` / `json.dumps()`

- `**json.loads(s: str, *, encoding=None, cls=None, object_hook=None, parse_float=None, parse_int=None, parse_constant=None, object_pairs_hook=None) -> object**`

- 将 JSON 格式的字符串 `s` 反序列化为 Python 对象。
- **常用参数：**

- `object_hook`: 如果传入函数，则在解码完成后，会将解析出的 dict 交给该函数进行进一步处理（用于自定义转换）。
- `parse_float`、`parse_int`：可指定在解析数字时使用的自定义函数，例如将数字解析为 Decimal 类型而非浮点。
- `object_pairs_hook`: 类似于 `object_hook`，但接收 `(key, value)` 列表，返回一个自定义的映射类型（如 `OrderedDict`）。

```python
import json

json_str = '{"name": "Bob", "age": 25, "scores": [90, 88, 76]}'
data = json.loads(json_str)
# data -> {'name': 'Bob', 'age': 25, 'scores': [90, 88, 76]}
```

- `**json.dumps(obj: object, *, skipkeys=False, ensure_ascii=True, check_circular=True, allow_nan=True, cls=None, indent=None, separators=None, default=None, sort_keys=False) -> str**`

- 将 Python 对象 `obj` 序列化为 JSON 格式的字符串。
- **常用参数：**

- `ensure_ascii`（默认 `True`）：是否只输出 ASCII 字符，如果为 `True`，则所有非 ASCII 字符会被转义为 `\uXXXX`。设置为 `False` 可以直接输出中文字符。
- `indent`：如果给定整数 `n`，则对输出进行缩进，每个层级缩进 `n` 个空格；如果 `None`，则输出结果为一行，不做格式化。
- `separators`：用于定制分隔符，默认 `(',', ': ')`；常见用法是 `(',', ':')`，去掉冒号后面的空格以减少文件大小。
- `default`：如果遇到无法序列化的对象（如自定义类实例），会调用该函数以返回可序列化的类型（通常是一个可 JSON 化的类型，比如 `dict` 或 `str`）。
- `sort_keys`：如果为 `True`，则按键名对字典进行排序，有利于日志或文件比较时保持一致性。

```python
import json

data = {
    "name": "张三",
    "age": 28,
    "languages": ["Python", "JavaScript"]
}
json_str = json.dumps(data, ensure_ascii=False, indent=2)
# 输出（含中文，无转义）：
# {
#   "name": "张三",
#   "age": 28,
#   "languages": [
#     "Python",
#     "JavaScript"
#   ]
# }
```

### 2. `json.load()` / `json.dump()`

- `**json.load(fp: TextIOBase, *, encoding=None, cls=None, object_hook=None, parse_float=None, parse_int=None, parse_constant=None, object_pairs_hook=None) -> object**`

- 从文件对象 `fp` 中读取 JSON 文本，并直接返回对应的 Python 对象。
- 与 `loads()` 对应，区别在于前者直接读取并解析文件。

```python
import json

with open('data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
# data 即为解析结果，通常为 dict 或 list
```

- `**json.dump(obj: object, fp: TextIOBase, *, skipkeys=False, ensure_ascii=True, check_circular=True, allow_nan=True, cls=None, indent=None, separators=None, default=None, sort_keys=False)**`

- 将 Python 对象 `obj` 序列化为 JSON 文本，并写入到文件对象 `fp` 中。
- 与 `dumps()` 对应，区别在于前者将结果直接写入文件。

```python
import json

data = {"city": "上海", "temp": 22.5}
with open('output.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=4)
# 这样就会在 output.json 中写入可读性较高的 JSON 文本
```

---

## 三、常见使用示例

### 1. 将 JSON 文件读取到 Python

假设文件 `config.json` 内容如下：

```json
{
  "host": "localhost",
  "port": 8080,
  "use_ssl": true,
  "paths": ["/api/v1/users", "/api/v1/orders"]
}
```

```python
import json

def load_config(path):
    with open(path, 'r', encoding='utf-8') as f:
        cfg = json.load(f)
    return cfg

config = load_config('config.json')
print(config['host'], config['port'], config['use_ssl'])
# 输出：localhost 8080 True
```

### 2. 从字符串解析并访问数据

```python
import json

raw = '{"product": "laptop", "price": 999.99, "tags": ["electronics", "computer"]}'
obj = json.loads(raw)
print(obj['product'])   # 'laptop'
print(obj['tags'][1])   # 'computer'
```

### 3. 将 Python 对象写入文件

```python
import json
from datetime import datetime

data = {
    "event": "login",
    "user": "Alice",
    "timestamp": datetime.now().isoformat()
}

with open('event.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
```

### 4. 控制输出格式：`indent`、`separators`、`sort_keys`

```python
import json

person = {"b": 2, "a": 1, "c": 3}
# 不格式化，默认分隔符
print(json.dumps(person))                 # {"b": 2, "a": 1, "c": 3}

# 排序键名、不换行、去除多余空格
print(json.dumps(person, sort_keys=True, separators=(",", ":")))
# {"a":1,"b":2,"c":3}

# 美化输出
print(json.dumps(person, sort_keys=True, indent=4, ensure_ascii=False))
# {
#     "a": 1,
#     "b": 2,
#     "c": 3
# }
```

---

## 四、进阶功能

### 1. 定制化解码：`object_hook` 与 `object_pairs_hook`

- **场景**：当想把 JSON 中的某些字典转换为自定义的 Python 类实例时，可以使用 `object_hook`。
- `object_hook` 会在解析每个 JSON 对象（dict）后被调用，其返回值会替换原本的 dict。

```python
import json

class User:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    def __repr__(self):
        return f"<User name={self.name} age={self.age}>"

def user_decoder(dct):
    # 如果 dict 中包含 'name' 和 'age' 字段，就生成 User 对象
    if 'name' in dct and 'age' in dct:
        return User(dct['name'], dct['age'])
    return dct

json_str = '[{"name":"Tom","age":20},{"score":95}]'
objs = json.loads(json_str, object_hook=user_decoder)
# 结果： [<User name=Tom age=20>, {'score': 95}]
```

- `**object_pairs_hook**`

- 如果需要保留 JSON 对象中键的原始顺序，或者想用有序字典（如 `collections.OrderedDict`）来接收数据，则可以使用 `object_pairs_hook`。
- 参数接受列表形式的 (key, value) 元组列表。

```python
import json
from collections import OrderedDict

json_str = '{"b": 2, "a": 1, "c": 3}'
ordered = json.loads(json_str, object_pairs_hook=OrderedDict)
# ordered -> OrderedDict([('b', 2), ('a', 1), ('c', 3)])
```

### 2. 定制化序列化：`default` 参数

- 当需要将自定义类或无法直接 JSON 化的对象（如 `datetime`、`Decimal` 等）转换为 JSON 时，可通过 `default` 参数指定如何“降级”成可序列化的类型。

```python
import json
from datetime import datetime, date

class DateEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (datetime, date)):
            return obj.isoformat()
        # 调用基类方法抛出 TypeError
        return super().default(obj)

data = {"today": date.today(), "event": "meeting"}
json_str = json.dumps(data, cls=DateEncoder, ensure_ascii=False)
# {"today": "2025-06-01", "event": "meeting"}
```

或者直接给 `default` 参数传入一个函数：

```python
import json
from datetime import datetime

def default(o):
    if isinstance(o, datetime):
        return o.isoformat()
    raise TypeError(f"{o!r} is not JSON serializable")

data = {"time": datetime.now()}
print(json.dumps(data, default=default, ensure_ascii=False))
```

### 3. 处理浮点数精度：`parse_float` 与 `parse_int`

- 在解析大型金融数据或需要高精度的场景下，可能不希望使用 Python 默认的 `float`（二进制浮点），而希望使用 `decimal.Decimal`。

```python
import json
from decimal import Decimal

json_str = '{"price": 19.99, "quantity": 3}'
# 使用 Decimal 来解析浮点数
data = json.loads(json_str, parse_float=Decimal)
# data['price'] 是 Decimal('19.99')
```

同理，也可自定义 `parse_int`，将整数字段解析为其他类型。

---

## 五、错误与异常

- `**json.JSONDecodeError**`

- 当传入的 JSON 字符串格式不合法时，会抛出此异常。通常可以捕获并定位错误位置。

```python
import json

bad = '{"name": "Alice", age: 30}'  # age 没有加引号
try:
    obj = json.loads(bad)
except json.JSONDecodeError as e:
    print("解析错误：", e)  
    # 输出示例：解析错误： Expecting property name enclosed in double quotes: line 1 column 17 (char 16)
```

- `**TypeError**`

- 在调用 `json.dumps()` 时，如果遇到无法序列化且未提供 `default` 回调，就会抛出 `TypeError`。

```python
import json

class A:
    pass

try:
    json.dumps(A())
except TypeError as e:
    print("序列化错误：", e)
    # 输出：序列化错误： Object of type A is not JSON serializable
```

---

## 六、性能与注意事项

1. **性能**

- Python 的内建 `json` 模块在多数场景下性能表现合理，但对于大规模数据（几 MB 或更大），可以考虑第三方库 `ujson`、`orjson` 等，它们在序列化/反序列化速度上更快。
- 如果对重复读写同一个 JSON 文件，避免频繁调用 `load`/`dump`，可考虑将内容缓存到内存中。

2. **字符编码**

- Python 3 中，`json.load`/`dump` 时应指定正确的 `encoding='utf-8'`（尽管在 Python 3.9+ 默认就是 UTF-8）。
- 默认 `json.dumps(..., ensure_ascii=True)` 会把所有非 ASCII 字符转义为 `\uXXXX`。如要直接输出中文或其他 Unicode 字符，需要 `ensure_ascii=False`。

3. **安全性**

- 从不可信来源解析 JSON 时，一般是安全的，因为 JSON 仅表示数据结构，不包含可执行代码。
- 但如果将 JSON 字符串 `eval`、`exec`，则会有安全风险。切勿用 Python 的 `eval` 来处理 JSON。

4. **浮点数精度**

- 如果需要高精度浮点运算或金融计算，强烈建议使用 `parse_float=Decimal`；否则 JSON 中的浮点会被解析为 Python `float`，存在精度误差。

---

## 七、常见场景示例

### 1. 将自定义对象批量序列化

```python
import json
from datetime import datetime

class Order:
    def __init__(self, order_id, price, date):
        self.order_id = order_id
        self.price = price
        self.date = date

def order_default(obj):
    if isinstance(obj, Order):
        return {
            "order_id": obj.order_id,
            "price": obj.price,
            "date": obj.date.isoformat()
        }
    raise TypeError(f"Type {type(obj)} not serializable")

orders = [
    Order(1001, 199.99, datetime(2025, 5, 20)),
    Order(1002, 289.50, datetime(2025, 5, 21))
]

json_str = json.dumps(orders, default=order_default, ensure_ascii=False, indent=2)
print(json_str)
```

**输出示例：**

```json
[
  {
    "order_id": 1001,
    "price": 199.99,
    "date": "2025-05-20T00:00:00"
  },
  {
    "order_id": 1002,
    "price": 289.5,
    "date": "2025-05-21T00:00:00"
  }
]
```

### 2. 使用 `object_hook` 自动反序列化为自定义对象

```python
import json
from datetime import datetime

class Event:
    def __init__(self, name, timestamp):
        self.name = name
        self.timestamp = timestamp
    def __repr__(self):
        return f"<Event {self.name} at {self.timestamp}>"

def event_hook(dct):
    if 'name' in dct and 'timestamp' in dct:
        dct['timestamp'] = datetime.fromisoformat(dct['timestamp'])
        return Event(dct['name'], dct['timestamp'])
    return dct

json_data = '''
[
  {"name": "start", "timestamp": "2025-06-01T08:30:00"},
  {"name": "stop",  "timestamp": "2025-06-01T09:00:00"}
]
'''

events = json.loads(json_data, object_hook=event_hook)
# events -> [<Event start at 2025-06-01 08:30:00>, <Event stop at 2025-06-01 09:00:00>]
```

---

## 八、常见问题

1. **对 JSON 字符串进行增量解析**

- 标准库不支持流式增量解析，但可以借助第三方库如 `json.JSONDecoder.raw_decode` 方法手动分段解析。
- 也可以使用 `ijson`、`yajl` 等第三方库实现对超大 JSON 的流式处理。

2. **如何保证序列化后字段顺序？**

- Python 3.7+ 中，普通 `dict` 保留插入顺序，若想确保按键排序可在 `dumps` 时传入 `sort_keys=True`。
- 如果需要在反序列化时保留 JSON 文件中的原始顺序，可以使用 `object_pairs_hook=collections.OrderedDict`。

3. **JSON 中含有注释怎么办？**

- 标准 JSON 规范中不支持注释；如果配置文件里包含注释，直接用 `json` 模块会报错。
- 常见解决方式是：

1. 事先用正则或简单逻辑去除注释行（`// ...`、`/* ... */`）。
2. 使用支持注释的扩展库，如 `json5`、`ruamel.yaml`（既可读 JSON 又可读 YAML）。

3. **如何处理非 ASCII 字符？**

- 默认 `json.dumps(..., ensure_ascii=True)` 会将中文等 Unicode 字符转义为 `\uXXXX` 格式。
- 如需直接输出中文，使用 `ensure_ascii=False`。同时文件读写时注意指定 `encoding='utf-8'`。

```python
import json

data = {"city": "北京", "天气": "晴"}
print(json.dumps(data, ensure_ascii=False))  # {"city": "北京", "天气": "晴"}
```

---

## 九、小结

- `json` 模块提供了四个核心函数：

- `loads()`、`dumps()`：处理字符串与 Python 对象互转。
- `load()`、`dump()`：处理文件与 Python 对象互转。

- 常用参数：

- **反序列化**：`object_hook`（自定义类）、`parse_float`/`parse_int`（高精度数字）。
- **序列化**：`ensure_ascii=False`（保留 Unicode 非 ASCII 字符）、`indent`（格式化缩进）、`default`（自定义对象处理）、`sort_keys`（键排序）。

- 进阶场景：

- 使用 `object_pairs_hook=OrderedDict` 保留键顺序。
- 使用自定义 `JSONEncoder` 或 `default` 函数序列化 `datetime`、`Decimal` 等类型。
- 第三方库（如 `ujson`、`orjson`）可在性能敏感场景下替代内置 `json`。
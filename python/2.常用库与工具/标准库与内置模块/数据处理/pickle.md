## 一、模块概述

1. **什么是** `**pickle**`

- `pickle` 是 Python 标准库提供的将 Python 对象转换为字节流（序列化，pickling）以及将字节流恢复为原始 Python 对象（反序列化，unpickling）的工具。
- 其设计目标是：在同一台机器或通过网络在受信任环境中，保存或传输复杂的 Python 对象（如列表、字典、类实例、函数引用等），并在之后恢复为“活”的对象，以便继续操作。

2. **主要应用场景**

- **持久化存储**：将某些中间计算结果或数据结构缓存到磁盘，下次程序启动时直接加载，而不用重新计算。
- **跨进程/网络传输**：在分布式任务、RPC、消息队列等场景中，将 Python 对象打包传输，接收端再恢复。
- **深拷贝**：利用 `pickle.dumps()` + `pickle.loads()` 可快速复制复杂对象（对循环引用也能正确处理）。
- **调试与快照**：在运行时把程序状态“拍照”保存下来，以便后续分析。

3. **与其他序列化工具的对比**

- 与 `json` 相比，`pickle` 可以序列化几乎所有 Python 对象（包括自定义类、函数引用、循环引用等），而 `json` 只能处理基础类型（`dict`、`list`、字符串、数字、布尔、`None`）或者需要自行转换。
- 与 `marshal` 相比，`marshal` 更底层、速度略快，但只适用于 Python 内部对象（比如编译后的字节码），且在不同 Python 版本间不保证兼容，官方不推荐用于一般持久化。
- 与第三方库（如 `dill`、`cloudpickle`）相比，`pickle` 局限在标准库中，不依赖第三方，但对闭包、Lambda、动态生成的类或函数支持有限，且在跨 Python 版本时可能不兼容。

---

## 二、核心接口与示例

### 1. `pickle.dump` 与 `pickle.load`

- `**dump(obj, file, protocol=None, *, fix_imports=True)**`

- 将 `obj` 序列化后写入到给定的文件类对象 `file`（必须以二进制模式打开，如 `'wb'`）。
- `protocol` 参数用于指定使用的序列化协议版本，默认为 `pickle.HIGHEST_PROTOCOL`（当前 Python 版本最高支持的协议）。
- `fix_imports` 用于在 Python 2/3 兼容时修正模块名，一般保持默认即可。

- `**load(file, *, fix_imports=True, encoding="ASCII", errors="strict")**`

- 从文件对象 `file`（必须以二进制模式打开，如 `'rb'`）中读取字节流，并尝试反序列化为 Python 对象。
- 如果 pickle 数据来源于 Python 2，且在 Python 3 中加载，需要配合 `encoding` 参数（常用 `'utf-8'` 或 `'latin1'`）来正确解码原始字节。

```python
import pickle

# 示例：将一个列表写入文件
data = {'a': [1, 2, 3], 'b': ("hello", 3.14)}
with open('data.pkl', 'wb') as f:
    # 指定协议版本为 4（可选）
    pickle.dump(data, f, protocol=4)

# 从文件中加载
with open('data.pkl', 'rb') as f:
    loaded = pickle.load(f)
    print(type(loaded), loaded)  # <class 'dict'> {'a': [1, 2, 3], 'b': ('hello', 3.14)}
```

### 2. `pickle.dumps` 与 `pickle.loads`

- `**dumps(obj, protocol=None, *, fix_imports=True)**`

- 将 `obj` 序列化为 bytes 对象并返回，可用于网络传输或存入数据库等。

- `**loads(data_bytes, *, fix_imports=True, encoding="ASCII", errors="strict")**`

- 将 `data_bytes`（类型为 `bytes` 或 `bytearray`）反序列化为 Python 对象。

```python
import pickle

# 将对象序列化为内存中的 bytes
raw = pickle.dumps([1, 2, 3], protocol=pickle.HIGHEST_PROTOCOL)
print(type(raw), raw[:10], '...')  # <class 'bytes'> b'\x80\x05]\x00\x00\x00\x00\x00\x00\x...'

# 从 bytes 恢复原始对象
lst = pickle.loads(raw)
print(type(lst), lst)  # <class 'list'> [1, 2, 3]
```

**要点提示**

- `dump`/`load` 适用于文件，`dumps`/`loads` 适用于内存或网络。
- pickle 数据格式本质是 Python 专用的二进制格式（也支持早期的 ASCII 文本协议，但默认为二进制）。
- 始终以二进制模式打开文件：写模式 `'wb'`，读模式 `'rb'`。

---

## 三、协议（Protocols）与兼容性

Python 的 pickle 协议随着版本演进不断扩展新功能、优化性能与压缩率。常见协议版本包括：

|   |   |   |
|---|---|---|
|协议版本|描述|Python 添加版本|
|0|原始 ASCII 文本格式，兼容极早期的 Python 。|Python 1.0 及以上|
|1|第一版二进制格式，比协议 0 更紧凑。|Python 1.4|
|2|支持扩展类型（extension types）和新式类（new-style classes）。|Python 2.3|
|3|Python 3 专用的二进制协议，不兼容 Python 2 的反序列化。|Python 3.0|
|4|改进对大对象（例如大于 4GB）支持，提供对 `collections.OrderedDict`<br><br>等新内置类型的优化。|Python 3.4|
|5|引入对 out-of-band 缓冲区（buffer out-of-band）协议的支持，可更高效地序列化大型字节对象（如 `bytes`<br><br>）。|Python 3.8|

- **默认协议**

- 在 Python 3.x 中，`pickle.dump` 默认使用 `pickle.HIGHEST_PROTOCOL`，一般会选择当前解释器能支持的最高协议（例如 Python 3.10 就是协议 5）。
- 如果需要与旧版本 Python 共享数据，可显式指定 `protocol=2` 或 `protocol=3`。

- **跨版本兼容**

- 若要在 Python 2.x 与 Python 3.x 之间共享 pickle 数据，推荐在两端都使用协议 2 或 3；Python 2 只能读到 2 及以下，不兼容 3。
- 在 Python 3 中加载由 Python 2 生成的 pickle 时，可能需要指定 `encoding='latin1'` 或 `encoding='bytes'`，以保留原始字节值，否则默认 `ASCII` 解码会报错。

```python
# Python 2 端生成（示意）：
#   import pickle
#   data = {'x': b'\xe4\xb8\xad'}  # 一些二进制
#   with open('py2data.pkl', 'wb') as f:
#       pickle.dump(data, f, protocol=2)

# Python 3 端加载：
import pickle

with open('py2data.pkl', 'rb') as f:
    # 使用 latin1 保证原始字节不丢失
    data_py2 = pickle.load(f, fix_imports=True, encoding='latin1')
    print(data_py2)  # {'x': b'\xe4\xb8\xad'}
```

**要点提示**

1. **尽量保持协议一致**：如果项目中有多台机器互通 pickle 二进制，最好统一指定协议版本并写入文档说明。
2. **协议 4/5 对大对象更友好**：当你的数据中包含超大 `bytes`、`bytearray` 时，协议 5 在性能和内存占用上有明显改进。
3. **明确** `**encoding**`：跨 Python 版本加载时，`encoding='latin1'` 会把所有原始字节映射到对应 Unicode 0–255 码位，不会丢数据。

---

## 四、示例：简单读写流程

下面以一个稍复杂的对象为例，演示完整的序列化与反序列化流程。

```python
import pickle
import datetime

# 1. 定义一个自定义类，用于演示
class Person:
    def __init__(self, name, birth):
        self.name = name
        self.birth = birth  # datetime.date 对象
    def __repr__(self):
        return f"<Person name={self.name!r} birth={self.birth!r}>"

# 2. 创建一个复杂结构：包含列表、字典、实例、内置对象
alice = Person("Alice", datetime.date(1990, 5, 17))
bob = Person("Bob", datetime.date(1985, 12, 3))
team = {
    "members": [alice, bob],
    "created": datetime.datetime.now(),
    "metadata": {"project": "Demo", "count": 2}
}

# 3. 序列化到文件
with open("team.pkl", "wb") as fw:
    pickle.dump(team, fw, protocol=pickle.HIGHEST_PROTOCOL)

# 4. 反序列化回内存
with open("team.pkl", "rb") as fr:
    loaded_team = pickle.load(fr)

print(type(loaded_team), loaded_team)
# <class 'dict'> {'members': [<Person name='Alice' birth=datetime.date(1990, 5, 17)>, ...], ...}

# 5. 验证对象类型保持不变
for member in loaded_team["members"]:
    print(type(member), member.name, member.birth, member.birth.year)
# <class '__main__.Person'> Alice 1990-05-17 1990
# <class '__main__.Person'> Bob 1985-12-03 1985
```

**要点提示**

- 自定义类实例可以“开箱即用”被 pickle 化，前提是：类定义可以被导入（即在反序列化时能够按同样的模块路径找到该类）。
- 如果你的类定义在交互式解释器（`__main__`）或某些动态生成的模块中，反序列化时可能会因找不到类而报错。
- 内置类型（如 `datetime.date`、`list`、`dict`、`tuple`）都会自动按理想方式序列化。

---

## 五、安全注意事项

**⚠️** **非常重要：不要对来自不可信来源的 pickle 数据执行** `**pickle.load**` **或** `**pickle.loads**`**。**

1. **为什么不安全**

- pickle 在反序列化时会执行“任意”构造指令、调用任意类/函数、甚至导入模块并执行它们的 `__reduce__`、`__setstate__` 等方法。一个恶意构造的 pickle 二进制可以在反序列化阶段执行恶意代码（如删除文件或下载执行脚本）。

2. **安全替代**

- 如果需要从不可信来源加载数据，应使用更安全的格式，例如 **JSON**、**YAML**（需谨慎选择安全加载函数）、或专门的沙箱化反序列化库。
- 也可在可信环境下先解析 pickle 流，检查其中的内容，但这一般非常复杂且容易出错。

3. **仅限受信任环境**

- 如果你明确知道数据来源、运行环境完全可信，可放心使用 pickle，以获得最灵活的序列化能力。
- 网络服务中若需要传输 Python 对象，推荐在应用层加签名或加密 pickle 数据，以确保接收端能够识别来源并防止中间人篡改。

---

## 六、进阶用法：定制序列化与反序列化

### 1. 基本原理：`__getstate__` 与 `__setstate__`

- 如果一个类定义了 `__getstate__(self)`，则在 pickle 时会调用该方法，获取一个状态（通常为字典或基本类型）作为实际要 pickle 的“payload”。
- 在 unpickle 时，如果类定义了 `__setstate__(self, state)`，反序列化后会先创建一个空对象实例，然后将 `state` 传入该方法，以恢复实例状态。

```python
import pickle
import datetime

class Event:
    def __init__(self, name, timestamp=None):
        self.name = name
        # timestamp 不可直接序列化，举例替换成 ISO 格式字符串
        self.timestamp = timestamp or datetime.datetime.now()

    def __getstate__(self):
        # 返回要 pickle 的状态。timestamp 转成 ISO 字符串
        state = self.__dict__.copy()
        state['timestamp'] = self.timestamp.isoformat()
        return state

    def __setstate__(self, state):
        # 反序列化时，将字符串再转换为 datetime 对象
        timestamp_str = state.get('timestamp')
        if timestamp_str:
            state['timestamp'] = datetime.datetime.fromisoformat(timestamp_str)
        self.__dict__.update(state)

    def __repr__(self):
        return f"<Event {self.name} at {self.timestamp}>"

# 演示
evt = Event("TestEvent")
raw = pickle.dumps(evt)
evt2 = pickle.loads(raw)
print(evt2, type(evt2.timestamp))  # <Event TestEvent at 2025-06-02T...> <class 'datetime.datetime'>
```

**要点提示**

- 当类包含某些不可序列化的成员（如打开的文件句柄、数据库连接、线程锁等），可以在 `__getstate__` 中剔除或转换，仅保留可恢复的必要部分。
- `__getstate__` 必须返回**纯 Python 类型**（内置类型或其他能直接 pickle 的类型）；`__setstate__` 则以相反思路恢复。
- 如果未定义 `__getstate__`/`__setstate__`，pickle 默认会将 `obj.__dict__` 全部 pickle（即逐属性写入），然后反序列化时重建 `__dict__`。

### 2. 更灵活的钩子：`__reduce__` 与 `__reduce_ex__`

- `__reduce__` 返回一个元组，告诉 pickle 如何重建该对象。典型格式为 `(callable, args, state, listiterator, dictiterator)` 中前两个元素最常用。

- `callable`：用于创建新对象的可调用对象（如类本身、工厂函数等）。
- `args`：调用该 `callable(*args)` 时的参数元组，用于生成“空”对象。
- `state`：一个任意的状态（如 `__dict__`），pickle 会在创建新对象后，将其传递给新对象的 `__setstate__` 或直接赋值 `obj.__dict__ = state`。

- `__reduce_ex__` 是更高级的接口，默认实现会调用 `__reduce__`。通常无需自定义，除非对不同协议版本有细粒度控制。

```python
import pickle

class MyRange:
    def __init__(self, start, stop):
        self.start = start
        self.stop = stop

    def __iter__(self):
        return iter(range(self.start, self.stop))

    def __reduce__(self):
        # 当 pickle 时，告诉它如何重建自己：
        #   首先调用 MyRange(self.start, self.stop)，得到一个实例
        #   然后 pickle 会将 __dict__ 作为 state 继续处理，但这里没有额外 state
        return (MyRange, (self.start, self.stop))

# 演示
r = MyRange(5, 10)
data = pickle.dumps(r)
r2 = pickle.loads(data)
print(list(r2))  # [5, 6, 7, 8, 9]
```

**要点提示**

- 当类需要更细粒度地控制序列化流程（例如类有工厂函数、单例模式、缓存机制等），可通过 `__reduce__` 指定“重建步骤”。
- 返回的元组可以包含 2 到 5 个元素，最常见仅返回 `(callable, args)` 或 `(callable, args, state)`。
- 如果希望指定自定义的 `state`，则在返回 `(callable, args, state)` 之后，pickle 会先调用 `callable(*args)` 得到对象实例，再自动将 `state` 赋予该对象（即调用 `__setstate__` 或直接 `__dict__` 更新）。

---

## 七、对象引用、循环引用与共享

1. **自动处理对象引用**

- Pickle 会自动记录对象引用（memoization），如果同一个对象在多个位置重复出现，pickle 只保存一份，并在反序列化时保持“共享”关系。
- 例如，以下示例中，`lst[0]` 与 `lst[1]` 都指向同一个列表对象，反序列化后仍保持这一引用关系。

```python
import pickle

shared = [1, 2, 3]
container = [shared, shared]
raw = pickle.dumps(container)
restored = pickle.loads(raw)

print(restored[0] is restored[1])  # True，说明指向同一对象
```

1. **循环引用**

- Pickle 能够正确处理“自引用”或“循环引用”的对象图。反序列化后仍能保持循环结构。
- 例如，下面创建了一个节点循环引用的链表：`a.next = b`，`b.next = a`。

```python
import pickle

class Node:
    def __init__(self, name):
        self.name = name
        self.next = None
    def __repr__(self):
        nxt = self.next.name if self.next else None
        return f"<Node {self.name}->{nxt}>"

a = Node("A")
b = Node("B")
a.next = b
b.next = a  # 循环

data = pickle.dumps(a)
a2 = pickle.loads(data)

# 验证循环依然存在
print(a2, a2.next, a2.next.next)     # <Node A->B> <Node B->A> <Node A->B>
print(a2.next.next is a2)            # True
```

**要点提示**

- Pickle 底层维护一个 internal memo 表，记录已序列化的对象 id，以便避免重复并妥善处理循环和多次引用。
- 循环引用不会导致死循环或无限递归，因为 pickle 会先为对象分配“占位标识”，之后再填充引用。

---

## 八、流式读写与定制流

除了最常见的直接对文件执行 `dump`/`load`，`pickle` 还提供了更底层的 `Pickler` 与 `Unpickler` 类，可对流进行更灵活的控制。

### 1. 使用 `Pickler` 与 `Unpickler`

```python
import pickle

# Pickler 用于直接向文件流或其他可写二进制流写入 pickle 数据
with open("stream.pkl", "wb") as f:
    pkl = pickle.Pickler(f, protocol=pickle.HIGHEST_PROTOCOL)
    pkl.dump({"x": 1})
    pkl.dump([1, 2, 3])
    # 这样做，将在同一文件中接连写入两个 pickle 对象

# Unpickler 逐个读取 pickle 对象
with open("stream.pkl", "rb") as f:
    up = pickle.Unpickler(f)
    obj1 = up.load()
    obj2 = up.load()
    print(obj1)  # {'x': 1}
    print(obj2)  # [1, 2, 3]
```

### 2. 从自定义字节流（如 `BytesIO`）读写

```python
import pickle
from io import BytesIO

buf = BytesIO()
picker = pickle.Pickler(buf)
picker.dump(("hello", 123))
# 此时 buf.getvalue() 返回完整的 pickle bytes

buf.seek(0)
unpicker = pickle.Unpickler(buf)
tup = unpicker.load()
print(tup)  # ('hello', 123)
```

**要点提示**

- 通过 `Pickler` 的 `dump` 方法可以多次写入多个对象；相应地，`Unpickler` 的 `load` 方法可反复调用，一次读一个对象。
- 如果你希望在网络传输层面对 pickle 二进制做分块处理或加密，使用 `Pickler`/`Unpickler` 加上自定义的流（socket、加密通道等）能更灵活地控制读写过程。

---

## 九、自定义扩展：`copyreg` 与扩展类型注册

在一些高级场景下，你可能需要为某些类型提供“全局”注册的定制序列化逻辑，而不想在类内部写 `__reduce__`。这时可以使用标准库的 `copyreg`（Python 2 中称 `copy_reg`）。

### 1. 注册简单函数实现

```python
import pickle
import copyreg

# 假设有一个不可变的类型：Fraction（可直接用 fractions.Fraction，可用此示意）
class Fraction:
    def __init__(self, num, den):
        self.num = num
        self.den = den
    def __repr__(self):
        return f"{self.num}/{self.den}"

# 定制的 reduce 函数：返回 (callable, args)
def reduce_fraction(frac):
    return (Fraction, (frac.num, frac.den))

# 注册到 copyreg
copyreg.pickle(Fraction, reduce_fraction)

# 使用示例
f = Fraction(3, 4)
data = pickle.dumps(f)
f2 = pickle.loads(data)
print(f2, type(f2))  # 3/4 <class '__main__.Fraction'>
```

**要点提示**

- `copyreg.pickle(type, reduce_func)`：告诉 pickle，当碰到 `type` 的实例时，直接调用 `reduce_func(obj)`，该函数需返回一个 `(callable, args)` 元组或 `(callable, args, state)`。
- 相比在类内部写 `__reduce__`，`copyreg` 实现了“与类解耦”，更适合向第三方类型（如在你控制不到其源码的情况下）或当你不想在类内添加序列化逻辑时使用。

---

## 十、进阶功能：Persistent ID / Persistent Load

在一些场景下，比如大型对象图中有数以千计的重复子对象，你希望在序列化时不把它们都打散到文件里，而是只保存一个“标识符”，在反序列化时通过“回调”去查找或重建实际对象。Pickle 提供了“persistent_id”和“persistent_load”机制来支持这样的策略。

### 1. 概念简述

- `**persistent_id(obj)**`：当 Pickler 在序列化时，为每个对象调用该方法。如果该方法返回 `None`，表示按正常流程序列化；如果返回一个任意非 `None` 的值（如字符串、数字、元组等），Pickle 会把这个值写入序列化流中，**而不序列化该对象本身**。
- `**persistent_load(pid)**`：当 Unpickler 反序列化时，如果看到某个 PID（persistent ID）占位符，会调用此方法，将 `pid` 转换为“真正”的对象。

通过这两个钩子，可以实现对大型共享对象或数据库对象的灵活处理。

### 2. 示例：数据表行引用

假设有一个进程需要把“用户对象”与“订单对象”序列化，但想把用户对象保存在数据库里，只在 pickle 中保留其 `user_id`，反序列化时再从数据库中查回完整 `User` 对象。

```python
import pickle

# 模拟数据库
DB = {
    'users': {
        1: {'name': 'Alice', 'age': 30},
        2: {'name': 'Bob', 'age': 25},
    }
}

class User:
    def __init__(self, uid):
        self.uid = uid
        # 其余属性从 DB 动态加载
    def __repr__(self):
        data = DB['users'][self.uid]
        return f"<User id={self.uid} name={data['name']} age={data['age']}>"

class Order:
    def __init__(self, order_id, user):
        self.order_id = order_id
        self.user = user
    def __repr__(self):
        return f"<Order id={self.order_id} user={self.user!r}>"

# 1. 自定义 Pickler，重写 persistent_id
class MyPickler(pickle.Pickler):
    def persistent_id(self, obj):
        if isinstance(obj, User):
            # 返回用户的唯一标识符，而非 pickle 对象本身
            return ('USER', obj.uid)
        else:
            return None   # 否则按常规 pickle 处理

# 2. 自定义 Unpickler，重写 persistent_load
class MyUnpickler(pickle.Unpickler):
    def persistent_load(self, pid):
        # pid 是 ('USER', uid)
        type_tag, uid = pid
        if type_tag == 'USER':
            # 根据 uid 从 DB 重建 User 实例
            return User(uid)
        else:
            raise pickle.UnpicklingError("Unsupported persistent object: %r" % (pid,))

# 演示
user1 = User(1)
order = Order(1001, user1)

# 序列化时，仅把 ('USER', 1) 写入 pickle 流
buf = BytesIO()
mp = MyPickler(buf)
mp.dump(order)

# 反序列化时，根据 pid 再从 DB 里查回 User(1)
buf.seek(0)
mu = MyUnpickler(buf)
restored_order = mu.load()
print(restored_order)  # <Order id=1001 user=<User id=1 name=Alice age=30>>
```

**要点提示**

- `persistent_id` 接受一个对象实例，如果该方法返回非 `None`，Pickler 在序列化时只保留该 “持久化 ID”。
- `persistent_load` 接受这个 ID，并负责将其转换为新的对象实例。
- 这种模式下，你可以避免在 pickle 文件中写入大量冗余数据，只保留外部资源的引用（如数据库主键、文件路径等），在反序列化时再做重建。

---

## 十一、常见问题与最佳实践

### 1. 不要把函数、Lambda 或本地（nested）类轻易 pickle

- 只能对**顶层**（module 级）定义的函数和类进行 pickle。如果你用 lambda、嵌套函数或交互式脚本里定义的类，pickle 会报错：“Can't pickle `<lambda>`: attribute lookup ... failed”。
- 如果确实想序列化函数，可考虑使用第三方库（如 `dill`、`cloudpickle`），它们对闭包、Lambda 支持更好。

```python
import pickle

def fn(x): return x * 2
raw = pickle.dumps(fn)          # 可以，因为 fn 是顶层函数
g = pickle.loads(raw)
print(g(5))                     # 10

h = lambda x: x+1
pickle.dumps(h)                 # 报错：Can't pickle <function <lambda> ...>
```

### 2. 注意对象定义位置与导入路径

- 反序列化时，pickle 会根据对象在序列化时的 `__module__` 和 `__qualname__` 去定位类/函数。所以如果类定义移动到其他模块或改名，反序列化就会失败。
- 例如，如果你把 `class Foo` 从 `mymodule` 移动到 `newmodule`，之前 pickle 的数据就会报错：`ModuleNotFoundError` 或 `AttributeError`。

### 3. 避免臃肿的数据结构

- 虽然 pickle 能序列化任意复杂对象，但对非常巨大的图结构，pickle 文件会很大，并且反序列化耗时也长。可考虑：

- 对关键数据做筛选，只 pickle 必要字段。
- 对深度嵌套对象或循环引用做好评估，或使用数据库/专门存储工具。

### 4. 当心版本升级导致的不兼容

- 如果你的应用需要在不同版本的 Python、或不同版本的自定义类之间共享 pickle 数据，最好：

1. **明确记录协议版本**：在文档里标记“此数据使用 protocol=2”，以确保各方使用一致。
2. **编写兼容代码**：在类定义中提供兼容旧版本 pickle 的 `__setstate__`、`__reduce__` 等方法，动态根据不同状态初始化。
3. **迁移工具**：如果类结构改变（新增/删除属性），可写脚本遍历旧数据，做“升级迁移”。

### 5. 性能与 C 实现的区别

- CPython 实现中，`_pickle` 模块（C 语言版本）在大多数情况下会优先被导入，以获得更高的执行效率；它与 Python 版本的纯 Python 实现具有相同 API。
- 反序列化大型对象时，若能选用 C 版的 pickle，可显著提升速度。通常在不做特别限制的情况下，导入 `import pickle` 就会自动使用 C 版实现；若需要纯 Python 实现可显式：

```python
import pickle
# 强制使用纯 Python 版本
import _pickle as cPickle  # 反而更快，通常不做此操作
```

- 对比来看：

- **协议 0/1/2/3/4/5**：协议本身决定了编码方式和功能。
- **实现**：`pickle`（Python） vs `_pickle`（C）只是性能差异，API 完全相同。

---

## 十二、常用示例汇总

### 1. 将多个对象存储到同一个文件中

```python
import pickle

objs = [{"name": "A"}, {"name": "B"}, [1, 2, 3]]

with open("multi.pkl", "wb") as f:
    p = pickle.Pickler(f)
    for obj in objs:
        p.dump(obj)

# 读取时逐行 load
with open("multi.pkl", "rb") as f:
    up = pickle.Unpickler(f)
    while True:
        try:
            o = up.load()
            print("Loaded:", o)
        except EOFError:
            break
```

### 2. 使用 `shelve` 模拟简单数据库

虽然 `shelve` 背后也是基于 `pickle`，但它为你封装了 key→value 存储，类似字典接口：

```python
import shelve

# 打开一个 on-disk “字典”
with shelve.open("mydata.db") as db:
    db["config"] = {"host": "127.0.0.1", "port": 8080}
    db["users"] = ["Alice", "Bob", "Carol"]

# 再次打开时，直接像访问字典一样访问
with shelve.open("mydata.db") as db2:
    print(db2["config"])  # {'host': '127.0.0.1', 'port': 8080}
    print(db2["users"])   # ['Alice', 'Bob', 'Carol']
```

**要点提示**

- `shelve` 的实现：对每个 key 对应的 value 都是 pickle 化后存储为值。
- `shelve` 底层一般有 `dbm`（如 `dbm.gnu`、`dbm.ndbm` 等）来做索引，value 部分才是 pickle 数据。

### 3. 使用 pickle 实现简单缓存（Memoization）

```python
import pickle
import os
import functools

def disk_cache(cache_file):
    """
    简单的磁盘缓存装饰器：如果 cache_file 存在，直接 load，否则执行 func 并 save。
    """
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            if os.path.exists(cache_file):
                with open(cache_file, 'rb') as f:
                    print("Loading from cache...")
                    return pickle.load(f)
            result = func(*args, **kwargs)
            with open(cache_file, 'wb') as f:
                print("Storing to cache...")
                pickle.dump(result, f, protocol=pickle.HIGHEST_PROTOCOL)
            return result
        return wrapper
    return decorator

@disk_cache("heavy_calc.pkl")
def heavy_calculation(x):
    # 模拟耗时计算
    import time; time.sleep(2)
    return x * x

# 第一次执行要模拟耗时
print(heavy_calculation(10))  # 延迟 ~2s，存入 cache
# 第二次直接从 cache 中读取
print(heavy_calculation(10))  # 立即返回
```

---

## 十三、常见错误与排查

1. `**AttributeError: Can't pickle <class 'XXX'>: attribute lookup failed**`

- 原因：要 pickle 的对象所属类（或函数）定义在交互式环境、本地作用域或动态创建上下文，不在可 import 的模块路径下。
- 解决：将类/函数提取到单独的 `.py` 模块文件中，并以模块方式导入；确保模块路径在 `sys.path` 中。

2. `**UnpicklingError: invalid load key, '<fragments of data>'**`

- 原因：试图对非 pickle 数据调用 `pickle.load`，如直接打开了文本文件、或文件损坏、读写混用了文本模式与二进制模式。
- 解决：

- 确保序列化时使用 `wb`，反序列化时使用 `rb`。
- 确认读写的是同一个 pickle 文件，且文件无损坏。

3. **跨版本** `**UnicodeDecodeError**` **或** `**TypeError**`

- 原因：Python 2 序列化的某些对象（如 `bytes`）在 Python 3 中默认当作文本处理，需要额外指定 `encoding='latin1'`。
- 解决：加载时用：

```python
pickle.load(f, fix_imports=True, encoding='latin1')
```

---

## 十四、总结与最佳实践要点

1. **仅在受信任环境中使用**：绝对不要 `pickle.load` 来自网络、用户上传或其他不可信数据。
2. **协议选择**：

- 默认使用 `pickle.HIGHEST_PROTOCOL` 以获得更高效的编码。
- 若需跨 Python 版本，统一指定一个兼容协议（如 2 或 3）。

3. **类定义要尽量模块化**：避免把类定义写在交互式环境或脚本内部，以免反序列化时报 `ModuleNotFoundError`。
4. **定制序列化**：利用 `__getstate__`/`__setstate__` 或 `__reduce__` 实现对不可序列化成员（文件句柄、线程锁、数据库连接等）的剥离与恢复。
5. **循环引用与共享**：pickle 自动处理，不用额外干预，但要注意序列化的图形规模，过大可能导致内存和性能问题。
6. **性能考虑**：

- 对大型二进制对象（如大数组、大 `bytes`）使用协议 5 更高效。
- 在 CPython 中会自动使用 C 版 `_pickle`，无需手动干预。

7. **对外部资源引用**：使用 `persistent_id` / `persistent_load` 可避免把所有数据都写入文件，仅存储引用；适用于数据库对象、大文件句柄等。
8. **替代方案**：在跨语言、跨平台需求下，建议使用 `JSON`、`MessagePack`、`Protocol Buffers`、`Avro` 等更通用的序列化方案。
9. **调试与验证**：

- 如果不确定序列化后是否可安全反序列化，可在开发环境先 `dump` 再 `load`，验证对象属性、方法是否完整。
- 使用 `pickletools.dis` 可以反汇编码数据，了解 pickle 流的组成。

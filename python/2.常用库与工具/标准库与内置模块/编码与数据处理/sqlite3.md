## 一、模块概述

1. **什么是** `**sqlite3**` **模块**

- `sqlite3` 是 Python 标准库内置的、用于与 SQLite 数据库交互的模块。它实现了 [DB-API 2.0](https://peps.python.org/pep-0249/)（PEP 249）接口规范，允许你在 Python 程序中通过纯 SQL 语句对 SQLite 数据库文件进行增删改查操作。
- SQLite 是轻量级的嵌入式关系型数据库，其数据库引擎以单个文件的形式直接嵌入到应用程序中，无需独立的服务器进程。Python 通过 `sqlite3` 模块直接调用 SQLite C 库，实现零配置、本地存储的数据库功能。

2. **模块特点与优点**

- **零依赖、开箱即用**：只要安装了 Python，就能够直接导入并使用 `import sqlite3`。
- **文件即数据库**：一个 `.db` 文件即可存储整个数据库，不需要额外部署数据库服务器。
- **支持事务**：默认开启自动提交（autocommit=false），可以通过 `commit()` 和 `rollback()` 进行事务管理。
- **跨平台**：同一个 `.db` 文件可以在 Windows、macOS、Linux 等平台间自由拷贝和使用。
- **丰富的功能**：支持大多数常用的 SQL 标准（DDL、DML、事务、索引、视图、触发器等），并暴露了 SQLite 特有的 PRAGMA、全文检索（FTS）、触发器等扩展功能。

3. **模块主要对象**

- `sqlite3.Connection`：数据库连接对象，代表对某个 SQLite 数据库文件（或内存）的一次会话。
- `sqlite3.Cursor`：游标对象，用于在连接上执行 SQL 语句、获取查询结果、控制结果集迭代。
- `sqlite3.Row`：行工厂类，用于让查询结果以字典或类似方式访问。
- 以及一系列异常类，如 `sqlite3.Error`、`sqlite3.OperationalError`、`sqlite3.IntegrityError` 等，用于捕获不同类型的数据库错误。

4. **何时使用** `**sqlite3**`

- **小型应用或本地存储**：如桌面应用、单用户 Web 应用、临时开发、原型系统、教育/学习场景等。
- **测试与调试**：可快速创建一个干净的数据库环境，用于单元测试或功能验证。
- **嵌入式设备**：无需运维数据库服务器，直接把 `.db` 文件打包到设备中。
- **小到中等并发量**：SQLite 适合单机、低并发场景；如果项目需要高并发、分布式部署，则应考虑 MySQL、PostgreSQL 等服务器型数据库。

---

## 二、连接到数据库

### 1. 打开（或创建）一个数据库

```python
import sqlite3

# 1) 连接到一个本地文件（如果文件不存在会自动创建）
conn = sqlite3.connect('example.db')

# 2) 使用内存数据库（进程结束后数据库消失）
mem_conn = sqlite3.connect(':memory:')

# 3) 配置超时时间、检查多线程访问
conn2 = sqlite3.connect(
    'example2.db',
    timeout=10,        # 当数据库被锁时，最多等待 10 秒
    check_same_thread=False  # 允许跨线程使用同一个连接（需自行保证线程安全）
)
```

- `**sqlite3.connect(database, timeout=5.0, detect_types=0, isolation_level='DEFERRED', check_same_thread=True, factory=Connection, cached_statements=128, uri=False)**`

- `database`：数据库文件路径，若为 `':memory:'` 则创建一个内存数据库；也可以使用 URI 方式（如 `'file:my.db?mode=ro'`，需 `uri=True`）。
- `timeout`：在数据库文件被锁定时，等待锁释放的最长时间，单位秒；在高并发写入时可适当调大此值。
- `detect_types`：用于启用 SQLite 类型检测与转换，常与 `PARSE_DECLTYPES`、`PARSE_COLNAMES` 一起使用，详见下文“数据类型与转换”。
- `isolation_level`：事务隔离级别，默认为 `'DEFERRED'`（延迟开始）；可设置为 `'IMMEDIATE'`、`'EXCLUSIVE'` 或 `None`（自动提交模式）。
- `check_same_thread`：默认值 `True`，意味着同一个连接只能在创建它的线程中使用；若设置为 `False`，可跨线程共享连接，需要自行保证线程安全。
- `factory`：指定一个 `Connection` 子类以自定义连接行为；一般无需修改。
- `cached_statements`：SQLite 语句缓存数量，可适当增大以提升性能。
- `uri`：若为 `True`，`database` 参数会被当作 URI 解析；可指定只读、共享内存等高级选项。

**要点提示**

1. **内存数据库（**`**':memory:'**`**）适用于临时数据、测试用例。**
2. **默认情况下，一个连接只能在创建它的线程中使用**（`check_same_thread=True`）。如果在多线程环境下共享连接，要将其设为 `False`，但要注意加锁保护。
3. **SQLite 单文件同时只能有一个写锁**，当其他线程/进程进行写操作时会进行等待，直到当前写事务提交或回滚。可以通过调整 `timeout` 缩短或延长等待时间。

### 2. 连接属性与方法

- `conn.cursor()`：创建并返回一个游标（`Cursor`）对象，用于执行 SQL 语句与获取结果。
- `conn.commit()`：提交当前事务，将所有未提交的写操作同步到数据库文件。
- `conn.rollback()`：回滚当前事务，撤销自上次 `commit()` 以来的所有更改。
- `conn.close()`：关闭连接，释放资源；若还有未提交的事务，会自动回滚。
- `conn.execute(sql, parameters)`：以最简方式执行 SQL 并返回一个 `Cursor` 对象；等价于 `cursor = conn.cursor(); cursor.execute(sql, parameters)`。
- `conn.executemany(sql, seq_of_parameters)`：批量执行相同 SQL 但不同参数；等价于循环调用 `execute`。
- `conn.executescript(script)`：一次执行多条 SQL 语句（不支持参数绑定），通常用于初始化表、创建索引、插入多行等场景。

```python
# 示例：基本连接与关闭
import sqlite3

conn = sqlite3.connect('mydb.db')
print(type(conn))  # <class 'sqlite3.Connection'>

# 快捷执行
cursor = conn.execute('SELECT sqlite_version()')
version = cursor.fetchone()[0]
print('SQLite version:', version)

conn.commit()   # 如果有写操作，需要手动提交
conn.close()
```

**要点提示**

- `conn.execute(...)` 返回的游标可以直接使用 `fetchone()`、`fetchall()` 获取结果，也可以 `for row in conn.execute(...)` 迭代。
- **每次对数据库做写操作（INSERT/UPDATE/DELETE/CREATE/DROP 等）都需要显式** `**commit()**`**，否则在连接关闭时会自动回滚**。
- 使用 `executescript` 时，SQL 语句之间用分号分隔；此方法不支持参数占位。

---

## 三、游标（Cursor）与执行 SQL

### 1. 创建与使用游标

```python
import sqlite3

conn = sqlite3.connect('example.db')
cursor = conn.cursor()  # 创建一个游标实例

# 执行一条 CREATE TABLE 语句
cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        age     INTEGER,
        email   TEXT
    )
''')

# 插入一条记录（写操作）
cursor.execute(
    'INSERT INTO users (username, age, email) VALUES (?, ?, ?)',
    ('alice', 30, 'alice@example.com')
)

# 查询所有记录
cursor.execute('SELECT id, username, age, email FROM users')
all_rows = cursor.fetchall()  # 获取所有结果，返回列表，每项是元组
print(all_rows)

# 记得提交事务
conn.commit()
cursor.close()
conn.close()
```

- **常用方法**

- `cursor.execute(sql, parameters=())`：执行单条 SQL，使用参数绑定替代字符串拼接，防止 SQL 注入。
- `cursor.executemany(sql, seq_of_parameters)`：批量执行相同 SQL，参数为可迭代对象（如列表）中的多组参数。
- `cursor.executescript(script)`：一次执行包含多条 SQL 的脚本，不支持参数绑定。
- `cursor.fetchone()`：获取一行查询结果，若无更多行则返回 `None`。
- `cursor.fetchmany(size=N)`：获取 `size` 条结果，返回列表；若剩余行数少于 `size`，则返回剩余行。
- `cursor.fetchall()`：获取所有剩余查询结果，返回列表。
- 迭代游标：可以直接写 `for row in cursor:` 或 `for row in conn.execute(...):` 进行行级别迭代。

**要点提示**

1. **调用** `**fetchall()**` **时会一次性把结果加载到内存**，若查询结果非常大，可能会导致内存压力；可使用 `fetchone()` 或 `fetchmany()` 做分批处理。
2. **在执行写操作（INSERT/UPDATE/DELETE）后一定要调用** `**conn.commit()**`，否则这些更改不会保存。
3. **参数绑定**：在 SQL 语句中使用问号占位符（`?`），或命名占位符（`:name` 或 `@name`），将参数作为第二个参数传入 `execute`，可自动适配并防止注入。

### 2. 参数绑定方式

1. **位置参数（qmark style）**

```python
cursor.execute(
    'INSERT INTO users (username, age) VALUES (?, ?)',
    ('bob', 25)
)
```

2. **命名参数（named style）**

```python
cursor.execute(
    'INSERT INTO users (username, age) VALUES (:uname, :uage)',
    {'uname': 'carol', 'uage': 28}
)
```

3. **数字参数（numeric style）**

```python
cursor.execute(
    'INSERT INTO users (username, age) VALUES (?1, ?2)',
    ('dave', 22)
)
```

**要点提示**

- **切勿使用字符串格式化（**`**%**`**、**`**str.format()**`**、f-string 等）拼接 SQL**，会导致严重的 SQL 注入风险。
- 在批量插入时，尽量使用 `executemany`，效率比在循环里单次 `execute` 更高。

### 3. 批量操作：`executemany`

```python
users_to_add = [
    ('eve', 35, 'eve@example.com'),
    ('frank', 40, 'frank@example.com'),
    ('grace', 27, 'grace@example.com'),
]

cursor.executemany(
    'INSERT INTO users (username, age, email) VALUES (?, ?, ?)',
    users_to_add
)
conn.commit()
```

- **原理**：`executemany` 会将同一条 SQL 与多组参数组合，内部会循环执行多次 `execute`，但是它会尽可能地在 C 层进行参数绑定，提升性能。
- **注意**：如果列表非常大，也会一次性将所有 SQL 执行完；如果担心事务过于庞大无法回滚或内存压力，可手动分批执行，比如每 1000 条提交一次。

### 4. 同时执行多条语句：`executescript`

```python
script = """
    PRAGMA foreign_keys = ON;
    CREATE TABLE IF NOT EXISTS departments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
    );
    CREATE TABLE IF NOT EXISTS employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dept_id INTEGER,
        FOREIGN KEY(dept_id) REFERENCES departments(id)
    );
"""

conn.executescript(script)
conn.commit()
```

- `**executescript(script_string)**`

- 参数是一个包含多条以分号 `;` 分隔的 SQL 语句的字符串。
- 内部会按分号分割并依次执行，不支持参数绑定。
- 适合一次性创建多张表、添加多条记录、设置多个 PRAGMA 等场景。

**要点提示**

1. `**executescript**` **不支持参数占位**，若需要以变量创建表名或字段名，必须手动拼接字符串并自行保证安全，但一般不建议动态生成表结构。
2. 通常将数据库初始化脚本（DDL）放到多行字符串里，通过 `executescript` 一次运行，逻辑更清晰。

---

## 四、事务与上下文管理

### 1. 自动提交与手动提交

- 默认情况下，`sqlite3` 连接是在 **事务模式（autocommit=False）**。这意味着在执行任何写操作（INSERT、UPDATE、DELETE、CREATE、DROP 等）时，必须显式调用 `conn.commit()`，否则在连接关闭时会自动回滚所有更改。
- 若希望进入自动提交模式，可将 `isolation_level=None` 作为 `connect()` 参数。此时对数据库的每条写操作都会立即提交。

```python
# 自动提交模式
conn = sqlite3.connect('auto.db', isolation_level=None)
cursor = conn.cursor()
cursor.execute("INSERT INTO users (username) VALUES ('tina')")  # 自动提交
```

- **常见事务控制**

```python
conn = sqlite3.connect('example.db')
cursor = conn.cursor()

try:
    cursor.execute("BEGIN")      # 开始一个显式事务（与 isolation_level=None 的自动提交相反）
    cursor.execute("UPDATE accounts SET balance = balance - 100 WHERE id = ?", (1,))
    cursor.execute("UPDATE accounts SET balance = balance + 100 WHERE id = ?", (2,))
    conn.commit()                # 提交
except Exception as e:
    conn.rollback()              # 出错回滚
    raise
finally:
    cursor.close()
    conn.close()
```

**要点提示**

1. **在 Python 3.6+ 中，若你使用** `**with conn:**` **上下文管理，离开** `**with**` **块时会自动根据是否发生异常进行提交或回滚**。
2. **事务粒度**：默认为 `DEFERRED`，即第一次执行 DML（写操作）时才真正加锁；也可以显式 `BEGIN IMMEDIATE`（在事务开始时加写锁）、`BEGIN EXCLUSIVE`（加独占锁），适用于并发控制。

### 2. 使用上下文管理（`with`）

```python
import sqlite3

# 方式一：针对 Connection 使用 with，自动 commit/rollback
with sqlite3.connect('example.db') as conn:
    cursor = conn.cursor()
    cursor.execute('INSERT INTO users (username) VALUES (?)', ('uma',))
    # 若此处没有异常，离开 with 块时会自动 conn.commit()
    # 若出现异常，离开 with 块时会自动 conn.rollback()

# 方式二：针对 Cursor 也可使用 with（在 Python 3.7+ 支持）
with sqlite3.connect('example.db') as conn:
    with conn.cursor() as cursor:
        cursor.execute('DELETE FROM users WHERE username = ?', ('unknown',))
```

- **行为说明**

- `with sqlite3.connect(...) as conn:` 相当于在 `__enter__` 时返回 `conn`，在正常退出时调用 `conn.commit()`，在发生异常时调用 `conn.rollback()` 并将异常向外抛出。
- 在 Python 3.7+，`Cursor` 也支持上下文管理，可以在 `with conn.cursor() as cursor:` 结束后自动 `cursor.close()`。

**要点提示**

- **推荐使用** `**with**` **来管理连接和游标**，可以减少漏写 `commit` 或漏 `close` 导致的资源泄漏与事务未提交问题。
- 对于多次写操作应放在同一个 `with` 块中，确保它们在同一事务内要么全部成功、要么全部回滚。

---

## 五、行工厂（Row Factory）与结果处理

默认情况下，`Cursor` 返回的每一行是一个元组（`tuple`），列的顺序与查询语句中的 SELECT 列顺序一致。如果想要更方便地通过列名访问结果，则可以使用行工厂。

### 1. 使用内置的 `sqlite3.Row`

```python
import sqlite3

conn = sqlite3.connect('example.db')
# 将 row_factory 设置为 sqlite3.Row，之后 cursor.fetchall() 返回的每行是 sqlite3.Row 对象
conn.row_factory = sqlite3.Row  
cursor = conn.cursor()

cursor.execute('SELECT id, username, age FROM users WHERE age > ?', (20,))
rows = cursor.fetchall()

for row in rows:
    # row['username'] 或 row['age'] 等都可以
    print(f"User {row['id']}: {row['username']} (age={row['age']})")
```

- `**sqlite3.Row**` **特点**

- 继承自 `tuple`，既可以像元组一样使用索引访问，也可以像字典一样通过列名访问。
- `row.keys()` 可以获取列名列表；`list(row)` 则是值列表。

**要点提示**

- **在连接级别设置** `**row_factory**` **后，该设置对该连接的所有游标均有效**。
- `sqlite3.Row` 在小结果集下性能足够，但若对数千行做高频访问，访问字典键会略慢于元组访问。

### 2. 自定义行工厂

如果希望将查询结果放到自定义的 Python 对象、命名元组（`collections.namedtuple`）或字典中，也可自定义 `row_factory` 函数/类。

#### 2.1 命名元组示例

```python
import sqlite3
from collections import namedtuple

def namedtuple_factory(cursor, row):
    # 根据 cursor.description 中的列名动态创建 namedtuple 类型
    fields = [column[0] for column in cursor.description]
    RowClass = namedtuple('Row', fields)
    return RowClass(*row)

conn = sqlite3.connect('example.db')
conn.row_factory = namedtuple_factory
cursor = conn.cursor()

cursor.execute('SELECT id, username, age FROM users')
for row in cursor.fetchall():
    # 现在 row.id、row.username、row.age 都可以直接访问
    print(f"{row.id}: {row.username} is {row.age} years old")
```

#### 2.2 字典示例

```python
import sqlite3

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

conn = sqlite3.connect('example.db')
conn.row_factory = dict_factory
cursor = conn.cursor()

cursor.execute('SELECT id, username, age FROM users')
for row in cursor.fetchall():
    # 现在 row['username']、row['age'] 访问更直观
    print(row['id'], row['username'], row['age'])
```

**要点提示**

1. **自定义** `**row_factory**` **会在每次** `**fetch*()**` **时调用，若对每行动态生成类会有额外开销**。如果结果集较大，建议创建一次命名元组类型后复用，而非每行都动态创建。
2. **如果只需偶尔通过列名访问，可将** `**cursor.description**` **缓存下来，然后用索引访问元组**。例如：

```python
cursor.execute('SELECT * FROM users')
columns = [col[0] for col in cursor.description]
for row in cursor.fetchall():
    user = dict(zip(columns, row))
    # ...
```

---

## 六、数据类型与转换

SQLite 本质上是弱类型（动态类型）的数据库，引擎在内部对“类型”采用“类型亲和性（type affinity）”而非严格的列类型约束。`sqlite3` 模块会把 SQLite 中的数据类型映射到相应的 Python 类型，但为了更精确地处理某些类型，可借助 `detect_types`、`PARSE_DECLTYPES`、`PARSE_COLNAMES`、自定义适配器与转换器等手段。

### 1. SQLite 的类型亲和性简介

- SQLite 列在创建表时可以指定类型名称，例如 `INTEGER`、`TEXT`、`BLOB`、`REAL`、`NUMERIC` 等，但 SQLite 并不会对插入数据做严格的类型检查，而是根据以下规则决定存储类型：

1. 如果列声明中包含 “INT”，亲和力为 `INTEGER`。
2. 如果包含 “CHAR”、“CLOB” 或 “TEXT”，亲和力为 `TEXT`。
3. 如果包含 “BLOB” 或声明为空，则亲和力为 `BLOB`。
4. 如果包含 “REAL”、“FLOA” 或 “DOUB”，亲和力为 `REAL`。
5. 否则，亲和力为 `NUMERIC`。

- 插入时，SQLite 会尝试将值转换到列的亲和类型，如果转换失败，则按原始类型存储。例如，如果往 `INTEGER` 列插入 `'123'`（字符串），则自动转换为整数 `123`；若插入 `'abc'`，则保留文本 `'abc'`。

### 2. Python 与 SQLite 类型映射

|   |   |   |
|---|---|---|
|SQLite 存储类型|对应 Python 类型|备注|
|`NULL`|`NoneType`<br><br>(`None`<br><br>)||
|`INTEGER`|`int`|64 位有符号整数|
|`REAL`|`float`|IEEE 浮点数|
|`TEXT`|`str`|Python 字符串（Unicode）|
|`BLOB`|`bytes`|Python 原始字节序列|

- 在大多数场景下，直接插入上述类型时，无需关注额外转换，模块会自动映射。例如：

```python
cursor.execute("INSERT INTO ttext (content) VALUES (?)", ("你好，世界",))
cursor.execute("INSERT INTO tblob (data) VALUES (?)", (b'\x00\x01\x02',))
```

**要点提示**

1. **如果对数据类型有更严格的需求，可在表定义时指定合适的列类型，但 SQLite 不会强制执行，主要用于亲和力提示。**
2. **对于** `**NUMERIC**` **亲和列，可以插入** `**decimal.Decimal**`**，但 SQLite 内部会先转换为文本或浮点，因此若要在 Python 中精确还原成** `**Decimal**`**，需要自定义转换器。**

### 3. `detect_types`、`PARSE_DECLTYPES` 与 `PARSE_COLNAMES`

- `**detect_types**` **参数**：在调用 `connect()` 时，可指定为以下任意组合：

- `sqlite3.PARSE_DECLTYPES`：根据列在创建表时声明的类型来转换结果。例如，如果表定义为 `created_at TIMESTAMP`，则查询时 Python 可以将该列自动转换成 `datetime.datetime`（前提是注册了相应的转换器）。
- `sqlite3.PARSE_COLNAMES`：根据查询时 SELECT 子句中为列起的别名（alias）来判断类型。例如：

```sql
SELECT created AS "created [timestamp]" FROM events;
```

如果在别名中指定了 `[timestamp]`，则可让 Python 按照 `timestamp` 类型进行转换。

- **示例：自动转换** `**datetime**`

1. 创建表时声明列类型：

```sql
CREATE TABLE events (
    id INTEGER PRIMARY KEY,
    name TEXT,
    created TIMESTAMP
);
```

2. 在 Python 中连接时启用 `PARSE_DECLTYPES`：

```python
import sqlite3
import datetime

# 先注册 datetime 转换器
sqlite3.register_adapter(datetime.datetime, lambda val: val.isoformat(' '))
sqlite3.register_converter("timestamp", lambda val: datetime.datetime.fromisoformat(val.decode()))

# 连接并启用类型检测
conn = sqlite3.connect(
    'events.db',
    detect_types=sqlite3.PARSE_DECLTYPES
)
cursor = conn.cursor()

# 插入 datetime 对象，适配器会将其转换为 ISO 格式字符串
now = datetime.datetime.now()
cursor.execute(
    'INSERT INTO events (name, created) VALUES (?, ?)',
    ('Test Event', now)
)
conn.commit()

# 查询时，“created”列会自动恢复为 datetime 对象（因声明类型为 TIMESTAMP 并注册了转换器）
cursor.execute('SELECT id, name, created FROM events')
row = cursor.fetchone()
print(type(row['created']), row['created'])  # <class 'datetime.datetime'> 2025-06-02 12:34:56.789
```

3. 示例中关键点：

- 先用 `register_adapter(datetime.datetime, adapter_func)` 将 `datetime` → 可存储类型（如字符串）的转换逻辑注册给模块。
- 再用 `register_converter("timestamp", converter_func)` 将数据库中类型名字 `"timestamp"` 对应的字节值转换回 Python 对象。
- 在 `connect()` 时加上 `detect_types=sqlite3.PARSE_DECLTYPES`，让模块根据表声明的列类型来启用转换器。

**要点提示**

1. `**PARSE_DECLTYPES**`**：根据表创建时为列指定的类型名称（不区分大小写）来决定是否调用相应的转换函数。**
2. `**PARSE_COLNAMES**`**：根据** `**SELECT ... AS "colname [typename]"**` **中的** `**typename**` **来决定是否调用转换函数。**
3. **对于多种自定义类型，都可以先调用** `**sqlite3.register_adapter**` **和** `**sqlite3.register_converter**` **注册后，再配合** `**detect_types**` **进行自定义序列化。**

---

## 七、自定义适配器（Adapter）与转换器（Converter）

当你想让 SQLite 自动存储并还原某些 Python 原生类型（如 `datetime.date`、`decimal.Decimal`、`uuid.UUID`、自定义对象等），可以使用 `sqlite3.register_adapter()` 和 `sqlite3.register_converter()` 注册对应逻辑。

### 1. `register_adapter`

- **用法**：`sqlite3.register_adapter(py_type, adapter_func)`

- `py_type`：需要适配的 Python 类型（class）。
- `adapter_func(value)`：将 `value` 转换为 SQLite 可存储的类型（通常是 `bytes` 或 `str`），返回转换后的值。

```python
import sqlite3
import uuid

# 1. 定义如何把 uuid.UUID 转成可存储类型（字符串）
def adapt_uuid(u):
    return u.hex  # 或 str(u)

# 2. 注册
sqlite3.register_adapter(uuid.UUID, adapt_uuid)
```

- 当你向数据库插入一个 `uuid.UUID` 实例时，SQLite 会自动调用 `adapt_uuid()` 把其转换为字符串；数据库内部存储为 TEXT 或 BLOB，具体取决于表定义。

### 2. `register_converter`

- **用法**：`sqlite3.register_converter(sqlite_type, converter_func)`

- `sqlite_type`：数据库中声明的类型名（如 `"UUID"`、`"DATE"`、`"DECIMAL"` 等，需与表定义或列别名中对应）。不区分大小写。
- `converter_func(value_bytes)`：接收数据库读取出的字节流（`bytes`），将其转换为对应 Python 类型后返回。

```python
import sqlite3
import uuid

# 1. 定义如何把数据库中的十六进制字符串转换回 uuid.UUID
def convert_uuid(b):
    # b 是 bytes，例如 b'550e8400e29b41d4a716446655440000'
    return uuid.UUID(hex=b.decode())

# 2. 注册
sqlite3.register_converter("UUID", convert_uuid)

# 3. 示例：创建表时使用自定义类型
conn = sqlite3.connect(
    'test_uuid.db',
    detect_types=sqlite3.PARSE_DECLTYPES
)
cursor = conn.cursor()

cursor.execute('CREATE TABLE IF NOT EXISTS items (id UUID PRIMARY KEY, name TEXT)')
u = uuid.uuid4()
cursor.execute('INSERT INTO items (id, name) VALUES (?, ?)', (u, 'Sample'))
conn.commit()

# 查询时，id 列会被转换成 uuid.UUID
cursor.execute('SELECT id, name FROM items')
row = cursor.fetchone()
print(type(row[0]), row[0])  # <class 'uuid.UUID'> 550e8400-e29b-41d4-a716-446655440000
```

**要点提示**

1. **适配器（Adapter）负责“Python 值 → 存储值”**；通常在写入阶段参与。
2. **转换器（Converter）负责“存储值 → Python 值”**；通常在查询阶段参与，需结合 `detect_types` 启用。
3. **类型名称匹配**：`register_converter` 的第一个参数要和表定义中列类型或 `SELECT` 别名中的类型（不区分大小写）一致，否则不会自动调用。
4. **如果你想让适配器输出的字节/字符串对应不同类型的存储行为，可在表创建时显式指定列类型。例如把 UUID 存储为 BLOB，可先将** `**adapt_uuid**` **返回一个 16 字节二进制，再把列定义为** `**BLOB**`**。**

---

## 八、常用实战示例

下面通过几个常见场景，演示在 Python 中用 `sqlite3` 模块对数据库进行更全面的操作。

### 1. 创建数据库并插入复杂数据

```python
import sqlite3
import datetime

# 1. 连接并启用 datetime 类型自动转换
sqlite3.register_adapter(datetime.date, lambda d: d.isoformat())
sqlite3.register_converter("DATE", lambda b: datetime.date.fromisoformat(b.decode()))

conn = sqlite3.connect(
    'company.db',
    detect_types=sqlite3.PARSE_DECLTYPES
)
cursor = conn.cursor()

# 2. 创建部门（departments）表和员工（employees）表
cursor.executescript("""
CREATE TABLE IF NOT EXISTS departments (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS employees (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    name      TEXT NOT NULL,
    dept_id   INTEGER,
    hire_date DATE,
    salary    REAL,
    FOREIGN KEY(dept_id) REFERENCES departments(id)
);
""")
conn.commit()

# 3. 插入部门数据
departments = [("HR",), ("Engineering",), ("Sales",)]
cursor.executemany('INSERT OR IGNORE INTO departments (name) VALUES (?)', departments)
conn.commit()

# 4. 查询部门 ID 以便插入员工
cursor.execute('SELECT id, name FROM departments')
dept_map = {row[1]: row[0] for row in cursor.fetchall()}

# 5. 批量插入员工
today = datetime.date.today()
employees = [
    ("Alice", dept_map["Engineering"], today, 90000.0),
    ("Bob", dept_map["HR"], today, 60000.0),
    ("Carol", dept_map["Sales"], today, 70000.0),
]
cursor.executemany(
    'INSERT INTO employees (name, dept_id, hire_date, salary) VALUES (?, ?, ?, ?)',
    employees
)
conn.commit()
```

**要点提示**

1. **使用** `**INSERT OR IGNORE**` **语法可以在唯一约束冲突时跳过该行插入**，避免程序抛出 `IntegrityError`。
2. **结合** `**datetime.date**` **与** `**register_adapter**`**/**`**register_converter**`**，可在 Python 端直接插入和读取日期类型而无需手动字符串转换。**
3. **在插入数据前先查询关联表（如部门）的主键，避免硬编码 ID，提高灵活性。**

### 2. 使用事务保护多步写操作

```python
import sqlite3

def transfer_funds(conn, from_acc, to_acc, amount):
    """
    在 accounts 表中，将 from_acc 账户的金额减少 amount，将 to_acc 增加 amount。
    如果余额不足或出现任何异常，回滚事务。
    """
    try:
        conn.execute('BEGIN IMMEDIATE')  # 显式启动一个写事务并加写锁
        cur = conn.execute('SELECT balance FROM accounts WHERE id = ?', (from_acc,))
        row = cur.fetchone()
        if row is None:
            raise ValueError(f"Account {from_acc} does not exist")
        if row[0] < amount:
            raise ValueError("Insufficient funds")

        # 扣款
        conn.execute('UPDATE accounts SET balance = balance - ? WHERE id = ?', (amount, from_acc))
        # 收款
        conn.execute('UPDATE accounts SET balance = balance + ? WHERE id = ?', (amount, to_acc))

        conn.commit()
        print("Transfer successful")
    except Exception as e:
        conn.rollback()
        print("Transfer failed:", e)

# 示例使用
conn = sqlite3.connect('bank.db')
# 假设 accounts 表已存在且有必要的初始数据
transfer_funds(conn, 1, 2, 100.0)
conn.close()
```

**要点提示**

1. **使用** `**BEGIN IMMEDIATE**` **可以确保事务一开始就获取写锁**，防止在事务中途被其他写操作阻塞。
2. **在事务中任何一步出现异常，都要显式** `**rollback()**`**，否则会导致数据库处于半提交状态。**
3. **若只调用** `**conn.commit()**` **而无写操作，则 commit 不会报错；若进入自动提交模式（**`**isolation_level=None**`**），则每条写操作会自动提交，此时就需要手动管理事务。**

### 3. 动态生成 WHERE 子句与防注入

当需要根据用户输入动态构建过滤条件时，千万不要直接字符串拼接。可以采用以下方法：

```python
import sqlite3

def query_products(conn, filters):
    """
    filters 是一个字典，例如 {'category': 'Electronics', 'price_min': 100, 'price_max': 500}
    动态构建 WHERE 子句，但使用参数绑定防止注入。
    """
    sql = "SELECT id, name, category, price FROM products"
    where_clauses = []
    params = []

    if 'category' in filters:
        where_clauses.append("category = ?")
        params.append(filters['category'])
    if 'price_min' in filters:
        where_clauses.append("price >= ?")
        params.append(filters['price_min'])
    if 'price_max' in filters:
        where_clauses.append("price <= ?")
        params.append(filters['price_max'])
    if 'keyword' in filters:
        where_clauses.append("name LIKE ?")
        params.append(f"%{filters['keyword']}%")

    if where_clauses:
        sql += " WHERE " + " AND ".join(where_clauses)

    cursor = conn.execute(sql, params)
    return cursor.fetchall()

# 示例调用
conn = sqlite3.connect('shop.db')
filters = {'category': 'Books', 'price_max': 50, 'keyword': 'Python'}
results = query_products(conn, filters)
for row in results:
    print(row)
conn.close()
```

**要点提示**

1. **在动态构建 SQL 时，只拼接固定的字段名和逻辑关键字（AND、OR 等），而将所有变量部分都放到参数列表里，通过** `**?**` **占位。**
2. **不要把用户输入直接拼到 SQL 里，否则极易导致 SQL 注入漏洞。**

### 4. 处理 BLOB（二进制）数据

假设你要在 SQLite 中存储图片或其他二进制文件，可以使用 `sqlite3.Binary()` 辅助函数将 `bytes` 包装为可以安全插入的类型。

```python
import sqlite3

# 存储图片到 BLOB 列
def store_image(conn, image_path, image_name):
    with open(image_path, 'rb') as f:
        img_data = f.read()
    # sqlite3.Binary() 将 bytes 转换为合适的格式
    conn.execute(
        'INSERT INTO images (name, data) VALUES (?, ?)',
        (image_name, sqlite3.Binary(img_data))
    )
    conn.commit()

# 从 BLOB 列读取图片到文件
def load_image(conn, image_id, output_path):
    cursor = conn.execute(
        'SELECT data FROM images WHERE id = ?',
        (image_id,)
    )
    row = cursor.fetchone()
    if row is None:
        raise ValueError("Image not found")
    img_data = row[0]  # bytes
    with open(output_path, 'wb') as f:
        f.write(img_data)

# 示例
conn = sqlite3.connect('media.db')
conn.execute('CREATE TABLE IF NOT EXISTS images (id INTEGER PRIMARY KEY, name TEXT, data BLOB)')
conn.commit()

store_image(conn, 'photo.jpg', 'MyPhoto')
load_image(conn, 1, 'exported_photo.jpg')
conn.close()
```

**要点提示**

1. **要插入二进制数据，务必使用** `**sqlite3.Binary(bytes_data)**`，否则在 Python 3 中直接传 `bytes` 也通常能工作，但在 Python 2 或者特定版本可能需要显式包装。
2. **BLOB 数据会增大 SQLite 文件体积，若需要存储大量大文件，建议改用文件系统 + 路径存储的方式。**

### 5. 使用 `ATTACH` 实现多库查询

SQLite 支持同时打开多个数据库，通过 `ATTACH` 将其他数据库附加到当前连接，并赋予别名，然后在查询时通过别名指定库名。

```python
import sqlite3

# 连接主库
conn = sqlite3.connect('main.db')
cursor = conn.cursor()

# 创建主库表
cursor.execute('CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)')
cursor.execute("INSERT OR IGNORE INTO users (id, name) VALUES (1, 'Alice')")
conn.commit()

# 附加另一个数据库
cursor.execute("ATTACH DATABASE 'archive.db' AS archive")
# 在 archive 下创建同名表并插入数据
cursor.executescript("""
CREATE TABLE IF NOT EXISTS archive.users (id INTEGER PRIMARY KEY, name TEXT);
INSERT OR IGNORE INTO archive.users (id, name) VALUES (2, 'Bob');
""")
conn.commit()

# 联合查询主库和附加库中的用户
cursor.execute("""
SELECT id, name, 'main' AS source FROM users
UNION ALL
SELECT id, name, 'archive' AS source FROM archive.users
""")
for row in cursor.fetchall():
    print(row)  # (1, 'Alice', 'main')  和  (2, 'Bob', 'archive')

# 分离附加库
cursor.execute("DETACH DATABASE archive")
conn.close()
```

**要点提示**

1. `**ATTACH DATABASE 'filename' AS alias**` **可以在同一个连接内同时访问多个数据库文件**。
2. **对附加的数据库执行 DML/DQL 时，需要在表名前加上** `**alias.**` **前缀，以区分不同数据库中的表。**
3. **当不再需要访问附加库时，一定要调用** `**DETACH DATABASE alias**`**，释放资源并关闭文件句柄。**

---

## 九、性能与优化

虽然 SQLite 适合轻量级场景，但在数据量增大或并发需求提升时，仍有一些优化策略可以提升性能。

### 1. 使用事务批量写入

将多次写操作包裹在一个事务内，大幅减少文件 I/O 次数：

```python
# 坏示例：每条插入自动提交
for item in items:
    cursor.execute('INSERT INTO t (a, b) VALUES (?, ?)', item)
    conn.commit()  # 每次都同步到磁盘，极慢

# 优化示例：一次性在事务中提交
cursor.execute('BEGIN')
for item in items:
    cursor.execute('INSERT INTO t (a, b) VALUES (?, ?)', item)
conn.commit()  # 一次提交，最快
```

**要点提示**

- SQLite 默认会为每个写操作做一次事务提交（若 `isolation_level=None`），或在游标执行时自动开启一个事务并在 `commit()` 时提交；无论哪种模式，都要避免在循环中频繁调用 `commit()`。
- 推荐显式 `BEGIN`，完成所有写操作后再 `commit()`。

### 2. 禁用同步与 WAL 模式

在对性能要求极高、对数据持久性要求相对宽松的场景下，可以调整 PRAGMA 设置：

```python
cursor.executescript("""
PRAGMA synchronous = OFF;   -- 关闭同步，写操作后不等待磁盘刷新
PRAGMA journal_mode = MEMORY; -- 日志保存在内存中而非磁盘
""")
conn.commit()
```

- `PRAGMA synchronous = OFF/0|NORMAL/1|FULL/2|EXTRA/3`：

- `FULL`（默认）保证事务提交时会等待操作系统将数据写入物理磁盘。
- `NORMAL` 略微提升性能，但在崩溃时可能丢失少量最新事务。
- `OFF` 性能最高，但崩溃时易导致数据库损坏。

- `PRAGMA journal_mode = DELETE/TRUNCATE/PERSIST/MEMORY/WAL/OFF`：

- `WAL`（Write-Ahead Logging）模式通常能显著提升并发写入性能：写入时先追加到 WAL 文件，不会阻塞读操作。
- `MEMORY` 日志只保存在内存，性能更好，但程序终止后日志信息丢失。
- `OFF` 关闭写前日志（危险，不建议在生产使用）。

**要点提示**

1. **这些 PRAGMA 设置会影响数据安全性，请评估崩溃与丢数据的风险后再决定**。
2. `**PRAGMA journal_mode = WAL**` **适合读多写少场景，允许多个并发读与一个写；但需要 SQLite 版本 ≥ 3.7.0。**
3. **在同一个连接中执行 PRAGMA 后对其生效，对其他连接也有影响；需要谨慎使用。**

### 3. 索引 (Index)

为常用的 WHERE、JOIN、ORDER BY 字段创建索引，可显著提升查询性能：

```python
# 假设 employees 表经常按 dept_id 查询
cursor.execute('CREATE INDEX IF NOT EXISTS idx_emp_dept ON employees(dept_id)')
conn.commit()
```

**要点提示**

1. **不要盲目为每个列都创建索引，索引会占用空间且插入/更新时需要维护索引，影响写性能。**
2. **可以使用** `**EXPLAIN QUERY PLAN SELECT ...**` **来查看查询计划，判断是否使用了索引。**

### 4. 减少 Python ↔ SQLite 之间的交互次数

- **批量操作**

- 使用 `executemany` 代替循环调用 `execute`。
- 如果需要大量数据加载，可考虑将数据先写到 CSV，再使用 SQLite 的 `import` 或通过 `conn.executescript()` 调用 `.readtable()` 等方式批量导入。

- **绑定参数一次构建多个 SQL**

- 对于大量结构相同但值不同的插入，使用 `INSERT INTO ... VALUES (...), (...), (...)` 语句（SQLite 3.7.11+ 支持多值插入）可减少 round-trip 次数：

```python
data = [(1, 'a'), (2, 'b'), (3, 'c')]
placeholders = ",".join(["(?, ?)"] * len(data))
flat_values = [x for tup in data for x in tup]
sql = f'INSERT INTO t (col1, col2) VALUES {placeholders}'
conn.execute(sql, flat_values)
conn.commit()
```

**要点提示**

1. **减少频繁的游标创建与销毁；在同一连接与游标中尽量合并多条 SQL。**
2. **对于只读查询，可考虑把** `**conn.row_factory = None**` **保持默认，让查询结果直接以元组形式返回，速度略快于字典/Row 形式。**

---

## 十、异常处理与错误类型

`sqlite3` 提供了一系列基于层次结构的异常类，用于在不同错误场景下捕获并处理。

### 1. 常见异常类

```pgsql
BaseException
 └── Exception
      └── sqlite3.Error
           ├── sqlite3.DatabaseError
           │    ├── sqlite3.DataError
           │    ├── sqlite3.IntegrityError
           │    ├── sqlite3.ProgrammingError
           │    ├── sqlite3.OperationalError
           │    ├── sqlite3.NotSupportedError
           │    └── sqlite3.InterfaceError
           └── sqlite3.Warning
```

- `**sqlite3.Error**`：所有 sqlite3 异常的基类。
- `**sqlite3.OperationalError**`：底层库返回的错误，如数据库文件不存在、表不存在、磁盘空间不足、锁冲突等。
- `**sqlite3.IntegrityError**`：违反完整性约束时抛出，如主键重复、外键约束失败、`CHECK` 约束失败等。
- `**sqlite3.ProgrammingError**`：SQL 语法错误、错误的参数绑定、不正确的游标使用等。
- `**sqlite3.DataError**`：数据类型错误或值超出允许范围。
- `**sqlite3.NotSupportedError**`：调用了不支持的 SQLite 功能。
- `**sqlite3.InterfaceError**`：在 Python ↔ SQLite 接口层发生的问题，如参数类型不匹配。
- `**sqlite3.Warning**`：警告类型，一般较少用到。

### 2. 捕获与处理示例

```python
import sqlite3

conn = sqlite3.connect(':memory:')
cursor = conn.cursor()

try:
    cursor.execute('CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT UNIQUE)')
    conn.commit()

    # 插入两条同名记录，触发 IntegrityError
    cursor.execute("INSERT INTO test (name) VALUES ('Bob')")
    cursor.execute("INSERT INTO test (name) VALUES ('Bob')")
    conn.commit()
except sqlite3.IntegrityError as ie:
    print("IntegrityError:", ie)
    conn.rollback()
except sqlite3.OperationalError as oe:
    print("OperationalError:", oe)
    conn.rollback()
except sqlite3.Error as e:
    print("Other sqlite3 error:", e)
    conn.rollback()
finally:
    cursor.close()
    conn.close()
```

**要点提示**

1. **在写操作前后都要捕获并处理** `**IntegrityError**`**、**`**OperationalError**` **等，以保证数据库不会挂起未提交的事务。**
2. **使用通用基类** `**sqlite3.Error**` **捕获所有类型时不要过度笼统，否则可能掩盖细节；在需要更细粒度识别时，可分开捕获子类。**
3. **对** `**fetchone()**` **返回** `**None**` **也要做判断，避免后续访问** `**row[0]**` **类型错误。**

---

## 十一、最佳实践与注意事项

1. **强烈推荐使用参数化查询**

- 永远不要通过字符串拼接生成 SQL。
- 使用 `?`、`:name` 或 `?1, ?2` 等占位符，将所有值都当做参数传入。

2. **在多线程环境下要小心**

- 每个线程应该使用各自的连接；若要跨线程共享同一个连接，需在 `connect(..., check_same_thread=False)` 并自行加锁，保证每次操作前后不会出现并发读写冲突。

3. **合理使用事务**

- 对多条写操作使用单个事务，避免循环中频繁 `commit()` 带来的性能问题。
- 对于只读查询，可以使用自动提交模式 (`isolation_level=None`) 或者显式 `BEGIN`/`END` 提升并发读性能。

4. **及时关闭连接与游标**

- 不再使用游标后，调用 `cursor.close()`；不再使用连接后，调用 `conn.close()`。
- 推荐使用上下文管理（`with sqlite3.connect(...) as conn:`）来自动管理关闭与回滚。

5. **使用适当的 PRAGMA 来优化**

- 通过 `PRAGMA journal_mode = WAL`、`PRAGMA synchronous = NORMAL` 等调整 SQLite 行为，以平衡安全性与性能。
- 可使用 `PRAGMA cache_size`、`PRAGMA temp_store` 优化内存使用。

6. **谨慎存储大文件与 BLOB**

- 虽然可以在 SQLite 中存储图片、音频等 BLOB，但对于大量大文件，建议将文件存放在文件系统，数据库中仅存路径。

7. **时刻留意 SQLite 版本**

- Python 自带的 SQLite 版本可能与系统的 SQLite 库版本不同；可通过 `sqlite3.sqlite_version` 查看 SQLite 引擎版本，通过 `sqlite3.version` 查看 Python 模块版本。
- 不同的 SQLite 版本支持不同的 SQL 特性（如 FTS5、JSON1、窗口函数等），在使用高级功能前需要确认当前版本支持情况。

8. **备份与恢复**

- 在需要热备份（复制正在使用的数据库）时，可使用 SQLite 提供的[在线备份 API](https://docs.python.org/3/library/sqlite3.html#sqlite3.Connection.backup)：

```python
with sqlite3.connect('target_backup.db') as bck:
    conn.backup(bck, pages=0, progress=None)
```

- 或者在应用层做文件级别的复制，但需保证在复制时没有未提交的写事务。

---

## 十二、示例：使用 `Connection.backup` 做在线备份

```python
import sqlite3
import time

def create_backup(source_db, backup_db):
    # 连接源数据库（只读模式）
    src = sqlite3.connect(f'file:{source_db}?mode=ro', uri=True)
    # 连接目标数据库
    dest = sqlite3.connect(backup_db)
    with dest:
        # 将 src 数据库备份到 dest，pages=1 表示每次复制 1 个页面，可通过 progress 回调监控进度
        src.backup(dest, pages=1, progress=lambda status, remaining, total: print(f'Copied {total-remaining}/{total} pages...'))
    src.close()
    dest.close()

# 示例调用
create_backup('production.db', 'backup.db')
print("Backup completed.")
```

**要点提示**

1. `**Connection.backup()**` **是原子操作**，在备份过程中仍可对源数据库进行读写（但写入时会有短暂延迟），非常适合生产环境热备份。
2. **如果不需要进度通知，可以将** `**pages=0, progress=None**` **作为默认值，此时一次性完成所有页面复制。**

---

## 十三、综合示例：构建一个简单的数据访问层（DAO）

下面演示一个较为完善的简单数据库封装类，使得上层业务调用更清晰。

```python
import sqlite3
import threading
from typing import Optional, List, Dict, Any
import datetime

class SQLiteDAO:
    """
    一个线程安全的 SQLite 数据访问层示例（Demo）。
    - 使用 threading.RLock 来保护连接。
    - 支持自动创建连接、获取游标、事务管理、行工厂切换等功能。
    """

    def __init__(self, db_path: str, detect_types=0, row_factory=sqlite3.Row):
        self.db_path = db_path
        self.detect_types = detect_types
        self.row_factory = row_factory
        self._lock = threading.RLock()
        self._conn: Optional[sqlite3.Connection] = None

    def _connect(self):
        if self._conn is None:
            conn = sqlite3.connect(
                self.db_path,
                detect_types=self.detect_types,
                check_same_thread=False
            )
            conn.row_factory = self.row_factory
            self._conn = conn
        return self._conn

    def _get_cursor(self):
        conn = self._connect()
        return conn.cursor()

    def execute(self, sql: str, params: tuple = ()) -> sqlite3.Cursor:
        """
        执行单条 SQL，并返回游标。
        自动加锁，保证多线程安全。
        """
        with self._lock:
            cursor = self._get_cursor()
            try:
                cursor.execute(sql, params)
            except sqlite3.Error:
                self._conn.rollback()
                raise
            return cursor

    def executemany(self, sql: str, seq_of_params: List[tuple]) -> None:
        """
        批量执行 SQL。
        """
        with self._lock:
            cursor = self._get_cursor()
            try:
                cursor.executemany(sql, seq_of_params)
            except sqlite3.Error:
                self._conn.rollback()
                raise

    def query_one(self, sql: str, params: tuple = ()) -> Optional[Dict[str, Any]]:
        """
        查询单行，返回字典或 Row 对象。
        """
        cursor = self.execute(sql, params)
        result = cursor.fetchone()
        return result

    def query_all(self, sql: str, params: tuple = ()) -> List[Dict[str, Any]]:
        """
        查询多行，返回字典列表或 Row 列表。
        """
        cursor = self.execute(sql, params)
        return cursor.fetchall()

    def commit(self):
        """
        手动提交事务。
        """
        with self._lock:
            if self._conn:
                self._conn.commit()

    def close(self):
        """
        关闭连接。
        """
        with self._lock:
            if self._conn:
                self._conn.close()
                self._conn = None

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """
        如果退出时没有异常，则提交；否则回滚并关闭连接。
        """
        if exc_type is None:
            self.commit()
        else:
            with self._lock:
                if self._conn:
                    self._conn.rollback()
        self.close()

# 使用示例
if __name__ == '__main__':
    # 先注册日期类型转换
    def adapt_date(d: datetime.date) -> str:
        return d.isoformat()
    def convert_date(b: bytes) -> datetime.date:
        return datetime.date.fromisoformat(b.decode())
    sqlite3.register_adapter(datetime.date, adapt_date)
    sqlite3.register_converter('DATE', convert_date)

    with SQLiteDAO('company2.db', detect_types=sqlite3.PARSE_DECLTYPES) as dao:
        # 创建表
        dao.execute('''
            CREATE TABLE IF NOT EXISTS departments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE
            )
        ''')
        dao.execute('''
            CREATE TABLE IF NOT EXISTS employees (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                dept_id INTEGER,
                hire_date DATE,
                salary REAL,
                FOREIGN KEY(dept_id) REFERENCES departments(id)
            )
        ''')

        # 插入数据
        dao.execute('INSERT OR IGNORE INTO departments (name) VALUES (?)', ('Marketing',))
        dao.execute('INSERT OR IGNORE INTO departments (name) VALUES (?)', ('Finance',))

        # 查询部门 id
        row = dao.query_one('SELECT id FROM departments WHERE name = ?', ('Marketing',))
        dept_id = row['id'] if row else None

        # 插入员工
        today = datetime.date.today()
        dao.execute(
            'INSERT INTO employees (name, dept_id, hire_date, salary) VALUES (?, ?, ?, ?)',
            ('Diana', dept_id, today, 80000.0)
        )

        # 查询员工
        employees = dao.query_all('SELECT id, name, hire_date FROM employees')
        for emp in employees:
            print(emp['id'], emp['name'], emp['hire_date'])
```

**要点提示**

1. **封装一个简单的 DAO 类，可以规范化数据库连接管理、事务处理和异常处理，让业务逻辑更清晰。**
2. **在多线程环境下，使用** `**threading.RLock**` **或其他锁机制保护连接与游标，防止竞态条件或并发冲突。**
3. **在** `**__exit__**` **中既要 commit 也要 rollback，确保在出现异常时不会把事务挂在半提交状态，避免数据不一致。**

---

## 十四、总结

- `**sqlite3**` **模块**：是 Python 标准库提供的用于与 SQLite 数据库交互的核心模块，支持 DB-API 2.0 接口，适合嵌入式、单机、小型或中等并发场景。
- **核心步骤**：

1. `sqlite3.connect()` 打开（或创建）数据库并获取 `Connection`。
2. `conn.cursor()` 或 `conn.execute()` 创建并获得 `Cursor`，执行 SQL，并使用参数绑定防止注入。
3. `fetchone() / fetchmany() / fetchall()` 获取查询结果。
4. `conn.commit()` 提交事务，或在 `with` 块中自动提交/回滚。
5. `cursor.close()`、`conn.close()` 释放资源。

- **关键功能**：

- **参数绑定**：始终使用 `?` 或命名占位符，绝不拼接 SQL 字符串。
- **事务管理**：多写操作包裹在单个事务中，避免频繁调用 `commit()`。
- **行工厂**：使用 `sqlite3.Row` 或自定义工厂，使查询结果支持通过列名访问。
- **数据类型转换**：通过 `register_adapter`/`register_converter` 与 `detect_types` 机制，实现如 `datetime`、`Decimal`、`UUID` 等自定义类型的自动存储与恢复。
- **BLOB 操作**：使用 `sqlite3.Binary()` 插入二进制数据，或从 BLOB 列读取 `bytes` 并写入文件。
- **性能优化**：使用批量插入、索引、PRAGMA（如 `WAL`、`synchronous` 设定）、减少 round-trip 调用等策略提升速度。
- **错误处理**：捕获并区别对待 `IntegrityError`、`OperationalError`、`ProgrammingError` 等异常，保证事务在错误时可回滚并释放锁。
- **在线备份**：利用 `Connection.backup()` 可在数据库运行时进行热备份。

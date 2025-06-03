## 一、模块概述

1. **什么是** `**xml**` **模块**

- Python 标准库的 `xml` 包（package）包含了一组子模块，用于解析、创建、操作、验证和序列化 XML 文档。
- 它遵循了 W3C 的 XML 标准，可帮助开发者以多种方式（树形、DOM、事件驱动等）来处理 XML。

2. **为何选择 Python 内置的** `**xml**`

- **开箱即用**：无需安装任何第三方库，就能满足大多数 XML 解析与生成需求。
- **多种 API 风格**：支持基于树的 `xml.etree.ElementTree`、基于 DOM 的 `xml.dom.minidom/xml.dom`、基于事件的 `xml.sax`，甚至更底层的 `xml.parsers.expat`。可根据场景灵活选用。
- **与标准兼容**：虽然没有内置支持完整的 XSLT、XPath 规范，但对基本的 XML 处理相当完备。

3. **主要子模块一览**

- `xml.etree.ElementTree`：简称 ElementTree（常写作 `ET`），提供类似于“轻量级 DOM”的树形 API，使用最广泛。
- `xml.dom` 与 `xml.dom.minidom`：实现了 W3C DOM Level 1/Level 2 的接口，可构建完整的节点对象模型。`minidom` 是纯 Python 的简单实现。
- `xml.sax`：基于 SAX（Simple API for XML）的事件驱动解析器，适合处理超大或流式 XML。
- `xml.parsers.expat`：Expat 库的 Python 绑定，提供低层的、基于 C 的高性能解析器，可用于对性能有严格要求的场景。
- 其它辅助模块：

- `xml.sax.saxutils`：常用的工具函数（如 `escape()`、`unescape()`、`XMLGenerator` 等）。
- `xml.sax.handler`：定义了各种 SAX 事件处理类的基类。
- `xml.dom.pulldom`：结合 DOM 与 SAX 优点的“拉取式”解析 API。
- `xml.parsers`：模块化命名空间下，针对不同解析器的包装。

4. **何时用哪种方式**

- **ElementTree（**`**xml.etree.ElementTree**`**）**：最常用，API 简洁，既可解析入内存直接操作，也可增量（iterparse）处理，适合绝大多数中、小型 XML 文档。
- **DOM（**`**xml.dom.minidom/xml.dom**`**）**：需要完全符合 W3C DOM 规范、操作节点类型（如 `DocumentType`、`ProcessingInstruction`）或需要输出格式化（pretty-print）的场景，可选用 `minidom`。但 `minidom` 内存开销较大，性能较低。
- **SAX（**`**xml.sax**`**）**：适合处理“极大文件”或流式读取，不将整个文档加载到内存，通过回调函数处理各类节点事件。缺点是编程相对繁琐，需要维护“状态机”以记录解析进度。
- **Expat（**`**xml.parsers.expat**`**）**：与 SAX 类似，也是事件驱动，但更底层，提供更高性能，可用于自定义更细的回调；一般用户可不直用，除非有非常高性能需求。
- **PullDOM（**`**xml.dom.pulldom**`**）**：在需要结合 SAX 解析的低内存消耗与 DOM 的随机访问能力时，可使用 PullDOM，将部分子树在内存中构造为 DOM 节点。

---

## 二、`xml.etree.ElementTree`（ElementTree）详解

### 1. 模块引入与常用别名

```python
import xml.etree.ElementTree as ET
```

- 约定俗成：大多数示例与文档都使用别名 `ET`，以简化代码。

### 2. 基本概念

1. **Element 对象**

- `Element` 类代表 XML 树中的一个节点，其主要属性与方法包括：

- `tag`：元素的标签名称（字符串）。
- `attrib`：元素的属性字典（`dict[str, str]`）。
- `text`：元素的文本内容（`str` 或 `None`）。
- `tail`：元素结束标签之后、下一个兄弟元素开始前的文本（常用于保持格式化换行及缩进时的空白）。
- `list(child elements)`：可以直接当做列表来遍历其子节点；也可以通过 `elem.append(child)`、`elem.insert(idx, child)` 来添加。
- `find(path)`、`findall(path)`、`iterfind(path)`：根据简单路径或 XPath 片段查找子元素。

- `SubElement(parent, tag, attrib={})`：创建并返回一个新的 `Element`，并自动追加到 `parent` 的子节点中。

2. **ElementTree 对象**

- `ElementTree` 封装了 `Element` 对象以及与文件/流的解析和写出操作。
- 常用方法：

- `ElementTree.parse(source)`：从文件名或文件对象解析，返回一个 `ElementTree` 实例。
- `ElementTree(root_element)`：通过已有的根 `Element` 构造对应的 `ElementTree` 实例。
- `tree.getroot()`：获取根元素（`Element`）。
- `tree.write(file, encoding="utf-8", xml_declaration=True, default_namespace=None, method="xml")`：将整个树写入到文件（或文件名）中。

3. **XPath 简化支持**

- ElementTree 支持有限的 XPath 查询，包括：

- `'.'`：当前节点；
- `'.//'`：所有后代元素；
- `'tag'`：直接子元素；
- `'.//tag'`：任意层级后代中匹配标签名的元素；
- `'./tag1/tag2'`：下一级嵌套；
- `'*'`：匹配所有元素；
- `'[@attrib="value"]'`：按属性过滤；
- `'.//tag[@attrib="value"]'`。

- 不支持完整 XPath（如：`position()`、`text()`、`|` 并集操作、复杂函数等）。

---

### 3. 解析 XML 文档

1. **从文件解析**

```python
import xml.etree.ElementTree as ET

# 假设有一个 example.xml：
# <root>
#   <user id="1">Alice</user>
#   <user id="2">Bob</user>
# </root>

tree = ET.parse('example.xml')        # 读取并解析文件，返回 ElementTree
root = tree.getroot()                 # 获取根元素 <root>
print(root.tag)                       # 'root'

for user in root.findall('user'):     # 查找所有直接子元素 <user>
    uid = user.get('id')              # 属性值：'1'、'2'
    name = user.text                  # 文本内容：'Alice'、'Bob'
    print(uid, name)
```

1. **从字符串解析**

```python
import xml.etree.ElementTree as ET

xml_data = """
<root>
    <item name="Item1" value="10"/>
    <item name="Item2" value="20"/>
</root>
"""
root = ET.fromstring(xml_data)       # 直接返回根 Element，无需 ElementTree
for item in root.findall('item'):
    print(item.attrib['name'], item.attrib['value'])
```

1. **增量解析（iterparse）**

- 对于超大 XML 文件，一次性加载会占用大量内存，可用 `ET.iterparse()` 按事件（start、end）逐步解析，并在不需要的时候清理已处理节点。
- 典型用法：

```python
import xml.etree.ElementTree as ET

# iterparse 返回一个可迭代的 (event, element) 对
# 默认只生成 'end' 事件，也可通过 events=('start', 'end') 指定
context = ET.iterparse('huge.xml', events=('end',))
for event, elem in context:
    # 当遇到 <record> 完整结束时进行处理
    if elem.tag == 'record':
        # 处理 record 节点
        print(elem.find('field1').text)
        # 清理已处理的子树，释放内存
        elem.clear()
```

**要点提示**

1. `parse()` 会一次性构建完整树，适合中小型 XML；`fromstring()` 适合小量内存字符串解析；`iterparse()` 则适合大文件。
2. 在 `iterparse` 中，一旦 `elem.clear()`，该节点的所有子节点与文本都会被移除，需谨慎保证不再使用它们。

---

### 4. 操作（创建/修改）XML 树

1. **创建树与子节点**

```python
import xml.etree.ElementTree as ET

# 创建根元素
root = ET.Element('catalog')

# 添加子元素
book1 = ET.SubElement(root, 'book', attrib={'id': 'bk101'})
title = ET.SubElement(book1, 'title')
title.text = 'XML Developer\'s Guide'
author = ET.SubElement(book1, 'author')
author.text = 'Gambardella, Matthew'

# 继续添加另一本书
book2 = ET.SubElement(root, 'book', attrib={'id': 'bk102'})
ET.SubElement(book2, 'title').text = 'Midnight Rain'
ET.SubElement(book2, 'author').text = 'Ralls, Kim'
```

1. **修改节点与属性**

```python
# 假设已通过 parse() 得到一个 tree 和 root
for book in root.findall('book'):
    if book.get('id') == 'bk101':
        # 修改属性
        book.set('lang', 'en')
        # 修改子节点文本
        title = book.find('title')
        title.text = 'XML Developer\'s Guide (2nd Edition)'

# 删除某个子节点
for book in root.findall('book'):
    if book.get('id') == 'bk102':
        root.remove(book)
```

1. **序列化并写入文件**

```python
# 如果要输出带有 XML 声明的文档
tree = ET.ElementTree(root)
tree.write('output.xml', encoding='utf-8', xml_declaration=True)

# 如果想获得字符串形式，可用 ET.tostring()
xml_bytes = ET.tostring(root, encoding='utf-8', method='xml')
xml_str = xml_bytes.decode('utf-8')
print(xml_str)
```

1. **美化（Pretty-Print）输出**

- ElementTree 原生 `write()` 不会自动添加缩进或换行，输出会全部连在一起。可借助 `xml.dom.minidom` 对字符串进行格式化：

```python
import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom

# 假设 root 已构造完毕
rough_string = ET.tostring(root, 'utf-8')
reparsed = minidom.parseString(rough_string)
pretty_xml = reparsed.toprettyxml(indent="  ")
print(pretty_xml)

# 保存到文件
with open('pretty_output.xml', 'w', encoding='utf-8') as f:
    f.write(pretty_xml)
```

**要点提示**

1. **ElementTree 本身不关心缩进与格式；若需要可读性更好的格式，可借助** `**minidom**` **或第三方库（如** `**xml.dom.minidom**`**、**`**lxml**`**）。**
2. **在创建节点时，请始终对需要的子节点设定** `**text**`**；若需要在子元素后加入额外文本，可使用** `**tail**` **属性。**

---

### 5. 命名空间（Namespaces）处理

1. **解析时映射命名空间前缀**

- 当 XML 文档中带有命名空间（xmlns="..." 或 xmlns:ns="..."）时，ElementTree 会将元素的 `tag` 改为包含完整 URI 的字符串，格式为 `'{namespace}localname'`。
- 示例：

```xml
<?xml version="1.0"?>
<root xmlns:h="http://example.org/hello" xmlns:f="http://example.org/farewell">
    <h:msg>Hello</h:msg>
    <f:msg>Goodbye</f:msg>
</root>
```

```python
import xml.etree.ElementTree as ET

tree = ET.parse('ns_example.xml')
root = tree.getroot()

for elem in root:
    print(elem.tag, elem.text)
    # 输出类似：
    # {http://example.org/hello}msg Hello
    # {http://example.org/farewell}msg Goodbye
```

1. **查找带命名空间的元素**

- 当用 `find()`、`findall()` 时，需要在路径中带上完整的 `{namespace}tag` 格式，或者传入一个命名空间映射字典并使用前缀，在 ElementTree 1.3+（Python 3.8+）可以更简洁：

```python
ns = {
    'h': 'http://example.org/hello',
    'f': 'http://example.org/farewell'
}

# 找到 <h:msg>
hello = root.find('h:msg', namespaces=ns)
print(hello.text)  # Hello

# 或者查找任意命名空间下的 <msg>
for m in root.findall('.//{http://example.org/hello}msg'):
    print(m.text)
```

1. **创建带命名空间的元素**

- 在创建节点时，同样在 `tag` 中使用 `{}` 包含 URI，或者先注册命名空间并使用前缀：

```python
ET.register_namespace('h', 'http://example.org/hello')
ET.register_namespace('f', 'http://example.org/farewell')

root = ET.Element('root')
# 添加带命名空间的子元素
h_msg = ET.SubElement(root, '{http://example.org/hello}msg')
h_msg.text = 'Hello'

f_msg = ET.SubElement(root, '{http://example.org/farewell}msg')
f_msg.text = 'Goodbye'

tree = ET.ElementTree(root)
tree.write('ns_output.xml', encoding='utf-8', xml_declaration=True)
```

- `register_namespace(prefix, uri)` 会让 `write()` 在输出时使用 `prefix:tagname` 而不是 `{uri}tagname` 形式。

**要点提示**

1. **Python 内置的 ElementTree 对命名空间的支持相对原始，需要在** `**tag**` **本身手动带上** `**{uri}**`**，并在查找时同样如此。**
2. **推荐同时使用** `**register_namespace**`**，否则直接写出会保留完整的** `**{uri}**` **语法，不够直观。**
3. **命名空间映射（**`**namespaces=...**`**）从 Python 3.8 开始支持；更低版本需要手动拼接** `**{uri}**`**，无法使用前缀形式。**

---

### 6. 错误处理与调试

1. **捕获解析错误**

- 在解析有语法错误或不合规范的 XML 文件时，ElementTree 会抛出 `xml.etree.ElementTree.ParseError`。可捕获并打印行号、列号、错误原因。

```python
import xml.etree.ElementTree as ET

try:
    tree = ET.parse('malformed.xml')
except ET.ParseError as e:
    print(f"ParseError: {e}")  # e.pos 可获取行号和列号
```

1. **验证 XML 模式（XSD/DTD）**

- **注意：Python 标准库本身不支持 XML Schema (XSD) 或 DTD 验证**。如果需要验证，可以借助第三方库（如 `lxml`）。
- 对于简单的 DTD 验证，可使用 `xml.dom.minidom` 结合 `DocumentType`，但通常推荐直接使用 `lxml.etree`。

2. **调试输出**

- 可将树序列化为字符串并打印，结合 `minidom.toprettyxml()`，以便逐步检查树结构与内容是否符合预期。

```python
rough = ET.tostring(root, 'utf-8')
print(rough.decode('utf-8'))
# 或使用 minidom 格式化
import xml.dom.minidom as minidom
print(minidom.parseString(rough).toprettyxml(indent="  "))
```

---

## 三、`xml.dom` 与 `xml.dom.minidom`（DOM 解析）详解

### 1. 概念简介

1. **DOM（Document Object Model）**

- W3C 标准定义的节点型树结构，XML 文档在内存中被解析为一棵树，每个节点（元素、文本、注释、属性等）都对应一个对象。
- 节点之间具有父子等关系，可通过 API 随意访问、修改、添加或删除任意位置的节点。

2. **Python 中的 DOM 实现**

- 标准库 `xml.dom` 定义了基础接口与类；`xml.dom.minidom` 是纯 Python 的简单实现，虽然效率不高，但 API 贴合 W3C DOM 规范，适合理解 DOM 概念或对小规模 XML 文档进行操作。

### 2. 基本用法示例

1. **解析文件/字符串为 DOM 树**

```python
from xml.dom import minidom

# 从文件解析
doc: minidom.Document = minidom.parse('example.xml')

# 从字符串解析
xml_string = '<root><user id="1">Alice</user><user id="2">Bob</user></root>'
doc2 = minidom.parseString(xml_string)
```

1. **遍历节点**

- `documentElement`：表示文档的根节点（相当于 `getElementsByTagName()` 的起点）。
- `getElementsByTagName(tag)`：获取所有匹配标签的节点列表。
- 节点类型常见枚举：`Node.ELEMENT_NODE`、`Node.TEXT_NODE`、`Node.COMMENT_NODE`、`Node.DOCUMENT_NODE` 等。
- 节点属性：

- `node.tagName`：元素的标签名。
- `node.attributes`：一个名为 `NamedNodeMap` 的映射，可通过 `getNamedItem('attr')` 或 `node.getAttribute('attr')` 获取属性值。
- `node.childNodes`：一个 `NodeList`，包含子节点。
- `node.firstChild`、`node.lastChild`、`node.nextSibling`、`node.previousSibling` 等。

```python
from xml.dom import minidom

doc = minidom.parse('example.xml')
root = doc.documentElement        # <root> 节点
users = root.getElementsByTagName('user')

for u in users:
    uid = u.getAttribute('id')
    name = ''
    # 假设 <user> 内部只包含文本节点
    for node in u.childNodes:
        if node.nodeType == node.TEXT_NODE:
            name = node.nodeValue.strip()
    print(uid, name)
```

1. **创建与修改节点**

```python
from xml.dom import minidom

# 创建一个空文档
doc = minidom.Document()

# 创建根节点
root = doc.createElement('library')
doc.appendChild(root)

# 创建 <book id="b1">
book = doc.createElement('book')
book.setAttribute('id', 'b1')
root.appendChild(book)

# 添加 <title>XML in a Nutshell</title>
title = doc.createElement('title')
txt = doc.createTextNode('XML in a Nutshell')
title.appendChild(txt)
book.appendChild(title)

# 添加 <author>xxx</author>
author = doc.createElement('author')
author.appendChild(doc.createTextNode('Elliotte Rusty Harold'))
book.appendChild(author)

# 序列化并输出
xml_str = doc.toprettyxml(indent='  ', encoding='utf-8')
print(xml_str.decode('utf-8'))
```

1. **删除节点**

```python
# 假设 doc 已有若干节点
root = doc.documentElement
books = root.getElementsByTagName('book')
for bk in books:
    if bk.getAttribute('id') == 'b2':
        root.removeChild(bk)
        bk.unlink()   # 解除引用，帮助垃圾回收
        break
```

**要点提示**

1. `**minidom**` **API 贴合 W3C DOM，但在纯 Python 实现下，解析与操作大量节点时会非常慢，内存占用也很高，慎用。**
2. **节点的** `**toxml()**` **或** `**toprettyxml()**` **可将部分子树或整个文档序列化为字符串，但输出编码与缩进可控性有限。**
3. **如果只需要轻量级操作，优先考虑 ElementTree；使用 minidom 仅在需要完整 DOM 功能（如节点类型判断、多文档导入导出、DocumentType 操作等）时才用。**

---

## 四、`xml.sax`（SAX 解析）详解

### 1. 基本概念

1. **SAX（Simple API for XML）**

- 基于事件驱动的解析模型：解析器在扫描到起始标签、文本、结束标签、注释等事件时，会回调用户定义的处理函数（Handler 方法）。
- 优点：不需要将整个文档加载到内存中，适合流式读取或超大 XML 文件。
- 缺点：编程方式更接近“状态机”，需要用户自己维护上下文与父子关系，不如 DOM/ElementTree 直观。

2. **Python 中的** `**xml.sax**`

- 提供了一个 SAX 解析器工厂 `xml.sax.make_parser()`，默认使用 Expat 解析器。
- 需要定义一个或多个继承自 `xml.sax.ContentHandler`（或 `xml.sax.handler.ContentHandler`）的类，重写其中的方法来处理各类事件：

- `startDocument()`、`endDocument()`：文档开始与结束时触发。
- `startElement(name, attrs)`：遇到起始标签时触发；`attrs` 是一个类似字典的对象，可用 `attrs.getValue('attrName')`。
- `endElement(name)`：遇到结束标签时触发。
- `characters(content)`：遇到文本节点时触发；连续的文本可能会多次调用此方法，需拼接。
- `ignorableWhitespace(whitespace)`、`processingInstruction(target, data)`、`startPrefixMapping(prefix, uri)`、`endPrefixMapping(prefix)` 等可选事件。

- 通过 `parser.setContentHandler(your_handler)` 来注册处理器，然后调用 `parser.parse(source)` 开始解析（`source` 可以是文件路径、文件对象、URL 等）。

### 2. 示例：统计元素出现次数

```python
import xml.sax

class CountHandler(xml.sax.ContentHandler):
    def __init__(self):
        super().__init__()
        self.counts = {}
    def startElement(self, name, attrs):
        # 每次遇到一个起始标签，就记录
        self.counts[name] = self.counts.get(name, 0) + 1
    def endDocument(self):
        print("元素出现次数：")
        for tag, cnt in self.counts.items():
            print(f"{tag}: {cnt}")

if __name__ == '__main__':
    parser = xml.sax.make_parser()
    handler = CountHandler()
    parser.setContentHandler(handler)
    parser.parse('large.xml')  # 解析文件
```

### 3. 解析文本节点（连续的 characters 调用）

```python
import xml.sax

class TextCollector(xml.sax.ContentHandler):
    def __init__(self):
        super().__init__()
        self.current_data = None
        self.buffer = ""  # 缓存连续的文本片段
    def startElement(self, name, attrs):
        self.current_data = name
        self.buffer = ""
    def characters(self, content):
        # content 可能被分段传入，需拼接
        if self.current_data:
            self.buffer += content
    def endElement(self, name):
        if name == self.current_data:
            text = self.buffer.strip()
            if text:
                print(f"{name} 内部文本：{text}")
        self.current_data = None

if __name__ == '__main__':
    parser = xml.sax.make_parser()
    handler = TextCollector()
    parser.setContentHandler(handler)
    parser.parse('example.xml')
```

### 4. 处理属性与命名空间

1. **属性**

- `attrs` 参数实现了 `AttributesImpl`，可通过 `attrs.getNames()` 或 `attrs.items()` 获取全部 `(name, value)`。
- 对于命名空间属性，SAX 默认不会将其分成 `{uri}name`，需要在创建解析器时设置命名空间支持：

```python
import xml.sax

class NSHandler(xml.sax.ContentHandler):
    def startElementNS(self, name, qname, attrs):
        # name 是一个 (uri, localname) 元组
        uri, localname = name
        print("元素：", localname, "命名空间：", uri)
        # attrs 也是字典格式，但键为 (uri, localname)
        for attr_name, attr_val in attrs.items():
            print("  属性：", attr_name, "=", attr_val)

if __name__ == '__main__':
    parser = xml.sax.make_parser()
    # 启用命名空间处理
    parser.setFeature(xml.sax.handler.feature_namespaces, True)
    handler = NSHandler()
    parser.setContentHandler(handler)
    parser.parse('ns_example.xml')
```

1. **命名空间映射**

- 如果想在 `startElement` 中仍然按 `{uri}tag` 获取标签名，可不开启 `feature_namespaces`，此时标签类型保留 `{uri}localname` 形式，但不分离 prefix 与 URI。

### 5. 错误处理与调试

1. **自定义错误处理器（ErrorHandler）**

- 继承 `xml.sax.handler.ErrorHandler`，实现 `error(exception)`、`fatalError(exception)`、`warning(exception)` 等方法。
- 注册给解析器：`parser.setErrorHandler(your_error_handler)`。

```python
import xml.sax
from xml.sax.handler import ErrorHandler

class MyErrorHandler(ErrorHandler):
    def warning(self, exception):
        print("Warning：", exception)
    def error(self, exception):
        print("Error：", exception)
    def fatalError(self, exception):
        print("FatalError：", exception)
        raise exception  # 停止解析

if __name__ == '__main__':
    parser = xml.sax.make_parser()
    parser.setErrorHandler(MyErrorHandler())
    parser.parse('malformed.xml')
```

1. **常见异常**

- `xml.sax.SAXParseException`：语法错误，包含行号、列号和错误信息。
- 通过 `exception.getLineNumber()`、`exception.getColumnNumber()`、`exception.getMessage()` 等获取更详细信息。

---

## 五、`xml.parsers.expat`（Expat 解析）详解

### 1. 模块简介

- `xml.parsers.expat` 提供了对 C 语言编写的 Expat 库的 Python 绑定，是 Python 默认 `xml.sax` 和 `xml.etree.ElementTree` 在底层调用的解析引擎。
- Expat 本身就是一个基于回调的事件驱动解析器，其接口类似于 SAX，但比 Python 代码实现更高效。

### 2. 基本 API

1. **创建解析器**

```python
import xml.parsers.expat

# 创建一个解析器实例
parser = xml.parsers.expat.ParserCreate(namespace_separator=' ')
```

- `namespace_separator`：指定在标签名或属性名中，用于分隔 URI 与本地名的字符，默认为 None，不分离命名空间。若指定 `' '`，则在 `StartElementHandler` 的 name 参数中会返回 `'uri localname'`。

1. **注册回调函数**

```python
def start_element(name, attrs):
    print("Start element:", name, attrs)

def end_element(name):
    print("End element:", name)

def char_data(data):
    print("Text data:", repr(data))

parser.StartElementHandler = start_element
parser.EndElementHandler = end_element
parser.CharacterDataHandler = char_data
```

- **常见回调**：

- `StartElementHandler(name, attrs)`：遇到起始标签；`name` 是标签名（可能包含命名空间前缀），`attrs` 是一个字典。
- `EndElementHandler(name)`：遇到结束标签时触发。
- `CharacterDataHandler(data)`：遇到文本时触发（会分段）。
- `ProcessingInstructionHandler(target, data)`：遇到处理指令（如 `<?xml-stylesheet ...?>`）。
- `StartNamespaceDeclHandler(prefix, uri)` / `EndNamespaceDeclHandler(prefix)`：命名空间声明开始/结束。
- `DefaultHandler(data)`：如果没有其他匹配时，会调用该回调。

1. **解析数据**

```python
# 从文件读取并解析
with open('example.xml', 'rb') as f:
    data = f.read()
parser.Parse(data, True)   # 第二个参数指定是否是文档末尾（True 表示结束）
```

- 也可使用分段解析：`parser.Parse(buffer_chunk, False)` 多次调用，最后一次传入 `True` 表示结束。

1. **捕获错误**

- 如果解析出错，会抛出 `xml.parsers.expat.ExpatError`，可捕获并获取错误信息：`e.code`, `e.lineno`, `e.offset`, `e.msg`。

```python
try:
    parser.Parse(data, True)
except xml.parsers.expat.ExpatError as e:
    print(f"ExpatError: Line {e.lineno} Col {e.offset}: {e.code} {e.msg}")
```

**要点提示**

1. `**xml.parsers.expat**` **提供最底层的高性能回调接口，但编程更为复杂；若只需业务逻辑，可考虑上层的** `**xml.sax**` **或** `**ElementTree**`**。**
2. **在需要超大文件且对性能极为敏感的场景，可以直接面向 Expat 回调 API。**

---

## 六、`xml.dom.pulldom`（PullDOM）简介

### 1. PullDOM 概念

- PullDOM 是在 SAX 解析基础上，结合 DOM 的创建机制，按需构建子 DOM 子树的一种“拉取式”解析方式。
- 与纯 SAX 不同，PullDOM 在遇到某些指定元素时，会将该节点以及其子孙节点解析为一个完整的 DOM 子树，然后返回给用户，让用户对该子树进行操作；处理完成后可释放该子树，节省内存。

### 2. 常用 API

```python
from xml.dom import pulldom

for event, node in pulldom.parse('large.xml'):
    if event == pulldom.START_ELEMENT and node.nodeName == 'item':
        # 构造以 <item> 为根的 DOM 子树
        item_dom = node.expandNode()   # 返回一个 DOM Element 节点
        # 此时 item_dom 及其全部子树已构造，可照常使用 DOM API
        title_nodes = item_dom.getElementsByTagName('title')
        if title_nodes:
            print(title_nodes[0].firstChild.nodeValue)
        # 处理完后，该子树可被垃圾回收，节省内存
```

- `parse(source)` 返回一个可迭代的 `(event, node)` 对，其中 `event` 是常量（`START_DOCUMENT, END_DOCUMENT, START_ELEMENT, END_ELEMENT, PROCESSING_INSTRUCTION, ...`），`node` 是一个临时 DOM 节点或空。

**要点提示**

1. **PullDOM 兼顾了 SAX 对大文件的低内存解析优势与 DOM 随机访问子树的方便，但实现复杂性略高。**
2. **如果只需要传统的树形操作，优先考虑 ElementTree；若仅仅读取并搜索少量子节点，可考虑 PullDOM。**

---

## 七、字符转义与辅助工具（`xml.sax.saxutils`）

### 1. `escape()` 与 `unescape()`

- 在生成 XML 的过程中，需要对特殊字符（`& < > ' "`）进行转义，以免与 XML 语法冲突。`xml.sax.saxutils` 提供了：

```python
from xml.sax.saxutils import escape, unescape

s = '5 < 10 & 20 > 15'
escaped = escape(s)  
# 默认会把 & → &amp;, < → &lt;, > → &gt;, " 与 ' 不会转义
print(escaped)  # '5 &lt; 10 &amp; 20 &gt; 15'

# 如果希望对双引号与单引号也做转义，可传入实体映射字典
escaped2 = escape(s, entities={'"': '&quot;', "'": '&apos;'})
print(escaped2)

# 反向：把 &amp; &lt; 等实体转回原字符
raw = unescape('Fish &amp; Chips &lt;3')
print(raw)  # 'Fish & Chips <3'
```

### 2. `XMLGenerator`

- `XMLGenerator` 是一个符合 SAX 的 `ContentHandler`，可用于将 SAX 事件流转换为字符串或写到文件中。常用于在代码中“模拟” SAX 事件生成 XML。

```python
from xml.sax.saxutils import XMLGenerator

# 将事件流写到文件
with open('out.xml', 'w', encoding='utf-8') as f:
    handler = XMLGenerator(f, encoding='utf-8')
    handler.startDocument()
    handler.startElement('greeting', {'lang': 'en'})
    handler.characters('Hello, World!')
    handler.endElement('greeting')
    handler.endDocument()

# 生成输出：
# <?xml version="1.0" encoding="utf-8"?>
# <greeting lang="en">Hello, World!</greeting>
```

### 3. `quoteattr()`

- 将属性值进行转义并加引号：

```python
from xml.sax.saxutils import quoteattr

val = 'Tom & Jerry "Best"'
print(quoteattr(val))  
# 输出 '"Tom &amp; Jerry &quot;Best&quot;"'
```

**要点提示**

1. **手动生成 XML 时，不要自己拼接** `**<tag>{text}</tag>**`**，而应先对** `**text**` **调用** `**escape()**`**，对属性值用** `**quoteattr()**`**。**
2. **对于定制复杂文档格式、需要严格控制空白与换行的场景，可结合** `**XMLGenerator**` **模拟 SAX 事件，更精确地输出。**

---

## 八、XML 校验（DTD/XSD）

### 1. Python 标准库不支持原生校验

- **注意**：Python 内置的 `xml` 包本身不提供 DTD（Document Type Definition）或 XSD（XML Schema Definition）的校验功能。即便在 `minidom.parse()` 时，若文档声明了 DTD，也只会解析，不会验证。
- 如果文档具有 DTD 或 XSD 引用，解析时不会自动报“验证错误”，只能手动根据 `DocumentType` 节点或第三方接口进行验证。

### 2. 使用第三方库进行校验（推荐）

1. **lxml**

- `lxml.etree` 可以直接支持 DTD 与 XSD 验证。示例（需要安装 `lxml`）：

```python
from lxml import etree

# DTD 验证
dtd = etree.DTD(open('example.dtd'))
xml_doc = etree.parse('example.xml')
if dtd.validate(xml_doc):
    print("DTD 验证通过")
else:
    print("DTD 验证失败：", dtd.error_log.filter_from_errors())

# XSD 验证
xmlschema_doc = etree.parse('example.xsd')
xmlschema = etree.XMLSchema(xmlschema_doc)
xml_doc = etree.parse('example.xml')
try:
    xmlschema.assertValid(xml_doc)
    print("XSD 验证通过")
except etree.DocumentInvalid as e:
    print("XSD 验证失败：", e)
```

1. **xmlschema**（第三方纯 Python 库）

- 支持完整的 XSD 1.0 规范验证，也能转换为 Python 数据对象。安装：`pip install xmlschema`。示例：

```python
import xmlschema

schema = xmlschema.XMLSchema('example.xsd')
if schema.is_valid('example.xml'):
    print("XML 符合 XSD 规范")
else:
    print("不符合：", schema.validate('example.xml'))
```

**要点提示**

1. **如果项目对 XML 文档的格式与内容有严格约束需求，请务必引入第三方库（如** `**lxml**` **或** `**xmlschema**`**），因为标准库本身仅能解析、不能验证。**
2. **在读写 XML 过程中，可先使用验证库检查文档合法性，再进行进一步处理。**

---

## 九、性能与最佳实践

1. **选择合适的 API**

- **小型、简单文档或配置文件**：使用 `xml.etree.ElementTree`。
- **需要严格 DOM 操作或 W3C 兼容**：少量时可选用 `xml.dom.minidom`；但若文档较大，建议使用 `lxml`（第三方）。
- **超大或流式处理**：使用 `xml.sax`（或底层的 `xml.parsers.expat`），结合 `iterparse`。

2. **避免重复转换与多次解析**

- 如果需要多次访问同一个子树，先保留引用，避免重复调用 `find()`、`findall()`。
- 若需要查找多次，可将元素列表缓存到 Python 数据结构（`dict` 或 `list`）中，以加速后续查找。

3. **及时释放资源（大文档）**

- 在 `iterparse` 场景下，对已经处理完的节点调用 `elem.clear()` 并删除对父节点的引用 `del elem`，以便 Python 垃圾回收。
- 对使用 DOM (`minidom`) 构建的节点，处理完后可用 `node.unlink()` 断开父子引用，释放内存。

4. **使用** `**encoding**` **与** `**errors**` **参数**

- 当 XML 声明了字符编码（如 `<?xml version="1.0" encoding="ISO-8859-1"?>`），Python 解析时一般会自动检测。但如果文件实际编码与声明不符，可先以二进制方式读取，手动 `decode()` 后再用 `fromstring()`。
- 在读取文件时，可用 `open('f.xml', encoding='utf-8', errors='replace')`，避免出现编码错误导致解析失败。

5. **遵循“先验证、后解析”原则**

- 如果输入来自外部、且需要严格符合特定结构，请先使用第三方验证库在解析前检查，保障后续逻辑不会因格式不符而出错。

6. **XML 注入与安全考虑**

- 避免信任来自用户的 XML 文档，防止所谓“XML 外部实体注入攻击”（XXE）。Python 中的 `xml.etree.ElementTree` 以及 `xml.dom.minidom` 在默认情况下不解析外部实体，但 `xml.sax` 可能会。
- 可通过配置禁用外部实体解析：

```python
import xml.sax
parser = xml.sax.make_parser()
# 禁用 DTD/外部实体
parser.setFeature(xml.sax.handler.feature_external_ges, False)
parser.setFeature(xml.sax.handler.feature_external_pes, False)
```

- 或者使用 `defusedxml`（第三方库）替换标准库中容易被 XXE 攻击的解析方法：

```python
from defusedxml.ElementTree import parse, fromstring
from defusedxml.minidom import parseString
```

---

## 十、综合示例：从多种方式解析并转换 XML

下面举例演示如何结合 ElementTree、minidom 和 SAX，对同一份 XML 文档做不同需求的处理。

```xml
<!-- orders.xml -->
<orders xmlns="http://example.com/orders" xmlns:prod="http://example.com/products">
  <order id="1001" date="2025-06-01">
    <customer>
      <name>Alice</name>
      <email>alice@example.com</email>
    </customer>
    <items>
      <prod:item prod:sku="SKU123" quantity="2"/>
      <prod:item prod:sku="SKU456" quantity="1"/>
    </items>
  </order>
  <order id="1002" date="2025-06-02">
    <customer>
      <name>Bob</name>
      <email>bob@example.com</email>
    </customer>
    <items>
      <prod:item prod:sku="SKU789" quantity="5"/>
    </items>
  </order>
</orders>
```

### 1. 使用 ElementTree 解析并输出订单摘要

```python
import xml.etree.ElementTree as ET

ns = {
    'o': 'http://example.com/orders',
    'p': 'http://example.com/products'
}

tree = ET.parse('orders.xml')
root = tree.getroot()

for order in root.findall('o:order', namespaces=ns):
    oid = order.get('id')
    date = order.get('date')
    cust = order.find('o:customer/o:name', namespaces=ns).text
    print(f"Order {oid} on {date}, Customer: {cust}")
    total_items = 0
    for item in order.findall('o:items/p:item', namespaces=ns):
        qty = int(item.get('quantity'))
        sku = item.get('{http://example.com/products}sku')  # 另一种写法
        print(f"  Item SKU={sku}, Quantity={qty}")
        total_items += qty
    print(f"  Total items: {total_items}")
```

### 2. 使用 minidom 格式化输出（Pretty Print）

```python
from xml.dom import minidom

# 读取并格式化
dom = minidom.parse('orders.xml')
print(dom.toprettyxml(indent='  '))
```

### 3. 使用 SAX 事件抽取所有 SKU 值

```python
import xml.sax

class SKUHandler(xml.sax.ContentHandler):
    def __init__(self):
        super().__init__()
        self.skus = []

    def startElementNS(self, name, qname, attrs):
        uri, localname = name
        # 判断是否是 prod:item
        if uri == 'http://example.com/products' and localname == 'item':
            sku = attrs.get((uri, 'sku'))  # 元组 (uri, localname)
            self.skus.append(sku)

if __name__ == '__main__':
    parser = xml.sax.make_parser()
    parser.setFeature(xml.sax.handler.feature_namespaces, True)
    handler = SKUHandler()
    parser.setContentHandler(handler)
    parser.parse('orders.xml')
    print("所有 SKU：", handler.skus)
```

**要点提示**

1. **ElementTree 是对大多数 XML 业务需求的首选，结合** `**namespaces**` **参数可轻松处理带命名空间的文档。**
2. **minidom 适合做“快速格式化”或需要操作 DOM 特殊节点（如** `**ProcessingInstruction**`**、**`**CDATASection**`**）时使用，但不适合大数据量。**
3. **SAX 事件驱动方式可非常高效地从文档中抽取关键信息（如 SKU 列表），且内存占用极低。**

---

## 十一、总结

- Python 标准库的 `xml` 包提供了多种方式来解析、创建、操作与序列化 XML：

1. `**xml.etree.ElementTree**`：轻量级树形 API，适合绝大多数中小型 XML 文档的读写与修改；支持简单的 XPath 片段查询与增量（iterparse）处理；命名空间需手动管理。
2. `**xml.dom.minidom**` **/** `**xml.dom**`：W3C DOM 兼容接口，面向完整的节点对象模型，可进行任意节点类型的操作，但性能与内存开销较高。
3. `**xml.sax**`：事件驱动解析，适合处理超大文档或流式读取；需要自行维护解析状态，编程稍繁琐。
4. `**xml.parsers.expat**`：底层高性能解析器，提供比 SAX 更原始的回调接口，一般在对性能有极致要求的场景下使用。
5. `**xml.dom.pulldom**`：结合 SAX 与 DOM 优势的拉取式解析，可按需将子树构造为 DOM，但使用场景有限。
6. `**xml.sax.saxutils**`：辅助工具，提供常用的字符转义、XML 生成器、属性转义等函数。

- **命名空间（Namespaces）**

- ElementTree 通过 `{uri}tag` 语法管理命名空间，且可注册前缀以简化输出；SAX 可以通过 `feature_namespaces` 获取 `(uri, localname)`。
- 在复杂文档中，务必先定义好命名空间映射，确保查找与创建节点时不会出现错配。

- **错误处理与安全**

- 标准库本身不提供 DTD/XSD 验证；若需要验证请使用第三方库（如 `lxml`、`xmlschema`）。
- 避免 XXE 攻击：在处理来自不可信来源的 XML 时，可禁用外部实体解析，或直接使用 `defusedxml` 等安全替代方案。

- **性能优化**

1. 对于大文件，优先考虑 `iterparse` 或 `xml.sax`，并在处理后及时清理内存。
2. 如果常规树形操作过于缓慢，可考虑引入 `lxml.etree`（第三方），其 API 与 ElementTree 类似，但性能更优、功能更强。
3. 手写 XML 时，务必对文本与属性做转义，或使用 `XMLGenerator`。

- **最佳实践要点**

1. **日常使用**：以 `xml.etree.ElementTree` 为主；只在极少数需要 DOM 复杂操作或严格验证时，才考虑其他方式，避免过度设计。
2. **命名空间**：在读写前先明确命名空间 URI 与前缀映射；创建时用 `{uri}tag`，解析时用 `namespaces={}`。
3. **安全与验证**：若文档来自用户或外部系统，务必做好验证与实体过滤，避免安全漏洞。
4. **错误定位**：在解析时捕获并打印 `ParseError`（或 `SAXParseException`），提供准确的行号和错误信息以便快速定位。
5. **测试与调试**：对于复杂 XML，先用小样本测试解析逻辑；可结合 `minidom` 的 `toprettyxml()` 输出格式化结果，直观查看结构。

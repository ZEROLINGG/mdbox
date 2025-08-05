**BeautifulSoup** 是 Python 中广泛应用的 HTML/XML 解析库，主要用于从网页中提取结构化数据。其接口友好，语法简洁，特别适合爬虫新手与中小型项目使用。

---

## 一、基本概念

### 1. 安装方式

```python
pip install beautifulsoup4
```

为提升解析效率与兼容性，建议安装以下可选解析器：

```python
pip install lxml html5lib
```

- `lxml`：性能较高，解析速度快，推荐优先使用。
- `html5lib`：兼容性更强，能够处理非标准 HTML，但解析速度较慢。

### 2. 初始化使用

```python
from bs4 import BeautifulSoup

html = """
<html>
  <body>
    <h1 class="title">页面标题</h1>
    <p id="desc">这里是描述文字。</p>
    <a href="http://example.com/page1">链接1</a>
    <a href="http://example.com/page2" class="link">链接2</a>
  </body>
</html>
"""

soup = BeautifulSoup(html, "lxml")  # 可替换为 "html.parser" 或 "html5lib"
```

---

## 二、核心用法

### 1. 标签查找方法

#### 基本查找

```python
soup.find("a")                # 查找第一个 <a> 标签
soup.find_all("a")           # 查找所有 <a> 标签
soup.find("h1", class_="title")  # 根据 class 查找
```

#### CSS 选择器查找（推荐使用 `.select()`）

```python
soup.select("#desc")         # 查找 id 为 desc 的元素
soup.select("a.link")        # 查找 class 为 link 的 <a> 标签
soup.select("body a")        # 查找 body 下的所有 <a> 标签
```

### 2. 标签内容与属性提取

```python
tag = soup.find("h1")

text = tag.get_text(strip=True)   # 获取纯文本
name = tag.name                   # 获取标签名，例如 'h1'
cls = tag["class"]                # 获取属性值 ['title']
cls_alt = tag.get("class")        # 同上，更安全
```

### 3. DOM 遍历与结构操作

#### 子节点与后代节点

```python
parent = soup.body
children = list(parent.children)       # 直接子节点（含空白文本）
descendants = list(parent.descendants) # 所有嵌套后代节点
```

#### 父节点与兄弟节点

```python
tag = soup.find("h1")
parent = tag.parent                 # 父节点
next_sib = tag.next_sibling         # 下一个兄弟节点（常是换行符）
prev_sib = tag.previous_sibling     # 上一个兄弟节点
```

### 4. 条件筛选与函数过滤

#### 按属性筛选

```python
soup.find_all("a", class_="link")
soup.find_all("a", href=True)  # 带有 href 属性的 <a> 标签
```

#### 自定义筛选函数

```python
def has_href(tag):
    return tag.has_attr("href")

soup.find_all(has_href)
```

#### 综合示例：提取所有带 class 且 href 以 http 开头的链接

```python
def valid_link(tag):
    return tag.name == "a" and tag.has_attr("href") and tag["href"].startswith("http") and tag.has_attr("class")

soup.find_all(valid_link)
```

### 5. 标签的修改、删除与插入

```python
tag = soup.find("p")

tag["id"] = "new_id"     # 修改属性
tag.string = "新文本内容"  # 修改文本内容

tag.decompose()          # 完全删除该标签（包含其内容）

# 插入新节点示例
from bs4 import Tag

new_tag = soup.new_tag("div", id="inserted")
new_tag.string = "这是新插入的内容"
soup.body.append(new_tag)  # 添加为 body 的子节点
```

---

## 三、实际示例：提取网页标题与链接

```python
import requests
from bs4 import BeautifulSoup

url = "https://example.com"
headers = {
    "User-Agent": "Mozilla/5.0"
}

res = requests.get(url, headers=headers)
soup = BeautifulSoup(res.text, "lxml")

# 提取页面标题
title = soup.title.get_text(strip=True) if soup.title else "无标题"

# 提取所有链接及其文本
for a in soup.find_all("a", href=True):
    text = a.get_text(strip=True)
    href = a["href"]
    print(f"{text} => {href}")
```

---

## 四、补充说明

### 1. 解析器选择建议

|   |   |   |   |
|---|---|---|---|
|解析器|速度|容错能力|安装需求|
|html.parser|中|中|无|
|lxml|快|中|需要安装|
|html5lib|慢|强|需要安装|

推荐优先使用 `lxml`，若页面结构不规范可考虑 `html5lib`。

### 2. 常见问题排查

- 使用 `.string` 时，若标签包含子标签将返回 `None`，应改用 `.get_text()`。
- 使用 `.next_sibling` 和 `.previous_sibling` 可能返回换行符，应结合 `strip()` 或循环过滤。

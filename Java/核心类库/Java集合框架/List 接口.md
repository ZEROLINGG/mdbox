## 一、`List` 接口概述

`java.util.List<E>` 接口定义了一个**元素有序**、**可重复**的集合，其中每个元素都有其对应的索引位置（从 0 开始）。

### 主要特性：

- 元素按插入顺序排序；
- 允许添加重复元素；
- 允许插入 `null`（视具体实现而定）；
- 提供基于索引的访问方法（如 `get(int index)`）；
- 可通过 `ListIterator` 进行双向迭代。

---

## 二、常用实现类

|                        |      |         |      |             |                     |
| ---------------------- | ---- | ------- | ---- | ----------- | ------------------- |
| 类名                     | 底层结构 | 线程安全    | 查询效率 | 插入/删除效率     | 备注                  |
| `ArrayList`            | 动态数组 | 否       | 高    | 较低（尤其在中间插入） | 最常用，适合读多写少场景        |
| `LinkedList`           | 双向链表 | 否       | 较低   | 高（在头尾插入/删除） | 支持队列、栈操作            |
| `Vector`               | 动态数组 | 是       | 高    | 较低          | 已过时，建议用 `ArrayList` |
| `CopyOnWriteArrayList` | 动态数组 | 是（读写分离） | 读高写低 | 写操作会复制整个数组  | 适用于读多写少的并发环境        |

---

## 三、常用方法（以 `ArrayList` 为例）

### 1. 添加元素

```Java
List<String> list = new ArrayList<>();
list.add("Java");
list.add("Python");
list.add(1, "C++");  // 在索引 1 处插入
```

### 2. 获取元素

```Java
String value = list.get(0);  // 获取第一个元素
```

### 3. 修改元素

```Java
list.set(1, "Go");  // 修改索引 1 的元素为 "Go"
```

### 4. 删除元素

```Java
list.remove("Python");  // 删除指定元素
list.remove(0);         // 删除指定索引的元素
```

### 5. 查找元素

```Java
int index = list.indexOf("Go");     // 第一次出现的索引
int lastIndex = list.lastIndexOf("Go"); // 最后一次出现的索引
boolean contains = list.contains("Java");
```

### 6. 子列表

```Java
List<String> subList = list.subList(1, 3);  // 左闭右开：[1, 3)
```

---

## 四、遍历方式

### 1. for-each 循环

```Java
for (String item : list) {
    System.out.println(item);
}
```

### 2. 使用 `Iterator`

```Java
Iterator<String> it = list.iterator();
while (it.hasNext()) {
    System.out.println(it.next());
}
```

### 3. 使用 `ListIterator`（支持双向遍历）

```Java
ListIterator<String> lit = list.listIterator();
while (lit.hasNext()) {
    System.out.println(lit.next());
}
```

---

## 五、线程安全方案

- `List` 本身不是线程安全的；
- 如果需要线程安全的列表：

- 使用 `Collections.synchronizedList(...)`

```Java
List<String> syncList = Collections.synchronizedList(new ArrayList<>());
```

- 使用并发包中的 `CopyOnWriteArrayList`

---

## 六、性能比较：`ArrayList` vs `LinkedList`

|   |   |   |
|---|---|---|
|操作类型|ArrayList|LinkedList|
|随机访问（get）|快（O(1)）|慢（O(n)）|
|插入/删除头部|慢（O(n)）|快（O(1)）|
|插入/删除中部|慢（O(n)）|慢（O(n)）|
|内存占用|较少|较多（节点+指针）|

---

## 七、典型应用场景

- `ArrayList`：适用于查找频繁、修改少的场景；
- `LinkedList`：适用于频繁插入/删除的队列或栈结构；
- `CopyOnWriteArrayList`：适用于并发读多、写少的场景（如监听器列表）；

---

## 八、示例代码

```Java
public class ListExample {
    public static void main(String[] args) {
        List<String> languages = new ArrayList<>();
        languages.add("Java");
        languages.add("Python");
        languages.add("C++");

        for (String lang : languages) {
            System.out.println(lang);
        }

        if (languages.contains("Java")) {
            System.out.println("Java is in the list.");
        }

        languages.remove("C++");
        System.out.println("After removal: " + languages);
    }
}
```

---

## 九、总结

`List` 接口是 Java 集合中最常用的一种类型，提供了丰富的操作方法来处理有序数据集合。合理选择其实现类（`ArrayList`、`LinkedList`、`Vector`、`CopyOnWriteArrayList`）对于提升程序性能和可维护性具有重要意义。

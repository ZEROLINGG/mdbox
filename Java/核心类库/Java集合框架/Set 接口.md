`Set` 接口是 Java 集合框架中用于存储**不重复元素**的数据结构。它继承自 `Collection` 接口，与 `List` 不同的是，`Set`**不保证元素的顺序**，并且**不允许包含重复元素**（即元素的 `equals()` 和 `hashCode()` 相同）。

---

## 一、`Set` 接口的主要特征

|   |   |
|---|---|
|特性|描述|
|唯一性|所有元素必须唯一，不能有重复项。|
|无序性|大多数实现类（如 `HashSet`<br><br>）不保证元素的插入顺序。|
|无索引|`Set`<br><br>不支持使用索引访问元素，如 `get(index)`<br><br>。|

---

## 二、常见的 `Set` 实现类及其特点

|   |   |
|---|---|
|实现类|特点|
|`HashSet`|基于哈希表，元素无序，访问速度快，不允许重复元素。|
|`LinkedHashSet`|保持插入顺序，基于哈希表+链表。|
|`TreeSet`|元素自动排序（默认按自然顺序，或可使用 `Comparator`<br><br>），基于红黑树。|
|`EnumSet`|专为枚举类型设计，效率高，不能用于非枚举。|
|`CopyOnWriteArraySet`|线程安全的 `Set`<br><br>，用于并发环境，写时复制策略。|

---

## 三、常用方法（继承自 `Collection` 接口）

|                      |                    |
| -------------------- | ------------------ |
| 方法                   | 描述                 |
| `add(E e)`           | 添加元素，如果元素已存在则添加失败。 |
| `remove(Object o)`   | 删除指定元素。            |
| `contains(Object o)` | 判断是否包含元素。          |
| `size()`             | 返回元素数量。            |
| `isEmpty()`          | 判断集合是否为空。          |
| `clear()`            | 清空集合。              |
| `iterator()`         | 返回一个迭代器，用于遍历元素。    |

---

## 四、典型示例

### 示例：使用 `HashSet`

```Java
import java.util.HashSet;
import java.util.Set;

public class SetExample {
    public static void main(String[] args) {
        Set<String> set = new HashSet<>();

        // 添加元素
        set.add("Apple");
        set.add("Banana");
        set.add("Cherry");
        set.add("Apple"); // 重复元素不会被添加

        // 打印所有元素（无特定顺序）
        System.out.println("Set内容: " + set);

        // 判断是否包含某元素
        System.out.println("是否包含 Banana: " + set.contains("Banana"));

        // 删除元素
        set.remove("Cherry");

        // 遍历Set（增强for循环）
        System.out.println("遍历Set:");
        for (String fruit : set) {
            System.out.println(fruit);
        }

        // 集合大小
        System.out.println("Set大小: " + set.size());
    }
}
```

---

### 示例输出（注意：HashSet 无顺序）

```Java
Set内容: [Banana, Apple, Cherry]
是否包含 Banana: true
遍历Set:
Banana
Apple
Set大小: 2
```

---

## 五、`HashSet` 背后的原理简述

- 内部使用 `HashMap` 来存储元素，元素作为键（`key`），值（`value`）是一个固定的常量。
- 元素的唯一性依赖于 `hashCode()` 和 `equals()` 方法。
- 添加新元素时，先计算其哈希值，查找是否已有等值元素，若无则插入。

---

## 六、选择使用哪种 `Set`

|   |   |
|---|---|
|使用场景|推荐实现|
|无序，快速查找|`HashSet`|
|保持插入顺序|`LinkedHashSet`|
|自动排序|`TreeSet`|
|枚举集合|`EnumSet`|
|多线程环境|`CopyOnWriteArraySet`<br><br>、`Collections.synchronizedSet()`|

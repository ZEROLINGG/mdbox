`Map` 接口是 Java 集合框架中用于**存储键值对（key-value）****的一种结构。与** `**Collection**` **接口不同，**`**Map**` **不是** `**Collection**` **的子接口。它专门用于****通过键来快速访问对应的值**，并且**键不能重复**（基于 `equals()` 和 `hashCode()`）。

---

## 一、`Map` 接口的基本特征

|   |   |
|---|---|
|特性|说明|
|键值对结构|每个元素都由一个键（key）和一个值（value）组成。|
|键唯一|同一个 `Map`<br><br>中不能有重复的键。|
|值可重复|值可以重复，不受限制。|
|无序|大多数实现类（如 `HashMap`<br><br>）不保证顺序。|

---

## 二、常见实现类对比

|   |   |
|---|---|
|实现类|特点|
|`HashMap`|无序，键值允许 `null`<br><br>，非线程安全，性能高。|
|`LinkedHashMap`|保持插入顺序，适合需要顺序访问的场景。|
|`TreeMap`|自动按键排序（自然顺序或自定义排序），基于红黑树。|
|`Hashtable`|线程安全，古老实现，不推荐使用。|
|`ConcurrentHashMap`|高性能并发 Map，线程安全，适合多线程环境。|
|`EnumMap`|专为枚举类型键设计，效率极高。|

---

## 三、常用方法

|                               |                                           |
| ----------------------------- | ----------------------------------------- |
| 方法                            | 描述                                        |
| `put(K key, V value)`         | 添加或替换键值对。                                 |
| `get(Object key)`             | 根据键获取值。                                   |
| `remove(Object key)`          | 删除指定键的映射。                                 |
| `containsKey(Object key)`     | 是否包含指定键。                                  |
| `containsValue(Object value)` | 是否包含指定值。                                  |
| `size()`                      | 获取映射数量。                                   |
| `isEmpty()`                   | 是否为空映射。                                   |
| `clear()`                     | 清空所有键值对。                                  |
| `keySet()`                    | 返回所有键的 `Set`<br><br>视图。                   |
| `values()`                    | 返回所有值的 `Collection`<br><br>视图。            |
| `entrySet()`                  | 返回所有键值对的 `Set<Map.Entry<K,V>>`<br><br>视图。 |

---

## 四、示例：使用 `HashMap`

```Java
import java.util.HashMap;
import java.util.Map;

public class MapExample {
    public static void main(String[] args) {
        // 创建一个 Map 实例
        Map<String, Integer> scores = new HashMap<>();

        // 添加元素
        scores.put("Alice", 85);
        scores.put("Bob", 90);
        scores.put("Charlie", 78);

        // 替换已有键的值
        scores.put("Alice", 88); // Alice 原来的 85 被替换为 88

        // 获取值
        System.out.println("Bob的成绩: " + scores.get("Bob"));

        // 遍历键值对
        System.out.println("所有成绩:");
        for (Map.Entry<String, Integer> entry : scores.entrySet()) {
            System.out.println(entry.getKey() + ": " + entry.getValue());
        }

        // 判断是否包含某键或某值
        System.out.println("是否包含 Alice: " + scores.containsKey("Alice"));
        System.out.println("是否包含成绩 100: " + scores.containsValue(100));

        // 删除键值对
        scores.remove("Charlie");

        // 输出剩余键值对
        System.out.println("删除后的Map: " + scores);

        // 获取键集合
        System.out.println("所有学生: " + scores.keySet());

        // 获取值集合
        System.out.println("所有成绩: " + scores.values());
    }
}
```

---

### 示例输出：

```Java
Bob的成绩: 90
所有成绩:
Alice: 88
Bob: 90
是否包含 Alice: true
是否包含成绩 100: false
删除后的Map: {Alice=88, Bob=90}
所有学生: [Alice, Bob]
所有成绩: [88, 90]
```

---

## 五、底层机制简要分析

### HashMap

- 基于哈希表（数组 + 链表 / 红黑树）。
- 插入时根据 `key.hashCode()` 计算哈希位置。
- JDK 1.8 起，链表长度超过 8 转为红黑树以提升效率。

### TreeMap

- 使用红黑树存储，自动对键进行排序。
- 插入与查找的时间复杂度为 O(log n)。

### LinkedHashMap

- 内部维护一个双向链表记录插入顺序。
- 适用于需要顺序遍历的场景，如缓存（可结合 LRU 策略使用）。

---

## 六、线程安全说明

|   |   |   |
|---|---|---|
|类型|是否线程安全|建议用途|
|`HashMap`|否|单线程或外部同步使用|
|`Hashtable`|是（过时）|不推荐使用|
|`ConcurrentHashMap`|是|并发访问环境下的首选|

---

## 七、适用场景建议

|           |                     |
| --------- | ------------------- |
| 场景        | 推荐实现                |
| 无需顺序，性能优先 | `HashMap`           |
| 保持插入顺序    | `LinkedHashMap`     |
| 需要键排序     | `TreeMap`           |
| 多线程安全     | `ConcurrentHashMap` |
| 键为枚举类型    | `EnumMap`           |

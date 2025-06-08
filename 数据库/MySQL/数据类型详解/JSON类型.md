## 一、概念与存储

- **本质**：MySQL 的 `JSON` 并非简单的文本，而是存储为一种紧凑的二进制格式（“JSON binary”），可以快速解析与随机访问。
- **版本支持**：从 MySQL 5.7.8 引入，5.7 系列提供基础 CRUD 与函数；MySQL 8.0 大幅增强了 JSON 函数、索引与查询能力。
- **优点**：

- 自动验证合法性，插入非法 JSON 会报错（严格模式下）。
- 存储紧凑，节省空间；随机访问子元素无需全行扫描。

- **缺点**：

- 不及关系型字段在 JOIN/聚合等场景下灵活，复杂查询需用专门 JSON 函数或 `JSON_TABLE()`。
- 大量深嵌套 JSON 会导致解析开销、可维护性下降。

---

## 二、定义与基本操作

### 2.1 建表时定义 JSON 列

```MySQL
CREATE TABLE configs (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  data    JSON                     NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

### 2.2 插入与更新

```MySQL
-- 插入 JSON 对象或数组
INSERT INTO configs (data) VALUES
  ('{"theme":"dark","features":{"beta":true,"maxItems":10}}'),
  ('[1,2,3,{"x":5}]');

-- 更新子属性
UPDATE configs
  SET data = JSON_SET(data, '$.features.maxItems', 20)
WHERE id = 1;
```

### 2.3 验证与转换

- **验证合法性**

```MySQL
SELECT JSON_VALID(data) FROM configs;
```

- **从字符串转换**

```MySQL
SELECT CAST('{"a":1}' AS JSON);
```

---

## 三、JSON 查询与修改函数

**路径** (`path`) 语法：`$` 根；`.key` 对象；`[index]` 数组；支持通配 `[*]`、`$.a.b[*].c`

### 3.1 访问与提取

- **操作符**

```MySQL
SELECT data->'$.features.beta'    AS beta_flag,   -- JSON 类型
       data->>'$.theme'            AS theme_text;  -- 文本
```

- **JSON_EXTRACT / JSON_UNQUOTE**

```MySQL
SELECT JSON_EXTRACT(data, '$.features.maxItems') AS maxItems;
SELECT JSON_UNQUOTE(JSON_EXTRACT(data, '$.theme')) AS theme;
```

### 3.2 修改与合并

- **JSON_SET**：设置或新增
- **JSON_REPLACE**：仅当路径存在时替换
- **JSON_REMOVE**：删除路径
- **JSON_MERGE_PRESERVE**：合并多个文档，不同 MySQL 版本函数名有细微差异

```MySQL
UPDATE configs
SET data = JSON_REMOVE(data, '$.features.beta');
```

### 3.3 数组操作

- **JSON_ARRAY_APPEND / JSON_ARRAY_INSERT**：追加或插入
- **JSON_LENGTH**：计算数组或对象键数
- **JSON_ARRAYAGG / JSON_OBJECTAGG**（8.0+）：聚合查询结果

```MySQL
SELECT JSON_ARRAYAGG(user_id) FROM orders WHERE status='shipped';
```

### 3.4 搜索与遍历

- **JSON_SEARCH**：查找元素路径
- **JSON_CONTAINS / JSON_CONTAINS_PATH**：判断包含

```MySQL
SELECT * FROM configs
WHERE JSON_CONTAINS_PATH(data, 'one', '$.features.beta');
```

- **JSON_TABLE**（8.0+）：将 JSON 文档映射为虚拟表，用于 JOIN 与更复杂的关系查询

```MySQL
SELECT * 
FROM configs,
     JSON_TABLE(data, '$.items[*]'
       COLUMNS (item_id INT PATH '$')) AS jt;
```

---

## 四、索引策略

### 4.1 直接索引

MySQL 8.0.17 起支持对 JSON 文档 **全文**索引：

```MySQL
ALTER TABLE configs
  ADD FULLTEXT INDEX idx_data (data);
```

### 4.2 虚拟/生成列索引

最常用方式：创建生成列（`VIRTUAL` 或 `STORED`），并对其建立普通或前缀索引：

```MySQL
ALTER TABLE configs
  ADD COLUMN theme VARCHAR(20) 
    AS (JSON_UNQUOTE(JSON_EXTRACT(data, '$.theme'))) 
    STORED,
  ADD INDEX idx_theme (theme);
```

- **优势**：对单一键快速过滤；
- **代价**：生成列占储存空间（`STORED`）或计算开销（`VIRTUAL`）。

---

## 五、性能与最佳实践

1. **文档大小**：尽量让 JSON 文档保持“小而扁平”，避免深度嵌套与超大数组。
2. **生成列索引**：对常查询字段务必用生成列并建索引，避免全表扫描 `JSON_EXTRACT`。
3. **合理划分**：若 JSON 字段中大部分属性在 WHERE/ORDER BY 中被频繁访问，建议拆到标准列。
4. **监控与分析**：使用 `EXPLAIN` 查看 `JSON_EXTRACT` 调用的成本，结合 `performance_schema` 跟踪慢查询。
5. **SQL 模式**：启用严格模式可防止非法 JSON 插入；关闭 `NO_ZERO_DATE` 避免自动填入无效日期。

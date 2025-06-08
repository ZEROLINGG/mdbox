下面对常用的 MySQL `CREATE` 系列语句进行补充和完善，涵盖语法细节、使用场景、权限要求及最佳实践。

---

## 1. CREATE DATABASE

### 语法

```MySQL
CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name
    [DEFAULT] CHARACTER SET [=] charset_name
    [DEFAULT] COLLATE [=] collation_name;
```

- **IF NOT EXISTS**：若数据库已存在则不报错。
    
- **DEFAULT CHARACTER SET / COLLATE**：指定默认字符集和校对规则，之后在表或列级别可自行覆盖。
    
- **权限要求**：`CREATE` 权限可创建；`DROP` 权限可删除已存在的数据库。
    

### 常用选项

- `SHOW CREATE DATABASE db_name;` 查看当前数据库配置。
    
- 通过 `ALTER DATABASE db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;` 修改已有数据库默认字符集。
    

### 示例

```MySQL
-- 创建 mydb，默认字符集 utf8mb4，校对规则 utf8mb4_unicode_ci
CREATE DATABASE IF NOT EXISTS mydb
    DEFAULT CHARACTER SET = utf8mb4
    DEFAULT COLLATE = utf8mb4_unicode_ci;

-- 查看数据库信息
SHOW CREATE DATABASE mydb;
```

---

## 2. CREATE TABLE

### 语法

```MySQL
CREATE TABLE [IF NOT EXISTS] tbl_name (
    column_name data_type [column_option ...],
    [table_constraint ...]
)
[ENGINE = engine_name]
[DEFAULT CHARSET = charset_name]
[COLLATE = collation_name]
[ROW_FORMAT = {DEFAULT | DYNAMIC | COMPRESSED}]
[AUTO_INCREMENT = N]
[COMMENT = 'table comment']
[PARTITION BY ...];
```

#### 列定义 (`column_option`)

- `NULL` / `NOT NULL`
    
- `DEFAULT <expr>`：可使用常量、`CURRENT_TIMESTAMP` 等。
    
- `AUTO_INCREMENT`
    
- `UNSIGNED` / `ZEROFILL`
    
- `COMMENT '说明'`
    
- `COLLATE collation_name`
    

#### 表级约束 (`table_constraint`)

- `PRIMARY KEY (col1, col2, ...)`
    
- `UNIQUE [KEY] (col_list)`
    
- `KEY [idx_name] (col_list)`
    
- `FULLTEXT KEY`, `SPATIAL KEY`
    
- `FOREIGN KEY (col) REFERENCES other_tbl(col) [ON DELETE ...] [ON UPDATE ...]`
    

#### 分区策略 (`PARTITION BY`)

- `RANGE(expr)`
    
- `LIST(expr)`
    
- `HASH(expr)` / `KEY(col_list)`
    

### 注意事项

- InnoDB 推荐用于事务与外键；MyISAM 支持全文与空间索引。
    
- `AUTO_INCREMENT` 列必须是索引的一部分。
    
- 表选项（如 `ENGINE` / `ROW_FORMAT`）可影响性能与存储格式。
    

### 示例

```MySQL
CREATE TABLE IF NOT EXISTS users (
    id          INT          UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    username    VARCHAR(50)  NOT NULL UNIQUE COMMENT '用户名',
    email       VARCHAR(100) NOT NULL COMMENT '邮箱',
    profile     JSON                      COMMENT '用户资料(JSON)',
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id)
)
ENGINE = InnoDB
DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci
ROW_FORMAT = DYNAMIC
COMMENT = '用户表'
PARTITION BY HASH(id) PARTITIONS 4;
```

---

## 3. CREATE INDEX

### 语法

```MySQL
CREATE [UNIQUE | FULLTEXT | SPATIAL] INDEX idx_name
    ON tbl_name (col_name [(length)] [ASC | DESC], ...)
[USING {BTREE | HASH}];
```

- **UNIQUE**：保证索引列值唯一。
    
- **FULLTEXT**：适合自然语言全文检索（InnoDB/MyISAM）。
    
- **SPATIAL**：用于 GIS 数据（仅 MyISAM）。
    
- `length`：对前缀索引（如 `VARCHAR(100)` 上的前 10 个字符）进行索引。
    
- `USING`：指定索引类型，缺省为 BTREE。
    

### 注意事项

- 可以在 `CREATE TABLE` 里内联定义，也可用此命令分离创建。
    
- 删除索引：`DROP INDEX idx_name ON tbl_name;`。
    

### 示例

```MySQL
-- 在 users.email 上创建唯一索引
CREATE UNIQUE INDEX idx_users_email ON users (email);

-- 在文章表 content 上创建全文索引
CREATE FULLTEXT INDEX idx_posts_content ON posts(content);
```

---

## 4. CREATE VIEW

### 语法

```MySQL
CREATE [OR REPLACE] VIEW view_name [(column_list)]
AS select_statement
[WITH [CASCADED | LOCAL] CHECK OPTION];
```

- **OR REPLACE**：若视图存在则覆盖。
    
- **CHECK OPTION**：保证通过视图插入/更新的行满足 `SELECT` 中的条件。
    
- 不支持在视图中使用 `ORDER BY`（除非配合 `LIMIT`）。
    
- 仅支持可更新视图（视图中不含聚合、`DISTINCT`、子查询等）。
    

### 性能与安全

- `MERGE` 算法：视图查询展开到主表；
    
- `TEMPTABLE` 算法：先执行视图查询写入临时表再查询。
    
- 由 `DEFINER` 决定视图执行时的权限。
    

### 示例

```MySQL
CREATE OR REPLACE VIEW active_users AS
SELECT id, username, email
FROM users
WHERE status = 'active'
WITH LOCAL CHECK OPTION;
```

---

## 5. CREATE USER

### 语法

```MySQL
CREATE USER [IF NOT EXISTS] 'user'@'host'
    IDENTIFIED WITH auth_plugin BY 'password'
    [REQUIRE tls_option [AND tls_option] ...]
    [WITH resource_option ...]
    [PASSWORD EXPIRE {DEFAULT | NEVER | INTERVAL N DAY}];
```

- **auth_plugin**：如 `mysql_native_password`、`caching_sha2_password`。
    
- **tls_option**：`SSL`, `X509`, `CIPHER 'cipher_list'` 等。
    
- **resource_option**：`MAX_QUERIES_PER_HOUR N`, `MAX_CONNECTIONS_PER_HOUR N` 等。
    
- **授权**：创建后需用 `GRANT` 赋权。
    

### 示例

```MySQL
CREATE USER IF NOT EXISTS 'appuser'@'%'
    IDENTIFIED WITH caching_sha2_password BY 'S3cr3tPwd!'
    REQUIRE SSL
    WITH MAX_QUERIES_PER_HOUR 1000;

-- 授予权限
GRANT SELECT, INSERT, UPDATE ON mydb.* TO 'appuser'@'%';
```

---

## 6. CREATE PROCEDURE / FUNCTION

### 语法

```MySQL
-- 存储过程
CREATE [DEFINER = user] PROCEDURE proc_name(
    [IN|OUT|INOUT] param_name data_type, ...
)
[characteristic ...]
BEGIN
    statements;
END;

-- 存储函数
CREATE [DEFINER = user] FUNCTION func_name(
    [IN] param_name data_type, ...
)
RETURNS data_type
[characteristic ...]
BEGIN
    statements;
    RETURN expr;
END;
```

- **characteristic**：`LANGUAGE SQL`, `DETERMINISTIC`/`NOT DETERMINISTIC`, `CONTAINS SQL`/`NO SQL`/`READS SQL DATA`/`MODIFIES SQL DATA`, `SQL SECURITY DEFINER`/`INVOKER`。
    
- **分隔符**：过程体内含 `;` 时需用 `DELIMITER` 切换。
    
- **错误处理**：使用 `DECLARE ... HANDLER` 捕获异常。
    

### 示例

```MySQL
DELIMITER $$
CREATE PROCEDURE add_user(
    IN p_username VARCHAR(50),
    IN p_email    VARCHAR(100)
)
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    INSERT INTO users(username, email)
    VALUES(p_username, p_email);
END$$

CREATE FUNCTION get_user_count()
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt FROM users;
    RETURN cnt;
END$$
DELIMITER ;
```

---

## 7. CREATE TRIGGER

### 语法

```MySQL
CREATE TRIGGER trigger_name
    {BEFORE | AFTER} {INSERT | UPDATE | DELETE}
    ON tbl_name
    FOR EACH ROW
    [FOLLOWS | PRECEDES existing_trigger]
BEGIN
    statements;
END;
```

- **BEFORE/AFTER**：行操作前或后触发。
    
- **NEW** / **OLD**：访问新旧行数据。
    
- 每个表每种事件可有多个触发器，触发器名唯一。
    

### 示例

```MySQL
DELIMITER $$
CREATE TRIGGER trg_users_before_insert
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    SET NEW.username = LOWER(NEW.username);
END$$

CREATE TRIGGER trg_update_timestamp
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    UPDATE users
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.id;
END$$
DELIMITER ;
```

---

## 权限一览

|对象|所需权限|
|---|---|
|DATABASE|CREATE|
|TABLE|CREATE|
|INDEX|CREATE, ALTER|
|VIEW|CREATE VIEW|
|USER|CREATE USER|
|PROCEDURE/FUNCTION|CREATE ROUTINE|
|TRIGGER|TRIGGER|

---

## 小结

- 使用 `IF NOT EXISTS` 或 `OR REPLACE` 提升 idempotence。
    
- 结合表/列级别选项优化性能与兼容性。
    
- 合理分配权限，保持最小授权原则。
    
- 对存储过程、触发器等复杂对象，注意分隔符与错误处理。
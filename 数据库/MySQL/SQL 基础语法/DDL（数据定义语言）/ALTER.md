## 一、ALTER DATABASE

用于修改已有数据库的默认字符集与校对规则，也可修改数据库的加密、归档等其它元数据（MySQL 8.0+）。

```MySQL
ALTER DATABASE db_name
    [CHARACTER SET [=] charset_name]
    [COLLATE [=] collation_name]
    [ENCRYPTION = {'Y'|'N'}]
    [COMMENT = 'text'];
```

- **CHARACTER SET** / **COLLATE**：更新数据库级别默认，影响后续新建的表和列。
- **ENCRYPTION**：开启或关闭数据文件加密（需要 InnoDB + 支持的密钥管理）。
- **COMMENT**：给数据库添加注释。

**示例**：

- 将 `shop` 改为 `utf8mb4`/`utf8mb4_general_ci`

```MySQL
ALTER DATABASE shop
  CHARACTER SET = utf8mb4
  COLLATE    = utf8mb4_general_ci;
```

- 为数据库开启加密、添加注释

```MySQL
ALTER DATABASE shop
  ENCRYPTION = 'Y'
  COMMENT    = '线上电商数据库（加密存储）';
```

---

## 二、ALTER TABLE

`ALTER TABLE` 是最常用的 DDL 之一，支持列、索引、分区、表选项等各种调整。MySQL 8.0 在 InnoDB 上提供了部分 **Online DDL** 能力。

```MySQL
ALTER [ONLINE | OFFLINE]
      TABLE tbl_name
    action [, action] ...;
```

- **ONLINE/OFFLINE**：显式指定在线或离线（MySQL 会根据操作选择最优策略）。
- **ALGORITHM**:

- `INPLACE`：尽量原地修改，不复制表。
- `COPY`：全表复制重建（默认）。
- `INSTANT`：仅修改元数据即可生效（仅限部分 `ADD COLUMN` 操作）。

- **LOCK**：

- `NONE`：允许读写。
- `SHARED`：阻塞写。
- `EXCLUSIVE`：阻塞读写。

**全表锁策略示例**

```MySQL
ALTER /*+ ALGORITHM=INPLACE, LOCK=NONE */ TABLE t
  ADD COLUMN remark VARCHAR(255);
```

### 2.1 常用操作一览

|             |                                                                                                                                       |                                                          |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| 操作          | 语法示例                                                                                                                                  | 说明                                                       |
| **添加列**     | `ADD [COLUMN] col_name 定义 [FIRST                                                                                                      | AFTER colX]`                                             |
| **删除列**     | `DROP [COLUMN] col_name`                                                                                                              |                                                          |
| **重命名/修改列** | `CHANGE [COLUMN] old_name new_name 定义 [FIRST                                                                                          | AFTER colX] `<br>`<br><br>MODIFY [COLUMN] col 定义`        |
| **添加约束**    | `ADD [CONSTRAINT 名称] PRIMARY KEY(cols)`<br><br>  <br>`ADD CONSTRAINT 名称 FOREIGN KEY(cols) REFERENCES ref_table(cols) [ON DELETE ...]` | 主键、外键等                                                   |
| **添加索引**    | `ADD [INDEX                                                                                                                           | KEY] 名称 (cols) `<br>`<br><br>ADD UNIQUE [KEY] 名称 (cols)` |
| **删除索引**    | `DROP INDEX 索引名`                                                                                                                      | InnoDB 同 `DROP KEY`                                      |
| **修改表选项**   | `ENGINE=InnoDB`<br><br>/ `AUTO_INCREMENT=1000`<br><br>/ `COMMENT='...'`<br><br>/ `ROW_FORMAT=Compact`                                 |                                                          |
| **分区操作**    | `ADD PARTITION...`<br><br>/ `DROP PARTITION...`<br><br>/ `COALESCE PARTITION`                                                         | 需根据分区类型谨慎操作                                              |

### 2.2 支持 Online/Instant 的操作

|   |   |   |   |
|---|---|---|---|
|操作类型|MySQL 版本|ALGORITHM|LOCK|
|`ADD COLUMN`<br><br>（无默认）|8.0.12+|INSTANT|NONE|
|`DROP COLUMN`|8.0.16+|INSTANT|NONE|
|`ADD INDEX`|5.6+ InnoDB|INPLACE|NONE|
|`MODIFY COLUMN`|部分情况|INPLACE|SHARED|
|`CHANGE COLUMN`|部分情况|COPY|EXCLUSIVE|
|**更多细节**：请参考官方文档 “Online DDL” 部分。||||

### 2.3 典型示例

1. **新增可空列并置于首位**

```MySQL
ALTER TABLE user
  ADD COLUMN last_login DATETIME NULL FIRST;
```

2. **修改列类型并设默认值**

```MySQL
ALTER TABLE orders
  MODIFY COLUMN amount DECIMAL(12,2) NOT NULL DEFAULT 0;
```

3. **重命名列并保留定义**

```MySQL
ALTER TABLE product
  CHANGE COLUMN old_name new_name VARCHAR(100) NOT NULL COMMENT '新列名示例';
```

4. **添加外键约束**

```MySQL
ALTER TABLE order_item
  ADD CONSTRAINT fk_order
    FOREIGN KEY (order_id)
    REFERENCES orders(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT;
```

5. **在线切换存储引擎（InnoDB）**

```MySQL
ALTER /*+ ALGORITHM=INPLACE, LOCK=NONE */ TABLE my_table
  ENGINE = InnoDB;
```

---

## 三、ALTER VIEW

用于重新定义视图的查询逻辑或元数据。

```MySQL
ALTER [ALGORITHM = {UNDEFINED|MERGE|TEMPTABLE}]
      VIEW view_name [(col_list)]
    AS select_statement
    [WITH [CASCADED|LOCAL] CHECK OPTION];
```

- **ALGORITHM**：

- `MERGE` / `TEMPTABLE`：同 `CREATE VIEW`。
- `UNDEFINED`：让服务器自动选择。

- **col_list**：可在重定义时调整列名顺序或别名。
- **CHECK OPTION**：

- `LOCAL`：只检查该视图本身的 WHERE 条件。
- `CASCADED`：检查所有基础视图/表的条件。

**示例**：更新视图以限制今年新用户

```MySQL
ALTER VIEW v_active_users
  AS SELECT id, name, created_at
  FROM user
  WHERE created_at >= '2025-01-01'
  WITH CASCADED CHECK OPTION;
```

---

## 四、其他 ALTER 语句概览

|   |   |
|---|---|
|语句|用途|
|**ALTER USER**|修改用户认证插件、密码、锁定状态、密码过期策略等|
|**ALTER ROLE**|MySQL 8.0+，管理角色成员、权限|
|**ALTER PROCEDURE/FUNCTION**|仅能修改 COMMENT、DETERMINISTIC、SQL SECURITY、LANGUAGE 等元数据|
|**ALTER EVENT**|修改 Event 调度器的执行时间、状态（ENABLE/DISABLE）、定义等|
|**ALTER SERVER**|在 Federated 或 Proxy 环境中调整远程服务器连接参数|
|**ALTER LOGFILE GROUP** / **TABLESPACE**|针对 InnoDB 引擎高级存储配置|

**示例**：

- 修改用户密码并要求下次登录重置

```MySQL
ALTER USER 'alice'@'%' 
  IDENTIFIED BY 's3cr3t' 
  PASSWORD EXPIRE;
```

- 禁用一个定时任务

```MySQL
ALTER EVENT cleanup_old_logs
  DISABLE;
```

---

## 五、实战建议与注意事项

1. **全量备份**：大表/生产库改结构前，务必做备份或在测试环境演练；可结合 `pt-online-schema-change` 实现零宕机改表。
2. **事务支持**：MySQL DDL 大多会提交当前事务，且不可回滚，执行前请谨慎。
3. **监控锁**：改表时关注 `INFORMATION_SCHEMA.INNODB_TRX`、`SHOW PROCESSLIST`，避免长时间锁表影响业务。
4. **版本兼容**：Online DDL 能力随版本增强，不同操作在不同版本可能行为截然不同，升级与设计前请查阅对应手册。
5. **规范命名**：索引、外键等显式命名，便于后续维护与定位问题。
6. **分区表改动**：分区表的 `ALTER TABLE` 语法与普通表类似，但有额外限制，特别是 DROP/REORGANIZE 分区时务必在线上验证。

## 一、DROP DATABASE / DROP SCHEMA

### 1.1 语法

```MySQL
DROP {DATABASE | SCHEMA} [IF EXISTS] db_name
    [RESTRICT | CASCADE];
```

- **IF EXISTS**：在数据库不存在时不报错，仅产生警告。
- **RESTRICT**（默认）／**CASCADE**：目前 MySQL 不区分，始终等同于 `RESTRICT`，即如果数据库被使用则会拒绝删除。

### 1.2 权限

- 需要对目标数据库拥有 `DROP` 权限，或全局 `CREATE` 权限。

### 1.3 注意事项

- **不可恢复**：删除数据库会移除所有表、视图、触发器、事件等元数据及数据文件，操作前请务必备份。
- 如果有连接正在使用该数据库，删除会失败或影响连接。

### 1.4 示例

```MySQL
-- 安全删除：仅当 shop 库存在时才删除
DROP DATABASE IF EXISTS shop;
```

---

## 二、DROP TABLE

### 2.1 语法

```MySQL
DROP [TEMPORARY] TABLE [IF EXISTS]
    tbl_name [, tbl_name] ... 
    [RESTRICT | CASCADE];
```

- **TEMPORARY**：仅删除当前会话中的临时表。
- **IF EXISTS**：表不存在时不报错，仅警告。
- **RESTRICT/CASCADE**：MySQL 不区分，均拒绝删除被外键依赖的表（InnoDB）。

### 2.2 权限

- 需要对表有 `DROP` 权限；若表是临时表，则仅需对临时表拥有权限。

### 2.3 注意事项

1. **事务行为**

- InnoDB 中 `DROP TABLE` 会隐含提交当前事务，不可回滚。

2. **外键约束**

- 若有其他表通过外键引用，删除会失败，需先 `ALTER TABLE ... DROP FOREIGN KEY`。

3. **表名大小写**

- 在不区分大小写的文件系统上，`DROP TABLE a; DROP TABLE A;` 可能会一次性删除同一个 `.frm/.ibd` 文件。

### 2.4 示例

```MySQL
-- 同时删除多个表
DROP TABLE IF EXISTS t1, t2, t3;

-- 删除会话级临时表
DROP TEMPORARY TABLE IF EXISTS tmp_users;
```

---

## 三、DROP VIEW

### 3.1 语法

```MySQL
DROP VIEW [IF EXISTS] view_name [, view_name] ... 
    [RESTRICT | CASCADE];
```

- **IF EXISTS**：视图不存在时只警告。
- **RESTRICT/CASCADE**：MySQL 同样不区分，拒绝删除被其他视图依赖的情况下。

### 3.2 权限

- 需要对视图有 `DROP` 权限，以及对底层表有 `SELECT` 权限。

### 3.3 注意事项

- 删除视图不会影响底层数据表。
- 若存在 **视图链**（视图依赖视图），先删除上层再删除下层。

### 3.4 示例

```MySQL
-- 批量删除视图
DROP VIEW IF EXISTS v_orders, v_customers;
```

---

## 四、DROP INDEX

### 4.1 语法（InnoDB）

```MySQL
ALTER TABLE tbl_name
  DROP INDEX index_name;  -- 等同于 DROP KEY index_name
```

或者对于 MyISAM：

```MySQL
DROP INDEX index_name
  ON tbl_name;
```

### 4.2 权限

- 修改表结构需 `ALTER` 权限；若是 DROP USER_DEFINED 索引，则需要 `INDEX` 权限。

### 4.3 注意事项

- 删除主键索引请使用 `ALTER TABLE ... DROP PRIMARY KEY`；
- InnoDB 中主键必须唯一且非空，删除后若无其他唯一索引，表将隐式创建聚簇主键。

### 4.4 示例

```MySQL
-- 删除普通索引
ALTER TABLE orders
  DROP INDEX idx_order_date;

-- 删除唯一索引
ALTER TABLE user
  DROP INDEX ux_email;
```

---

## 五、DROP TRIGGER

### 5.1 语法

```MySQL
DROP TRIGGER [IF EXISTS] [schema_name.]trigger_name;
```

- **IF EXISTS**：触发器不存在时不报错。

### 5.2 权限

- 需要对触发器所属表具有 `ALTER` 和 `TRIGGER` 权限。

### 5.3 注意事项

- 删除触发器后，所有与该触发器关联的业务逻辑（如日志记录、级联操作）将不再执行，需谨慎。

### 5.4 示例

```MySQL
-- 删除触发表
DROP TRIGGER IF EXISTS audit_before_insert;
```

---

## 六、DROP PROCEDURE / DROP FUNCTION

### 6.1 语法

```MySQL
DROP {PROCEDURE | FUNCTION} [IF EXISTS]
     sp_name[, sp_name ...];
```

### 6.2 权限

- `DROP ROUTINE` 或者对该存储例程有 `ALTER ROUTINE` 权限。

### 6.3 注意事项

- 删除前可先 `SHOW CREATE PROCEDURE/FUNCTION` 备份定义脚本；
- 若有其他对象依赖此例程（如事件、触发器），执行前先清理依赖。

### 6.4 示例

```MySQL
DROP PROCEDURE IF EXISTS proc_update_stats;
DROP FUNCTION IF EXISTS fn_calc_tax;
```

---

## 七、DROP EVENT

### 7.1 语法

```MySQL
DROP EVENT [IF EXISTS] event_name;
```

### 7.2 权限

- 需要对事件有 `ALTER ROUTINE` 或全局 `EVENT` 权限。

### 7.3 注意事项

- 删除后，调度器不再执行该任务；
- 可通过 `SHOW EVENTS` 查看剩余事件。

### 7.4 示例

```MySQL
DROP EVENT IF EXISTS cleanup_daily;
```

---

## 八、DROP USER / DROP ROLE

### 8.1 DROP USER

```MySQL
DROP USER [IF EXISTS] user_spec [, user_spec ...];
```

- **user_spec**：`'user'@'host'`。
- 删除用户会同时删除其在 grant tables 中的所有权限。

#### 权限

- 需要全局 `CREATE USER` 或 `INSERT`、`DELETE`、`UPDATE` 权限。

#### 示例

```MySQL
DROP USER IF EXISTS 'bob'@'%';
```

### 8.2 DROP ROLE （MySQL 8.0+）

```MySQL
DROP ROLE [IF EXISTS] role_name [, role_name ...];
```

- 删除角色前，确保已从所有用户和角色中 `REVOKE`。

#### 权限

- 需要全局 `DROP ROLE` 或 `SET ROLE` 权限。

#### 示例

```MySQL
DROP ROLE IF EXISTS reporting_analyst;
```

---

## 九、DROP PARTITION

### 9.1 语法

```MySQL
ALTER TABLE tbl_name
  DROP PARTITION p0 [, p1, ...]
  [UPDATE GLOBAL INDEXES];
```

- 只能在分区表上使用，不是独立的 `DROP` 语句。

### 9.2 注意事项

- 数据会被删除且无法恢复；
- 若有全局二级索引，需加 `UPDATE GLOBAL INDEXES` 同步重建。

### 9.3 示例

```MySQL
ALTER TABLE metrics
  DROP PARTITION p2025_01, p2025_02
  UPDATE GLOBAL INDEXES;
```

---

## 十、其他 DROP 语句

- **DROP SERVER**：移除 Federated/MySQL Proxy 远程服务器
- **DROP LOGFILE GROUP**：删除 InnoDB 日志文件组
- **DROP TABLESPACE**：删除 InnoDB 表空间
- **DROP RESOURCE**（8.0.16+）：删除 Resource group
- **DROP SPATIAL REFERENCE SYSTEM**：移除空间参照系统

```MySQL
-- 删除 Federated 服务器
DROP SERVER IF EXISTS fed_server;

-- 删除自定义表空间
DROP TABLESPACE ts1 ENGINE = InnoDB;
```

---

## 十一、实战建议与注意事项

1. **备份优先**：任何 `DROP` 操作执行前，请先备份（`mysqldump`、文件拷贝或快照）。
2. **权限审计**：合理分离权限，避免误删。生产环境建议启用多级审批流程。
3. **IF EXISTS**：在自动化脚本中加上 `IF EXISTS`，避免中断批量执行。
4. **依赖检查**：大对象（表／视图／例程）相互依赖时，先用 `INFORMATION_SCHEMA` 或 `SHOW` 系列命令检查依赖链。
5. **清理残留**：删除用户或角色后，可通过 `SHOW GRANTS` 和 `mysql.user` 表确认权限已清理。
6. **运维脚本**：建议将所有 `DROP` 操作纳入版本控制，配合审计日志，保障可追溯。

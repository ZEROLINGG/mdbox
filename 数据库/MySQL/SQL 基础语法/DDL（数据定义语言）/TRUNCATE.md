## 一、概述

`TRUNCATE TABLE` 用于 **快速清空** 整个表的所有行，但保留 **表结构**（包括列、索引、约束等）不变。

- 本质上它属于 **DDL** 而非 DML；
- 逻辑上等同于 `DELETE FROM tbl_name`（无 `WHERE`）或 `DROP TABLE` + `CREATE TABLE` 的组合。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

---

## 二、语法与权限

```MySQL
TRUNCATE [TABLE] tbl_name;
```

- **IF EXISTS** 不支持；
- **多表清空** 必须分别对各表执行。
- **权限**：需要对目标表拥有 **DROP** 权限。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

---

## 三、关键特性与行为差异

1. **DDL 而非 DML**

- 虽然效果类似 `DELETE`，但分类为 **数据定义语句**；
- 不触发 `ON DELETE` 触发器。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

2. **隐式提交**

- 执行前后都会自动提交当前事务，无法回滚。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

3. **性能优势**

- 通过 **丢弃并重建** 表或表空间来清空数据，避免逐行删除，速度极快；
- 对大表特别有效。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

4. `**AUTO_INCREMENT**` **重置**

- 将自增计数器重置为初始值；
- 对 InnoDB、MyISAM 均生效。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

5. **外键约束限制**

- **InnoDB** 或 **NDB** 表如有父—子表（外键）依赖时，无法执行 `TRUNCATE`；
- 同表内自引用外键则允许。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

6. **表锁要求**

- 如会话已持有任何表锁，`TRUNCATE` 会失败。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

7. **关闭打开的 HANDLER**

- 会关闭所有通过 `HANDLER OPEN` 打开的句柄。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

8. **分区表**

- 保留分区定义，仅对各分区数据和索引文件执行丢弃重建；
- 分区方案及元数据不变。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

9. **损坏表支持**

- 即使数据或索引文件损坏，只要表定义有效，亦能成功清空。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

10. **Performance Schema 汇总表**

- 用于统计汇总的表被清空时，会将汇总列重置为 `0` 或 `NULL`，而不是删除行。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

---

## 四、事务与原子性

- 对于支持 **原子 DDL** 的存储引擎（如 InnoDB），`TRUNCATE` 本身具有原子性：若服务器崩溃，操作要么全量生效，要么全量回滚 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)；
- 但在执行过程中仍会产生 **隐式提交**，不可与其它 DML 一并回滚。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)

---

## 五、二进制日志与复制

- `TRUNCATE TABLE` 始终以 **DDL 语句** 形式记录在 binlog 中，不受 binlog_format（ROW/STATEMENT/MIXED）影响；
- 从库按语句方式执行，遵循主库 InnoDB 行为规则。 [docs.oracle.com](https://docs.oracle.com/cd/E17952_01/mysql-8.0-en/replication-features-truncate.html)

---

## 六、存储引擎差异

|   |   |
|---|---|
|存储引擎|行为|
|**InnoDB**|删除并重新创建表（或表空间），重置自增；不触发触发器；需 DROP 权限；外键依赖时失败；支持原子性。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)|
|**MyISAM**|类似 InnoDB；重置自增；快速丢弃数据文件。 [dev.mysql.com](https://dev.mysql.com/doc/en/truncate-table.html)|
|**MEMORY**|释放全部内存；同样可使用 `TRUNCATE`<br><br>清空表，内存引擎直接回收所有页。 [dev.mysql.com](https://dev.mysql.com/doc/refman/8.4/en/memory-storage-engine.html?utm_source=chatgpt.com)|

---

## 七、典型示例

```MySQL
-- 基本用法：清空 orders 表
TRUNCATE TABLE orders;

-- 当有分区时，仅重建数据文件，保留分区定义
TRUNCATE TABLE user_logs;  

-- 结合外键约束：需先禁用外键检查（不推荐，仅演示）
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE parent_table;
SET FOREIGN_KEY_CHECKS = 1;
```

---

## 八、注意事项与最佳实践

1. **务必备份**：清空前请先全量备份（`mysqldump`、快照等），否则数据不可恢复。
2. **审慎对待外键**：如表被其它表引用，应先处理约束再清空。
3. **避免在高峰期**：虽为快速操作，但仍会隐式提交并重建表文件，可能短暂影响并发。
4. **脚本化谨慎**：生产脚本中可加 `IF EXISTS` 检测（手动包装）或加流程审批。
5. **区别 DELETE**：若需触发器、事务回滚或行级删除计数，应使用 `DELETE`。

以上便是 MySQL 中 `TRUNCATE TABLE` 的全面详解，涵盖语法、权限、执行机制、存储引擎差异及实战建议。

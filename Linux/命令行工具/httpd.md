# openEuler中httpd完整使用指南

## 一、httpd简介与用途

### 在openEuler中的应用场景
- **企业Web服务器** - 部署企业门户、内部系统
- **开发测试环境** - 搭建本地开发和测试平台
- **反向代理服务** - 作为负载均衡器和代理服务器
- **静态资源服务** - CDN节点、文件下载服务器
- **API网关** - 微服务架构中的API接入层
- **容器化部署** - 配合Docker/Kubernetes使用
- **高可用集群** - 配合Keepalived/HAProxy实现HA

## 二、安装与基础配置

### 1. 安装httpd
```bash
# 更新系统软件包
sudo dnf update -y

# 安装httpd
sudo dnf install httpd -y

# 安装常用模块和工具
sudo dnf install httpd-tools mod_ssl mod_security -y

# 检查安装版本
httpd -v

# 验证安装
rpm -qa | grep httpd
```

### 2. 基本服务管理
```bash
# 启动httpd服务
sudo systemctl start httpd

# 停止httpd服务
sudo systemctl stop httpd

# 重启httpd服务
sudo systemctl restart httpd

# 重载配置（不中断服务）
sudo systemctl reload httpd

# 查看服务状态
sudo systemctl status httpd

# 设置开机自启
sudo systemctl enable httpd

# 取消开机自启
sudo systemctl disable httpd

# 查看服务是否启用
sudo systemctl is-enabled httpd

# 优雅重启（等待当前请求完成）
sudo httpd -k graceful
```

### 3. 防火墙配置
```bash
# 启动firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# 允许HTTP服务（端口80）
sudo firewall-cmd --permanent --add-service=http

# 允许HTTPS服务（端口443）
sudo firewall-cmd --permanent --add-service=https

# 允许自定义端口
sudo firewall-cmd --permanent --add-port=8080/tcp

# 重载防火墙配置
sudo firewall-cmd --reload

# 查看已开放的服务和端口
sudo firewall-cmd --list-all

# 删除服务
sudo firewall-cmd --permanent --remove-service=http
```

### 4. SELinux配置
```bash
# 查看SELinux状态
getenforce
sestatus

# 临时禁用SELinux（重启后恢复）
sudo setenforce 0

# 永久禁用SELinux（不推荐，仅用于测试）
sudo nano /etc/selinux/config
# 修改：SELINUX=disabled

# 推荐：配置SELinux策略而不是禁用
# 允许httpd网络连接
sudo setsebool -P httpd_can_network_connect on

# 允许httpd连接数据库
sudo setsebool -P httpd_can_network_connect_db on

# 允许httpd发送邮件
sudo setsebool -P httpd_can_sendmail on

# 允许httpd执行脚本
sudo setsebool -P httpd_enable_cgi on

# 设置Web目录的SELinux上下文
sudo semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"
sudo restorecon -Rv /web

# 查看httpd相关的布尔值
getsebool -a | grep httpd
```

### 5. 快速验证
```bash
# 浏览器访问
http://localhost
http://127.0.0.1
http://[本机IP]

# 命令行测试
curl http://localhost
wget http://localhost -O -

# 查看监听端口
sudo ss -tlnp | grep httpd
sudo netstat -tlnp | grep httpd

# 检查进程
ps aux | grep httpd
```

## 三、目录结构与配置文件

### 重要目录说明
```
/etc/httpd/                    # 主配置目录
├── conf/                      # 核心配置文件
│   ├── httpd.conf            # 主配置文件（全局设置）
│   └── magic                 # MIME类型检测
├── conf.d/                    # 附加配置目录（虚拟主机、站点配置）
│   ├── ssl.conf              # SSL配置
│   ├── autoindex.conf        # 目录索引配置
│   ├── userdir.conf          # 用户目录配置
│   └── welcome.conf          # 默认欢迎页面
├── conf.modules.d/            # 模块配置目录
│   ├── 00-base.conf          # 基础模块
│   ├── 00-mpm.conf           # MPM模块配置
│   ├── 00-ssl.conf           # SSL模块
│   ├── 10-php.conf           # PHP模块（安装PHP后）
│   └── 10-proxy.conf         # 代理模块
├── logs -> /var/log/httpd/    # 日志目录（符号链接）
├── modules -> /usr/lib64/httpd/modules/  # 模块目录（符号链接）
└── run -> /run/httpd/         # 运行时文件

/var/www/                      # Web根目录
├── html/                      # 默认网站目录
├── cgi-bin/                   # CGI脚本目录
└── [其他站点目录]

/var/log/httpd/                # 日志文件目录
├── access_log                 # 访问日志
├── error_log                  # 错误日志
└── ssl_access_log             # SSL访问日志（启用SSL后）

/usr/lib64/httpd/modules/      # httpd模块文件
/usr/share/httpd/              # httpd共享文件
/run/httpd/                    # 运行时文件（PID等）
```

### 配置文件加载顺序
1. `/etc/httpd/conf/httpd.conf` - 主配置
2. `/etc/httpd/conf.modules.d/*.conf` - 模块配置
3. `/etc/httpd/conf.d/*.conf` - 附加配置和虚拟主机

### 与Debian系统的主要区别
| 项目 | openEuler (RHEL系) | Debian/Ubuntu |
|------|-------------------|---------------|
| 包名 | httpd | apache2 |
| 服务名 | httpd.service | apache2.service |
| 主配置 | /etc/httpd/conf/httpd.conf | /etc/apache2/apache2.conf |
| 站点配置 | /etc/httpd/conf.d/ | /etc/apache2/sites-available/ |
| 模块配置 | /etc/httpd/conf.modules.d/ | /etc/apache2/mods-available/ |
| Web根目录 | /var/www/html | /var/www/html |
| 日志目录 | /var/log/httpd/ | /var/log/apache2/ |
| 用户/组 | apache:apache | www-data:www-data |
| 包管理 | dnf/yum | apt |

## 四、基础配置操作

### 1. 修改默认端口
```bash
# 编辑主配置文件
sudo nano /etc/httpd/conf/httpd.conf

# 找到并修改监听端口（例如改为8080）
Listen 8080

# 如需监听多个端口
Listen 80
Listen 8080
Listen 8443

# 测试配置
sudo httpd -t
sudo apachectl configtest

# 重启服务生效
sudo systemctl restart httpd

# 防火墙开放新端口
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# 验证端口
sudo ss -tlnp | grep httpd
```

### 2. 配置虚拟主机（基于域名）
```bash
# 创建网站目录
sudo mkdir -p /var/www/testsite/{public_html,logs}

# 创建测试页面
echo "<h1>Test Site on openEuler</h1>" | sudo tee /var/www/testsite/public_html/index.html

# 设置权限
sudo chown -R apache:apache /var/www/testsite
sudo chmod -R 755 /var/www/testsite

# 设置SELinux上下文
sudo semanage fcontext -a -t httpd_sys_content_t "/var/www/testsite(/.*)?"
sudo restorecon -Rv /var/www/testsite

# 创建虚拟主机配置
sudo nano /etc/httpd/conf.d/testsite.conf
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
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        
        # 默认索引文件
        DirectoryIndex index.html index.php
    </Directory>
    
    # 日志配置
    ErrorLog /var/www/testsite/logs/error_log
    CustomLog /var/www/testsite/logs/access_log combined
    
    # 日志级别
    LogLevel warn
</VirtualHost>
```

**应用配置：**
```bash
# 测试配置
sudo httpd -t

# 重载配置
sudo systemctl reload httpd

# 添加hosts记录（本地测试）
echo "127.0.0.1 testsite.local" | sudo tee -a /etc/hosts

# 测试访问
curl http://testsite.local
```

### 3. 基于IP的虚拟主机
```apache
# /etc/httpd/conf.d/ip-vhosts.conf
<VirtualHost 192.168.1.100:80>
    ServerName site1.example.com
    DocumentRoot /var/www/site1
    
    <Directory /var/www/site1>
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost 192.168.1.101:80>
    ServerName site2.example.com
    DocumentRoot /var/www/site2
    
    <Directory /var/www/site2>
        Require all granted
    </Directory>
</VirtualHost>
```

### 4. 基于端口的虚拟主机
```apache
# 在httpd.conf中添加
Listen 8080
Listen 8081

# 在conf.d/中创建配置
<VirtualHost *:8080>
    ServerName port8080.local
    DocumentRoot /var/www/site1
    
    <Directory /var/www/site1>
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:8081>
    ServerName port8081.local
    DocumentRoot /var/www/site2
    
    <Directory /var/www/site2>
        Require all granted
    </Directory>
</VirtualHost>
```

## 五、安全配置

### 1. 隐藏httpd版本和系统信息
```bash
# 编辑主配置文件
sudo nano /etc/httpd/conf/httpd.conf

# 在文件末尾添加或修改
ServerTokens Prod          # 仅显示"Apache"
ServerSignature Off        # 关闭页面签名
TraceEnable Off           # 禁用TRACE方法

# 重启服务
sudo systemctl restart httpd

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
sudo htpasswd -c /etc/httpd/.htpasswd admin

# 添加更多用户（不使用-c）
sudo htpasswd /etc/httpd/.htpasswd user2

# 删除用户
sudo htpasswd -D /etc/httpd/.htpasswd user2

# 查看用户列表
sudo cat /etc/httpd/.htpasswd

# 设置文件权限
sudo chmod 640 /etc/httpd/.htpasswd
sudo chown root:apache /etc/httpd/.htpasswd

# 配置认证
sudo nano /etc/httpd/conf.d/auth.conf
```

**认证配置示例：**
```apache
<Directory /var/www/html/secure>
    AuthType Basic
    AuthName "Restricted Area - Authentication Required"
    AuthUserFile /etc/httpd/.htpasswd
    Require valid-user
    
    # 或指定特定用户
    # Require user admin user2
    
    # 或指定用户组
    # AuthGroupFile /etc/httpd/.htgroup
    # Require group admins
</Directory>
```

### 4. 文件和目录安全
```apache
# 保护敏感文件
<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>

<FilesMatch "\.(bak|config|sql|log|sh|rpm)$">
    Require all denied
</FilesMatch>

# 保护Git和SVN目录
<DirectoryMatch "^/.*/\.(git|svn)/">
    Require all denied
</DirectoryMatch>

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
```bash
# 加载headers模块（默认已加载）
# 在配置文件中添加
sudo nano /etc/httpd/conf.d/security-headers.conf
```

```apache
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
# 在httpd.conf或虚拟主机配置中添加
LimitRequestBody 10485760        # 限制请求体为10MB
LimitRequestFields 100           # 限制请求头字段数量
LimitRequestFieldSize 8190       # 限制请求头字段大小
LimitRequestLine 8190            # 限制请求行大小

Timeout 60                       # 请求超时时间（秒）
KeepAliveTimeout 5              # 保持连接超时时间
MaxKeepAliveRequests 100        # 每个连接的最大请求数
```

## 六、常用模块配置

### 1. URL重写模块（mod_rewrite）
```bash
# 检查模块是否加载
httpd -M | grep rewrite

# 如果未加载，编辑模块配置
sudo nano /etc/httpd/conf.modules.d/00-base.conf
# 确保包含：LoadModule rewrite_module modules/mod_rewrite.so

# 重启httpd
sudo systemctl restart httpd

# 验证模块加载
httpd -M | grep rewrite
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
# 安装SSL模块
sudo dnf install mod_ssl -y

# SSL模块配置文件
sudo nano /etc/httpd/conf.d/ssl.conf

# 创建自签名证书（测试用）
sudo mkdir -p /etc/pki/tls/{certs,private}

# 生成私钥和证书
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/pki/tls/private/localhost.key \
    -out /etc/pki/tls/certs/localhost.crt \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=Organization/CN=localhost"

# 生成强DH参数（可选，增强安全性）
sudo openssl dhparam -out /etc/pki/tls/certs/dhparam.pem 2048

# 设置证书文件权限
sudo chmod 600 /etc/pki/tls/private/localhost.key
sudo chmod 644 /etc/pki/tls/certs/localhost.crt

# 设置SELinux上下文
sudo restorecon -RvF /etc/pki/tls/
```

**完整SSL虚拟主机配置：**
```apache
# /etc/httpd/conf.d/ssl-vhost.conf
<VirtualHost *:443>
    ServerName localhost
    ServerAdmin admin@localhost
    DocumentRoot /var/www/html
    
    # SSL引擎
    SSLEngine on
    
    # 证书文件
    SSLCertificateFile /etc/pki/tls/certs/localhost.crt
    SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
    
    # 证书链文件（如果有）
    # SSLCertificateChainFile /etc/pki/tls/certs/chain.crt
    
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
    ErrorLog /var/log/httpd/ssl_error_log
    CustomLog /var/log/httpd/ssl_access_log combined
    LogLevel warn
</VirtualHost>
```

**启用SSL站点：**
```bash
# 测试配置
sudo httpd -t

# 重启httpd
sudo systemctl restart httpd

# 防火墙开放443端口
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# 测试HTTPS访问
curl -k https://localhost

# 查看证书信息
openssl s_client -connect localhost:443 -showcerts
```

**使用Let's Encrypt免费证书（生产环境）：**
```bash
# 安装Certbot
sudo dnf install epel-release -y
sudo dnf install certbot python3-certbot-apache -y

# 自动配置SSL
sudo certbot --apache -d yourdomain.com -d www.yourdomain.com

# 仅获取证书不自动配置
sudo certbot certonly --apache -d yourdomain.com

# 测试自动续期
sudo certbot renew --dry-run

# 查看已安装证书
sudo certbot certificates

# 设置自动续期
sudo systemctl enable --now certbot-renew.timer
```

### 3. PHP支持
```bash
# 安装PHP及常用扩展
sudo dnf install php php-mysqlnd php-gd php-xml php-mbstring php-curl php-json -y

# PHP配置文件会自动创建在
# /etc/httpd/conf.d/php.conf
# /etc/httpd/conf.modules.d/10-php.conf

# 重启httpd
sudo systemctl restart httpd

# 创建测试文件
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

# 设置权限和SELinux上下文
sudo chown apache:apache /var/www/html/info.php
sudo restorecon -v /var/www/html/info.php

# 访问测试
curl http://localhost/info.php

# 安全起见，测试后删除
sudo rm /var/www/html/info.php
```

**PHP安全配置：**
```bash
# 编辑php.ini
sudo nano /etc/php.ini

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

# 创建日志文件
sudo touch /var/log/php_errors.log
sudo chown apache:apache /var/log/php_errors.log

# 重启生效
sudo systemctl restart httpd
```

### 4. 代理模块（反向代理）
```bash
# 检查代理模块是否加载
httpd -M | grep proxy

# 如果未加载，编辑配置
sudo nano /etc/httpd/conf.modules.d/00-proxy.conf
```

```apache
# 确保包含以下行
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule proxy_balancer_module modules/mod_proxy_balancer.so
LoadModule lbmethod_byrequests_module modules/mod_lbmethod_byrequests.so
```

**反向代理配置示例：**
```apache
# /etc/httpd/conf.d/proxy.conf
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
    
    # SELinux允许httpd网络连接
    # sudo setsebool -P httpd_can_network_connect on
</VirtualHost>
```

### 5. 其他有用模块
```bash
# 查看所有已加载模块
httpd -M

# 查看可用模块
ls /usr/lib64/httpd/modules/

# 常用模块配置文件位置
ls /etc/httpd/conf.modules.d/

# 启用/禁用模块（编辑对应配置文件）
# 压缩模块（默认已加载）
# LoadModule deflate_module modules/mod_deflate.so

# 缓存模块
# LoadModule cache_module modules/mod_cache.so
# LoadModule cache_disk_module modules/mod_cache_disk.so

# HTTP/2模块
# LoadModule http2_module modules/mod_http2.so

# 用户目录模块
# LoadModule userdir_module modules/mod_userdir.so
```

## 七、日志管理与监控

### 1. 日志文件说明
```bash
# 主要日志文件
/var/log/httpd/access_log     # 访问日志
/var/log/httpd/error_log      # 错误日志
/var/log/httpd/ssl_access_log # SSL访问日志
/var/log/httpd/ssl_error_log  # SSL错误日志

# 查看日志
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log

# 查看最近100行
sudo tail -n 100 /var/log/httpd/access_log

# 搜索特定内容
sudo grep "404" /var/log/httpd/access_log
sudo grep -i "error" /var/log/httpd/error_log

# 使用journalctl查看日志
sudo journalctl -u httpd -f
sudo journalctl -u httpd --since "1 hour ago"
```

### 2. 日志格式配置
```apache
# 在httpd.conf中
# Common日志格式
LogFormat "%h %l %u %t \"%r\" %>s %b" common

# Combined日志格式（推荐）
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

# 自定义日志格式
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D %{X-Forwarded-For}i" custom

# 使用自定义格式
CustomLog /var/log/httpd/access_log custom
```

### 3. 日志分析
```bash
# 统计访问最多的IP
sudo awk '{print $1}' /var/log/httpd/access_log | sort | uniq -c | sort -rn | head -20

# 统计请求的URL
sudo awk '{print $7}' /var/log/httpd/access_log | sort | uniq -c | sort -rn | head -20

# 统计HTTP状态码
sudo awk '{print $9}' /var/log/httpd/access_log | sort | uniq -c | sort -rn

# 统计User-Agent
sudo awk -F'"' '{print $6}' /var/log/httpd/access_log | sort | uniq -c | sort -rn | head -10

# 查找404错误
sudo grep " 404 " /var/log/httpd/access_log

# 查找5xx错误
sudo grep " 50[0-9] " /var/log/httpd/access_log

# 统计每小时的请求数
sudo awk '{print $4}' /var/log/httpd/access_log | cut -d: -f2 | sort | uniq -c

# 实时监控访问（彩色显示）
sudo tail -f /var/log/httpd/access_log | awk '{print "\033[1;32m"$1"\033[0m", $7, "\033[1;33m"$9"\033[0m"}'
```

### 4. 使用日志分析工具
```bash
# 安装GoAccess（实时日志分析工具）
sudo dnf install goaccess -y

# 实时终端分析
sudo goaccess /var/log/httpd/access_log -c

# 生成HTML报告
sudo goaccess /var/log/httpd/access_log -o /var/www/html/report.html --log-format=COMBINED

# 实时更新HTML报告
sudo goaccess /var/log/httpd/access_log -o /var/www/html/report.html --log-format=COMBINED --real-time-html

# 安装AWStats
sudo dnf install awstats -y

# 安装Webalizer
sudo dnf install webalizer -y
```

### 5. 日志轮换配置
```bash
# 查看当前配置
sudo cat /etc/logrotate.d/httpd

# 编辑日志轮换配置
sudo nano /etc/logrotate.d/httpd
```

**日志轮换配置示例：**
```
/var/log/httpd/*log {
    daily                    # 每日轮换
    missingok               # 日志丢失不报错
    rotate 52               # 保留52个旧日志
    compress                # 压缩旧日志
    delaycompress          # 延迟压缩（下次轮换时压缩）
    notifempty             # 空日志不轮换
    sharedscripts          # 所有日志轮换完后执行一次脚本
    postrotate
        /bin/systemctl reload httpd.service > /dev/null 2>/dev/null || true
    endscript
}
```

```bash
# 手动执行日志轮换
sudo logrotate -f /etc/logrotate.d/httpd

# 测试日志轮换（不实际执行）
sudo logrotate -d /etc/logrotate.d/httpd

# 查看日志轮换状态
sudo cat /var/lib/logrotate/logrotate.status
```

### 6. 错误日志级别
```apache
# 在httpd.conf或虚拟主机配置中设置
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
# 检查deflate模块是否加载
httpd -M | grep deflate

# 配置压缩规则
sudo nano /etc/httpd/conf.d/compression.conf
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
    
    # 压缩级别（1-9）
    DeflateCompressionLevel 6
</IfModule>
```

### 2. 配置缓存
```bash
# 检查缓存模块
httpd -M | grep cache
httpd -M | grep expires

# 配置缓存
sudo nano /etc/httpd/conf.d/cache.conf
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
    
    # 图片
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType image/x-icon "access plus 1 year"
    
    # 字体
    ExpiresByType font/woff "access plus 1 year"
    ExpiresByType font/woff2 "access plus 1 year"
    
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
    
    # 移除ETag
    Header unset ETag
    FileETag None
</IfModule>

# 磁盘缓存配置（需要mod_cache_disk）
<IfModule mod_cache_disk.c>
    CacheRoot /var/cache/httpd/cache
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
sudo mkdir -p /var/cache/httpd/cache
sudo chown -R apache:apache /var/cache/httpd/cache
sudo chmod -R 700 /var/cache/httpd/cache

# 设置SELinux上下文
sudo semanage fcontext -a -t httpd_cache_t "/var/cache/httpd/cache(/.*)?"
sudo restorecon -Rv /var/cache/httpd/cache
```

### 3. 优化MPM（多处理模块）
```bash
# 查看当前使用的MPM
httpd -V | grep -i mpm

# 可用的MPM模块
# - prefork: 多进程，每个进程一个线程（兼容性最好）
# - worker: 多进程多线程
# - event: 类似worker，性能更好（推荐）

# 切换MPM
sudo nano /etc/httpd/conf.modules.d/00-mpm.conf
```

**MPM配置文件：**
```apache
# 注释掉当前MPM，取消注释目标MPM
# LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
# LoadModule mpm_worker_module modules/mod_mpm_worker.so
LoadModule mpm_event_module modules/mod_mpm_event.so
```

**Event MPM配置优化：**
```apache
# /etc/httpd/conf.d/mpm.conf
<IfModule mpm_event_module>
    StartServers             2      # 启动时的进程数
    MinSpareThreads          25     # 最小空闲线程数
    MaxSpareThreads          75     # 最大空闲线程数
    ThreadsPerChild          25     # 每个子进程的线程数
    MaxRequestWorkers        150    # 最大并发请求数
    MaxConnectionsPerChild   10000  # 子进程处理的最大请求数
</IfModule>
```

### 4. 启用HTTP/2
```bash
# 检查HTTP/2模块
httpd -M | grep http2

# 如果未安装
sudo dnf install mod_http2 -y

# 在SSL虚拟主机中启用
sudo nano /etc/httpd/conf.d/ssl.conf

# 添加以下行（在<VirtualHost>内）
Protocols h2 http/1.1

# 重启httpd
sudo systemctl restart httpd

# 测试HTTP/2
curl -I --http2 https://localhost
```

### 5. KeepAlive优化
```bash
sudo nano /etc/httpd/conf/httpd.conf
```

```apache
# 启用持久连接
KeepAlive On

# 持久连接的最大请求数
MaxKeepAliveRequests 100

# 持久连接超时时间（秒）
KeepAliveTimeout 5
```

### 6. 资源限制配置
```apache
# 在httpd.conf中配置
Timeout 60
KeepAliveTimeout 5
MaxKeepAliveRequests 100

# 限制请求大小
LimitRequestBody 10485760
LimitRequestFields 100
LimitRequestFieldSize 8190
LimitRequestLine 8190
```

## 九、故障排查

### 1. 配置测试命令
```bash
# 测试配置文件语法
sudo httpd -t
sudo apachectl configtest

# 显示编译的设置
httpd -V

# 显示已加载的模块
httpd -M

# 显示虚拟主机配置
httpd -S

# 显示MPM设置
httpd -V | grep -i mpm

# 完整配置转储
httpd -t -D DUMP_VHOSTS
httpd -t -D DUMP_RUN_CFG
```

### 2. 端口和进程检查
```bash
# 检查httpd是否运行
sudo systemctl status httpd
ps aux | grep httpd

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

### 3. 权限和SELinux问题排查
```bash
# 检查文件权限
ls -la /var/www/html

# 正确的权限设置
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# 检查SELinux状态
getenforce
sestatus

# 查看SELinux上下文
ls -Z /var/www/html

# 恢复正确的SELinux上下文
sudo restorecon -Rv /var/www/html

# 设置新目录的SELinux上下文
sudo semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"
sudo restorecon -Rv /web

# 临时禁用SELinux测试（不推荐）
sudo setenforce 0

# 查看SELinux拒绝日志
sudo ausearch -m avc -ts recent
sudo grep "SELinux is preventing" /var/log/audit/audit.log

# 生成SELinux策略
sudo audit2allow -a
sudo audit2allow -a -M mypolicy
sudo semodule -i mypolicy.pp
```

### 4. 日志实时监控
```bash
# 同时监控访问和错误日志
sudo tail -f /var/log/httpd/access_log /var/log/httpd/error_log

# 使用journalctl监控
sudo journalctl -u httpd -f
sudo journalctl -u httpd --since "10 minutes ago"
sudo journalctl -u httpd --priority=err

# 过滤特定错误
sudo tail -f /var/log/httpd/error_log | grep -i "error\|warning"
```

### 5. 常见问题及解决方案

**问题1：httpd无法启动**
```bash
# 检查详细错误信息
sudo systemctl status httpd -l
sudo journalctl -xe -u httpd

# 测试配置
sudo httpd -t

# 检查端口冲突
sudo netstat -tlnp | grep :80

# 查看错误日志
sudo tail -50 /var/log/httpd/error_log

# 检查SELinux
sudo ausearch -m avc -ts recent
```

**问题2：403 Forbidden错误**
```bash
# 检查目录权限
ls -la /var/www/html

# 检查SELinux上下文
ls -Z /var/www/html

# 恢复SELinux上下文
sudo restorecon -Rv /var/www/html

# 确保目录有正确的权限
sudo chmod 755 /var/www/html
sudo chown -R apache:apache /var/www/html

# 检查httpd配置
sudo grep -r "Require" /etc/httpd/

# 检查SELinux布尔值
getsebool -a | grep httpd
sudo setsebool -P httpd_read_user_content on
```

**问题3：PHP不工作**
```bash
# 检查PHP模块是否加载
httpd -M | grep php

# 重新安装PHP模块
sudo dnf reinstall php

# 检查PHP配置
php -v
php -m

# 查看PHP错误日志
sudo tail -f /var/log/php_errors.log

# 重启httpd
sudo systemctl restart httpd
```

**问题4：SELinux阻止httpd网络连接**
```bash
# 检查SELinux日志
sudo ausearch -m avc -ts recent | grep httpd

# 允许httpd网络连接
sudo setsebool -P httpd_can_network_connect on

# 允许httpd连接数据库
sudo setsebool -P httpd_can_network_connect_db on
```

**问题5：防火墙阻止访问**
```bash
# 检查防火墙状态
sudo firewall-cmd --state

# 查看已开放的服务
sudo firewall-cmd --list-all

# 开放HTTP和HTTPS
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# 或开放特定端口
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload
```

### 6. 性能诊断
```bash
# 使用Apache Bench测试性能
ab -n 1000 -c 10 http://localhost/

# 参数说明：
# -n: 总请求数
# -c: 并发数
# -t: 测试时间（秒）

# 查看Apache进程资源使用
ps aux | grep httpd | awk '{sum+=$6} END {print "Total Memory (KB): " sum}'

# 使用top监控
top -p $(pgrep -d',' httpd)

# 使用htop（更友好）
sudo dnf install htop -y
htop -p $(pgrep -d',' httpd)
```

## 十、openEuler特有功能

### 1. 使用systemd管理
```bash
# 查看服务状态
sudo systemctl status httpd

# 查看服务启动失败原因
sudo systemctl --failed
sudo journalctl -xeu httpd

# 查看服务依赖关系
sudo systemctl list-dependencies httpd

# 创建systemd drop-in配置
sudo mkdir -p /etc/systemd/system/httpd.service.d/
sudo nano /etc/systemd/system/httpd.service.d/custom.conf
```

**systemd自定义配置示例：**
```ini
[Service]
# 限制内存使用
MemoryLimit=2G

# 限制CPU使用
CPUQuota=50%

# 自动重启策略
Restart=on-failure
RestartSec=10s

# 启动超时时间
TimeoutStartSec=90s

# 进程数限制
LimitNPROC=512

# 文件描述符限制
LimitNOFILE=65535
```

```bash
# 重载systemd配置
sudo systemctl daemon-reload

# 重启服务使配置生效
sudo systemctl restart httpd
```

### 2. 使用dnf模块流管理
```bash
# 查看可用的httpd模块流
dnf module list httpd

# 启用特定版本的httpd
sudo dnf module enable httpd:2.4

# 安装指定模块流
sudo dnf module install httpd:2.4/common

# 查看已启用的模块流
dnf module list --enabled

# 切换模块流（先重置）
sudo dnf module reset httpd
sudo dnf module enable httpd:2.4
sudo dnf module install httpd:2.4

# 查看模块流信息
dnf module info httpd:2.4
```

### 3. RPM包管理技巧
```bash
# 查看httpd包信息
rpm -qi httpd

# 列出httpd包的所有文件
rpm -ql httpd

# 查找文件属于哪个包
rpm -qf /etc/httpd/conf/httpd.conf

# 验证包完整性
rpm -V httpd

# 查看包的依赖关系
rpm -qR httpd

# 查看包的变更日志
rpm -q --changelog httpd | head -20

# 查找相关的httpd包
dnf search httpd

# 查看包组信息
dnf group info "Web Server"

# 安装Web服务器包组
sudo dnf group install "Web Server"
```

### 4. 使用openEuler仓库
```bash
# 查看当前仓库列表
dnf repolist

# 添加EPEL仓库（扩展包）
sudo dnf install epel-release -y

# 添加Remi仓库（PHP等）
sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-$(rpm -E %{rhel}).rpm -y

# 清理缓存
sudo dnf clean all

# 更新缓存
sudo dnf makecache

# 搜索特定包
dnf search mod_security

# 查看包的可用版本
dnf --showduplicates list httpd
```

### 5. 性能调优（openEuler特定）
```bash
# 调整系统参数
sudo nano /etc/sysctl.conf
```

```ini
# 网络性能优化
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.ip_local_port_range = 1024 65535

# 文件系统优化
fs.file-max = 2097152
fs.nr_open = 2097152

# 虚拟内存优化
vm.swappiness = 10
```

```bash
# 应用系统参数
sudo sysctl -p

# 调整文件描述符限制
sudo nano /etc/security/limits.conf
```

```
apache soft nofile 65535
apache hard nofile 65535
apache soft nproc 65535
apache hard nproc 65535
```

```bash
# 针对httpd服务调整限制
sudo nano /etc/systemd/system/httpd.service.d/limits.conf
```

```ini
[Service]
LimitNOFILE=65535
LimitNPROC=65535
```

```bash
# 重载配置
sudo systemctl daemon-reload
sudo systemctl restart httpd
```

## 十一、高级配置

### 1. 配置高可用集群（使用Keepalived）
```bash
# 安装Keepalived
sudo dnf install keepalived -y

# 配置Keepalived
sudo nano /etc/keepalived/keepalived.conf
```

**主服务器配置：**
```
vrrp_script check_httpd {
    script "/usr/bin/systemctl is-active httpd"
    interval 2
    weight 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    
    authentication {
        auth_type PASS
        auth_pass 1234
    }
    
    virtual_ipaddress {
        192.168.1.100/24
    }
    
    track_script {
        check_httpd
    }
}
```

**备份服务器配置：**
```
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 90
    advert_int 1
    
    authentication {
        auth_type PASS
        auth_pass 1234
    }
    
    virtual_ipaddress {
        192.168.1.100/24
    }
}
```

```bash
# 启动Keepalived
sudo systemctl start keepalived
sudo systemctl enable keepalived

# 查看VIP是否生效
ip addr show eth0
```

### 2. 配置ModSecurity WAF
```bash
# 安装ModSecurity
sudo dnf install mod_security mod_security_crs -y

# 配置ModSecurity
sudo nano /etc/httpd/conf.d/mod_security.conf
```

```apache
<IfModule mod_security2.c>
    # 启用ModSecurity
    SecRuleEngine On
    
    # 请求体处理
    SecRequestBodyAccess On
    SecRequestBodyLimit 13107200
    SecRequestBodyNoFilesLimit 131072
    
    # 响应体处理
    SecResponseBodyAccess On
    SecResponseBodyMimeType text/plain text/html text/xml
    SecResponseBodyLimit 524288
    
    # 调试日志
    SecDebugLog /var/log/httpd/modsec_debug.log
    SecDebugLogLevel 0
    
    # 审计日志
    SecAuditEngine RelevantOnly
    SecAuditLogRelevantStatus "^(?:5|4(?!04))"
    SecAuditLogParts ABIJDEFHZ
    SecAuditLogType Serial
    SecAuditLog /var/log/httpd/modsec_audit.log
    
    # 临时目录
    SecTmpDir /var/lib/mod_security
    SecDataDir /var/lib/mod_security
    
    # 包含OWASP核心规则集
    IncludeOptional /etc/httpd/modsecurity.d/*.conf
    IncludeOptional /etc/httpd/modsecurity.d/activated_rules/*.conf
</IfModule>
```

```bash
# 创建必要的目录
sudo mkdir -p /var/lib/mod_security
sudo chown apache:apache /var/lib/mod_security

# 设置SELinux上下文
sudo semanage fcontext -a -t httpd_var_lib_t "/var/lib/mod_security(/.*)?"
sudo restorecon -Rv /var/lib/mod_security

# 重启httpd
sudo systemctl restart httpd
```

### 3. 配置负载均衡（使用HAProxy）
```bash
# 安装HAProxy
sudo dnf install haproxy -y

# 配置HAProxy
sudo nano /etc/haproxy/haproxy.cfg
```

```
global
    log /dev/log local0
    chroot /var/lib/haproxy
    user haproxy
    group haproxy
    daemon

defaults
    mode http
    log global
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend http_front
    bind *:80
    stats uri /haproxy?stats
    default_backend http_back

backend http_back
    balance roundrobin
    server web1 192.168.1.101:80 check
    server web2 192.168.1.102:80 check
    server web3 192.168.1.103:80 check
```

```bash
# 启动HAProxy
sudo systemctl start haproxy
sudo systemctl enable haproxy

# 配置SELinux
sudo setsebool -P haproxy_connect_any on
```

### 4. 配置WebSocket支持
```bash
# 确保代理模块已加载
httpd -M | grep proxy_wstunnel

# 配置WebSocket代理
sudo nano /etc/httpd/conf.d/websocket.conf
```

```apache
<VirtualHost *:80>
    ServerName ws.example.com
    
    # WebSocket代理
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} =websocket [NC]
    RewriteRule /(.*)           ws://localhost:3000/$1 [P,L]
    RewriteCond %{HTTP:Upgrade} !=websocket [NC]
    RewriteRule /(.*)           http://localhost:3000/$1 [P,L]
    
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
    
    # WebSocket特定配置
    ProxyTimeout 3600
    ProxyRequests Off
</VirtualHost>
```

### 5. 配置容器化部署
```bash
# 安装Docker
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker

# 创建Dockerfile
cat > Dockerfile << 'EOF'
FROM openeuler/openeuler:latest

# 安装httpd
RUN dnf install -y httpd && \
    dnf clean all

# 复制配置文件
COPY httpd.conf /etc/httpd/conf/httpd.conf
COPY index.html /var/www/html/

# 暴露端口
EXPOSE 80

# 启动httpd
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
EOF

# 构建镜像
sudo docker build -t my-httpd .

# 运行容器
sudo docker run -d -p 80:80 --name web-server my-httpd

# 查看容器日志
sudo docker logs -f web-server
```

**使用docker-compose：**
```yaml
# docker-compose.yml
version: '3'
services:
  web:
    image: openeuler/openeuler:latest
    container_name: httpd-server
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./html:/var/www/html
      - ./conf:/etc/httpd/conf.d
      - ./logs:/var/log/httpd
    command: >
      bash -c "dnf install -y httpd mod_ssl &&
               httpd -D FOREGROUND"
    restart: unless-stopped
```

```bash
# 启动服务
sudo docker-compose up -d

# 查看日志
sudo docker-compose logs -f
```

## 十二、安全加固清单

### openEuler生产环境安全检查表

```bash
# 1. 系统更新
sudo dnf update -y

# 2. 最小化安装
httpd -M  # 检查已启用模块
# 禁用不需要的模块

# 3. 配置防火墙
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# 4. 配置SELinux
sudo setsebool -P httpd_can_network_connect on
sudo setsebool -P httpd_read_user_content on

# 5. 隐藏版本信息
# ServerTokens Prod
# ServerSignature Off

# 6. 禁用目录浏览
# Options -Indexes

# 7. 限制HTTP方法
# <LimitExcept GET POST>
#     Require all denied
# </LimitExcept>

# 8. 配置SSL/TLS
# 使用强加密套件和TLS 1.2+

# 9. 实施访问控制
# 使用IP白名单、认证等

# 10. 定期备份配置
sudo tar -czf httpd-config-$(date +%Y%m%d).tar.gz /etc/httpd/

# 11. 监控日志
sudo journalctl -u httpd -f

# 12. 使用ModSecurity
sudo dnf install mod_security mod_security_crs -y

# 13. 限制上传文件大小
# LimitRequestBody 10485760

# 14. 配置适当的文件权限
sudo find /var/www -type f -exec chmod 644 {} \;
sudo find /var/www -type d -exec chmod 755 {} \;
sudo chown -R apache:apache /var/www

# 15. 禁用不安全的PHP函数
# disable_functions = exec,passthru,shell_exec...

# 16. 定期安全审计
sudo dnf install aide -y
sudo aide --init
```

### 安全加固脚本
```bash
#!/bin/bash
# httpd-hardening.sh - openEuler httpd安全加固脚本

echo "开始httpd安全加固..."

# 1. 更新系统
echo "1. 更新系统..."
sudo dnf update -y

# 2. 隐藏版本信息
echo "2. 配置安全设置..."
if ! grep -q "ServerTokens Prod" /etc/httpd/conf/httpd.conf; then
    echo "ServerTokens Prod" | sudo tee -a /etc/httpd/conf/httpd.conf
fi
if ! grep -q "ServerSignature Off" /etc/httpd/conf/httpd.conf; then
    echo "ServerSignature Off" | sudo tee -a /etc/httpd/conf/httpd.conf
fi
if ! grep -q "TraceEnable Off" /etc/httpd/conf/httpd.conf; then
    echo "TraceEnable Off" | sudo tee -a /etc/httpd/conf/httpd.conf
fi

# 3. 设置正确的文件权限
echo "3. 设置文件权限..."
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# 4. 配置SELinux
echo "4. 配置SELinux..."
sudo setsebool -P httpd_can_network_connect on
sudo restorecon -Rv /var/www/html

# 5. 配置防火墙
echo "5. 配置防火墙..."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# 6. 备份配置
echo "6. 备份配置..."
BACKUP_DIR="/backup/httpd"
sudo mkdir -p $BACKUP_DIR
sudo tar -czf $BACKUP_DIR/httpd-config-$(date +%Y%m%d-%H%M%S).tar.gz /etc/httpd/

# 7. 重启httpd
echo "7. 重启httpd..."
sudo systemctl restart httpd

echo "安全加固完成！"
```

## 十三、备份与恢复

### 1. 完整备份脚本
```bash
#!/bin/bash
# backup-httpd.sh - openEuler httpd完整备份脚本

BACKUP_DIR="/backup/httpd"
DATE=$(date +%Y%m%d-%H%M%S)
HOSTNAME=$(hostname)

# 创建备份目录
mkdir -p $BACKUP_DIR

echo "开始备份httpd配置和数据..."

# 备份配置文件
echo "备份配置文件..."
sudo tar -czf $BACKUP_DIR/httpd-config-$HOSTNAME-$DATE.tar.gz \
    /etc/httpd/ \
    /etc/pki/tls/

# 备份网站文件
echo "备份网站文件..."
sudo tar -czf $BACKUP_DIR/httpd-www-$HOSTNAME-$DATE.tar.gz \
    /var/www/

# 备份日志（可选）
echo "备份日志..."
sudo tar -czf $BACKUP_DIR/httpd-logs-$HOSTNAME-$DATE.tar.gz \
    /var/log/httpd/

# 创建备份信息文件
cat > $BACKUP_DIR/backup-info-$DATE.txt << EOF
备份时间: $(date)
主机名: $HOSTNAME
httpd版本: $(httpd -v | head -1)
操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
备份文件:
- httpd-config-$HOSTNAME-$DATE.tar.gz
- httpd-www-$HOSTNAME-$DATE.tar.gz
- httpd-logs-$HOSTNAME-$DATE.tar.gz
EOF

# 删除30天前的备份
echo "清理旧备份..."
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

# 显示备份信息
echo ""
echo "备份完成！"
echo "备份位置: $BACKUP_DIR"
ls -lh $BACKUP_DIR/*$DATE*

# 可选：上传到远程服务器
# rsync -avz $BACKUP_DIR/ user@backup-server:/backups/httpd/
```

### 2. 恢复脚本
```bash
#!/bin/bash
# restore-httpd.sh - httpd恢复脚本

if [ $# -eq 0 ]; then
    echo "用法: $0 <备份文件日期，如: 20241117-143000>"
    exit 1
fi

BACKUP_DATE=$1
BACKUP_DIR="/backup/httpd"

echo "警告：此操作将覆盖当前配置！"
read -p "确认恢复备份 $BACKUP_DATE？(yes/no) " confirm

if [ "$confirm" != "yes" ]; then
    echo "操作已取消"
    exit 0
fi

# 停止httpd服务
echo "停止httpd服务..."
sudo systemctl stop httpd

# 备份当前配置（以防万一）
echo "备份当前配置..."
sudo tar -czf /tmp/httpd-current-$(date +%Y%m%d-%H%M%S).tar.gz /etc/httpd/ /var/www/

# 恢复配置文件
echo "恢复配置文件..."
sudo tar -xzf $BACKUP_DIR/httpd-config-*-$BACKUP_DATE.tar.gz -C /

# 恢复网站文件
echo "恢复网站文件..."
sudo tar -xzf $BACKUP_DIR/httpd-www-*-$BACKUP_DATE.tar.gz -C /

# 恢复SELinux上下文
echo "恢复SELinux上下文..."
sudo restorecon -Rv /etc/httpd/
sudo restorecon -Rv /var/www/

# 测试配置
echo "测试配置..."
sudo httpd -t

if [ $? -eq 0 ]; then
    # 启动httpd服务
    echo "启动httpd服务..."
    sudo systemctl start httpd
    echo "恢复完成！"
else
    echo "配置测试失败！请检查配置文件。"
    exit 1
fi
```

### 3. 自动备份配置
```bash
# 创建备份脚本
sudo nano /usr/local/bin/httpd-backup.sh
# 粘贴上面的备份脚本内容

# 设置执行权限
sudo chmod +x /usr/local/bin/httpd-backup.sh

# 创建systemd定时器
sudo nano /etc/systemd/system/httpd-backup.service
```

```ini
[Unit]
Description=httpd Backup Service
After=httpd.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/httpd-backup.sh
User=root
```

```bash
# 创建定时器配置
sudo nano /etc/systemd/system/httpd-backup.timer
```

```ini
[Unit]
Description=httpd Backup Timer
Requires=httpd-backup.service

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
# 启用并启动定时器
sudo systemctl daemon-reload
sudo systemctl enable httpd-backup.timer
sudo systemctl start httpd-backup.timer

# 查看定时器状态
sudo systemctl list-timers
sudo systemctl status httpd-backup.timer
```

## 十四、监控与告警

### 1. 使用Prometheus监控
```bash
# 安装Apache Exporter
wget https://github.com/Lusitaniae/apache_exporter/releases/download/v0.11.0/apache_exporter-0.11.0.linux-amd64.tar.gz
tar -xzf apache_exporter-0.11.0.linux-amd64.tar.gz
sudo cp apache_exporter-0.11.0.linux-amd64/apache_exporter /usr/local/bin/

# 启用server-status
sudo nano /etc/httpd/conf.d/status.conf
```

```apache
<Location /server-status>
    SetHandler server-status
    Require local
    Require ip 127.0.0.1
</Location>

ExtendedStatus On
```

```bash
# 创建systemd服务
sudo nano /etc/systemd/system/apache-exporter.service
```

```ini
[Unit]
Description=Apache Exporter
After=network.target

[Service]
Type=simple
User=apache
ExecStart=/usr/local/bin/apache_exporter --scrape_uri=http://localhost/server-status/?auto
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

```bash
# 启动exporter
sudo systemctl daemon-reload
sudo systemctl start apache-exporter
sudo systemctl enable apache-exporter

# 测试metrics
curl http://localhost:9117/metrics
```

### 2. 日志监控脚本
```bash
#!/bin/bash
# monitor-httpd.sh - httpd监控脚本

LOG_FILE="/var/log/httpd/access_log"
ERROR_LOG="/var/log/httpd/error_log"
ALERT_EMAIL="admin@example.com"
THRESHOLD=100  # 每分钟请求数阈值

# 检查httpd服务状态
if ! systemctl is-active --quiet httpd; then
    echo "httpd服务未运行！" | mail -s "httpd Alert" $ALERT_EMAIL
    exit 1
fi

# 统计最近1分钟的请求数
REQUESTS=$(tail -n 1000 $LOG_FILE | grep "$(date -d '1 minute ago' '+%d/%b/%Y:%H:%M')" | wc -l)

if [ $REQUESTS -gt $THRESHOLD ]; then
    echo "请求数异常：最近1分钟有 $REQUESTS 个请求" | mail -s "httpd High Traffic Alert" $ALERT_EMAIL
fi

# 检查错误日志
ERRORS=$(tail -n 100 $ERROR_LOG | grep -c "$(date '+%Y-%m-%d')")

if [ $ERRORS -gt 50 ]; then
    echo "错误日志异常：今天有 $ERRORS 个错误" | mail -s "httpd Error Alert" $ALERT_EMAIL
fi

# 检查磁盘空间
DISK_USAGE=$(df -h /var/www | awk 'NR==2 {print $5}' | sed 's/%//')

if [ $DISK_USAGE -gt 80 ]; then
    echo "磁盘空间不足：当前使用 $DISK_USAGE%" | mail -s "httpd Disk Alert" $ALERT_EMAIL
fi
```

### 3. 性能监控
```bash
# 创建性能监控脚本
cat > /usr/local/bin/httpd-perf-monitor.sh << 'EOF'
#!/bin/bash

echo "========== httpd性能监控 =========="
echo "时间: $(date)"
echo ""

echo "--- 服务状态 ---"
systemctl status httpd | head -5
echo ""

echo "--- 进程数 ---"
ps aux | grep httpd | wc -l
echo ""

echo "--- 内存使用 ---"
ps aux | grep httpd | awk '{sum+=$6} END {print "总计: " sum/1024 " MB"}'
echo ""

echo "--- 连接数 ---"
ss -ant | grep :80 | wc -l
echo ""

echo "--- 最近访问统计 ---"
tail -n 1000 /var/log/httpd/access_log | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
echo ""

echo "--- 状态码统计 ---"
tail -n 1000 /var/log/httpd/access_log | awk '{print $9}' | sort | uniq -c | sort -rn
echo ""
EOF

chmod +x /usr/local/bin/httpd-perf-monitor.sh

# 定期执行
echo "*/5 * * * * /usr/local/bin/httpd-perf-monitor.sh >> /var/log/httpd-perf.log 2>&1" | sudo crontab -
```

## 十五、常见应用场景示例

### 1. WordPress部署
```bash
# 安装必要软件
sudo dnf install httpd php php-mysqlnd mariadb-server -y

# 启动服务
sudo systemctl start httpd mariadb
sudo systemctl enable httpd mariadb

# 安全配置MariaDB
sudo mysql_secure_installation

# 创建WordPress数据库
sudo mysql -u root -p << EOF
CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# 下载WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/

# 配置WordPress
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo nano wp-config.php
# 修改数据库配置

# 设置权限
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# SELinux配置
sudo setsebool -P httpd_can_network_connect_db on
sudo restorecon -Rv /var/www/html

# 访问 http://your-server/wp-admin/install.php
```

### 2. 反向代理Node.js应用
```apache
# /etc/httpd/conf.d/nodejs-app.conf
<VirtualHost *:80>
    ServerName app.example.com
    
    ProxyPreserveHost On
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
    
    # WebSocket支持
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} =websocket [NC]
    RewriteRule /(.*)           ws://localhost:3000/$1 [P,L]
    
    ErrorLog /var/log/httpd/nodejs-error.log
    CustomLog /var/log/httpd/nodejs-access.log combined
</VirtualHost>
```

### 3. 静态文件CDN
```apache
# /etc/httpd/conf.d/cdn.conf
<VirtualHost *:80>
    ServerName cdn.example.com
    DocumentRoot /var/www/cdn
    
    <Directory /var/www/cdn>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
        
        # 启用压缩
        <IfModule mod_deflate.c>
            AddOutputFilterByType DEFLATE text/css application/javascript image/svg+xml
        </IfModule>
        
        # 长期缓存
        <IfModule mod_expires.c>
            ExpiresActive On
            ExpiresDefault "access plus 1 year"
        </IfModule>
        
        # 添加CORS头
        <IfModule mod_headers.c>
            Header set Access-Control-Allow-Origin "*"
        </IfModule>
    </Directory>
</VirtualHost>
```

## 十六、迁移指南

### 从Debian/Ubuntu迁移到openEuler

```bash
# 1. 备份原系统配置
# 在Debian/Ubuntu上执行
sudo tar -czf apache-debian-backup.tar.gz /etc/apache2/ /var/www/

# 2. 在openEuler上安装httpd
sudo dnf install httpd -y

# 3. 转换配置文件（手动调整）
# - Apache2 -> httpd
# - /etc/apache2/ -> /etc/httpd/
# - www-data -> apache
# - sites-available -> conf.d

# 4. 迁移虚拟主机配置
# 将 /etc/apache2/sites-available/*.conf 复制到 /etc/httpd/conf.d/
# 并修改以下内容：
# - 用户/组：www-data -> apache
# - 日志路径：/var/log/apache2/ -> /var/log/httpd/
# - 模块路径：如有必要调整

# 5. 迁移网站文件
sudo rsync -avz /var/www/ root@openeuler-server:/var/www/

# 6. 调整权限和SELinux
sudo chown -R apache:apache /var/www/
sudo restorecon -Rv /var/www/

# 7. 迁移SSL证书
sudo rsync -avz /etc/ssl/ root@openeuler-server:/etc/pki/tls/

# 8. 测试配置
sudo httpd -t

# 9. 启动服务
sudo systemctl start httpd
```

**配置转换对照表：**

| Debian/Ubuntu | openEuler |
|---------------|-----------|
| /etc/apache2/apache2.conf | /etc/httpd/conf/httpd.conf |
| /etc/apache2/sites-available/ | /etc/httpd/conf.d/ |
| /etc/apache2/mods-available/ | /etc/httpd/conf.modules.d/ |
| /var/log/apache2/ | /var/log/httpd/ |
| www-data | apache |
| a2ensite/a2dissite | 直接编辑 conf.d/ |
| a2enmod/a2dismod | 编辑 conf.modules.d/ |

### 配置文件转换脚本
```bash
#!/bin/bash
# convert-apache-config.sh - 转换Apache配置到httpd

SOURCE_DIR="/tmp/apache2-backup/etc/apache2"
DEST_DIR="/etc/httpd"

echo "开始转换配置..."

# 转换虚拟主机配置
for file in $SOURCE_DIR/sites-available/*.conf; do
    filename=$(basename "$file")
    echo "转换 $filename..."
    
    sed -e 's/www-data/apache/g' \
        -e 's|/var/log/apache2/|/var/log/httpd/|g' \
        -e 's|/etc/apache2/|/etc/httpd/|g' \
        "$file" > "$DEST_DIR/conf.d/$filename"
done

echo "配置转换完成！请手动检查并调整配置。"
```

## 十七、问题诊断工具集

### 1. 综合诊断脚本
```bash
#!/bin/bash
# httpd-diagnosis.sh - httpd综合诊断工具

echo "========================================="
echo "httpd诊断工具 - openEuler"
echo "========================================="
echo ""

# 1. 基本信息
echo "=== 1. 基本信息 ==="
echo "操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "httpd版本: $(httpd -v | head -1)"
echo "当前时间: $(date)"
echo ""

# 2. 服务状态
echo "=== 2. 服务状态 ==="
systemctl status httpd --no-pager | head -10
echo ""

# 3. 进程信息
echo "=== 3. 进程信息 ==="
ps aux | grep httpd | grep -v grep
echo ""
echo "进程总数: $(ps aux | grep httpd | grep -v grep | wc -l)"
echo ""

# 4. 端口监听
echo "=== 4. 端口监听 ==="
ss -tlnp | grep httpd
echo ""

# 5. 配置测试
echo "=== 5. 配置测试 ==="
httpd -t 2>&1
echo ""

# 6. 已加载模块
echo "=== 6. 已加载模块（前20个）==="
httpd -M | head -20
echo ""

# 7. 虚拟主机配置
echo "=== 7. 虚拟主机配置 ==="
httpd -S 2>&1 | head -20
echo ""

# 8. 最近错误日志
echo "=== 8. 最近错误日志（最后10行）==="
tail -10 /var/log/httpd/error_log
echo ""

# 9. 连接统计
echo "=== 9. 当前连接统计 ==="
ss -ant | grep :80 | wc -l
echo "HTTP连接数: $(ss -ant | grep :80 | wc -l)"
echo "HTTPS连接数: $(ss -ant | grep :443 | wc -l)"
echo ""

# 10. 资源使用
echo "=== 10. 资源使用 ==="
echo "内存使用: $(ps aux | grep httpd | awk '{sum+=$6} END {print sum/1024 " MB"}')"
echo "CPU使用: $(ps aux | grep httpd | awk '{sum+=$3} END {print sum "%"}')"
echo ""

# 11. 磁盘空间
echo "=== 11. 磁盘空间 ==="
df -h /var/www /var/log/httpd
echo ""

# 12. SELinux状态
echo "=== 12. SELinux状态 ==="
echo "SELinux模式: $(getenforce)"
echo "最近SELinux拒绝（最后5条）:"
ausearch -m avc -ts recent 2>/dev/null | grep httpd | tail -5
echo ""

# 13. 防火墙状态
echo "=== 13. 防火墙状态 ==="
firewall-cmd --list-services 2>/dev/null
echo ""

# 14. 文件权限检查
echo "=== 14. 文件权限检查 ==="
ls -la /var/www/html/ | head -10
echo ""

# 15. 最近访问统计
echo "=== 15. 最近访问统计（前10个IP）==="
tail -1000 /var/log/httpd/access_log 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
echo ""

echo "========================================="
echo "诊断完成"
echo "========================================="
```

### 2. 性能测试工具
```bash
#!/bin/bash
# httpd-benchmark.sh - httpd性能基准测试

URL="http://localhost"
CONCURRENCY=10
REQUESTS=1000

echo "========================================="
echo "httpd性能基准测试"
echo "========================================="
echo "测试URL: $URL"
echo "并发数: $CONCURRENCY"
echo "请求数: $REQUESTS"
echo ""

# 使用ab进行测试
echo "开始测试..."
ab -n $REQUESTS -c $CONCURRENCY $URL/ > /tmp/ab-result.txt 2>&1

# 解析结果
echo ""
echo "=== 测试结果 ==="
grep "Requests per second" /tmp/ab-result.txt
grep "Time per request" /tmp/ab-result.txt
grep "Transfer rate" /tmp/ab-result.txt
grep "Failed requests" /tmp/ab-result.txt

echo ""
echo "=== 连接时间分布 ==="
grep -A 5 "Connection Times" /tmp/ab-result.txt

echo ""
echo "=== 百分位延迟 ==="
grep -A 10 "Percentage of the requests" /tmp/ab-result.txt

echo ""
echo "完整结果保存在: /tmp/ab-result.txt"
```

## 十八、最佳实践总结

### 1. 配置文件组织
```bash
/etc/httpd/
├── conf/
│   └── httpd.conf                    # 仅全局配置
├── conf.d/
│   ├── 00-security.conf             # 安全配置
│   ├── 10-performance.conf          # 性能配置
│   ├── 20-site1.example.com.conf   # 站点配置
│   └── 21-site2.example.com.conf   # 站点配置
└── conf.modules.d/
    └── *.conf                        # 模块配置
```

### 2. 命名约定
```
# 虚拟主机配置文件命名
[priority]-[domain].conf

示例：
10-mainsite.com.conf
20-api.example.com.conf
30-cdn.example.com.conf

# 使用数字前缀控制加载顺序
00-99: 系统配置
10-19: 主站点
20-29: 子站点
30-39: API/服务
40-49: 特殊用途
```

### 3. 安全检查清单
```bash
# 定期执行的安全检查
cat > /usr/local/bin/httpd-security-check.sh << 'EOF'
#!/bin/bash

echo "=== httpd安全检查 ==="
echo ""

# 1. 检查版本信息是否隐藏
echo "1. 检查ServerTokens和ServerSignature..."
grep -r "ServerTokens\|ServerSignature" /etc/httpd/conf* | grep -v "^#"

# 2. 检查目录浏览是否禁用
echo ""
echo "2. 检查Indexes选项..."
grep -r "Options.*Indexes" /etc/httpd/conf* | grep -v "^#"

# 3. 检查HTTP方法限制
echo ""
echo "3. 检查HTTP方法限制..."
grep -r "LimitExcept" /etc/httpd/conf* | grep -v "^#"

# 4. 检查文件权限
echo ""
echo "4. 检查关键文件权限..."
ls -l /etc/httpd/conf/httpd.conf
ls -l /etc/pki/tls/private/*.key 2>/dev/null

# 5. 检查SELinux上下文
echo ""
echo "5. 检查SELinux上下文..."
ls -Z /var/www/html/ | head -5

# 6. 检查SSL配置
echo ""
echo "6. 检查SSL协议配置..."
grep -r "SSLProtocol" /etc/httpd/conf* | grep -v "^#"

# 7. 检查防火墙规则
echo ""
echo "7. 检查防火墙规则..."
firewall-cmd --list-services

# 8. 检查最近的错误
echo ""
echo "8. 最近的错误（最后5条）..."
tail -5 /var/log/httpd/error_log

EOF

chmod +x /usr/local/bin/httpd-security-check.sh
```

### 4. 性能优化检查清单
```bash
cat > /usr/local/bin/httpd-perf-check.sh << 'EOF'
#!/bin/bash

echo "=== httpd性能优化检查 ==="
echo ""

# 1. 检查MPM配置
echo "1. 当前MPM模式..."
httpd -V | grep -i mpm

# 2. 检查KeepAlive设置
echo ""
echo "2. KeepAlive配置..."
grep -r "KeepAlive\|MaxKeepAlive" /etc/httpd/conf/httpd.conf | grep -v "^#"

# 3. 检查压缩配置
echo ""
echo "3. 压缩模块..."
httpd -M | grep deflate

# 4. 检查缓存配置
echo ""
echo "4. 缓存模块..."
httpd -M | grep cache
httpd -M | grep expires

# 5. 检查HTTP/2支持
echo ""
echo "5. HTTP/2支持..."
httpd -M | grep http2

# 6. 检查资源限制
echo ""
echo "6. 系统资源限制..."
ulimit -n
cat /etc/security/limits.conf | grep apache

# 7. 检查日志轮换
echo ""
echo "7. 日志轮换配置..."
cat /etc/logrotate.d/httpd

# 8. 当前连接数
echo ""
echo "8. 当前连接统计..."
ss -ant | grep :80 | wc -l

EOF

chmod +x /usr/local/bin/httpd-perf-check.sh
```

### 5. 日常维护任务
```bash
# 创建维护任务脚本
cat > /usr/local/bin/httpd-maintenance.sh << 'EOF'
#!/bin/bash

echo "=== httpd日常维护任务 ==="
echo "执行时间: $(date)"
echo ""

# 1. 检查服务状态
echo "1. 检查服务状态..."
if ! systemctl is-active --quiet httpd; then
    echo "警告: httpd服务未运行！"
    systemctl start httpd
fi

# 2. 清理旧日志（保留30天）
echo "2. 清理旧日志..."
find /var/log/httpd/ -name "*.log-*" -mtime +30 -delete

# 3. 检查磁盘空间
echo "3. 检查磁盘空间..."
DISK_USAGE=$(df -h /var/www | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "警告: 磁盘使用率 $DISK_USAGE%"
fi

# 4. 分析访问日志
echo "4. 今日访问统计..."
TODAY=$(date +%d/%b/%Y)
echo "今日请求数: $(grep "$TODAY" /var/log/httpd/access_log | wc -l)"
echo "今日独立IP: $(grep "$TODAY" /var/log/httpd/access_log | awk '{print $1}' | sort -u | wc -l)"

# 5. 检查错误日志
echo "5. 今日错误统计..."
TODAY_ERRORS=$(grep "$(date +%Y-%m-%d)" /var/log/httpd/error_log | wc -l)
echo "今日错误数: $TODAY_ERRORS"
if [ $TODAY_ERRORS -gt 100 ]; then
    echo "警告: 错误数量较多！"
fi

# 6. 备份配置（每周一次）
if [ $(date +%u) -eq 1 ]; then
    echo "6. 执行每周配置备份..."
    /usr/local/bin/httpd-backup.sh
fi

echo ""
echo "维护任务完成"
EOF

chmod +x /usr/local/bin/httpd-maintenance.sh

# 添加到cron（每天凌晨2点执行）
echo "0 2 * * * /usr/local/bin/httpd-maintenance.sh >> /var/log/httpd-maintenance.log 2>&1" | sudo crontab -
```

## 十九、常见问题FAQ

### Q1: httpd启动失败，提示端口已被占用
```bash
# 查找占用80端口的进程
sudo ss -tlnp | grep :80
sudo fuser 80/tcp

# 终止占用进程
sudo fuser -k 80/tcp

# 或者修改httpd监听端口
sudo nano /etc/httpd/conf/httpd.conf
# 修改: Listen 8080
```

### Q2: 403 Forbidden错误
```bash
# 检查文件权限
ls -la /var/www/html

# 检查SELinux
ls -Z /var/www/html
sudo restorecon -Rv /var/www/html

# 检查配置
sudo grep -r "Require" /etc/httpd/conf.d/

# 修复权限
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
```

### Q3: SELinux阻止httpd访问
```bash
# 查看SELinux拒绝日志
sudo ausearch -m avc -ts recent | grep httpd

# 允许httpd网络连接
sudo setsebool -P httpd_can_network_connect on

# 允许httpd读取用户内容
sudo setsebool -P httpd_read_user_content on

# 查看所有httpd相关的布尔值
getsebool -a | grep httpd
```

### Q4: PHP文件直接下载而不执行
```bash
# 检查PHP模块是否加载
httpd -M | grep php

# 重新安装PHP
sudo dnf reinstall php

# 检查配置
sudo cat /etc/httpd/conf.d/php.conf

# 重启httpd
sudo systemctl restart httpd
```

### Q5: 虚拟主机配置不生效
```bash
# 检查配置语法
sudo httpd -t

# 查看虚拟主机配置
sudo httpd -S

# 检查文件是否在conf.d目录
ls -la /etc/httpd/conf.d/

# 重启httpd
sudo systemctl restart httpd
```

### Q6: SSL证书错误
```bash
# 检查证书文件
ls -l /etc/pki/tls/certs/
ls -l /etc/pki/tls/private/

# 验证证书
sudo openssl x509 -in /etc/pki/tls/certs/localhost.crt -noout -text

# 检查证书和密钥是否匹配
openssl x509 -noout -modulus -in /etc/pki/tls/certs/cert.crt | openssl md5
openssl rsa -noout -modulus -in /etc/pki/tls/private/cert.key | openssl md5

# 测试SSL连接
openssl s_client -connect localhost:443
```

### Q7: httpd性能低下
```bash
# 检查MPM配置
httpd -V | grep -i mpm

# 调整MPM参数
sudo nano /etc/httpd/conf.d/mpm.conf

# 启用压缩
httpd -M | grep deflate

# 启用缓存
httpd -M | grep cache

# 检查系统资源
top -p $(pgrep -d',' httpd)

# 检查网络连接
ss -ant | grep :80 | wc -l
```

### Q8: 日志文件过大
```bash
# 立即轮换日志
sudo logrotate -f /etc/logrotate.d/httpd

# 手动清理（慎用）
sudo truncate -s 0 /var/log/httpd/access_log

# 调整日志轮换策略
sudo nano /etc/logrotate.d/httpd
# 改为daily并保留更少天数
```

## 二十、快速参考命令

### 常用命令速查
```bash
# === 服务管理 ===
sudo systemctl start httpd        # 启动
sudo systemctl stop httpd         # 停止
sudo systemctl restart httpd      # 重启
sudo systemctl reload httpd       # 重载配置
sudo systemctl status httpd       # 查看状态

# === 配置测试 ===
sudo httpd -t                     # 测试配置语法
sudo httpd -S                     # 显示虚拟主机配置
sudo httpd -M                     # 显示已加载模块
sudo httpd -V                     # 显示编译信息

# === 日志查看 ===
sudo tail -f /var/log/httpd/access_log     # 实时访问日志
sudo tail -f /var/log/httpd/error_log      # 实时错误日志
sudo journalctl -u httpd -f                # systemd日志

# === 防火墙 ===
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload

# === SELinux ===
sudo setsebool -P httpd_can_network_connect on
sudo restorecon -Rv /var/www/html
sudo ausearch -m avc -ts recent | grep httpd

# === 权限修复 ===
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# === 性能测试 ===
ab -n 1000 -c 10 http://localhost/

# === 备份恢复 ===
sudo tar -czf httpd-backup.tar.gz /etc/httpd/ /var/www/
sudo tar -xzf httpd-backup.tar.gz -C /
```

### 配置文件位置速查
```bash
# 主配置
/etc/httpd/conf/httpd.conf

# 模块配置
/etc/httpd/conf.modules.d/

# 站点配置
/etc/httpd/conf.d/

# SSL配置
/etc/httpd/conf.d/ssl.conf

# Web根目录
/var/www/html/

# 日志目录
/var/log/httpd/

# 证书目录
/etc/pki/tls/certs/
/etc/pki/tls/private/
```


## 二一、apache配置文件

参考Apache2：
[apache配置文件](./Apache2#十四、配置文件详细讲解)
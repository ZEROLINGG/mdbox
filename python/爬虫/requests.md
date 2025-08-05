# Python Requests 库完整学习指南

`requests` 模块是 Python 中最受欢迎的 HTTP 客户端库，被誉为"人类友好的 HTTP 库"。它将复杂的 HTTP 协议操作封装成简洁直观的接口，让网络编程变得轻松愉快。无论是进行 API 调用、数据抓取，还是构建 Web 应用的客户端，`requests` 都是开发者的首选工具。

---

## 一、理解 HTTP 基础与 requests 的设计理念

### HTTP 协议核心概念回顾

在深入学习 `requests` 之前，让我们先理解它要解决的问题。HTTP（超文本传输协议）是现代互联网的基石，每当你在浏览器中访问网页、提交表单或调用 API 时，都在使用 HTTP 进行通信。

HTTP 请求包含几个关键组成部分：请求方法（GET、POST 等）、URL、请求头（headers）、请求体（body）。服务器收到请求后返回响应，包含状态码、响应头和响应体。传统的 Python 标准库 `urllib` 虽然功能完整，但使用起来相当繁琐，需要处理很多底层细节。

### requests 的设计哲学

`requests` 库的设计遵循"简单胜于复杂"的 Python 哲学。它将常用的 HTTP 操作抽象为简单的函数调用，同时保留了足够的灵活性来处理复杂场景。这种设计让初学者能够快速上手，同时为高级用户提供强大的功能。

---

## 二、安装与环境配置

### 基础安装

如果你的系统中尚未安装 `requests`，可以通过 pip 进行安装：

```bash
pip install requests
```

对于需要处理特定编码或证书验证的场景，你可能还需要安装额外的依赖：

```bash
pip install requests[security]  # 增强安全特性
pip install requests[socks]     # SOCKS 代理支持
```

### 验证安装

安装完成后，可以通过简单的代码验证是否正常工作：

```python
import requests
print(requests.__version__)  # 查看版本信息
response = requests.get('https://httpbin.org/get')
print(f"状态码: {response.status_code}")  # 应该输出 200
```

---

## 三、核心概念与基本用法

### 1. 理解请求方法

HTTP 定义了多种请求方法，每种都有特定的语义和用途：

```python
import requests

# GET - 获取资源（幂等操作，不应产生副作用）
response = requests.get('https://httpbin.org/get')
print(f"GET 请求状态码: {response.status_code}")

# POST - 创建新资源或提交数据（非幂等，会产生副作用）
data = {'name': '张三', 'age': 25}
response = requests.post('https://httpbin.org/post', data=data)
print(f"POST 请求响应: {response.json()}")

# PUT - 更新完整资源（幂等操作）
user_data = {'id': 1, 'name': '李四', 'email': 'lisi@example.com'}
response = requests.put('https://httpbin.org/put', json=user_data)

# PATCH - 部分更新资源
update_data = {'email': 'newemail@example.com'}
response = requests.patch('https://httpbin.org/patch', json=update_data)

# DELETE - 删除资源（幂等操作）
response = requests.delete('https://httpbin.org/delete')
```

理解这些方法的语义很重要，因为它们不仅仅是技术实现，更体现了 RESTful API 的设计原则。

### 2. 深入理解请求参数

#### URL 参数（Query Parameters）

URL 参数用于向服务器传送额外信息，通常用于过滤、排序或分页：

```python
# 手动构造 URL（不推荐）
url = 'https://api.example.com/users?page=2&limit=10&sort=name'

# 使用 params 参数（推荐）
base_url = 'https://api.example.com/users'
params = {
    'page': 2,
    'limit': 10,
    'sort': 'name',
    'active': True  # 布尔值会自动转换为字符串
}
response = requests.get(base_url, params=params)
print(f"实际请求的 URL: {response.url}")
```

使用 `params` 参数的好处是 `requests` 会自动处理 URL 编码，避免特殊字符带来的问题。

#### 请求体数据的不同格式

根据 API 的要求，你需要选择合适的数据格式：

```python
# 表单数据（application/x-www-form-urlencoded）
# 适用于传统的 HTML 表单提交
form_data = {'username': 'admin', 'password': 'secret'}
response = requests.post('https://httpbin.org/post', data=form_data)

# JSON 数据（application/json）
# 现代 API 的主流格式
json_data = {'user': {'name': '王五', 'skills': ['Python', 'JavaScript']}}
response = requests.post('https://httpbin.org/post', json=json_data)

# 文件上传（multipart/form-data）
# 用于上传文件或二进制数据
files = {'avatar': open('profile.jpg', 'rb')}
data = {'user_id': '12345'}  # 可以同时传送其他字段
response = requests.post('https://httpbin.org/post', files=files, data=data)

# 原始数据（自定义 Content-Type）
raw_data = '<?xml version="1.0"?><user><name>赵六</name></user>'
headers = {'Content-Type': 'application/xml'}
response = requests.post('https://httpbin.org/post', data=raw_data, headers=headers)
```

### 3. 请求头的重要性

请求头包含了关于请求的元信息，很多时候是成功与否的关键：

```python
# 基础请求头设置
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'application/json',  # 告诉服务器我们期望的响应格式
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',  # 语言偏好
    'Referer': 'https://example.com',  # 来源页面
    'Authorization': 'Bearer your-jwt-token-here'  # 身份验证令牌
}

response = requests.get('https://api.example.com/data', headers=headers)
```

不同的请求头有不同的作用：`User-Agent` 标识客户端类型，`Accept` 指定期望的响应格式，`Authorization` 用于身份验证等。

---

## 四、响应对象深度解析

### Response 对象的完整属性

当你发送请求后，`requests` 返回一个 `Response` 对象，它包含了服务器响应的所有信息：

```python
response = requests.get('https://httpbin.org/json')

# 状态相关信息
print(f"状态码: {response.status_code}")  # 200, 404, 500 等
print(f"状态描述: {response.reason}")     # OK, Not Found, Internal Server Error
print(f"是否成功: {response.ok}")         # status_code < 400 时为 True

# URL 相关信息
print(f"请求的原始 URL: {response.url}")
print(f"响应历史: {response.history}")    # 如果有重定向，显示重定向链

# 响应内容
print(f"文本内容: {response.text}")       # 自动解码的字符串
print(f"字节内容: {response.content}")    # 原始字节数据
print(f"JSON 数据: {response.json()}")    # 解析为 Python 对象

# 响应头信息
print(f"响应头: {response.headers}")
print(f"内容类型: {response.headers['Content-Type']}")

# 编码信息
print(f"检测到的编码: {response.encoding}")
print(f"表观编码: {response.apparent_encoding}")  # 基于内容猜测的编码
```

### 处理不同类型的响应内容

```python
# 处理 JSON 响应
try:
    data = response.json()  # 自动解析 JSON
    print(f"解析的数据: {data}")
except ValueError as e:  # JSON 解析失败
    print(f"响应不是有效的 JSON: {e}")

# 处理二进制内容（图片、PDF 等）
img_response = requests.get('https://httpbin.org/image/png')
with open('downloaded_image.png', 'wb') as f:
    f.write(img_response.content)  # 使用 content 而不是 text

# 处理大文件（流式下载）
large_file_response = requests.get('https://example.com/largefile.zip', stream=True)
with open('largefile.zip', 'wb') as f:
    for chunk in large_file_response.iter_content(chunk_size=8192):
        if chunk:  # 过滤掉保持连接的空块
            f.write(chunk)
```

---

## 五、高级功能详解

### 1. 会话管理：持久连接与状态保持

`Session` 对象是 `requests` 的强大功能之一，它可以在多个请求之间保持连接和状态：

```python
# 创建会话对象
session = requests.Session()

# 设置会话级别的配置
session.headers.update({
    'User-Agent': 'MyApp/1.0',
    'Accept': 'application/json'
})

# 模拟登录流程
login_data = {'username': 'admin', 'password': 'secret'}
login_response = session.post('https://example.com/login', data=login_data)

if login_response.ok:
    # 登录成功后，session 会自动保存 cookies
    # 后续请求会自动携带这些 cookies
    protected_response = session.get('https://example.com/protected-data')
    print("成功访问受保护的资源")
else:
    print("登录失败")

# 会话对象还能提高性能（连接复用）
for i in range(10):
    response = session.get(f'https://api.example.com/data/{i}')
    # 这些请求会复用 TCP 连接，减少握手开销
```

### 2. 超时控制：避免程序假死

网络请求可能因为各种原因变得很慢，合理的超时设置是稳定程序的关键：

```python
# 简单超时（总时间限制）
try:
    response = requests.get('https://httpbin.org/delay/10', timeout=5)
except requests.exceptions.Timeout:
    print("请求超时了")

# 精细超时控制（连接超时，读取超时）
try:
    response = requests.get(
        'https://httpbin.org/delay/3',
        timeout=(3.05, 27)  # (连接超时, 读取超时)
    )
except requests.exceptions.ConnectTimeout:
    print("连接超时")
except requests.exceptions.ReadTimeout:
    print("读取超时")
```

连接超时是建立 TCP 连接的时间限制，读取超时是服务器开始响应后的数据传输时间限制。

### 3. 异常处理：构建健壮的网络应用

网络编程中异常处理至关重要，`requests` 提供了层次化的异常体系：

```python
import requests
from requests.exceptions import RequestException, HTTPError, ConnectionError, Timeout

def robust_request(url, max_retries=3):
    """一个具有重试机制的健壮请求函数"""
    for attempt in range(max_retries):
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()  # 检查 HTTP 状态码
            return response
        
        except HTTPError as e:
            print(f"HTTP 错误 (尝试 {attempt + 1}): {e.response.status_code}")
            if e.response.status_code == 404:
                # 404 错误通常不需要重试
                raise
                
        except ConnectionError:
            print(f"连接错误 (尝试 {attempt + 1})")
            
        except Timeout:
            print(f"超时错误 (尝试 {attempt + 1})")
            
        except RequestException as e:
            print(f"其他请求错误 (尝试 {attempt + 1}): {e}")
        
        if attempt < max_retries - 1:
            time.sleep(2 ** attempt)  # 指数退避
    
    raise RequestException(f"在 {max_retries} 次尝试后仍然失败")

# 使用示例
try:
    response = robust_request('https://httpbin.org/status/503')
    print("请求成功")
except RequestException:
    print("请求最终失败")
```

### 4. 身份验证：多种认证方式

现代 Web 应用使用各种身份验证机制：

```python
from requests.auth import HTTPBasicAuth, HTTPDigestAuth

# HTTP 基本认证
response = requests.get(
    'https://httpbin.org/basic-auth/user/pass',
    auth=HTTPBasicAuth('user', 'pass')
)

# 简化写法
response = requests.get(
    'https://httpbin.org/basic-auth/user/pass',
    auth=('user', 'pass')
)

# HTTP 摘要认证
response = requests.get(
    'https://httpbin.org/digest-auth/auth/user/pass',
    auth=HTTPDigestAuth('user', 'pass')
)

# Bearer Token 认证（常用于 API）
headers = {'Authorization': 'Bearer your-access-token-here'}
response = requests.get('https://api.example.com/data', headers=headers)

# 自定义认证类
class APIKeyAuth:
    def __init__(self, api_key):
        self.api_key = api_key
    
    def __call__(self, request):
        request.headers['X-API-Key'] = self.api_key
        return request

response = requests.get('https://api.example.com/data', auth=APIKeyAuth('your-api-key'))
```

---

## 六、网络爬虫应用实战

### 理解爬虫的工作原理

网络爬虫本质上是模拟人类浏览网页的行为，通过发送 HTTP 请求获取网页内容，然后从中提取有用信息。`requests` 在爬虫系统中扮演着"网络通信引擎"的角色。

一个典型的爬虫工作流程包括：构造请求 → 发送请求 → 获取响应 → 解析内容 → 提取数据 → 存储数据 → 处理反爬策略。

### 1. 模拟真实浏览器行为

许多网站会检查请求的特征来区分人类用户和机器人：

```python
import random
import time

# 构造真实的浏览器请求头
user_agents = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
]

def create_realistic_headers():
    return {
        'User-Agent': random.choice(user_agents),
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3',
        'Accept-Encoding': 'gzip, deflate',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1'
    }

def crawl_with_delays(urls):
    """带有随机延时的爬虫函数"""
    session = requests.Session()
    
    for url in urls:
        # 随机延时，模拟人类行为
        time.sleep(random.uniform(1, 3))
        
        headers = create_realistic_headers()
        try:
            response = session.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            
            print(f"成功爬取: {url} (状态码: {response.status_code})")
            # 这里处理响应内容...
            
        except requests.exceptions.RequestException as e:
            print(f"爬取失败 {url}: {e}")
```

### 2. 处理 Cookies 和会话状态

许多网站需要维持会话状态才能正常访问：

```python
def login_and_crawl():
    """登录后爬取受保护内容的示例"""
    session = requests.Session()
    
    # 第一步：访问登录页面，获取 CSRF token 等信息
    login_page = session.get('https://example.com/login')
    # 这里可能需要解析页面获取隐藏的表单字段
    
    # 第二步：提交登录表单
    login_data = {
        'username': 'your_username',
        'password': 'your_password',
        # 'csrf_token': extracted_csrf_token  # 如果需要的话
    }
    
    login_response = session.post('https://example.com/login', data=login_data)
    
    if '欢迎' in login_response.text:  # 简单的登录成功判断
        print("登录成功")
        
        # 第三步：访问需要登录的页面
        protected_content = session.get('https://example.com/protected-area')
        return protected_content.text
    else:
        print("登录失败")
        return None
```

### 3. 代理池管理

当需要大规模爬取或绕过 IP 限制时，代理池是常用策略：

```python
import itertools

class ProxyManager:
    def __init__(self, proxy_list):
        self.proxy_list = proxy_list
        self.proxy_cycle = itertools.cycle(proxy_list)  # 创建循环迭代器
        self.failed_proxies = set()
    
    def get_next_proxy(self):
        """获取下一个可用代理"""
        attempts = 0
        while attempts < len(self.proxy_list):
            proxy = next(self.proxy_cycle)
            if proxy not in self.failed_proxies:
                return proxy
            attempts += 1
        return None  # 所有代理都失效了
    
    def mark_proxy_failed(self, proxy):
        """标记代理失效"""
        self.failed_proxies.add(proxy)
        print(f"代理 {proxy} 已标记为失效")

def crawl_with_proxy_rotation(urls):
    """使用代理轮换的爬虫"""
    proxy_list = [
        {'http': 'http://proxy1:8080', 'https': 'https://proxy1:8080'},
        {'http': 'http://proxy2:8080', 'https': 'https://proxy2:8080'},
        # 更多代理...
    ]
    
    proxy_manager = ProxyManager(proxy_list)
    session = requests.Session()
    
    for url in urls:
        current_proxy = proxy_manager.get_next_proxy()
        if not current_proxy:
            print("没有可用的代理了")
            break
            
        try:
            response = session.get(
                url, 
                proxies=current_proxy,
                timeout=10,
                headers=create_realistic_headers()
            )
            response.raise_for_status()
            print(f"使用代理 {current_proxy} 成功爬取: {url}")
            
        except requests.exceptions.RequestException as e:
            print(f"使用代理 {current_proxy} 爬取失败: {e}")
            proxy_manager.mark_proxy_failed(current_proxy)
```

### 4. 处理反爬虫机制

现代网站采用多种反爬虫技术，了解这些机制有助于制定对策：

```python
def handle_rate_limiting():
    """处理速率限制的策略"""
    session = requests.Session()
    retry_after = 1  # 初始重试间隔
    
    def make_request(url):
        nonlocal retry_after
        
        try:
            response = session.get(url, timeout=10)
            
            if response.status_code == 429:  # Too Many Requests
                # 检查 Retry-After 头
                retry_after = int(response.headers.get('Retry-After', retry_after * 2))
                print(f"触发速率限制，等待 {retry_after} 秒")
                time.sleep(retry_after)
                return make_request(url)  # 递归重试
            
            response.raise_for_status()
            retry_after = 1  # 重置重试间隔
            return response
            
        except requests.exceptions.RequestException as e:
            print(f"请求失败: {e}")
            return None
    
    return make_request

# 使用示例
smart_request = handle_rate_limiting()
response = smart_request('https://api.example.com/data')
```

---

## 七、性能优化与最佳实践

### 1. 连接池与会话复用

理解 `requests` 的连接管理机制对性能优化很重要：

```python
import concurrent.futures
import time

# 不推荐：每次请求都创建新连接
def inefficient_requests(urls):
    start_time = time.time()
    for url in urls:
        response = requests.get(url)  # 每次都建立新连接
        print(f"状态码: {response.status_code}")
    print(f"耗时: {time.time() - start_time:.2f} 秒")

# 推荐：使用会话复用连接
def efficient_requests(urls):
    start_time = time.time()
    session = requests.Session()
    for url in urls:
        response = session.get(url)  # 复用连接
        print(f"状态码: {response.status_code}")
    print(f"耗时: {time.time() - start_time:.2f} 秒")

# 进一步优化：并发请求（注意控制并发数量）
def concurrent_requests(urls, max_workers=5):
    start_time = time.time()
    
    def fetch_url(url):
        session = requests.Session()  # 每个线程使用独立的会话
        response = session.get(url)
        return response.status_code
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [executor.submit(fetch_url, url) for url in urls]
        results = [future.result() for future in concurrent.futures.as_completed(futures)]
    
    print(f"并发请求耗时: {time.time() - start_time:.2f} 秒")
    return results
```

### 2. 流式处理大文件

当处理大文件时，内存管理变得至关重要：

```python
def download_large_file(url, filename):
    """流式下载大文件，避免内存溢出"""
    with requests.get(url, stream=True) as response:
        response.raise_for_status()
        
        # 获取文件大小（如果服务器提供的话）
        total_size = int(response.headers.get('Content-Length', 0))
        downloaded_size = 0
        
        with open(filename, 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:  # 过滤掉保持连接的空块
                    file.write(chunk)
                    downloaded_size += len(chunk)
                    
                    # 显示下载进度
                    if total_size > 0:
                        progress = (downloaded_size / total_size) * 100
                        print(f"\r下载进度: {progress:.1f}%", end='', flush=True)
        
        print(f"\n下载完成: {filename}")

# 使用示例
download_large_file('https://example.com/large-dataset.zip', 'dataset.zip')
```

### 3. 错误处理与重试策略

构建健壮的网络应用需要全面的错误处理：

```python
from functools import wraps
import random

def retry_on_failure(max_retries=3, backoff_factor=1, status_forcelist=None):
    """装饰器：为函数添加重试机制"""
    if status_forcelist is None:
        status_forcelist = [500, 502, 503, 504]
    
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            
            for attempt in range(max_retries):
                try:
                    response = func(*args, **kwargs)
                    
                    # 检查是否需要重试的状态码
                    if hasattr(response, 'status_code') and response.status_code in status_forcelist:
                        raise requests.exceptions.HTTPError(f"HTTP {response.status_code}")
                    
                    return response
                    
                except (requests.exceptions.RequestException, requests.exceptions.HTTPError) as e:
                    last_exception = e
                    if attempt < max_retries - 1:
                        # 指数退避 + 随机抖动
                        sleep_time = backoff_factor * (2 ** attempt) + random.uniform(0, 1)
                        print(f"第 {attempt + 1} 次尝试失败，{sleep_time:.2f} 秒后重试...")
                        time.sleep(sleep_time)
                    else:
                        print(f"所有重试尝试都失败了")
            
            raise last_exception
        
        return wrapper
    return decorator

# 使用示例
@retry_on_failure(max_retries=3, backoff_factor=2)
def reliable_get(url, **kwargs):
    return requests.get(url, **kwargs)

# 现在这个函数具有自动重试能力
response = reliable_get('https://httpbin.org/status/503', timeout=5)
```

---

## 八、安全考虑与最佳实践

### 1. SSL/TLS 证书验证

在生产环境中，正确处理 SSL 证书至关重要：

```python
# 默认情况下，requests 会验证 SSL 证书
response = requests.get('https://www.google.com')  # 安全

# 危险操作：跳过证书验证（仅用于测试）
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
response = requests.get('https://self-signed.badssl.com', verify=False)

# 推荐做法：使用自定义证书或证书包
response = requests.get('https://example.com', verify='/path/to/certificate.pem')

# 为企业内部 CA 配置证书验证
import ssl
import certifi

def create_secure_session():
    session = requests.Session()
    # 使用系统证书存储
    session.verify = certifi.where()
    return session
```

### 2. 敏感信息处理

避免在代码中硬编码敏感信息：

```python
import os
from urllib.parse import urljoin

class APIClient:
    def __init__(self):
        # 从环境变量读取敏感配置
        self.base_url = os.getenv('API_BASE_URL', 'https://api.example.com')
        self.api_key = os.getenv('API_KEY')
        
        if not self.api_key:
            raise ValueError("API_KEY 环境变量未设置")
        
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {self.api_key}',
            'User-Agent': 'MyApp/1.0'
        })
    
    def get(self, endpoint, **kwargs):
        url = urljoin(self.base_url, endpoint)
        return self.session.get(url, **kwargs)
    
    def post(self, endpoint, **kwargs):
        url = urljoin(self.base_url, endpoint)
        return self.session.post(url, **kwargs)

# 使用示例
# export API_KEY="your-secret-key"
# export API_BASE_URL="https://api.example.com"
client = APIClient()
response = client.get('/users/profile')
```

### 3. 防止请求伪造和注入攻击

在处理用户输入时要格外小心：

```python
from urllib.parse import quote, urljoin
import re

def safe_url_builder(base_url, path, params=None):
    """安全构建 URL，防止注入攻击"""
    # 验证基础 URL 格式
    if not re.match(r'^https?://', base_url):
        raise ValueError("无效的基础 URL")
    
    # 清理路径，防止路径遍历攻击
    safe_path = quote(path.strip('/'), safe='/')
    
    # 构建完整 URL
    full_url = urljoin(base_url.rstrip('/') + '/', safe_path)
    
    if params:
        # requests 会自动处理参数编码
        response = requests.get(full_url, params=params)
    else:
        response = requests.get(full_url)
    
    return response

# 安全使用示例
user_input = "../../../etc/passwd"  # 恶意输入
try:
    response = safe_url_builder('https://api.example.com', user_input)
except ValueError as e:
    print(f"安全检查失败: {e}")
```

---

## 九、高级应用场景

### 1. API 客户端开发

创建一个功能完整的 API 客户端类：

```python
import json
from datetime import datetime, timedelta
from typing import Optional, Dict, Any

class RESTAPIClient:
    """通用 REST API 客户端基类"""
    
    def __init__(self, base_url: str, auth_token: str = None, timeout: int = 30):
        self.base_url = base_url.rstrip('/')
        self.timeout = timeout
        self.session = requests.Session()
        
        # 设置默认请求头
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'Python-APIClient/1.0'
        })
        
        if auth_token:
            self.session.headers['Authorization'] = f'Bearer {auth_token}'
        
        # 令牌过期时间跟踪
        self.token_expires_at = None
    
    def _make_request(self, method: str, endpoint: str, **kwargs) -> requests.Response:
        """发送请求的内部方法"""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        
        # 设置默认超时
        kwargs.setdefault('timeout', self.timeout)
        
        try:
            response = self.session.request(method, url, **kwargs)
            response.raise_for_status()
            return response
            
        except requests.exceptions.HTTPError as e:
            # 处理特定的 HTTP 错误
            if e.response.status_code == 401:
                raise APIAuthenticationError("身份验证失败")
            elif e.response.status_code == 429:
                raise APIRateLimitError("API 调用频率超限")
            else:
                raise APIError(f"API 调用失败: {e.response.status_code}")
        
        except requests.exceptions.RequestException as e:
            raise APIConnectionError(f"网络连接失败: {e}")
    
    def get(self, endpoint: str, params: Dict = None, **kwargs) -> Dict[str, Any]:
        """GET 请求"""
        response = self._make_request('GET', endpoint, params=params, **kwargs)
        return response.json()
    
    def post(self, endpoint: str, data: Dict = None, **kwargs) -> Dict[str, Any]:
        """POST 请求"""
        if data:
            kwargs['json'] = data
        response = self._make_request('POST', endpoint, **kwargs)
        return response.json()
    
    def put(self, endpoint: str, data: Dict = None, **kwargs) -> Dict[str, Any]:
        """PUT 请求"""
        if data:
            kwargs['json'] = data
        response = self._make_request('PUT', endpoint, **kwargs)
        return response.json()
    
    def delete(self, endpoint: str, **kwargs) -> bool:
        """DELETE 请求"""
        response = self._make_request('DELETE', endpoint, **kwargs)
        return response.status_code == 204
    
    def refresh_token(self, refresh_token: str) -> str:
        """刷新访问令牌"""
        data = {'refresh_token': refresh_token}
        response = self.post('/auth/refresh', data)
        
        new_token = response['access_token']
        self.session.headers['Authorization'] = f'Bearer {new_token}'
        
        # 更新过期时间
        expires_in = response.get('expires_in', 3600)
        self.token_expires_at = datetime.now() + timedelta(seconds=expires_in)
        
        return new_token

# 自定义异常类
class APIError(Exception):
    pass

class APIAuthenticationError(APIError):
    pass

class APIRateLimitError(APIError):
    pass

class APIConnectionError(APIError):
    pass

# 使用示例
api_client = RESTAPIClient('https://api.example.com', auth_token='your-token')

try:
    # 获取用户列表
    users = api_client.get('/users', params={'page': 1, 'limit': 10})
    
    # 创建新用户
    new_user = api_client.post('/users', data={'name': '张三', 'email': 'zhangsan@example.com'})
    
    # 更新用户
    updated_user = api_client.put(f'/users/{new_user["id"]}', data={'name': '李四'})
    
    # 删除用户
    success = api_client.delete(f'/users/{new_user["id"]}')
    
except APIError as e:
    print(f"API 调用失败: {e}")
```

### 2. 文件批量处理

处理文件上传、下载和批量操作：

```python
import os
from pathlib import Path
import mimetypes
from concurrent.futures import ThreadPoolExecutor, as_completed

class FileManager:
    """文件操作管理器"""
    
    def __init__(self, base_url: str, auth_token: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers['Authorization'] = f'Bearer {auth_token}'
    
    def upload_file(self, file_path: Path, endpoint: str = '/files/upload') -> Dict:
        """上传单个文件"""
        if not file_path.exists():
            raise FileNotFoundError(f"文件不存在: {file_path}")
        
        # 自动检测文件类型
        mime_type, _ = mimetypes.guess_type(str(file_path))
        
        with open(file_path, 'rb') as file:
            files = {
                'file': (file_path.name, file, mime_type or 'application/octet-stream')
            }
            data = {
                'filename': file_path.name,
                'size': file_path.stat().st_size
            }
            
            response = self.session.post(
                f"{self.base_url}{endpoint}",
                files=files,
                data=data,
                timeout=300  # 5 分钟超时，适合大文件
            )
            response.raise_for_status()
            return response.json()
    
    def download_file(self, file_id: str, save_path: Path) -> bool:
        """下载文件"""
        url = f"{self.base_url}/files/{file_id}/download"
        
        with self.session.get(url, stream=True) as response:
            response.raise_for_status()
            
            # 确保目录存在
            save_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(save_path, 'wb') as file:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        file.write(chunk)
        
        return True
    
    def batch_upload(self, file_paths: list, max_workers: int = 3) -> Dict:
        """批量上传文件"""
        results = {'success': [], 'failed': []}
        
        def upload_single(file_path):
            try:
                result = self.upload_file(Path(file_path))
                return ('success', file_path, result)
            except Exception as e:
                return ('failed', file_path, str(e))
        
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            # 提交所有上传任务
            future_to_path = {
                executor.submit(upload_single, path): path 
                for path in file_paths
            }
            
            # 收集结果
            for future in as_completed(future_to_path):
                status, path, result = future.result()
                results[status].append({'path': path, 'result': result})
        
        return results
    
    def get_upload_progress(self, file_path: Path, endpoint: str = '/files/upload') -> None:
        """带进度显示的文件上传"""
        file_size = file_path.stat().st_size
        
        class ProgressFile:
            def __init__(self, file_obj, callback):
                self.file_obj = file_obj
                self.callback = callback
                self.bytes_read = 0
            
            def read(self, size=-1):
                chunk = self.file_obj.read(size)
                if chunk:
                    self.bytes_read += len(chunk)
                    self.callback(self.bytes_read)
                return chunk
            
            def __getattr__(self, name):
                return getattr(self.file_obj, name)
        
        def progress_callback(bytes_read):
            percent = (bytes_read / file_size) * 100
            print(f"\r上传进度: {percent:.1f}% ({bytes_read}/{file_size} 字节)", 
                  end='', flush=True)
        
        with open(file_path, 'rb') as file:
            progress_file = ProgressFile(file, progress_callback)
            files = {'file': (file_path.name, progress_file)}
            
            response = self.session.post(
                f"{self.base_url}{endpoint}",
                files=files,
                timeout=300
            )
            print()  # 换行
            response.raise_for_status()

# 使用示例
file_manager = FileManager('https://api.example.com', 'your-token')

# 上传单个文件
result = file_manager.upload_file(Path('document.pdf'))
print(f"文件上传成功: {result}")

# 批量上传
file_list = ['file1.txt', 'file2.jpg', 'file3.pdf']
batch_results = file_manager.batch_upload(file_list)
print(f"成功上传: {len(batch_results['success'])} 个文件")
print(f"上传失败: {len(batch_results['failed'])} 个文件")
```

### 3. 实时数据处理与 WebHook

处理实时数据和 WebHook 回调：

```python
import hashlib
import hmac
from typing import Callable
import threading
import queue
import time

class WebHookProcessor:
    """WebHook 处理器"""
    
    def __init__(self, secret_key: str):
        self.secret_key = secret_key
        self.session = requests.Session()
        self.message_queue = queue.Queue()
        self.processing_thread = None
        self.running = False
    
    def verify_signature(self, payload: bytes, signature: str) -> bool:
        """验证 WebHook 签名"""
        expected_signature = hmac.new(
            self.secret_key.encode(),
            payload,
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(f"sha256={expected_signature}", signature)
    
    def process_webhook(self, payload: Dict, signature: str) -> bool:
        """处理 WebHook 请求"""
        payload_bytes = json.dumps(payload, sort_keys=True).encode()
        
        if not self.verify_signature(payload_bytes, signature):
            raise ValueError("WebHook 签名验证失败")
        
        # 将消息加入处理队列
        self.message_queue.put(payload)
        return True
    
    def start_processing(self, handler: Callable):
        """启动后台处理线程"""
        self.running = True
        self.processing_thread = threading.Thread(
            target=self._process_messages,
            args=(handler,)
        )
        self.processing_thread.start()
    
    def stop_processing(self):
        """停止后台处理"""
        self.running = False
        if self.processing_thread:
            self.processing_thread.join()
    
    def _process_messages(self, handler: Callable):
        """后台消息处理循环"""
        while self.running:
            try:
                # 从队列获取消息，超时 1 秒
                message = self.message_queue.get(timeout=1)
                handler(message)
                self.message_queue.task_done()
            except queue.Empty:
                continue
            except Exception as e:
                print(f"处理消息时发生错误: {e}")

class RealTimeDataCollector:
    """实时数据收集器"""
    
    def __init__(self, api_base_url: str, auth_token: str):
        self.api_base_url = api_base_url
        self.session = requests.Session()
        self.session.headers['Authorization'] = f'Bearer {auth_token}'
        self.data_buffer = []
        self.buffer_size = 100
        self.last_flush = time.time()
        self.flush_interval = 60  # 60 秒强制刷新一次
    
    def collect_data_point(self, data: Dict):
        """收集单个数据点"""
        data['timestamp'] = datetime.now().isoformat()
        self.data_buffer.append(data)
        
        # 检查是否需要刷新缓冲区
        if (len(self.data_buffer) >= self.buffer_size or 
            time.time() - self.last_flush >= self.flush_interval):
            self.flush_buffer()
    
    def flush_buffer(self):
        """刷新数据缓冲区到服务器"""
        if not self.data_buffer:
            return
        
        try:
            response = self.session.post(
                f"{self.api_base_url}/data/batch",
                json={'data_points': self.data_buffer},
                timeout=30
            )
            response.raise_for_status()
            
            print(f"成功上传 {len(self.data_buffer)} 个数据点")
            self.data_buffer.clear()
            self.last_flush = time.time()
            
        except requests.exceptions.RequestException as e:
            print(f"数据上传失败: {e}")
            # 可以选择重试或者将数据写入本地文件
    
    def stream_data(self, data_source_url: str, handler: Callable):
        """流式处理数据"""
        try:
            with self.session.get(data_source_url, stream=True) as response:
                response.raise_for_status()
                
                for line in response.iter_lines():
                    if line:
                        try:
                            data = json.loads(line.decode('utf-8'))
                            handler(data)
                        except json.JSONDecodeError:
                            print(f"无法解析的数据行: {line}")
                        
        except requests.exceptions.RequestException as e:
            print(f"流式数据处理失败: {e}")

# 使用示例
def handle_webhook_data(payload):
    """WebHook 数据处理函数"""
    event_type = payload.get('event_type')
    print(f"收到 WebHook 事件: {event_type}")
    
    # 根据事件类型进行处理
    if event_type == 'user_signup':
        # 处理用户注册事件
        user_data = payload.get('data', {})
        print(f"新用户注册: {user_data.get('email')}")
    
    elif event_type == 'payment_completed':
        # 处理支付完成事件
        payment_data = payload.get('data', {})
        print(f"支付完成: {payment_data.get('amount')} 元")

# 设置 WebHook 处理器
webhook_processor = WebHookProcessor('your-webhook-secret')
webhook_processor.start_processing(handle_webhook_data)

# 设置实时数据收集器
data_collector = RealTimeDataCollector('https://api.example.com', 'your-token')

# 收集数据点
data_collector.collect_data_point({
    'sensor_id': 'temp_001',
    'value': 23.5,
    'unit': 'celsius'
})
```

---

## 十、故障排查与调试技巧

### 1. 启用详细日志

调试网络问题时，详细的日志信息至关重要：

```python
import logging
import http.client as http_client

# 启用 HTTP 请求日志
http_client.HTTPConnection.debuglevel = 1

# 配置 logging
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

# 现在所有请求都会显示详细日志
response = requests.get('https://httpbin.org/get')
```

### 2. 请求和响应检查工具

创建调试友好的请求函数：

```python
def debug_request(method, url, **kwargs):
    """带调试信息的请求函数"""
    print(f"\n{'='*50}")
    print(f"请求方法: {method.upper()}")
    print(f"请求 URL: {url}")
    
    # 显示请求头
    headers = kwargs.get('headers', {})
    if headers:
        print("请求头:")
        for key, value in headers.items():
            print(f"  {key}: {value}")
    
    # 显示请求参数
    params = kwargs.get('params')
    if params:
        print(f"URL 参数: {params}")
    
    # 显示请求体
    data = kwargs.get('data')
    json_data = kwargs.get('json')
    if data:
        print(f"表单数据: {data}")
    if json_data:
        print(f"JSON 数据: {json.dumps(json_data, indent=2, ensure_ascii=False)}")
    
    # 发送请求
    start_time = time.time()
    try:
        response = requests.request(method, url, **kwargs)
        elapsed_time = time.time() - start_time
        
        print(f"\n响应信息:")
        print(f"状态码: {response.status_code} ({response.reason})")
        print(f"响应时间: {elapsed_time:.3f} 秒")
        print(f"响应大小: {len(response.content)} 字节")
        
        # 显示响应头
        print("响应头:")
        for key, value in response.headers.items():
            print(f"  {key}: {value}")
        
        # 显示响应内容（截断长内容）
        content_preview = response.text[:500]
        if len(response.text) > 500:
            content_preview += "..."
        print(f"\n响应内容预览:\n{content_preview}")
        
        return response
        
    except requests.exceptions.RequestException as e:
        elapsed_time = time.time() - start_time
        print(f"\n请求失败:")
        print(f"错误类型: {type(e).__name__}")
        print(f"错误信息: {e}")
        print(f"失败时间: {elapsed_time:.3f} 秒")
        raise
    finally:
        print(f"{'='*50}\n")

# 使用示例
debug_request('GET', 'https://httpbin.org/headers', 
              headers={'User-Agent': 'Debug/1.0'})
```

### 3. 网络连接诊断

诊断网络连接问题的工具函数：

```python
import socket
from urllib.parse import urlparse

def diagnose_connection(url):
    """诊断到目标 URL 的连接状态"""
    parsed = urlparse(url)
    host = parsed.hostname
    port = parsed.port or (443 if parsed.scheme == 'https' else 80)
    
    print(f"诊断连接到 {host}:{port}")
    
    # DNS 解析测试
    try:
        ip_address = socket.gethostbyname(host)
        print(f"✓ DNS 解析成功: {host} -> {ip_address}")
    except socket.gaierror as e:
        print(f"✗ DNS 解析失败: {e}")
        return False
    
    # TCP 连接测试
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        result = sock.connect_ex((host, port))
        sock.close()
        
        if result == 0:
            print(f"✓ TCP 连接成功")
        else:
            print(f"✗ TCP 连接失败，错误代码: {result}")
            return False
    except Exception as e:
        print(f"✗ TCP 连接异常: {e}")
        return False
    
    # HTTP 请求测试
    try:
        response = requests.get(url, timeout=10)
        print(f"✓ HTTP 请求成功，状态码: {response.status_code}")
        return True
    except requests.exceptions.RequestException as e:
        print(f"✗ HTTP 请求失败: {e}")
        return False

# 使用示例
diagnose_connection('https://www.google.com')
```

---

## 十一、与其他库的集成

### 1. 与数据处理库集成

结合 pandas 进行数据分析：

```python
import pandas as pd
import io

def fetch_csv_data(url, **kwargs):
    """从 URL 获取 CSV 数据并转换为 DataFrame"""
    response = requests.get(url, **kwargs)
    response.raise_for_status()
    
    # 使用 StringIO 将响应文本转换为文件对象
    csv_data = io.StringIO(response.text)
    df = pd.read_csv(csv_data)
    
    return df

def post_dataframe(url, df, format='json', **kwargs):
    """将 DataFrame 发送到服务器"""
    if format == 'json':
        data = df.to_json(orient='records')
        headers = {'Content-Type': 'application/json'}
    elif format == 'csv':
        data = df.to_csv(index=False)
        headers = {'Content-Type': 'text/csv'}
    else:
        raise ValueError("不支持的格式")
    
    kwargs.setdefault('headers', {}).update(headers)
    return requests.post(url, data=data, **kwargs)

# 使用示例
# df = fetch_csv_data('https://example.com/data.csv')
# result = post_dataframe('https://api.example.com/upload', df)
```

### 2. 与异步框架集成

使用 asyncio 和 aiohttp 进行高性能异步请求：

```python
import asyncio
import aiohttp
from concurrent.futures import ThreadPoolExecutor

class AsyncRequestsMixin:
    """为 requests 添加异步支持的混入类"""
    
    def __init__(self):
        self.executor = ThreadPoolExecutor(max_workers=10)
    
    async def async_get(self, url, **kwargs):
        """异步 GET 请求"""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(
            self.executor, 
            lambda: requests.get(url, **kwargs)
        )
    
    async def async_post(self, url, **kwargs):
        """异步 POST 请求"""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(
            self.executor,
            lambda: requests.post(url, **kwargs)
        )
    
    async def batch_requests(self, urls, method='GET'):
        """批量异步请求"""
        tasks = []
        
        for url in urls:
            if method.upper() == 'GET':
                task = self.async_get(url)
            elif method.upper() == 'POST':
                task = self.async_post(url)
            else:
                raise ValueError(f"不支持的方法: {method}")
            
            tasks.append(task)
        
        responses = await asyncio.gather(*tasks, return_exceptions=True)
        return responses

# 使用示例
async def main():
    client = AsyncRequestsMixin()
    
    urls = [
        'https://httpbin.org/delay/1',
        'https://httpbin.org/delay/2',
        'https://httpbin.org/delay/3'
    ]
    
    start_time = time.time()
    responses = await client.batch_requests(urls)
    elapsed_time = time.time() - start_time
    
    print(f"异步请求完成，耗时: {elapsed_time:.2f} 秒")
    for i, response in enumerate(responses):
        if isinstance(response, Exception):
            print(f"请求 {i} 失败: {response}")
        else:
            print(f"请求 {i} 成功: {response.status_code}")

# 运行异步代码
# asyncio.run(main())
```

---


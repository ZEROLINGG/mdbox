# C++ libcurl 详细使用教程

## 一、libcurl 简介

libcurl 支持多种协议（HTTP、HTTPS、FTP、SMTP等），是进行网络编程的强大工具。

## 二、安装配置

### Linux
```bash
# Ubuntu/Debian
sudo apt-get install libcurl4-openssl-dev

# CentOS/RedHat
sudo yum install libcurl-devel
```

### Windows
- 下载预编译库或使用 vcpkg：
```bash
vcpkg install curl
```

### 编译链接
```bash
g++ main.cpp -lcurl -o main
```

## 三、基本使用流程

### 1. 基本框架
```cpp
#include <curl/curl.h>
#include <iostream>
#include <string>

int main() {
    // 1. 全局初始化（程序开始时调用一次）
    curl_global_init(CURL_GLOBAL_DEFAULT);
    
    // 2. 创建 easy handle
    CURL* curl = curl_easy_init();
    
    if(curl) {
        // 3. 设置选项
        curl_easy_setopt(curl, CURLOPT_URL, "http://example.com");
        
        // 4. 执行请求
        CURLcode res = curl_easy_perform(curl);
        
        // 5. 检查错误
        if(res != CURLE_OK) {
            fprintf(stderr, "curl_easy_perform() failed: %s\n",
                    curl_easy_strerror(res));
        }
        
        // 6. 清理
        curl_easy_cleanup(curl);
    }
    
    // 7. 全局清理（程序结束时调用一次）
    curl_global_cleanup();
    
    return 0;
}
```

## 四、常用功能示例

### 1. GET 请求

```cpp
#include <curl/curl.h>     // 引入 libcurl 的核心头文件
#include <string>
#include <iostream>

/**
 * 回调函数：用于处理服务器返回的数据。
 *
 * libcurl 在接收数据时会多次调用此函数，每次提供一段数据块。
 * 该函数需要将数据写入用户指定的缓冲区中。
 *
 * @param contents 指向当前收到的数据块的指针
 * @param size     单个数据项大小（一般为 1）
 * @param nmemb    数据项数量（实际数据块大小为 size * nmemb）
 * @param userp    由 CURLOPT_WRITEDATA 设置的用户指针，这里用于保存响应内容
 *
 * @return 写入的数据大小，若返回值不一致则会被视为写入失败
 */
size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    // 将接收到的数据内容追加到 std::string 中
    // `->` 是 C/C++ 中结构体指针或类指针的成员访问运算符。
    ((std::string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;   // 返回实际处理的字节数
}

/**
 * 执行简单的 HTTP GET 请求。
 *
 * @param url 目标 URL 地址
 * @return    返回服务器响应的完整内容
 */
std::string httpGet(const std::string& url) {
    CURL* curl;            // CURL 句柄，用于执行 HTTP 请求
    CURLcode res;          // 用于接收请求执行后的返回码
    std::string readBuffer; // 用于保存服务器响应结果

    curl = curl_easy_init();  // 初始化一个 easy handle，用于单次传输
    if (curl) {
        // 设置目标 URL
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());

        // 设置数据写入回调函数
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);

        // 设置回调写入的目标缓冲区，即 readBuffer
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

        // 启用自动跟随 HTTP 重定向（如 301、302）
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);

        // 设置最大超时（秒）
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10L);

        // 执行 HTTP GET 请求（阻塞直到完成或失败）
        res = curl_easy_perform(curl);

        // 检查请求是否成功
        if (res != CURLE_OK) {
            std::cerr << "curl_easy_perform() failed: "
                      << curl_easy_strerror(res) << std::endl;
        }

        // 释放 CURL easy 句柄，防止内存泄漏
        curl_easy_cleanup(curl);
    }

    // 返回服务器完整响应内容
    return readBuffer;
}

int main() {
    // 初始化 libcurl 全局环境
    curl_global_init(CURL_GLOBAL_DEFAULT);

    // 调用 httpGet 执行 GET 请求
    std::string response = httpGet("http://httpbin.org/get");

    // 输出服务器响应
    std::cout << response << std::endl;

    // 清理 libcurl 全局资源
    curl_global_cleanup();

    return 0;
}

```

### 2. POST 请求

```cpp
std::string httpPost(const std::string& url, const std::string& postData) {
    CURL* curl;
    CURLcode res;
    std::string readBuffer;
    
    curl = curl_easy_init();
    if(curl) {
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_POST, 1L);
        
        // 设置POST数据
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postData.c_str());
        
        // 设置回调函数
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
        
        res = curl_easy_perform(curl);
        
        if(res != CURLE_OK) {
            std::cerr << "Error: " << curl_easy_strerror(res) << std::endl;
        }
        
        curl_easy_cleanup(curl);
    }
    
    return readBuffer;
}

// 使用示例
int main() {
    curl_global_init(CURL_GLOBAL_DEFAULT);
    
    std::string postData = "name=John&age=30";
    std::string response = httpPost("http://httpbin.org/post", postData);
    std::cout << response << std::endl;
    
    curl_global_cleanup();
    return 0;
}
```

### 3. POST JSON 数据

```cpp
std::string httpPostJson(const std::string& url, const std::string& jsonData) {
    CURL* curl;
    CURLcode res;
    std::string readBuffer;
    
    curl = curl_easy_init();
    if(curl) {
        struct curl_slist* headers = NULL;
        headers = curl_slist_append(headers, "Content-Type: application/json");
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, jsonData.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
        
        res = curl_easy_perform(curl);
        
        if(res != CURLE_OK) {
            std::cerr << "Error: " << curl_easy_strerror(res) << std::endl;
        }
        
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
    }
    
    return readBuffer;
}

// 使用示例
int main() {
    curl_global_init(CURL_GLOBAL_DEFAULT);
    
    std::string jsonData = R"({"name":"John", "age":30})";
    std::string response = httpPostJson("http://httpbin.org/post", jsonData);
    std::cout << response << std::endl;
    
    curl_global_cleanup();
    return 0;
}
```

### 4. 添加自定义请求头

```cpp
std::string httpGetWithHeaders(const std::string& url) {
    CURL* curl;
    CURLcode res;
    std::string readBuffer;
    
    curl = curl_easy_init();
    if(curl) {
        struct curl_slist* headers = NULL;
        headers = curl_slist_append(headers, "User-Agent: MyApp/1.0");
        headers = curl_slist_append(headers, "Authorization: Bearer token123");
        headers = curl_slist_append(headers, "Accept: application/json");
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
        
        res = curl_easy_perform(curl);
        
        if(res != CURLE_OK) {
            std::cerr << "Error: " << curl_easy_strerror(res) << std::endl;
        }
        
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
    }
    
    return readBuffer;
}
```

### 5. 下载文件

```cpp
bool downloadFile(const std::string& url, const std::string& filepath) {
    CURL* curl;
    FILE* fp;
    CURLcode res;
    
    curl = curl_easy_init();
    if(curl) {
        fp = fopen(filepath.c_str(), "wb");
        if(!fp) {
            curl_easy_cleanup(curl);
            return false;
        }
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, NULL);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
        
        // 显示进度
        curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0L);
        
        res = curl_easy_perform(curl);
        
        fclose(fp);
        curl_easy_cleanup(curl);
        
        return (res == CURLE_OK);
    }
    
    return false;
}
```

### 6. 上传文件

```cpp
bool uploadFile(const std::string& url, const std::string& filepath) {
    CURL* curl;
    CURLcode res;
    
    curl = curl_easy_init();
    if(curl) {
        curl_mime* form = curl_mime_init(curl);
        curl_mimepart* field = curl_mime_addpart(form);
        
        curl_mime_name(field, "file");
        curl_mime_filedata(field, filepath.c_str());
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_MIMEPOST, form);
        
        res = curl_easy_perform(curl);
        
        curl_mime_free(form);
        curl_easy_cleanup(curl);
        
        return (res == CURLE_OK);
    }
    
    return false;
}
```

## 五、高级功能

### 1. 获取响应信息

```cpp
void getResponseInfo(const std::string& url) {
    CURL* curl;
    CURLcode res;
    
    curl = curl_easy_init();
    if(curl) {
        std::string readBuffer;
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
        
        res = curl_easy_perform(curl);
        
        if(res == CURLE_OK) {
            long response_code;
            double total_time;
            double download_size;
            
            // 获取HTTP响应码
            curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
            
            // 获取总耗时
            curl_easy_getinfo(curl, CURLINFO_TOTAL_TIME, &total_time);
            
            // 获取下载大小
            curl_easy_getinfo(curl, CURLINFO_SIZE_DOWNLOAD, &download_size);
            
            std::cout << "Response Code: " << response_code << std::endl;
            std::cout << "Total Time: " << total_time << " seconds" << std::endl;
            std::cout << "Download Size: " << download_size << " bytes" << std::endl;
        }
        
        curl_easy_cleanup(curl);
    }
}
```

### 2. 获取响应头

```cpp
size_t HeaderCallback(char* buffer, size_t size, size_t nitems, void* userdata) {
    ((std::string*)userdata)->append(buffer, size * nitems);
    return size * nitems;
}

void getHeaders(const std::string& url) {
    CURL* curl;
    CURLcode res;
    std::string headerBuffer;
    std::string bodyBuffer;
    
    curl = curl_easy_init();
    if(curl) {
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, HeaderCallback);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, &headerBuffer);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &bodyBuffer);
        
        res = curl_easy_perform(curl);
        
        if(res == CURLE_OK) {
            std::cout << "Headers:\n" << headerBuffer << std::endl;
            std::cout << "Body:\n" << bodyBuffer << std::endl;
        }
        
        curl_easy_cleanup(curl);
    }
}
```

### 3. HTTPS 请求（SSL）

```cpp
std::string httpsGet(const std::string& url) {
    CURL* curl;
    CURLcode res;
    std::string readBuffer;
    
    curl = curl_easy_init();
    if(curl) {
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        
        // SSL 验证
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 2L);
        
        // 可选：指定CA证书路径
        // curl_easy_setopt(curl, CURLOPT_CAINFO, "/path/to/ca-bundle.crt");
        
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
        
        res = curl_easy_perform(curl);
        
        if(res != CURLE_OK) {
            std::cerr << "Error: " << curl_easy_strerror(res) << std::endl;
        }
        
        curl_easy_cleanup(curl);
    }
    
    return readBuffer;
}
```

### 4. Cookie 处理

```cpp
std::string httpWithCookies(const std::string& url) {
    CURL* curl;
    CURLcode res;
    std::string readBuffer;
    
    curl = curl_easy_init();
    if(curl) {
        // 启用cookie引擎
        curl_easy_setopt(curl, CURLOPT_COOKIEFILE, "");
        
        // 保存cookie到文件
        curl_easy_setopt(curl, CURLOPT_COOKIEJAR, "cookies.txt");
        
        // 从文件加载cookie
        // curl_easy_setopt(curl, CURLOPT_COOKIEFILE, "cookies.txt");
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
        
        res = curl_easy_perform(curl);
        
        curl_easy_cleanup(curl);
    }
    
    return readBuffer;
}
```

## 六、封装的 HTTP 客户端类

```cpp
#include <curl/curl.h>
#include <string>
#include <map>

class HttpClient {
private:
    CURL* curl;
    struct curl_slist* headers;
    std::string responseBody;
    std::string responseHeader;
    long responseCode;
    
    static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
        ((std::string*)userp)->append((char*)contents, size * nmemb);
        return size * nmemb;
    }
    
    static size_t HeaderCallback(char* buffer, size_t size, size_t nitems, void* userdata) {
        ((std::string*)userdata)->append(buffer, size * nitems);
        return size * nitems;
    }
    
public:
    HttpClient() : curl(nullptr), headers(nullptr), responseCode(0) {
        curl = curl_easy_init();
    }
    
    ~HttpClient() {
        if(headers) {
            curl_slist_free_all(headers);
        }
        if(curl) {
            curl_easy_cleanup(curl);
        }
    }
    
    void addHeader(const std::string& header) {
        headers = curl_slist_append(headers, header.c_str());
    }
    
    void setTimeout(long seconds) {
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, seconds);
    }
    
    bool get(const std::string& url) {
        if(!curl) return false;
        
        responseBody.clear();
        responseHeader.clear();
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBody);
        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, HeaderCallback);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, &responseHeader);
        
        if(headers) {
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        }
        
        CURLcode res = curl_easy_perform(curl);
        
        if(res == CURLE_OK) {
            curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &responseCode);
            return true;
        }
        
        return false;
    }
    
    bool post(const std::string& url, const std::string& data) {
        if(!curl) return false;
        
        responseBody.clear();
        responseHeader.clear();
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_POST, 1L);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBody);
        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, HeaderCallback);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, &responseHeader);
        
        if(headers) {
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        }
        
        CURLcode res = curl_easy_perform(curl);
        
        if(res == CURLE_OK) {
            curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &responseCode);
            return true;
        }
        
        return false;
    }
    
    std::string getResponse() const { return responseBody; }
    std::string getHeaders() const { return responseHeader; }
    long getResponseCode() const { return responseCode; }
};

// 使用示例
int main() {
    curl_global_init(CURL_GLOBAL_DEFAULT);
    
    HttpClient client;
    client.addHeader("User-Agent: MyApp/1.0");
    client.setTimeout(10);
    
    if(client.get("http://httpbin.org/get")) {
        std::cout << "Response Code: " << client.getResponseCode() << std::endl;
        std::cout << "Body: " << client.getResponse() << std::endl;
    }
    
    curl_global_cleanup();
    return 0;
}
```

## 七、常用选项说明

| 选项                     | 说明            |
| ---------------------- | ------------- |
| CURLOPT_URL            | 设置请求的URL      |
| CURLOPT_WRITEFUNCTION  | 设置数据接收回调函数    |
| CURLOPT_WRITEDATA      | 设置回调函数的用户数据指针 |
| CURLOPT_TIMEOUT        | 设置超时时间（秒）     |
| CURLOPT_FOLLOWLOCATION | 是否跟随重定向       |
| CURLOPT_POST           | 设置为POST请求     |
| CURLOPT_POSTFIELDS     | POST数据        |
| CURLOPT_HTTPHEADER     | 自定义HTTP头      |
| CURLOPT_SSL_VERIFYPEER | 是否验证SSL证书     |
| CURLOPT_VERBOSE        | 输出详细调试信息      |

## 八、错误处理

```cpp
CURLcode res = curl_easy_perform(curl);
if(res != CURLE_OK) {
    // 方式1: 使用 curl_easy_strerror
    std::cerr << "Error: " << curl_easy_strerror(res) << std::endl;
    
    // 方式2: 使用自定义错误缓冲区
    char errbuf[CURL_ERROR_SIZE];
    curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, errbuf);
    // ... 执行请求
    std::cerr << "Error: " << errbuf << std::endl;
}
```

## 九、最佳实践

1. **全局初始化只调用一次**
2. **使用RAII管理资源**（如上面的HttpClient类）
3. **设置合理的超时时间**
4. **正确处理SSL证书验证**
5. **使用连接池提高性能**（multi interface）
6. **及时释放资源**


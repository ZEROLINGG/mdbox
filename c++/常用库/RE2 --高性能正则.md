## RE2 正则表达式库详解

RE2是Google开发的一个高效、安全的正则表达式库，它牺牲了一些功能来保证线性时间复杂度和避免回溯。

## 1. RE2的特点

### 优点
- **性能保证**：最坏情况下也是O(n)时间复杂度
- **安全性**：不会因为恶意输入导致程序崩溃
- **线程安全**：RE2对象是线程安全的
- **内存可控**：不会出现指数级内存消耗

### 限制
- 不支持反向引用
- 不支持环视断言(lookaround)
- 某些复杂模式可能不支持

## 2. 安装配置

### Ubuntu/Debian
```bash
sudo apt-get install libre2-dev
```

### 从源码编译
```bash
git clone https://github.com/google/re2.git
cd re2
make
sudo make install
```

### CMake配置
```cmake
find_package(re2 REQUIRED)
target_link_libraries(your_target re2::re2)
```

## 3. 基本使用

### 3.1 简单匹配

```cpp
#include <re2/re2.h>
#include <iostream>
#include <string>

int main() {
    std::string text = "Hello World 123";
    
    // 完全匹配
    if (RE2::FullMatch(text, "Hello World \\d+")) {
        std::cout << "完全匹配成功\n";
    }
    
    // 部分匹配
    if (RE2::PartialMatch(text, "\\d+")) {
        std::cout << "找到数字\n";
    }
    
    return 0;
}
```

### 3.2 提取匹配内容

```cpp
#include <re2/re2.h>
#include <iostream>

int main() {
    std::string email = "user@example.com";
    std::string user, domain;
    
    // 提取邮箱的用户名和域名
    if (RE2::FullMatch(email, "([^@]+)@([^@]+)", &user, &domain)) {
        std::cout << "用户名: " << user << "\n";
        std::cout << "域名: " << domain << "\n";
    }
    
    // 提取多个数字
    std::string text = "价格是 123.45 元";
    double price;
    if (RE2::PartialMatch(text, "(\\d+\\.\\d+)", &price)) {
        std::cout << "价格: " << price << "\n";
    }
    
    return 0;
}
```

## 4. RE2对象使用

### 4.1 预编译正则表达式

```cpp
#include <re2/re2.h>
#include <iostream>

int main() {
    // 预编译正则表达式（推荐用于重复使用的模式）
    RE2 pattern("\\b\\w+@\\w+\\.\\w+\\b");
    
    // 检查编译是否成功
    if (!pattern.ok()) {
        std::cout << "正则表达式错误: " << pattern.error() << "\n";
        return 1;
    }
    
    // 使用预编译的模式
    std::string text = "联系我: alice@example.com 或 bob@test.org";
    std::string email;
    
    if (RE2::PartialMatch(text, pattern)) {
        std::cout << "找到邮箱地址\n";
    }
    
    return 0;
}
```

### 4.2 配置选项

```cpp
#include <re2/re2.h>
#include <iostream>

int main() {
    // 创建配置选项
    RE2::Options opts;
    opts.set_case_sensitive(false);  // 忽略大小写
    opts.set_dot_nl(true);           // . 匹配换行符
    opts.set_max_mem(1024 * 1024);   // 设置最大内存使用
    
    // 使用配置创建RE2对象
    RE2 pattern("hello.*world", opts);
    
    if (RE2::PartialMatch("HELLO\nWORLD", pattern)) {
        std::cout << "匹配成功（忽略大小写，跨行）\n";
    }
    
    return 0;
}
```

## 5. 高级功能

### 5.1 FindAndConsume

```cpp
#include <re2/re2.h>
#include <iostream>
#include <string>

int main() {
    std::string input = "apple:100 banana:200 orange:150";
    re2::StringPiece sp(input);
    
    std::string item;
    int price;
    
    // 逐个提取商品和价格
    while (RE2::FindAndConsume(&sp, "(\\w+):(\\d+)", &item, &price)) {
        std::cout << item << " 价格: " << price << "\n";
    }
    
    return 0;
}
```

### 5.2 替换操作

```cpp
#include <re2/re2.h>
#include <iostream>
#include <string>

int main() {
    std::string text = "Hello 123 World 456";
    
    // 替换第一个匹配
    if (RE2::Replace(&text, "\\d+", "XXX")) {
        std::cout << "替换后: " << text << "\n";  // Hello XXX World 456
    }
    
    // 替换所有匹配
    text = "Hello 123 World 456";
    int count = RE2::GlobalReplace(&text, "\\d+", "XXX");
    std::cout << "替换了 " << count << " 处\n";
    std::cout << "结果: " << text << "\n";  // Hello XXX World XXX
    
    // 使用捕获组进行替换
    text = "John Smith";
    RE2::Replace(&text, "(\\w+) (\\w+)", "\\2, \\1");
    std::cout << "姓名格式: " << text << "\n";  // Smith, John
    
    return 0;
}
```

### 5.3 命名捕获组

```cpp
#include <re2/re2.h>
#include <iostream>
#include <map>

int main() {
    // 使用命名捕获组
    RE2 pattern("(?P<year>\\d{4})-(?P<month>\\d{2})-(?P<day>\\d{2})");
    
    std::string date = "2024-03-15";
    std::string year, month, day;
    
    // 方法1：按顺序提取
    if (RE2::FullMatch(date, pattern, &year, &month, &day)) {
        std::cout << "年: " << year << ", 月: " << month << ", 日: " << day << "\n";
    }
    
    // 方法2：获取命名捕获组信息
    const std::map<std::string, int>& groups = pattern.NamedCapturingGroups();
    for (const auto& [name, index] : groups) {
        std::cout << "组名: " << name << ", 索引: " << index << "\n";
    }
    
    return 0;
}
```

## 6. 实用示例

### 6.1 URL解析

```cpp
#include <re2/re2.h>
#include <iostream>

class URLParser {
private:
    RE2 pattern;
    
public:
    URLParser() : pattern(
        "^(https?)://([^/:]+)(:(\\d+))?(/.*)?$"
    ) {}
    
    bool parse(const std::string& url) {
        std::string protocol, host, port_str, path;
        int port = 0;
        
        if (RE2::FullMatch(url, pattern, 
                           &protocol, &host, (void*)nullptr, &port_str, &path)) {
            std::cout << "协议: " << protocol << "\n";
            std::cout << "主机: " << host << "\n";
            
            if (!port_str.empty()) {
                port = std::stoi(port_str);
                std::cout << "端口: " << port << "\n";
            }
            
            if (!path.empty()) {
                std::cout << "路径: " << path << "\n";
            }
            
            return true;
        }
        return false;
    }
};

int main() {
    URLParser parser;
    parser.parse("https://example.com:8080/api/data");
    return 0;
}
```

### 6.2 日志分析

```cpp
#include <re2/re2.h>
#include <iostream>
#include <fstream>
#include <string>

class LogAnalyzer {
private:
    RE2 log_pattern;
    
public:
    LogAnalyzer() : log_pattern(
        "\\[(\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2})\\] "
        "\\[(\\w+)\\] (.+)"
    ) {}
    
    void analyze(const std::string& line) {
        std::string timestamp, level, message;
        
        if (RE2::FullMatch(line, log_pattern, 
                           &timestamp, &level, &message)) {
            if (level == "ERROR" || level == "FATAL") {
                std::cout << "严重错误 [" << timestamp << "]: " 
                         << message << "\n";
            }
        }
    }
    
    void analyzeFile(const std::string& filename) {
        std::ifstream file(filename);
        std::string line;
        
        while (std::getline(file, line)) {
            analyze(line);
        }
    }
};
```

### 6.3 数据验证

```cpp
#include <re2/re2.h>
#include <iostream>

class Validator {
private:
    RE2 email_pattern;
    RE2 phone_pattern;
    RE2 ip_pattern;
    
public:
    Validator() : 
        email_pattern("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"),
        phone_pattern("^\\+?[1-9]\\d{1,14}$"),
        ip_pattern("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}"
                  "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$") {}
    
    bool isValidEmail(const std::string& email) {
        return RE2::FullMatch(email, email_pattern);
    }
    
    bool isValidPhone(const std::string& phone) {
        return RE2::FullMatch(phone, phone_pattern);
    }
    
    bool isValidIP(const std::string& ip) {
        return RE2::FullMatch(ip, ip_pattern);
    }
};

int main() {
    Validator validator;
    
    std::cout << "Email valid: " 
              << validator.isValidEmail("user@example.com") << "\n";
    std::cout << "Phone valid: " 
              << validator.isValidPhone("+1234567890") << "\n";
    std::cout << "IP valid: " 
              << validator.isValidIP("192.168.1.1") << "\n";
    
    return 0;
}
```

## 7. 性能优化建议

1. **预编译模式**：对于重复使用的正则表达式，使用RE2对象而不是静态方法
2. **避免贪婪匹配**：使用非贪婪量词（如`*?`、`+?`）
3. **使用原始字符串**：使用`R"(regex)"`避免转义
4. **设置合理的内存限制**：通过Options控制内存使用
5. **使用StringPiece**：避免不必要的字符串复制

## 8. 注意事项

1. RE2不支持所有PCRE特性
2. 对于简单匹配，考虑使用标准库函数
3. 注意线程安全：RE2对象可以在多线程中共享
4. 合理处理编译失败的情况
5. 使用`FullMatch`还是`PartialMatch`取决于具体需求

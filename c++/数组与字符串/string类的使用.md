C++ 中的 `std::string` 类是标准库提供的字符串类，相比 C 风格字符串更安全、更易用、功能更强大。它是现代 C++ 中处理字符串的首选方式。

## string 类的基础

### 包含头文件和基本声明

```cpp
#include <iostream>
#include <string>
#include <vector>

int main() {
    // 1. 默认构造函数 - 空字符串
    std::string str1;
    std::cout << "str1: '" << str1 << "', length: " << str1.length() << std::endl;
    
    // 2. 从 C 风格字符串构造
    std::string str2("Hello World");
    std::string str3 = "Hello C++";
    
    // 3. 拷贝构造函数
    std::string str4(str2);
    std::string str5 = str3;
    
    // 4. 从字符构造（重复 n 次）
    std::string str6(5, 'A');  // "AAAAA"
    
    // 5. 从子字符串构造
    std::string str7(str2, 6);      // 从位置 6 开始到末尾："World"
    std::string str8(str2, 0, 5);   // 从位置 0 开始，长度 5："Hello"
    
    // 6. C++11 初始化列表
    std::string str9{'H', 'e', 'l', 'l', 'o'};
    
    // 7. C++11 统一初始化
    std::string str10{"Modern C++"};
    
    std::cout << "str2: " << str2 << std::endl;
    std::cout << "str6: " << str6 << std::endl;
    std::cout << "str7: " << str7 << std::endl;
    std::cout << "str8: " << str8 << std::endl;
    
    return 0;
}
```

### 基本属性和容量

```cpp
#include <iostream>
#include <string>

int main() {
    std::string str = "Hello World";
    
    // 长度和大小
    std::cout << "Length: " << str.length() << std::endl;    // 11
    std::cout << "Size: " << str.size() << std::endl;        // 11 (等价于 length)
    std::cout << "Capacity: " << str.capacity() << std::endl; // 实际分配的内存大小
    std::cout << "Max size: " << str.max_size() << std::endl; // 理论最大大小
    
    // 检查是否为空
    std::cout << "Is empty: " << std::boolalpha << str.empty() << std::endl;
    
    std::string emptyStr;
    std::cout << "Empty string is empty: " << emptyStr.empty() << std::endl;
    
    // 预分配内存
    str.reserve(100);  // 预分配至少 100 字符的空间
    std::cout << "After reserve(100), capacity: " << str.capacity() << std::endl;
    
    // 调整大小
    str.resize(5);     // 截断为 5 个字符："Hello"
    std::cout << "After resize(5): '" << str << "'" << std::endl;
    
    str.resize(10, '*'); // 扩展到 10 个字符，用 '*' 填充："Hello*****"
    std::cout << "After resize(10, '*'): '" << str << "'" << std::endl;
    
    // 清空字符串
    str.clear();
    std::cout << "After clear: '" << str << "', empty: " << str.empty() << std::endl;
    
    return 0;
}
```

## 字符串访问和修改

### 元素访问

```cpp
#include <iostream>
#include <string>

int main() {
    std::string str = "Hello World";
    
    // 1. 下标运算符 [] - 不进行边界检查
    std::cout << "First character: " << str[0] << std::endl;
    std::cout << "Last character: " << str[str.length() - 1] << std::endl;
    
    // 修改字符
    str[0] = 'h';
    std::cout << "After modification: " << str << std::endl;
    
    // 2. at() 方法 - 进行边界检查，越界会抛出异常
    try {
        std::cout << "Character at index 6: " << str.at(6) << std::endl;
        // std::cout << str.at(100) << std::endl;  // 会抛出 std::out_of_range 异常
    } catch (const std::out_of_range& e) {
        std::cout << "Exception: " << e.what() << std::endl;
    }
    
    // 3. front() 和 back() - C++11
    std::cout << "Front: " << str.front() << std::endl;  // 第一个字符
    std::cout << "Back: " << str.back() << std::endl;    // 最后一个字符
    
    // 4. 获取 C 风格字符串
    const char* cstr = str.c_str();  // 返回以 null 结尾的 C 字符串
    std::cout << "C-style string: " << cstr << std::endl;
    
    const char* data_ptr = str.data();  // C++11 前不保证 null 结尾，C++11 后等价于 c_str()
    std::cout << "Data pointer: " << data_ptr << std::endl;
    
    // 5. 遍历字符串
    std::cout << "Characters: ";
    for (size_t i = 0; i < str.length(); ++i) {
        std::cout << str[i] << " ";
    }
    std::cout << std::endl;
    
    // 6. 范围 for 循环 (C++11)
    std::cout << "Range-based for: ";
    for (char c : str) {
        std::cout << c << " ";
    }
    std::cout << std::endl;
    
    // 7. 迭代器
    std::cout << "Using iterators: ";
    for (auto it = str.begin(); it != str.end(); ++it) {
        std::cout << *it << " ";
    }
    std::cout << std::endl;
    
    return 0;
}
```

### 字符串赋值

```cpp
#include <iostream>
#include <string>

int main() {
    std::string str;
    
    // 1. 赋值运算符
    str = "Hello";
    std::cout << "Assignment operator: " << str << std::endl;
    
    str = 'A';  // 单个字符赋值
    std::cout << "Single char assignment: " << str << std::endl;
    
    std::string other = "World";
    str = other;  // 字符串对象赋值
    std::cout << "String object assignment: " << str << std::endl;
    
    // 2. assign() 方法
    str.assign("New String");
    std::cout << "assign(): " << str << std::endl;
    
    str.assign(5, 'X');  // 5 个 'X'
    std::cout << "assign(5, 'X'): " << str << std::endl;
    
    str.assign(other, 1, 3);  // 从 other 的位置 1 开始，长度 3
    std::cout << "assign(other, 1, 3): " << str << std::endl;
    
    // 3. C++11 移动赋值
    std::string temp = "Temporary";
    str = std::move(temp);  // 移动赋值，temp 变为空
    std::cout << "Move assignment: " << str << std::endl;
    std::cout << "temp after move: '" << temp << "'" << std::endl;
    
    return 0;
}
```

## 字符串连接和追加

### 字符串连接

```cpp
#include <iostream>
#include <string>

int main() {
    std::string str1 = "Hello";
    std::string str2 = "World";
    
    // 1. + 运算符
    std::string result1 = str1 + " " + str2;
    std::cout << "Using +: " << result1 << std::endl;
    
    std::string result2 = str1 + " C++";
    std::cout << "String + literal: " << result2 << std::endl;
    
    std::string result3 = "Welcome to " + str2;
    std::cout << "Literal + string: " << result3 << std::endl;
    
    // 2. += 运算符
    std::string str3 = "Hello";
    str3 += " ";
    str3 += str2;
    str3 += "!";
    std::cout << "Using +=: " << str3 << std::endl;
    
    // 3. append() 方法
    std::string str4 = "C++";
    str4.append(" is");
    str4.append(" awesome", 8);  // 只追加前 8 个字符
    str4.append(3, '!');         // 追加 3 个 '!' 字符
    std::cout << "Using append(): " << str4 << std::endl;
    
    // 4. 链式操作
    std::string str5;
    str5.append("Learning").append(" ").append("C++").append(" is fun!");
    std::cout << "Chain append: " << str5 << std::endl;
    
    // 5. 性能比较示例
    auto start = std::chrono::high_resolution_clock::now();
    
    // 低效方式：多次重新分配
    std::string inefficient;
    for (int i = 0; i < 10000; ++i) {
        inefficient += "a";
    }
    
    auto mid = std::chrono::high_resolution_clock::now();
    
    // 高效方式：预分配空间
    std::string efficient;
    efficient.reserve(10000);
    for (int i = 0; i < 10000; ++i) {
        efficient += "a";
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    
    std::cout << "Inefficient time: " 
              << std::chrono::duration_cast<std::chrono::microseconds>(mid - start).count() 
              << " microseconds" << std::endl;
    std::cout << "Efficient time: " 
              << std::chrono::duration_cast<std::chrono::microseconds>(end - mid).count() 
              << " microseconds" << std::endl;
    
    return 0;
}
```

## 字符串查找和搜索

### 基本查找操作

```cpp
#include <iostream>
#include <string>

int main() {
    std::string text = "Hello World, Hello C++, Hello Programming";
    
    // 1. find() - 查找子字符串
    size_t pos = text.find("Hello");
    if (pos != std::string::npos) {
        std::cout << "First 'Hello' found at position: " << pos << std::endl;
    }
    
    // 从指定位置开始查找
    pos = text.find("Hello", 1);  // 从位置 1 开始查找
    std::cout << "Second 'Hello' found at position: " << pos << std::endl;
    
    // 查找字符
    pos = text.find('W');
    std::cout << "'W' found at position: " << pos << std::endl;
    
    // 2. rfind() - 反向查找
    pos = text.rfind("Hello");
    std::cout << "Last 'Hello' found at position: " << pos << std::endl;
    
    // 3. find_first_of() - 查找任意指定字符中的第一个
    pos = text.find_first_of("aeiou");  // 查找第一个元音字母
    if (pos != std::string::npos) {
        std::cout << "First vowel '" << text[pos] << "' at position: " << pos << std::endl;
    }
    
    // 4. find_last_of() - 查找任意指定字符中的最后一个
    pos = text.find_last_of("aeiou");
    if (pos != std::string::npos) {
        std::cout << "Last vowel '" << text[pos] << "' at position: " << pos << std::endl;
    }
    
    // 5. find_first_not_of() - 查找第一个不在指定字符集中的字符
    pos = text.find_first_not_of("Hello ");
    if (pos != std::string::npos) {
        std::cout << "First non-'Hello ' char '" << text[pos] << "' at position: " << pos << std::endl;
    }
    
    // 6. find_last_not_of() - 查找最后一个不在指定字符集中的字符
    pos = text.find_last_not_of("gramming");
    if (pos != std::string::npos) {
        std::cout << "Last non-'gramming' char '" << text[pos] << "' at position: " << pos << std::endl;
    }
    
    // 7. 查找所有匹配项
    std::cout << "\nAll occurrences of 'Hello':" << std::endl;
    pos = 0;
    while ((pos = text.find("Hello", pos)) != std::string::npos) {
        std::cout << "Found at position: " << pos << std::endl;
        pos += 5;  // 移动到下一个可能的位置
    }
    
    return 0;
}
```

### 高级查找示例

```cpp
#include <iostream>
#include <string>
#include <vector>

// 查找所有匹配的子字符串
std::vector<size_t> findAll(const std::string& text, const std::string& pattern) {
    std::vector<size_t> positions;
    size_t pos = 0;
    
    while ((pos = text.find(pattern, pos)) != std::string::npos) {
        positions.push_back(pos);
        pos += pattern.length();
    }
    
    return positions;
}

// 统计子字符串出现次数
int countOccurrences(const std::string& text, const std::string& pattern) {
    int count = 0;
    size_t pos = 0;
    
    while ((pos = text.find(pattern, pos)) != std::string::npos) {
        ++count;
        pos += pattern.length();
    }
    
    return count;
}

// 检查字符串是否包含指定模式
bool contains(const std::string& text, const std::string& pattern) {
    return text.find(pattern) != std::string::npos;
}

int main() {
    std::string document = "The quick brown fox jumps over the lazy dog.
```

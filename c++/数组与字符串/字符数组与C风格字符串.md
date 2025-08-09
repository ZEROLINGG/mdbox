C++ 中的字符数组和 C 风格字符串是处理文本数据的基础方式。虽然现代 C++ 推荐使用 `std::string`，但理解字符数组和 C 风格字符串仍然非常重要。

## 字符数组基础

### 字符数组的声明和初始化

```cpp
#include <iostream>
#include <cstring>

int main() {
    // 1. 声明字符数组（未初始化）
    char arr1[10];  // 包含垃圾值
    
    // 2. 逐个字符初始化
    char arr2[6] = {'H', 'e', 'l', 'l', 'o', '\0'};
    
    // 3. 部分初始化
    char arr3[10] = {'A', 'B', 'C'};  // 剩余位置自动填充 '\0'
    
    // 4. 全零初始化
    char arr4[10] = {};  // 所有元素初始化为 '\0'
    char arr5[10] = {0}; // 等价写法
    
    // 5. 字符串字面量初始化
    char arr6[10] = "Hello";     // 自动添加 '\0'
    char arr7[] = "World";       // 自动推导大小为 6（包括 '\0'）
    
    // 6. C++11 统一初始化
    char arr8{'H', 'i', '\0'};
    char arr9{"Hello"};
    
    // 输出字符数组
    std::cout << "arr2: " << arr2 << std::endl;
    std::cout << "arr6: " << arr6 << std::endl;
    std::cout << "arr7: " << arr7 << std::endl;
    
    // 显示数组大小
    std::cout << "Size of arr6: " << sizeof(arr6) << std::endl;  // 10
    std::cout << "Size of arr7: " << sizeof(arr7) << std::endl;  // 6
    
    return 0;
}
```

### 字符数组 vs 字符指针

```cpp
#include <iostream>

int main() {
    // 字符数组：在栈上分配，可修改
    char arr[] = "Hello";
    std::cout << "Array: " << arr << std::endl;
    std::cout << "Array address: " << static_cast<void*>(arr) << std::endl;
    std::cout << "Array size: " << sizeof(arr) << std::endl;  // 6
    
    // 修改字符数组
    arr[0] = 'h';
    std::cout << "Modified array: " << arr << std::endl;
    
    // 字符指针：指向字符串字面量，通常不可修改
    const char* ptr = "World";
    std::cout << "Pointer: " << ptr << std::endl;
    std::cout << "Pointer address: " << static_cast<const void*>(ptr) << std::endl;
    std::cout << "Pointer size: " << sizeof(ptr) << std::endl;  // 8 (64位系统)
    
    // ptr[0] = 'w';  // 错误！字符串字面量通常存储在只读内存中
    
    // 字符指针指向字符数组
    char* mutablePtr = arr;
    mutablePtr[1] = 'E';
    std::cout << "Through pointer: " << mutablePtr << std::endl;
    
    return 0;
}
```

## C 风格字符串

### C 风格字符串的特点

```cpp
#include <iostream>
#include <cstring>

void demonstrateNullTerminator() {
    char str1[] = "Hello";
    char str2[10];
    
    // 手动构建字符串
    str2[0] = 'W';
    str2[1] = 'o';
    str2[2] = 'r';
    str2[3] = 'l';
    str2[4] = 'd';
    str2[5] = '\0';  // 必须手动添加空终止符
    
    std::cout << "str1: " << str1 << std::endl;
    std::cout << "str2: " << str2 << std::endl;
    
    // 显示字符串的实际内容（包括 '\0'）
    std::cout << "str1 characters: ";
    for (int i = 0; i <= 5; ++i) {
        if (str1[i] == '\0') {
            std::cout << "\\0 ";
        } else {
            std::cout << str1[i] << " ";
        }
    }
    std::cout << std::endl;
    
    // 没有空终止符的"字符串"
    char notString[5] = {'H', 'e', 'l', 'l', 'o'};  // 没有 '\0'
    std::cout << "Not a proper string: " << notString << std::endl;  // 可能输出垃圾字符
}

int main() {
    demonstrateNullTerminator();
    return 0;
}
```

### 字符串长度和大小

```cpp
#include <iostream>
#include <cstring>

int main() {
    char str1[20] = "Hello";
    char str2[] = "World";
    
    // sizeof：数组的总大小（字节数）
    std::cout << "sizeof(str1): " << sizeof(str1) << std::endl;  // 20
    std::cout << "sizeof(str2): " << sizeof(str2) << std::endl;  // 6
    
    // strlen：字符串的实际长度（不包括 '\0'）
    std::cout << "strlen(str1): " << strlen(str1) << std::endl;  // 5
    std::cout << "strlen(str2): " << strlen(str2) << std::endl;  // 5
    
    // 自定义 strlen 实现
    auto myStrlen = [](const char* str) -> size_t {
        size_t length = 0;
        while (str[length] != '\0') {
            ++length;
        }
        return length;
    };
    
    std::cout << "myStrlen(str1): " << myStrlen(str1) << std::endl;
    
    // 显示字符串的内存布局
    std::cout << "str1 memory layout: ";
    for (size_t i = 0; i < sizeof(str1); ++i) {
        if (str1[i] == '\0') {
            std::cout << "\\0 ";
        } else if (str1[i] == 0) {
            std::cout << "0 ";
        } else {
            std::cout << str1[i] << " ";
        }
    }
    std::cout << std::endl;
    
    return 0;
}
```

## 字符串操作函数

### 基本字符串函数

```cpp
#include <iostream>
#include <cstring>
#include <cctype>

int main() {
    char str1[50] = "Hello";
    char str2[50] = "World";
    char str3[50];
    char str4[50] = "Hello World";
    
    // 1. strcpy - 字符串复制
    strcpy(str3, str1);
    std::cout << "strcpy result: " << str3 << std::endl;
    
    // 2. strcat - 字符串连接
    strcat(str1, " ");
    strcat(str1, str2);
    std::cout << "strcat result: " << str1 << std::endl;
    
    // 3. strcmp - 字符串比较
    int cmp1 = strcmp("abc", "abc");  // 0 (相等)
    int cmp2 = strcmp("abc", "abd");  // < 0 (第一个小于第二个)
    int cmp3 = strcmp("abd", "abc");  // > 0 (第一个大于第二个)
    
    std::cout << "strcmp results: " << cmp1 << ", " << cmp2 << ", " << cmp3 << std::endl;
    
    // 4. strchr - 查找字符
    char* found = strchr(str4, 'W');
    if (found) {
        std::cout << "Found 'W' at position: " << (found - str4) << std::endl;
    }
    
    // 5. strstr - 查找子字符串
    char* substr = strstr(str4, "World");
    if (substr) {
        std::cout << "Found 'World' at position: " << (substr - str4) << std::endl;
    }
    
    // 6. 安全版本的函数
    char safe1[10];
    char safe2[10] = "Test";
    
    strncpy(safe1, "Very long string", sizeof(safe1) - 1);
    safe1[sizeof(safe1) - 1] = '\0';  // 确保空终止
    std::cout << "strncpy result: " << safe1 << std::endl;
    
    strncat(safe2, " String", sizeof(safe2) - strlen(safe2) - 1);
    std::cout << "strncat result: " << safe2 << std::endl;
    
    return 0;
}
```

### 字符处理函数

```cpp
#include <iostream>
#include <cctype>
#include <cstring>

void processString(char* str) {
    std::cout << "Original: " << str << std::endl;
    
    // 转换为大写
    char upper[100];
    strcpy(upper, str);
    for (int i = 0; upper[i]; ++i) {
        upper[i] = toupper(upper[i]);
    }
    std::cout << "Uppercase: " << upper << std::endl;
    
    // 转换为小写
    char lower[100];
    strcpy(lower, str);
    for (int i = 0; lower[i]; ++i) {
        lower[i] = tolower(lower[i]);
    }
    std::cout << "Lowercase: " << lower << std::endl;
    
    // 统计字符类型
    int letters = 0, digits = 0, spaces = 0, others = 0;
    for (int i = 0; str[i]; ++i) {
        if (isalpha(str[i])) letters++;
        else if (isdigit(str[i])) digits++;
        else if (isspace(str[i])) spaces++;
        else others++;
    }
    
    std::cout << "Statistics - Letters: " << letters 
              << ", Digits: " << digits 
              << ", Spaces: " << spaces 
              << ", Others: " << others << std::endl;
}

int main() {
    char text[] = "Hello World 123!";
    processString(text);
    
    return 0;
}
```

## 字符串输入输出

### 不同的输入方式

```cpp
#include <iostream>
#include <cstring>

int main() {
    char name[50];
    char sentence[200];
    char word[50];
    
    std::cout << "Enter your name: ";
    std::cin >> name;  // 读取到空白字符为止
    std::cout << "Hello, " << name << std::endl;
    
    // 清除输入缓冲区
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    
    std::cout << "Enter a sentence: ";
    std::cin.getline(sentence, sizeof(sentence));  // 读取整行
    std::cout << "You said: " << sentence << std::endl;
    
    std::cout << "Enter another word: ";
    std::cin.get(word, sizeof(word));  // 类似 getline，但不消费换行符
    std::cout << "Word: " << word << std::endl;
    
    // 使用 fgets（更安全）
    std::cout << "Enter text with fgets: ";
    std::cin.ignore();  // 清除之前的换行符
    if (fgets(sentence, sizeof(sentence), stdin)) {
        // fgets 包含换行符，需要移除
        size_t len = strlen(sentence);
        if (len > 0 && sentence[len-1] == '\n') {
            sentence[len-1] = '\0';
        }
        std::cout << "fgets result: " << sentence << std::endl;
    }
    
    return 0;
}
```

### 格式化输入输出

```cpp
#include <iostream>
#include <cstdio>
#include <cstring>

int main() {
    char buffer[100];
    char name[50];
    int age;
    double salary;
    
    // sprintf - 格式化输出到字符串
    sprintf(buffer, "Name: %s, Age: %d, Salary: %.2f", "John", 30, 50000.75);
    std::cout << "sprintf result: " << buffer << std::endl;
    
    // snprintf - 安全版本
    snprintf(buffer, sizeof(buffer), "Safe formatting: %d", 12345);
    std::cout << "snprintf result: " << buffer << std::endl;
    
    // sscanf - 从字符串解析
    strcpy(buffer, "Alice 25 45000.50");
    if (sscanf(buffer, "%s %d %lf", name, &age, &salary) == 3) {
        std::cout << "Parsed - Name: " << name 
                  << ", Age: " << age 
                  << ", Salary: " << salary << std::endl;
    }
    
    // 自定义格式化函数
    auto formatPerson = [](char* dest, size_t size, const char* name, int age) {
        snprintf(dest, size, "[Person: %s, %d years old]", name, age);
    };
    
    formatPerson(buffer, sizeof(buffer), "Bob", 35);
    std::cout << "Custom format: " << buffer << std::endl;
    
    return 0;
}
```

## 字符串数组

### 字符串数组的不同表示方法

```cpp
#include <iostream>
#include <cstring>

int main() {
    // 1. 二维字符数组
    char names1[3][20] = {
        "Alice",
        "Bob", 
        "Charlie"
    };
    
    // 2. 字符指针数组
    const char* names2[] = {
        "David",
        "Eve",
        "Frank"
    };
    
    // 3. 字符指针数组（可修改指针）
    char* names3[] = {
        const_cast<char*>("Grace"),
        const_cast<char*>("Henry"),
        const_cast<char*>("Ivy")
    };
    
    std::cout << "Method 1 - 2D char array:" << std::endl;
    for (int i = 0; i < 3; ++i) {
        std::cout << "names1[" << i << "]: " << names1[i] << std::endl;
        std::cout << "  Address: " << static_cast<void*>(names1[i]) << std::endl;
        std::cout << "  Size: "
```

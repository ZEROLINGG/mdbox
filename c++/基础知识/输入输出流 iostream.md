
C++ 的 I/O 系统是基于一个非常优雅的抽象概念——**流 (Stream)**。一个流就是一个字节序列，你可以从中读取（输入流）或向其写入（输出流）。这个抽象使得我们能用同样的方式来处理不同的 I/O 设备，例如键盘、屏幕、文件，甚至是内存中的字符串。

整个 I/O 库的核心在三个头文件中：

- `<iostream>`: 用于标准输入/输出流（键盘、屏幕）。
- `<fstream>`: 用于文件流。
- `<sstream>`: 用于字符串流（在内存中进行 I/O）。

---

### 第一部分：标准输入输出 (`<iostream>`)

这是最常用、最基础的 I/O 操作。`<iostream>` 库定义了四个标准流对象：

1. `std::cin`: **标准输入流** (Standard Input)，通常关联到键盘。
2. `std::cout`: **标准输出流** (Standard Output)，通常关联到屏幕。
3. `std::cerr`: **标准错误流** (Standard Error)，通常也关联到屏幕。它是**非缓冲的**，意味着消息会立即显示，主要用于输出错误信息。
4. `std::clog`: **标准日志流** (Standard Log)，也关联到屏幕。它是**缓冲的**，意味着消息会先存放在缓冲区，待缓冲区满或刷新时才显示，用于输出日志信息。

#### 1. 基本操作符：`>>` 和 `<<`

- `<<` **(插入运算符)**：用于将数据“插入”到输出流。可以把它想象成数据流向的方向。
- `>>` **(提取运算符)**：用于从输入流中“提取”数据。

```cpp
#include <iostream>
#include <string>

int main() {
    // ---- 输出操作 ----
    std::cout << "Hello, C++!" << std::endl; // 输出字符串和换行符
    int age = 25;
    std::cout << "My age is: " << age << std::endl; // 可以链式调用

    // ---- 输入操作 ----
    int your_age;
    std::string name;

    std::cout << "Please enter your name: ";
    std::cin >> name; // 读取一个单词（遇到空格、制表符或换行符停止）

    std::cout << "Please enter your age: ";
    std::cin >> your_age;

    std::cout << "Hello, " << name << "! You are " << your_age << " years old." << std::endl;

    return 0;
}
```

**注意**：`std::cin >> name;` 只会读取到第一个空白字符（空格、Tab、换行）之前的内容。如果输入 "John Doe"，`name` 只会得到 "John"。

#### 2. 读取整行文本：`std::getline`

要解决上面 `std::cin` 读取单词的问题，我们需要使用 `std::getline` 函数来读取一整行。

```cpp
#include <iostream>
#include <string>

int main() {
    std::string full_name;
    std::cout << "Please enter your full name: ";
    std::getline(std::cin, full_name); // 读取一整行，直到遇到换行符

    std::cout << "Welcome, " << full_name << "!" << std::endl;
    return 0;
}
```

**常见陷阱**：在 `std::cin >> var;` 和 `std::getline()` 混合使用时，`>>` 操作会把换行符 `\n` 留在输入缓冲区中。`getline` 看到这个换行符会立即停止读取，导致得到一个空字符串。**解决方法**：在 `getline` 之前清除缓冲区中的换行符。

```cpp
#include <iostream>
#include <string>
#include <limits> // 需要这个头文件来用 numeric_limits

int main() {
    int id;
    std::string name;

    std::cout << "Enter ID: ";
    std::cin >> id;

    // 清除留在缓冲区中的换行符
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); 
    // 上面这行代码会忽略缓冲区中所有字符，直到找到并丢弃一个换行符

    std::cout << "Enter full name: ";
    std::getline(std::cin, name);

    std::cout << "ID: " << id << ", Name: " << name << std::endl;
    return 0;
}
```

---

### 第二部分：输出格式化 (Manipulators)

我们可以使用**操纵符 (Manipulators)** 来控制输出的格式。一些简单的操纵符在 `<iostream>` 中，而需要参数的操纵符在 `<iomanip>` 头文件中。

- `std::endl`: 插入换行符并**刷新 (flush)** 输出缓冲区。
- `'\n'`: 只插入换行符，不刷新缓冲区。在大量输出时性能更好。
- `std::flush`: 强制刷新输出缓冲区。
- `std::setw(n)`: 设置下一个输出项的字段宽度为 `n`。
- `std::setprecision(n)`: 设置浮点数的输出精度为 `n` 位。
- `std::fixed`: 使用定点表示法显示浮点数。
- `std::scientific`: 使用科学计数法显示浮点数。
- `std::left`, `std::right`: 设置对齐方式（需要 `setw`）。
- `std::setfill(c)`: 当宽度大于输出项时，用字符 `c` 填充。
- `std::hex`, `std::oct`, `std::dec`: 设置整数的显示基数（十六/八/十进制）。

```cpp
#include <iostream>
#include <iomanip> // 必须包含这个头文件
#include <cmath>

int main() {
    double pi = M_PI; // 3.14159265...

    std::cout << "Default PI: " << pi << std::endl;
    std::cout << "PI with precision 3: " << std::setprecision(3) << pi << std::endl;
    std::cout << "PI with precision 10: " << std::setprecision(10) << pi << std::endl;

    // fixed 结合 setprecision 控制小数点后的位数
    std::cout << "PI with fixed 4 decimal places: " << std::fixed << std::setprecision(4) << pi << std::endl;

    int num = 255;
    std::cout << "Number formatting:" << std::endl;
    std::cout << std::setw(10) << "Decimal:" << std::setw(10) << std::dec << num << std::endl;
    std::cout << std::setw(10) << "Hexadecimal:" << std::setw(10) << std::hex << num << std::endl;
    std::cout << std::setw(10) << "Octal:" << std::setw(10) << std::oct << num << std::endl;

    // 演示 setfill 和 left/right 对齐
    std::cout << std::dec; // 切换回十进制
    std::cout << "Left aligned: " << std::left << std::setw(10) << std::setfill('*') << num << "END" << std::endl;
    std::cout << "Right aligned: " << std::right << std::setw(10) << std::setfill('-') << num << "END" << std::endl;
    
    return 0;
}
```

---

### 第三部分：文件输入输出 (`<fstream>`)

`<fstream>` 库提供了三个类来处理文件：

1. `std::ifstream`: **输入文件流** (Input File Stream)，用于从文件读取数据。
2. `std::ofstream`: **输出文件流** (Output File Stream)，用于向文件写入数据。
3. `std::fstream`: **文件流**，可以同时进行读写操作。

操作文件流和操作 `cin`/`cout` 几乎一模一样！

```cpp
#include <iostream>
#include <fstream>
#include <string>

int main() {
    // ---- 写入文件 (ofstream) ----
    std::ofstream outFile("data.txt"); // 创建并打开文件，如果文件已存在则清空内容

    if (!outFile.is_open()) { // 检查文件是否成功打开
        std::cerr << "Error opening file for writing!" << std::endl;
        return 1;
    }

    outFile << "Hello, File!" << std::endl;
    outFile << 42 << std::endl;
    outFile << 3.14 << std::endl;

    outFile.close(); // 关闭文件，释放资源

    // ---- 从文件读取 (ifstream) ----
    std::ifstream inFile("data.txt");

    if (!inFile.is_open()) {
        std::cerr << "Error opening file for reading!" << std::endl;
        return 1;
    }

    std::string line;
    int int_val;
    double double_val;

    // 读取一行
    std::getline(inFile, line);
    // 读取一个整数和一个浮点数
    inFile >> int_val >> double_val;

    inFile.close(); // 关闭文件

    std::cout << "Read from file:" << std::endl;
    std::cout << "Line: " << line << std::endl;
    std::cout << "Integer: " << int_val << std::endl;
    std::cout << "Double: " << double_val << std::endl;

    // ---- 循环读取整个文件 ----
    inFile.open("data.txt"); // 重新打开
    std::cout << "\nReading whole file line by line:" << std::endl;
    while (std::getline(inFile, line)) {
        std::cout << line << std::endl;
    }
    inFile.close();

    // ---- 追加模式 (append) ----
    std::ofstream appendFile("data.txt", std::ios::app); // 使用追加模式打开
    appendFile << "This is an appended line." << std::endl;
    appendFile.close();

    return 0;
}
```

---

### 第四部分：字符串流 (`<sstream>`)

字符串流允许你像操作 `cin`/`cout` 一样来操作内存中的 `std::string` 对象。这在**数据格式转换**和**解析字符串**时非常有用。

- `std::stringstream`: 可读可写的字符串流。

**常见用途：**

1. **将多种数据类型拼接成一个字符串。**
2. **从一个字符串中解析出多种数据类型。**

```cpp
#include <iostream>
#include <sstream>
#include <string>

int main() {
    // ---- 1. 将数据转换为字符串 ----
    std::stringstream ss;
    std::string name = "Alice";
    int score = 95;
    double height = 1.68;

    // 像 cout 一样 "打印" 到 stringstream 中
    ss << "Name: " << name << ", Score: " << score << ", Height: " << height;

    // 从 stringstream 中获取最终的字符串
    std::string result = ss.str();
    std::cout << "Generated string: " << result << std::endl;

    // ---- 2. 从字符串中解析数据 ----
    ss.clear(); // 清空流的状态
    ss.str("Bob 88 1.75"); // 设置新的字符串内容

    std::string parsed_name;
    int parsed_score;
    double parsed_height;

    // 像 cin 一样从 stringstream 中读取
    ss >> parsed_name >> parsed_score >> parsed_height;

    std::cout << "\nParsed data:" << std::endl;
    std::cout << "Name: " << parsed_name << std::endl;
    std::cout << "Score: " << parsed_score << std::endl;
    std::cout << "Height: " << parsed_height << std::endl;

    return 0;
}
```

---

### 第五部分：错误处理和流状态

流对象内部维护着状态位，你可以检查这些状态来判断操作是否成功。

- `good()`: 所有都正常。
- `fail()`: 发生了**可恢复的**逻辑错误，如试图读取一个字母到 `int` 变量。
- `bad()`: 发生了**不可恢复的**系统级错误，如读写时设备故障。
- `eof()`: (End-of-File) 到达了流的末尾。

**检查方式：**流对象可以被隐式转换为 `bool` 类型。如果流处于 `good` 状态，它就是 `true`；否则是 `false`。

```cpp
// 常见的读取循环
while (inFile >> data) {
    // ... process data ...
}
// 这个循环会在读取失败（包括到达文件末尾）时自动终止
// 因为 (inFile >> data) 的结果是 inFile 对象本身，它会被转换为 bool

// 显式检查
if (!std::cin) { // or if (std::cin.fail())
    std::cerr << "Invalid input!" << std::endl;
    // 清除错误状态
    std::cin.clear();
    // 丢弃缓冲区中的错误输入
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}
```

---

### 第六部分：性能和现代 C++

#### 性能优化

默认情况下，C++ 的流 (`cin`/`cout`) 与 C 的标准 I/O (`printf`/`scanf`) 是同步的，这会带来一些性能开销。在高性能需求（如算法竞赛）的场景下，可以关闭同步并解绑 `cin` 和 `cout` 来提速。

```cpp
// 在 main 函数开头加入这两行
std::ios_base::sync_with_stdio(false);
std::cin.tie(nullptr);
```

**警告**：执行此操作后，**不要**混用 C++ 的 `cout`/`cin` 和 C 的 `printf`/`scanf`，否则可能导致输出顺序混乱。

#### 现代方法：C++20 `<format>`

C++20 引入了 `<format>` 库（受 Python 的 `.format()` 启发），提供了一种更安全、更高效、更易读的格式化方式。

```cpp
#include <iostream>
#include <format> // C++20
#include <string>

int main() {
    std::string name = "David";
    int age = 30;

    // 创建一个格式化的字符串
    std::string message = std::format("User {} is {} years old.", name, age);
    std::cout << message << std::endl;

    // C++23 甚至引入了 std::print，可以直接打印，无需 cout
    // std::print("User {} is {} years old.\n", name, age);
}
```

`<format>` 库是类型安全的，并且性能通常优于 iostream 和 `sprintf`，是现代 C++ 中推荐的文本格式化方式。

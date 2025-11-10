# cxxopts 库完整详细教程

## 1. 库概述与特性

### 1.1 什么是 cxxopts
cxxopts 是一个轻量级、仅头文件的 C++ 命令行解析库，由 Jarryd Beck 开发。它提供了类似于 Python 的 argparse 的功能，但专为 C++ 设计。

### 1.2 核心特性详解
```cpp
// 特性展示
#include "cxxopts.hpp"
#include <iostream>

void demonstrateFeatures()
{
    // 1. 自动类型推导
    cxxopts::Options options("demo", "特性演示");
    
    // 2. 链式调用
    options.add_options()
        ("string", "字符串", cxxopts::value<std::string>())
        ("int", "整数", cxxopts::value<int>())
        ("float", "浮点", cxxopts::value<float>())
        ("double", "双精度", cxxopts::value<double>())
        ("bool", "布尔", cxxopts::value<bool>())
        ("vector", "向量", cxxopts::value<std::vector<int>>())
        ("optional", "可选", cxxopts::value<std::string>()->default_value("default"))
        ("implicit", "隐式值", cxxopts::value<std::string>()->implicit_value("implicit"));
    
    // 3. Unicode 支持
    options.add_options("Unicode支持")
        ("中文选项", "支持中文描述", cxxopts::value<std::string>())
        ("emoji", "支持😀表情", cxxopts::value<std::string>());
}
```

### 1.3 版本要求与兼容性
```cpp
// CMakeLists.txt 配置示例
cmake_minimum_required(VERSION 3.10)
project(cxxopts_demo)

set(CMAKE_CXX_STANDARD 11)  # 最低 C++11
# set(CMAKE_CXX_STANDARD 14)  # 推荐 C++14
# set(CMAKE_CXX_STANDARD 17)  # 支持 C++17
# set(CMAKE_CXX_STANDARD 20)  # 支持 C++20

# 检查编译器版本
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.8.1)
        message(FATAL_ERROR "GCC version must be at least 4.8.1")
    endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.3)
        message(FATAL_ERROR "Clang version must be at least 3.3")
    endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.0)
        message(FATAL_ERROR "MSVC version must be at least 19.0")
    endif()
endif()
```

## 2. 安装与配置详解

### 2.1 多种安装方式

#### 方式1：单文件集成
```bash
# 下载最新版本
wget https://raw.githubusercontent.com/jarro2783/cxxopts/master/include/cxxopts.hpp

# 或使用 curl
curl -O https://raw.githubusercontent.com/jarro2783/cxxopts/master/include/cxxopts.hpp

# 下载特定版本
wget https://raw.githubusercontent.com/jarro2783/cxxopts/v3.0.0/include/cxxopts.hpp
```

#### 方式2：Git Submodule
```bash
# 添加为子模块
git submodule add https://github.com/jarro2783/cxxopts.git external/cxxopts
git submodule update --init --recursive

# 在 CMakeLists.txt 中
add_subdirectory(external/cxxopts)
target_link_libraries(your_target cxxopts::cxxopts)
```

#### 方式3：CMake FetchContent（推荐）
```cmake
# CMakeLists.txt
include(FetchContent)

FetchContent_Declare(
    cxxopts
    GIT_REPOSITORY https://github.com/jarro2783/cxxopts.git
    GIT_TAG        v3.1.1  # 使用特定版本
    GIT_SHALLOW    TRUE    # 浅克隆，加快下载
)

FetchContent_MakeAvailable(cxxopts)

# 或者更详细的控制
FetchContent_GetProperties(cxxopts)
if(NOT cxxopts_POPULATED)
    FetchContent_Populate(cxxopts)
    add_subdirectory(${cxxopts_SOURCE_DIR} ${cxxopts_BINARY_DIR})
endif()
```

#### 方式4：包管理器安装

**Conan:**
```bash
# conanfile.txt
[requires]
cxxopts/3.1.1

[generators]
cmake

# 安装
conan install . --build=missing
```

**vcpkg:**
```bash
vcpkg install cxxopts
```

**Ubuntu/Debian:**
```bash
sudo apt-get install libcxxopts-dev
```

**macOS Homebrew:**
```bash
brew install cxxopts
```

msys2:
```bash
pacman -S mingw-w64-x86_64-cxxopts
```

### 2.2 项目配置示例

#### 完整的 CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.10)
project(MyApp VERSION 1.0.0 LANGUAGES CXX)

# C++ 标准设置
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 编译选项
if(MSVC)
    add_compile_options(/W4 /WX)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Werror)
endif()

# 查找或下载 cxxopts
find_package(cxxopts QUIET)
if(NOT cxxopts_FOUND)
    include(FetchContent)
    FetchContent_Declare(
        cxxopts
        GIT_REPOSITORY https://github.com/jarro2783/cxxopts.git
        GIT_TAG v3.1.1
    )
    FetchContent_MakeAvailable(cxxopts)
endif()

# 添加可执行文件
add_executable(myapp src/main.cpp)

# 链接库
target_link_libraries(myapp PRIVATE cxxopts::cxxopts)

# 安装规则
install(TARGETS myapp DESTINATION bin)
```

## 3. 基础 API 详解

### 3.1 Options 类详解

```cpp
#include "cxxopts.hpp"
#include <iostream>

int main(int argc, char* argv[])
{
    // Options 构造函数参数：
    // 1. program: 程序名称
    // 2. help_string: 程序描述
    cxxopts::Options options("myapp", "应用程序详细描述");
    
    // 设置自定义帮助信息宽度
    options.set_width(120);
    
    // 设置制表符扩展
    options.set_tab_expansion(true);
    
    // 允许未识别的选项（不抛出异常）
    options.allow_unrecognised_options();
    
    // 自定义语法显示
    options.custom_help("[选项...] 参数...");
    
    // 设置位置参数帮助
    options.positional_help("[输入文件] [输出文件]");
    
    // 显示位置参数在帮助中
    options.show_positional_help();
    
    return 0;
}
```

### 3.2 add_options 详细用法

```cpp
#include "cxxopts.hpp"
#include <iostream>
#include <vector>

void detailedAddOptions()
{
    cxxopts::Options options("detailed", "详细的 add_options 示例");
    
    // 基本语法：(选项名, 描述, 值类型)
    options.add_options()
        // 1. 简单标志（无参数）
        ("h,help", "打印帮助信息")
        
        // 2. 短选项和长选项
        ("v,verbose", "详细输出")
        ("q,quiet", "静默模式")
        
        // 3. 只有长选项
        ("version", "显示版本")
        
        // 4. 只有短选项
        ("n", "数字", cxxopts::value<int>())
        
        // 5. 带参数的选项
        ("f,file", "文件路径", cxxopts::value<std::string>())
        
        // 6. 带默认值
        ("t,timeout", "超时时间", 
         cxxopts::value<int>()->default_value("30"))
        
        // 7. 隐式值（选项出现但没给值时使用）
        ("o,optimization", "优化级别", 
         cxxopts::value<std::string>()->implicit_value("2")->default_value("0"))
        
        // 8. 向量参数（逗号分隔）
        ("i,include", "包含路径", 
         cxxopts::value<std::vector<std::string>>())
        
        // 9. 布尔选项的不同写法
        ("enable-debug", "启用调试", 
         cxxopts::value<bool>()->default_value("false"))
        
        // 10. 不在帮助中显示的选项
        ("secret", "秘密选项", cxxopts::value<std::string>());
    
    // 分组选项
    options.add_options("Advanced")
        ("cpu", "CPU 核心数", cxxopts::value<int>())
        ("memory", "内存限制", cxxopts::value<std::string>());
    
    options.add_options("Experimental")
        ("experimental", "实验性功能", cxxopts::value<bool>())
        ("unsafe", "不安全操作", cxxopts::value<bool>());
}
```

### 3.3 值类型系统详解

```cpp
#include "cxxopts.hpp"
#include <iostream>
#include <vector>
#include <optional>  // C++17

class ValueTypeDemo
{
public:
    static void demonstrateValueTypes()
    {
        cxxopts::Options options("types", "值类型演示");
        
        // 基础类型
        options.add_options()
            // 整数类型
            ("int8", "8位整数", cxxopts::value<int8_t>())
            ("uint8", "无符号8位", cxxopts::value<uint8_t>())
            ("int16", "16位整数", cxxopts::value<int16_t>())
            ("uint16", "无符号16位", cxxopts::value<uint16_t>())
            ("int32", "32位整数", cxxopts::value<int32_t>())
            ("uint32", "无符号32位", cxxopts::value<uint32_t>())
            ("int64", "64位整数", cxxopts::value<int64_t>())
            ("uint64", "无符号64位", cxxopts::value<uint64_t>())
            
            // 浮点类型
            ("float", "单精度浮点", cxxopts::value<float>())
            ("double", "双精度浮点", cxxopts::value<double>())
            ("long-double", "长双精度", cxxopts::value<long double>())
            
            // 字符和字符串
            ("char", "字符", cxxopts::value<char>())
            ("string", "字符串", cxxopts::value<std::string>())
            
            // 布尔类型
            ("bool", "布尔值", cxxopts::value<bool>())
            
            // 容器类型
            ("vector-int", "整数向量", cxxopts::value<std::vector<int>>())
            ("vector-string", "字符串向量", cxxopts::value<std::vector<std::string>>())
            ("vector-double", "浮点向量", cxxopts::value<std::vector<double>>());
    }
    
    // 自定义类型示例
    struct Point
    {
        double x, y;
    };
    
    // 需要为自定义类型提供解析函数
    static void customTypeExample()
    {
        cxxopts::Options options("custom", "自定义类型");
        
        // 使用字符串接收，然后手动解析
        options.add_options()
            ("point", "坐标点 (x,y)", cxxopts::value<std::string>());
        
        // 解析后转换
        // auto result = options.parse(argc, argv);
        // if (result.count("point"))
        // {
        //     std::string point_str = result["point"].as<std::string>();
        //     Point p = parsePoint(point_str);
        // }
    }
    
    static Point parsePoint(const std::string& str)
    {
        Point p;
        sscanf(str.c_str(), "%lf,%lf", &p.x, &p.y);
        return p;
    }
};
```

## 4. 高级特性详解

### 4.1 位置参数完整示例

```cpp
#include "cxxopts.hpp"
#include <iostream>
#include <vector>

class PositionalArgumentsDemo
{
public:
    static int run(int argc, char* argv[])
    {
        cxxopts::Options options("positional", "位置参数详细示例");
        
        // 添加选项（包括用于位置参数的选项）
        options.add_options()
            ("h,help", "帮助信息")
            ("v,verbose", "详细模式", cxxopts::value<bool>()->default_value("false"))
            // 位置参数选项（不会在命令行中使用 --input 或 --output）
            ("input", "输入文件", cxxopts::value<std::vector<std::string>>())
            ("output", "输出文件", cxxopts::value<std::string>())
            ("extra", "额外参数", cxxopts::value<std::vector<std::string>>());
        
        // 定义位置参数的解析顺序
        // 注意：顺序很重要！
        options.parse_positional({"input", "output", "extra"});
        
        // 设置位置参数的帮助信息
        options.positional_help("[输入文件...] [输出文件] [额外参数...]");
        
        // 在帮助信息中显示位置参数
        options.show_positional_help();
        
        try
        {
            // 解析命令行参数
            auto result = options.parse(argc, argv);
            
            if (result.count("help"))
            {
                std::cout << options.help() << std::endl;
                return 0;
            }
            
            bool verbose = result["verbose"].as<bool>();
            
            // 获取位置参数
            if (result.count("input"))
            {
                auto& inputs = result["input"].as<std::vector<std::string>>();
                if (verbose)
                {
                    std::cout << "输入文件:" << std::endl;
                    for (const auto& input : inputs)
                    {
                        std::cout << "  - " << input << std::endl;
                    }
                }
            }
            
            if (result.count("output"))
            {
                auto output = result["output"].as<std::string>();
                if (verbose)
                {
                    std::cout << "输出文件: " << output << std::endl;
                }
            }
            
            if (result.count("extra"))
            {
                auto& extras = result["extra"].as<std::vector<std::string>>();
                if (verbose)
                {
                    std::cout << "额外参数:" << std::endl;
                    for (const auto& extra : extras)
                    {
                        std::cout << "  - " << extra << std::endl;
                    }
                }
            }
        }
        catch (const cxxopts::exceptions::exception& e)
        {
            std::cerr << "错误: " << e.what() << std::endl;
            return 1;
        }
        
        return 0;
    }
};

// 使用示例：
// ./program file1.txt file2.txt output.txt extra1 extra2
// file1.txt 和 file2.txt -> input
// output.txt -> output  
// extra1 和 extra2 -> extra
```

### 4.2 选项组管理

```cpp
#include "cxxopts.hpp"
#include <iostream>
#include <set>

class OptionGroupsDemo
{
public:
    static void advanced_groups_example()
    {
        cxxopts::Options options("groups", "高级分组示例");
        
        // 默认组（不指定组名）
        options.add_options()
            ("h,help", "显示帮助信息")
            ("version", "显示版本信息")
            ("config", "配置文件路径", cxxopts::value<std::string>());
        
        // 输入/输出组
        options.add_options("Input/Output")
            ("i,input", "输入文件", cxxopts::value<std::vector<std::string>>())
            ("o,output", "输出目录", cxxopts::value<std::string>())
            ("f,format", "输出格式", cxxopts::value<std::string>()->default_value("json"))
            ("encoding", "文件编码", cxxopts::value<std::string>()->default_value("utf-8"));
        
        // 处理选项组
        options.add_options("Processing")
            ("t,threads", "线程数", cxxopts::value<int>()->default_value("4"))
            ("m,memory", "内存限制(MB)", cxxopts::value<int>()->default_value("1024"))
            ("timeout", "超时(秒)", cxxopts::value<int>()->default_value("300"))
            ("retry", "重试次数", cxxopts::value<int>()->default_value("3"));
        
        // 网络选项组
        options.add_options("Network")
            ("host", "服务器地址", cxxopts::value<std::string>()->default_value("localhost"))
            ("p,port", "端口号", cxxopts::value<int>()->default_value("8080"))
            ("ssl", "使用SSL", cxxopts::value<bool>()->default_value("false"))
            ("proxy", "代理服务器", cxxopts::value<std::string>());
        
        // 日志选项组
        options.add_options("Logging")
            ("log-level", "日志级别", cxxopts::value<std::string>()->default_value("info"))
            ("log-file", "日志文件", cxxopts::value<std::string>())
            ("log-format", "日志格式", cxxopts::value<std::string>()->default_value("text"))
            ("verbose", "详细输出", cxxopts::value<bool>()->default_value("false"))
            ("quiet", "静默模式", cxxopts::value<bool>()->default_value("false"));
        
        // 调试选项组
        options.add_options("Debug")
            ("debug", "调试模式", cxxopts::value<bool>())
            ("profile", "性能分析", cxxopts::value<bool>())
            ("trace", "跟踪模式", cxxopts::value<bool>())
            ("dry-run", "演练模式", cxxopts::value<bool>());
        
        // 实验性选项组
        options.add_options("Experimental")
            ("experimental", "启用实验性功能", cxxopts::value<bool>())
            ("beta-features", "Beta功能列表", cxxopts::value<std::vector<std::string>>())
            ("unsafe", "允许不安全操作", cxxopts::value<bool>());
    }
    
    static void print_grouped_help(cxxopts::Options& options)
    {
        // 选择要显示的组及其顺序
        std::vector<std::string> groups = {
            "",              // 默认组
            "Input/Output",
            "Processing",
            "Network",
            "Logging",
            "Debug"
            // 不显示 "Experimental" 组
        };
        
        std::cout << options.help(groups) << std::endl;
    }
    
    static void conditional_groups(int argc, char* argv[])
    {
        cxxopts::Options options("conditional", "条件组示例");
        
        // 基础选项
        options.add_options()
            ("mode", "运行模式", cxxopts::value<std::string>());
        
        // 预解析以获取模式
        auto pre_result = options.parse(argc, argv);
        
        if (pre_result.count("mode"))
        {
            std::string mode = pre_result["mode"].as<std::string>();
            
            if (mode == "server")
            {
                // 添加服务器相关选项
                options.add_options("Server")
                    ("bind", "绑定地址", cxxopts::value<std::string>())
                    ("port", "监听端口", cxxopts::value<int>())
                    ("workers", "工作进程数", cxxopts::value<int>());
            }
            else if (mode == "client")
            {
                // 添加客户端相关选项
                options.add_options("Client")
                    ("server", "服务器地址", cxxopts::value<std::string>())
                    ("retry", "重连次数", cxxopts::value<int>());
            }
        }
        
        // 重新解析完整的选项
        auto result = options.parse(argc, argv);
    }
};
```

### 4.3 解析控制与异常处理

```cpp
#include "cxxopts.hpp"
#include <iostream>
#include <exception>

class ParseControlDemo
{
public:
    static void comprehensive_error_handling(int argc, char* argv[])
    {
        cxxopts::Options options("error_demo", "错误处理示例");
        
        options.add_options()
            ("required", "必需参数", cxxopts::value<std::string>())
            ("optional", "可选参数", cxxopts::value<int>()->default_value("0"))
            ("h,help", "帮助");
        
        try
        {
            // 解析选项
            cxxopts::ParseResult result = options.parse(argc, argv);
            
            // 自定义验证
            if (!result.count("required") && !result.count("help"))
            {
                throw cxxopts::exceptions::option_required_exception("required");
            }
            
            if (result.count("help"))
            {
                std::cout << options.help() << std::endl;
                return;
            }
            
            // 获取值并验证
            std::string req_value = result["required"].as<std::string>();
            if (req_value.empty())
            {
                throw std::invalid_argument("required 参数不能为空");
            }
            
            int opt_value = result["optional"].as<int>();
            if (opt_value < 0 || opt_value > 100)
            {
                throw std::out_of_range("optional 参数必须在 0-100 之间");
            }
        }
        catch (const cxxopts::exceptions::no_such_option& e)
        {
            std::cerr << "未知选项: " << e.what() << std::endl;
            std::cerr << "使用 --help 查看可用选项" << std::endl;
        }
        catch (const cxxopts::exceptions::option_requires_argument& e)
        {
            std::cerr << "选项需要参数: " << e.what() << std::endl;
        }
        catch (const cxxopts::exceptions::option_not_exists& e)
        {
            std::cerr << "选项不存在: " << e.what() << std::endl;
        }
        catch (const cxxopts::exceptions::incorrect_argument_type& e)
        {
            std::cerr << "参数类型错误: " << e.what() << std::endl;
        }
        catch (const cxxopts::exceptions::option_syntax_exception& e)
        {
            std::cerr << "选项语法错误: " << e.what() << std::endl;
        }
        catch (const cxxopts::exceptions::option_not_has_argument& e)
        {
            std::cerr << "选项不接受参数: " << e.what() << std::endl;
        }
        catch (const cxxopts::exceptions::option_not_present& e)
        {
            std::cerr << "选项未提供: " << e.what() << std::endl;
        }
        catch (const cxxopts::exceptions::option_required_exception& e)
        {
            std::cerr << "缺少必需的选项: " << e.what() << std::endl;
        }
        catch (const cxxopts::exceptions::duplicate_option& e)
        {
            std::cerr << "重复的选项定义: " << e.what() << std::endl;
        }
        catch (const cxxopts::exceptions::invalid_option_syntax& e)
        {
            std::cerr << "无效的选项语法: " << e.what() << std::endl;
        }
        catch (const std::exception& e)
        {
            std::cerr << "错误: " << e.what() << std::endl;
        }
    }
    
    // 允许未识别选项
    static void allow_unrecognised_example(int argc, char* argv[])
    {
        cxxopts::Options options("unrecognised", "未识别选项示例");
        
        // 允许未识别的选项
        options.allow_unrecognised_options();
        
        options.add_options()
            ("known", "已知选项", cxxopts::value<std::string>());
        
        auto result = options.parse(argc, argv);
        
        // 获取未识别的选项
        auto& unmatched = result.unmatched();
        if (!unmatched.empty())
        {
            std::cout << "未识别的选项:" << std::endl;
            for (const auto& opt : unmatched)
            {
                std::cout << "  " << opt << std::endl;
            }
        }
    }
};
```

## 5. 实战案例

### 5.1 完整的命令行工具框架

```cpp
#include "cxxopts.hpp"
#include <iostream>
#include <fstream>
#include <memory>
#include <map>
#include <functional>
#include <chrono>
#include <iomanip>

// 命令行应用框架
class CommandLineApp
{
public:
    struct Config
    {
        // 通用配置
        std::string config_file;
        bool verbose = false;
        bool quiet = false;
        std::string log_file;
        std::string log_level = "info";
        
        // 应用特定配置
        std::vector<std::string> input_files;
        std::string output_dir = "./output";
        std::string format = "json";
        int threads = 4;
        int timeout = 300;
        
        // 网络配置
        std::string host = "localhost";
        int port = 8080;
        bool use_ssl = false;
        std::string proxy;
        
        // 调试配置
        bool debug = false;
        bool dry_run = false;
        bool profile = false;
    };
    
private:
    std::string app_name_;
    std::string app_description_;
    std::string version_;
    Config config_;
    cxxopts::Options options_;
    std::map<std::string, std::function<int()>> commands_;
    
    // 日志级别
    enum class LogLevel
    {
        ERROR = 0,
        WARNING = 1,
        INFO = 2,
        DEBUG = 3,
        TRACE = 4
    };
    
    LogLevel current_log_level_ = LogLevel::INFO;
    std::ofstream log_file_;
    
public:
    CommandLineApp(const std::string& name, const std::string& description, const std::string& version)
        : app_name_(name)
        , app_description_(description)
        , version_(version)
        , options_(name, description)
    {
        setupOptions();
        setupCommands();
    }
    
    ~CommandLineApp()
    {
        if (log_file_.is_open())
        {
            log_file_.close();
        }
    }
    
private:
    void setupOptions()
    {
        // 基本选项
        options_.add_options()
            ("h,help", "显示帮助信息")
            ("version", "显示版本信息")
            ("c,config", "配置文件路径", cxxopts::value<std::string>())
            ("v,verbose", "详细输出", cxxopts::value<bool>()->default_value("false"))
            ("q,quiet", "静默模式", cxxopts::value<bool>()->default_value("false"));
        
        // 输入输出选项
        options_.add_options("Input/Output")
            ("i,input", "输入文件", cxxopts::value<std::vector<std::string>>())
            ("o,output", "输出目录", cxxopts::value<std::string>()->default_value("./output"))
            ("f,format", "输出格式 (json|xml|csv|txt)", 
             cxxopts::value<std::string>()->default_value("json"))
            ("encoding", "文件编码", cxxopts::value<std::string>()->default_value("utf-8"))
            ("compress", "压缩输出", cxxopts::value<bool>()->default_value("false"));
        
        // 处理选项
        options_.add_options("Processing")
            ("t,threads", "线程数", cxxopts::value<int>()->default_value("4"))
            ("timeout", "超时时间(秒)", cxxopts::value<int>()->default_value("300"))
            ("batch-size", "批处理大小", cxxopts::value<int>()->default_value("100"))
            ("memory-limit", "内存限制(MB)", cxxopts::value<int>()->default_value("1024"))
            ("cache", "启用缓存", cxxopts::value<bool>()->default_value("true"));
        
        // 网络选项
        options_.add_options("Network")
            ("host", "服务器地址", cxxopts::value<std::string>()->default_value("localhost"))
            ("p,port", "端口号", cxxopts::value<int>()->default_value("8080"))
            ("ssl", "使用SSL", cxxopts::value<bool>()->default_value("false"))
            ("proxy", "代理服务器", cxxopts::value<std::string>())
            ("auth", "认证信息", cxxopts::value<std::string>())
            ("retry", "重试次数", cxxopts::value<int>()->default_value("3"));
        
        // 日志选项
        options_.add_options("Logging")
            ("log-file", "日志文件", cxxopts::value<std::string>())
            ("log-level", "日志级别 (error|warning|info|debug|trace)", 
             cxxopts::value<std::string>()->default_value("info"))
            ("log-format", "日志格式 (text|json)", 
             cxxopts::value<std::string>()->default_value("text"))
            ("log-rotate", "日志轮转大小(MB)", cxxopts::value<int>()->default_value("10"));
        
        // 调试选项
        options_.add_options("Debug")
            ("debug", "调试模式", cxxopts::value<bool>()->default_value("false"))
            ("dry-run", "演练模式", cxxopts::value<bool>()->default_value("false"))
            ("profile", "性能分析", cxxopts::value<bool>()->default_value("false"))
            ("trace", "跟踪执行", cxxopts::value<bool>()->default_value("false"))
            ("validate-only", "仅验证", cxxopts::value<bool>()->default_value("false"));
        
        // 设置位置参数
        options_.parse_positional({"input"});
        options_.positional_help("[文件...]");
        options_.show_positional_help();
    }
    
    void setupCommands()
    {
        // 注册命令处理器
        commands_["process"] = [this]() { return processCommand(); };
        commands_["analyze"] = [this]() { return analyzeCommand(); };
        commands_["convert"] = [this]() { return convertCommand(); };
        commands_["validate"] = [this]() { return validateCommand(); };
    }
    
    int processCommand()
    {
        log(LogLevel::INFO, "开始处理文件...");
        
        if (config_.dry_run)
        {
            log(LogLevel::INFO, "演练模式：不会实际执行操作");
        }
        
        for (const auto& file : config_.input_files)
        {
            log(LogLevel::DEBUG, "处理文件: " + file);
            
            if (!config_.dry_run)
            {
                // 实际处理逻辑
                processFile(file);
            }
        }
        
        log(LogLevel::INFO, "处理完成");
        return 0;
    }
    
    void processFile(const std::string& file)
    {
        auto start = std::chrono::high_resolution_clock::now();
        
        // 模拟文件处理
        log(LogLevel::DEBUG, "读取文件: " + file);
        log(LogLevel::DEBUG, "应用转换...");
        log(LogLevel::DEBUG, "保存结果...");
        
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        
        log(LogLevel::INFO, "文件 " + file + " 处理完成，耗时: " + 
            std::to_string(duration.count()) + "ms");
    }
    
    int analyzeCommand()
    {
        log(LogLevel::INFO, "分析命令未实现");
        return 0;
    }
    
    int convertCommand()
    {
        log(LogLevel::INFO, "转换命令未实现");
        return 0;
    }
    
    int validateCommand()
    {
        log(LogLevel::INFO, "验证配置...");
        
        // 验证输入文件
        for (const auto& file : config_.input_files)
        {
            std::ifstream ifs(file);
            if (!ifs.good())
            {
                log(LogLevel::ERROR, "文件不存在: " + file);
                return 1;
            }
            log(LogLevel::INFO, "✓ 文件存在: " + file);
        }
        
        // 验证输出目录
        // ... 
        
        log(LogLevel::INFO, "配置验证通过");
        return 0;
    }
    
    void log(LogLevel level, const std::string& message)
    {
        if (config_.quiet)
            return;
            
        if (level > current_log_level_)
            return;
        
        auto now = std::chrono::system_clock::now();
        auto time_t = std::chrono::system_clock::to_time_t(now);
        
        std::stringstream ss;
        ss << std::put_time(std::localtime(&time_t), "%Y-%m-%d %H:%M:%S");
        ss << " [" << logLevelToString(level) << "] ";
        ss << message;
        
        std::string log_line = ss.str();
        
        // 输出到控制台
        if (level == LogLevel::ERROR)
        {
            std::cerr << log_line << std::endl;
        }
        else if (config_.verbose || level <= LogLevel::INFO)
        {
            std::cout << log_line << std::endl;
        }
        
        // 输出到日志文件
        if (log_file_.is_open())
        {
            log_file_ << log_line << std::endl;
            log_file_.flush();
        }
    }
    
    std::string logLevelToString(LogLevel level)
    {
        switch (level)
        {
            case LogLevel::ERROR:   return "ERROR";
            case LogLevel::WARNING: return "WARN ";
            case LogLevel::INFO:    return "INFO ";
            case LogLevel::DEBUG:   return "DEBUG";
            case LogLevel::TRACE:   return "TRACE";
            default:                return "UNKNOWN";
        }
    }
    
    LogLevel stringToLogLevel(const std::string& level)
    {
        if (level == "error")   return LogLevel::ERROR;
        if (level == "warning") return LogLevel::WARNING;
        if (level == "info")    return LogLevel::INFO;
        if (level == "debug")   return LogLevel::DEBUG;
        if (level == "trace")   return LogLevel::TRACE;
        return LogLevel::INFO;
    }
    
public:
    int run(int argc, char* argv[])
    {
        try
        {
            auto result = options_.parse(argc, argv);
            
            // 处理帮助
            if (result.count("help"))
            {
                printHelp();
                return 0;
            }
            
            // 处理版本
            if (result.count("version"))
            {
                std::cout << app_name_ << " version " << version_ << std::endl;
                return 0;
            }
            
            // 加载配置文件
            if (result.count("config"))
            {
                loadConfigFile(result["config"].as<std::string>());
            }
            
            // 解析命令行参数（覆盖配置文件）
            parseArguments(result);
            
            // 设置日志
            setupLogging();
            
            // 执行主逻辑
            return execute();
        }
        catch (const cxxopts::exceptions::exception& e)
        {
            std::cerr << "参数错误: " << e.what() << std::endl;
            std::cerr << "使用 --help 查看帮助" << std::endl;
            return 1;
        }
        catch (const std::exception& e)
        {
            std::cerr << "错误: " << e.what() << std::endl;
            return 1;
        }
    }
    
    void loadConfigFile(const std::string& path)
    {
        log(LogLevel::INFO, "加载配置文件: " + path);
        // 实现配置文件加载逻辑
        // 可以是 JSON、YAML、INI 等格式
    }
    
    void parseArguments(const cxxopts::ParseResult& result)
    {
        // 通用选项
        config_.verbose = result["verbose"].as<bool>();
        config_.quiet = result["quiet"].as<bool>();
        
        // 输入输出
        if (result.count("input"))
        {
            config_.input_files = result["input"].as<std::vector<std::string>>();
        }
        config_.output_dir = result["output"].as<std::string>();
        config_.format = result["format"].as<std::string>();
        
        // 处理选项
        config_.threads = result["threads"].as<int>();
        config_.timeout = result["timeout"].as<int>();
        
        // 网络选项
        config_.host = result["host"].as<std::string>();
        config_.port = result["port"].as<int>();
        config_.use_ssl = result["ssl"].as<bool>();
        
        if (result.count("proxy"))
        {
            config_.proxy = result["proxy"].as<std::string>();
        }
        
        // 日志选项
        if (result.count("log-file"))
        {
            config_.log_file = result["log-file"].as<std::string>();
        }
        config_.log_level = result["log-level"].as<std::string>();
        
        // 调试选项
        config_.debug = result["debug"].as<bool>();
        config_.dry_run = result["dry-run"].as<bool>();
        config_.profile = result["profile"].as<bool>();
    }
    
    void setupLogging()
    {
        // 设置日志级别
        current_log_level_ = stringToLogLevel(config_.log_level);
        
        // 打开日志文件
        if (!config_.log_file.empty())
        {
            log_file_.open(config_.log_file, std::ios::app);
            if (!log_file_.is_open())
            {
                throw std::runtime_error("无法打开日志文件: " + config_.log_file);
            }
        }
        
        log(LogLevel::INFO, "日志系统已初始化");
    }
    
    int execute()
    {
        // 验证配置
        validateConfig();
        
        // 打印配置（调试模式）
        if (config_.debug)
        {
            printConfig();
        }
        
        // 性能分析
        if (config_.profile)
        {
            log(LogLevel::INFO, "性能分析已启用");
        }
        
        // 执行主命令
        return processCommand();
    }
    
    void validateConfig()
    {
        // 验证线程数
        if (config_.threads < 1 || config_.threads > 100)
        {
            throw std::invalid_argument("线程数必须在 1-100 之间");
        }
        
        // 验证格式
        static const std::set<std::string> valid_formats = {"json", "xml", "csv", "txt"};
        if (valid_formats.find(config_.format) == valid_formats.end())
        {
            throw std::invalid_argument("不支持的格式: " + config_.format);
        }
        
        // 验证端口
        if (config_.port < 1 || config_.port > 65535)
        {
            throw std::invalid_argument("端口号必须在 1-65535 之间");
        }
        
        log(LogLevel::DEBUG, "配置验证通过");
    }
    
    void printConfig()
    {
        std::cout << "\n=== 当前配置 ===" << std::endl;
        std::cout << "详细输出: " << (config_.verbose ? "是" : "否") << std::endl;
        std::cout << "静默模式: " << (config_.quiet ? "是" : "否") << std::endl;
        std::cout << "输出目录: " << config_.output_dir << std::endl;
        std::cout << "输出格式: " << config_.format << std::endl;
        std::cout << "线程数: " << config_.threads << std::endl;
        std::cout << "超时: " << config_.timeout << " 秒" << std::endl;
        std::cout << "服务器: " << config_.host << ":" << config_.port << std::endl;
        std::cout << "SSL: " << (config_.use_ssl ? "启用" : "禁用") << std::endl;
        
        if (!config_.proxy.empty())
        {
            std::cout << "代理: " << config_.proxy << std::endl;
        }
        
        std::cout << "调试模式: " << (config_.debug ? "是" : "否") << std::endl;
        std::cout << "演练模式: " << (config_.dry_run ? "是" : "否") << std::endl;
        std::cout << "==================\n" << std::endl;
    }
    
    void printHelp()
    {
        std::cout << options_.help({
            "",
            "Input/Output",
            "Processing",
            "Network",
            "Logging",
            "Debug"
        }) << std::endl;
        
        std::cout << "\n示例:" << std::endl;
        std::cout << "  " << app_name_ << " file1.txt file2.txt" << std::endl;
        std::cout << "  " << app_name_ << " -i file1.txt -o ./output" << std::endl;
        std::cout << "  " << app_name_ << " --config=config.json" << std::endl;
        std::cout << "  " << app_name_ << " --threads=8 --format=xml file.txt" << std::endl;
        
        std::cout << "\n更多信息，请访问: https://example.com/docs" << std::endl;
    }
};

// 使用示例
int main(int argc, char* argv[])
{
    CommandLineApp app("myapp", "强大的命令行应用程序", "1.0.0");
    return app.run(argc, argv);
}
```

### 5.2 Git 风格的子命令

```cpp
#include "cxxopts.hpp"
#include <iostream>
#include <memory>
#include <map>
#include <functional>

// 子命令基类
class SubCommand
{
public:
    virtual ~SubCommand() = default;
    virtual int execute(int argc, char* argv[]) = 0;
    virtual std::string getName() const = 0;
    virtual std::string getDescription() const = 0;
};

// Add 子命令
class AddCommand : public SubCommand
{
public:
    std::string getName() const override { return "add"; }
    std::string getDescription() const override { return "添加文件到暂存区"; }
    
    int execute(int argc, char* argv[]) override
    {
        cxxopts::Options options("myapp add", getDescription());
        
        options.add_options()
            ("A,all", "添加所有文件")
            ("p,patch", "交互式添加")
            ("f,force", "强制添加")
            ("files", "要添加的文件", cxxopts::value<std::vector<std::string>>())
            ("h,help", "显示帮助");
        
        options.parse_positional({"files"});
        
        try
        {
            auto result = options.parse(argc, argv);
            
            if (result.count("help"))
            {
                std::cout << options.help() << std::endl;
                return 0;
            }
            
            if (result.count("all"))
            {
                std::cout << "添加所有文件..." << std::endl;
            }
            else if (result.count("files"))
            {
                auto& files = result["files"].as<std::vector<std::string>>();
                for (const auto& file : files)
                {
                    std::cout << "添加文件: " << file << std::endl;
                }
            }
            
            return 0;
        }
        catch (const std::exception& e)
        {
            std::cerr << "错误: " << e.what() << std::endl;
            return 1;
        }
    }
};

// Commit 子命令
class CommitCommand : public SubCommand
{
public:
    std::string getName() const override { return "commit"; }
    std::string getDescription() const override { return "提交更改"; }
    
    int execute(int argc, char* argv[]) override
    {
        cxxopts::Options options("myapp commit", getDescription());
        
        options.add_options()
            ("m,message", "提交信息", cxxopts::value<std::string>())
            ("a,all", "自动暂存已修改文件")
            ("amend", "修改上次提交")
            ("author", "作者", cxxopts::value<std::string>())
            ("date", "日期", cxxopts::value<std::string>())
            ("h,help", "显示帮助");
        
        try
        {
            auto result = options.parse(argc, argv);
            
            if (result.count("help"))
            {
                std::cout << options.help() << std::endl;
                return 0;
            }
            
            if (!result.count("message") && !result.count("amend"))
            {
                std::cerr << "错误: 需要提交信息 (-m)" << std::endl;
                return 1;
            }
            
            if (result.count("message"))
            {
                std::string msg = result["message"].as<std::string>();
                std::cout << "提交信息: " << msg << std::endl;
            }
            
            if (result.count("amend"))
            {
                std::cout << "修改上次提交..." << std::endl;
            }
            
            return 0;
        }
        catch (const std::exception& e)
        {
            std::cerr << "错误: " << e.what() << std::endl;
            return 1;
        }
    }
};

// Push 子命令
class PushCommand : public SubCommand
{
public:
    std::string getName() const override { return "push"; }
    std::string getDescription() const override { return "推送到远程仓库"; }
    
    int execute(int argc, char* argv[]) override
    {
        cxxopts::Options options("myapp push", getDescription());
        
        options.add_options()
            ("remote", "远程仓库", cxxopts::value<std::string>()->default_value("origin"))
            ("branch", "分支", cxxopts::value<std::string>())
            ("f,force", "强制推送")
            ("tags", "推送标签")
            ("u,set-upstream", "设置上游分支")
            ("h,help", "显示帮助");
        
        options.parse_positional({"remote", "branch"});
        
        try
        {
            auto result = options.parse(argc, argv);
            
            if (result.count("help"))
            {
                std::cout << options.help() << std::endl;
                return 0;
            }
            
            std::string remote = result["remote"].as<std::string>();
            std::cout << "推送到远程: " << remote << std::endl;
            
            if (result.count("branch"))
            {
                std::string branch = result["branch"].as<std::string>();
                std::cout << "分支: " << branch << std::endl;
            }
            
            if (result.count("force"))
            {
                std::cout << "强制推送模式" << std::endl;
            }
            
            return 0;
        }
        catch (const std::exception& e)
        {
            std::cerr << "错误: " << e.what() << std::endl;
            return 1;
        }
    }
};

// 主应用程序
class GitStyleApp
{
private:
    std::map<std::string, std::unique_ptr<SubCommand>> commands_;
    std::string app_name_;
    std::string app_version_;
    
public:
    GitStyleApp(const std::string& name, const std::string& version)
        : app_name_(name), app_version_(version)
    {
        // 注册子命令
        registerCommand(std::make_unique<AddCommand>());
        registerCommand(std::make_unique<CommitCommand>());
        registerCommand(std::make_unique<PushCommand>());
    }
    
    void registerCommand(std::unique_ptr<SubCommand> cmd)
    {
        commands_[cmd->getName()] = std::move(cmd);
    }
    
    int run(int argc, char* argv[])
    {
        if (argc < 2)
        {
            printUsage();
            return 1;
        }
        
        std::string cmd_name = argv[1];
        
        // 处理全局选项
        if (cmd_name == "--help" || cmd_name == "-h")
        {
            printHelp();
            return 0;
        }
        
        if (cmd_name == "--version" || cmd_name == "-v")
        {
            std::cout << app_name_ << " version " << app_version_ << std::endl;
            return 0;
        }
        
        // 查找并执行子命令
        auto it = commands_.find(cmd_name);
        if (it == commands_.end())
        {
            std::cerr << "错误: 未知命令 '" << cmd_name << "'" << std::endl;
            printUsage();
            return 1;
        }
        
        // 传递剩余参数给子命令
        return it->second->execute(argc - 1, argv + 1);
    }
    
    void printUsage()
    {
        std::cout << "用法: " << app_name_ << " <命令> [选项]" << std::endl;
        std::cout << "\n可用命令:" << std::endl;
        
        for (const auto& pair : commands_)
        {
            std::cout << "  " << std::left << std::setw(15) 
                      << pair.first << pair.second->getDescription() << std::endl;
        }
        
        std::cout << "\n使用 '" << app_name_ << " <命令> --help' 查看命令帮助" << std::endl;
    }
    
    void printHelp()
    {
        std::cout << app_name_ << " - Git 风格的命令行应用" << std::endl;
        std::cout << "版本: " << app_version_ << std::endl;
        std::cout << std::endl;
        printUsage();
        
        std::cout << "\n全局选项:" << std::endl;
        std::cout << "  -h, --help     显示帮助信息" << std::endl;
        std::cout << "  -v, --version  显示版本信息" << std::endl;
    }
};

// 主函数
int main(int argc, char* argv[])
{
    GitStyleApp app("myapp", "1.0.0");
    return app.run(argc, argv);
}

// 使用示例：
// ./myapp add file1.txt file2.txt
// ./myapp commit -m "Initial commit"
// ./myapp push origin main
// ./myapp --help
// ./myapp add --help
```

## 6. 性能优化与最佳实践

### 6.1 性能优化技巧

```cpp
#include "cxxopts.hpp"
#include <iostream>
#include <chrono>

class PerformanceOptimization
{
public:
    // 1. 避免重复解析
    static void reuseParseResult()
    {
        cxxopts::Options options("perf", "性能优化");
        options.add_options()
            ("input", "输入", cxxopts::value<std::string>())
            ("output", "输出", cxxopts::value<std::string>())
            ("threads", "线程", cxxopts::value<int>());
        
        // 解析一次，多次使用
        auto result = options.parse(argc, argv);
        
        // 缓存结果，避免重复 as<> 调用
        std::string input = result.count("input") ? 
            result["input"].as<std::string>() : "";
        std::string output = result.count("output") ? 
            result["output"].as<std::string>() : "default.out";
        int threads = result.count("threads") ? 
            result["threads"].as<int>() : 1;
        
        // 使用缓存的值
        for (int i = 0; i < 1000; ++i)
        {
            process(input, output, threads);
        }
    }
    
    // 2. 延迟初始化
    class LazyOptions
    {
    private:
        mutable std::unique_ptr<cxxopts::Options> options_;
        mutable std::unique_ptr<cxxopts::ParseResult> result_;
        int argc_;
        char** argv_;
        
    public:
        LazyOptions(int argc, char* argv[]) 
            : argc_(argc), argv_(argv) {}
        
        const cxxopts::ParseResult& getResult() const
        {
            if (!result_)
            {
                initOptions();
                result_ = std::make_unique<cxxopts::ParseResult>(
                    options_->parse(argc_, argv_));
            }
            return *result_;
        }
        
    private:
        void initOptions() const
        {
            if (!options_)
            {
                options_ = std::make_unique<cxxopts::Options>("lazy", "延迟初始化");
                options_->add_options()
                    ("option1", "选项1", cxxopts::value<std::string>())
                    ("option2", "选项2", cxxopts::value<int>());
            }
        }
    };
    
    // 3. 批量处理选项
    struct BatchConfig
    {
        std::vector<std::string> inputs;
        std::string output;
        int threads;
        bool verbose;
        
        static BatchConfig fromArgs(const cxxopts::ParseResult& result)
        {
            BatchConfig config;
            
            // 批量获取所有需要的值
            if (result.count("input"))
                config.inputs = result["input"].as<std::vector<std::string>>();
            if (result.count("output"))
                config.output = result["output"].as<std::string>();
            if (result.count("threads"))
                config.threads = result["threads"].as<int>();
            if (result.count("verbose"))
                config.verbose = result["verbose"].as<bool>();
            
            return config;
        }
    };
    
    // 4. 使用 move 语义
    static cxxopts::Options createOptions()
    {
        cxxopts::Options options("move", "Move 语义");
        options.add_options()
            ("test", "测试", cxxopts::value<std::string>());
        return options;  // 利用 RVO/NRVO
    }
};
```

### 6.2 错误处理最佳实践

```cpp
#include "cxxopts.hpp"
#include <iostream>

class ErrorHandlingBestPractices
{
public:
    enum class ErrorCode
    {
        SUCCESS = 0,
        INVALID_ARGS = 1,
        MISSING_REQUIRED = 2,
        INVALID_VALUE = 3,
        FILE_NOT_FOUND = 4,
        PERMISSION_DENIED = 5,
        UNKNOWN_ERROR = 99
    };
    
    struct Result
    {
        ErrorCode code = ErrorCode::SUCCESS;
        std::string message;
        
        bool isSuccess() const { return code == ErrorCode::SUCCESS; }
        operator bool() const { return isSuccess(); }
    };
    
    static Result parseAndValidate(int argc, char* argv[])
    {
        cxxopts::Options options("error", "错误处理示例");
        
        options.add_options()
            ("input", "输入文件（必需）", cxxopts::value<std::string>())
            ("output", "输出文件", cxxopts::value<std::string>())
            ("threads", "线程数", cxxopts::value<int>())
            ("h,help", "帮助");
        
        try
        {
            auto result = options.parse(argc, argv);
            
            // 检查帮助
            if (result.count("help"))
            {
                std::cout << options.help() << std::endl;
                return {ErrorCode::SUCCESS, ""};
            }
            
            // 验证必需参数
            if (!result.count("input"))
            {
                return {ErrorCode::MISSING_REQUIRED, 
                        "缺少必需的参数: --input"};
            }
            
            // 验证文件存在
            std::string input = result["input"].as<std::string>();
            std::ifstream file(input);
            if (!file.good())
            {
                return {ErrorCode::FILE_NOT_FOUND,
                        "文件不存在: " + input};
            }
            
            // 验证数值范围
            if (result.count("threads"))
            {
                int threads = result["threads"].as<int>();
                if (threads < 1 || threads > 256)
                {
                    return {ErrorCode::INVALID_VALUE,
                            "线程数必须在 1-256 之间"};
                }
            }
            
            return {ErrorCode::SUCCESS, ""};
        }
        catch (const cxxopts::exceptions::no_such_option& e)
        {
            return {ErrorCode::INVALID_ARGS,
                    std::string("未知选项: ") + e.what()};
        }
        catch (const cxxopts::exceptions::option_requires_argument& e)
        {
            return {ErrorCode::INVALID_ARGS,
                    std::string("选项需要参数: ") + e.what()};
        }
        catch (const cxxopts::exceptions::incorrect_argument_type& e)
        {
            return {ErrorCode::INVALID_VALUE,
                    std::string("参数类型错误: ") + e.what()};
        }
        catch (const std::exception& e)
        {
            return {ErrorCode::UNKNOWN_ERROR,
                    std::string("未知错误: ") + e.what()};
        }
    }
    
    static int main(int argc, char* argv[])
    {
        auto result = parseAndValidate(argc, argv);
        
        if (!result)
        {
            std::cerr << "错误: " << result.message << std::endl;
            return static_cast<int>(result.code);
        }
        
        // 继续正常处理
        return 0;
    }
};
```

## 7. 与其他库的集成

### 7.1 与 JSON 库集成

```cpp
#include "cxxopts.hpp"
#include <nlohmann/json.hpp>
#include <fstream>

using json = nlohmann::json;

class JsonIntegration
{
public:
    struct Config
    {
        std::string name;
        int value;
        std::vector<std::string> items;
        
        // 从 JSON 加载
        static Config fromJson(const json& j)
        {
            Config config;
            config.name = j.value("name", "default");
            config.value = j.value("value", 0);
            
            if (j.contains("items"))
            {
                config.items = j["items"].get<std::vector<std::string>>();
            }
            
            return config;
        }
        
        // 转换为 JSON
        json toJson() const
        {
            return json{
                {"name", name},
                {"value", value},
                {"items", items}
            };
        }
    };
    
    static Config parseWithJsonConfig(int argc, char* argv[])
    {
        cxxopts::Options options("json", "JSON 集成示例");
        
        options.add_options()
            ("c,config", "JSON 配置文件", cxxopts::value<std::string>())
            ("name", "名称", cxxopts::value<std::string>())
            ("value", "值", cxxopts::value<int>())
            ("items", "项目列表", cxxopts::value<std::vector<std::string>>());
        
        auto result = options.parse(argc, argv);
        
        Config config;
        
        // 首先从 JSON 文件加载
        if (result.count("config"))
        {
            std::ifstream file(result["config"].as<std::string>());
            json j;
            file >> j;
            config = Config::fromJson(j);
        }
        
        // 命令行参数覆盖 JSON 配置
        if (result.count("name"))
            config.name = result["name"].as<std::string>();
        
        if (result.count("value"))
            config.value = result["value"].as<int>();
        
        if (result.count("items"))
            config.items = result["items"].as<std::vector<std::string>>();
        
        return config;
    }
    
    static void saveConfig(const Config& config, const std::string& filename)
    {
        std::ofstream file(filename);
        file << config.toJson().dump(4) << std::endl;
    }
};
```

### 7.2 与日志库集成

```cpp
#include "cxxopts.hpp"
#include <spdlog/spdlog.h>
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>

class LoggingIntegration
{
public:
    static void setupLogging(const cxxopts::ParseResult& result)
    {
        // 设置日志级别
        std::string log_level = result["log-level"].as<std::string>();
        
        if (log_level == "trace")
            spdlog::set_level(spdlog::level::trace);
        else if (log_level == "debug")
            spdlog::set_level(spdlog::level::debug);
        else if (log_level == "info")
            spdlog::set_level(spdlog::level::info);
        else if (log_level == "warning")
            spdlog::set_level(spdlog::level::warn);
        else if (log_level == "error")
            spdlog::set_level(spdlog::level::err);
        
        // 设置日志输出
        if (result.count("log-file"))
        {
            auto file_logger = spdlog::basic_logger_mt(
                "file_logger", 
                result["log-file"].as<std::string>()
            );
            spdlog::set_default_logger(file_logger);
        }
        else
        {
            auto console_logger = spdlog::stdout_color_mt("console");
            spdlog::set_default_logger(console_logger);
        }
        
        // 设置日志格式
        if (result.count("log-format"))
        {
            std::string format = result["log-format"].as<std::string>();
            if (format == "json")
            {
                spdlog::set_pattern("{\"time\":\"%Y-%m-%d %H:%M:%S\",\"level\":\"%l\",\"msg\":\"%v\"}");
            }
            else
            {
                spdlog::set_pattern("[%Y-%m-%d %H:%M:%S] [%l] %v");
            }
        }
    }
    
    static cxxopts::Options createOptionsWithLogging()
    {
        cxxopts::Options options("app", "带日志的应用");
        
        options.add_options("Logging")
            ("log-level", "日志级别", 
             cxxopts::value<std::string>()->default_value("info"))
            ("log-file", "日志文件", cxxopts::value<std::string>())
            ("log-format", "日志格式 (text|json)", 
             cxxopts::value<std::string>()->default_value("text"));
        
        return options;
    }
};
```

## 8. 测试与调试

### 8.1 单元测试示例

```cpp
#include "cxxopts.hpp"
#include <gtest/gtest.h>
#include <vector>
#include <string>

class CxxoptsTest : public ::testing::Test
{
protected:
    cxxopts::Options options{"test", "测试程序"};
    
    void SetUp() override
    {
        options.add_options()
            ("s,string", "字符串选项", cxxopts::value<std::string>())
            ("i,integer", "整数选项", cxxopts::value<int>())
            ("b,bool", "布尔选项", cxxopts::value<bool>())
            ("v,vector", "向量选项", cxxopts::value<std::vector<int>>());
    }
    
    cxxopts::ParseResult parse(const std::vector<std::string>& args)
    {
        std::vector<const char*> argv;
        argv.push_back("test");
        for (const auto& arg : args)
        {
            argv.push_back(arg.c_str());
        }
        return options.parse(argv.size(), const_cast<char**>(argv.data()));
    }
};

TEST_F(CxxoptsTest, ParseString)
{
    auto result = parse({"--string=hello"});
    EXPECT_TRUE(result.count("string"));
    EXPECT_EQ(result["string"].as<std::string>(), "hello");
}

TEST_F(CxxoptsTest, ParseInteger)
{
    auto result = parse({"-i", "42"});
    EXPECT_TRUE(result.count("integer"));
    EXPECT_EQ(result["integer"].as<int>(), 42);
}

TEST_F(CxxoptsTest, ParseBoolean)
{
    auto result = parse({"--bool=true"});
    EXPECT_TRUE(result.count("bool"));
    EXPECT_TRUE(result["bool"].as<bool>());
}

TEST_F(CxxoptsTest, ParseVector)
{
    auto result = parse({"--vector=1,2,3,4,5"});
    EXPECT_TRUE(result.count("vector"));
    auto vec = result["vector"].as<std::vector<int>>();
    EXPECT_EQ(vec.size(), 5);
    EXPECT_EQ(vec[0], 1);
    EXPECT_EQ(vec[4], 5);
}

TEST_F(CxxoptsTest, MissingRequired)
{
    // 测试缺少必需参数的情况
    EXPECT_NO_THROW(parse({}));
    auto result = parse({});
    EXPECT_FALSE(result.count("string"));
}

TEST_F(CxxoptsTest, InvalidType)
{
    // 测试类型错误
    EXPECT_THROW(parse({"--integer=not_a_number"}), cxxopts::exceptions::incorrect_argument_type);
}

TEST_F(CxxoptsTest, UnknownOption)
{
    // 测试未知选项
    EXPECT_THROW(parse({"--unknown"}), cxxopts::exceptions::no_such_option);
}
```

### 8.2 调试技巧

```cpp
#include "cxxopts.hpp"
#include <iostream>

class DebugHelper
{
public:
    static void debugPrintResult(const cxxopts::ParseResult& result)
    {
        std::cout << "=== 调试信息 ===" << std::endl;
        
        // 打印所有解析的参数
        std::cout << "已解析的参数:" << std::endl;
        for (const auto& arg : result.arguments())
        {
            std::cout << "  " << arg.key() << " = ";
            std::cout << arg.value() << " (count: " << arg.count() << ")" << std::endl;
        }
        
        // 打印未匹配的参数
        auto unmatched = result.unmatched();
        if (!unmatched.empty())
        {
            std::cout << "未匹配的参数:" << std::endl;
            for (const auto& u : unmatched)
            {
                std::cout << "  " << u << std::endl;
            }
        }
        
        std::cout << "=================" << std::endl;
    }
    
    // 参数验证辅助函数
    template<typename T>
    static bool validateAndGet(
        const cxxopts::ParseResult& result,
        const std::string& option,
        T& value,
        std::function<bool(const T&)> validator = nullptr)
    {
        try
        {
            if (!result.count(option))
            {
                std::cerr << "调试: 选项 '" << option << "' 未提供" << std::endl;
                return false;
            }
            
            value = result[option].as<T>();
            
            if (validator && !validator(value))
            {
                std::cerr << "调试: 选项 '" << option << "' 验证失败" << std::endl;
                return false;
            }
            
            std::cout << "调试: " << option << " = " << value << std::endl;
            return true;
        }
        catch (const std::exception& e)
        {
            std::cerr << "调试: 获取选项 '" << option << "' 失败: " << e.what() << std::endl;
            return false;
        }
    }
};

// 使用示例
int main(int argc, char* argv[])
{
    cxxopts::Options options("debug", "调试示例");
    
    options.add_options()
        ("input", "输入", cxxopts::value<std::string>())
        ("count", "数量", cxxopts::value<int>());
    
    auto result = options.parse(argc, argv);
    
    // 调试打印
    DebugHelper::debugPrintResult(result);
    
    // 验证并获取值
    std::string input;
    int count;
    
    if (DebugHelper::validateAndGet(result, "input", input))
    {
        // 处理输入
    }
    
    if (DebugHelper::validateAndGet(result, "count", count,
        [](const int& v) { return v > 0 && v <= 100; }))
    {
        // 处理数量
    }
    
    return 0;
}
```

## 9. 常见问题与解决方案

### 9.1 FAQ

```cpp
// Q1: 如何处理带空格的参数？
// A: 使用引号
// 命令行: ./program --name="John Doe" 
// 或: ./program --name "John Doe"

// Q2: 如何处理负数参数？
// A: 使用 = 或 -- 分隔
// 命令行: ./program --value=-10
// 或: ./program -- -10

// Q3: 如何实现互斥选项？
class MutuallyExclusiveOptions
{
public:
    static void example(int argc, char* argv[])
    {
        cxxopts::Options options("mutex", "互斥选项");
        
        options.add_options()
            ("encrypt", "加密模式")
            ("decrypt", "解密模式")
            ("help", "帮助");
        
        auto result = options.parse(argc, argv);
        
        // 手动检查互斥
        if (result.count("encrypt") && result.count("decrypt"))
        {
            throw std::runtime_error("--encrypt 和 --decrypt 不能同时使用");
        }
        
        if (!result.count("encrypt") && !result.count("decrypt"))
        {
            throw std::runtime_error("必须指定 --encrypt 或 --decrypt");
        }
    }
};

// Q4: 如何实现依赖选项？
class DependentOptions
{
public:
    static void example(int argc, char* argv[])
    {
        cxxopts::Options options("depend", "依赖选项");
        
        options.add_options()
            ("ssl", "使用 SSL")
            ("cert", "证书文件", cxxopts::value<std::string>())
            ("key", "密钥文件", cxxopts::value<std::string>());
        
        auto result = options.parse(argc, argv);
        
        // 如果使用 SSL，则需要证书和密钥
        if (result.count("ssl"))
        {
            if (!result.count("cert") || !result.count("key"))
            {
                throw std::runtime_error("使用 --ssl 时必须提供 --cert 和 --key");
            }
        }
    }
};

// Q5: 如何处理环境变量？
class EnvironmentVariables
{
public:
    static std::string getEnvOrDefault(const std::string& var, const std::string& default_value)
    {
        const char* value = std::getenv(var.c_str());
        return value ? std::string(value) : default_value;
    }
    
    static void example(int argc, char* argv[])
    {
        cxxopts::Options options("env", "环境变量");
        
        // 从环境变量获取默认值
        std::string default_host = getEnvOrDefault("APP_HOST", "localhost");
        std::string default_port = getEnvOrDefault("APP_PORT", "8080");
        
        options.add_options()
            ("host", "主机", cxxopts::value<std::string>()->default_value(default_host))
            ("port", "端口", cxxopts::value<std::string>()->default_value(default_port));
        
        auto result = options.parse(argc, argv);
    }
};
```

## 10. 总结与资源

### 10.1 最佳实践总结

1. **始终提供帮助选项**
2. **使用有意义的选项名称**
3. **提供合理的默认值**
4. **进行充分的错误处理**
5. **使用分组来组织选项**
6. **编写单元测试**
7. **提供使用示例**
8. **支持配置文件**
9. **记录日志**
10. **考虑国际化**

### 10.2 相关资源

- **官方仓库**: https://github.com/jarro2783/cxxopts
- **文档**: https://github.com/jarro2783/cxxopts/blob/master/README.md
- **示例代码**: https://github.com/jarro2783/cxxopts/tree/master/test

### 10.3 编译命令示例

```bash
# 基本编译
g++ -std=c++11 main.cpp -o myapp

# 优化编译
g++ -std=c++17 -O3 -Wall -Wextra main.cpp -o myapp

# 调试编译
g++ -std=c++17 -g -O0 -DDEBUG main.cpp -o myapp

# CMake 编译
mkdir build && cd build
cmake ..
make

# 使用 pkg-config
g++ main.cpp `pkg-config --cflags --libs cxxopts` -o myapp
```


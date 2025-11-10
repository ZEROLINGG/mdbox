## uchardet库详解

uchardet是Mozilla的通用字符编码检测库，可以自动检测文本文件的字符编码。它支持多种语言和编码格式，是处理未知编码文本的利器。

## 1. 基本介绍

### 1.1 什么是uchardet
- **功能**：自动检测文本编码
- **来源**：基于Mozilla的编码检测算法
- **优势**：支持多种语言和编码，准确率高
- **应用场景**：处理来源不明的文本文件、网页抓取、数据迁移等

### 1.2 支持的编码
```
Unicode: UTF-8, UTF-16(BE/LE), UTF-32(BE/LE)
中文: GB18030, GBK, GB2312, BIG5, EUC-TW
日文: ISO-2022-JP, SHIFT_JIS, EUC-JP
韩文: ISO-2022-KR, EUC-KR
欧洲: ISO-8859系列, Windows-1250系列
其他: TIS-620, KOI8-R, IBM系列等
```

## 2. 安装和配置

### 2.1 安装方法
```bash
# Ubuntu/Debian
sudo apt-get install libuchardet-dev

# CentOS/RHEL
sudo yum install uchardet-devel

# macOS
brew install uchardet

# 从源码编译
git clone https://gitlab.freedesktop.org/uchardet/uchardet.git
cd uchardet
mkdir build && cd build
cmake ..
make
sudo make install
```

## 3. 核心API

### 3.1 主要函数接口
```c
#include <uchardet/uchardet.h>

// 创建检测器句柄
uchardet_t uchardet_new(void);

// 向检测器输入数据
int uchardet_handle_data(uchardet_t ud, const char *data, size_t len);

// 完成数据输入
void uchardet_data_end(uchardet_t ud);

// 获取检测结果
const char* uchardet_get_charset(uchardet_t ud);

// 重置检测器
void uchardet_reset(uchardet_t ud);

// 删除检测器
void uchardet_delete(uchardet_t ud);
```

## 4. 基本使用示例

### 4.1 简单的编码检测
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <uchardet/uchardet.h>

int detect_charset_simple(const char *data, size_t len) {
    uchardet_t ud;
    const char *charset;
    
    // 创建检测器
    ud = uchardet_new();
    if (!ud) {
        fprintf(stderr, "创建检测器失败\n");
        return -1;
    }
    
    // 输入数据
    if (uchardet_handle_data(ud, data, len) != 0) {
        fprintf(stderr, "处理数据失败\n");
        uchardet_delete(ud);
        return -1;
    }
    
    // 完成数据输入
    uchardet_data_end(ud);
    
    // 获取检测结果
    charset = uchardet_get_charset(ud);
    if (charset && strlen(charset) > 0) {
        printf("检测到的编码: %s\n", charset);
    } else {
        printf("无法检测编码\n");
    }
    
    // 清理资源
    uchardet_delete(ud);
    return 0;
}

int main() {
    const char *test_data = "Hello, 世界! こんにちは";
    detect_charset_simple(test_data, strlen(test_data));
    return 0;
}
```

### 4.2 文件编码检测
```c
#include <stdio.h>
#include <stdlib.h>
#include <uchardet/uchardet.h>

#define BUFFER_SIZE 65536

char* detect_file_charset(const char *filename) {
    FILE *file;
    uchardet_t ud;
    char buffer[BUFFER_SIZE];
    size_t len;
    char *detected_charset = NULL;
    
    // 打开文件
    file = fopen(filename, "rb");
    if (!file) {
        perror("打开文件失败");
        return NULL;
    }
    
    // 创建检测器
    ud = uchardet_new();
    if (!ud) {
        fclose(file);
        return NULL;
    }
    
    // 分块读取文件并检测
    while ((len = fread(buffer, 1, BUFFER_SIZE, file)) > 0) {
        if (uchardet_handle_data(ud, buffer, len) != 0) {
            fprintf(stderr, "处理数据失败\n");
            break;
        }
    }
    
    // 完成检测
    uchardet_data_end(ud);
    
    // 获取结果
    const char *charset = uchardet_get_charset(ud);
    if (charset && strlen(charset) > 0) {
        detected_charset = strdup(charset);
    }
    
    // 清理资源
    uchardet_delete(ud);
    fclose(file);
    
    return detected_charset;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("用法: %s <文件名>\n", argv[0]);
        return 1;
    }
    
    char *charset = detect_file_charset(argv[1]);
    if (charset) {
        printf("文件 '%s' 的编码: %s\n", argv[1], charset);
        free(charset);
    } else {
        printf("无法检测文件编码\n");
    }
    
    return 0;
}
```

## 5. 高级功能

### 5.1 批量文件检测
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <uchardet/uchardet.h>

typedef struct {
    char filename[256];
    char charset[64];
    double confidence;
} FileCharset;

// 检测目录下所有文件的编码
void detect_directory(const char *dir_path) {
    DIR *dir;
    struct dirent *entry;
    struct stat file_stat;
    char full_path[512];
    
    dir = opendir(dir_path);
    if (!dir) {
        perror("打开目录失败");
        return;
    }
    
    printf("%-50s %s\n", "文件名", "编码");
    printf("----------------------------------------"
           "------------------------------\n");
    
    while ((entry = readdir(dir)) != NULL) {
        // 构建完整路径
        snprintf(full_path, sizeof(full_path), 
                 "%s/%s", dir_path, entry->d_name);
        
        // 获取文件信息
        if (stat(full_path, &file_stat) == 0) {
            // 只处理普通文件
            if (S_ISREG(file_stat.st_mode)) {
                char *charset = detect_file_charset(full_path);
                printf("%-50s %s\n", 
                       entry->d_name, 
                       charset ? charset : "未知");
                if (charset) free(charset);
            }
        }
    }
    
    closedir(dir);
}
```

### 5.2 带置信度的检测器封装
```c
#include <uchardet/uchardet.h>

typedef struct {
    char charset[64];
    float confidence;
    size_t bytes_consumed;
} CharsetDetectResult;

typedef struct {
    uchardet_t detector;
    size_t min_bytes;      // 最少需要的字节数
    size_t max_bytes;      // 最多处理的字节数
    int early_stop;        // 是否早停
} CharsetDetector;

// 创建增强型检测器
CharsetDetector* create_detector(size_t min_bytes, 
                                 size_t max_bytes) {
    CharsetDetector *detector = malloc(sizeof(CharsetDetector));
    if (!detector) return NULL;
    
    detector->detector = uchardet_new();
    if (!detector->detector) {
        free(detector);
        return NULL;
    }
    
    detector->min_bytes = min_bytes;
    detector->max_bytes = max_bytes;
    detector->early_stop = 1;
    
    return detector;
}

// 执行检测
CharsetDetectResult* detect_with_confidence(CharsetDetector *detector,
                                           const char *data,
                                           size_t len) {
    CharsetDetectResult *result = malloc(sizeof(CharsetDetectResult));
    if (!result) return NULL;
    
    memset(result, 0, sizeof(CharsetDetectResult));
    
    // 重置检测器
    uchardet_reset(detector->detector);
    
    // 确定要处理的数据量
    size_t bytes_to_process = len;
    if (bytes_to_process > detector->max_bytes) {
        bytes_to_process = detector->max_bytes;
    }
    
    // 分块处理数据
    size_t chunk_size = 4096;
    size_t processed = 0;
    
    while (processed < bytes_to_process) {
        size_t current_chunk = chunk_size;
        if (processed + current_chunk > bytes_to_process) {
            current_chunk = bytes_to_process - processed;
        }
        
        int ret = uchardet_handle_data(detector->detector,
                                       data + processed,
                                       current_chunk);
        if (ret != 0) {
            break;
        }
        
        processed += current_chunk;
        
        // 早停检查
        if (detector->early_stop && processed >= detector->min_bytes) {
            const char *charset = uchardet_get_charset(detector->detector);
            if (charset && strlen(charset) > 0) {
                // 如果已经有高置信度结果，提前结束
                break;
            }
        }
    }
    
    uchardet_data_end(detector->detector);
    
    // 获取结果
    const char *charset = uchardet_get_charset(detector->detector);
    if (charset && strlen(charset) > 0) {
        strncpy(result->charset, charset, sizeof(result->charset) - 1);
        result->bytes_consumed = processed;
        
        // 简单的置信度计算（基于处理的数据量）
        if (processed >= detector->min_bytes) {
            result->confidence = 0.9;
        } else {
            result->confidence = 0.5 + 0.4 * 
                                (float)processed / detector->min_bytes;
        }
    }
    
    return result;
}

// 释放检测器
void free_detector(CharsetDetector *detector) {
    if (detector) {
        if (detector->detector) {
            uchardet_delete(detector->detector);
        }
        free(detector);
    }
}
```

## 6. 实用工具函数

### 6.1 智能文本读取器
```c
#include <iconv.h>

typedef struct {
    char *text;
    size_t length;
    char encoding[64];
} TextContent;

// 自动检测编码并转换为UTF-8
TextContent* read_text_auto(const char *filename) {
    FILE *file;
    char *buffer;
    size_t file_size;
    TextContent *content = NULL;
    
    // 读取文件
    file = fopen(filename, "rb");
    if (!file) return NULL;
    
    fseek(file, 0, SEEK_END);
    file_size = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    buffer = malloc(file_size);
    if (!buffer) {
        fclose(file);
        return NULL;
    }
    
    fread(buffer, 1, file_size, file);
    fclose(file);
    
    // 检测编码
    uchardet_t ud = uchardet_new();
    uchardet_handle_data(ud, buffer, file_size);
    uchardet_data_end(ud);
    
    const char *charset = uchardet_get_charset(ud);
    if (!charset || strlen(charset) == 0) {
        charset = "UTF-8";  // 默认UTF-8
    }
    
    // 创建返回结构
    content = malloc(sizeof(TextContent));
    strncpy(content->encoding, charset, sizeof(content->encoding) - 1);
    
    // 如果已经是UTF-8，直接返回
    if (strcasecmp(charset, "UTF-8") == 0) {
        content->text = buffer;
        content->length = file_size;
    } else {
        // 转换为UTF-8
        iconv_t cd = iconv_open("UTF-8", charset);
        if (cd != (iconv_t)-1) {
            size_t outlen = file_size * 4;  // 预留足够空间
            char *outbuf = malloc(outlen);
            char *inptr = buffer;
            char *outptr = outbuf;
            size_t inleft = file_size;
            size_t outleft = outlen;
            
            if (iconv(cd, &inptr, &inleft, &outptr, &outleft) != (size_t)-1) {
                content->text = outbuf;
                content->length = outlen - outleft;
                free(buffer);
            } else {
                // 转换失败，返回原始数据
                content->text = buffer;
                content->length = file_size;
                free(outbuf);
            }
            
            iconv_close(cd);
        } else {
            content->text = buffer;
            content->length = file_size;
        }
    }
    
    uchardet_delete(ud);
    return content;
}

// 释放文本内容
void free_text_content(TextContent *content) {
    if (content) {
        free(content->text);
        free(content);
    }
}
```

### 6.2 网页编码检测
```c
// 从HTML中提取声明的编码
char* extract_html_charset(const char *html, size_t len) {
    char *charset = NULL;
    const char *patterns[] = {
        "charset=\"",
        "charset='",
        "charset=",
        NULL
    };
    
    for (int i = 0; patterns[i]; i++) {
        char *pos = strstr(html, patterns[i]);
        if (pos) {
            pos += strlen(patterns[i]);
            char *end = NULL;
            
            if (patterns[i][strlen(patterns[i])-1] == '"') {
                end = strchr(pos, '"');
            } else if (patterns[i][strlen(patterns[i])-1] == '\'') {
                end = strchr(pos, '\'');
            } else {
                end = pos;
                while (*end && !isspace(*end) && 
                       *end != '>' && *end != '/') {
                    end++;
                }
            }
            
            if (end) {
                size_t charset_len = end - pos;
                charset = malloc(charset_len + 1);
                strncpy(charset, pos, charset_len);
                charset[charset_len] = '\0';
                break;
            }
        }
    }
    
    return charset;
}

// 智能网页编码检测
char* detect_html_charset(const char *html_data, size_t len) {
    char *declared_charset = NULL;
    char *detected_charset = NULL;
    
    // 首先尝试从HTML中提取声明的编码
    declared_charset = extract_html_charset(html_data, 
                                           len > 1024 ? 1024 : len);
    
    // 使用uchardet检测实际编码
    uchardet_t ud = uchardet_new();
    uchardet_handle_data(ud, html_data, len);
    uchardet_data_end(ud);
    
    const char *detected = uchardet_get_charset(ud);
    if (detected && strlen(detected) > 0) {
        detected_charset = strdup(detected);
    }
    
    uchardet_delete(ud);
    
    // 比较两个结果
    char *result = NULL;
    if (declared_charset && detected_charset) {
        // 如果都存在，优先使用检测到的
        printf("声明编码: %s, 检测编码: %s\n", 
               declared_charset, detected_charset);
        result = detected_charset;
        free(declared_charset);
    } else if (detected_charset) {
        result = detected_charset;
    } else if (declared_charset) {
        result = declared_charset;
    } else {
        result = strdup("UTF-8");  // 默认
    }
    
    return result;
}
```

## 7. 性能优化

### 7.1 多线程检测
```c
#include <pthread.h>

typedef struct {
    char *filename;
    char charset[64];
    int status;
} DetectTask;

typedef struct {
    DetectTask *tasks;
    int count;
    int current;
    pthread_mutex_t mutex;
} TaskQueue;

void* worker_thread(void *arg) {
    TaskQueue *queue = (TaskQueue *)arg;
    
    while (1) {
        pthread_mutex_lock(&queue->mutex);
        
        if (queue->current >= queue->count) {
            pthread_mutex_unlock(&queue->mutex);
            break;
        }
        
        int index = queue->current++;
        pthread_mutex_unlock(&queue->mutex);
        
        // 执行检测任务
        char *charset = detect_file_charset(queue->tasks[index].filename);
        if (charset) {
            strncpy(queue->tasks[index].charset, charset, 63);
            free(charset);
            queue->tasks[index].status = 1;
        } else {
            queue->tasks[index].status = -1;
        }
    }
    
    return NULL;
}

// 并行检测多个文件
void parallel_detect(char **files, int file_count, int thread_count) {
    pthread_t *threads = malloc(sizeof(pthread_t) * thread_count);
    TaskQueue queue;
    
    // 初始化任务队列
    queue.tasks = malloc(sizeof(DetectTask) * file_count);
    queue.count = file_count;
    queue.current = 0;
    pthread_mutex_init(&queue.mutex, NULL);
    
    for (int i = 0; i < file_count; i++) {
        queue.tasks[i].filename = files[i];
        queue.tasks[i].status = 0;
    }
    
    // 创建工作线程
    for (int i = 0; i < thread_count; i++) {
        pthread_create(&threads[i], NULL, worker_thread, &queue);
    }
    
    // 等待所有线程完成
    for (int i = 0; i < thread_count; i++) {
        pthread_join(threads[i], NULL);
    }
    
    // 输出结果
    for (int i = 0; i < file_count; i++) {
        if (queue.tasks[i].status == 1) {
            printf("%s: %s\n", 
                   queue.tasks[i].filename, 
                   queue.tasks[i].charset);
        }
    }
    
    // 清理资源
    free(queue.tasks);
    free(threads);
    pthread_mutex_destroy(&queue.mutex);
}
```

## 8. 编译和链接

```bash
# 基本编译
gcc -o detector detector.c -luchardet

# 包含iconv支持
gcc -o detector detector.c -luchardet -liconv

# 多线程版本
gcc -o detector detector.c -luchardet -lpthread

# 调试版本
gcc -g -O0 -o detector detector.c -luchardet -DDEBUG

# 使用pkg-config
gcc -o detector detector.c `pkg-config --cflags --libs uchardet`
```

## 9. 错误处理和最佳实践

### 9.1 错误处理示例
```c
typedef enum {
    DETECT_SUCCESS = 0,
    DETECT_ERROR_MEMORY = -1,
    DETECT_ERROR_FILE = -2,
    DETECT_ERROR_UNKNOWN = -3
} DetectError;

typedef struct {
    char *charset;
    DetectError error;
    char error_msg[256];
} DetectResult;

DetectResult* safe_detect(const char *filename) {
    DetectResult *result = calloc(1, sizeof(DetectResult));
    if (!result) {
        return NULL;
    }
    
    FILE *file = fopen(filename, "rb");
    if (!file) {
        result->error = DETECT_ERROR_FILE;
        snprintf(result->error_msg, sizeof(result->error_msg),
                "Cannot open file: %s", filename);
        return result;
    }
    
    // ... 检测逻辑 ...
    
    fclose(file);
    return result;
}
```

## 注意事项

1. **内存管理**：记得释放uchardet_new()创建的句柄
2. **数据量**：通常前几KB数据就足够检测
3. **准确性**：短文本可能检测不准确
4. **编码名称**：返回的编码名称是标准的IANA字符集名称
5. **线程安全**：每个线程应使用独立的检测器实例


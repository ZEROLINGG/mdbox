
## iconv库详解

iconv是一个强大的字符编码转换库，用于在不同字符编码之间进行转换。它在处理国际化文本时非常重要。

## 1. 基本概念

### 1.1 什么是iconv
- **功能**：字符编码转换库
- **支持平台**：Linux、Unix、Windows等
- **主要用途**：处理不同编码格式的文本转换

### 1.2 常见字符编码
```
UTF-8、UTF-16、UTF-32
GBK、GB2312、GB18030
ISO-8859-1、ISO-8859-15
ASCII、BIG5、SHIFT_JIS等
```

## 2. 核心API函数

### 2.1 主要函数接口
```c
#include <iconv.h>

// 打开转换描述符
iconv_t iconv_open(const char *tocode, const char *fromcode);

// 执行转换
size_t iconv(iconv_t cd,
             char **inbuf, size_t *inbytesleft,
             char **outbuf, size_t *outbytesleft);

// 关闭转换描述符
int iconv_close(iconv_t cd);
```

## 3. 基本使用示例

### 3.1 简单的编码转换
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iconv.h>
#include <errno.h>

int convert_encoding(const char *from_charset, 
                     const char *to_charset,
                     char *inbuf, size_t inlen,
                     char *outbuf, size_t outlen) {
    iconv_t cd;
    char **pin = &inbuf;
    char **pout = &outbuf;
    
    // 打开转换句柄
    cd = iconv_open(to_charset, from_charset);
    if (cd == (iconv_t)-1) {
        perror("iconv_open");
        return -1;
    }
    
    // 执行转换
    if (iconv(cd, pin, &inlen, pout, &outlen) == (size_t)-1) {
        perror("iconv");
        iconv_close(cd);
        return -1;
    }
    
    // 关闭句柄
    iconv_close(cd);
    return 0;
}

int main() {
    char *input = "Hello, 世界!";
    char output[256];
    size_t inlen = strlen(input);
    size_t outlen = sizeof(output);
    
    // UTF-8转GBK
    if (convert_encoding("UTF-8", "GBK", 
                        input, inlen, 
                        output, outlen) == 0) {
        printf("转换成功\n");
    }
    
    return 0;
}
```

### 3.2 完整的转换函数封装
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iconv.h>
#include <errno.h>

typedef struct {
    char *data;
    size_t size;
} Buffer;

// 智能编码转换函数
Buffer* smart_convert(const char *from_charset, 
                      const char *to_charset,
                      const char *input, 
                      size_t input_len) {
    iconv_t cd;
    Buffer *result = NULL;
    size_t outlen, converted;
    char *outbuf, *outptr;
    char *inptr;
    size_t inleft, outleft;
    
    // 打开转换描述符
    cd = iconv_open(to_charset, from_charset);
    if (cd == (iconv_t)-1) {
        fprintf(stderr, "不支持从 %s 到 %s 的转换\n", 
                from_charset, to_charset);
        return NULL;
    }
    
    // 分配输出缓冲区（预估大小为输入的4倍）
    outlen = input_len * 4;
    outbuf = (char *)malloc(outlen);
    if (!outbuf) {
        iconv_close(cd);
        return NULL;
    }
    
    // 设置指针和长度
    inptr = (char *)input;
    inleft = input_len;
    outptr = outbuf;
    outleft = outlen;
    
    // 执行转换
    converted = iconv(cd, &inptr, &inleft, &outptr, &outleft);
    
    if (converted == (size_t)-1) {
        switch(errno) {
            case E2BIG:
                fprintf(stderr, "输出缓冲区太小\n");
                break;
            case EILSEQ:
                fprintf(stderr, "输入序列无效\n");
                break;
            case EINVAL:
                fprintf(stderr, "不完整的多字节序列\n");
                break;
            default:
                perror("iconv");
        }
        free(outbuf);
        iconv_close(cd);
        return NULL;
    }
    
    // 创建结果结构
    result = (Buffer *)malloc(sizeof(Buffer));
    result->size = outlen - outleft;
    result->data = (char *)malloc(result->size + 1);
    memcpy(result->data, outbuf, result->size);
    result->data[result->size] = '\0';
    
    // 清理
    free(outbuf);
    iconv_close(cd);
    
    return result;
}

// 释放Buffer
void free_buffer(Buffer *buf) {
    if (buf) {
        free(buf->data);
        free(buf);
    }
}
```

## 4. 高级用法

### 4.1 处理大文件转换
```c
#include <stdio.h>
#include <stdlib.h>
#include <iconv.h>

int convert_file(const char *from_charset, 
                 const char *to_charset,
                 const char *input_file, 
                 const char *output_file) {
    FILE *fin, *fout;
    iconv_t cd;
    char inbuf[4096];
    char outbuf[4096];
    char *inptr, *outptr;
    size_t inleft, outleft, nread;
    
    // 打开文件
    fin = fopen(input_file, "rb");
    if (!fin) {
        perror("打开输入文件失败");
        return -1;
    }
    
    fout = fopen(output_file, "wb");
    if (!fout) {
        fclose(fin);
        perror("打开输出文件失败");
        return -1;
    }
    
    // 创建转换描述符
    cd = iconv_open(to_charset, from_charset);
    if (cd == (iconv_t)-1) {
        fclose(fin);
        fclose(fout);
        perror("iconv_open");
        return -1;
    }
    
    // 逐块转换
    while ((nread = fread(inbuf, 1, sizeof(inbuf), fin)) > 0) {
        inptr = inbuf;
        inleft = nread;
        
        while (inleft > 0) {
            outptr = outbuf;
            outleft = sizeof(outbuf);
            
            size_t ret = iconv(cd, &inptr, &inleft, 
                               &outptr, &outleft);
            
            if (ret == (size_t)-1) {
                if (errno == E2BIG) {
                    // 输出缓冲区满，写入文件后继续
                    fwrite(outbuf, 1, sizeof(outbuf) - outleft, fout);
                    continue;
                } else if (errno == EINVAL) {
                    // 不完整的多字节序列，保存到下一次处理
                    memmove(inbuf, inptr, inleft);
                    break;
                } else {
                    perror("iconv");
                    goto cleanup;
                }
            }
            
            // 写入转换后的数据
            fwrite(outbuf, 1, sizeof(outbuf) - outleft, fout);
        }
    }
    
cleanup:
    iconv_close(cd);
    fclose(fin);
    fclose(fout);
    return 0;
}
```

### 4.2 编码检测与转换
```c
#include <stdio.h>
#include <string.h>
#include <iconv.h>

// 简单的编码检测
const char* detect_encoding(const unsigned char *data, size_t len) {
    // 检查BOM
    if (len >= 3) {
        if (data[0] == 0xEF && data[1] == 0xBB && data[2] == 0xBF) {
            return "UTF-8";
        }
    }
    if (len >= 2) {
        if (data[0] == 0xFF && data[1] == 0xFE) {
            return "UTF-16LE";
        }
        if (data[0] == 0xFE && data[1] == 0xFF) {
            return "UTF-16BE";
        }
    }
    
    // 简单的UTF-8验证
    size_t i = 0;
    while (i < len) {
        if (data[i] < 0x80) {
            // ASCII字符
            i++;
        } else if ((data[i] & 0xE0) == 0xC0) {
            // 2字节UTF-8
            if (i + 1 >= len) break;
            if ((data[i+1] & 0xC0) != 0x80) break;
            i += 2;
        } else if ((data[i] & 0xF0) == 0xE0) {
            // 3字节UTF-8
            if (i + 2 >= len) break;
            if ((data[i+1] & 0xC0) != 0x80) break;
            if ((data[i+2] & 0xC0) != 0x80) break;
            i += 3;
        } else if ((data[i] & 0xF8) == 0xF0) {
            // 4字节UTF-8
            if (i + 3 >= len) break;
            if ((data[i+1] & 0xC0) != 0x80) break;
            if ((data[i+2] & 0xC0) != 0x80) break;
            if ((data[i+3] & 0xC0) != 0x80) break;
            i += 4;
        } else {
            // 非UTF-8，可能是GBK或其他
            return "GBK";
        }
    }
    
    if (i == len) {
        return "UTF-8";
    }
    
    return "GBK";  // 默认返回GBK
}
```

## 5. 错误处理

### 5.1 常见错误码
```c
void handle_iconv_error() {
    switch(errno) {
        case E2BIG:
            printf("错误：输出缓冲区空间不足\n");
            // 解决：增加输出缓冲区大小
            break;
            
        case EILSEQ:
            printf("错误：遇到无效的多字节序列\n");
            // 解决：跳过无效字符或使用替代字符
            break;
            
        case EINVAL:
            printf("错误：不完整的多字节序列\n");
            // 解决：需要更多输入数据
            break;
            
        case EBADF:
            printf("错误：无效的转换描述符\n");
            break;
            
        default:
            perror("iconv错误");
    }
}
```

### 5.2 容错处理
```c
// 带容错的转换函数
int convert_with_fallback(iconv_t cd,
                          char **inbuf, size_t *inbytesleft,
                          char **outbuf, size_t *outbytesleft) {
    while (*inbytesleft > 0) {
        size_t res = iconv(cd, inbuf, inbytesleft, 
                          outbuf, outbytesleft);
        
        if (res == (size_t)-1) {
            if (errno == EILSEQ) {
                // 跳过无效字符
                (*inbuf)++;
                (*inbytesleft)--;
                
                // 插入替代字符（如问号）
                if (*outbytesleft > 0) {
                    **outbuf = '?';
                    (*outbuf)++;
                    (*outbytesleft)--;
                }
            } else {
                return -1;
            }
        }
    }
    return 0;
}
```

## 6. 实用工具函数

### 6.1 查询支持的编码
```c
#include <locale.h>

void list_encodings() {
    // 常用编码列表
    const char *encodings[] = {
        "UTF-8", "UTF-16", "UTF-16LE", "UTF-16BE",
        "UTF-32", "UTF-32LE", "UTF-32BE",
        "GBK", "GB2312", "GB18030",
        "BIG5", "ISO-8859-1", "ASCII",
        NULL
    };
    
    printf("测试支持的编码:\n");
    for (int i = 0; encodings[i]; i++) {
        iconv_t cd = iconv_open("UTF-8", encodings[i]);
        if (cd != (iconv_t)-1) {
            printf("  ✓ %s\n", encodings[i]);
            iconv_close(cd);
        } else {
            printf("  ✗ %s\n", encodings[i]);
        }
    }
}
```

## 7. 编译和链接

```bash
# 编译命令
gcc -o program program.c -liconv

# 在某些系统上可能需要
gcc -o program program.c -L/usr/local/lib -liconv -I/usr/local/include
```

## 注意事项

1. **线程安全**：iconv_t描述符不是线程安全的
2. **内存管理**：注意输出缓冲区大小
3. **编码名称**：不同系统支持的编码名称可能不同
4. **性能考虑**：处理大文件时使用流式处理
5. **错误处理**：始终检查返回值和errno

iconv库是处理字符编码转换的标准工具，掌握它的使用对于国际化应用开发非常重要。
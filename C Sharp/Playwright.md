

## 目录结构

1. **核心基础** - 架构、生命周期、基本概念
2. **元素定位与交互** - 选择器、Locator API、等待策略
3. **媒体捕获** - 截图、视频录制、PDF生成
4. **高级交互** - 表单、键鼠操作、拖拽
5. **网络层操作** - 请求拦截、Mock、API测试
6. **多页面管理** - 窗口、Frame、Shadow DOM
7. **测试配置** - 浏览器配置、设备模拟、认证
8. **调试与优化** - 性能监控、调试技巧、最佳实践
9. **测试框架集成** - NUnit、

---

## 第一部分：核心基础

### 1.1 完整架构与生命周期

```c#
/// <summary>
/// Playwright 完整架构说明
/// </summary>
public class PlaywrightArchitecture
{
    /*
     * 架构层次：
     * 
     * Playwright (全局实例)
     *     ├── BrowserType (浏览器类型：Chromium/Firefox/WebKit)
     *     │   └── Browser (浏览器实例)
     *     │       ├── BrowserContext (隔离的浏览器上下文)
     *     │       │   ├── Page (页面/标签页)
     *     │       │   │   ├── Frame (框架)
     *     │       │   │   ├── Locator (元素定位器)
     *     │       │   │   ├── ElementHandle (元素句柄)
     *     │       │   │   ├── JSHandle (JavaScript句柄)
     *     │       │   │   ├── Request (网络请求)
     *     │       │   │   ├── Response (网络响应)
     *     │       │   │   ├── Route (路由)
     *     │       │   │   ├── WebSocket (WebSocket连接)
     *     │       │   │   ├── Worker (Web Worker)
     *     │       │   │   └── ConsoleMessage (控制台消息)
     *     │       │   ├── APIRequestContext (API请求上下文)
     *     │       │   ├── Tracing (追踪)
     *     │       │   ├── Coverage (覆盖率)
     *     │       │   └── ServiceWorker (服务工作者)
     *     │       └── CDPSession (Chrome DevTools Protocol会话)
     *     └── Selectors (选择器引擎)
     */

    public async Task CompleteLifecycleExample()
    {
        // 1. 初始化阶段
        using var playwright = await Playwright.CreateAsync();
        
        // 2. 浏览器启动配置
        var browserOptions = new BrowserTypeLaunchOptions
        {
            // 基础配置
            Headless = false,                    // 是否无头模式
            Channel = "chrome",                  // 浏览器通道：chrome, msedge, chrome-beta等
            ExecutablePath = null,               // 自定义浏览器路径
            
            // 性能配置
            SlowMo = 0,                         // 操作延迟（毫秒）
            Timeout = 30000,                     // 超时时间
            
            // 启动参数
            Args = new[]
            {
                "--start-maximized",            // 最大化窗口
                "--disable-blink-features=AutomationControlled", // 隐藏自动化特征
                "--disable-dev-shm-usage",      // 禁用/dev/shm使用
                "--no-sandbox",                  // 禁用沙箱（Docker环境需要）
                "--disable-setuid-sandbox",     // 禁用setuid沙箱
                "--disable-web-security",        // 禁用同源策略
                "--disable-features=IsolateOrigins,site-per-process", // 禁用站点隔离
            },
            
            // 调试配置
            Devtools = false,                   // 是否自动打开开发者工具
            DownloadsPath = "./downloads",      // 下载目录
            
            // 环境变量
            Env = new Dictionary<string, string>
            {
                ["DEBUG"] = "pw:api",           // 启用API调试日志
                ["NODE_ENV"] = "test"
            },
            
            // 进程管理
            HandleSIGINT = true,                // 处理Ctrl+C
            HandleSIGTERM = true,               // 处理终止信号
            HandleSIGHUP = true,                // 处理挂起信号
            
            // 代理配置
            Proxy = new Proxy
            {
                Server = "http://proxy.example.com:8080",
                Bypass = "localhost,127.0.0.1",
                Username = "user",
                Password = "pass"
            }
        };
        
        await using var browser = await playwright.Chromium.LaunchAsync(browserOptions);
        
        // 3. 上下文配置
        var contextOptions = new BrowserNewContextOptions
        {
            // 视口和显示
            ViewportSize = new ViewportSize { Width = 1920, Height = 1080 },
            DeviceScaleFactor = 1,
            IsMobile = false,
            HasTouch = false,
            
            // 权限和功能
            JavaScriptEnabled = true,
            IgnoreHTTPSErrors = true,
            Offline = false,
            
            // 地理位置
            Geolocation = new Geolocation { Latitude = 37.7749f, Longitude = -122.4194f },
            Permissions = new[] { "geolocation", "notifications", "camera", "microphone" },
            
            // 语言和时区
            Locale = "en-US",
            TimezoneId = "America/Los_Angeles",
            
            // 用户代理
            UserAgent = "Custom User Agent String",
            
            // 存储
            StorageState = "./auth.json",        // 加载已保存的认证状态
            
            // HTTP认证
            HttpCredentials = new HttpCredentials
            {
                Username = "user",
                Password = "pass"
            },
            
            // 录制配置
            RecordVideoDir = "./videos",
            RecordVideoSize = new RecordVideoSize { Width = 1280, Height = 720 },
            
            // 其他
            ExtraHTTPHeaders = new Dictionary<string, string>
            {
                ["X-Custom-Header"] = "value"
            },
            BaseURL = "https://example.com",    // 基础URL
            ColorScheme = ColorScheme.Dark,
            ReducedMotion = ReducedMotion.Reduce,
            ForcedColors = ForcedColors.Active
        };
        
        var context = await browser.NewContextAsync(contextOptions);
        
        // 4. 页面创建和配置
        var page = await context.NewPageAsync();
        
        // 设置默认超时
        page.SetDefaultTimeout(60000);
        page.SetDefaultNavigationTimeout(30000);
        
        // 5. 使用页面
        await page.GotoAsync("https://example.com");
        
        // 6. 清理资源（using语句会自动处理）
    }
}
```

### 1.2 选择器引擎完整指南

```c#
public class ComprehensiveSelectors
{
    private IPage _page;
    
    public async Task AllSelectorTypes()
    {
        // ========== CSS 选择器 ==========
        // 基础选择器
        await _page.ClickAsync(".class");                      // 类选择器
        await _page.ClickAsync("#id");                        // ID选择器
        await _page.ClickAsync("tag");                        // 标签选择器
        await _page.ClickAsync("[attribute]");                // 属性选择器
        await _page.ClickAsync("[attr='value']");            // 属性值选择器
        await _page.ClickAsync("[attr*='partial']");         // 属性包含
        await _page.ClickAsync("[attr^='start']");           // 属性开头
        await _page.ClickAsync("[attr$='end']");             // 属性结尾
        
        // 组合选择器
        await _page.ClickAsync("div.class");                  // 元素+类
        await _page.ClickAsync("div#id");                     // 元素+ID
        await _page.ClickAsync("div[attr='value']");         // 元素+属性
        await _page.ClickAsync("parent > child");             // 直接子元素
        await _page.ClickAsync("ancestor descendant");        // 后代元素
        await _page.ClickAsync("prev + next");                // 相邻兄弟
        await _page.ClickAsync("prev ~ siblings");            // 所有兄弟
        
        // 伪类选择器
        await _page.ClickAsync("a:hover");                    // 悬停状态
        await _page.ClickAsync("input:focus");                // 焦点状态
        await _page.ClickAsync("li:first-child");             // 第一个子元素
        await _page.ClickAsync("li:last-child");              // 最后一个子元素
        await _page.ClickAsync("li:nth-child(3)");            // 第N个子元素
        await _page.ClickAsync("li:nth-child(odd)");          // 奇数子元素
        await _page.ClickAsync("li:nth-child(even)");         // 偶数子元素
        await _page.ClickAsync("input:checked");              // 选中状态
        await _page.ClickAsync("input:disabled");             // 禁用状态
        await _page.ClickAsync("div:empty");                  // 空元素
        await _page.ClickAsync("p:not(.exclude)");            // 排除选择器
        
        // ========== XPath 选择器 ==========
        await _page.ClickAsync("xpath=//div");                // 所有div
        await _page.ClickAsync("xpath=//div[@class='test']"); // 带属性的div
        await _page.ClickAsync("xpath=//div[text()='Hello']"); // 文本匹配
        await _page.ClickAsync("xpath=//div[contains(@class, 'test')]"); // 部分匹配
        await _page.ClickAsync("xpath=//div[contains(text(), 'Hello')]"); // 文本包含
        await _page.ClickAsync("xpath=//parent/child");       // 父子关系
        await _page.ClickAsync("xpath=//div[1]");             // 第一个div
        await _page.ClickAsync("xpath=//div[last()]");        // 最后一个div
        await _page.ClickAsync("xpath=//div[@id='test']/following-sibling::span"); // 后续兄弟
        await _page.ClickAsync("xpath=//div[@id='test']/preceding-sibling::span"); // 前置兄弟
        await _page.ClickAsync("xpath=//div[@id='test']/parent::*"); // 父元素
        await _page.ClickAsync("xpath=//div[@id='test']/ancestor::form"); // 祖先元素
        
        // ========== 文本选择器 ==========
        await _page.ClickAsync("text=Exact Text");            // 精确匹配
        await _page.ClickAsync("text=/regex pattern/i");      // 正则匹配
        await _page.ClickAsync("text=Partial");               // 部分匹配
        await _page.ClickAsync("text=\"Quoted Text\"");       // 引号文本
        await _page.ClickAsync("'Exact Text'");               // 简写精确匹配
        
        // ========== Playwright 特有选择器 ==========
        // Role 选择器（ARIA角色）
        await _page.ClickAsync("role=button");
        await _page.ClickAsync("role=button[name='Submit']");
        await _page.ClickAsync("role=checkbox[checked]");
        await _page.ClickAsync("role=heading[level=1]");
        await _page.ClickAsync("role=link[name='Home']");
        await _page.ClickAsync("role=list >> role=listitem");
        await _page.ClickAsync("role=navigation");
        await _page.ClickAsync("role=textbox[name='Email']");
        
        // 其他内置选择器
        await _page.ClickAsync("alt=Image Alt Text");         // 图片alt属性
        await _page.ClickAsync("title=Tooltip Text");         // title属性
        await _page.ClickAsync("placeholder=Enter text");     // placeholder属性
        await _page.ClickAsync("label=Field Label");          // label文本
        
        // ========== 链式选择器 ==========
        await _page.ClickAsync("div.container >> text=Click"); // 组合选择
        await _page.ClickAsync("xpath=//form >> input[name='email']"); // XPath + CSS
        await _page.ClickAsync("#parent >> nth=2 >> text=Item"); // 多级链式
        
        // ========== 相对定位选择器 ==========
        await _page.ClickAsync("button:near(.label)");        // 附近元素
        await _page.ClickAsync("button:near(.label, 100)");   // 100px范围内
        await _page.ClickAsync("button:left-of(.reference)"); // 左侧元素
        await _page.ClickAsync("button:right-of(.reference)");// 右侧元素
        await _page.ClickAsync("button:above(.reference)");   // 上方元素
        await _page.ClickAsync("button:below(.reference)");   // 下方元素
    }
    
    public async Task CustomSelectorEngine()
    {
        // 注册自定义选择器引擎
        await _page.Selectors.RegisterAsync("data-test", new()
        {
            Script = @"
                {
                    query(root, selector) {
                        return root.querySelector(`[data-test='${selector}']`);
                    },
                    queryAll(root, selector) {
                        return Array.from(root.querySelectorAll(`[data-test='${selector}']`));
                    }
                }
            "
        });
        
        // 使用自定义选择器
        await _page.ClickAsync("data-test=submit-button");
        await _page.FillAsync("data-test=email-input", "test@example.com");
    }
}
```

## 第二部分：元素定位与交互

### 2.1 Locator API 完整方法列表

```c#
public class LocatorCompleteAPI
{
    private IPage _page;
    
    public async Task AllLocatorMethods()
    {
        var locator = _page.Locator(".element");
        
        // ========== 状态检查方法 ==========
        bool isVisible = await locator.IsVisibleAsync();      // 是否可见
        bool isHidden = await locator.IsHiddenAsync();        // 是否隐藏
        bool isEnabled = await locator.IsEnabledAsync();      // 是否启用
        bool isDisabled = await locator.IsDisabledAsync();    // 是否禁用
        bool isEditable = await locator.IsEditableAsync();    // 是否可编辑
        bool isChecked = await locator.IsCheckedAsync();      // 是否选中（checkbox/radio）
        
        // ========== 等待方法 ==========
        await locator.WaitForAsync(new LocatorWaitForOptions
        {
            State = WaitForSelectorState.Visible,    // visible|hidden|attached|detached
            Timeout = 30000
        });
        
        // ========== 获取信息方法 ==========
        int count = await locator.CountAsync();               // 匹配元素数量
        string text = await locator.TextContentAsync();       // 文本内容
        string innerText = await locator.InnerTextAsync();    // 内部文本
        string innerHTML = await locator.InnerHTMLAsync();    // HTML内容
        string value = await locator.InputValueAsync();       // 输入值
        string attr = await locator.GetAttributeAsync("id");  // 属性值
        var allTexts = await locator.AllTextContentsAsync();  // 所有文本
        var allInnerTexts = await locator.AllInnerTextsAsync(); // 所有内部文本
        
        // ========== 定位相关方法 ==========
        var first = locator.First;                           // 第一个元素
        var last = locator.Last;                            // 最后一个元素
        var nth = locator.Nth(2);                           // 第N个元素（0开始）
        
        // ========== 过滤方法 ==========
        var filtered = locator.Filter(new LocatorFilterOptions
        {
            HasText = "text",                               // 包含文本
            HasTextString = "exact text",                   // 精确文本
            HasTextRegex = new Regex(@"\d+"),              // 正则匹配
            Has = _page.Locator(".child"),                 // 包含子元素
            HasNot = _page.Locator(".exclude")             // 不包含元素
        });
        
        // ========== 相对定位 ==========
        var parent = locator.Locator("..");                 // 父元素
        var child = locator.Locator(".child");              // 子元素
        
        // ========== 交互方法 ==========
        await locator.ClickAsync(new LocatorClickOptions
        {
            Button = MouseButton.Left,                      // left|right|middle
            ClickCount = 1,                                 // 点击次数
            Delay = 0,                                      // 点击间隔
            Position = new Position { X = 0, Y = 0 },      // 点击位置
            Modifiers = new[] { KeyboardModifier.Control }, // 修饰键
            Force = false,                                  // 强制点击
            NoWaitAfter = false,                           // 不等待导航
            Trial = false,                                  // 试运行
            Timeout = 30000                                // 超时
        });
        
        await locator.DblClickAsync();                     // 双击
        await locator.TripleClickAsync();                  // 三击（选择整行）
        
        // 右键菜单
        await locator.ClickAsync(new() { Button = MouseButton.Right });
        
        // ========== 输入方法 ==========
        await locator.FillAsync("text");                   // 填充文本
        await locator.ClearAsync();                        // 清空
        await locator.TypeAsync("text", new LocatorTypeOptions
        {
            Delay = 100,                                   // 按键延迟
            NoWaitAfter = false,
            Timeout = 30000
        });
        
        await locator.PressAsync("Enter");                 // 按键
        await locator.PressAsync("Control+A");             // 组合键
        await locator.PressSequentiallyAsync("text", new() // 逐字输入
        {
            Delay = 50
        });
        
        // ========== 选择方法 ==========
        await locator.SelectOptionAsync("value");          // 选择选项
        await locator.SelectOptionAsync(new[] { "1", "2" }); // 多选
        await locator.SelectOptionAsync(new SelectOptionValue
        {
            Value = "value",                              // 按值选择
            Label = "Label",                              // 按标签选择
            Index = 0                                      // 按索引选择
        });
        
        await locator.SelectTextAsync();                   // 选择文本
        
        // ========== 复选框/单选按钮 ==========
        await locator.CheckAsync();                        // 选中
        await locator.UncheckAsync();                      // 取消选中
        await locator.SetCheckedAsync(true);               // 设置选中状态
        
        // ========== 文件上传 ==========
        await locator.SetInputFilesAsync("file.txt");      // 单文件
        await locator.SetInputFilesAsync(new[] { "1.txt", "2.txt" }); // 多文件
        await locator.SetInputFilesAsync(new FilePayload   // 内存文件
        {
            Name = "test.txt",
            MimeType = "text/plain",
            Buffer = Encoding.UTF8.GetBytes("content")
        });
        
        // ========== 拖拽 ==========
        await locator.DragToAsync(_page.Locator("#target"), new LocatorDragToOptions
        {
            Force = false,
            NoWaitAfter = false,
            SourcePosition = new() { X = 0, Y = 0 },
            TargetPosition = new() { X = 0, Y = 0 },
            Trial = false,
            Timeout = 30000
        });
        
        // ========== 悬停 ==========
        await locator.HoverAsync(new LocatorHoverOptions
        {
            Position = new() { X = 0, Y = 0 },
            Modifiers = new[] { KeyboardModifier.Shift },
            Force = false,
            NoWaitAfter = false,
            Trial = false,
            Timeout = 30000
        });
        
        // ========== 焦点 ==========
        await locator.FocusAsync();                        // 获取焦点
        await locator.BlurAsync();                         // 失去焦点
        
        // ========== 滚动 ==========
        await locator.ScrollIntoViewIfNeededAsync();       // 滚动到可见
        
        // ========== 截图 ==========
        await locator.ScreenshotAsync(new LocatorScreenshotOptions
        {
            Path = "element.png",
            Type = ScreenshotType.Png,                    // png|jpeg
            Quality = 100,                                // jpeg质量
            OmitBackground = false,                       // 透明背景
            Animations = ScreenshotAnimations.Disabled,   // 禁用动画
            Caret = ScreenshotCaret.Hide,                // 隐藏光标
            Scale = ScreenshotScale.Css,                 // css|device
            Mask = new[] { _page.Locator(".mask") },     // 遮罩元素
            MaskColor = "pink",                          // 遮罩颜色
            Timeout = 30000
        });
        
        // ========== 评估 ==========
        var result = await locator.EvaluateAsync<string>("el => el.className");
        var allResults = await locator.EvaluateAllAsync<string[]>(
            "elements => elements.map(e => e.textContent)"
        );
        
        // ========== 元素句柄 ==========
        var handle = await locator.ElementHandleAsync();   // 获取元素句柄
        var handles = await locator.ElementHandlesAsync(); // 获取所有元素句柄
        
        // ========== 边界框 ==========
        var box = await locator.BoundingBoxAsync();        // 获取边界框
        if (box != null)
        {
            Console.WriteLine($"Position: {box.X}, {box.Y}");
            Console.WriteLine($"Size: {box.Width}x{box.Height}");
        }
    }
}
```

### 2.2 等待策略详解

```c#
public class WaitingStrategies
{
    private IPage _page;
    
    public async Task ComprehensiveWaitingExamples()
    {
        // ========== 页面等待 ==========
        // 等待导航
        await _page.WaitForURLAsync("**/success");
        await _page.WaitForURLAsync(new Regex(@".*\/user\/\d+"));
        await _page.WaitForURLAsync(url => url.Contains("dashboard"));
        
        // 等待加载状态
        await _page.WaitForLoadStateAsync(LoadState.Load);        // load事件
        await _page.WaitForLoadStateAsync(LoadState.DOMContentLoaded); // DOM加载
        await _page.WaitForLoadStateAsync(LoadState.NetworkIdle); // 网络空闲
        
        // 等待函数
        await _page.WaitForFunctionAsync("() => document.readyState === 'complete'");
        await _page.WaitForFunctionAsync(
            "count => document.querySelectorAll('.item').length >= count",
            10  // 参数
        );
        
        // 等待超时
        await _page.WaitForTimeoutAsync(1000);
        
        // ========== 元素等待 ==========
        // 等待选择器
        var element = await _page.WaitForSelectorAsync(".dynamic", new WaitForSelectorOptions
        {
            State = WaitForSelectorState.Visible,         // visible|hidden|attached|detached
            Strict = true,                                // 严格模式（只匹配一个）
            Timeout = 30000
        });
        
        // Locator等待
        var locator = _page.Locator(".element");
        await locator.WaitForAsync();
        await locator.WaitForAsync(new() { State = WaitForSelectorState.Hidden });
        
        // ========== 网络等待 ==========
        // 等待请求
        var requestTask = _page.WaitForRequestAsync("**/api/data");
        await _page.ClickAsync("#load");
        var request = await requestTask;
        
        // 等待响应
        var responseTask = _page.WaitForResponseAsync(
            resp => resp.Url.Contains("/api") && resp.Status == 200
        );
        await _page.ClickAsync("#submit");
        var response = await responseTask;
        
        // 等待WebSocket
        var wsTask = _page.WaitForWebSocketAsync();
        await _page.ClickAsync("#connect");
        var ws = await wsTask;
        
        // ========== 事件等待 ==========
        // 等待控制台消息
        var consoleTask = _page.WaitForConsoleMessageAsync();
        await _page.EvaluateAsync("console.log('test')");
        var consoleMsg = await consoleTask;
        
        // 等待下载
        var downloadTask = _page.WaitForDownloadAsync();
        await _page.ClickAsync("#download");
        var download = await downloadTask;
        
        // 等待文件选择器
        var fileChooserTask = _page.WaitForFileChooserAsync();
        await _page.ClickAsync("#upload");
        var fileChooser = await fileChooserTask;
        
        // 等待弹出窗口
        var popupTask = _page.WaitForPopupAsync();
        await _page.ClickAsync("#open-popup");
        var popup = await popupTask;
        
        // ========== 自定义等待 ==========
        // 组合等待
        var tasks = new[]
        {
            _page.WaitForSelectorAsync("#option1"),
            _page.WaitForSelectorAsync("#option2"),
            _page.WaitForSelectorAsync("#option3")
        };
        var firstAppeared = await Task.WhenAny(tasks);
        
        // 超时处理
        using var cts = new CancellationTokenSource(5000);
        try
        {
            await _page.WaitForSelectorAsync("#slow-element", new()
            {
                Timeout = 0  // 禁用超时
            }).WaitAsync(cts.Token);
        }
        catch (OperationCanceledException)
        {
            Console.WriteLine("等待超时");
        }
        
        // 轮询等待
        async Task<bool> WaitForCondition(Func<Task<bool>> condition, int timeout = 30000)
        {
            var endTime = DateTime.UtcNow.AddMilliseconds(timeout);
            while (DateTime.UtcNow < endTime)
            {
                if (await condition())
                    return true;
                await Task.Delay(100);
            }
            return false;
        }
        
        var success = await WaitForCondition(async () =>
        {
            var text = await _page.TextContentAsync(".status");
            return text == "Complete";
        });
    }
}
```

## 第三部分：媒体捕获（截图、视频、PDF）

### 3.1 截图功能详解

```c#
public class ScreenshotCapture
{
    private IPage _page;
    
    public async Task ComprehensiveScreenshotExamples()
    {
        // ========== 页面截图 ==========
        // 基础截图
        await _page.ScreenshotAsync(new PageScreenshotOptions
        {
            Path = "screenshot.png",                      // 保存路径
            Type = ScreenshotType.Png,                   // png|jpeg
            Quality = 90,                                // JPEG质量（1-100）
            FullPage = true,                             // 完整页面
            Clip = new Clip                             // 裁剪区域
            {
                X = 0,
                Y = 0,
                Width = 800,
                Height = 600
            },
            OmitBackground = true,                      // 透明背景
            Animations = ScreenshotAnimations.Disabled,  // disabled|allow
            Caret = ScreenshotCaret.Hide,               // hide|initial
            Scale = ScreenshotScale.Css,                // css|device
            Timeout = 30000
        });
        
        // 获取截图字节数组
        var bytes = await _page.ScreenshotAsync();
        await File.WriteAllBytesAsync("screenshot.png", bytes);
        
        // Base64编码
        var base64 = Convert.ToBase64String(bytes);
        var dataUri = $"data:image/png;base64,{base64}";
        
        // ========== 元素截图 ==========
        var element = _page.Locator("#element");
        await element.ScreenshotAsync(new LocatorScreenshotOptions
        {
            Path = "element.png",
            Type = ScreenshotType.Png,
            Quality = 100,
            OmitBackground = false,
            Animations = ScreenshotAnimations.Allow,
            Caret = ScreenshotCaret.Initial,
            Scale = ScreenshotScale.Device,
            Mask = new[] { _page.Locator(".overlay") }, // 遮罩其他元素
            MaskColor = "#FF00FF",                      // 遮罩颜色
            Timeout = 30000
        });
        
        // ========== 高级截图技巧 ==========
        // 截图前准备
        await _page.EvaluateAsync(@"() => {
            // 隐藏滚动条
            document.documentElement.style.overflow = 'hidden';
            // 等待图片加载
            return Promise.all(
                Array.from(document.images)
                    .filter(img => !img.complete)
                    .map(img => new Promise(resolve => {
                        img.onload = img.onerror = resolve;
                    }))
            );
        }");
        
        // 移除动态元素
        await _page.EvaluateAsync(@"() => {
            // 移除广告
            document.querySelectorAll('.ad, .popup').forEach(el => el.remove());
            // 停止动画
            document.querySelectorAll('*').forEach(el => {
                el.style.animation = 'none';
                el.style.transition = 'none';
            });
        }");
        
        // 多个元素截图
        var elements = await _page.Locator(".screenshot-target").AllAsync();
        for (int i = 0; i < elements.Count; i++)
        {
            await elements[i].ScreenshotAsync(new()
            {
                Path = $"element_{i}.png"
            });
        }
        
        // 滚动截图
        async Task<byte[]> CaptureFullPageByScrolling()
        {
            var images = new List<byte[]>();
            var viewportHeight = await _page.EvaluateAsync<int>("window.innerHeight");
            var totalHeight = await _page.EvaluateAsync<int>("document.body.scrollHeight");
            
            for (int offset = 0; offset < totalHeight; offset += viewportHeight)
            {
                await _page.EvaluateAsync($"window.scrollTo(0, {offset})");
                await _page.WaitForTimeoutAsync(500); // 等待渲染
                
                var screenshot = await _page.ScreenshotAsync(new()
                {
                    FullPage = false
                });
                images.Add(screenshot);
            }
            
            // 这里需要使用图像处理库合并图片
            return MergeImages(images);
        }
        
        // 对比截图（用于视觉测试）
        async Task<bool> CompareScreenshots(string baseline, string current)
        {
            var baselineBytes = await File.ReadAllBytesAsync(baseline);
            var currentBytes = await _page.ScreenshotAsync();
            
            // 使用图像对比库（如ImageSharp）
            // return CompareImages(baselineBytes, currentBytes);
            return true;
        }
    }
    
    private byte[] MergeImages(List<byte[]> images)
    {
        // 实现图片合并逻辑
        return images.FirstOrDefault() ?? Array.Empty<byte>();
    }
}
```

### 3.2 视频录制功能

```c#
public class VideoRecording
{
    private IBrowser _browser;
    
    public async Task VideoRecordingExamples()
    {
        // ========== 上下文级别录制 ==========
        var context = await _browser.NewContextAsync(new BrowserNewContextOptions
        {
            RecordVideoDir = "./videos",                 // 视频保存目录
            RecordVideoSize = new RecordVideoSize        // 视频尺寸
            {
                Width = 1280,
                Height = 720
            },
            ViewportSize = new ViewportSize              // 视口尺寸
            {
                Width = 1280,
                Height = 720
            }
        });
        
        var page = await context.NewPageAsync();
        
        // 执行测试操作
        await page.GotoAsync("https://example.com");
        await page.ClickAsync("#button");
        await page.FillAsync("#input", "test");
        
        // 关闭页面以保存视频
        await page.CloseAsync();
        
        // 获取视频路径
        var video = page.Video;
        if (video != null)
        {
            var videoPath = await video.PathAsync();
            Console.WriteLine($"Video saved to: {videoPath}");
            
            // 保存到特定位置
            await video.SaveAsAsync("./test-recording.webm");
            
            // 删除视频
            await video.DeleteAsync();
        }
        
        // ========== 条件录制 ==========
        var recordVideo = Environment.GetEnvironmentVariable("RECORD_VIDEO") == "true";
        
        var contextOptions = new BrowserNewContextOptions
        {
            ViewportSize = new ViewportSize { Width = 1920, Height = 1080 }
        };
        
        if (recordVideo)
        {
            contextOptions.RecordVideoDir = "./videos";
            contextOptions.RecordVideoSize = new RecordVideoSize
            {
                Width = 1920,
                Height = 1080
            };
        }
        
        var ctx = await _browser.NewContextAsync(contextOptions);
        
        // ========== 测试失败时保存视频 ==========
        IPage testPage = null;
        try
        {
            testPage = await ctx.NewPageAsync();
            await testPage.GotoAsync("https://example.com");
            // 测试操作...
            
            // 测试成功，删除视频
            if (testPage.Video != null)
            {
                await testPage.Video.DeleteAsync();
            }
        }
        catch (Exception ex)
        {
            // 测试失败，保存视频
            if (testPage?.Video != null)
            {
                var timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
                await testPage.Video.SaveAsAsync($"./failures/test_failure_{timestamp}.webm");
            }
            throw;
        }
        finally
        {
            await testPage?.CloseAsync();
            await ctx.CloseAsync();
        }
    }
    
    public async Task ScreenRecordingWithAnnotations()
    {
        // 创建带录制的上下文
        var context = await _browser.NewContextAsync(new()
        {
            RecordVideoDir = "./videos",
            RecordVideoSize = new() { Width = 1280, Height = 720 }
        });
        
        var page = await context.NewPageAsync();
        
        // 添加注释层
        await page.AddInitScriptAsync(@"
            window.addAnnotation = (text, x, y) => {
                const div = document.createElement('div');
                div.style.position = 'fixed';
                div.style.left = x + 'px';
                div.style.top = y + 'px';
                div.style.background = 'yellow';
                div.style.padding = '5px';
                div.style.border = '2px solid red';
                div.style.zIndex = '10000';
                div.style.fontSize = '14px';
                div.style.fontWeight = 'bold';
                div.textContent = text;
                document.body.appendChild(div);
                setTimeout(() => div.remove(), 3000);
            };
        ");
        
        await page.GotoAsync("https://example.com");
        
        // 添加步骤注释
        await page.EvaluateAsync("window.addAnnotation('Step 1: Click button', 100, 100)");
        await page.ClickAsync("#button");
        
        await page.EvaluateAsync("window.addAnnotation('Step 2: Fill form', 100, 150)");
        await page.FillAsync("#input", "test data");
        
        await page.CloseAsync();
    }
}
```

### 3.3 PDF生成

```c#
public class PDFGeneration
{
    private IPage _page;
    
    public async Task ComprehensivePDFExamples()
    {
        // ========== 基础PDF生成 ==========
        await _page.GotoAsync("https://example.com");
        
        await _page.PdfAsync(new PagePdfOptions
        {
            Path = "document.pdf",                      // 保存路径
            Scale = 1,                                  // 缩放比例 (0.1-2)
            DisplayHeaderFooter = true,                 // 显示页眉页脚
            HeaderTemplate = @"
                <div style='font-size: 10px; text-align: center; width: 100%;'>
                    <span class='title'></span>
                </div>
            ",
            FooterTemplate = @"
                <div style='font-size: 10px; text-align: center; width: 100%;'>
                    Page <span class='pageNumber'></span> of <span class='totalPages'></span>
                </div>
            ",
            PrintBackground = true,                     // 打印背景
            Landscape = false,                          // 横向打印
            PageRanges = "1-5",                        // 页面范围
            Format = "A4",                              // 纸张格式
            Width = "210mm",                            // 自定义宽度
            Height = "297mm",                           // 自定义高度
            Margin = new Margin                        // 页边距
            {
                Top = "20mm",
                Bottom = "20mm",
                Left = "10mm",
                Right = "10mm"
            },
            PreferCSSPageSize = false,                 // 使用CSS页面大小
            Outline = true,                             // 生成大纲
            Tagged = true                               // 生成带标签的PDF（可访问性）
        });
        
        // 获取PDF字节数组
        var pdfBytes = await _page.PdfAsync();
        await File.WriteAllBytesAsync("output.pdf", pdfBytes);
        
        // ========== 高级PDF生成 ==========
        // 准备打印样式
        await _page.AddStyleTagAsync(new PageAddStyleTagOptions
        {
            Content = @"
                @media print {
                    .no-print { display: none; }
                    .page-break { page-break-after: always; }
                    body { font-size: 12pt; }
                    h1 { font-size: 18pt; }
                }
            "
        });
        
        // 修改页面内容
        await _page.EvaluateAsync(@"() => {
            // 移除不需要的元素
            document.querySelectorAll('.advertisement, .sidebar').forEach(el => el.remove());
            
            // 展开所有折叠内容
            document.querySelectorAll('.collapsed').forEach(el => {
                el.classList.remove('collapsed');
                el.classList.add('expanded');
            });
            
            // 将链接转换为脚注
            const links = document.querySelectorAll('a[href]');
            links.forEach((link, index) => {
                const footnote = document.createElement('sup');
                footnote.textContent = `[${index + 1}]`;
                link.parentNode.insertBefore(footnote, link.nextSibling);
            });
        }");
        
        // 生成目录
        var headings = await _page.EvaluateAsync<List<object>>(@"() => {
            return Array.from(document.querySelectorAll('h1, h2, h3')).map(h => ({
                level: parseInt(h.tagName[1]),
                text: h.textContent,
                id: h.id || ''
            }));
        }");
        
        // 批量生成PDF
        var urls = new[] { "page1.html", "page2.html", "page3.html" };
        var pdfs = new List<byte[]>();
        
        foreach (var url in urls)
        {
            await _page.GotoAsync(url);
            var pdf = await _page.PdfAsync();
            pdfs.Add(pdf);
        }
        
        // 合并PDF（需要使用PDF库如iTextSharp）
        // MergePDFs(pdfs);
        
        // ========== 发票/报告生成 ==========
        // 加载HTML模板
        var templateHtml = await File.ReadAllTextAsync("invoice-template.html");
        
        // 注入数据
        var invoiceData = new
        {
            invoiceNumber = "INV-001",
            date = DateTime.Now.ToString("yyyy-MM-dd"),
            customer = new
            {
                name = "John Doe",
                address = "123 Main St"
            },
            items = new[]
            {
                new { description = "Item 1", quantity = 2, price = 10.00 },
                new { description = "Item 2", quantity = 1, price = 25.00 }
            },
            total = 45.00
        };
        
        // 渲染模板
        await _page.SetContentAsync(templateHtml);
        await _page.EvaluateAsync($@"(data) => {{
            // 使用模板引擎或手动替换
            document.getElementById('invoice-number').textContent = data.invoiceNumber;
            document.getElementById('date').textContent = data.date;
            // ... 填充其他数据
        }}", invoiceData);
        
        // 生成PDF
        await _page.PdfAsync(new()
        {
            Path = $"invoice_{invoiceData.invoiceNumber}.pdf",
            Format = "A4",
            PrintBackground = true
        });
    }
}
```

## 第四部分：高级交互

### 4.1 键盘和鼠标操作

```c#
public class KeyboardMouseOperations
{
    private IPage _page;
    
    public async Task CompleteKeyboardOperations()
    {
        // ========== 键盘基础操作 ==========
        var keyboard = _page.Keyboard;
        
        // 单个按键
        await keyboard.PressAsync("Enter");
        await keyboard.PressAsync("Tab");
        await keyboard.PressAsync("Escape");
        await keyboard.PressAsync("Space");
        await keyboard.PressAsync("Backspace");
        await keyboard.PressAsync("Delete");
        await keyboard.PressAsync("ArrowUp");
        await keyboard.PressAsync("ArrowDown");
        await keyboard.PressAsync("ArrowLeft");
        await keyboard.PressAsync("ArrowRight");
        await keyboard.PressAsync("Home");
        await keyboard.PressAsync("End");
        await keyboard.PressAsync("PageUp");
        await keyboard.PressAsync("PageDown");
        
        // 功能键
        await keyboard.PressAsync("F1");
        await keyboard.PressAsync("F12");
        
        // 组合键
        await keyboard.PressAsync("Control+A");         // 全选
        await keyboard.PressAsync("Control+C");         // 复制
        await keyboard.PressAsync("Control+V");         // 粘贴
        await keyboard.PressAsync("Control+X");         // 剪切
        await keyboard.PressAsync("Control+Z");         // 撤销
        await keyboard.PressAsync("Control+Shift+Z");   // 重做
        await keyboard.PressAsync("Alt+Tab");           // 切换窗口
        await keyboard.PressAsync("Shift+Tab");         // 反向Tab
        
        // 按下和释放
        await keyboard.DownAsync("Shift");
        await keyboard.PressAsync("A");                 // 大写A
        await keyboard.UpAsync("Shift");
        
        // 输入文本
        await keyboard.TypeAsync("Hello World!");
        await keyboard.TypeAsync("Special chars: @#$%", new() { Delay = 100 });
        
        // 插入文本（不触发键盘事件）
        await keyboard.InsertTextAsync("Pasted text");
        
        // ========== 鼠标操作 ==========
        var mouse = _page.Mouse;
        
        // 移动鼠标
        await mouse.MoveAsync(100, 200);
        await mouse.MoveAsync(100, 200, new() { Steps = 10 }); // 平滑移动
        
        // 点击
        await mouse.ClickAsync(100, 200);
        await mouse.ClickAsync(100, 200, new()
        {
            Button = MouseButton.Right,                 // 右键
            ClickCount = 2,                             // 双击
            Delay = 100                                 // 点击间隔
        });
        
        // 按下和释放
        await mouse.DownAsync();
        await mouse.MoveAsync(200, 300);
        await mouse.UpAsync();
        
        // 双击
        await mouse.DblClickAsync(100, 200);
        
        // 滚轮
        await mouse.WheelAsync(0, 100);                // 向下滚动
        await mouse.WheelAsync(0, -100);               // 向上滚动
        
        // ========== 复杂交互 ==========
        // 拖拽操作
        async Task DragAndDrop(string source, string target)
        {
            var sourceElement = await _page.QuerySelectorAsync(source);
            var targetElement = await _page.QuerySelectorAsync(target);
            
            var sourceBox = await sourceElement.BoundingBoxAsync();
            var targetBox = await targetElement.BoundingBoxAsync();
            
            // 移动到源元素中心
            await mouse.MoveAsync(
                sourceBox.X + sourceBox.Width / 2,
                sourceBox.Y + sourceBox.Height / 2
            );
            
            // 按下鼠标
            await mouse.DownAsync();
            
            // 移动到目标元素中心
            await mouse.MoveAsync(
                targetBox.X + targetBox.Width / 2,
                targetBox.Y + targetBox.Height / 2,
                new() { Steps = 10 }
            );
            
            // 释放鼠标
            await mouse.UpAsync();
        }
        
        // 绘制签名
        async Task DrawSignature()
        {
            var canvas = await _page.QuerySelectorAsync("#signature-canvas");
            var box = await canvas.BoundingBoxAsync();
            
            var points = new[]
            {
                new { x = 10, y = 50 },
                new { x = 30, y = 20 },
                new { x = 50, y = 40 },
                new { x = 70, y = 30 },
                new { x = 90, y = 50 }
            };
            
            await mouse.MoveAsync(box.X + points[0].x, box.Y + points[0].y);
            await mouse.DownAsync();
            
            foreach (var point in points.Skip(1))
            {
                await mouse.MoveAsync(
                    box.X + point.x,
                    box.Y + point.y,
                    new() { Steps = 5 }
                );
            }
            
            await mouse.UpAsync();
        }
        
        // 选择文本
        async Task SelectText(string selector)
        {
            var element = await _page.QuerySelectorAsync(selector);
            await element.ClickAsync(new() { ClickCount = 3 }); // 三击选择整行
            
            // 或者使用键盘
            await element.ClickAsync();
            await keyboard.PressAsync("Control+A");
        }
        
        // 上下文菜单
        async Task OpenContextMenu(string selector)
        {
            var element = await _page.QuerySelectorAsync(selector);
            var box = await element.BoundingBoxAsync();
            
            await mouse.ClickAsync(
                box.X + box.Width / 2,
                box.Y + box.Height / 2,
                new() { Button = MouseButton.Right }
            );
        }
    }
}
```

### 4.2 表单高级操作

```c#
public class AdvancedFormHandling
{
    private IPage _page;
    
    public async Task CompleteFormOperations()
    {
        // ========== 动态表单处理 ==========
        // 等待表单加载
        await _page.WaitForSelectorAsync("form#dynamic-form");
        
        // 处理动态字段
        await _page.EvaluateAsync(@"() => {
            // 触发显示隐藏字段
            document.querySelector('#show-advanced').click();
        }");
        
        await _page.WaitForSelectorAsync("#advanced-field");
        await _page.FillAsync("#advanced-field", "Advanced Value");
        
        // ========== 自动完成处理 ==========
        var autocomplete = _page.Locator("#autocomplete-input");
        
        // 输入触发自动完成
        await autocomplete.FillAsync("");
        await autocomplete.PressSequentiallyAsync("New Y", new() { Delay = 100 });
        
        // 等待建议出现
        await _page.WaitForSelectorAsync(".autocomplete-suggestions");
        
        // 选择建议
        await _page.Keyboard.PressAsync("ArrowDown");
        await _page.Keyboard.PressAsync("ArrowDown");
        await _page.Keyboard.PressAsync("Enter");
        
        // ========== 富文本编辑器 ==========
        // TinyMCE / CKEditor
        await _page.FrameLocator("iframe.editor-frame").Locator("body").FillAsync(@"
            <h1>Title</h1>
            <p>This is <strong>bold</strong> text.</p>
            <ul>
                <li>Item 1</li>
                <li>Item 2</li>
            </ul>
        ");
        
        // ContentEditable
        await _page.Locator("[contenteditable=true]").FillAsync("Rich text content");
        
        // 使用工具栏
        await _page.ClickAsync(".editor-toolbar button[title='Bold']");
        await _page.Keyboard.TypeAsync("Bold text");
        
        // ========== 日期时间选择器 ==========
        // HTML5 日期输入
        await _page.Locator("input[type='date']").FillAsync("2024-12-25");
        await _page.Locator("input[type='time']").FillAsync("14:30");
        await _page.Locator("input[type='datetime-local']").FillAsync("2024-12-25T14:30");
        
        // 自定义日期选择器
        await _page.ClickAsync("#datepicker");
        await _page.WaitForSelectorAsync(".datepicker-popup");
        
        // 选择年月
        await _page.SelectOptionAsync(".year-select", "2024");
        await _page.SelectOptionAsync(".month-select", "12");
        
        // 选择日期
        await _page.ClickAsync(".datepicker-day:has-text('25')");
        
        // ========== 多步骤表单 ==========
        async Task FillMultiStepForm()
        {
            // 步骤 1: 个人信息
            await _page.FillAsync("#firstName", "John");
            await _page.FillAsync("#lastName", "Doe");
            await _page.ClickAsync("#next-step-1");
            
            // 等待步骤2
            await _page.WaitForSelectorAsync("#step-2:visible");
            
            // 步骤 2: 联系信息
            await _page.FillAsync("#email", "john@example.com");
            await _page.FillAsync("#phone", "+1234567890");
            await _page.ClickAsync("#next-step-2");
            
            // 步骤 3: 确认
            await _page.WaitForSelectorAsync("#step-3:visible");
            
            // 验证摘要信息
            var summary = await _page.TextContentAsync("#summary");
            Assert.That(summary, Does.Contain("John Doe"));
            
            await _page.ClickAsync("#submit-form");
        }
        
        // ========== 表单验证处理 ==========
        async Task HandleFormValidation()
        {
            // 触发HTML5验证
            await _page.ClickAsync("#submit");
            
            // 检查验证消息
            var emailInput = _page.Locator("#email");
            var validationMessage = await emailInput.EvaluateAsync<string>(
                "el => el.validationMessage"
            );
            
            if (!string.IsNullOrEmpty(validationMessage))
            {
                Console.WriteLine($"Validation error: {validationMessage}");
                
                // 修正输入
                await emailInput.FillAsync("valid@email.com");
            }
            
            // 自定义验证
            var customError = await _page.Locator(".error-message").IsVisibleAsync();
            if (customError)
            {
                var errorText = await _page.TextContentAsync(".error-message");
                Console.WriteLine($"Custom error: {errorText}");
            }
        }
        
        // ========== 文件上传高级处理 ==========
        async Task AdvancedFileUpload()
        {
            // 拖拽上传
            await _page.DispatchEventAsync("#drop-zone", "drop", new
            {
                dataTransfer = new
                {
                    files = new[] { "path/to/file.pdf" }
                }
            });
            
            // 多文件上传与进度
            var fileInput = _page.Locator("input[type='file']");
            
            // 监听上传进度
            await _page.ExposeFunctionAsync("onUploadProgress", (int percent) =>
            {
                Console.WriteLine($"Upload progress: {percent}%");
            });
            
            await fileInput.SetInputFilesAsync(new[]
            {
                "file1.pdf",
                "file2.jpg",
                "file3.png"
            });
            
            // 等待上传完成
            await _page.WaitForSelectorAsync(".upload-complete");
            
            // 验证上传的文件
            var uploadedFiles = await _page.Locator(".uploaded-file").AllTextContentsAsync();
            Assert.That(uploadedFiles, Has.Count.EqualTo(3));
        }
    }
}
```

## 第五部分：网络层操作

### 5.1 请求拦截和修改

```c#
public class NetworkInterception
{
    private IPage _page;
    
    public async Task CompleteNetworkHandling()
    {
        // ========== 请求拦截 ==========
        var blockedRequests = new List<string>();
        
        await _page.RouteAsync("**/*", async route =>
        {
            var request = route.Request;
            
            // 记录请求
            Console.WriteLine($"{request.Method} {request.Url}");
            
            // 按资源类型处理
            switch (request.ResourceType)
            {
                case "image":
                    // 替换图片
                    await route.FulfillAsync(new()
                    {
                        Path = "./placeholder.png",
                        ContentType = "image/png"
                    });
                    break;
                    
                case "stylesheet":
                    // 注入自定义CSS
                    var response = await route.FetchAsync();
                    var css = await response.TextAsync();
                    css += "\n/* Injected CSS */\nbody { background: lightblue !important; }";
                    await route.FulfillAsync(new()
                    {
                        Body = css,
                        ContentType = "text/css"
                    });
                    break;
                    
                case "script":
                    if (request.Url.Contains("analytics") || request.Url.Contains("tracking"))
                    {
                        // 阻止跟踪脚本
                        blockedRequests.Add(request.Url);
                        await route.AbortAsync();
                    }
                    else
                    {
                        await route.ContinueAsync();
                    }
                    break;
                    
                case "document":
                case "xhr":
                case "fetch":
                    // 修改请求头
                    var headers = new Dictionary<string, string>(request.Headers)
                    {
                        ["Authorization"] = "Bearer custom-token",
                        ["X-Custom-Header"] = "custom-value",
                        ["User-Agent"] = "Custom User Agent"
                    };
                    
                    await route.ContinueAsync(new()
                    {
                        Headers = headers
                    });
                    break;
                    
                default:
                    await route.ContinueAsync();
                    break;
            }
        });
        
        // ========== API Mocking ==========
        await _page.RouteAsync("**/api/users", async route =>
        {
            if (route.Request.Method == "GET")
            {
                await route.FulfillAsync(new()
                {
                    Status = 200,
                    ContentType = "application/json",
                    Body = JsonSerializer.Serialize(new[]
                    {
                        new { id = 1, name = "John Doe", email = "john@example.com" },
                        new { id = 2, name = "Jane Smith", email = "jane@example.com" }
                    })
                });
            }
            else if (route.Request.Method == "POST")
            {
                var postData = route.Request.PostData;
                var user = JsonSerializer.Deserialize<dynamic>(postData);
                
                await route.FulfillAsync(new()
                {
                    Status = 201,
                    ContentType = "application/json",
                    Body = JsonSerializer.Serialize(new
                    {
                        id = 3,
                        name = user.name,
                        email = user.email,
                        createdAt = DateTime.UtcNow
                    })
                });
            }
        });
        
        // ========== 延迟和限速 ==========
        await _page.RouteAsync("**/slow-endpoint", async route =>
        {
            // 添加延迟
            await Task.Delay(3000);
            await route.ContinueAsync();
        });
        
        // 模拟慢速网络
        await _page.RouteAsync("**/*", async route =>
        {
            var response = await route.FetchAsync();
            
            // 模拟下载速度限制
            if (response.Headers.ContainsKey("content-length"))
            {
                var size = int.Parse(response.Headers["content-length"]);
                var delay = size / 1024 * 10; // 10ms per KB
                await Task.Delay(Math.Min(delay, 5000)); // 最大5秒
            }
            
            await route.FulfillAsync(new() { Response = response });
        });
        
        // ========== 错误注入 ==========
        var errorRate = 0.1; // 10% 错误率
        var random = new Random();
        
        await _page.RouteAsync("**/api/**", async route =>
        {
            if (random.NextDouble() < errorRate)
            {
                // 随机错误
                var errors = new[]
                {
                    (500, "Internal Server Error"),
                    (503, "Service Unavailable"),
                    (429, "Too Many Requests"),
                    (408, "Request Timeout")
                };
                
                var error = errors[random.Next(errors.Length)];
                
                await route.FulfillAsync(new()
                {
                    Status = error.Item1,
                    ContentType = "application/json",
                    Body = JsonSerializer.Serialize(new
                    {
                        error = error.Item2,
                        timestamp = DateTime.UtcNow
                    })
                });
            }
            else
            {
                await route.ContinueAsync();
            }
        });
    }
    
    public async Task HARRecording()
    {
        // 开始HAR录制
        await _page.RouteFromHARAsync("./network.har", new()
        {
            Url = "**/api/**",
            Update = false
        });
        
        // 或录制新的HAR
        await _page.Context.RouteAsync("**/*", route => route.ContinueAsync());
        
        // 执行操作
        await _page.GotoAsync("https://example.com");
        
        // 保存HAR文件
        await _page.Context.CloseAsync(); // 会自动保存HAR
        
        // 分析HAR文件
        var harContent = await File.ReadAllTextAsync("./network.har");
        var har = JsonSerializer.Deserialize<dynamic>(harContent);
        
        // 提取性能指标
        foreach (var entry in har.log.entries)
        {
            Console.WriteLine($"URL: {entry.request.url}");
            Console.WriteLine($"Time: {entry.time}ms");
            Console.WriteLine($"Size: {entry.response.bodySize} bytes");
        }
    }
}
```

### 5.2 WebSocket处理

```c#
public class WebSocketHandling
{
    private IPage _page;
    
    public async Task WebSocketOperations()
    {
        var webSocketMessages = new List<string>();
        IWebSocket webSocket = null;
        
        // 监听WebSocket创建
        _page.WebSocket += (_, ws) =>
        {
            webSocket = ws;
            Console.WriteLine($"WebSocket opened: {ws.Url}");
            
            // 监听消息
            ws.FrameReceived += (_, frame) =>
            {
                if (frame.OpCode == 1) // 文本帧
                {
                    var message = Encoding.UTF8.GetString(frame.Payload);
                    webSocketMessages.Add(message);
                    Console.WriteLine($"Received: {message}");
                }
            };
            
            ws.FrameSent += (_, frame) =>
            {
                if (frame.OpCode == 1)
                {
                    var message = Encoding.UTF8.GetString(frame.Payload);
                    Console.WriteLine($"Sent: {message}");
                }
            };
            
            ws.Close += (_, _) =>
            {
                Console.WriteLine("WebSocket closed");
            };
            
            ws.Error += (_, error) =>
            {
                Console.WriteLine($"WebSocket error: {error}");
            };
        };
        
        // 导航到使用WebSocket的页面
        await _page.GotoAsync("https://example.com/websocket");
        
        // 等待WebSocket连接
        await _page.WaitForWebSocketAsync();
        
        // 通过页面发送WebSocket消息
        await _page.EvaluateAsync(@"() => {
            window.ws.send(JSON.stringify({ type: 'message', data: 'Hello' }));
        }");
        
        // 等待特定消息
        await _page.WaitForFunctionAsync(@"() => {
            return window.lastMessage && window.lastMessage.includes('response');
        }");
        
        // 验证消息
        Assert.That(webSocketMessages, Has.Count.GreaterThan(0));
    }
}
```


## 第六部分：多页面管理

### 6.1 多窗口和标签页管理

```c#
public class MultiWindowManagement
{
    private IBrowser _browser;
    private IBrowserContext _context;
    
    public async Task ComprehensiveWindowHandling()
    {
        // ========== 基础窗口管理 ==========
        _context = await _browser.NewContextAsync();
        
        // 监听新页面创建
        var newPages = new List<IPage>();
        _context.Page += (_, page) =>
        {
            newPages.Add(page);
            Console.WriteLine($"New page opened: {page.Url}");
            
            // 为每个新页面设置事件处理
            page.Load += (_, _) => Console.WriteLine($"Page loaded: {page.Url}");
            page.Close += (_, _) => Console.WriteLine($"Page closed: {page.Url}");
        };
        
        // 创建多个页面
        var page1 = await _context.NewPageAsync();
        var page2 = await _context.NewPageAsync();
        var page3 = await _context.NewPageAsync();
        
        // 在不同页面中导航
        await page1.GotoAsync("https://example.com/page1");
        await page2.GotoAsync("https://example.com/page2");
        await page3.GotoAsync("https://example.com/page3");
        
        // ========== 弹出窗口处理 ==========
        var mainPage = await _context.NewPageAsync();
        await mainPage.GotoAsync("https://example.com");
        
        // 方法1: 使用 WaitForPageAsync
        var popupPromise = _context.WaitForPageAsync();
        await mainPage.ClickAsync("a[target='_blank']");
        var popup = await popupPromise;
        
        // 方法2: 使用 RunAndWaitForPageAsync
        var newPage = await _context.RunAndWaitForPageAsync(async () =>
        {
            await mainPage.ClickAsync("#open-popup");
        });
        
        // 在弹出窗口中操作
        await popup.WaitForLoadStateAsync(LoadState.DOMContentLoaded);
        await popup.FillAsync("#popup-input", "test data");
        await popup.ClickAsync("#popup-submit");
        
        // ========== 窗口切换和管理 ==========
        // 获取所有打开的页面
        var allPages = _context.Pages;
        Console.WriteLine($"Total pages: {allPages.Count}");
        
        // 遍历所有页面
        foreach (var page in allPages)
        {
            var title = await page.TitleAsync();
            var url = page.Url;
            Console.WriteLine($"Page: {title} - {url}");
        }
        
        // 根据条件查找页面
        var targetPage = allPages.FirstOrDefault(p => p.Url.Contains("target"));
        if (targetPage != null)
        {
            await targetPage.BringToFrontAsync();
            await targetPage.ClickAsync("#action");
        }
        
        // ========== 窗口间通信 ==========
        // 在页面间共享数据
        await page1.EvaluateAsync(@"() => {
            window.sharedData = { message: 'Hello from Page 1' };
        }");
        
        // 使用 localStorage 共享数据
        await page1.EvaluateAsync(@"() => {
            localStorage.setItem('sharedKey', JSON.stringify({ data: 'shared value' }));
        }");
        
        // 在另一个页面读取
        var sharedData = await page2.EvaluateAsync<string>(@"() => {
            return localStorage.getItem('sharedKey');
        }");
        
        // ========== 窗口大小和位置 ==========
        // 设置视口大小
        await page1.SetViewportSizeAsync(1920, 1080);
        
        // 最大化窗口（仅在非无头模式下）
        await page1.EvaluateAsync(@"() => {
            window.moveTo(0, 0);
            window.resizeTo(screen.availWidth, screen.availHeight);
        }");
        
        // ========== 关闭窗口策略 ==========
        // 关闭除主窗口外的所有窗口
        var mainWindow = allPages.First();
        foreach (var page in allPages.Skip(1))
        {
            await page.CloseAsync();
        }
        
        // 关闭满足条件的窗口
        var pagesToClose = allPages.Where(p => p.Url.Contains("popup"));
        foreach (var page in pagesToClose)
        {
            await page.CloseAsync(new PageCloseOptions { RunBeforeUnload = true });
        }
    }
    
    public async Task WindowEventHandling()
    {
        var page = await _context.NewPageAsync();
        
        // ========== 对话框处理 ==========
        page.Dialog += async (_, dialog) =>
        {
            Console.WriteLine($"Dialog type: {dialog.Type}");
            Console.WriteLine($"Dialog message: {dialog.Message}");
            
            switch (dialog.Type)
            {
                case DialogType.Alert:
                    await dialog.AcceptAsync();
                    break;
                    
                case DialogType.Confirm:
                    // 根据消息内容决定
                    if (dialog.Message.Contains("delete"))
                    {
                        await dialog.DismissAsync();
                    }
                    else
                    {
                        await dialog.AcceptAsync();
                    }
                    break;
                    
                case DialogType.Prompt:
                    await dialog.AcceptAsync("Default input value");
                    break;
                    
                case DialogType.Beforeunload:
                    await dialog.AcceptAsync();
                    break;
            }
        };
        
        // ========== 下载处理 ==========
        page.Download += async (_, download) =>
        {
            Console.WriteLine($"Download started: {download.SuggestedFilename}");
            
            // 保存到指定路径
            var savePath = Path.Combine("downloads", download.SuggestedFilename);
            await download.SaveAsAsync(savePath);
            
            // 获取下载信息
            Console.WriteLine($"Download URL: {download.Url}");
            Console.WriteLine($"Download saved to: {savePath}");
        };
        
        // 等待下载
        var downloadTask = page.WaitForDownloadAsync();
        await page.ClickAsync("#download-button");
        var download = await downloadTask;
        
        // ========== 文件选择器处理 ==========
        page.FileChooser += async (_, fileChooser) =>
        {
            Console.WriteLine($"File chooser opened for: {fileChooser.Element}");
            Console.WriteLine($"Multiple files: {fileChooser.IsMultiple}");
            
            // 选择文件
            await fileChooser.SetFilesAsync(new[] 
            { 
                "file1.txt", 
                "file2.pdf" 
            });
        };
    }
}
```

### 6.2 Frame 处理

```c#
public class FrameHandling
{
    private IPage _page;
    
    public async Task ComprehensiveFrameHandling()
    {
        // ========== 基础 Frame 操作 ==========
        await _page.GotoAsync("https://example.com/with-frames");
        
        // 获取所有 frames
        var frames = _page.Frames;
        Console.WriteLine($"Total frames: {frames.Count}");
        
        // 主 frame
        var mainFrame = _page.MainFrame;
        Console.WriteLine($"Main frame URL: {mainFrame.Url}");
        
        // 通过名称获取 frame
        var namedFrame = _page.Frame("frameName");
        
        // 通过 URL 获取 frame
        var urlFrame = _page.Frame(url: "https://example.com/frame.html");
        
        // 通过 URL 模式获取 frame
        var patternFrame = _page.Frames.FirstOrDefault(f => f.Url.Contains("iframe"));
        
        // ========== FrameLocator API (推荐) ==========
        // 使用 FrameLocator 定位 frame 内元素
        var frameLocator = _page.FrameLocator("#my-iframe");
        
        // 在 frame 内操作
        await frameLocator.Locator("#button").ClickAsync();
        await frameLocator.Locator("#input").FillAsync("text");
        
        // 获取 frame 内文本
        var text = await frameLocator.Locator(".content").TextContentAsync();
        
        // ========== 嵌套 Frames ==========
        // 处理嵌套的 frames
        var outerFrame = _page.FrameLocator("#outer-frame");
        var innerFrame = outerFrame.FrameLocator("#inner-frame");
        
        await innerFrame.Locator("#nested-button").ClickAsync();
        
        // 多层嵌套
        await _page
            .FrameLocator("#level1")
            .FrameLocator("#level2")
            .FrameLocator("#level3")
            .Locator("#deep-element")
            .ClickAsync();
        
        // ========== Frame 导航和等待 ==========
        // 等待 frame 导航
        var frame = _page.Frame("frameName");
        await frame.WaitForURLAsync("**/frame-loaded");
        
        // 在 frame 中导航
        await frame.GotoAsync("https://example.com/new-frame-content");
        
        // 等待 frame 中的元素
        await frame.WaitForSelectorAsync("#frame-element");
        
        // ========== Frame 内容操作 ==========
        // 获取 frame HTML
        var frameHtml = await frame.ContentAsync();
        
        // 在 frame 中执行 JavaScript
        var frameResult = await frame.EvaluateAsync<string>(@"() => {
            return document.title;
        }");
        
        // 在 frame 中截图
        await frame.ScreenshotAsync(new FrameScreenshotOptions
        {
            Path = "frame-screenshot.png",
            FullPage = true
        });
        
        // ========== 动态 Frame 处理 ==========
        // 监听 frame 附加
        _page.FrameAttached += (_, frame) =>
        {
            Console.WriteLine($"Frame attached: {frame.Name} - {frame.Url}");
        };
        
        // 监听 frame 导航
        _page.FrameNavigated += (_, frame) =>
        {
            Console.WriteLine($"Frame navigated: {frame.Url}");
        };
        
        // 监听 frame 分离
        _page.FrameDetached += (_, frame) =>
        {
            Console.WriteLine($"Frame detached: {frame.Name}");
        };
        
        // 等待动态创建的 frame
        await _page.ClickAsync("#create-frame");
        await _page.WaitForFunctionAsync(@"() => {
            return document.querySelectorAll('iframe').length > 0;
        }");
        
        // ========== 跨 Frame 通信 ==========
        // 从主页面向 frame 发送消息
        await _page.EvaluateAsync(@"() => {
            const iframe = document.querySelector('#my-iframe');
            iframe.contentWindow.postMessage({ type: 'greeting', data: 'Hello Frame' }, '*');
        }");
        
        // 在 frame 中接收消息
        await frame.EvaluateAsync(@"() => {
            window.addEventListener('message', (event) => {
                console.log('Received message:', event.data);
                // 回复消息
                event.source.postMessage({ type: 'reply', data: 'Hello Parent' }, event.origin);
            });
        }");
    }
    
    public async Task AdvancedFrameScenarios()
    {
        // ========== 同源和跨域 Frame ==========
        // 处理跨域 frame（功能受限）
        var crossOriginFrame = _page.Frames.FirstOrDefault(f => 
            !f.Url.StartsWith(_page.Url.Substring(0, _page.Url.IndexOf('/', 8))));
        
        if (crossOriginFrame != null)
        {
            // 跨域 frame 只能进行有限操作
            try
            {
                // 这可能会失败
                await crossOriginFrame.EvaluateAsync("() => document.title");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Cross-origin access denied: {ex.Message}");
            }
        }
        
        // ========== Frame 中的表单提交 ==========
        var formFrame = _page.FrameLocator("#form-frame");
        
        // 填写表单
        await formFrame.Locator("#username").FillAsync("user");
        await formFrame.Locator("#password").FillAsync("pass");
        
        // 提交并等待导航
        await Promise.All(
            formFrame.Locator("form").EvaluateAsync("form => form.submit()"),
            _page.WaitForLoadStateAsync(LoadState.NetworkIdle)
        );
        
        // ========== Frame 错误处理 ==========
        async Task SafeFrameOperation(string frameSelector, Func<IFrameLocator, Task> operation)
        {
            try
            {
                var frameLocator = _page.FrameLocator(frameSelector);
                
                // 检查 frame 是否存在
                var exists = await _page.Locator(frameSelector).CountAsync() > 0;
                if (!exists)
                {
                    Console.WriteLine($"Frame {frameSelector} not found");
                    return;
                }
                
                await operation(frameLocator);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Frame operation failed: {ex.Message}");
            }
        }
        
        await SafeFrameOperation("#optional-frame", async frame =>
        {
            await frame.Locator("#element").ClickAsync();
        });
    }
}
```

### 6.3 Shadow DOM 处理

```c#
public class ShadowDOMHandling
{
    private IPage _page;
    
    public async Task ComprehensiveShadowDOMHandling()
    {
        // ========== 基础 Shadow DOM 操作 ==========
        await _page.GotoAsync("https://example.com/shadow-dom");
        
        // Playwright 自动穿透 Shadow DOM
        // 直接定位 shadow DOM 内的元素
        await _page.ClickAsync("#shadow-host >> #shadow-element");
        
        // 使用 CSS 选择器穿透
        await _page.ClickAsync("custom-element >> .internal-class");
        
        // ========== 复杂 Shadow DOM 结构 ==========
        // 嵌套 Shadow DOM
        await _page.ClickAsync(@"
            custom-app >> 
            custom-header >> 
            custom-button >> 
            button
        ");
        
        // 混合普通 DOM 和 Shadow DOM
        await _page.ClickAsync(@"
            #regular-container >> 
            custom-component >> 
            .shadow-content >> 
            #regular-child
        ");
        
        // ========== 使用 JavaScript 操作 Shadow DOM ==========
        await _page.EvaluateAsync(@"() => {
            // 获取 shadow host
            const host = document.querySelector('#shadow-host');
            
            // 访问 shadow root
            const shadowRoot = host.shadowRoot;
            
            // 在 shadow DOM 中查找元素
            const shadowElement = shadowRoot.querySelector('#shadow-button');
            shadowElement.click();
            
            // 修改 shadow DOM 内容
            shadowRoot.innerHTML = '<div>New shadow content</div>';
        }");
        
        // ========== 自定义元素和 Shadow DOM ==========
        // 创建自定义元素
        await _page.EvaluateAsync(@"() => {
            class CustomButton extends HTMLElement {
                constructor() {
                    super();
                    const shadow = this.attachShadow({ mode: 'open' });
                    
                    const button = document.createElement('button');
                    button.textContent = this.getAttribute('label') || 'Click me';
                    
                    const style = document.createElement('style');
                    style.textContent = `
                        button {
                            padding: 10px 20px;
                            background: blue;
                            color: white;
                            border: none;
                            border-radius: 5px;
                            cursor: pointer;
                        }
                        button:hover {
                            background: darkblue;
                        }
                    `;
                    
                    shadow.appendChild(style);
                    shadow.appendChild(button);
                }
            }
            
            customElements.define('custom-button', CustomButton);
            
            // 添加到页面
            const customBtn = document.createElement('custom-button');
            customBtn.setAttribute('label', 'Custom Action');
            document.body.appendChild(customBtn);
        }");
        
        // 与自定义元素交互
        await _page.ClickAsync("custom-button >> button");
        
        // ========== Shadow DOM 中的表单 ==========
        // 填写 shadow DOM 中的表单
        await _page.FillAsync("custom-form >> input[name='username']", "user");
        await _page.FillAsync("custom-form >> input[name='password']", "pass");
        await _page.ClickAsync("custom-form >> button[type='submit']");
        
        // ========== Shadow DOM 事件处理 ==========
        await _page.EvaluateAsync(@"() => {
            const host = document.querySelector('#shadow-host');
            const shadowRoot = host.shadowRoot;
            
            // 添加事件监听器到 shadow DOM 元素
            const button = shadowRoot.querySelector('#shadow-button');
            button.addEventListener('click', (e) => {
                console.log('Shadow button clicked');
                
                // 触发自定义事件
                host.dispatchEvent(new CustomEvent('shadow-click', {
                    detail: { timestamp: Date.now() },
                    bubbles: true,
                    composed: true  // 允许事件穿透 shadow boundary
                }));
            });
        }");
        
        // 监听来自 shadow DOM 的事件
        await _page.ExposeFunctionAsync("onShadowClick", (object detail) =>
        {
            Console.WriteLine($"Shadow click event received: {detail}");
        });
        
        await _page.EvaluateAsync(@"() => {
            document.addEventListener('shadow-click', (e) => {
                window.onShadowClick(e.detail);
            });
        }");
        
        // ========== 获取 Shadow DOM 内容 ==========
        var shadowContent = await _page.EvaluateAsync<string>(@"() => {
            const host = document.querySelector('#shadow-host');
            const shadowRoot = host.shadowRoot;
            return shadowRoot.innerHTML;
        }");
        
        // 获取 shadow DOM 中的文本
        var shadowText = await _page.EvaluateAsync<string>(@"() => {
            const host = document.querySelector('#shadow-host');
            const shadowRoot = host.shadowRoot;
            const element = shadowRoot.querySelector('.shadow-text');
            return element ? element.textContent : null;
        }");
        
        // ========== Shadow DOM 样式隔离 ==========
        await _page.EvaluateAsync(@"() => {
            const host = document.querySelector('#shadow-host');
            const shadowRoot = host.shadowRoot;
            
            // 添加样式到 shadow DOM
            const style = document.createElement('style');
            style.textContent = `
                :host {
                    display: block;
                    padding: 20px;
                    border: 1px solid #ccc;
                }
                :host(.active) {
                    border-color: blue;
                }
                ::slotted(*) {
                    color: red;
                }
            `;
            shadowRoot.appendChild(style);
        }");
        
        // ========== 测试 Shadow DOM 组件 ==========
        // 等待 shadow DOM 元素可见
        await _page.WaitForSelectorAsync("custom-component >> .loaded");
        
        // 验证 shadow DOM 内容
        var isVisible = await _page.IsVisibleAsync("custom-component >> .content");
        Assert.That(isVisible, Is.True);
        
        // 获取 shadow DOM 元素数量
        var count = await _page.Locator("custom-list >> li").CountAsync();
        Assert.That(count, Is.GreaterThan(0));
    }
    
    public async Task WebComponentsTesting()
    {
        // ========== 完整的 Web Components 测试示例 ==========
        // 定义和注册 Web Component
        await _page.EvaluateAsync(@"() => {
            class TodoList extends HTMLElement {
                constructor() {
                    super();
                    this.attachShadow({ mode: 'open' });
                    this.todos = [];
                    this.render();
                }
                
                render() {
                    this.shadowRoot.innerHTML = `
                        <style>
                            :host {
                                display: block;
                                font-family: Arial, sans-serif;
                            }
                            .todo-item {
                                padding: 10px;
                                border-bottom: 1px solid #eee;
                            }
                            .todo-item.completed {
                                text-decoration: line-through;
                                opacity: 0.6;
                            }
                            input {
                                padding: 5px;
                                margin-right: 10px;
                            }
                            button {
                                padding: 5px 10px;
                                cursor: pointer;
                            }
                        </style>
                        <div class='todo-container'>
                            <div class='input-section'>
                                <input type='text' id='todo-input' placeholder='Add a todo'>
                                <button id='add-btn'>Add</button>
                            </div>
                            <div class='todo-list'>
                                ${this.todos.map((todo, index) => `
                                    <div class='todo-item ${todo.completed ? 'completed' : ''}' data-index='${index}'>
                                        <input type='checkbox' ${todo.completed ? 'checked' : ''}>
                                        <span>${todo.text}</span>
                                        <button class='delete-btn'>Delete</button>
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                    `;
                    
                    this.attachEvents();
                }
                
                attachEvents() {
                    const addBtn = this.shadowRoot.querySelector('#add-btn');
                    const input = this.shadowRoot.querySelector('#todo-input');
                    
                    addBtn.addEventListener('click', () => {
                        if (input.value) {
                            this.addTodo(input.value);
                            input.value = '';
                        }
                    });
                    
                    this.shadowRoot.addEventListener('click', (e) => {
                        if (e.target.classList.contains('delete-btn')) {
                            const index = e.target.closest('.todo-item').dataset.index;
                            this.deleteTodo(index);
                        }
                    });
                    
                    this.shadowRoot.addEventListener('change', (e) => {
                        if (e.target.type === 'checkbox') {
                            const index = e.target.closest('.todo-item').dataset.index;
                            this.toggleTodo(index);
                        }
                    });
                }
                
                addTodo(text) {
                    this.todos.push({ text, completed: false });
                    this.render();
                    this.dispatchEvent(new CustomEvent('todo-added', { 
                        detail: { text },
                        bubbles: true 
                    }));
                }
                
                deleteTodo(index) {
                    this.todos.splice(index, 1);
                    this.render();
                }
                
                toggleTodo(index) {
                    this.todos[index].completed = !this.todos[index].completed;
                    this.render();
                }
            }
            
            customElements.define('todo-list', TodoList);
        }");
        
        // 添加组件到页面
        await _page.EvaluateAsync(@"() => {
            const todoList = document.createElement('todo-list');
            document.body.appendChild(todoList);
        }");
        
        // 测试组件功能
        // 添加待办事项
        await _page.FillAsync("todo-list >> #todo-input", "Test todo item");
        await _page.ClickAsync("todo-list >> #add-btn");
        
        // 验证添加
        var todoCount = await _page.Locator("todo-list >> .todo-item").CountAsync();
        Assert.That(todoCount, Is.EqualTo(1));
        
        // 切换完成状态
        await _page.ClickAsync("todo-list >> .todo-item input[type='checkbox']");
        
        // 验证完成状态
        var isCompleted = await _page.IsVisibleAsync("todo-list >> .todo-item.completed");
        Assert.That(isCompleted, Is.True);
        
        // 删除待办事项
        await _page.ClickAsync("todo-list >> .delete-btn");
        
        // 验证删除
        todoCount = await _page.Locator("todo-list >> .todo-item").CountAsync();
        Assert.That(todoCount, Is.EqualTo(0));
    }
}
```

## 第七部分：测试配置

### 7.1 浏览器配置和设备模拟

```c#
public class BrowserConfiguration
{
    public async Task ComprehensiveBrowserSetup()
    {
        var playwright = await Playwright.CreateAsync();
        
        // ========== 不同浏览器配置 ==========
        // Chromium 配置
        var chromium = await playwright.Chromium.LaunchAsync(new()
        {
            Channel = "chrome", // 使用 Chrome 而不是 Chromium
            Headless = false,
            Args = new[]
            {
                "--disable-blink-features=AutomationControlled",
                "--disable-dev-shm-usage",
                "--disable-web-security",
                "--disable-features=IsolateOrigins,site-per-process",
                "--start-maximized",
                "--window-size=1920,1080",
                "--user-data-dir=/tmp/chrome-user-data",
                "--profile-directory=Default",
                "--disable-extensions",
                "--disable-plugins",
                "--disable-images", // 禁用图片加载
                "--disable-javascript", // 禁用 JavaScript（慎用）
            },
            IgnoreDefaultArgs = new[] { "--enable-automation" },
            ChromiumSandbox = false
        });
        
        // Firefox 配置
        var firefox = await playwright.Firefox.LaunchAsync(new()
        {
            Headless = false,
            FirefoxUserPrefs = new Dictionary<string, object>
            {
                ["dom.webnotifications.enabled"] = false,
                ["dom.push.enabled"] = false,
                ["network.cookie.cookieBehavior"] = 0,
                ["network.cookie.lifetimePolicy"] = 0,
                ["privacy.trackingprotection.enabled"] = false,
                ["permissions.default.image"] = 2, // 禁用图片
                ["javascript.enabled"] = true
            },
            Args = new[] { "-width=1920", "-height=1080" }
        });
        
        // WebKit 配置
        var webkit = await playwright.Webkit.LaunchAsync(new()
        {
            Headless = false,
            Args = new[] { "--enable-developer-extras" }
        });
        
        // ========== 设备模拟 ==========
        // 预定义设备
        var iPhone = playwright.Devices["iPhone 13"];
        var pixel = playwright.Devices["Pixel 5"];
        var iPad = playwright.Devices["iPad Pro"];
        
        // 使用预定义设备
        var mobileContext = await chromium.NewContextAsync(iPhone);
        var mobilePage = await mobileContext.NewPageAsync();
        await mobilePage.GotoAsync("https://example.com");
        
        // 自定义移动设备配置
        var customMobileContext = await chromium.NewContextAsync(new()
        {
            ViewportSize = new ViewportSize { Width = 375, Height = 812 },
            DeviceScaleFactor = 3,
            IsMobile = true,
            HasTouch = true,
            UserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15",
            
            // 设置屏幕方向
            ScreenSize = new ScreenSize { Width = 375, Height = 812 },
            
            // 模拟网络速度
            Offline = false,
            
            // 权限
            Permissions = new[] { "geolocation", "camera", "microphone" },
            
            // 地理位置
            Geolocation = new Geolocation 
            { 
                Latitude = 37.7749f, 
                Longitude = -122.4194f,
                Accuracy = 100
            }
        });
        
        // ========== 多浏览器测试配置 ==========
        var browsers = new[]
        {
            ("chromium", await playwright.Chromium.LaunchAsync()),
            ("firefox", await playwright.Firefox.LaunchAsync()),
            ("webkit", await playwright.Webkit.LaunchAsync())
        };
        
        foreach (var (name, browser) in browsers)
        {
            var context = await browser.NewContextAsync();
            var page = await context.NewPageAsync();
            
            await page.GotoAsync("https://example.com");
            await page.ScreenshotAsync(new() { Path = $"screenshot-{name}.png" });
            
            await browser.CloseAsync();
        }
        
        // ========== 响应式测试 ==========
        var viewports = new[]
        {
            ("Mobile", 375, 667),
            ("Tablet", 768, 1024),
            ("Desktop", 1920, 1080),
            ("4K", 3840, 2160)
        };
        
        foreach (var (name, width, height) in viewports)
        {
            var context = await chromium.NewContextAsync(new()
            {
                ViewportSize = new ViewportSize { Width = width, Height = height }
            });
            
            var page = await context.NewPageAsync();
            await page.GotoAsync("https://example.com");
            await page.ScreenshotAsync(new() { Path = $"responsive-{name}.png" });
            
            await context.CloseAsync();
        }
        
        // ========== 网络条件模拟 ==========
        // 模拟慢速网络
        var page = await chromium.NewPageAsync();
        
        // 使用 Chrome DevTools Protocol
        var client = await page.Context.NewCDPSessionAsync(page);
        await client.SendAsync("Network.emulateNetworkConditions", new Dictionary<string, object>
        {
            ["offline"] = false,
            ["downloadThroughput"] = 1.5 * 1024 * 1024 / 8, // 1.5 Mbps
            ["uploadThroughput"] = 750 * 1024 / 8,          // 750 Kbps
            ["latency"] = 40                                 // 40ms
        });
    }
    
    public async Task LocaleAndTimezoneConfiguration()
    {
        var playwright = await Playwright.CreateAsync();
        var browser = await playwright.Chromium.LaunchAsync();
        
        // ========== 语言和地区设置 ==========
        var locales = new[]
        {
            ("en-US", "America/New_York"),
            ("zh-CN", "Asia/Shanghai"),
            ("ja-JP", "Asia/Tokyo"),
            ("de-DE", "Europe/Berlin")
        };
        
        foreach (var (locale, timezone) in locales)
        {
            var context = await browser.NewContextAsync(new()
            {
                Locale = locale,
                TimezoneId = timezone,
                
                // 设置 Accept-Language 头
                ExtraHTTPHeaders = new Dictionary<string, string>
                {
                    ["Accept-Language"] = locale
                }
            });
            
            var page = await context.NewPageAsync();
            
            // 验证语言设置
            var language = await page.EvaluateAsync<string>("() => navigator.language");
            Console.WriteLine($"Browser language: {language}");
            
            // 验证时区
            var date = await page.EvaluateAsync<string>("() => new Date().toString()");
            Console.WriteLine($"Local time: {date}");
            
            await context.CloseAsync();
        }
        
        // ========== 主题和配色方案 ==========
        var themes = new[] { ColorScheme.Light, ColorScheme.Dark, ColorScheme.NoPreference };
        
        foreach (var theme in themes)
        {
            var context = await browser.NewContextAsync(new()
            {
                ColorScheme = theme,
                ForcedColors = ForcedColors.Active,
                ReducedMotion = ReducedMotion.Reduce
            });
            
            var page = await context.NewPageAsync();
            await page.GotoAsync("https://example.com");
            
            // 验证主题
            var isDarkMode = await page.EvaluateAsync<bool>(@"() => {
                return window.matchMedia('(prefers-color-scheme: dark)').matches;
            }");
            
            Console.WriteLine($"Dark mode: {isDarkMode}");
            
            await context.CloseAsync();
        }
    }
}
```

### 7.2 认证和状态管理

```c#
public class AuthenticationAndStateManagement
{
    private IBrowser _browser;
    
    public async Task ComprehensiveAuthenticationHandling()
    {
        // ========== 保存登录状态 ==========
        var context = await _browser.NewContextAsync();
        var page = await context.NewPageAsync();
        
        // 执行登录
        await page.GotoAsync("https://example.com/login");
        await page.FillAsync("#username", "user@example.com");
        await page.FillAsync("#password", "password123");
        await page.ClickAsync("#login-button");
        
        // 等待登录完成
        await page.WaitForURLAsync("**/dashboard");
        
        // 保存认证状态（包括 cookies、localStorage、sessionStorage）
        await context.StorageStateAsync(new()
        {
            Path = "auth-state.json"
        });
        
        await context.CloseAsync();
        
        // ========== 重用登录状态 ==========
        // 创建新的上下文并加载保存的状态
        var authenticatedContext = await _browser.NewContextAsync(new()
        {
            StorageState = "auth-state.json"
        });
        
        var authenticatedPage = await authenticatedContext.NewPageAsync();
        await authenticatedPage.GotoAsync("https://example.com/dashboard");
        // 应该已经登录，直接进入 dashboard
        
        // ========== 程序化状态管理 ==========
        // 获取当前状态
        var currentState = await authenticatedContext.StorageStateAsync();
        
        // 状态包含的内容
        var cookies = currentState.Cookies;
        var origins = currentState.Origins;
        
        // 手动设置 cookies
        await context.AddCookiesAsync(new[]
        {
            new Cookie
            {
                Name = "auth_token",
                Value = "abc123xyz",
                Domain = ".example.com",
                Path = "/",
                Expires = DateTimeOffset.Now.AddDays(7).ToUnixTimeSeconds(),
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteAttribute.Lax
            },
            new Cookie
            {
                Name = "session_id",
                Value = "session_123",
                Domain = "example.com",
                Path = "/",
                HttpOnly = true,
                Secure = true
            }
        });
        
        // 清除特定 cookie
        await context.ClearCookiesAsync();
        
        // ========== HTTP 基础认证 ==========
        var httpAuthContext = await _browser.NewContextAsync(new()
        {
            HttpCredentials = new HttpCredentials
            {
                Username = "admin",
                Password = "admin123",
                Origin = "https://example.com" // 可选：限定认证范围
            }
        });
        
        // ========== OAuth/SSO 认证流程 ==========
        async Task HandleOAuthFlow()
        {
            var oauthContext = await _browser.NewContextAsync();
            var oauthPage = await oauthContext.NewPageAsync();
            
            // 开始 OAuth 流程
            await oauthPage.GotoAsync("https://example.com/auth/oauth/authorize");
            
            // 在 OAuth 提供商页面登录
            await oauthPage.FillAsync("#oauth-username", "oauth@example.com");
            await oauthPage.FillAsync("#oauth-password", "oauthpass");
            await oauthPage.ClickAsync("#oauth-login");
            
            // 授权应用
            await oauthPage.ClickAsync("#authorize-app");
            
            // 等待重定向回应用
            await oauthPage.WaitForURLAsync("**/callback");
            
            // 保存认证后的状态
            await oauthContext.StorageStateAsync(new() { Path = "oauth-state.json" });
        }
        
        // ========== 多用户会话管理 ==========
        var users = new[]
        {
            ("user1", "pass1", "user1-state.json"),
            ("user2", "pass2", "user2-state.json"),
            ("admin", "adminpass", "admin-state.json")
        };
        
        // 为每个用户创建会话
        foreach (var (username, password, stateFile) in users)
        {
            var userContext = await _browser.NewContextAsync();
            var userPage = await userContext.NewPageAsync();
            
            // 登录
            await userPage.GotoAsync("https://example.com/login");
            await userPage.FillAsync("#username", username);
            await userPage.FillAsync("#password", password);
            await userPage.ClickAsync("#login");
            
            // 保存状态
            await userContext.StorageStateAsync(new() { Path = stateFile });
            await userContext.CloseAsync();
        }
        
        // 使用不同用户状态进行测试
        async Task TestWithUser(string stateFile)
        {
            var userContext = await _browser.NewContextAsync(new()
            {
                StorageState = stateFile
            });
            
            var page = await userContext.NewPageAsync();
            await page.GotoAsync("https://example.com/profile");
            
            // 执行用户特定的测试
            var username = await page.TextContentAsync(".username");
            Console.WriteLine($"Logged in as: {username}");
            
            await userContext.CloseAsync();
        }
        
        await TestWithUser("user1-state.json");
        await TestWithUser("admin-state.json");
    }
    
    public async Task LocalStorageAndSessionStorage()
    {
        var context = await _browser.NewContextAsync();
        var page = await context.NewPageAsync();
        
        // ========== LocalStorage 管理 ==========
        await page.GotoAsync("https://example.com");
        
        // 设置 localStorage
        await page.EvaluateAsync(@"() => {
            localStorage.setItem('user_preferences', JSON.stringify({
                theme: 'dark',
                language: 'en',
                notifications: true
            }));
            localStorage.setItem('auth_token', 'token123');
            localStorage.setItem('user_id', '12345');
        }");
        
        // 获取 localStorage
        var preferences = await page.EvaluateAsync<string>(@"() => {
            return localStorage.getItem('user_preferences');
        }");
        
        // 获取所有 localStorage 键值
        var allLocalStorage = await page.EvaluateAsync<Dictionary<string, string>>(@"() => {
            const items = {};
            for (let i = 0; i < localStorage.length; i++) {
                const key = localStorage.key(i);
                items[key] = localStorage.getItem(key);
            }
            return items;
        }");
        
        // 清除特定项
        await page.EvaluateAsync(@"() => {
            localStorage.removeItem('auth_token');
        }");
        
        // 清除所有
        await page.EvaluateAsync("() => localStorage.clear()");
        
        // ========== SessionStorage 管理 ==========
        // 设置 sessionStorage
        await page.EvaluateAsync(@"() => {
            sessionStorage.setItem('session_data', JSON.stringify({
                cart: ['item1', 'item2'],
                tempAuth: 'temp123'
            }));
        }");
        
        // 保存包含 storage 的完整状态
        var state = await context.StorageStateAsync();
        
        // state.Origins 包含 localStorage 和 sessionStorage
        foreach (var origin in state.Origins)
        {
            Console.WriteLine($"Origin: {origin.Origin}");
            
            if (origin.LocalStorage != null)
            {
                foreach (var item in origin.LocalStorage)
                {
                    Console.WriteLine($"  LocalStorage: {item.Name} = {item.Value}");
                }
            }
            
            if (origin.SessionStorage != null)
            {
                foreach (var item in origin.SessionStorage)
                {
                    Console.WriteLine($"  SessionStorage: {item.Name} = {item.Value}");
                }
            }
        }
        
        // ========== 跨域存储管理 ==========
        // 为不同域设置存储
        await page.GotoAsync("https://app.example.com");
        await page.EvaluateAsync(@"() => {
            localStorage.setItem('app_data', 'app_value');
        }");
        
        await page.GotoAsync("https://api.example.com");
        await page.EvaluateAsync(@"() => {
            localStorage.setItem('api_data', 'api_value');
        }");
        
        // 保存多域状态
        await context.StorageStateAsync(new() { Path = "multi-domain-state.json" });
    }
    
    public async Task TokenBasedAuthentication()
    {
        // ========== JWT Token 管理 ==========
        var context = await _browser.NewContextAsync();
        
        // 设置 Authorization header
        await context.SetExtraHTTPHeadersAsync(new Dictionary<string, string>
        {
            ["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        });
        
        // 拦截请求添加 token
        await context.RouteAsync("**/*", async route =>
        {
            var headers = new Dictionary<string, string>(route.Request.Headers)
            {
                ["Authorization"] = await GetCurrentToken()
            };
            
            await route.ContinueAsync(new() { Headers = headers });
        });
        
        // Token 刷新逻辑
        async Task<string> GetCurrentToken()
        {
            // 检查 token 是否过期
            var token = await context.EvaluateAsync<string>(@"() => {
                return localStorage.getItem('access_token');
            }");
            
            if (IsTokenExpired(token))
            {
                // 刷新 token
                var refreshToken = await context.EvaluateAsync<string>(@"() => {
                    return localStorage.getItem('refresh_token');
                }");
                
                var newToken = await RefreshToken(refreshToken);
                
                // 更新存储的 token
                await context.EvaluateAsync(@"(token) => {
                    localStorage.setItem('access_token', token);
                }", newToken);
                
                return newToken;
            }
            
            return token;
        }
    }
    
    private bool IsTokenExpired(string token)
    {
        // 实现 token 过期检查逻辑
        return false;
    }
    
    private async Task<string> RefreshToken(string refreshToken)
    {
        // 实现 token 刷新逻辑
        return "new-token";
    }
}
```

## 第八部分：调试与优化

### 8.1 调试技巧

```c#
public class DebuggingTechniques
{
    private IPage _page;
    
    public async Task DebugingMethods()
    {
        // ========== 启用调试模式 ==========
        // 方法1: 环境变量
        Environment.SetEnvironmentVariable("PWDEBUG", "1");
        Environment.SetEnvironmentVariable("DEBUG", "pw:api");
        
        // 方法2: 启动参数
        var browser = await new BrowserTypeLaunchOptions
        {
            Headless = false,
            Devtools = true,  // 自动打开DevTools
            SlowMo = 500      // 每个操作延迟500ms
        };
        
        // ========== 暂停执行 ==========
        // 暂停并打开Playwright Inspector
        await _page.PauseAsync();
        
        // 条件暂停
        if (Debugger.IsAttached)
        {
            await _page.PauseAsync();
        }
        
        // ========== 日志记录 ==========
        // 控制台日志
        _page.Console += (_, msg) =>
        {
            var type = msg.Type;
            var text = msg.Text;
            var location = msg.Location;
            
            Console.WriteLine($"[{type}] {text}");
            if (location != null)
            {
                Console.WriteLine($"  at {location.Url}:{location.LineNumber}:{location.ColumnNumber}");
            }
            
            // 获取参数详情
            foreach (var arg in msg.Args)
            {
                var value = arg.JsonValueAsync().Result;
                Console.WriteLine($"  Arg: {value}");
            }
        };
        
        // 页面错误
        _page.PageError += (_, error) =>
        {
            Console.WriteLine($"Page error: {error.Message}");
            Console.WriteLine($"Stack: {error.Stack}");
        };
        
        // ========== 追踪 ==========
        await _page.Context.Tracing.StartAsync(new()
        {
            Screenshots = true,
            Snapshots = true,
            Sources = true
        });
        
        try
        {
            // 执行操作
            await _page.GotoAsync("https://example.com");
            await _page.ClickAsync("#button");
        }
        finally
        {
            await _page.Context.Tracing.StopAsync(new()
            {
                Path = "trace.zip"
            });
        }
        
        // ========== 截图调试 ==========
        async Task DebugStep(string stepName)
        {
            await _page.ScreenshotAsync(new()
            {
                Path = $"debug_{stepName}_{DateTime.Now:HHmmss}.png",
                FullPage = true
            });
            
            // 添加调试标记
            await _page.EvaluateAsync($@"() => {{
                const marker = document.createElement('div');
                marker.style.cssText = 'position:fixed;top:10px;right:10px;background:red;color:white;padding:10px;z-index:10000';
                marker.textContent = '{stepName}';
                document.body.appendChild(marker);
            }}");
        }
        
        // ========== 元素高亮 ==========
        async Task HighlightElement(string selector)
        {
            await _page.EvaluateAsync($@"() => {{
                const element = document.querySelector('{selector}');
                if (element) {{
                    element.style.outline = '3px solid red';
                    element.style.backgroundColor = 'yellow';
                    element.scrollIntoView({{ behavior: 'smooth', block: 'center' }});
                }}
            }}");
            
            await _page.WaitForTimeoutAsync(1000);
        }
        
        // ========== 性能分析 ==========
        async Task MeasurePerformance(string operation, Func<Task> action)
        {
            var sw = Stopwatch.StartNew();
            
            // 开始性能记录
            await _page.EvaluateAsync("() => performance.mark('start')");
            
            await action();
            
            // 结束性能记录
            await _page.EvaluateAsync("() => performance.mark('end')");
            await _page.EvaluateAsync("() => performance.measure('operation', 'start', 'end')");
            
            var measure = await _page.EvaluateAsync<double>(
                "() => performance.getEntriesByName('operation')[0].duration"
            );
            
            sw.Stop();
            Console.WriteLine($"{operation}: {sw.ElapsedMilliseconds}ms (Browser: {measure}ms)");
        }
    }
}
```

### 8.2 最佳实践

```c#
public class BestPractices
{
    // ========== Page Object Model ==========
    public class LoginPage
    {
        private readonly IPage _page;
        private readonly ILocator _emailInput;
        private readonly ILocator _passwordInput;
        private readonly ILocator _submitButton;
        private readonly ILocator _errorMessage;
        
        public LoginPage(IPage page)
        {
            _page = page;
            _emailInput = page.Locator("#email");
            _passwordInput = page.Locator("#password");
            _submitButton = page.Locator("button[type='submit']");
            _errorMessage = page.Locator(".error-message");
        }
        
        public async Task NavigateAsync()
        {
            await _page.GotoAsync("/login");
        }
        
        public async Task LoginAsync(string email, string password)
        {
            await _emailInput.FillAsync(email);
            await _passwordInput.FillAsync(password);
            await _submitButton.ClickAsync();
        }
        
        public async Task<bool> HasErrorAsync()
        {
            return await _errorMessage.IsVisibleAsync();
        }
        
        public async Task<string> GetErrorMessageAsync()
        {
            return await _errorMessage.TextContentAsync();
        }
    }
    
    // ========== 可重用组件 ==========
    public class SearchComponent
    {
        private readonly IPage _page;
        private readonly string _rootSelector;
        
        public SearchComponent(IPage page, string rootSelector = "[data-testid='search']")
        {
            _page = page;
            _rootSelector = rootSelector;
        }
        
        private ILocator Root => _page.Locator(_rootSelector);
        private ILocator Input => Root.Locator("input[type='search']");
        private ILocator Button => Root.Locator("button");
        private ILocator Results => Root.Locator(".results .item");
        
        public async Task SearchAsync(string query)
        {
            await Input.FillAsync(query);
            await Button.ClickAsync();
            await _page.WaitForLoadStateAsync(LoadState.NetworkIdle);
        }
        
        public async Task<int> GetResultCountAsync()
        {
            return await Results.CountAsync();
        }
        
        public async Task<List<string>> GetResultTitlesAsync()
        {
            return await Results.Locator(".title").AllTextContentsAsync();
        }
    }
    
    // ========== 配置管理 ==========
    public class TestConfiguration
    {
        public string BaseUrl { get; set; }
        public bool Headless { get; set; }
        public int Timeout { get; set; }
        public string Browser { get; set; }
        public Dictionary<string, string> Credentials { get; set; }
        
        public static TestConfiguration Load()
        {
            var environment = Environment.GetEnvironmentVariable("TEST_ENV") ?? "dev";
            var configFile = $"appsettings.{environment}.json";
            
            var json = File.ReadAllText(configFile);
            return JsonSerializer.Deserialize<TestConfiguration>(json);
        }
    }
    
    // ========== 重试机制 ==========
    public class RetryHelper
    {
        public static async Task<T> RetryAsync<T>(
            Func<Task<T>> operation,
            int maxAttempts = 3,
            int delayMs = 1000,
            Func<Exception, bool> retryWhen = null)
        {
            retryWhen ??= _ => true;
            
            for (int attempt = 1; attempt <= maxAttempts; attempt++)
            {
                try
                {
                    return await operation();
                }
                catch (Exception ex) when (attempt < maxAttempts && retryWhen(ex))
                {
                    Console.WriteLine($"Attempt {attempt} failed: {ex.Message}");
                    await Task.Delay(delayMs * attempt); // 指数退避
                }
            }
            
            throw new Exception($"Operation failed after {maxAttempts} attempts");
        }
    }
    
    // ========== 并行测试 ==========
    public class ParallelTestBase
    {
        private static readonly SemaphoreSlim BrowserSemaphore = new(3); // 最多3个并行浏览器
        
        protected async Task<IPage> CreatePageAsync()
        {
            await BrowserSemaphore.WaitAsync();
            
            try
            {
                var playwright = await Playwright.CreateAsync();
                var browser = await playwright.Chromium.LaunchAsync();
                var context = await browser.NewContextAsync();
                return await context.NewPageAsync();
            }
            finally
            {
                BrowserSemaphore.Release();
            }
        }
    }
}
```

## 第九部分：测试框架完整集成

### 9.1 NUnit 高级集成

```c#
[TestFixture]
public class NUnitAdvancedIntegration : PageTest
{
    private TestConfiguration _config;
    private IAPIRequestContext _apiContext;
    
    [OneTimeSetUp]
    public async Task GlobalSetup()
    {
        _config = TestConfiguration.Load();
        
        // 设置全局API上下文
        var playwright = await Playwright.CreateAsync();
        _apiContext = await playwright.APIRequest.NewContextAsync(new()
        {
            BaseURL = _config.ApiBaseUrl,
            ExtraHTTPHeaders = new Dictionary<string, string>
            {
                ["Authorization"] = $"Bearer {_config.ApiToken}"
            }
        });
    }
    
    [SetUp]
    public async Task Setup()
    {
        // 设置测试数据
        await SetupTestDataAsync();
        
        // 启动追踪
        await Context.Tracing.StartAsync(new()
        {
            Title = TestContext.CurrentContext.Test.Name,
            Screenshots = true,
            Snapshots = true
        });
    }
    
    [TearDown]
    public async Task Teardown()
    {
        var testName = TestContext.CurrentContext.Test.Name;
        var outcome = TestContext.CurrentContext.Result.Outcome.Status;
        
        // 保存追踪
        await Context.Tracing.StopAsync(new()
        {
            Path = $"traces/{testName}.zip"
        });
        
        // 失败时额外操作
        if (outcome == TestStatus.Failed)
        {
            await CaptureFailureDetailsAsync(testName);
        }
        
        // 清理测试数据
        await CleanupTestDataAsync();
    }
    
    private async Task SetupTestDataAsync()
    {
        // 通过API设置测试数据
        var response = await _apiContext.PostAsync("/test-data", new()
        {
            DataObject = new
            {
                type = "user",
                data = new { name = "Test User", email = "test@example.com" }
            }
        });
        
        Assert.That(response.Ok, Is.True);
    }
    
    private async Task CleanupTestDataAsync()
    {
        await _apiContext.DeleteAsync("/test-data/all");
    }
    
    private async Task CaptureFailureDetailsAsync(string testName)
    {
        // 截图
        await Page.ScreenshotAsync(new()
        {
            Path = $"failures/{testName}.png",
            FullPage = true
        });
        
        // 保存HTML
        var html = await Page.ContentAsync();
        await File.WriteAllTextAsync($"failures/{testName}.html", html);
        
        // 保存控制台日志
        var logs = await Page.EvaluateAsync<string[]>(
            "() => window.__consoleLogs || []"
        );
        await File.WriteAllLinesAsync($"failures/{testName}.log", logs);
    }
    
    [Test]
    [Category("Smoke")]
    [Property("Priority", "High")]
    [TestCase("chrome")]
    [TestCase("firefox")]
    [TestCase("webkit")]
    public async Task CrossBrowserTest(string browserName)
    {
        // 根据参数启动不同浏览器
        var playwright = await Playwright.CreateAsync();
        IBrowser browser = browserName switch
        {
            "firefox" => await playwright.Firefox.LaunchAsync(),
            "webkit" => await playwright.Webkit.LaunchAsync(),
            _ => await playwright.Chromium.LaunchAsync()
        };
        
        var context = await browser.NewContextAsync();
        var page = await context.NewPageAsync();
        
        await page.GotoAsync(_config.BaseUrl);
        // 测试逻辑...
        
        await browser.CloseAsync();
    }
    
    [Test]
    [Timeout(60000)]
    [Retry(3)]
    public async Task FlakyTestWithRetry()
    {
        await Page.GotoAsync($"{_config.BaseUrl}/flaky-page");
        
        // 使用自定义等待
        await Expect(Page.Locator(".dynamic-content"))
            .ToBeVisibleAsync(new() { Timeout = 10000 });
    }
}
```


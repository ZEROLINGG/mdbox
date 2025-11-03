

## 一、Process 类深入剖析

### 1.1 类层次结构和基本概念

```csharp
// Process 类继承关系
public class Process : Component, IDisposable
{
    // Process 代表系统中的一个进程
    // 可以是本地进程或远程计算机上的进程
}
```

### 1.2 Process 类的所有属性详解

#### 1.2.1 进程标识属性

```csharp
public class ProcessIdentificationDemo
{
    public void ShowIdentificationProperties()
    {
        Process process = Process.GetCurrentProcess();
        
        // 基本标识
        int id = process.Id;                          // 进程唯一标识符
        string name = process.ProcessName;            // 进程名称（不含扩展名）
        IntPtr handle = process.Handle;               // 进程句柄
        int sessionId = process.SessionId;            // 终端服务会话标识符
        string machineName = process.MachineName;     // 运行进程的计算机名
        
        // 模块和文件信息
        ProcessModule mainModule = process.MainModule;           // 主模块
        string fileName = mainModule?.FileName;                  // 可执行文件完整路径
        ProcessModuleCollection modules = process.Modules;       // 所有加载的模块
        
        Console.WriteLine($"进程ID: {id}");
        Console.WriteLine($"进程名: {name}");
        Console.WriteLine($"会话ID: {sessionId}");
        Console.WriteLine($"主模块: {fileName}");
        Console.WriteLine($"计算机名: {machineName}");
        
        // 遍历所有模块
        foreach (ProcessModule module in modules)
        {
            Console.WriteLine($"  模块: {module.ModuleName} - {module.FileName}");
        }
    }
}
```

#### 1.2.2 窗口和UI相关属性

```csharp
public class ProcessUIProperties
{
    public void ShowUIProperties()
    {
        Process[] processes = Process.GetProcessesByName("notepad");
        if (processes.Length > 0)
        {
            Process notepad = processes[0];
            
            // 窗口相关
            IntPtr mainWindowHandle = notepad.MainWindowHandle;     // 主窗口句柄
            string mainWindowTitle = notepad.MainWindowTitle;       // 主窗口标题
            bool responding = notepad.Responding;                    // 是否响应
            
            Console.WriteLine($"主窗口句柄: {mainWindowHandle}");
            Console.WriteLine($"窗口标题: {mainWindowTitle}");
            Console.WriteLine($"响应状态: {responding}");
            
            // 刷新进程信息（获取最新状态）
            notepad.Refresh();
            
            // 窗口操作
            if (mainWindowHandle != IntPtr.Zero)
            {
                // 关闭主窗口（发送关闭消息，进程可以选择忽略）
                bool closed = notepad.CloseMainWindow();
                Console.WriteLine($"关闭窗口请求: {closed}");
            }
        }
    }
}
```

#### 1.2.3 时间相关属性

```csharp
public class ProcessTimeProperties
{
    public void ShowTimeProperties()
    {
        Process process = Process.GetCurrentProcess();
        
        try
        {
            // 时间信息
            DateTime startTime = process.StartTime;                    // 启动时间
            TimeSpan totalProcessorTime = process.TotalProcessorTime; // 总CPU时间
            TimeSpan userProcessorTime = process.UserProcessorTime;   // 用户模式CPU时间
            TimeSpan privilegedProcessorTime = process.PrivilegedProcessorTime; // 内核模式CPU时间
            
            // 如果进程已退出
            if (process.HasExited)
            {
                DateTime exitTime = process.ExitTime;                  // 退出时间
                int exitCode = process.ExitCode;                       // 退出代码
                Console.WriteLine($"退出时间: {exitTime}");
                Console.WriteLine($"退出代码: {exitCode}");
            }
            
            Console.WriteLine($"启动时间: {startTime}");
            Console.WriteLine($"运行时长: {DateTime.Now - startTime}");
            Console.WriteLine($"总CPU时间: {totalProcessorTime}");
            Console.WriteLine($"用户CPU时间: {userProcessorTime}");
            Console.WriteLine($"内核CPU时间: {privilegedProcessorTime}");
            Console.WriteLine($"CPU使用率: {totalProcessorTime.TotalMilliseconds / (DateTime.Now - startTime).TotalMilliseconds:P}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"无法获取时间信息: {ex.Message}");
        }
    }
}
```

#### 1.2.4 内存和资源属性

```csharp
public class ProcessMemoryProperties
{
    public void ShowMemoryProperties()
    {
        Process process = Process.GetCurrentProcess();
        
        // 内存信息（64位版本，推荐使用）
        long workingSet64 = process.WorkingSet64;                   // 物理内存
        long virtualMemorySize64 = process.VirtualMemorySize64;     // 虚拟内存
        long privateMemorySize64 = process.PrivateMemorySize64;     // 私有内存
        long pagedMemorySize64 = process.PagedMemorySize64;         // 分页内存
        long nonpagedSystemMemorySize64 = process.NonpagedSystemMemorySize64; // 非分页系统内存
        long pagedSystemMemorySize64 = process.PagedSystemMemorySize64;       // 分页系统内存
        long peakWorkingSet64 = process.PeakWorkingSet64;           // 峰值物理内存
        long peakVirtualMemorySize64 = process.PeakVirtualMemorySize64; // 峰值虚拟内存
        long peakPagedMemorySize64 = process.PeakPagedMemorySize64;     // 峰值分页内存
        
        // 句柄计数
        int handleCount = process.HandleCount;
        
        // 格式化输出
        Console.WriteLine("=== 内存使用情况 ===");
        Console.WriteLine($"物理内存: {FormatBytes(workingSet64)}");
        Console.WriteLine($"虚拟内存: {FormatBytes(virtualMemorySize64)}");
        Console.WriteLine($"私有内存: {FormatBytes(privateMemorySize64)}");
        Console.WriteLine($"分页内存: {FormatBytes(pagedMemorySize64)}");
        Console.WriteLine($"非分页系统内存: {FormatBytes(nonpagedSystemMemorySize64)}");
        Console.WriteLine($"分页系统内存: {FormatBytes(pagedSystemMemorySize64)}");
        Console.WriteLine("\n=== 峰值内存使用 ===");
        Console.WriteLine($"峰值物理内存: {FormatBytes(peakWorkingSet64)}");
        Console.WriteLine($"峰值虚拟内存: {FormatBytes(peakVirtualMemorySize64)}");
        Console.WriteLine($"峰值分页内存: {FormatBytes(peakPagedMemorySize64)}");
        Console.WriteLine($"\n句柄数: {handleCount}");
    }
    
    private string FormatBytes(long bytes)
    {
        string[] sizes = { "B", "KB", "MB", "GB", "TB" };
        int order = 0;
        double size = bytes;
        while (size >= 1024 && order < sizes.Length - 1)
        {
            order++;
            size /= 1024;
        }
        return $"{size:0.##} {sizes[order]}";
    }
}
```

#### 1.2.5 线程和优先级属性

```csharp
public class ProcessThreadProperties
{
    public void ShowThreadProperties()
    {
        Process process = Process.GetCurrentProcess();
        
        // 线程集合
        ProcessThreadCollection threads = process.Threads;
        
        // 优先级
        ProcessPriorityClass priorityClass = process.PriorityClass;
        bool priorityBoostEnabled = process.PriorityBoostEnabled;
        int basePriority = process.BasePriority;
        
        // 处理器亲和性
        IntPtr processorAffinity = process.ProcessorAffinity;
        
        Console.WriteLine($"线程数: {threads.Count}");
        Console.WriteLine($"优先级类: {priorityClass}");
        Console.WriteLine($"基础优先级: {basePriority}");
        Console.WriteLine($"优先级提升: {priorityBoostEnabled}");
        Console.WriteLine($"处理器亲和性: {processorAffinity}");
        
        // 遍历所有线程
        foreach (ProcessThread thread in threads)
        {
            Console.WriteLine($"\n线程 ID: {thread.Id}");
            Console.WriteLine($"  状态: {thread.ThreadState}");
            Console.WriteLine($"  优先级: {thread.CurrentPriority}");
            Console.WriteLine($"  基础优先级: {thread.BasePriority}");
            Console.WriteLine($"  启动时间: {thread.StartTime}");
            Console.WriteLine($"  CPU时间: {thread.TotalProcessorTime}");
            Console.WriteLine($"  用户时间: {thread.UserProcessorTime}");
            //Console.WriteLine($"  等待原因: {thread.WaitReason}");
        }
        
        // 修改进程优先级
        try
        {
            process.PriorityClass = ProcessPriorityClass.High;
            Console.WriteLine("已将进程优先级设置为高");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"无法修改优先级: {ex.Message}");
        }
    }
}
```

### 1.3 Process 类的所有方法详解

#### 1.3.1 静态方法完整列表

```csharp
public class ProcessStaticMethodsComplete
{
    public void DemoAllStaticMethods()
    {
        // 1. 获取当前进程
        Process current = Process.GetCurrentProcess();
        
        // 2. 根据ID获取进程
        try
        {
            Process processById = Process.GetProcessById(1234);
            Process processOnRemote = Process.GetProcessById(1234, "RemotePC");
        }
        catch (ArgumentException)
        {
            Console.WriteLine("进程不存在");
        }
        
        // 3. 根据名称获取进程
        Process[] notepadProcesses = Process.GetProcessesByName("notepad");
        Process[] remoteProcesses = Process.GetProcessesByName("notepad", "RemotePC");
        
        // 4. 获取所有进程
        Process[] allLocal = Process.GetProcesses();
        Process[] allRemote = Process.GetProcesses("RemotePC");
        
        // 5. 启动进程的各种方式
        Process p1 = Process.Start("notepad.exe");
        Process p2 = Process.Start("notepad.exe", "file.txt");
        Process p3 = Process.Start(new ProcessStartInfo("cmd.exe"));
        
        // 6. 进入/离开调试模式
        Process.EnterDebugMode();  // 需要SeDebugPrivilege权限
        Process.LeaveDebugMode();
    }
}
```

#### 1.3.2 Process 实例方法完全详解 

##### 1. Start() - 启动进程

```csharp
public class ProcessStartMethods
{
    public void DemoStart()
    {
        Process process = new Process();
        
        // 方法签名: public bool Start()
        // 返回值: 如果启动了新进程返回true，如果进程已在运行返回false
        // 用途: 启动（或重用）ProcessStartInfo指定的进程资源
        
        process.StartInfo = new ProcessStartInfo
        {
            FileName = "notepad.exe",
            Arguments = "test.txt",
            UseShellExecute = false,
            RedirectStandardOutput = true
        };
        
        try
        {
            bool started = process.Start();
            
            if (started)
            {
                Console.WriteLine($"进程已启动，PID: {process.Id}");
            }
            else
            {
                Console.WriteLine("进程启动失败或已在运行");
            }
        }
        catch (InvalidOperationException ex)
        {
            // StartInfo中没有指定FileName
            Console.WriteLine($"无效操作: {ex.Message}");
        }
        catch (Win32Exception ex)
        {
            // 发生错误（如文件未找到）
            Console.WriteLine($"Win32错误: {ex.Message}");
        }
        catch (PlatformNotSupportedException ex)
        {
            // 操作系统不支持该操作
            Console.WriteLine($"平台不支持: {ex.Message}");
        }
        
        // 注意事项：
        // 1. 必须先设置StartInfo属性
        // 2. 如果UseShellExecute=false，必须提供完整路径或确保程序在PATH中
        // 3. Start()后立即访问某些属性可能抛出异常，需要等待进程完全启动
    }
}
```

##### 2. Kill() - 终止进程

```csharp
public class ProcessKillMethods
{
    public void DemoKill()
    {
        Process process = Process.Start("notepad.exe");
        Thread.Sleep(1000);
        
        // 方法1: Kill() - 立即终止进程
        // 方法签名: public void Kill()
        // 用途: 立即停止关联的进程（强制终止）
        
        try
        {
            process.Kill();
            Console.WriteLine("进程已被终止");
            
            // Kill后进程可能不会立即退出，使用WaitForExit确保
            process.WaitForExit();
            Console.WriteLine($"退出代码: {process.ExitCode}");
        }
        catch (Win32Exception ex)
        {
            // 无法终止进程（如权限不足）
            Console.WriteLine($"无法终止进程: {ex.Message}");
        }
        catch (InvalidOperationException ex)
        {
            // 进程已退出
            Console.WriteLine($"进程已退出: {ex.Message}");
        }
        
        // 方法2: Kill(bool entireProcessTree) - .NET 5.0+
        // 方法签名: public void Kill(bool entireProcessTree)
        // 用途: 终止进程及其所有子进程
        
        Process parentProcess = Process.Start(new ProcessStartInfo
        {
            FileName = "cmd.exe",
            Arguments = "/c \"start notepad.exe && timeout 10\"",
            UseShellExecute = false
        });
        
        Thread.Sleep(2000);
        
        try
        {
            // 终止整个进程树
            parentProcess.Kill(entireProcessTree: true);
            Console.WriteLine("进程树已被终止");
        }
        catch (PlatformNotSupportedException)
        {
            Console.WriteLine("当前平台不支持终止进程树");
        }
        
        // 注意事项：
        // 1. Kill()是异步的，调用后进程可能不会立即终止
        // 2. 应该在Kill()后调用WaitForExit()
        // 3. Kill()会导致数据丢失，应优先使用CloseMainWindow()
        // 4. 需要适当的权限才能终止其他用户的进程
    }
}
```

##### 3. CloseMainWindow() - 请求关闭主窗口

```csharp
public class ProcessCloseMainWindow
{
    public void DemoCloseMainWindow()
    {
        Process process = Process.Start("notepad.exe");
        Thread.Sleep(2000);
        
        // 方法签名: public bool CloseMainWindow()
        // 返回值: 如果成功发送关闭消息返回true，否则返回false
        // 用途: 通过向主窗口发送关闭消息来关闭具有用户界面的进程
        
        try
        {
            bool result = process.CloseMainWindow();
            
            if (result)
            {
                Console.WriteLine("已发送关闭请求");
                
                // 等待进程响应关闭请求
                if (process.WaitForExit(5000))
                {
                    Console.WriteLine("进程已正常关闭");
                }
                else
                {
                    Console.WriteLine("进程未响应关闭请求，强制终止");
                    process.Kill();
                }
            }
            else
            {
                Console.WriteLine("无法发送关闭请求（可能没有主窗口）");
            }
        }
        catch (InvalidOperationException)
        {
            Console.WriteLine("进程已退出或没有关联的进程");
        }
        catch (PlatformNotSupportedException)
        {
            Console.WriteLine("远程计算机不支持此操作");
        }
        
        // 与Kill()的区别：
        // 1. CloseMainWindow()是请求，进程可以选择忽略
        // 2. 允许进程执行清理操作（保存数据等）
        // 3. 只对有GUI的进程有效
        // 4. 更优雅的关闭方式
    }
}
```

##### 4. WaitForExit() - 等待进程退出

```csharp
public class ProcessWaitForExit
{
    public void DemoWaitForExit()
    {
        Process process = Process.Start("notepad.exe");
        
        // 方法1: WaitForExit() - 无限期等待
        // 方法签名: public void WaitForExit()
        // 用途: 指示Process组件无限期等待关联进程退出
        
        Task.Run(() =>
        {
            Thread.Sleep(3000);
            process.Kill();
        });
        
        process.WaitForExit();
        Console.WriteLine("进程已退出");
        
        // 方法2: WaitForExit(int milliseconds) - 等待指定时间
        // 方法签名: public bool WaitForExit(int milliseconds)
        // 返回值: 如果进程已退出返回true，如果超时返回false
        
        Process process2 = Process.Start("cmd.exe", "/c timeout 10");
        
        bool exited = process2.WaitForExit(5000);  // 等待5秒
        
        if (exited)
        {
            Console.WriteLine($"进程已退出，退出代码: {process2.ExitCode}");
        }
        else
        {
            Console.WriteLine("等待超时，强制终止进程");
            process2.Kill();
            process2.WaitForExit();  // 确保进程完全退出
        }
        
        // 方法3: WaitForExit(TimeSpan timeout) - .NET 5.0+
        // 方法签名: public bool WaitForExit(TimeSpan timeout)
        
        Process process3 = Process.Start("notepad.exe");
        bool exitedInTime = process3.WaitForExit(TimeSpan.FromSeconds(10));
        
        // 异步等待示例
        async Task WaitForExitAsync(Process p, int timeoutMs)
        {
            await Task.Run(() => p.WaitForExit(timeoutMs));
        }
        
        // 注意事项：
        // 1. WaitForExit()会阻塞当前线程
        // 2. 在UI线程中使用时要小心，可能导致界面无响应
        // 3. 使用超时版本可以避免无限期等待
        // 4. 如果进程已经退出，立即返回
    }
}
```

##### 5. WaitForInputIdle() - 等待进程空闲

```csharp
public class ProcessWaitForInputIdle
{
    public void DemoWaitForInputIdle()
    {
        // 方法签名: 
        // public bool WaitForInputIdle()
        // public bool WaitForInputIdle(int milliseconds)
        // public bool WaitForInputIdle(TimeSpan timeout) // .NET 5.0+
        
        // 用途: 等待关联进程进入空闲状态（消息循环空闲，等待用户输入）
        // 主要用于GUI应用程序
        
        Process process = Process.Start("notepad.exe");
        
        try
        {
            // 等待进程进入空闲状态（最多等待10秒）
            bool idle = process.WaitForInputIdle(10000);
            
            if (idle)
            {
                Console.WriteLine("进程已进入空闲状态，可以进行自动化操作");
                
                // 现在可以安全地进行UI自动化操作
                // 例如：发送键盘输入、鼠标点击等
            }
            else
            {
                Console.WriteLine("等待超时，进程未进入空闲状态");
            }
        }
        catch (InvalidOperationException)
        {
            Console.WriteLine("进程没有图形界面或已退出");
        }
        
        // 控制台应用程序的情况
        Process consoleProcess = Process.Start("cmd.exe");
        try
        {
            consoleProcess.WaitForInputIdle(1000);
        }
        catch (InvalidOperationException)
        {
            Console.WriteLine("控制台应用程序没有消息循环");
        }
        
        // 用途示例：自动化测试
        void AutomateNotepad()
        {
            var process = Process.Start("notepad.exe");
            
            // 等待记事本完全启动并准备好接收输入
            if (process.WaitForInputIdle(5000))
            {
                // 使用SendKeys或UI自动化库进行操作
                System.Windows.Forms.SendKeys.SendWait("Hello World!");
            }
            
            process.CloseMainWindow();
        }
        
        // 注意事项：
        // 1. 只对有消息循环的GUI程序有效
        // 2. 对控制台程序会抛出InvalidOperationException
        // 3. 用于确保GUI程序完全启动后再进行自动化操作
        // 4. 不能用于判断程序是否完成某个操作
    }
}
```

##### 6. Refresh() - 刷新进程信息

```csharp
public class ProcessRefresh
{
    public void DemoRefresh()
    {
        Process process = Process.Start("notepad.exe");
        
        // 方法签名: public void Refresh()
        // 用途: 丢弃进程的缓存信息，强制从系统重新读取
        
        // 初始信息
        Console.WriteLine($"初始内存: {process.WorkingSet64 / 1024 / 1024} MB");
        
        // 等待一段时间，期间进程可能使用更多内存
        Thread.Sleep(5000);
        
        // 不刷新的情况下，某些属性可能返回缓存的值
        Console.WriteLine($"缓存的内存: {process.WorkingSet64 / 1024 / 1024} MB");
        
        // 刷新后获取最新信息
        process.Refresh();
        Console.WriteLine($"刷新后内存: {process.WorkingSet64 / 1024 / 1024} MB");
        
        // 需要刷新的属性示例
        void MonitorProcess(Process p)
        {
            while (!p.HasExited)
            {
                p.Refresh();  // 刷新以获取最新状态
                
                // 这些属性会被缓存，需要Refresh()才能获取最新值
                Console.WriteLine($"时间: {DateTime.Now:HH:mm:ss}");
                Console.WriteLine($"  内存: {p.WorkingSet64 / 1024 / 1024} MB");
                Console.WriteLine($"  线程数: {p.Threads.Count}");
                Console.WriteLine($"  句柄数: {p.HandleCount}");
                Console.WriteLine($"  CPU时间: {p.TotalProcessorTime}");
                
                Thread.Sleep(1000);
            }
        }
        
        // 哪些信息会被缓存：
        // - Threads集合
        // - Modules集合
        // - 内存相关属性（WorkingSet64等）
        // - CPU时间属性
        // - MainWindowTitle
        // - Responding状态
        
        // 注意事项：
        // 1. Refresh()会清除所有缓存的属性值
        // 2. 下次访问属性时会重新从系统获取
        // 3. 频繁调用可能影响性能
        // 4. HasExited属性不需要Refresh()
    }
}
```

##### 7. 异步I/O读取方法

```csharp
public class ProcessAsyncIO
{
    public void DemoAsyncIO()
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = "cmd.exe",
            Arguments = "/c dir C:\\ /s",
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        };
        
        Process process = new Process { StartInfo = startInfo };
        
        // BeginOutputReadLine() - 开始异步读取标准输出
        // 方法签名: public void BeginOutputReadLine()
        
        StringBuilder outputBuilder = new StringBuilder();
        process.OutputDataReceived += (sender, e) =>
        {
            if (e.Data != null)
            {
                outputBuilder.AppendLine(e.Data);
                Console.WriteLine($"[OUTPUT] {e.Data}");
            }
        };
        
        // BeginErrorReadLine() - 开始异步读取标准错误
        // 方法签名: public void BeginErrorReadLine()
        
        StringBuilder errorBuilder = new StringBuilder();
        process.ErrorDataReceived += (sender, e) =>
        {
            if (e.Data != null)
            {
                errorBuilder.AppendLine(e.Data);
                Console.WriteLine($"[ERROR] {e.Data}");
            }
        };
        
        process.Start();
        
        // 开始异步读取
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();
        
        // 等待一段时间后取消读取
        Thread.Sleep(2000);
        
        // CancelOutputRead() - 取消异步读取输出
        // 方法签名: public void CancelOutputRead()
        process.CancelOutputRead();
        
        // CancelErrorRead() - 取消异步读取错误
        // 方法签名: public void CancelErrorRead()
        process.CancelErrorRead();
        
        process.Kill();
        process.WaitForExit();
        
        // 完整的异步读取示例
        async Task<(string output, string error)> ExecuteAsync(string fileName, string arguments)
        {
            var tcs = new TaskCompletionSource<(string, string)>();
            var output = new StringBuilder();
            var error = new StringBuilder();
            
            var process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = fileName,
                    Arguments = arguments,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                },
                EnableRaisingEvents = true
            };
            
            process.OutputDataReceived += (s, e) =>
            {
                if (e.Data != null) output.AppendLine(e.Data);
            };
            
            process.ErrorDataReceived += (s, e) =>
            {
                if (e.Data != null) error.AppendLine(e.Data);
            };
            
            process.Exited += (s, e) =>
            {
                tcs.SetResult((output.ToString(), error.ToString()));
                process.Dispose();
            };
            
            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            
            return await tcs.Task;
        }
        
        // 注意事项：
        // 1. 必须先设置RedirectStandardOutput/Error = true
        // 2. 必须先订阅DataReceived事件
        // 3. 必须在Start()之后调用Begin方法
        // 4. e.Data为null表示流结束
        // 5. 异步读取避免了同步读取可能造成的死锁
    }
}
```

##### 8. Close() 和 Dispose() - 资源释放

```csharp
public class ProcessResourceManagement
{
    public void DemoResourceManagement()
    {
        // Close() - 释放与进程关联的所有资源
        // 方法签名: public void Close()
        
        Process process1 = Process.Start("notepad.exe");
        
        // Close()释放Process对象的资源，但不停止实际进程
        process1.Close();
        
        // Close()后不能再访问进程属性
        try
        {
            var id = process1.Id;  // 抛出异常
        }
        catch (InvalidOperationException)
        {
            Console.WriteLine("Close()后无法访问进程属性");
        }
        
        // Dispose() - 释放Component使用的所有资源
        // 方法签名: public void Dispose()
        
        Process process2 = Process.Start("notepad.exe");
        
        // Dispose()调用Close()并释放托管和非托管资源
        process2.Dispose();
        
        // 推荐使用using语句自动释放资源
        using (Process process3 = Process.Start("notepad.exe"))
        {
            // 使用进程
            process3.WaitForExit(1000);
        } // 自动调用Dispose()
        
        // Dispose(bool disposing) - 受保护的虚方法
        // 可以在派生类中重写以自定义清理逻辑
        class CustomProcess : Process
        {
            private FileStream logFile;
            
            protected override void Dispose(bool disposing)
            {
                if (disposing)
                {
                    // 释放托管资源
                    logFile?.Dispose();
                }
                
                // 释放非托管资源
                
                base.Dispose(disposing);
            }
        }
        
        // Close() vs Dispose() vs Kill()
        void CompareCleanupMethods()
        {
            Process p = Process.Start("notepad.exe");
            
            // Kill() - 终止进程
            // p.Kill();  // 进程被终止
            
            // Close() - 释放Process对象资源，进程继续运行
            // p.Close();  // 记事本继续运行
            
            // Dispose() - 释放所有资源，进程继续运行
            // p.Dispose();  // 记事本继续运行
        }
        
        // 最佳实践
        async Task BestPractice()
        {
            using (var process = new Process())
            {
                process.StartInfo = new ProcessStartInfo("app.exe");
                process.Start();
                
                // 使用进程
                await Task.Run(() => process.WaitForExit(5000));
                
                if (!process.HasExited)
                {
                    process.Kill();
                }
            } // 自动清理资源
        }
        
        // 注意事项：
        // 1. Close()和Dispose()不会终止进程
        // 2. 这些方法只是释放Process对象的资源
        // 3. 始终使用using语句或try-finally确保资源释放
        // 4. 释放后不能再访问进程属性
    }
}
```

##### 9. 事件相关方法和属性

```csharp
public class ProcessEvents
{
    public void DemoEvents()
    {
        Process process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "notepad.exe",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            },
            
            // EnableRaisingEvents - 获取或设置是否应在进程终止时引发Exited事件
            // 属性: public bool EnableRaisingEvents { get; set; }
            EnableRaisingEvents = true
        };
        
        // Exited事件 - 进程退出时发生
        // 事件签名: public event EventHandler Exited
        process.Exited += (sender, e) =>
        {
            Console.WriteLine($"进程已退出，时间: {DateTime.Now}");
            Process p = sender as Process;
            Console.WriteLine($"退出代码: {p.ExitCode}");
        };
        
        // OutputDataReceived事件 - 异步读取输出时接收数据
        // 事件签名: public event DataReceivedEventHandler OutputDataReceived
        process.OutputDataReceived += (sender, e) =>
        {
            // e.Data为null表示输出结束
            if (e.Data != null)
            {
                Console.WriteLine($"输出: {e.Data}");
            }
        };
        
        // ErrorDataReceived事件 - 异步读取错误时接收数据
        // 事件签名: public event DataReceivedEventHandler ErrorDataReceived
        process.ErrorDataReceived += (sender, e) =>
        {
            if (e.Data != null)
            {
                Console.WriteLine($"错误: {e.Data}");
            }
        };
        
        process.Start();
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();
        
        // 完整的事件处理示例
        class ProcessMonitor
        {
            private Process _process;
            private DateTime _startTime;
            
            public void StartMonitoring(string fileName)
            {
                _process = new Process
                {
                    StartInfo = new ProcessStartInfo(fileName),
                    EnableRaisingEvents = true
                };
                
                // 订阅所有事件
                _process.Exited += OnProcessExited;
                
                _startTime = DateTime.Now;
                _process.Start();
            }
            
            private void OnProcessExited(object sender, EventArgs e)
            {
                var duration = DateTime.Now - _startTime;
                Console.WriteLine($"进程运行时长: {duration}");
                
                // 清理资源
                _process.Exited -= OnProcessExited;
                _process.Dispose();
                
                // 可以在这里重启进程或执行其他操作
                RestartIfNeeded();
            }
            
            private void RestartIfNeeded()
            {
                if (_process.ExitCode != 0)
                {
                    Console.WriteLine("进程异常退出，准备重启...");
                    StartMonitoring(_process.StartInfo.FileName);
                }
            }
        }
        
        // 异步事件处理
        async void HandleExitedAsync(object sender, EventArgs e)
        {
            var process = sender as Process;
            
            // 记录日志
            await File.AppendAllTextAsync(
                "process.log",
                $"{DateTime.Now}: Process {process.Id} exited with code {process.ExitCode}\n"
            );
            
            // 发送通知
            await SendNotificationAsync($"进程 {process.ProcessName} 已退出");
        }
        
        async Task SendNotificationAsync(string message)
        {
            // 发送邮件、推送通知等
            await Task.Delay(100);
        }
        
        // 注意事项：
        // 1. 必须设置EnableRaisingEvents = true才能接收Exited事件
        // 2. 事件处理程序在线程池线程上执行
        // 3. 进程退出后仍可访问某些属性（如ExitCode）
        // 4. OutputDataReceived/ErrorDataReceived需要先调用Begin方法
    }
}
```

##### 10. 其他实用方法

```csharp
public class ProcessOtherMethods
{
    public void DemoOtherMethods()
    {
        Process process = Process.Start("notepad.exe");
        
        // ToString() - 返回进程名称的字符串表示
        // 方法签名: public override string ToString()
        string processString = process.ToString();
        Console.WriteLine($"进程字符串: {processString}");  // 输出: System.Diagnostics.Process (notepad)
        
        // GetType() - 获取当前实例的Type
        Type processType = process.GetType();
        Console.WriteLine($"类型: {processType.FullName}");
        
        // Equals() - 确定指定对象是否等于当前对象
        Process anotherProcess = Process.GetProcessById(process.Id);
        bool areEqual = process.Equals(anotherProcess);  // false，不同的Process实例
        
        // GetHashCode() - 作为默认哈希函数
        int hashCode = process.GetHashCode();
        
        // 使用示例：在集合中使用Process
        var processDict = new Dictionary<Process, string>();
        processDict[process] = "My Notepad";
        
        // 自定义Process扩展方法
        public static class ProcessExtensions
        {
            // 安全获取进程信息
            public static bool TryGetProcessInfo(this Process process, out string info)
            {
                info = null;
                try
                {
                    process.Refresh();
                    info = $"PID: {process.Id}, Name: {process.ProcessName}, Memory: {process.WorkingSet64 / 1024 / 1024}MB";
                    return true;
                }
                catch
                {
                    return false;
                }
            }
            
            // 等待进程退出（带超时和取消）
            public static async Task<bool> WaitForExitAsync(
                this Process process, 
                TimeSpan timeout,
                CancellationToken cancellationToken = default)
            {
                var tcs = new TaskCompletionSource<bool>();
                
                process.EnableRaisingEvents = true;
                process.Exited += (s, e) => tcs.TrySetResult(true);
                
                using (var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken))
                {
                    cts.CancelAfter(timeout);
                    cts.Token.Register(() => tcs.TrySetResult(false));
                    
                    return await tcs.Task;
                }
            }
            
            // 安全终止进程
            public static bool TryKill(this Process process, int waitMs = 5000)
            {
                try
                {
                    if (!process.HasExited)
                    {
                        process.Kill();
                        return process.WaitForExit(waitMs);
                    }
                    return true;
                }
                catch
                {
                    return false;
                }
            }
        }
    }
}
```

##### 11. 高级方法使用场景

```csharp
public class AdvancedMethodScenarios
{
    // 场景1：监控进程生命周期
    public class ProcessLifecycleMonitor
    {
        private readonly Process _process;
        private readonly System.Timers.Timer _timer;
        private readonly List<ProcessSnapshot> _snapshots = new();
        
        public class ProcessSnapshot
        {
            public DateTime Time { get; set; }
            public long MemoryUsage { get; set; }
            public TimeSpan CpuTime { get; set; }
            public int ThreadCount { get; set; }
        }
        
        public ProcessLifecycleMonitor(Process process)
        {
            _process = process;
            _process.EnableRaisingEvents = true;
            _process.Exited += OnProcessExited;
            
            _timer = new System.Timers.Timer(1000);
            _timer.Elapsed += CollectSnapshot;
            _timer.Start();
        }
        
        private void CollectSnapshot(object sender, EventArgs e)
        {
            if (!_process.HasExited)
            {
                _process.Refresh();
                _snapshots.Add(new ProcessSnapshot
                {
                    Time = DateTime.Now,
                    MemoryUsage = _process.WorkingSet64,
                    CpuTime = _process.TotalProcessorTime,
                    ThreadCount = _process.Threads.Count
                });
            }
        }
        
        private void OnProcessExited(object sender, EventArgs e)
        {
            _timer.Stop();
            GenerateReport();
        }
        
        private void GenerateReport()
        {
            Console.WriteLine("进程生命周期报告:");
            Console.WriteLine($"运行时长: {_process.ExitTime - _process.StartTime}");
            Console.WriteLine($"退出代码: {_process.ExitCode}");
            Console.WriteLine($"峰值内存: {_snapshots.Max(s => s.MemoryUsage) / 1024 / 1024}MB");
            Console.WriteLine($"平均线程数: {_snapshots.Average(s => s.ThreadCount):F2}");
        }
    }
    
    // 场景2：进程通信管理器
    public class ProcessCommunicationManager
    {
        private Process _childProcess;
        private StreamWriter _input;
        private TaskCompletionSource<string> _responseTask;
        
        public async Task<string> SendCommandAsync(string command, TimeSpan timeout)
        {
            if (_childProcess == null || _childProcess.HasExited)
            {
                StartChildProcess();
            }
            
            _responseTask = new TaskCompletionSource<string>();
            
            await _input.WriteLineAsync(command);
            await _input.FlushAsync();
            
            using (var cts = new CancellationTokenSource(timeout))
            {
                cts.Token.Register(() => _responseTask.TrySetCanceled());
                return await _responseTask.Task;
            }
        }
        
        private void StartChildProcess()
        {
            _childProcess = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "child.exe",
                    UseShellExecute = false,
                    RedirectStandardInput = true,
                    RedirectStandardOutput = true,
                    CreateNoWindow = true
                },
                EnableRaisingEvents = true
            };
            
            _childProcess.OutputDataReceived += (s, e) =>
            {
                if (e.Data != null)
                {
                    _responseTask?.TrySetResult(e.Data);
                }
            };
            
            _childProcess.Exited += (s, e) =>
            {
                _responseTask?.TrySetException(new Exception("子进程意外退出"));
                Restart();
            };
            
            _childProcess.Start();
            _childProcess.BeginOutputReadLine();
            _input = _childProcess.StandardInput;
        }
        
        private void Restart()
        {
            _childProcess?.Dispose();
            Task.Delay(1000).ContinueWith(_ => StartChildProcess());
        }
    }
    
    // 场景3：批量进程管理
    public class BatchProcessManager
    {
        private readonly List<Process> _processes = new();
        private readonly SemaphoreSlim _semaphore;
        
        public BatchProcessManager(int maxConcurrent)
        {
            _semaphore = new SemaphoreSlim(maxConcurrent);
        }
        
        public async Task ExecuteBatchAsync(string[] commands)
        {
            var tasks = commands.Select(cmd => ExecuteCommandAsync(cmd));
            await Task.WhenAll(tasks);
        }
        
        private async Task ExecuteCommandAsync(string command)
        {
            await _semaphore.WaitAsync();
            
            try
            {
                var process = new Process
                {
                    StartInfo = new ProcessStartInfo("cmd.exe", $"/c {command}")
                    {
                        UseShellExecute = false,
                        CreateNoWindow = true
                    },
                    EnableRaisingEvents = true
                };
                
                var tcs = new TaskCompletionSource<int>();
                process.Exited += (s, e) =>
                {
                    tcs.SetResult(process.ExitCode);
                    _processes.Remove(process);
                    process.Dispose();
                    _semaphore.Release();
                };
                
                _processes.Add(process);
                process.Start();
                
                var exitCode = await tcs.Task;
                Console.WriteLine($"命令 '{command}' 完成，退出代码: {exitCode}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"执行命令 '{command}' 失败: {ex.Message}");
                _semaphore.Release();
            }
        }
        
        public void KillAll()
        {
            foreach (var process in _processes.ToList())
            {
                try
                {
                    if (!process.HasExited)
                    {
                        process.Kill();
                    }
                }
                catch { }
            }
        }
    }
}
```

我来补充Process标准流（StandardInput/Output/Error）的详细内容：



### 1.4 Process 标准流（StandardInput/Output/Error）

#### 1.4.1 标准流基础概念

```csharp
public class StandardStreamsBasics
{
    public void ExplainStandardStreams()
    {
        /*
         * 标准流概念：
         * 1. StandardInput (stdin) - 进程的输入流，文件描述符0
         * 2. StandardOutput (stdout) - 进程的输出流，文件描述符1
         * 3. StandardError (stderr) - 进程的错误流，文件描述符2
         * 
         * 重要特性：
         * - 默认情况下，子进程继承父进程的标准流
         * - 可以重定向到文件、管道或其他进程
         * - 支持同步和异步操作
         * - 可以设置编码方式
         */
        
        Process process = new Process();
        
        // 标准流相关属性
        StreamWriter stdin = process.StandardInput;   // 写入子进程
        StreamReader stdout = process.StandardOutput; // 读取子进程输出
        StreamReader stderr = process.StandardError;  // 读取子进程错误
        
        // 必须设置重定向才能访问这些流
        process.StartInfo.RedirectStandardInput = true;
        process.StartInfo.RedirectStandardOutput = true;
        process.StartInfo.RedirectStandardError = true;
        process.StartInfo.UseShellExecute = false; // 必须为false
    }
}
```

#### 1.4.2 StandardInput - 标准输入流详解

```csharp
public class StandardInputComplete
{
    // 基本使用
    public void BasicStandardInput()
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = "cmd.exe",
            UseShellExecute = false,
            RedirectStandardInput = true,
            RedirectStandardOutput = true,
            CreateNoWindow = true
        };
        
        using (Process process = Process.Start(startInfo))
        {
            // 获取标准输入流
            StreamWriter stdin = process.StandardInput;
            
            // 写入命令
            stdin.WriteLine("echo Hello World");
            stdin.WriteLine("dir");
            stdin.WriteLine("exit");
            
            // 刷新缓冲区
            stdin.Flush();
            
            // 关闭输入流（发送EOF）
            stdin.Close();
            
            // 读取输出
            string output = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            
            Console.WriteLine(output);
        }
    }
    
    // 交互式输入
    public class InteractiveInput
    {
        private Process _process;
        private StreamWriter _stdin;
        private StreamReader _stdout;
        
        public void StartInteractiveSession()
        {
            _process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "python.exe",
                    Arguments = "-i", // 交互模式
                    UseShellExecute = false,
                    RedirectStandardInput = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true,
                    StandardOutputEncoding = Encoding.UTF8,
                    StandardErrorEncoding = Encoding.UTF8
                }
            };
            
            _process.Start();
            _stdin = _process.StandardInput;
            _stdout = _process.StandardOutput;
            
            // 启动异步读取
            Task.Run(() => ReadOutput());
        }
        
        public async Task SendCommandAsync(string command)
        {
            await _stdin.WriteLineAsync(command);
            await _stdin.FlushAsync();
        }
        
        private async Task ReadOutput()
        {
            char[] buffer = new char[4096];
            while (!_process.HasExited)
            {
                int read = await _stdout.ReadAsync(buffer, 0, buffer.Length);
                if (read > 0)
                {
                    Console.Write(new string(buffer, 0, read));
                }
            }
        }
    }
    
    // 发送二进制数据
    public void SendBinaryData()
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = "processor.exe",
            UseShellExecute = false,
            RedirectStandardInput = true,
            RedirectStandardOutput = true
        };
        
        using (Process process = Process.Start(startInfo))
        {
            // 获取基础流进行二进制操作
            Stream inputStream = process.StandardInput.BaseStream;
            
            // 发送二进制数据
            byte[] data = { 0x01, 0x02, 0x03, 0x04 };
            inputStream.Write(data, 0, data.Length);
            inputStream.Flush();
            
            // 发送文件内容
            byte[] fileData = File.ReadAllBytes("input.dat");
            inputStream.Write(fileData, 0, fileData.Length);
            
            // 关闭输入
            process.StandardInput.Close();
            
            process.WaitForExit();
        }
    }
    
    // 管道式输入
    public async Task PipeInput(string inputFile, string outputFile)
    {
        var compressProcess = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "gzip.exe",
                Arguments = "-c", // 输出到stdout
                UseShellExecute = false,
                RedirectStandardInput = true,
                RedirectStandardOutput = true
            }
        };
        
        compressProcess.Start();
        
        // 异步写入输入
        using (var fileStream = File.OpenRead(inputFile))
        {
            await fileStream.CopyToAsync(compressProcess.StandardInput.BaseStream);
        }
        compressProcess.StandardInput.Close();
        
        // 异步读取输出并写入文件
        using (var outputStream = File.Create(outputFile))
        {
            await compressProcess.StandardOutput.BaseStream.CopyToAsync(outputStream);
        }
        
        compressProcess.WaitForExit();
    }
}
```

#### 1.4.3 StandardOutput - 标准输出流详解

```csharp
public class StandardOutputComplete
{
    // 同步读取输出
    public void SynchronousRead()
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = "ipconfig.exe",
            Arguments = "/all",
            UseShellExecute = false,
            RedirectStandardOutput = true,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8 // 设置编码
        };
        
        using (Process process = Process.Start(startInfo))
        {
            // 方法1: ReadToEnd() - 读取所有输出
            string allOutput = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            Console.WriteLine(allOutput);
        }
        
        // 方法2: ReadLine() - 逐行读取
        using (Process process2 = Process.Start(startInfo))
        {
            string line;
            while ((line = process2.StandardOutput.ReadLine()) != null)
            {
                Console.WriteLine($"Line: {line}");
                // 可以在这里处理每一行
            }
            process2.WaitForExit();
        }
        
        // 方法3: Read() - 逐字符读取
        using (Process process3 = Process.Start(startInfo))
        {
            int charCode;
            while ((charCode = process3.StandardOutput.Read()) != -1)
            {
                Console.Write((char)charCode);
            }
            process3.WaitForExit();
        }
    }
    
    // 异步读取输出（推荐）
    public class AsynchronousRead
    {
        public async Task ReadOutputAsync()
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = "ping.exe",
                Arguments = "google.com -t",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                // 方法1: 使用事件处理器（最常用）
                process.OutputDataReceived += (sender, e) =>
                {
                    if (e.Data != null)
                    {
                        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {e.Data}");
                    }
                };
                
                process.BeginOutputReadLine(); // 开始异步读取
                
                await Task.Delay(5000); // 运行5秒
                
                process.CancelOutputRead(); // 取消读取
                process.Kill();
                process.WaitForExit();
            }
        }
        
        // 方法2: 使用async/await
        public async Task<string> ReadAllOutputAsync()
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = "/c dir C:\\ /s",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                // 异步读取所有输出
                string output = await process.StandardOutput.ReadToEndAsync();
                await Task.Run(() => process.WaitForExit());
                return output;
            }
        }
        
        // 方法3: 流式处理大量输出
        public async Task ProcessLargeOutput()
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = "largeoutput.exe",
                UseShellExecute = false,
                RedirectStandardOutput = true
            };
            
            using (Process process = Process.Start(startInfo))
            using (StreamReader reader = process.StandardOutput)
            {
                char[] buffer = new char[4096];
                StringBuilder output = new StringBuilder();
                
                int read;
                while ((read = await reader.ReadAsync(buffer, 0, buffer.Length)) > 0)
                {
                    output.Append(buffer, 0, read);
                    
                    // 处理缓冲区，避免内存溢出
                    if (output.Length > 1000000) // 1MB
                    {
                        await ProcessChunk(output.ToString());
                        output.Clear();
                    }
                }
                
                // 处理剩余数据
                if (output.Length > 0)
                {
                    await ProcessChunk(output.ToString());
                }
                
                process.WaitForExit();
            }
        }
        
        private async Task ProcessChunk(string chunk)
        {
            // 处理数据块
            await File.AppendAllTextAsync("output.txt", chunk);
        }
    }
    
    // 实时输出监控
    public class RealTimeOutputMonitor
    {
        private readonly Subject<string> _outputSubject = new Subject<string>();
        public IObservable<string> Output => _outputSubject;
        
        public async Task StartMonitoring(string command, string arguments)
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = command,
                Arguments = arguments,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                process.OutputDataReceived += (s, e) =>
                {
                    if (e.Data != null)
                    {
                        _outputSubject.OnNext(e.Data);
                    }
                };
                
                process.EnableRaisingEvents = true;
                process.Exited += (s, e) =>
                {
                    _outputSubject.OnCompleted();
                };
                
                process.BeginOutputReadLine();
                
                await Task.Run(() => process.WaitForExit());
            }
        }
    }
}
```

#### 1.4.4 StandardError - 标准错误流详解

```csharp
public class StandardErrorComplete
{
    // 分离处理输出和错误
    public class SeparateOutputAndError
    {
        public class ExecutionResult
        {
            public string Output { get; set; }
            public string Error { get; set; }
            public bool HasError => !string.IsNullOrEmpty(Error);
            public int ExitCode { get; set; }
        }
        
        public async Task<ExecutionResult> ExecuteWithSeparateStreams(string command)
        {
            var result = new ExecutionResult();
            var outputBuilder = new StringBuilder();
            var errorBuilder = new StringBuilder();
            
            var startInfo = new ProcessStartInfo
            {
                FileName = command,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                // 同时读取输出和错误（避免死锁）
                var outputTask = Task.Run(() =>
                {
                    string line;
                    while ((line = process.StandardOutput.ReadLine()) != null)
                    {
                        outputBuilder.AppendLine(line);
                    }
                });
                
                var errorTask = Task.Run(() =>
                {
                    string line;
                    while ((line = process.StandardError.ReadLine()) != null)
                    {
                        errorBuilder.AppendLine(line);
                    }
                });
                
                await Task.WhenAll(outputTask, errorTask);
                process.WaitForExit();
                
                result.Output = outputBuilder.ToString();
                result.Error = errorBuilder.ToString();
                result.ExitCode = process.ExitCode;
            }
            
            return result;
        }
    }
    
    // 合并输出和错误流
    public class MergedStreams
    {
        public void RedirectErrorToOutput()
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = "/c \"dir invalid_path & echo Done\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                var allOutput = new List<string>();
                
                // 使用相同的处理器处理输出和错误
                DataReceivedEventHandler handler = (s, e) =>
                {
                    if (e.Data != null)
                    {
                        allOutput.Add(e.Data);
                        Console.WriteLine(e.Data);
                    }
                };
                
                process.OutputDataReceived += handler;
                process.ErrorDataReceived += handler;
                
                process.BeginOutputReadLine();
                process.BeginErrorReadLine();
                
                process.WaitForExit();
            }
        }
        
        // 2>&1 风格的重定向
        public void UnixStyleRedirection()
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = "bash",
                Arguments = "-c \"command 2>&1\"", // 将stderr重定向到stdout
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                string combinedOutput = process.StandardOutput.ReadToEnd();
                process.WaitForExit();
                Console.WriteLine(combinedOutput);
            }
        }
    }
    
    // 错误流的特殊处理
    public class ErrorHandling
    {
        public enum OutputType
        {
            StandardOutput,
            StandardError
        }
        
        public class OutputLine
        {
            public string Text { get; set; }
            public OutputType Type { get; set; }
            public DateTime Timestamp { get; set; }
        }
        
        public async Task<List<OutputLine>> CaptureAllOutput(string command)
        {
            var output = new List<OutputLine>();
            var outputLock = new object();
            
            var startInfo = new ProcessStartInfo
            {
                FileName = command,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                process.OutputDataReceived += (s, e) =>
                {
                    if (e.Data != null)
                    {
                        lock (outputLock)
                        {
                            output.Add(new OutputLine
                            {
                                Text = e.Data,
                                Type = OutputType.StandardOutput,
                                Timestamp = DateTime.Now
                            });
                        }
                    }
                };
                
                process.ErrorDataReceived += (s, e) =>
                {
                    if (e.Data != null)
                    {
                        lock (outputLock)
                        {
                            output.Add(new OutputLine
                            {
                                Text = e.Data,
                                Type = OutputType.StandardError,
                                Timestamp = DateTime.Now
                            });
                        }
                        
                        // 特殊处理错误
                        LogError(e.Data);
                    }
                };
                
                process.BeginOutputReadLine();
                process.BeginErrorReadLine();
                
                await Task.Run(() => process.WaitForExit());
            }
            
            return output;
        }
        
        private void LogError(string error)
        {
            File.AppendAllText("errors.log", 
                $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {error}\n");
        }
    }
}
```

#### 1.4.5 编码处理

```csharp
public class EncodingHandling
{
    // 处理不同编码的输出
    public class EncodingExamples
    {
        public string ReadWithEncoding(string command, Encoding encoding)
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = command,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                StandardOutputEncoding = encoding, // 设置输出编码
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                string output = process.StandardOutput.ReadToEnd();
                process.WaitForExit();
                return output;
            }
        }
        
        // 自动检测编码
        public string ReadWithAutoDetection(string command)
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = command,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                // 读取原始字节
                var memoryStream = new MemoryStream();
                process.StandardOutput.BaseStream.CopyTo(memoryStream);
                byte[] bytes = memoryStream.ToArray();
                
                process.WaitForExit();
                
                // 检测编码
                Encoding encoding = DetectEncoding(bytes);
                return encoding.GetString(bytes);
            }
        }
        
        private Encoding DetectEncoding(byte[] bytes)
        {
            // 检查BOM
            if (bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF)
                return Encoding.UTF8;
            if (bytes.Length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE)
                return Encoding.Unicode;
            if (bytes.Length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF)
                return Encoding.BigEndianUnicode;
            
            // 默认使用系统编码
            return Encoding.Default;
        }
        
        // 处理多语言输出
        public void HandleMultilingualOutput()
        {
            var commands = new[]
            {
                new { Command = "chcp 65001 & echo 你好世界", Encoding = Encoding.UTF8 },
                new { Command = "chcp 936 & echo 你好世界", Encoding = Encoding.GetEncoding(936) }, // GBK
                new { Command = "echo Hello World", Encoding = Encoding.ASCII }
            };
            
            foreach (var cmd in commands)
            {
                var startInfo = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    Arguments = $"/c \"{cmd.Command}\"",
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    StandardOutputEncoding = cmd.Encoding,
                    CreateNoWindow = true
                };
                
                using (Process process = Process.Start(startInfo))
                {
                    string output = process.StandardOutput.ReadToEnd();
                    process.WaitForExit();
                    Console.WriteLine($"[{cmd.Encoding.EncodingName}] {output}");
                }
            }
        }
    }
}
```

#### 1.4.6 高级流操作技巧

```csharp
public class AdvancedStreamOperations
{
    // 1. 管道链式处理
    public class PipelineProcessor
    {
        public async Task<string> ExecutePipeline(params string[] commands)
        {
            Process previousProcess = null;
            Stream previousOutput = null;
            
            for (int i = 0; i < commands.Length; i++)
            {
                var startInfo = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    Arguments = $"/c {commands[i]}",
                    UseShellExecute = false,
                    RedirectStandardInput = i > 0,
                    RedirectStandardOutput = i < commands.Length - 1,
                    CreateNoWindow = true
                };
                
                var process = Process.Start(startInfo);
                
                if (previousOutput != null)
                {
                    // 连接前一个进程的输出到当前进程的输入
                    await previousOutput.CopyToAsync(process.StandardInput.BaseStream);
                    process.StandardInput.Close();
                    previousProcess?.WaitForExit();
                }
                
                if (i < commands.Length - 1)
                {
                    previousOutput = process.StandardOutput.BaseStream;
                    previousProcess = process;
                }
                else
                {
                    // 最后一个进程，读取输出
                    string result = await process.StandardOutput.ReadToEndAsync();
                    process.WaitForExit();
                    return result;
                }
            }
            
            return string.Empty;
        }
    }
    
    // 2. 超时控制的流读取
    public class TimeoutStreamReader
    {
        public async Task<string> ReadWithTimeout(Process process, int timeoutMs)
        {
            var outputBuilder = new StringBuilder();
            var cts = new CancellationTokenSource(timeoutMs);
            
            try
            {
                await Task.Run(async () =>
                {
                    char[] buffer = new char[4096];
                    while (!cts.Token.IsCancellationRequested)
                    {
                        var readTask = process.StandardOutput.ReadAsync(buffer, 0, buffer.Length);
                        var completedTask = await Task.WhenAny(
                            readTask,
                            Task.Delay(100, cts.Token)
                        );
                        
                        if (completedTask == readTask)
                        {
                            int read = await readTask;
                            if (read == 0) break;
                            outputBuilder.Append(buffer, 0, read);
                        }
                    }
                }, cts.Token);
            }
            catch (OperationCanceledException)
            {
                Console.WriteLine("读取超时");
            }
            
            return outputBuilder.ToString();
        }
    }
    
    // 3. 流的多路复用
    public class StreamMultiplexer
    {
        public event EventHandler<string> OutputReceived;
        public event EventHandler<string> ErrorReceived;
        public event EventHandler<string> CombinedReceived;
        
        public async Task MultiplexStreams(string command)
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = command,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                var outputTask = Task.Run(async () =>
                {
                    string line;
                    while ((line = await process.StandardOutput.ReadLineAsync()) != null)
                    {
                        OutputReceived?.Invoke(this, line);
                        CombinedReceived?.Invoke(this, $"[OUT] {line}");
                    }
                });
                
                var errorTask = Task.Run(async () =>
                {
                    string line;
                    while ((line = await process.StandardError.ReadLineAsync()) != null)
                    {
                        ErrorReceived?.Invoke(this, line);
                        CombinedReceived?.Invoke(this, $"[ERR] {line}");
                    }
                });
                
                await Task.WhenAll(outputTask, errorTask);
                process.WaitForExit();
            }
        }
    }
    
    // 4. 缓冲区管理
    public class BufferedStreamProcessor
    {
        private readonly int _bufferSize;
        private readonly Queue<string> _outputBuffer;
        private readonly int _maxBufferLines;
        
        public BufferedStreamProcessor(int bufferSize = 8192, int maxBufferLines = 1000)
        {
            _bufferSize = bufferSize;
            _maxBufferLines = maxBufferLines;
            _outputBuffer = new Queue<string>();
        }
        
        public async Task ProcessWithBuffer(string command)
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = command,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            };
            
            using (Process process = Process.Start(startInfo))
            {
                // 设置自定义缓冲区大小
                var reader = new StreamReader(
                    process.StandardOutput.BaseStream,
                    Encoding.UTF8,
                    true,
                    _bufferSize
                );
                
                string line;
                while ((line = await reader.ReadLineAsync()) != null)
                {
                    _outputBuffer.Enqueue(line);
                    
                    // 防止缓冲区过大
                    if (_outputBuffer.Count > _maxBufferLines)
                    {
                        await FlushBuffer();
                    }
                }
                
                // 处理剩余数据
                if (_outputBuffer.Count > 0)
                {
                    await FlushBuffer();
                }
                
                process.WaitForExit();
            }
        }
        
        private async Task FlushBuffer()
        {
            var batch = new List<string>();
            while (_outputBuffer.Count > 0)
            {
                batch.Add(_outputBuffer.Dequeue());
            }
            
            // 批量处理
            await ProcessBatch(batch);
        }
        
        private async Task ProcessBatch(List<string> lines)
        {
            // 批量写入文件或数据库
            await File.AppendAllLinesAsync("output.log", lines);
        }
    }
}
```

#### 1.4.7 常见问题和解决方案

```csharp
public class StreamProblemsAndSolutions
{
    // 1. 死锁问题及解决
    public class DeadlockPrevention
    {
        // 错误示例：可能导致死锁
        public void WrongWay()
        {
            var process = Process.Start(new ProcessStartInfo
            {
                FileName = "largeoutput.exe",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            });
            
            // 危险：如果错误输出缓冲区满了，进程会阻塞
            string output = process.StandardOutput.ReadToEnd();
            string error = process.StandardError.ReadToEnd();
            process.WaitForExit();
        }
        
        // 正确方式1：使用异步读取
        public async Task CorrectWayAsync()
        {
            var process = Process.Start(new ProcessStartInfo
            {
                FileName = "largeoutput.exe",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            });
            
            // 同时读取两个流
            var outputTask = process.StandardOutput.ReadToEndAsync();
            var errorTask = process.StandardError.ReadToEndAsync();
            
            await Task.WhenAll(outputTask, errorTask);
            process.WaitForExit();
            
            string output = outputTask.Result;
            string error = errorTask.Result;
        }
        
        // 正确方式2：使用BeginOutputReadLine
        public void CorrectWayEvents()
        {
            var process = Process.Start(new ProcessStartInfo
            {
                FileName = "largeoutput.exe",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            });
            
            var output = new StringBuilder();
            var error = new StringBuilder();
            
            process.OutputDataReceived += (s, e) => output.AppendLine(e.Data);
            process.ErrorDataReceived += (s, e) => error.AppendLine(e.Data);
            
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            
            process.WaitForExit();
        }
    }
    
    // 2. 处理无限输出的进程
    public class InfiniteOutputHandler
    {
        public async Task HandleInfiniteOutput(string command, CancellationToken cancellationToken)
        {
            var process = Process.Start(new ProcessStartInfo
            {
                FileName = command,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            });
            
            try
            {
                using (var reader = process.StandardOutput)
                {
                    char[] buffer = new char[4096];
                    while (!cancellationToken.IsCancellationRequested)
                    {
                        var readTask = reader.ReadAsync(buffer, 0, buffer.Length);
                        var delayTask = Task.Delay(100, cancellationToken);
                        
                        var completedTask = await Task.WhenAny(readTask, delayTask);
                        
                        if (completedTask == readTask)
                        {
                            int read = await readTask;
                            if (read == 0) break;
                            
                            // 处理数据
                            ProcessData(new string(buffer, 0, read));
                        }
                    }
                }
            }
            finally
            {
                if (!process.HasExited)
                {
                    process.Kill();
                    process.WaitForExit();
                }
            }
        }
        
        private void ProcessData(string data)
        {
            // 处理数据，避免内存累积
            Console.Write(data);
        }
    }
    
    // 3. 处理二进制输出
    public class BinaryOutputHandler
    {
        public async Task<byte[]> ReadBinaryOutput(string command)
        {
            var process = Process.Start(new ProcessStartInfo
            {
                FileName = command,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            });
            
            using (var memoryStream = new MemoryStream())
            {
                await process.StandardOutput.BaseStream.CopyToAsync(memoryStream);
                process.WaitForExit();
                return memoryStream.ToArray();
            }
        }
        
        public async Task ProcessBinaryStream(string command)
        {
            var process = Process.Start(new ProcessStartInfo
            {
                FileName = command,
                UseShellExecute = false,
                RedirectStandardOutput = true
            });
            
            using (var binaryReader = new BinaryReader(process.StandardOutput.BaseStream))
            {
                while (!process.HasExited)
                {
                    try
                    {
                        // 读取特定格式的二进制数据
                        int length = binaryReader.ReadInt32();
                        byte[] data = binaryReader.ReadBytes(length);
                        
                        await ProcessBinaryData(data);
                    }
                    catch (EndOfStreamException)
                    {
                        break;
                    }
                }
            }
            
            process.WaitForExit();
        }
        
        private async Task ProcessBinaryData(byte[] data)
        {
            // 处理二进制数据
            await Task.CompletedTask;
        }
    }
}
```

#### 1.4.8 实际应用示例

```csharp
public class RealWorldStreamExamples
{
    // 1. Git操作封装
    public class GitWrapper
    {
        public async Task<string> ExecuteGitCommand(string command, string workingDirectory)
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = "git",
                Arguments = command,
                WorkingDirectory = workingDirectory,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8
            };
            
            using (var process = Process.Start(startInfo))
            {
                var output = await process.StandardOutput.ReadToEndAsync();
                var error = await process.StandardError.ReadToEndAsync();
                
                process.WaitForExit();
                
                if (process.ExitCode != 0)
                {
                    throw new Exception($"Git command failed: {error}");
                }
                
                return output;
            }
        }
        
        public async Task<List<string>> GetChangedFiles(string workingDirectory)
        {
            var output = await ExecuteGitCommand("status --porcelain", workingDirectory);
            return output.Split('\n')
                .Where(line => !string.IsNullOrWhiteSpace(line))
                .Select(line => line.Substring(3))
                .ToList();
        }
    }
    
    // 2. 实时日志监控
    public class LogMonitor
    {
        public event EventHandler<LogEntry> LogReceived;
        
        public class LogEntry
        {
            public DateTime Timestamp { get; set; }
            public string Level { get; set; }
            public string Message { get; set; }
        }
        
        public async Task MonitorLogs(string command)
        {
            var process = Process.Start(new ProcessStartInfo
            {
                FileName = command,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            });
            
            await Task.Run(async () =>
            {
                string line;
                while ((line = await process.StandardOutput.ReadLineAsync()) != null)
                {
                    var entry = ParseLogEntry(line);
                    if (entry != null)
                    {
                        LogReceived?.Invoke(this, entry);
                    }
                }
            });
        }
        
        private LogEntry ParseLogEntry(string line)
        {
            // 解析日志格式: [2024-01-01 10:00:00] [INFO] Message
            var match = Regex.Match(line, @"\[(.*?)\] \[(.*?)\] (.*)");
            if (match.Success)
            {
                return new LogEntry
                {
                    Timestamp = DateTime.Parse(match.Groups[1].Value),
                    Level = match.Groups[2].Value,
                    Message = match.Groups[3].Value
                };
            }
            return null;
        }
    }
    
    // 3. 交互式Shell会话
    public class InteractiveShell
    {
        private Process _shellProcess;
        private StreamWriter _input;
        private TaskCompletionSource<string> _outputTcs;
        private StringBuilder _outputBuffer;
        
        public async Task StartShell()
        {
            _shellProcess = Process.Start(new ProcessStartInfo
            {
                FileName = "cmd.exe",
                UseShellExecute = false,
                RedirectStandardInput = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            });
            
            _input = _shellProcess.StandardInput;
            _outputBuffer = new StringBuilder();
            
            // 启动输出监听
            Task.Run(() => ReadOutput());
            Task.Run(() => ReadError());
        }
        
        public async Task<string> ExecuteCommand(string command)
        {
            _outputTcs = new TaskCompletionSource<string>();
            _outputBuffer.Clear();
            
            await _input.WriteLineAsync(command);
            await _input.FlushAsync();
            
            // 等待输出完成（使用超时）
            var timeout = Task.Delay(5000);
            var outputTask = _outputTcs.Task;
            
            var completed = await Task.WhenAny(outputTask, timeout);
            
            if (completed == timeout)
            {
                return _outputBuffer.ToString();
            }
            
            return await outputTask;
        }
        
        private async Task ReadOutput()
        {
            var reader = _shellProcess.StandardOutput;
            char[] buffer = new char[256];
            
            while (!_shellProcess.HasExited)
            {
                int read = await reader.ReadAsync(buffer, 0, buffer.Length);
                if (read > 0)
                {
                    string text = new string(buffer, 0, read);
                    _outputBuffer.Append(text);
                    
                    // 检测命令完成（简化版）
                    if (text.Contains(">"))
                    {
                        _outputTcs?.TrySetResult(_outputBuffer.ToString());
                    }
                }
            }
        }
        
        private async Task ReadError()
        {
            string line;
            while ((line = await _shellProcess.StandardError.ReadLineAsync()) != null)
            {
                _outputBuffer.AppendLine($"[ERROR] {line}");
            }
        }
        
        public void Dispose()
        {
            _input?.Close();
            if (!_shellProcess.HasExited)
            {
                _shellProcess.Kill();
            }
            _shellProcess?.Dispose();
        }
    }
}
```


## 二、ProcessStartInfo

### 2.1 所有属性详细说明

```csharp
public class ProcessStartInfoComplete
{
    public void ShowAllProperties()
    {
        ProcessStartInfo startInfo = new ProcessStartInfo();
        
        // ========== 1. 程序和参数 ==========
        startInfo.FileName = @"C:\Program Files\App\app.exe";  // 要执行的程序
        startInfo.Arguments = "-arg1 value1 -arg2 value2";     // 命令行参数
        startInfo.ArgumentList.Add("-arg3");                    // .NET Core 2.1+ 参数列表
        startInfo.ArgumentList.Add("value3");
        
        // ========== 2. 工作环境 ==========
        startInfo.WorkingDirectory = @"C:\WorkDir";             // 工作目录
        startInfo.Verb = "runas";                               // 操作动词(runas=管理员,open,print等)
        
        // ========== 3. 环境变量 ==========
        startInfo.UseShellExecute = false;                      // 必须为false才能修改环境变量
        startInfo.EnvironmentVariables["MY_VAR"] = "value";     // 添加/修改环境变量
        startInfo.EnvironmentVariables.Remove("TEMP");          // 删除环境变量
        startInfo.Environment["NEW_VAR"] = "value";             // .NET Core方式
        
        // ========== 4. 窗口和显示 ==========
        startInfo.WindowStyle = ProcessWindowStyle.Normal;       // 窗口样式
        // Normal - 正常窗口
        // Hidden - 隐藏窗口
        // Minimized - 最小化
        // Maximized - 最大化
        
        startInfo.CreateNoWindow = false;                       // 是否创建窗口
        startInfo.ErrorDialog = true;                           // 启动失败时显示错误对话框
        startInfo.ErrorDialogParentHandle = IntPtr.Zero;        // 错误对话框的父窗口句柄
        
        // ========== 5. Shell执行 ==========
        startInfo.UseShellExecute = true;                       // 是否使用操作系统Shell启动
        // true: 可以打开文档、URL，使用Verb
        // false: 可以重定向I/O，需要指定可执行文件
        
        // ========== 6. I/O重定向 (需要UseShellExecute = false) ==========
        startInfo.RedirectStandardInput = true;                 // 重定向标准输入
        startInfo.RedirectStandardOutput = true;                // 重定向标准输出  
        startInfo.RedirectStandardError = true;                 // 重定向标准错误
        startInfo.StandardInputEncoding = Encoding.UTF8;        // 标准输入编码
        startInfo.StandardOutputEncoding = Encoding.UTF8;       // 标准输出编码
        startInfo.StandardErrorEncoding = Encoding.UTF8;        // 标准错误编码
        
        // ========== 7. 用户凭据 (需要UseShellExecute = false) ==========
        startInfo.UserName = "username";                        // 用户名
        startInfo.Domain = "DOMAIN";                            // 域
        startInfo.PasswordInClearText = "password";             // 明文密码（不安全）
        
        // 安全密码
        System.Security.SecureString securePassword = new System.Security.SecureString();
        foreach (char c in "password")
        {
            securePassword.AppendChar(c);
        }
        securePassword.MakeReadOnly();
        startInfo.Password = securePassword;                    // 安全密码
        
        startInfo.LoadUserProfile = true;                       // 是否加载用户配置文件
        
        // ========== 8. 文件关联 ==========
        startInfo.UseShellExecute = true;                       // 必须为true
        startInfo.FileName = "document.pdf";                    // 可以是文档
        startInfo.FileName = "https://www.example.com";         // 可以是URL
    }
}
```

### 2.2 高级配置示例

```csharp
public class AdvancedProcessStartInfo
{
    // 示例1：完整的进程启动配置
    public Process StartProcessAdvanced()
    {
        ProcessStartInfo startInfo = new ProcessStartInfo
        {
            FileName = "git.exe",
            Arguments = "status",
            WorkingDirectory = @"C:\MyRepo",
            
            // 环境配置
            UseShellExecute = false,
            CreateNoWindow = true,
            WindowStyle = ProcessWindowStyle.Hidden,
            
            // I/O重定向
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            RedirectStandardInput = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8,
            
            // 环境变量
            // 清空现有环境变量并设置新的
        };
        
        // 配置环境变量
        startInfo.EnvironmentVariables.Clear();
        startInfo.EnvironmentVariables["PATH"] = @"C:\Git\bin";
        startInfo.EnvironmentVariables["HOME"] = @"C:\Users\User";
        
        Process process = new Process
        {
            StartInfo = startInfo,
            EnableRaisingEvents = true
        };
        
        // 配置事件处理
        process.OutputDataReceived += (s, e) => Console.WriteLine($"输出: {e.Data}");
        process.ErrorDataReceived += (s, e) => Console.WriteLine($"错误: {e.Data}");
        process.Exited += (s, e) => Console.WriteLine("进程已退出");
        
        process.Start();
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();
        
        return process;
    }
    
    // 示例2：不同场景的启动配置
    public class StartInfoScenarios
    {
        // 场景1：打开网页
        public void OpenWebPage(string url)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = url,
                UseShellExecute = true
            });
        }
        
        // 场景2：打开文件夹
        public void OpenFolder(string path)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "explorer.exe",
                Arguments = path
            });
        }
        
        // 场景3：使用默认程序打开文件
        public void OpenFileWithDefaultProgram(string filePath)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = filePath,
                UseShellExecute = true
            });
        }
        
        // 场景4：以管理员身份运行
        public void RunAsAdmin(string exePath)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = exePath,
                UseShellExecute = true,
                Verb = "runas"
            });
        }
        
        // 场景5：隐藏执行
        public void RunHidden(string command)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/c {command}",
                WindowStyle = ProcessWindowStyle.Hidden,
                CreateNoWindow = true,
                UseShellExecute = false
            });
        }
    }
}
```

## 三、实战应用场景

### 3.1 进程管理器实现

```csharp
public class ProcessManager
{
    private readonly Dictionary<int, ProcessInfo> _processCache = new();
    private readonly Timer _refreshTimer;
    
    public class ProcessInfo
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public long MemoryUsage { get; set; }
        public double CpuUsage { get; set; }
        public DateTime StartTime { get; set; }
        public int ThreadCount { get; set; }
        public ProcessPriorityClass Priority { get; set; }
        public string Status { get; set; }
        public TimeSpan LastCpuTime { get; set; }
        public DateTime LastCheckTime { get; set; }
    }
    
    public ProcessManager()
    {
        _refreshTimer = new Timer(RefreshProcessInfo, null, 0, 1000);
    }
    
    private void RefreshProcessInfo(object state)
    {
        var processes = Process.GetProcesses();
        var currentTime = DateTime.Now;
        
        foreach (var process in processes)
        {
            try
            {
                if (!_processCache.TryGetValue(process.Id, out var info))
                {
                    info = new ProcessInfo
                    {
                        Id = process.Id,
                        LastCheckTime = currentTime
                    };
                    _processCache[process.Id] = info;
                }
                
                // 更新进程信息
                info.Name = process.ProcessName;
                info.MemoryUsage = process.WorkingSet64;
                info.ThreadCount = process.Threads.Count;
                info.Priority = process.PriorityClass;
                info.Status = process.Responding ? "响应" : "未响应";
                
                // 计算CPU使用率
                var currentCpuTime = process.TotalProcessorTime;
                var timeDiff = currentTime - info.LastCheckTime;
                
                if (timeDiff.TotalMilliseconds > 0)
                {
                    var cpuTimeDiff = currentCpuTime - info.LastCpuTime;
                    info.CpuUsage = cpuTimeDiff.TotalMilliseconds / 
                                    timeDiff.TotalMilliseconds / 
                                    Environment.ProcessorCount * 100;
                }
                
                info.LastCpuTime = currentCpuTime;
                info.LastCheckTime = currentTime;
                info.StartTime = process.StartTime;
            }
            catch (Exception ex)
            {
                // 某些系统进程可能无法访问
                Console.WriteLine($"无法访问进程 {process.Id}: {ex.Message}");
            }
        }
        
        // 清理已退出的进程
        var exitedProcessIds = _processCache.Keys
            .Except(processes.Select(p => p.Id))
            .ToList();
        
        foreach (var id in exitedProcessIds)
        {
            _processCache.Remove(id);
        }
    }
    
    public List<ProcessInfo> GetTopMemoryProcesses(int count = 10)
    {
        return _processCache.Values
            .OrderByDescending(p => p.MemoryUsage)
            .Take(count)
            .ToList();
    }
    
    public List<ProcessInfo> GetTopCpuProcesses(int count = 10)
    {
        return _processCache.Values
            .OrderByDescending(p => p.CpuUsage)
            .Take(count)
            .ToList();
    }
    
    public void KillProcess(int processId, bool killTree = false)
    {
        try
        {
            var process = Process.GetProcessById(processId);
            if (killTree && Environment.OSVersion.Version.Major >= 10)
            {
                // Windows 10+ 支持终止进程树
                KillProcessTree(process);
            }
            else
            {
                process.Kill();
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"终止进程失败: {ex.Message}");
        }
    }
    
    private void KillProcessTree(Process parent)
    {
        var children = GetChildProcesses(parent.Id);
        foreach (var child in children)
        {
            KillProcessTree(child);
        }
        parent.Kill();
    }
    
    private List<Process> GetChildProcesses(int parentId)
    {
        var children = new List<Process>();
        var allProcesses = Process.GetProcesses();
        
        // 使用WMI获取父子关系（需要添加System.Management引用）
        // 这里简化处理
        return children;
    }
}
```

### 3.2 命令执行器（支持超时和取消）

```csharp
public class CommandExecutor
{
    public class ExecutionResult
    {
        public string Output { get; set; }
        public string Error { get; set; }
        public int ExitCode { get; set; }
        public bool TimedOut { get; set; }
        public bool Cancelled { get; set; }
        public TimeSpan ExecutionTime { get; set; }
    }
    
    public async Task<ExecutionResult> ExecuteAsync(
        string command,
        string arguments = null,
        string workingDirectory = null,
        int timeoutMs = 30000,
        CancellationToken cancellationToken = default)
    {
        var result = new ExecutionResult();
        var startTime = DateTime.Now;
        var outputBuilder = new StringBuilder();
        var errorBuilder = new StringBuilder();
        
        var startInfo = new ProcessStartInfo
        {
            FileName = command,
            Arguments = arguments ?? string.Empty,
            WorkingDirectory = workingDirectory ?? Directory.GetCurrentDirectory(),
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8
        };
        
        using var process = new Process { StartInfo = startInfo };
        using var outputCompleted = new TaskCompletionSource<bool>();
        using var errorCompleted = new TaskCompletionSource<bool>();
        
        process.OutputDataReceived += (sender, e) =>
        {
            if (e.Data == null)
            {
                outputCompleted.TrySetResult(true);
            }
            else
            {
                outputBuilder.AppendLine(e.Data);
            }
        };
        
        process.ErrorDataReceived += (sender, e) =>
        {
            if (e.Data == null)
            {
                errorCompleted.TrySetResult(true);
            }
            else
            {
                errorBuilder.AppendLine(e.Data);
            }
        };
        
        try
        {
            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            
            // 创建超时和取消的组合token
            using var timeoutCts = new CancellationTokenSource(timeoutMs);
            using var linkedCts = CancellationTokenSource
                .CreateLinkedTokenSource(cancellationToken, timeoutCts.Token);
            
            // 等待进程退出
            var processTask = Task.Run(() => process.WaitForExit(), linkedCts.Token);
            var outputTask = outputCompleted.Task;
            var errorTask = errorCompleted.Task;
            
            try
            {
                await Task.WhenAll(processTask, outputTask, errorTask)
                    .ConfigureAwait(false);
                
                result.ExitCode = process.ExitCode;
            }
            catch (OperationCanceledException)
            {
                if (timeoutCts.IsCancellationRequested && !cancellationToken.IsCancellationRequested)
                {
                    result.TimedOut = true;
                }
                else
                {
                    result.Cancelled = true;
                }
                
                // 终止进程
                if (!process.HasExited)
                {
                    process.Kill(true); // 终止进程树
                }
            }
            
            result.Output = outputBuilder.ToString();
            result.Error = errorBuilder.ToString();
            result.ExecutionTime = DateTime.Now - startTime;
            
            return result;
        }
        catch (Exception ex)
        {
            result.Error = ex.ToString();
            result.ExitCode = -1;
            result.ExecutionTime = DateTime.Now - startTime;
            return result;
        }
    }
    
    // 便捷方法：执行PowerShell命令
    public async Task<ExecutionResult> ExecutePowerShellAsync(
        string script,
        int timeoutMs = 30000,
        CancellationToken cancellationToken = default)
    {
        return await ExecuteAsync(
            "powershell.exe",
            $"-NoProfile -ExecutionPolicy Bypass -Command \"{script}\"",
            null,
            timeoutMs,
            cancellationToken);
    }
    
    // 便捷方法：执行CMD命令
    public async Task<ExecutionResult> ExecuteCmdAsync(
        string command,
        int timeoutMs = 30000,
        CancellationToken cancellationToken = default)
    {
        return await ExecuteAsync(
            "cmd.exe",
            $"/c {command}",
            null,
            timeoutMs,
            cancellationToken);
    }
}
```

### 3.3 进程间通信（IPC）实现

```csharp
public class ProcessCommunication
{
    // 使用命名管道进行进程间通信
    public class NamedPipeServer
    {
        private readonly string _pipeName;
        private readonly Process _clientProcess;
        
        public NamedPipeServer(string pipeName)
        {
            _pipeName = pipeName;
        }
        
        public async Task StartServerAsync()
        {
            using var pipeServer = new NamedPipeServerStream(
                _pipeName,
                PipeDirection.InOut,
                1,
                PipeTransmissionMode.Message,
                PipeOptions.Asynchronous);
            
            // 启动客户端进程
            _clientProcess = Process.Start(new ProcessStartInfo
            {
                FileName = "ClientApp.exe",
                Arguments = _pipeName,
                UseShellExecute = false
            });
            
            // 等待客户端连接
            await pipeServer.WaitForConnectionAsync();
            
            // 通信
            using var reader = new StreamReader(pipeServer);
            using var writer = new StreamWriter(pipeServer) { AutoFlush = true };
            
            await writer.WriteLineAsync("Hello from server");
            var response = await reader.ReadLineAsync();
            Console.WriteLine($"收到客户端消息: {response}");
        }
    }
    
    // 使用标准输入输出进行通信
    public class StdIOCommunication
    {
        private Process _childProcess;
        private StreamWriter _stdin;
        private StreamReader _stdout;
        private StreamReader _stderr;
        
        public void StartChildProcess(string exePath)
        {
            _childProcess = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = exePath,
                    UseShellExecute = false,
                    RedirectStandardInput = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                }
            };
            
            _childProcess.Start();
            
            _stdin = _childProcess.StandardInput;
            _stdout = _childProcess.StandardOutput;
            _stderr = _childProcess.StandardError;
        }
        
        public async Task<string> SendCommandAsync(string command)
        {
            await _stdin.WriteLineAsync(command);
            return await _stdout.ReadLineAsync();
        }
        
        public void Cleanup()
        {
            _stdin?.Close();
            _stdout?.Close();
            _stderr?.Close();
            
            if (!_childProcess.HasExited)
            {
                _childProcess.Kill();
            }
            
            _childProcess?.Dispose();
        }
    }
}
```

### 3.4 批处理执行器

```csharp
public class BatchProcessor
{
    public class BatchCommand
    {
        public string Command { get; set; }
        public string Arguments { get; set; }
        public string WorkingDirectory { get; set; }
        public int TimeoutMs { get; set; } = 30000;
        public bool ContinueOnError { get; set; } = false;
        public Dictionary<string, string> EnvironmentVariables { get; set; }
    }
    
    public class BatchResult
    {
        public List<CommandResult> Results { get; set; } = new();
        public bool Success { get; set; }
        public TimeSpan TotalExecutionTime { get; set; }
    }
    
    public class CommandResult
    {
        public string Command { get; set; }
        public string Output { get; set; }
        public string Error { get; set; }
        public int ExitCode { get; set; }
        public bool Success { get; set; }
        public TimeSpan ExecutionTime { get; set; }
    }
    
    public async Task<BatchResult> ExecuteBatchAsync(
        List<BatchCommand> commands,
        int maxParallel = 1,
        IProgress<string> progress = null)
    {
        var batchResult = new BatchResult();
        var startTime = DateTime.Now;
        
        if (maxParallel > 1)
        {
            // 并行执行
            await ExecuteParallelAsync(commands, maxParallel, batchResult, progress);
        }
        else
        {
            // 串行执行
            await ExecuteSequentialAsync(commands, batchResult, progress);
        }
        
        batchResult.TotalExecutionTime = DateTime.Now - startTime;
        batchResult.Success = batchResult.Results.All(r => r.Success);
        
        return batchResult;
    }
    
    private async Task ExecuteSequentialAsync(
        List<BatchCommand> commands,
        BatchResult batchResult,
        IProgress<string> progress)
    {
        foreach (var command in commands)
        {
            progress?.Report($"执行: {command.Command} {command.Arguments}");
            
            var result = await ExecuteCommandAsync(command);
            batchResult.Results.Add(result);
            
            if (!result.Success && !command.ContinueOnError)
            {
                progress?.Report($"命令失败，停止执行: {command.Command}");
                break;
            }
        }
    }
    
    private async Task ExecuteParallelAsync(
        List<BatchCommand> commands,
        int maxParallel,
        BatchResult batchResult,
        IProgress<string> progress)
    {
        using var semaphore = new SemaphoreSlim(maxParallel);
        var tasks = commands.Select(async command =>
        {
            await semaphore.WaitAsync();
            try
            {
                progress?.Report($"开始执行: {command.Command}");
                var result = await ExecuteCommandAsync(command);
                lock (batchResult.Results)
                {
                    batchResult.Results.Add(result);
                }
                progress?.Report($"完成: {command.Command}");
                return result;
            }
            finally
            {
                semaphore.Release();
            }
        });
        
        await Task.WhenAll(tasks);
    }
    
    private async Task<CommandResult> ExecuteCommandAsync(BatchCommand command)
    {
        var startTime = DateTime.Now;
        var result = new CommandResult
        {
            Command = $"{command.Command} {command.Arguments}"
        };
        
        var startInfo = new ProcessStartInfo
        {
            FileName = command.Command,
            Arguments = command.Arguments,
            WorkingDirectory = command.WorkingDirectory ?? Directory.GetCurrentDirectory(),
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        };
        
        // 设置环境变量
        if (command.EnvironmentVariables != null)
        {
            foreach (var kvp in command.EnvironmentVariables)
            {
                startInfo.EnvironmentVariables[kvp.Key] = kvp.Value;
            }
        }
        
        try
        {
            using var process = Process.Start(startInfo);
            using var outputTask = process.StandardOutput.ReadToEndAsync();
            using var errorTask = process.StandardError.ReadToEndAsync();
            
            var completed = process.WaitForExit(command.TimeoutMs);
            
            if (!completed)
            {
                process.Kill();
                result.Error = "命令执行超时";
                result.Success = false;
            }
            else
            {
                result.Output = await outputTask;
                result.Error = await errorTask;
                result.ExitCode = process.ExitCode;
                result.Success = process.ExitCode == 0;
            }
        }
        catch (Exception ex)
        {
            result.Error = ex.ToString();
            result.Success = false;
        }
        
        result.ExecutionTime = DateTime.Now - startTime;
        return result;
    }
}
```

### 3.5 服务包装器

```csharp
public class ServiceWrapper
{
    private Process _serviceProcess;
    private readonly string _servicePath;
    private readonly string _serviceName;
    private bool _isRunning;
    private readonly object _lock = new object();
    
    public event EventHandler<string> OutputReceived;
    public event EventHandler<string> ErrorReceived;
    public event EventHandler ServiceStopped;
    
    public ServiceWrapper(string servicePath, string serviceName)
    {
        _servicePath = servicePath;
        _serviceName = serviceName;
    }
    
    public void Start(string arguments = null)
    {
        lock (_lock)
        {
            if (_isRunning)
            {
                throw new InvalidOperationException("服务已在运行");
            }
            
            var startInfo = new ProcessStartInfo
            {
                FileName = _servicePath,
                Arguments = arguments ?? string.Empty,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true,
                WorkingDirectory = Path.GetDirectoryName(_servicePath)
            };
            
            _serviceProcess = new Process
            {
                StartInfo = startInfo,
                EnableRaisingEvents = true
            };
            
            // 配置事件处理
            _serviceProcess.OutputDataReceived += (s, e) =>
            {
                if (!string.IsNullOrEmpty(e.Data))
                {
                    OutputReceived?.Invoke(this, e.Data);
                    LogToFile($"[OUTPUT] {e.Data}");
                }
            };
            
            _serviceProcess.ErrorDataReceived += (s, e) =>
            {
                if (!string.IsNullOrEmpty(e.Data))
                {
                    ErrorReceived?.Invoke(this, e.Data);
                    LogToFile($"[ERROR] {e.Data}");
                }
            };
            
            _serviceProcess.Exited += (s, e) =>
            {
                _isRunning = false;
                ServiceStopped?.Invoke(this, EventArgs.Empty);
                LogToFile($"[INFO] 服务已停止，退出代码: {_serviceProcess.ExitCode}");
                
                // 自动重启逻辑
                if (AutoRestart && _serviceProcess.ExitCode != 0)
                {
                    Task.Delay(RestartDelay).ContinueWith(_ => Restart());
                }
            };
            
            _serviceProcess.Start();
            _serviceProcess.BeginOutputReadLine();
            _serviceProcess.BeginErrorReadLine();
            
            _isRunning = true;
            LogToFile($"[INFO] 服务已启动，PID: {_serviceProcess.Id}");
        }
    }
    
    public bool AutoRestart { get; set; } = false;
    public TimeSpan RestartDelay { get; set; } = TimeSpan.FromSeconds(5);
    
    public void Stop(int timeoutMs = 5000)
    {
        lock (_lock)
        {
            if (!_isRunning || _serviceProcess == null)
            {
                return;
            }
            
            try
            {
                // 首先尝试优雅关闭
                if (_serviceProcess.CloseMainWindow())
                {
                    if (_serviceProcess.WaitForExit(timeoutMs))
                    {
                        LogToFile("[INFO] 服务已优雅关闭");
                        return;
                    }
                }
                
                // 强制终止
                _serviceProcess.Kill();
                _serviceProcess.WaitForExit(timeoutMs);
                LogToFile("[WARNING] 服务被强制终止");
            }
            catch (Exception ex)
            {
                LogToFile($"[ERROR] 停止服务时出错: {ex.Message}");
            }
            finally
            {
                _isRunning = false;
                _serviceProcess?.Dispose();
                _serviceProcess = null;
            }
        }
    }
    
    public void Restart()
    {
        Stop();
        Thread.Sleep(1000); // 等待资源释放
        Start();
    }
    
    public bool IsRunning
    {
        get
        {
            lock (_lock)
            {
                return _isRunning && _serviceProcess != null && !_serviceProcess.HasExited;
            }
        }
    }
    
    public ProcessInfo GetInfo()
    {
        if (!IsRunning)
        {
            return null;
        }
        
        _serviceProcess.Refresh();
        
        return new ProcessInfo
        {
            Id = _serviceProcess.Id,
            Name = _serviceProcess.ProcessName,
            MemoryUsage = _serviceProcess.WorkingSet64,
            StartTime = _serviceProcess.StartTime,
            ThreadCount = _serviceProcess.Threads.Count
        };
    }
    
    private void LogToFile(string message)
    {
        var logFile = Path.Combine(
            Path.GetDirectoryName(_servicePath),
            $"{_serviceName}_{DateTime.Now:yyyyMMdd}.log");
            
        File.AppendAllText(logFile, $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} {message}\n");
    }
    
    public class ProcessInfo
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public long MemoryUsage { get; set; }
        public DateTime StartTime { get; set; }
        public int ThreadCount { get; set; }
    }
}
```

## 四、平台差异和兼容性

### 4.1 跨平台注意事项

```csharp
public class CrossPlatformProcess
{
    public static void ExecuteCommand(string command)
    {
        ProcessStartInfo startInfo;
        
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            startInfo = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/c {command}",
                UseShellExecute = false
            };
        }
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
        {
            startInfo = new ProcessStartInfo
            {
                FileName = "/bin/bash",
                Arguments = $"-c \"{command}\"",
                UseShellExecute = false
            };
        }
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
        {
            startInfo = new ProcessStartInfo
            {
                FileName = "/bin/zsh",
                Arguments = $"-c \"{command}\"",
                UseShellExecute = false
            };
        }
        else
        {
            throw new PlatformNotSupportedException();
        }
        
        using var process = Process.Start(startInfo);
        process.WaitForExit();
    }
    
    // 平台特定的进程查找
    public static string FindExecutable(string name)
    {
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            // Windows: 搜索PATH和常见位置
            var paths = Environment.GetEnvironmentVariable("PATH").Split(';');
            var extensions = new[] { ".exe", ".bat", ".cmd" };
            
            foreach (var path in paths)
            {
                foreach (var ext in extensions)
                {
                    var fullPath = Path.Combine(path, name + ext);
                    if (File.Exists(fullPath))
                    {
                        return fullPath;
                    }
                }
            }
        }
        else
        {
            // Unix-like: 使用which命令
            var process = Process.Start(new ProcessStartInfo
            {
                FileName = "which",
                Arguments = name,
                UseShellExecute = false,
                RedirectStandardOutput = true
            });
            
            var output = process.StandardOutput.ReadToEnd().Trim();
            process.WaitForExit();
            
            if (process.ExitCode == 0 && !string.IsNullOrEmpty(output))
            {
                return output;
            }
        }
        
        return null;
    }
}
```

## 五、性能优化和最佳实践

### 5.1 性能优化技巧

```csharp
public class ProcessPerformanceOptimization
{
    // 1. 使用对象池避免频繁创建
    public class ProcessPool
    {
        private readonly ConcurrentBag<Process> _pool = new();
        private readonly ProcessStartInfo _template;
        
        public ProcessPool(ProcessStartInfo template)
        {
            _template = template;
        }
        
        public Process Rent()
        {
            if (_pool.TryTake(out var process))
            {
                return process;
            }
            
            return new Process { StartInfo = _template };
        }
        
        public void Return(Process process)
        {
            if (process.HasExited)
            {
                process.Dispose();
                return;
            }
            
            // 重置进程状态
            process.CancelOutputRead();
            process.CancelErrorRead();
            _pool.Add(process);
        }
    }
    
    // 2. 批量处理减少系统调用
    public class BatchProcessManager
    {
        private readonly List<Process> _processes = new();
        private readonly Timer _batchTimer;
        
        public BatchProcessManager()
        {
            _batchTimer = new Timer(ProcessBatch, null, 1000, 1000);
        }
        
        private void ProcessBatch(object state)
        {
            Process[] snapshot;
            lock (_processes)
            {
                snapshot = _processes.ToArray();
            }
            
            // 批量刷新进程信息
            Parallel.ForEach(snapshot, process =>
            {
                try
                {
                    process.Refresh();
                }
                catch { }
            });
        }
    }
    
    // 3. 缓存进程信息
    public class CachedProcessInfo
    {
        private readonly MemoryCache _cache = new MemoryCache(new MemoryCacheOptions
        {
            SizeLimit = 1000
        });
        
        public async Task<T> GetProcessInfoAsync<T>(int processId, Func<Process, T> selector)
        {
            var cacheKey = $"{processId}_{typeof(T).Name}";
            
            if (_cache.TryGetValue(cacheKey, out T cached))
            {
                return cached;
            }
            
            var process = Process.GetProcessById(processId);
            var value = selector(process);
            
            _cache.Set(cacheKey, value, new MemoryCacheEntryOptions
            {
                Size = 1,
                SlidingExpiration = TimeSpan.FromSeconds(5)
            });
            
            return value;
        }
    }
}
```

### 5.2 安全性最佳实践

```csharp
public class SecureProcessExecution
{
    // 1. 输入验证
    public void ExecuteSecure(string command, string[] allowedCommands)
    {
        if (!allowedCommands.Contains(command))
        {
            throw new SecurityException($"不允许执行命令: {command}");
        }
        
        // 防止命令注入
        if (command.Contains("&") || command.Contains("|") || 
            command.Contains(";") || command.Contains("`"))
        {
            throw new SecurityException("检测到潜在的命令注入");
        }
        
        Process.Start(command);
    }
    
    // 2. 使用受限权限运行
    public void RunWithLimitedPrivileges(string command)
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = command,
            UseShellExecute = false,
            LoadUserProfile = false,
            // 设置较低的进程优先级
        };
        
        using var process = new Process { StartInfo = startInfo };
        process.PriorityClass = ProcessPriorityClass.BelowNormal;
        process.Start();
    }
    
    // 3. 安全的密码处理
    public void RunWithSecureCredentials(string command, string username, SecureString password)
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = command,
            UserName = username,
            Password = password,  // 使用SecureString
            UseShellExecute = false,
            LoadUserProfile = true
        };
        
        Process.Start(startInfo);
    }
}
```

## 六、故障排除和调试

### 6.1 常见问题和解决方案

```csharp
public class ProcessTroubleshooting
{
    // 1. 处理访问被拒绝
    public bool TryGetProcessInfo(int processId, out string info)
    {
        info = null;
        try
        {
            var process = Process.GetProcessById(processId);
            info = $"{process.ProcessName} - {process.MainWindowTitle}";
            return true;
        }
        catch (ArgumentException)
        {
            info = "进程不存在";
            return false;
        }
        catch (InvalidOperationException)
        {
            info = "进程已退出";
            return false;
        }
        catch (System.ComponentModel.Win32Exception ex) when (ex.NativeErrorCode == 5)
        {
            info = "访问被拒绝";
            return false;
        }
        catch (Exception ex)
        {
            info = $"未知错误: {ex.Message}";
            return false;
        }
    }
    
    // 2. 处理死锁问题
    public async Task<string> ExecuteWithoutDeadlock(string command)
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = command,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true
        };
        
        using var process = Process.Start(startInfo);
        
        // 避免死锁：同时读取输出和错误
        var outputTask = process.StandardOutput.ReadToEndAsync();
        var errorTask = process.StandardError.ReadToEndAsync();
        
        await Task.WhenAll(outputTask, errorTask);
        process.WaitForExit();
        
        return outputTask.Result;
    }
    
    // 3. 诊断进程启动失败
    public void DiagnoseStartupFailure(string command)
    {
        try
        {
            // 检查文件是否存在
            if (!File.Exists(command))
            {
                Console.WriteLine($"文件不存在: {command}");
                return;
            }
            
            // 检查文件权限
            var fileInfo = new FileInfo(command);
            Console.WriteLine($"文件属性: {fileInfo.Attributes}");
            
            // 尝试不同的启动方式
            var methods = new[]
            {
                new { UseShell = true, Description = "使用Shell" },
                new { UseShell = false, Description = "不使用Shell" }
            };
            
            foreach (var method in methods)
            {
                try
                {
                    var startInfo = new ProcessStartInfo
                    {
                        FileName = command,
                        UseShellExecute = method.UseShell
                    };
                    
                    Process.Start(startInfo);
                    Console.WriteLine($"成功: {method.Description}");
                    break;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"失败 ({method.Description}): {ex.Message}");
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"诊断失败: {ex}");
        }
    }
}
```

## 七、总结

Process和ProcessStartInfo类是C#中处理进程的核心工具，掌握它们的使用对于系统编程、自动化和进程管理至关重要。关键要点：

1. **正确的资源管理**：始终使用using语句或手动Dispose
2. **异步操作**：避免阻塞主线程，使用异步方法
3. **错误处理**：充分的异常处理和错误恢复机制
4. **安全性**：验证输入，使用最小权限原则
5. **跨平台**：考虑不同操作系统的差异
6. **性能**：合理使用缓存和批处理

通过合理运用这些类和技术，可以构建强大、高效和可靠的进程管理解决方案。
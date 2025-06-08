# Python `asyncio` 模块详解

`asyncio` 是 Python 中用于编写并发代码的库，它使用 `async/await` 语法。`asyncio` 被用作各种 Python 异步框架的基础，提供了高性能的网络和 Web 服务器、数据库连接库、分布式任务队列等等。

`asyncio` 非常适合 I/O 密集型任务和高层级的结构化网络代码。

## 1. 什么是 `asyncio`？

`asyncio` 是一个通过在单线程内管理多个“任务”（协程）来实现并发的库。它不使用多线程或多进程，而是依赖于一个**事件循环 (Event Loop)** 来协调这些任务的执行。当一个任务遇到 I/O 操作（例如等待网络响应或文件读写）时，事件循环会暂停该任务，并切换到另一个准备好运行的任务，而不是阻塞整个线程。

**核心组件：**

- **事件循环 (Event Loop):**`asyncio` 的核心，负责调度和执行异步任务、处理 I/O 事件和回调。
- **协程 (Coroutines):** 使用 `async def` 定义的特殊函数。协程是可以暂停和恢复执行的函数。它们是 `asyncio` 中并发的基本单位。
- `**async**` **和** `**await**` **关键字:**

- `async`: 用于定义一个协程函数或异步生成器。
- `await`: 用于暂停协程的执行，直到等待的异步操作完成。它只能在 `async def` 函数内部使用。

- **任务 (Tasks):** 用于调度协程在事件循环中并发执行。`Task` 对象是对协程的封装。
- **Future 对象:** 一个特殊的低层级可等待对象，表示一个异步操作的最终结果。`Task` 是 `Future` 的一个子类。

## 2. 为什么使用 `asyncio`？

- **高并发性:**`asyncio` 可以在单个线程中处理成千上万的并发连接，这对于需要处理大量并发 I/O 操作的应用程序（如 Web 服务器、聊天应用）非常有用。
- **I/O 密集型任务优化:** 对于那些大部分时间都在等待外部操作（如网络请求、数据库查询）完成的任务，`asyncio` 可以显著提高效率，因为它允许程序在等待期间执行其他任务。
- **避免线程开销:** 与多线程相比，`asyncio` 的协程切换开销更小，并且避免了线程同步带来的复杂性（如锁竞争、死锁）。
- **清晰的异步代码:**`async/await` 语法使得异步代码的编写和阅读更加直观，类似于同步代码的结构。

## 3. `asyncio` 的核心概念与用法

### 3.1. `async` 和 `await`

这是 `asyncio` 的基石。

- `**async def**`: 定义一个协程函数。调用协程函数不会立即执行它，而是返回一个协程对象。
- `**await**`: 只能用在 `async def` 函数内部。`await` 后面通常跟一个可等待对象 (awaitable object)，例如另一个协程、一个 `Task` 或一个 `Future`。当解释器遇到 `await` 时，它会暂停当前协程的执行，让事件循环去处理其他任务，直到 `await` 等待的操作完成。

```python
import asyncio
import time

async def say_after(delay, what):
    await asyncio.sleep(delay)  # asyncio.sleep 是一个异步函数，模拟 I/O 操作
    print(what)
    return f"{what} done"

async def main():
    print(f"开始于 {time.strftime('%X')}")

    # 调用协程函数返回一个协程对象
    coro1 = say_after(1, 'hello')
    coro2 = say_after(2, 'world')

    # 使用 await 来执行协程并等待其完成
    # 注意：直接 await 协程对象是可以的，但通常我们会用 Task 来并发执行
    result1 = await coro1
    result2 = await coro2
    
    print(result1)
    print(result2)

    print(f"结束于 {time.strftime('%X')}")

# Python 3.7+ 可以直接使用 asyncio.run()
if __name__ == "__main__":
    asyncio.run(main())
```

在上面的例子中，`say_after(1, 'hello')` 会先执行，`await asyncio.sleep(1)` 使其暂停1秒。然后 `say_after(2, 'world')` 会执行，`await asyncio.sleep(2)` 使其暂停2秒。因为是顺序 `await`，所以总耗时约3秒。

### 3.2. 事件循环 (Event Loop)

事件循环是 `asyncio` 应用的核心。它执行以下操作：

- 运行异步任务和回调。
- 执行网络 IO 操作。
- 执行子进程。

`**asyncio.run()**` **(推荐方式):** 在 Python 3.7 及更高版本中，`asyncio.run(coroutine)` 是运行顶层入口点协程（通常是 `main` 函数）的推荐方式。它负责获取事件循环、运行任务直到完成，并关闭事件循环。

```python
# (如上例所示)
# if __name__ == "__main__":
#     asyncio.run(main())
```

**手动管理事件循环 (旧版或特定场景):**

```python
# async def main():
#     # ...
#     pass

# loop = asyncio.get_event_loop()
# try:
#     loop.run_until_complete(main())
# finally:
#     loop.close() # 不再需要手动关闭，asyncio.run() 会处理
```

通常情况下，你不需要手动与事件循环交互，`asyncio.run()` 会为你处理大部分事情。

### 3.3. 任务 (Tasks)

`Task` 用于在事件循环中并发地调度协程。当你将一个协程包装成一个 `Task` 时，事件循环就可以管理它的执行。

`**asyncio.create_task()**` **(推荐方式):** 在 Python 3.7 及更高版本中，使用 `asyncio.create_task(coro)` 来创建任务。

```python
import asyncio
import time

async def say_after(delay, what):
    await asyncio.sleep(delay)
    print(what)
    return f"{what} processed"

async def main():
    print(f"开始于 {time.strftime('%X')}")

    # 创建任务，任务会立即开始调度（但不是立即执行完毕）
    task1 = asyncio.create_task(say_after(1, 'hello'))
    task2 = asyncio.create_task(say_after(2, 'world'))

    # 等待任务完成并获取结果
    # await 会暂停 main 协程，直到 task1 完成
    result1 = await task1 
    print(f"Task 1 返回: {result1}")
    
    # await 会暂停 main 协程，直到 task2 完成
    result2 = await task2
    print(f"Task 2 返回: {result2}")

    print(f"结束于 {time.strftime('%X')}")

if __name__ == "__main__":
    asyncio.run(main())
```

在这个例子中，`task1` 和 `task2` 会并发执行。`say_after(1, 'hello')` 和 `say_after(2, 'world')` 会几乎同时开始。`task1` 在1秒后完成，`task2` 在2秒后完成。总耗时约2秒，而不是顺序执行的3秒。

### 3.4. `asyncio.gather()`

`asyncio.gather(*aws, return_exceptions=False)` 用于并发运行多个可等待对象（协程、任务或 Future）。它会等待所有提供的可等待对象完成后返回结果。

````python
import asyncio
import time

async def factorial(name, number):
    f = 1
    for i in range(2, number + 1):
        print(f"Task {name}: 计算 factorial({i})...")
        await asyncio.sleep(0.1) # 模拟耗时计算
        f *= i
    print(f"Task {name}: factorial({number}) = {f}")
    return f

async def main():
    print(f"开始于 {time.strftime('%X')}")
    # 使用 gather 并发运行多个协程
    # gather 会自动将协程包装成 Task
    results = await asyncio.gather(
        factorial("A", 2),
        factorial("B", 3),
        factorial("C", 4),
    )
    print(f"所有任务完成于 {time.strftime('%X')}")
    print(f"结果: {results}") # results 是一个包含各协程返回值的列表

if __name__ == "__main__":
    asyncio.run(main())
```gather` 的结果是一个列表，包含了所有输入协程的返回值，顺序与输入顺序一致。如果 `return_exceptions=True`，则异常会作为结果返回，而不是引发。

### 3.5. `asyncio.wait()`

`asyncio.wait(aws, timeout=None, return_when=ALL_COMPLETED)` 是一个更低层级的函数，用于等待一组可等待对象完成。它返回两个 `Task`/`Future` 集合：已完成的和未完成的。

* `return_when`:
    * `asyncio.FIRST_COMPLETED`: 当任何一个可等待对象完成时返回。
    * `asyncio.FIRST_EXCEPTION`: 当任何一个可等待对象引发异常时返回。如果没有异常，则行为类似 `ALL_COMPLETED`。
    * `asyncio.ALL_COMPLETED`: (默认) 当所有可等待对象都完成时返回。

```python
import asyncio

async def my_coro(delay, name):
    await asyncio.sleep(delay)
    print(f"{name} 完成")
    return f"{name} result"

async def main():
    coros = [my_coro(1, "Task 1"), my_coro(3, "Task 2"), my_coro(0.5, "Task 3")]
    tasks = [asyncio.create_task(coro) for coro in coros]

    # 等待所有任务完成
    done, pending = await asyncio.wait(tasks)
    
    print("所有任务完成:")
    for task in done:
        print(f" - {task.result()}") # 获取任务结果
    
    # 等待第一个任务完成
    # tasks = [asyncio.create_task(coro) for coro in coros] # 重新创建，因为之前的已完成
    # done_first, pending_first = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
    # print("\n第一个完成的任务:")
    # for task in done_first:
    #     print(f" - {task.result()}")
    # for task in pending_first: # 取消未完成的任务
    #     task.cancel()

if __name__ == "__main__":
    asyncio.run(main())
```gather` 通常比 `wait` 更易用，因为它直接返回结果列表。`wait` 提供了对已完成和未完成任务更细致的控制。

### 3.6. Futures

`Future` 对象代表一个最终会产生结果的异步操作。它是一个可等待对象。`Task` 是 `Future` 的一个子类，专门用于运行协程。

通常你不需要直接创建 `Future` 对象，除非你在编写基于回调的底层代码并希望将其与 `async/await` 集成。

```python
import asyncio

async def set_after(fut, delay, value):
    await asyncio.sleep(delay)
    fut.set_result(value) # 设置 Future 的结果

async def main():
    loop = asyncio.get_running_loop() # Python 3.7+
    fut = loop.create_future() # 创建一个 Future 对象

    # 调度一个协程来设置 Future 的结果
    asyncio.create_task(set_after(fut, 1, '... Future 结果 ...'))

    print('等待 Future...')
    result = await fut # 等待 Future 完成并获取结果
    print(result)

if __name__ == "__main__":
    asyncio.run(main())
````

## 4. 高级特性 (简述)

### 4.1. 同步原语 (Synchronization Primitives)

当多个协程需要协调对共享资源的访问时，`asyncio` 提供了类似于 `threading` 模块的同步原语：

- `**asyncio.Lock**`: 互斥锁，一次只允许一个协程获取锁。
- `**asyncio.Event**`: 一个简单的事件标志，协程可以等待事件被设置，或者设置/清除事件。
- `**asyncio.Condition**`: 条件变量，允许一个或多个协程等待某个条件成立。
- `**asyncio.Semaphore**`: 信号量，控制对资源的并发访问数量。
- `**asyncio.BoundedSemaphore**`: 有界信号量，与 `Semaphore` 类似，但 `release()` 次数不能超过 `acquire()` 次数。

```python
import asyncio

lock = asyncio.Lock()
shared_resource = 0

async def worker(worker_id):
    global shared_resource
    print(f"Worker {worker_id} 尝试获取锁")
    async with lock: # 自动获取和释放锁
        print(f"Worker {worker_id} 已获取锁")
        current_val = shared_resource
        await asyncio.sleep(0.1) # 模拟一些工作
        shared_resource = current_val + 1
        print(f"Worker {worker_id} 释放锁, shared_resource = {shared_resource}")

async def main():
    await asyncio.gather(*(worker(i) for i in range(5)))
    print(f"最终 shared_resource = {shared_resource}")

if __name__ == "__main__":
    asyncio.run(main())
```

### 4.2. 队列 (`asyncio.Queue`)

`asyncio.Queue` 用于在协程之间安全地传递数据，实现了生产者-消费者模式。

- `put(item)`: 将元素放入队列。如果队列已满，则阻塞直到有空间。
- `get()`: 从队列中获取元素。如果队列为空，则阻塞直到有元素。
- `task_done()`: 表示之前 `get()` 的任务已完成。
- `join()`: 阻塞直到队列中所有元素都被获取并处理（即每个 `put()` 都有对应的 `task_done()`）。

```python
import asyncio
import random

async def producer(queue, n_items):
    for i in range(n_items):
        item = f"项目-{i}"
        await asyncio.sleep(random.uniform(0.1, 0.5)) # 模拟生产耗时
        await queue.put(item)
        print(f"生产者: 已生产 {item}")
    await queue.put(None) # 发送结束信号

async def consumer(queue, consumer_id):
    while True:
        item = await queue.get()
        if item is None: # 收到结束信号
            queue.task_done() # 标记结束信号已处理
            await queue.put(None) # 将结束信号传递给其他消费者 (如果需要)
            print(f"消费者 {consumer_id}: 收到结束信号, 退出")
            break
        print(f"消费者 {consumer_id}: 正在处理 {item}")
        await asyncio.sleep(random.uniform(0.2, 1.0)) # 模拟消费耗时
        print(f"消费者 {consumer_id}: 已处理 {item}")
        queue.task_done()

async def main():
    queue = asyncio.Queue(maxsize=5) # 设置队列最大容量
    
    producers = [asyncio.create_task(producer(queue, 10))]
    consumers = [asyncio.create_task(consumer(queue, i)) for i in range(2)]

    await asyncio.gather(*producers) # 等待生产者完成
    print("所有生产者已完成生产。")
    
    await queue.join() # 等待所有队列中的项目被处理
    print("所有项目已处理。消费者即将退出。")

    # gather 消费者以确保它们都正确退出 (可选，因为 join 已经保证了任务完成)
    await asyncio.gather(*consumers)


if __name__ == "__main__":
    asyncio.run(main())
```

### 4.3. 子进程 (`asyncio.create_subprocess_exec`, `asyncio.create_subprocess_shell`)

`asyncio` 允许以异步方式运行和管理子进程。

- `create_subprocess_exec()`: 执行一个可执行文件。
- `create_subprocess_shell()`: 通过 shell 执行命令 (注意安全风险)。

```python
import asyncio

async def run_command():
    # 执行 'ls -l' 命令
    # 注意：在 Windows 上，'ls' 不是标准命令，可以使用 'dir'
    # 为了跨平台，这里用一个简单的 echo 示例
    try:
        # process = await asyncio.create_subprocess_exec(
        #     'ls', '-l', '/', # Unix/Linux/macOS
        #     stdout=asyncio.subprocess.PIPE,
        #     stderr=asyncio.subprocess.PIPE
        # )
        
        # 更跨平台的示例
        process = await asyncio.create_subprocess_exec(
            'python', '-c', 'import time; time.sleep(1); print("来自子进程的输出")',
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        stdout, stderr = await process.communicate() # 等待子进程完成

        if stdout:
            print(f"[标准输出]:\n{stdout.decode()}")
        if stderr:
            print(f"[标准错误]:\n{stderr.decode()}")
        
        print(f"子进程退出码: {process.returncode}")

    except FileNotFoundError:
        print("错误: 命令未找到。请确保命令在您的 PATH 中，或提供完整路径。")
    except Exception as e:
        print(f"运行命令时发生错误: {e}")


if __name__ == "__main__":
    asyncio.run(run_command())
```

### 4.4. 流 (Streams)

Streams API 用于处理网络连接 (TCP, UDP, SSL/TLS, etc.)。它提供了高层级的 `async/await` 接口来发送和接收数据。

- `asyncio.open_connection(host, port)`: 创建一个 TCP 连接，返回 `(reader, writer)` 对。
- `asyncio.start_server(client_connected_cb, host, port)`: 启动一个 TCP 服务器。

```python
import asyncio

async def handle_echo_client(reader, writer):
    addr = writer.get_extra_info('peername')
    print(f"收到来自 {addr} 的连接")

    while True:
        data = await reader.read(100) # 读取最多100字节
        if not data: # 连接关闭
            break
        
        message = data.decode()
        print(f"从 {addr} 收到: {message!r}")
        
        writer.write(data) # 回显数据
        await writer.drain() # 等待写入缓冲区清空

    print(f"关闭来自 {addr} 的连接")
    writer.close()
    await writer.wait_closed() # Python 3.7+

async def main_server():
    server = await asyncio.start_server(
        handle_echo_client, '127.0.0.1', 8888)

    addr = server.sockets[0].getsockname()
    print(f'服务器正在监听 {addr}')

    async with server: # 确保服务器正确关闭
        await server.serve_forever()

# 客户端示例 (可以单独运行或集成)
async def tcp_echo_client(message):
    try:
        reader, writer = await asyncio.open_connection('127.0.0.1', 8888)
        print(f'发送: {message!r}')
        writer.write(message.encode())
        await writer.drain()

        data = await reader.read(100)
        print(f'收到: {data.decode()!r}')

        print('关闭连接')
        writer.close()
        await writer.wait_closed()
    except ConnectionRefusedError:
        print("连接被拒绝。请确保服务器正在运行。")

if __name__ == "__main__":
    # 要运行服务器，取消注释下一行并注释掉客户端部分
    # asyncio.run(main_server())
    
    # 要运行客户端示例 (需要服务器先运行)
    asyncio.run(tcp_echo_client('你好, asyncio 服务器!'))
    asyncio.run(tcp_echo_client('这是第二条消息。'))
```

## 5. 常见陷阱与最佳实践

- **不要在协程中调用阻塞的 I/O 操作:** 标准的阻塞 I/O 函数（如 `time.sleep()`, `requests.get()`, 标准文件操作）会阻塞整个事件循环，使 `asyncio` 失去并发优势。

- **解决方法:** 使用 `asyncio` 提供的异步版本（如 `asyncio.sleep()`），或使用像 `aiohttp` (用于 HTTP 请求)、`aiofiles` (用于文件操作) 这样的异步库。对于无法避免的阻塞代码，可以使用 `loop.run_in_executor()` 将其放到单独的线程池中执行。

- **正确处理任务异常:** 如果一个 `Task` 抛出未处理的异常，且该异常没有被 `await` 该任务的代码捕获，它可能会在任务被垃圾回收时打印出来，或者在某些情况下导致程序行为异常。

- **解决方法:** 始终 `await` 你创建的任务，或使用 `asyncio.gather(..., return_exceptions=True)`，并检查结果。或者为任务添加 `done_callback` 来处理异常。

- **理解** `**asyncio.run()**` **与手动循环管理:**`asyncio.run()` 是启动和关闭 `asyncio` 程序的首选方式。它会自动处理事件循环的创建和销毁。避免在 `asyncio.run()` 调用的协程内部再次调用 `asyncio.run()`。
- **取消任务 (Cancellation):** 任务可以被取消。被取消的任务会在其 `await` 点抛出 `asyncio.CancelledError`。协程应该捕获此异常以执行清理操作。

```python
async def my_task():
    try:
        while True:
            print("任务运行中...")
            await asyncio.sleep(1)
    except asyncio.CancelledError:
        print("任务被取消，正在清理...")
        # 执行清理操作
        raise # 重新抛出 CancelledError 很重要

# task = asyncio.create_task(my_task())
# await asyncio.sleep(3)
# task.cancel()
# try:
#     await task
# except asyncio.CancelledError:
#     print("主协程捕获到任务取消")
```

- **合理使用** `**gather**` **vs** `**wait**`**:**

- `gather`: 当你需要所有任务的结果，并且希望它们并发执行时，`gather` 通常更方便。
- `wait`: 当你需要更细粒度的控制，例如等待第一个任务完成或出现第一个异常时，`wait` 更合适。

## 6. 何时使用 `asyncio` (以及何时不使用)

**适合使用** `**asyncio**` **的场景:**

- **I/O 密集型应用:** 网络服务器、Web Scrapers、数据库客户端、消息队列等，这些应用花费大量时间等待网络或磁盘 I/O。
- **高并发需求:** 需要同时处理大量连接或请求的应用。
- **需要与其他异步库集成:** 许多现代 Python 库都支持 `asyncio`。

**可能不适合或需要谨慎使用** `**asyncio**` **的场景:**

- **CPU 密集型任务:** 对于主要由计算而非 I/O 限制的任务，`asyncio` 的单线程模型可能无法提供性能优势。在这种情况下，多进程 (`multiprocessing` 模块) 通常是更好的选择，因为它能利用多核 CPU。
- **项目中已有大量同步阻塞代码:** 将现有的大型同步项目转换为异步可能非常耗时且容易出错。可以考虑逐步引入，或使用 `run_in_executor` 桥接。
- **简单的脚本或任务:** 对于不需要高并发的简单脚本，引入 `asyncio` 的复杂性可能没有必要。

## 总结

`asyncio` 是 Python 中一个强大且灵活的库，用于构建高性能的并发应用程序。通过 `async/await` 语法，它提供了一种编写和维护异步代码的优雅方式。理解其核心概念，如事件循环、协程、任务和同步原语，对于有效地利用 `asyncio` 至关重要。虽然它主要针对 I/O 密集型任务，但通过与其他技术的结合（如多进程），也可以构建出复杂的混合型应用。

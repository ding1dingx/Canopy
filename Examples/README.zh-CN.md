# Canopy 可扩展性示例

Canopy 的 Tree 架构完全可扩展，支持集成任何日志服务。

---

## 快速开始

### 1. Xlog 集成

```swift
import Canopy
import Xlog  // 腾讯 Mars Xlog SDK

// 初始化 Xlog
let xlog = ...  // 你的 Xlog 实例

// 创建并种植 XlogTree
let xlogTree = XlogTree(xlog: xlog, flushInterval: 60)
Canopy.plant(xlogTree)

// 所有日志会自动通过 Xlog 高性能写入
Canopy.i("This will be logged by Xlog")
```

### 2. Sentry 错误追踪

```swift
import Canopy
import Sentry

// 初始化 Sentry
SentrySDK.start { options in
    options.dsn = "your_sentry_dsn"
}

// 创建并种植 SentryTree
let sentryTree = SentryTree(
    sentry: SentrySDK.shared,
    minLevel: .error  // 只记录 error 及以上
)
Canopy.plant(sentryTree)

// Error 会自动发送到 Sentry
Canopy.e("Critical error", error: someError)
```

### 3. 远程日志服务（批量 + 重试 + 采样）

```swift
import Canopy

// 配置远程日志
let config = RemoteLogTree.Configuration(
    endpoint: URL(string: "https://your-log-service.com/logs")!,
    apiKey: "your_api_key",
    batchSize: 50,              // 50 条日志批量上传
    flushInterval: 30,            // 30 秒定时刷新
    retryCount: 3,               // 失败重试 3 次
    retryDelay: 5,                // 重试延迟 5 秒
    samplingRate: 0.1            // 10% 采样率（info/debug）
)

let remoteLogTree = RemoteLogTree(config: config, minLevel: .info)
Canopy.plant(remoteLogTree)

// 日志会批量、带重试、采样地发送到远程服务
Canopy.i("This will be batched and sent with retry")
```

### 4. 组合使用多个 Tree

```swift
Canopy.plant(
    DebugTree(),              // Debug 模式控制台输出
    XlogTree(xlog: xlog),     // 高性能本地存储
    SentryTree(sentry: sentry), // 自动发送 error 到 Sentry
    RemoteLogTree(config: config) // 远程日志服务
)

// 一个日志调用会经过所有 Tree
Canopy.e("Database connection failed", error: error)
// → 控制台输出（Debug 模式）
// → Xlog 存储（本地）
// → Sentry 上报（error）
// → 远程服务上传（批量）
```

### 5. 高级组合：异步 + 错误上报

```swift
let asyncRemoteTree = AsyncTree(wrapping: RemoteLogTree(config: config))
Canopy.plant(asyncRemoteTree)

// 日志会在后台线程异步发送，不阻塞调用者
for i in 0..<10000 {
    Canopy.i("Log entry \(i)")  // 不会阻塞主线程
}
```

---

## Release 模式最佳实践

### 只记录重要日志

```swift
#if DEBUG
Canopy.plant(DebugTree())
#endif

// Release 模式只记录 error+
let sentryTree = SentryTree(sentry: sentry, minLevel: .error)
Canopy.plant(sentryTree)

// 使用 tag 添加上下文
Canopy.tag("PaymentGateway").e("Transaction failed", error: error)
```

### 分级记录到不同服务

```swift
// Verbose/Debug → Xlog 本地存储
let xlogTree = XlogTree(xlog: xlog)
xlogTree.minLevel = .verbose
Canopy.plant(xlogTree)

// Warning/Error → Sentry 上报
let sentryTree = SentryTree(sentry: sentry)
sentryTree.minLevel = .warning
Canopy.plant(sentryTree)

// Error → 远程服务实时上报
let errorRemoteTree = RemoteLogTree(config: errorConfig)
errorRemoteTree.minLevel = .error
Canopy.plant(errorRemoteTree)
```

---

## 高级特性

### 采样控制

```swift
// 只记录 10% 的 info/debug 日志，但记录 100% 的 warning/error
let config = RemoteLogTree.Configuration(
    endpoint: endpoint,
    samplingRate: 0.1  // 10% 采样
)
```

### 批量上传

```swift
// 累积 100 条日志后批量上传
let config = RemoteLogTree.Configuration(
    endpoint: endpoint,
    batchSize: 100,
    flushInterval: 60  // 或者 60 秒定时刷新
)
```

### 网络重试

```swift
// 网络失败时自动重试 3 次，指数退避
let config = RemoteLogTree.Configuration(
    endpoint: endpoint,
    retryCount: 3,
    retryDelay: 5  // 5s → 10s → 20s
)
```

---

## 自定义 Tree 模板

### 基础模板

```swift
open class MyCustomTree: Tree {
    override func log(
        priority: LogLevel,
        tag: String?,
        message: String,
        error: Error?
    ) {
        // 实现你的日志逻辑
        // 1. 处理 error（如果存在）
        var fullMessage = message
        if let err = error {
            fullMessage += " | Error: \(err.localizedDescription)"
            // 你还可以捕获 error 详情用于结构化日志
            // sendErrorTracking(err)
        }

        // 2. 格式化日志
        let formatted = formatLog(priority, tag, fullMessage)

        // 3. 发送到服务
        sendToService(formatted)

        // 4. 本地缓存（可选）
        cacheLocally(formatted)
    }
}
```

### 带缓冲和批量的模板

```swift
open class BatchedTree: Tree {
    private var buffer: [String] = []
    private let maxBatchSize: Int

    override func log(...) {
        buffer.append(formattedMessage)

        if buffer.count >= maxBatchSize {
            flush()
        }
    }

    private func flush() {
        // 批量发送 buffer 中的日志
        sendBatch(buffer)
        buffer.removeAll()
    }
}
```

### 带重试的模板

```swift
open class RetryTree: Tree {
    private func sendWithRetry(_ data: Data) {
        var retryCount = 0
        while retryCount < maxRetries {
            if send(data) {
                break  // 成功，退出重试
            }
            retryCount += 1
            Thread.sleep(forTimeInterval: retryDelay * pow(2, retryCount))
        }
    }
}
```

---

## 性能考虑

### 1. 使用 AsyncTree 避免阻塞

```swift
// 所有远程日志都应使用 AsyncTree 包装
let asyncRemoteTree = AsyncTree(wrapping: RemoteLogTree(config: config))
Canopy.plant(asyncRemoteTree)
```

### 2. 合理设置批量大小

```swift
// 太小 → 频繁网络请求
batchSize: 10  // 太频繁

// 太大 → 内存占用和延迟
batchSize: 1000  // 延迟高

// 推荐
batchSize: 50-100  // 平衡
```

### 3. 使用采样降低负载

```swift
// 生产环境推荐采样
#if DEBUG
let samplingRate = 1.0      // Debug: 100%
#else
let samplingRate = 0.1      // Release: 10%
#endif
```

---

## 安全考虑

### 1. 敏感信息过滤

```swift
override func log(...) {
    let sanitized = sanitize(message)  // 移除密码、token 等敏感信息
    super.log(...)
}

private func sanitize(_ message: String) -> String {
    message
        .replacingOccurrences(of: "password=\\S+", with: "password=***", options: .regularExpression)
        .replacingOccurrences(of: "token=\\S+", with: "token=***", options: .regularExpression)
}
```

### 2. 加密传输

```swift
private func sendLogs(_ logs: [String]) {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"

    // 加密日志
    let encrypted = encrypt(logs)
    request.httpBody = encrypted

    // HTTPS 传输
    request.setValue("application/encrypted", forHTTPHeaderField: "Content-Type")
}
```

---

## 总结

### Canopy 的可扩展性：

✅ **完全可自定义** - 继承 `Tree` 即可实现任何功能  
✅ **多 Tree 组合** - 同时使用多个日志服务  
✅ **灵活过滤** - 每个 Tree 独立的 `minLevel`  
✅ **性能优化** - `AsyncTree` 避免阻塞  
✅ **高级特性** - 批量、重试、采样都支持  

### 需要你自己实现的部分：

- ❌ 具体的日志服务集成（Xlog、Sentry 等）
- ❌ 网络发送逻辑
- ❌ 批量、重试、采样算法
- ❌ 本地存储策略

**Canopy 提供了架构和基础设施，你需要根据具体需求实现业务逻辑。**

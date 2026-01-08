# Canopy

> 🌲 树冠覆盖森林，全面洞察你的 App。

轻量级、高性能的 iOS 日志框架，灵感来自 Android 的 Timber。

## 特性

- **Tree 架构** - 通过可插拔的 Tree 灵活配置日志
- **性能优化** - Release 模式下如果只用 `DebugTree` 则零开销
- **iOS 14+ 支持** - 仅使用 Swift 标准库和 Foundation
- **无外部依赖** - 纯 Swift 实现
- **线程安全** - 锁保护的并发访问
- **全面测试** - 91 个测试用例，包含性能基准测试

## 快速开始

使用 Swift Package Manager 或 CocoaPods 将 Canopy 添加到你的项目：

```bash
# Swift Package Manager
dependencies: [
    .package(url: "https://github.com/ding1dingx/Canopy.git", from: "0.1.0")
]

# CocoaPods
pod 'Canopy', '~> 0.1.0'
```

在 `AppDelegate` 中初始化：

```swift
#if DEBUG
Canopy.plant(DebugTree())
#endif
Canopy.plant(CrashBufferTree(maxSize: 100))

// 在应用任何地方使用
Canopy.v("Verbose message")
Canopy.d("Debug message")
Canopy.i("Info message")
Canopy.w("Warning message")
Canopy.e("Error message")

// 带标签（线程安全）
Canopy.v("Network request", tag: "Network")
```

## 工作原理

### Debug 模式

- 所有日志都会打印到控制台

### Release 模式

- `DebugTree` 的日志**不会**打印
- 其他 Tree（如 `CrashBufferTree`）的日志**仍然**会打印
- 如果只种了 `DebugTree`，Release 构建中**零开销**

## 日志级别

| 方法 | 级别 | 用途 |
|------|------|------|
| `Canopy.v()` | Verbose | 详细诊断信息 |
| `Canopy.d()` | Debug | 开发调试信息 |
| `Canopy.i()` | Info | 一般信息 |
| `Canopy.w()` | Warning | 潜在问题 |
| `Canopy.e()` | Error | 错误和失败 |

## Tree 类型

### DebugTree

只在 Debug 模式打印日志到控制台。

```swift
Canopy.plant(DebugTree())
```

### CrashBufferTree

在内存中保存最近的日志。崩溃时保存到文件用于分析。

```swift
let crashTree = CrashBufferTree(maxSize: 100)
Canopy.plant(crashTree)

// 稍后获取日志
let logs = crashTree.recentLogs()
```

**使用场景：** 非常适合 Release 模式 - 即使控制台日志关闭也能保留崩溃日志。

### AsyncTree

包装任意 Tree，在后台队列记录日志，不阻塞调用者。

```swift
let asyncTree = AsyncTree(wrapping: crashTree)
Canopy.plant(asyncTree)
```

### 自定义 Tree

通过继承 `Tree` 创建自己的 Tree：

```swift
public final class FileTree: Tree {
    override func log(priority: LogLevel, tag: String?, message: String, error: Error?) {
        // 写入文件
    }
}
```

## 带标签的日志

为日志添加上下文：

```swift
Canopy.tag("Network").i("API 请求开始")
Canopy.tag("Database").w("检测到慢查询")
Canopy.tag("Analytics").v("事件已追踪：page_view")
```

## 演示应用

内置演示展示所有 Canopy 功能：

| 按钮 | 功能 |
|------|------|
| Verbose/Debug/Info/Warning/Error | 不同日志级别演示 |
| Format Log | 字符串格式化 |
| Tagged Log | 基于上下文的日志 |
| Async Log | 异步日志 |
| View Crash Buffer | 显示缓冲日志 |

**运行演示：**

1. 在 Xcode 中打开项目
2. 选择 iOS 14.0+ 模拟器或真机
3. Build 并运行
4. 在 Xcode Console（⌘⇧Y）中查看日志

## 要求

- iOS 14.0+
- Swift 5.0+
- Xcode 12.0+

## 最佳实践

### 1. 使用适当的日志级别

```swift
// ✅ 正确：生产环境使用适当级别
func processData(_ data: Data) {
    Canopy.d("Processing \(data.count) bytes")  // 只在 Debug 构建中生效
}

// ❌ 避免：生产环境过度使用 verbose 日志
func processData(_ data: Data) {
    Canopy.v("Step 1: Starting")
    Canopy.v("Step 2: Parsing")
    Canopy.v("Step 3: Validating")
    Canopy.v("Step 4: Saving")
}
```

### 2. 利用 @autoclosure 提高性能

```swift
// ✅ 正确：懒加载字符串
Canopy.d("Processing item: \(itemName)")  // 只有日志启用时才构建字符串

// ✅ 更好：使用格式化参数（无字符串插值）
Canopy.d("Processing item: %@", itemName)

// ❌ 避免：总是构建字符串（有性能开销）
Canopy.d("Processing item: " + itemName)
```

### 3. 对昂贵操作使用 AsyncTree

```swift
// ✅ 正确：用 AsyncTree 包装昂贵操作
let crashTree = CrashBufferTree(maxSize: 100)
let asyncCrashTree = AsyncTree(wrapping: crashTree)
Canopy.plant(asyncCrashTree)

// 日志不会阻塞调用线程
Canopy.d("User logged in")
```

### 4. 使用标签进行上下文日志记录

```swift
// ✅ 正确：使用标签添加上下文
class NetworkManager {
    private let tag = "Network"

    func makeRequest() {
        Canopy.tag(tag).i("Starting request to \(url)")
    }

    func handleResponse() {
        Canopy.tag(tag).i("Received response: \(statusCode)")
    }
}

// ✅ 最佳：使用 CanopyContext.with() 实现自动作用域上下文管理
func fetchUserData(userId: String) {
    CanopyContext.with("API") {
        Canopy.i("Fetching user data")
        Canopy.i("Request started for user: %@", userId)
        // 退出时自动恢复上下文
    }
}

// ✅ 正确：CanopyContext.with() 支持嵌套作用域
func processOrder() {
    CanopyContext.with("OrderService") {
        Canopy.i("Processing order")

        CanopyContext.with("Payment") {
            Canopy.i("Processing payment")
            // 这里使用 "Payment" 标签
        }

        // 这里恢复为 "OrderService" 标签
        Canopy.i("Order completed")
    }
}

// ❌ 避免：手动管理上下文（容易出错）
func pushView(_ viewController: UIViewController) {
    CanopyContext.push(viewController: viewController)
    Canopy.i("View displayed")
    CanopyContext.current = nil  // 容易忘记！
}
```

### 5. Release 模式配置

```swift
// ✅ 推荐：生产环境最小化日志
#if DEBUG
Canopy.plant(DebugTree())
#endif

// 即使在 release 环境也保留崩溃日志
let crashTree = CrashBufferTree(maxSize: 100)
Canopy.plant(crashTree)

// 可选：为错误添加远程日志
#if !DEBUG
let sentryTree = SentryTree(sentry: sentry, minLevel: .error)
Canopy.plant(sentryTree)
#endif
```

### 6. 避免常见陷阱

```swift
// ❌ 避免：日志中的字符串拼接
Canopy.d("User: " + username + " logged in")

// ❌ 避免：日志中使用 String.format（可能导致崩溃）
Canopy.d(String.format("URL is %s", url))

// ✅ 正确：使用 Canopy 内置格式化
Canopy.d("User %@ logged in", username)
Canopy.d("URL is %@", url)

// ❌ 避免：记录敏感数据
Canopy.d("Password: %@", password)

// ✅ 正确：清理或省略敏感数据
Canopy.d("User %@ logged in (password hidden)", username)
```

## 性能分析

### 基准测试结果

来自 `CanopyBenchmarkTests` 在 Apple Silicon M3（macOS 14）上的性能测量：

| 操作 | 操作数 | 平均时间 | 每次操作 | 备注 |
|------|--------|----------|----------|------|
| 日志调用（无参数） | 10,000 | ~2ms | ~200ns | 基准日志调用 |
| 日志调用（单参数） | 10,000 | ~20ms | ~2μs | 带字符串格式化 |
| 日志调用（多参数） | 10,000 | ~57ms | ~5.7μs | 3 个格式说明符 |
| 仅格式化消息 | 10,000 | ~1ms | ~100ns | 无日志开销 |
| Canopy API（无 tree） | 1,000 | ~3ms | ~3μs | 未种植 trees |
| Canopy API（DebugTree） | 1,000 | ~4ms | ~4μs | 已种植 DebugTree |
| Canopy 带标签参数 | 1,000 | ~4ms | ~4μs | 线程安全标签 |
| AsyncTree（1,000 日志） | 1,000 | ~10ms | ~10μs | 后台队列 |
| 并发日志 | 10,000 | ~100ms | ~10μs | 10 线程 × 1,000 |
| 并发带标签日志 | 10,000 | ~110ms | ~11μs | 4 标签，10 线程 |
| CrashBufferTree（1,000 日志） | 1,000 | ~20ms | ~20ns | 缓冲区操作 |

> **注意**：结果会因设备和 iOS 版本而异。运行 `swift test --filter CanopyBenchmarkTests` 来对您的环境进行基准测试。

### 内存影响

| 组件 | 内存占用 |
|------|----------|
| Canopy 核心 | ~5KB |
| DebugTree | ~2KB |
| CrashBufferTree（100 条日志） | ~10KB |
| AsyncTree 开销 | ~1KB |

### Release 模式优化

| 场景 | Debug 模式 | Release 模式 |
|------|------------|--------------|
| 日志调用开销 | ~200ns | 0ns（空操作） |
| 字符串格式化 | ~2μs | 0ns（不执行） |
| Tree 遍历 | ~10ns | 0ns（无 trees） |

当只种植 `DebugTree` 时，编译器会在 Release 构建中优化掉所有日志代码，从而实现**零开销**。

### 优化技巧

1. **使用 @autoclosure** - 只有在日志启用时才构建字符串
2. **设置适当的 minLevel** - 避免生产环境不必要的工作
3. **使用 AsyncTree** - 不要为昂贵操作阻塞调用线程
4. **限制缓冲区大小** - CrashBufferTree 使用 100-500 条日志最优
5. **避免过度日志记录** - 可能导致性能下降

## CI/CD

Canopy 包含用于持续集成的 GitHub Actions 工作流。

### 工作流特性

- **SwiftLint**：每次推送/PR 时进行代码质量检查
- **多版本测试**：iOS 15.0, 16.0, 17.0
- **SPM 测试**：原生 Swift Package Manager 测试
- **基于路径的过滤**：跳过仅文档更改的 CI

### 本地运行 CI

```bash
# 代码检查
swiftlint

# 测试
swift test

# 构建（Xcode）
xcodebuild -project Canopy.xcodeproj \
  -scheme Canopy \
  -destination "generic/platform=iOS Simulator" \
  build
```

### CI 配置

工作流定义在 [`.github/workflows/ci.yml`](.github/workflows/ci.yml)。CI 在以下情况自动运行：

- 推送到 `main` 或 `master` 分支
- 向 `main` 或 `master` 分支提交 Pull Request

仅文档更改（`.md` 文件、`docs/`、`Examples/`）会自动跳过以节省资源。

## 故障排查

### 常见问题

#### 1. 日志不显示在控制台

**症状：**
- 日志不显示在 Xcode 控制台
- 只显示部分日志

**解决方案：**
```swift
// 检查是否种植了 Tree
#if DEBUG
Canopy.plant(DebugTree())  // 确保已调用
#endif

// 检查日志级别过滤
let tree = DebugTree()
tree.minLevel = .verbose  // 确保级别足够低

// 检查 Release 模式是否禁用了 DebugTree
#if DEBUG
// DebugTree 只在 DEBUG 构建中生效
#endif
```

#### 2. 性能问题

**症状：**
- 启用日志后应用变慢
- 主线程阻塞

**解决方案：**
```swift
// 1. 对昂贵操作使用 AsyncTree
let asyncTree = AsyncTree(wrapping: crashTree)
Canopy.plant(asyncTree)

// 2. 生产环境提高 minLevel
tree.minLevel = .error  // 只记录错误

// 3. 减少日志频率
// 不要记录每次迭代
for i in 0..<1000 {
    if i % 100 == 0 {
        Canopy.d("Progress: %d/1000", i)
    }
}
```

#### 3. 日志缺少上下文

**症状：**
- 无法判断哪个模块记录了日志
- 日志缺乏源信息

**解决方案：**
```swift
// 1. 使用标签
Canopy.tag("Network").i("Request started")

// 2. 使用 CanopyContext
#if canImport(UIKit)
CanopyContext.push(viewController: self)
Canopy.i("User action")
#endif

// 3. 包含相关数据
Canopy.i("User %@ action: %@", userId, actionType)
```

#### 4. 线程安全问题

**症状：**
- 从多个线程记录日志时崩溃
- 日志交错不正确

**解决方案：**
```swift
// Canopy 设计上是线程安全的
// 只需确保不违反线程安全：
// ✅ 正确：线程安全使用
DispatchQueue.global().async {
    Canopy.d("Background task")
}

// ❌ 避免：在没有锁的情况下共享可变状态
class BadTree: Tree {
    var logs: [String] = []  // 非线程安全！
}
```

#### 5. 崩溃日志未保存

**症状：**
- 崩溃后找不到 CrashBufferTree 日志
- 文件不存在

**解决方案：**
```swift
// 1. 确保 CrashBufferTree 已种植
let crashTree = CrashBufferTree(maxSize: 100)
Canopy.plant(crashTree)

// 2. 检查文件权限
// 日志保存到 Documents 目录
// 确保应用有写权限

// 3. 在应用终止时刷新
// CrashBufferTree 在正常退出时自动刷新
// 手动刷新：
crashTree.flush()
```

### 调试技巧

1. **使用 Console.app 查看 iOS 日志：**
   - 打开 Console.app（应用程序 > 实用工具）
   - 按应用 bundle ID 过滤
   - 查看来自 os.log 的结构化日志

2. **选择性启用日志级别：**
   ```swift
   #if DEBUG
   tree.minLevel = .verbose
   #else
   tree.minLevel = .error
   #endif
   ```

3. **使用断点验证日志记录：**
   - 在自定义 Tree 的 log() 方法中设置断点
   - 检查传入参数
   - 验证过滤逻辑

4. **分析日志开销：**
   - 使用 Instruments Time Profiler
   - 识别昂贵的日志调用
   - 优化热点路径

### 获取帮助

- **GitHub Issues:** [github.com/ding1dingx/Canopy/issues](https://github.com/ding1dingx/Canopy/issues)
- **示例：** 查看 [Examples/README.zh-CN.md](Examples/README.zh-CN.md) 了解集成示例
- **测试指南：** 查看 [TESTING.zh-CN.md](TESTING.zh-CN.md) 了解基准测试和 CI/CD 文档
- **文档：** [Canopy Wiki](https://github.com/ding1dingx/Canopy/wiki)

## 许可证

查看项目 LICENSE 文件。

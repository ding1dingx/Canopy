# Canopy

> 🌲 Canopy：树冠覆盖森林，全面洞察你的 App。

轻量级、高性能的 iOS 日志框架，灵感来自 Android 的 Timber。

## 特性

- **Tree 架构** - 通过可插拔的 Tree 灵活配置日志
- **性能优化** - Release 模式下如果只用 `DebugTree` 则零开销
- **iOS 13+ 支持** - 仅使用 Swift 标准库和 Foundation
- **无外部依赖** - 纯 Swift 实现

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
Canopy.v("详细日志")
Canopy.d("调试日志")
Canopy.i("信息日志")
Canopy.w("警告日志")
Canopy.e("错误日志")
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
|---------|--------|-------|
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
1. 在 Xcode 中打开 `Canopy.xcodeproj`
2. 选择 iOS 13.0+ 模拟器或真机
3. Build 并运行
4. 在 Xcode Console（⌘⇧Y）中查看日志

## 要求

- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## 许可证

查看项目 LICENSE 文件。

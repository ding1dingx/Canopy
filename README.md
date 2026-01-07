# Canopy

> 🌲 Canopy: A tree canopy covering your entire app's forest with comprehensive logging insights.

A lightweight, high-performance logging framework for iOS, inspired by Android's Timber.

## Features

- **Tree-based Architecture** - Flexible logging through pluggable trees
- **Performance Optimized** - Zero overhead in Release mode when only `DebugTree` is used
- **iOS 13+ Support** - Uses only Swift standard library and Foundation
- **No External Dependencies** - Pure Swift implementation

## Quick Start

```swift
import Foundation

// In AppDelegate.application(_:didFinishLaunchingWithOptions:)
#if DEBUG
Canopy.plant(DebugTree())
#endif
Canopy.plant(CrashBufferTree(maxSize: 100))

// Use anywhere in your app
Canopy.v("Verbose message")
Canopy.d("Debug message")
Canopy.i("Info message")
Canopy.w("Warning message")
Canopy.e("Error message")
```

## How It Works

### Debug Mode
- All logs are printed to console

### Release Mode
- Logs from `DebugTree` are **not** printed
- Logs from other trees (like `CrashBufferTree`) are still printed
- If you only plant `DebugTree`, there is **zero overhead** in Release builds

## Log Levels

| Method | Level | Use Case |
|---------|--------|-----------|
| `Canopy.v()` | Verbose | Detailed diagnostics |
| `Canopy.d()` | Debug | Development debugging |
| `Canopy.i()` | Info | General information |
| `Canopy.w()` | Warning | Potential issues |
| `Canopy.e()` | Error | Errors and failures |

## Tree Types

### DebugTree
Prints logs to console in Debug mode only.

```swift
Canopy.plant(DebugTree())
```

### CrashBufferTree
Stores recent logs in memory. On crash, saves them to file for analysis.

```swift
let crashTree = CrashBufferTree(maxSize: 100)
Canopy.plant(crashTree)

// Retrieve logs later
let logs = crashTree.recentLogs()
```

**Use Case:** Perfect for Release mode - keeps crash logs even when console logs are disabled.

### AsyncTree
Wraps any tree to log on a background queue without blocking the caller.

```swift
let asyncTree = AsyncTree(wrapping: crashTree)
Canopy.plant(asyncTree)
```

### Custom Trees
Create your own by extending `Tree`:

```swift
public final class FileTree: Tree {
    override func log(priority: LogLevel, tag: String?, message: String, error: Error?) {
        // Write to file
    }
}
```

## Tagged Logging

Add context to logs:

```swift
Canopy.tag("Network").i("API request started")
Canopy.tag("Database").w("Slow query detected")
Canopy.tag("Analytics").v("Event tracked: page_view")
```

## Demo App

The included demo showcases all Canopy features:

| Button | Feature |
|--------|----------|
| Verbose/Debug/Info/Warning/Error | Log level demonstration |
| Format Log | String formatting |
| Tagged Log | Context-based logging |
| Async Log | Background logging |
| View Crash Buffer | Display buffered logs |

**Run Demo:**
1. Open `Canopy.xcodeproj` in Xcode
2. Select iOS 13.0+ simulator/device
3. Build and run
4. View logs in Xcode Console (⌘⇧Y)

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## License

See project LICENSE file.

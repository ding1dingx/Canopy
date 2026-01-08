# Canopy

> 🌲 Canopy: A tree canopy covering your entire app's forest with comprehensive logging insights.

A lightweight, high-performance logging framework for iOS, inspired by Android's Timber.

## Features

- **Tree-based Architecture** - Flexible logging through pluggable trees
- **Performance Optimized** - Zero overhead in Release mode when only `DebugTree` is used
- **iOS 14+ Support** - Uses only Swift standard library and Foundation
- **No External Dependencies** - Pure Swift implementation

## Quick Start

Add Canopy to your project using Swift Package Manager or CocoaPods:

```bash
# Swift Package Manager
dependencies: [
    .package(url: "https://github.com/ding1dingx/Canopy.git", from: "0.1.0")
]

# CocoaPods
pod 'Canopy', '~> 0.1.0'
```

Initialize in your `AppDelegate`:

```swift
#if DEBUG
Canopy.plant(DebugTree())
#endif
Canopy.plant(CrashBufferTree(maxSize: 100))

// Use anywhere
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
2. Select iOS 14.0+ simulator/device
3. Build and run
4. View logs in Xcode Console (⌘⇧Y)

## Requirements

- iOS 14.0+
- Swift 5.0+
- Xcode 12.0+

## Best Practices

### 1. Use Appropriate Log Levels

```swift
// ✅ GOOD: Use appropriate levels for production
func processData(_ data: Data) {
    Canopy.d("Processing \(data.count) bytes")  // Only in debug builds
}

// ❌ AVOID: Excessive verbose logging in production
func processData(_ data: Data) {
    Canopy.v("Step 1: Starting")
    Canopy.v("Step 2: Parsing")
    Canopy.v("Step 3: Validating")
    Canopy.v("Step 4: Saving")
}
```

### 2. Leverage @autoclosure for Performance

```swift
// ✅ GOOD: Lazy string evaluation
Canopy.d("Processing item: \(itemName)")  // String only built if log is enabled

// ✅ BETTER: Use format args (no string interpolation)
Canopy.d("Processing item: %@", itemName)

// ❌ AVOID: Always builds strings (performance cost)
Canopy.d("Processing item: " + itemName)
```

### 3. Use AsyncTree for Expensive Operations

```swift
// ✅ GOOD: Wrap expensive trees with AsyncTree
let crashTree = CrashBufferTree(maxSize: 100)
let asyncCrashTree = AsyncTree(wrapping: crashTree)
Canopy.plant(asyncCrashTree)

// Logs won't block the calling thread
Canopy.d("User logged in")
```

### 4. Contextual Logging with Tags

```swift
// ✅ GOOD: Use tags for context
class NetworkManager {
    private let tag = "Network"

    func makeRequest() {
        Canopy.tag(tag).i("Starting request to \(url)")
    }

    func handleResponse() {
        Canopy.tag(tag).i("Received response: \(statusCode)")
    }
}

// ✅ EVEN BETTER: Tag via CanopyContext
func pushView(_ viewController: UIViewController) {
    CanopyContext.push(viewController: viewController)
    Canopy.i("View displayed")
    CanopyContext.current = nil
}
```

### 5. Release Mode Configuration

```swift
// ✅ RECOMMENDED: Minimize logging in production
#if DEBUG
Canopy.plant(DebugTree())
#endif

// Keep crash logs even in release
let crashTree = CrashBufferTree(maxSize: 100)
Canopy.plant(crashTree)

// Optional: Add remote logging for errors
#if !DEBUG
let sentryTree = SentryTree(sentry: sentry, minLevel: .error)
Canopy.plant(sentryTree)
#endif
```

### 6. Avoid Common Pitfalls

```swift
// ❌ AVOID: String concatenation in logs
Canopy.d("User: " + username + " logged in")

// ❌ AVOID: String.format in logs (can cause crashes)
Canopy.d(String.format("URL is %s", url))

// ✅ GOOD: Use Canopy's built-in formatting
Canopy.d("User %@ logged in", username)
Canopy.d("URL is %@", url)

// ❌ AVOID: Logging sensitive data
Canopy.d("Password: %@", password)

// ✅ GOOD: Sanitize or omit sensitive data
Canopy.d("User %@ logged in (password hidden)", username)
```

## Performance Analysis

### Benchmark Results

| Operation | Debug Mode | Release Mode (DebugTree only) |
|------------|-------------|---------------------------|
| Log call overhead | ~50ns | 0ns (compiler optimizes out) |
| String formatting | ~200ns | 0ns (not executed) |
| Tree traversal | ~10ns | 0ns (no trees planted) |

### Memory Impact

| Component | Memory Footprint |
|-----------|------------------|
| Canopy core | ~5KB |
| DebugTree | ~2KB |
| CrashBufferTree (100 logs) | ~10KB |
| AsyncTree overhead | ~1KB |

### Optimization Tips

1. **Use @autoclosure** - Strings only built when logging is enabled
2. **Set appropriate minLevel** - Avoid unnecessary work in production
3. **Use AsyncTree** - Don't block calling threads for expensive operations
4. **Limit buffer size** - CrashBufferTree with 100-500 logs is optimal
5. **Avoid excessive logging** - Can cause performance degradation

## Troubleshooting

### Common Issues

#### 1. Logs Not Appearing in Console

**Symptoms:**
- Logs don't appear in Xcode Console
- Only some logs appear

**Solutions:**
```swift
// Check if tree is planted
#if DEBUG
Canopy.plant(DebugTree())  // Ensure this is called
#endif

// Check log level filtering
let tree = DebugTree()
tree.minLevel = .verbose  // Ensure level is low enough

// Check if Release mode disables DebugTree
#if DEBUG
// DebugTree only works in DEBUG builds
#endif
```

#### 2. Performance Issues

**Symptoms:**
- App slows down with logging enabled
- Main thread blocking

**Solutions:**
```swift
// 1. Use AsyncTree for expensive operations
let asyncTree = AsyncTree(wrapping: crashTree)
Canopy.plant(asyncTree)

// 2. Increase minLevel in production
tree.minLevel = .error  // Only log errors in production

// 3. Reduce log frequency
// Instead of logging every iteration
for i in 0..<1000 {
    if i % 100 == 0 {
        Canopy.d("Progress: %d/1000", i)
    }
}
```

#### 3. Missing Context in Logs

**Symptoms:**
- Can't tell which module logged a message
- Logs lack source information

**Solutions:**
```swift
// 1. Use tags
Canopy.tag("Network").i("Request started")

// 2. Use CanopyContext
#if canImport(UIKit)
CanopyContext.push(viewController: self)
Canopy.i("User action")
#endif

// 3. Include relevant data
Canopy.i("User %@ action: %@", userId, actionType)
```

#### 4. Thread Safety Issues

**Symptoms:**
- Crashes when logging from multiple threads
- Logs interleaved incorrectly

**Solutions:**
```swift
// Canopy is thread-safe by design
// Just ensure you don't violate thread safety:
// ✅ GOOD: Thread-safe usage
DispatchQueue.global().async {
    Canopy.d("Background task")
}

// ❌ AVOID: Sharing mutable state without locks
class BadTree: Tree {
    var logs: [String] = []  // Not thread-safe!
}
```

#### 5. Crash Logs Not Saved

**Symptoms:**
- CrashBufferTree logs not found after crash
- File doesn't exist

**Solutions:**
```swift
// 1. Ensure CrashBufferTree is planted
let crashTree = CrashBufferTree(maxSize: 100)
Canopy.plant(crashTree)

// 2. Check file permissions
// Logs saved to Documents directory
// Ensure app has write access

// 3. Flush on app termination
// CrashBufferTree automatically flushes on normal exit
// For manual flush:
crashTree.flush()

// 4. Check file location
let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
let logFile = documentsURL?.appendingPathComponent("canopy_crash_buffer.txt")
```

### Debugging Tips

1. **Use Console.app for iOS logs:**
   - Open Console.app (Applications > Utilities)
   - Filter by your app bundle ID
   - See structured logs from os.log

2. **Enable log levels selectively:**
   ```swift
   #if DEBUG
   tree.minLevel = .verbose
   #else
   tree.minLevel = .error
   #endif
   ```

3. **Use breakpoints to verify logging:**
   - Set breakpoints in custom Tree log() methods
   - Inspect incoming parameters
   - Verify filtering logic

4. **Profile logging overhead:**
   - Use Instruments Time Profiler
   - Identify expensive logging calls
   - Optimize hot paths

### Getting Help

- **GitHub Issues:** [github.com/ding1dingx/Canopy/issues](https://github.com/ding1dingx/Canopy/issues)
- **Examples:** See [Examples/README.md](Examples/README.md) for integration examples
- **Documentation:** [Canopy Wiki](https://github.com/ding1dingx/Canopy/wiki)

## License

See project LICENSE file.

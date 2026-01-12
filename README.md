# Canopy

> 🌲 A tree canopy covering your entire app's forest with comprehensive logging insights.

A lightweight, high-performance logging framework for iOS, inspired by Android's Timber.

## Features

- **Tree-based Architecture** - Flexible logging through pluggable trees
- **Performance Optimized** - Zero overhead in Release mode when only `DebugTree` is used
- **iOS 14+ Support** - Uses only Swift standard library and Foundation
- **No External Dependencies** - Pure Swift implementation
- **Thread Safe** - Lock-protected concurrent access
- **Comprehensive Testing** - 102 tests with performance benchmarks
- **Error Parameter Support** - Pass Error objects to log methods for error tracking services like Sentry

## Quick Start

Add Canopy to your project using Swift Package Manager or CocoaPods:

```bash
# Swift Package Manager
dependencies: [
    .package(url: "https://github.com/ding1dingx/Canopy.git", from: "0.2.3")
]

# CocoaPods
pod 'Canopy', '~> 0.2.3'
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

// With tag (thread-safe)
Canopy.v("Network request", tag: "Network")
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

## Logging with Errors

Canopy supports passing `Error` objects to log methods. This is particularly useful for error tracking services like Sentry.

### Basic Usage

```swift
do {
    try someThrowingOperation()
} catch {
    // Error object is captured and can be sent to error tracking services
    Canopy.e("Operation failed", error: error)
}
```

### With Format Arguments

```swift
Canopy.e("Failed to fetch user %@ (attempt %d)", error: networkError, userId, retryCount)
```

### All Log Levels Support Errors

```swift
Canopy.v("Detailed info", error: error)
Canopy.d("Debug info", error: error)
Canopy.i("Info with error", error: error)
Canopy.w("Warning with error", error: error)
Canopy.e("Error occurred", error: error)
```

### Tagged Logging with Errors

```swift
Canopy.tag("Network").e("Request failed", error: networkError)
Canopy.tag("Database").w("Query slow", error: dbError)
```

### Backward Compatibility

The original API without error parameters still works:

```swift
Canopy.e("Simple error message")
```

This is equivalent to passing `error: nil`.

## Tree Types

### DebugTree
Prints logs to console in Debug mode only.

```swift
Canopy.plant(DebugTree())
```

### CrashBufferTree
Stores recent logs in memory. On crash, saves them to file for analysis.

**Parameter Validation:**
- `maxSize` must be > 0 (throws fatalError if 0 or negative)
- `maxSize` must be <= 10000 (throws fatalError if exceeded)
- Recommended range: 10-500 for optimal performance

**Empty Tag Handling:**
- When tag is `nil` or empty, the log format is `[priority]: message`
- No square brackets `[]` are displayed for empty tags
- This improves readability and avoids confusing `[nil] message` output

**Signal Handler Safety:**
- `flush()` is NOT called in signal handlers (NSLock is not async-signal-safe)
- Flush only occurs via `atexit()` handler on normal app termination
- Signal handlers only set the crash flag, actual flush happens safely

**Flush Failure Logging:**
- Failed flush operations are logged via `NSLog`
- Errors: UTF-8 encoding failure, missing documents directory, file write errors
- Success: Number of logs flushed and file path are logged

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

// ✅ BEST: Use CanopyContext.with() for automatic scope-based context
func fetchUserData(userId: String) {
    CanopyContext.with("API") {
        Canopy.i("Fetching user data")
        Canopy.i("Request started for user: %@", userId)
        // Context automatically restored on exit
    }
}

// ✅ GOOD: CanopyContext.with() with nested scopes
func processOrder() {
    CanopyContext.with("OrderService") {
        Canopy.i("Processing order")

        CanopyContext.with("Payment") {
            Canopy.i("Processing payment")
            // "Payment" tag is active here
        }

        // "OrderService" tag is restored here
        Canopy.i("Order completed")
    }
}

// ❌ AVOID: Manual context management (error-prone)
func pushView(_ viewController: UIViewController) {
    CanopyContext.push(viewController: viewController)
    Canopy.i("View displayed")
    CanopyContext.current = nil  // Easy to forget!
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

Performance measurements from `CanopyBenchmarkTests` on Apple Silicon M3 (macOS 14):

| Operation | Operations | Time (avg) | Per-operation | Notes |
|-----------|------------|------------|---------------|-------|
| Log call (no args) | 10,000 | ~2ms | ~200ns | Baseline log call |
| Log call (single arg) | 10,000 | ~20ms | ~2μs | With string formatting |
| Log call (multiple args) | 10,000 | ~57ms | ~5.7μs | 3 format specifiers |
| Format message only | 10,000 | ~1ms | ~100ns | Without log overhead |
| Canopy API (no tree) | 1,000 | ~3ms | ~3μs | No trees planted |
| Canopy API (with DebugTree) | 1,000 | ~4ms | ~4μs | DebugTree planted |
| Canopy with tag parameter | 1,000 | ~4ms | ~4μs | Thread-safe tagging |
| AsyncTree (1,000 logs) | 1,000 | ~10ms | ~10μs | Background queue |
| Concurrent logging | 10,000 | ~100ms | ~10μs | 10 threads × 1,000 |
| Concurrent tagged logging | 10,000 | ~110ms | ~11μs | 4 tags, 10 threads |
| CrashBufferTree (1,000 logs) | 1,000 | ~20ms | ~20ns | Buffer operations |

> **Note**: Results vary based on device and iOS version. Run `swift test --filter CanopyBenchmarkTests` to benchmark your environment.

### Memory Impact

| Component | Memory Footprint |
|-----------|------------------|
| Canopy core | ~5KB |
| DebugTree | ~2KB |
| CrashBufferTree (100 logs) | ~10KB |
| AsyncTree overhead | ~1KB |

### Release Mode Optimization

| Scenario | Debug Mode | Release Mode |
|----------|------------|--------------|
| Log call overhead | ~200ns | 0ns (no-op) |
| String formatting | ~2μs | 0ns (not executed) |
| Tree traversal | ~10ns | 0ns (no trees) |

When only `DebugTree` is planted, the compiler optimizes out all logging code in Release builds, resulting in **zero overhead**.

### Optimization Tips

1. **Use @autoclosure** - Strings only built when logging is enabled
2. **Set appropriate minLevel** - Avoid unnecessary work in production
3. **Use AsyncTree** - Don't block calling threads for expensive operations
4. **Limit buffer size** - CrashBufferTree with 100-500 logs is optimal
5. **Avoid excessive logging** - Can cause performance degradation

## CI/CD

Canopy includes a comprehensive GitHub Actions workflow for continuous integration.

### Workflow Features

- **SwiftLint**: Code quality checks on every push/PR
- **Multi-version testing**: iOS 15.0, 16.0, 17.0
- **SPM testing**: Native Swift Package Manager tests
- **Path-based filtering**: Skips CI for documentation-only changes

### Running CI Locally

```bash
# Lint
swiftlint

# Test
swift test

# Build (Xcode)
xcodebuild -project Canopy.xcodeproj \
  -scheme Canopy \
  -destination "generic/platform=iOS Simulator" \
  build
```

### CI Configuration

The workflow is defined in [`.github/workflows/ci.yml`](.github/workflows/ci.yml). CI runs automatically on:

- Push to `main` or `master` branch
- Pull requests to `main` or `master` branch

Documentation-only changes (`.md` files, `docs/`, `Examples/`) are automatically skipped to save resources.

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
- **Testing Guide:** See [TESTING.md](TESTING.md) for benchmarks and CI/CD documentation
- **Documentation:** [Canopy Wiki](https://github.com/ding1dingx/Canopy/wiki)

## License

See project LICENSE file.

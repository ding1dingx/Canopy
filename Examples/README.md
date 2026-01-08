# Canopy Extensibility Examples

The Canopy Tree architecture is fully extensible and supports integrating any logging service.

---

## Quick Start

### 1. Xlog Integration

```swift
import Canopy
import Xlog  // Tencent Mars Xlog SDK

// Initialize Xlog
let xlog = ...  // Your Xlog instance

// Create and plant XlogTree
let xlogTree = XlogTree(xlog: xlog, flushInterval: 60)
Canopy.plant(xlogTree)

// All logs will be automatically written through Xlog high-performance
Canopy.i("This will be logged by Xlog")
```

### 2. Sentry Error Tracking

```swift
import Canopy
import Sentry

// Initialize Sentry
SentrySDK.start { options in
    options.dsn = "your_sentry_dsn"
}

// Create and plant SentryTree
let sentryTree = SentryTree(
    sentry: SentrySDK.shared,
    minLevel: .error  // Only log error and above
)
Canopy.plant(sentryTree)

// Errors will be automatically sent to Sentry
Canopy.e("Critical error", error: someError)
```

### 3. Remote Log Service (Batching + Retry + Sampling)

```swift
import Canopy

// Configure remote logging
let config = RemoteLogTree.Configuration(
    endpoint: URL(string: "https://your-log-service.com/logs")!,
    apiKey: "your_api_key",
    batchSize: 50,              // Upload 50 logs at once
    flushInterval: 30,            // Flush every 30 seconds
    retryCount: 3,               // Retry 3 times on failure
    retryDelay: 5,                // Retry delay 5 seconds
    samplingRate: 0.1            // 10% sampling rate (info/debug)
)

let remoteLogTree = RemoteLogTree(config: config, minLevel: .info)
Canopy.plant(remoteLogTree)

// Logs will be batched and sent with retry
Canopy.i("This will be batched and sent with retry")
```

### 4. Using Multiple Trees

```swift
Canopy.plant(
    DebugTree(),              // Console output in Debug mode
    XlogTree(xlog: xlog),     // High-performance local storage
    SentryTree(sentry: sentry), // Auto send error to Sentry
    RemoteLogTree(config: config) // Remote log service
)

// One log call goes through all Trees
Canopy.e("Database connection failed", error: error)
// → Console output (Debug mode)
// → Xlog storage (local)
// → Sentry reporting (error)
// → Remote service upload (batching)
```

### 5. Advanced Composition: Async + Error Reporting

```swift
let asyncRemoteTree = AsyncTree(wrapping: RemoteLogTree(config: config))
Canopy.plant(asyncRemoteTree)

// Logs are sent in background thread without blocking caller
for i in 0..<10000 {
    Canopy.i("Log entry \(i)")  // Won't block main thread
}
```

---

## Release Mode Best Practices

### Log Only Important Logs

```swift
#if DEBUG
Canopy.plant(DebugTree())
#endif

// In Release mode, only log error+
let sentryTree = SentryTree(sentry: sentry, minLevel: .error)
Canopy.plant(sentryTree)

// Use tags to add context
Canopy.tag("PaymentGateway").e("Transaction failed", error: error)
```

### Hierarchical Logging to Different Services

```swift
// Verbose/Debug → Xlog local storage
let xlogTree = XlogTree(xlog: xlog)
xlogTree.minLevel = .verbose
Canopy.plant(xlogTree)

// Warning/Error → Sentry reporting
let sentryTree = SentryTree(sentry: sentry)
sentryTree.minLevel = .warning
Canopy.plant(sentryTree)

// Error → Remote service real-time reporting
let errorRemoteTree = RemoteLogTree(config: errorConfig)
errorRemoteTree.minLevel = .error
Canopy.plant(errorRemoteTree)
```

---

## Advanced Features

### Sampling Control

```swift
// Only log 10% of info/debug logs, but 100% of warning/error
let config = RemoteLogTree.Configuration(
    endpoint: endpoint,
    samplingRate: 0.1  // 10% sampling
)
```

### Batch Upload

```swift
// Accumulate 100 logs before batch upload
let config = RemoteLogTree.Configuration(
    endpoint: endpoint,
    batchSize: 100,
    flushInterval: 60  // Or flush every 60 seconds
)
```

### Network Retry

```swift
// Auto retry 3 times on network failure, exponential backoff
let config = RemoteLogTree.Configuration(
    endpoint: endpoint,
    retryCount: 3,
    retryDelay: 5  // 5s → 10s → 20s
)
```

---

## Custom Tree Templates

### Basic Template

```swift
open class MyCustomTree: Tree {
    override func log(
        priority: LogLevel,
        tag: String?,
        message: String,
        error: Error?
    ) {
        // Implement your logging logic
        // 1. Format log
        let formatted = formatLog(priority, tag, message, error)

        // 2. Send to service
        sendToService(formatted)

        // 3. Local cache (optional)
        cacheLocally(formatted)
    }
}
```

### Template with Buffering and Batching

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
        // Send all logs in buffer as a batch
        sendBatch(buffer)
        buffer.removeAll()
    }
}
```

### Template with Retry

```swift
open class RetryTree: Tree {
    private func sendWithRetry(_ data: Data) {
        var retryCount = 0
        while retryCount < maxRetries {
            if send(data) {
                break  // Success, exit retry
            }
            retryCount += 1
            Thread.sleep(forTimeInterval: retryDelay * pow(2, retryCount))
        }
    }
}
```

---

## Performance Considerations

### 1. Use AsyncTree to Avoid Blocking

```swift
// All remote logging should be wrapped with AsyncTree
let asyncRemoteTree = AsyncTree(wrapping: RemoteLogTree(config: config))
Canopy.plant(asyncRemoteTree)
```

### 2. Set Reasonable Batch Size

```swift
// Too small → Frequent network requests
batchSize: 10  // Too frequent

// Too large → Memory usage and latency
batchSize: 1000  // High latency

// Recommended
batchSize: 50-100  // Balanced
```

### 3. Use Sampling to Reduce Load

```swift
// Recommended sampling for production
#if DEBUG
let samplingRate = 1.0      // Debug: 100%
#else
let samplingRate = 0.1      // Release: 10%
#endif
```

---

## Security Considerations

### 1. Sensitive Information Filtering

```swift
override func log(...) {
    let sanitized = sanitize(message)  // Remove passwords, tokens, etc.
    super.log(...)
}

private func sanitize(_ message: String) -> String {
    message
        .replacingOccurrences(of: "password=\\S+", with: "password=***", options: .regularExpression)
        .replacingOccurrences(of: "token=\\S+", with: "token=***", options: .regularExpression)
}
```

### 2. Encrypted Transmission

```swift
private func sendLogs(_ logs: [String]) {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"

    // Encrypt logs
    let encrypted = encrypt(logs)
    request.httpBody = encrypted

    // Transfer over HTTPS
    request.setValue("application/encrypted", forHTTPHeaderField: "Content-Type")
}
```

---

## Summary

### Canopy Extensibility:

- **Fully Customizable** - Implement any functionality by inheriting from `Tree`
- **Multiple Tree Composition** - Use multiple logging services simultaneously
- **Flexible Filtering** - Independent `minLevel` for each Tree
- **Performance Optimized** - `AsyncTree` avoids blocking
- **Advanced Features** - Batching, retry, and sampling all supported

### Parts You Need to Implement:

- **Specific Service Integration** - Xlog, Sentry, etc.
- **Network Sending Logic** - Network requests
- **Batching, Retry, Sampling** - Algorithms for these features
- **Local Storage Strategy** - File storage, caching, etc.

**Canopy provides the architecture and infrastructure, you need to implement business logic based on specific requirements.**

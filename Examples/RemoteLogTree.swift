//
//  RemoteLogTree.swift
//  Canopy Examples
//
//  Complete remote logging tree implementation with batching, retry, and sampling
//

import Foundation

/// Remote logging tree with batching, retry, and sampling capabilities
open class RemoteLogTree: Tree {
    /// Configuration for remote logging
    public struct Configuration {
        let endpoint: URL
        let apiKey: String?
        let batchSize: Int
        let flushInterval: TimeInterval
        let retryCount: Int
        let retryDelay: TimeInterval
        let samplingRate: Double

        /// Initialize configuration with defaults
        public init(
            endpoint: URL,
            apiKey: String? = nil,
            batchSize: Int = 50,
            flushInterval: TimeInterval = 30,
            retryCount: Int = 3,
            retryDelay: TimeInterval = 5,
            samplingRate: Double = 1.0
        ) {
            self.endpoint = endpoint
            self.apiKey = apiKey
            self.batchSize = batchSize
            self.flushInterval = flushInterval
            self.retryCount = retryCount
            self.retryDelay = retryDelay
            self.samplingRate = samplingRate
        }
    }

    private let config: Configuration
    private var buffer: [LogEntry] = []
    private var flushTimer: Timer?
    private var isFlushing = false
    private let lock = NSLock()
    private let queue = DispatchQueue(label: "com.canopy.remotelogtree")

    /// Initialize with configuration and minimum log level
    public init(config: Configuration, minLevel: LogLevel = .info) {
        self.config = config
        super.init()
        self.minLevel = minLevel

        startFlushTimer()
    }

    deinit {
        flushTimer?.invalidate()
        flush()
    }

    /// Override log to add to buffer with sampling
    open override func log(
        priority: LogLevel,
        tag: String?,
        message: String,
        error: Error?
    ) {
        guard shouldSample(priority: priority) else { return }

        let entry = LogEntry(
            level: priority,
            tag: tag,
            message: message,
            error: error,
            timestamp: Date(),
            file: "",
            line: 0
        )

        queue.async { [weak self] in
            self?.addToBuffer(entry)
        }
    }

    /// Check if log should be sampled based on priority and sampling rate
    private func shouldSample(priority: LogLevel) -> Bool {
        if priority == .error || priority == .warning {
            return true
        }
        return Double.random(in: 0...1) <= config.samplingRate
    }

    /// Add entry to buffer, trigger flush if batch size reached
    private func addToBuffer(_ entry: LogEntry) {
        lock.lock()
        defer { lock.unlock() }

        buffer.append(entry)

        if buffer.count >= config.batchSize {
            flushAsync()
        }
    }

    /// Start periodic flush timer
    private func startFlushTimer() {
        flushTimer = Timer.scheduledTimer(
            withTimeInterval: config.flushInterval,
            repeats: true
        ) { [weak self] _ in
            self?.flushAsync()
        }
    }

    /// Flush buffer asynchronously with retry logic
    private func flushAsync() {
        guard !isFlushing else { return }

        let entries: [LogEntry]
        lock.lock()
        entries = buffer
        buffer.removeAll()
        lock.unlock()

        guard !entries.isEmpty else { return }

        isFlushing = true

        sendWithRetry(entries: entries) { [weak self] success in
            if success {
                self?.isFlushing = false
            } else {
                self?.handleSendFailure(entries: entries)
            }
        }
    }

    /// Synchronous flush method
    private func flush() {
        flushAsync()
    }

    /// Send logs with exponential backoff retry
    private func sendWithRetry(entries: [LogEntry], completion: @escaping (Bool) -> Void) {
        var retryCount = 0
        var currentDelay = config.retryDelay

        func attempt() {
            self.sendLogs(entries: entries) { [weak self] success in
                if success {
                    completion(true)
                } else if retryCount < self.config.retryCount {
                    retryCount += 1
                    DispatchQueue.global().asyncAfter(deadline: .now() + currentDelay) {
                        currentDelay *= 2
                        attempt()
                    }
                } else {
                    completion(false)
                }
            }
        }

        attempt()
    }

    /// Send logs to remote endpoint
    private func sendLogs(entries: [LogEntry], completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: config.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let apiKey = config.apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }

        do {
            let payload = LogBatch(entries: entries)
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            let success = error == nil && (response as? HTTPURLResponse)?.statusCode == 200
            completion(success)
        }.resume()
    }

    /// Handle failed send by putting entries back into buffer
    private func handleSendFailure(entries: [LogEntry]) {
        lock.lock()
        buffer.insert(contentsOf: entries, at: 0)
        isFlushing = false
        lock.unlock()
    }

    /// Individual log entry
    private struct LogEntry: Codable {
        let level: LogLevel
        let tag: String?
        let message: String
        let error: String?
        let timestamp: Date
        let file: String
        let line: UInt

        init(level: LogLevel, tag: String?, message: String, error: Error?, timestamp: Date, file: String, line: UInt) {
            self.level = level
            self.tag = tag
            self.message = message
            self.error = error?.localizedDescription
            self.timestamp = timestamp
            self.file = file
            self.line = line
        }
    }

    /// Batch of log entries with device and app info
    private struct LogBatch: Codable {
        let entries: [LogEntry]
        let deviceInfo: DeviceInfo
        let appInfo: AppInfo

        init(entries: [LogEntry]) {
            self.entries = entries
            self.deviceInfo = DeviceInfo.current
            self.appInfo = AppInfo.current
        }
    }

    /// Device information
    private struct DeviceInfo: Codable {
        let platform: String
        let systemVersion: String
        let deviceModel: String
        let appVersion: String

        static var current: DeviceInfo {
            DeviceInfo(
                platform: "iOS",
                systemVersion: UIDevice.current.systemVersion,
                deviceModel: UIDevice.current.model,
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            )
        }
    }

    /// Application information
    private struct AppInfo: Codable {
        let bundleIdentifier: String
        let buildNumber: String
        let environment: String

        static var current: AppInfo {
            AppInfo(
                bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
                buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
                environment: isDebug ? "debug" : "release"
            )
        }

        private static var isDebug: Bool {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
}

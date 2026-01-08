//
//  SentryTree.swift
//  Canopy Examples
//
//  Example tree for Sentry error reporting integration
//

import Foundation

/// Tree implementation for Sentry error reporting
open class SentryTree: Tree {
    private let sentry: Any
    private let bufferSize: Int
    private var logBuffer: [LogEntry] = []
    private let queue: DispatchQueue = DispatchQueue(label: "com.canopy.sentrytree")

    /// Initialize SentryTree with Sentry instance and buffer size
    public init(
        sentry: Any,
        bufferSize: Int = 100,
        minLevel: LogLevel = .error
    ) {
        self.sentry = sentry
        self.bufferSize = bufferSize
        super.init()
        self.minLevel = minLevel
    }

    /// Override log method to send errors to Sentry
    open override func log(
        priority: LogLevel,
        tag: String?,
        message: String,
        error: Error?
    ) {
        let entry = LogEntry(
            level: priority,
            tag: tag,
            message: message,
            error: error,
            timestamp: Date()
        )

        queue.async { [weak self] in
            self?.addToBuffer(entry)

            if priority == .error || error != nil {
                self?.sendToSentry(entry)
            }
        }
    }

    /// Add entry to buffer, maintain max size
    private func addToBuffer(_ entry: LogEntry) {
        logBuffer.append(entry)
        if logBuffer.count > bufferSize {
            logBuffer.removeFirst()
        }
    }

    /// Send log entry to Sentry as error or breadcrumb
    private func sendToSentry(_ entry: LogEntry) {
        let level = convertToSentryLevel(entry.level)

        if let error = entry.error {
            sendErrorToSentry(error, level: level, extra: entry.asExtra())
        } else {
            sendBreadcrumbToSentry(entry, level: level)
        }
    }

    /// Send error to Sentry
    private func sendErrorToSentry(_ error: Error, level: Int, extra: [String: Any]) {
    }

    /// Send breadcrumb to Sentry
    private func sendBreadcrumbToSentry(_ entry: LogEntry, level: Int) {
    }

    /// Convert Canopy LogLevel to Sentry level
    private func convertToSentryLevel(_ level: LogLevel) -> Int {
        switch level {
        case .verbose, .debug: return 1
        case .info:    return 2
        case .warning: return 3
        case .error:   return 4
        }
    }

    /// Log entry with metadata
    private struct LogEntry {
        let level: LogLevel
        let tag: String?
        let message: String
        let error: Error?
        let timestamp: Date

        func asExtra() -> [String: Any] {
            var extra: [String: Any] = [
                "level": String(describing: level),
                "message": message,
                "timestamp": ISO8601DateFormatter().string(from: timestamp)
            ]

            if let tag = tag {
                extra["tag"] = tag
            }

            return extra
        }
    }
}

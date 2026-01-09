//
//  CrashBufferTree.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation
import os

nonisolated(unsafe) private var crashBufferTreeInstance: CrashBufferTree?
nonisolated(unsafe) private var crashSignalOccurred: sig_atomic_t = 0

private func crashSignalHandler(_ signal: Int32) {
    crashSignalOccurred = 1
}

private func uncaughtExceptionHandler(_ exception: NSException) {
    crashSignalOccurred = 1
}

private func exitHandler() {
    crashBufferTreeInstance?.flush()
}

/// A Tree that buffers logs in memory and flushes them to a file on app exit or crash.
/// Uses locks for thread-safe access to internal state.
public final class CrashBufferTree: Tree, @unchecked Sendable {
    /// Maximum number of logs to buffer.
    private let maxSize: Int
    
    /// Thread-unsafe buffer - protected by lock.
    nonisolated(unsafe) private var buffer: [String] = []
    
    /// Lock for thread-safe buffer access.
    private let lock = NSLock()

    public init(maxSize: Int = 100) {
        guard maxSize > 0 else {
            fatalError("CrashBufferTree: maxSize must be greater than 0, got \(maxSize)")
        }
        guard maxSize <= 10000 else {
            fatalError("CrashBufferTree: maxSize too large, limit is 10000, got \(maxSize)")
        }
        self.maxSize = maxSize
        super.init()

        crashBufferTreeInstance = self

        signal(SIGABRT, crashSignalHandler)
        signal(SIGSEGV, crashSignalHandler)
        signal(SIGBUS, crashSignalHandler)
        signal(SIGFPE, crashSignalHandler)
        signal(SIGILL, crashSignalHandler)
        NSSetUncaughtExceptionHandler(uncaughtExceptionHandler)
        atexit(exitHandler)

        checkAndFlushOnCrash()
    }

    private nonisolated func checkAndFlushOnCrash() {
        if crashSignalOccurred == 1 {
            flush()
            crashSignalOccurred = 0
        }
    }

    nonisolated public override func log(
        priority: LogLevel,
        tag: String?,
        message: @autoclosure () -> String,
        arguments: [CVarArg],
        error: Error?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        checkAndFlushOnCrash()

        let effectiveTag = explicitTag ?? tag
        explicitTag = nil

        let msg = "[\(priority)] \(effectiveTag ?? ""): \(message())"
        lock.lock()
        buffer.append(msg)
        if buffer.count > maxSize { buffer.removeFirst() }
        lock.unlock()
    }

    nonisolated func flush() {
        lock.lock()
        defer { lock.unlock() }

        guard let data = buffer.joined(separator: "\n").data(using: .utf8) else {
            NSLog("Canopy: Failed to encode buffer to UTF-8")
            return
        }

        guard let url = documentsURL()?.appendingPathComponent("canopy_crash_buffer.txt") else {
            NSLog("Canopy: Failed to get documents directory")
            return
        }

        do {
            try data.write(to: url, options: .atomic)
            NSLog("Canopy: Successfully flushed \(buffer.count) logs to \(url.path)")
        } catch {
            NSLog("Canopy: Failed to flush buffer to \(url.path): \(error.localizedDescription)")
        }
    }

    nonisolated private func documentsURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    nonisolated public func recentLogs() -> String {
        lock.lock()
        defer { lock.unlock() }
        return buffer.joined(separator: "\n")
    }
}

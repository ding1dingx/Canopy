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

public final class CrashBufferTree: Tree {
    private let maxSize: Int
    nonisolated(unsafe) private var buffer: [String] = []
    nonisolated(unsafe) private var lock = os_unfair_lock()

    public init(maxSize: Int = 100) {
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
        explicitTag = nil  // 重要：清除 tag，避免影响后续日志

        let msg = "[\(priority)] \(effectiveTag ?? ""): \(message())"
        os_unfair_lock_lock(&lock)
        buffer.append(msg)
        if buffer.count > maxSize { buffer.removeFirst() }
        os_unfair_lock_unlock(&lock)
    }

    nonisolated func flush() {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        guard let data = buffer.joined(separator: "\n").data(using: .utf8) else { return }
        guard let url = documentsURL()?.appendingPathComponent("canopy_crash_buffer.txt") else { return }
        try? data.write(to: url, options: .atomic)
    }

    nonisolated private func documentsURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    nonisolated public func recentLogs() -> String {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return buffer.joined(separator: "\n")
    }
}

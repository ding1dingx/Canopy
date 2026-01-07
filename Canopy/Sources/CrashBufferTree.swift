//
//  CrashBufferTree.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation

private var crashBufferTreeInstance: CrashBufferTree?

private func crashSignalHandler(_ signal: Int32) {
    crashBufferTreeInstance?.flush()
}

public final class CrashBufferTree: Tree {
    private let maxSize: Int
    private var buffer: [String] = []
    private let lock = NSLock()

    public init(maxSize: Int = 100) {
        self.maxSize = maxSize
        super.init()

        crashBufferTreeInstance = self
        NSSetUncaughtExceptionHandler { _ in
            crashBufferTreeInstance?.flush()
        }

        signal(SIGABRT, crashSignalHandler)
        signal(SIGSEGV, crashSignalHandler)
        signal(SIGBUS, crashSignalHandler)
        signal(SIGFPE, crashSignalHandler)
        signal(SIGILL, crashSignalHandler)
    }

    @MainActor
    deinit {
        crashBufferTreeInstance = nil
    }

    nonisolated(unsafe) public override func log(
        priority: LogLevel,
        tag: String?,
        message: @autoclosure () -> String,
        arguments: [CVarArg],
        error: Error?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        let msg = "[\(priority)] \(tag ?? ""): \(message())"
        lock.lock()
        buffer.append(msg)
        if buffer.count > maxSize { buffer.removeFirst() }
        lock.unlock()
    }

    nonisolated(unsafe) func flush() {
        lock.lock()
        let data = buffer.joined(separator: "\n").data(using: .utf8)!
        lock.unlock()

        if let url = documentsURL()?.appendingPathComponent("canopy_crash_buffer.txt") {
            try? data.write(to: url, options: .atomic)
        }
    }

    nonisolated(unsafe) private func documentsURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    nonisolated(unsafe) public func recentLogs() -> String {
        lock.lock()
        defer { lock.unlock() }
        return buffer.joined(separator: "\n")
    }
}

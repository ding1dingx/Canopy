//
//  DebugTree.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation

#if canImport(os.log)
import os.log
#endif

/// A Tree that logs messages to the system console.
/// Uses os.log on supported platforms, falls back to NSLog.
open class DebugTree: Tree, @unchecked Sendable {

    public override init() {
        super.init()
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
        let effectiveTag = explicitTag ?? tag ?? CanopyContext.current ?? autoTag(from: file)
        explicitTag = nil
        let fullMessage = buildFullMessage(message(), error: error)

        let fileName = (file.withUTF8Buffer { String(decoding: $0, as: UTF8.self) } as NSString).lastPathComponent
        let sourceRef = "\(fileName):\(line)"

        let output: String
        if effectiveTag.isEmpty {
            output = "\(fullMessage) (\(sourceRef))"
        } else {
            output = "[\(effectiveTag)] \(fullMessage) (\(sourceRef))"
        }

        #if canImport(os.log)
        if #available(macOS 11.0, iOS 14.0, *) {
            let subsystem = Bundle.main.bundleIdentifier ?? "com.canopy.logger"
            let logger = Logger(subsystem: subsystem, category: effectiveTag)
            let osLevel: OSLogType = priority.osLogLevel
            logger.log(level: osLevel, "\(output)")
            return
        }
        #endif

        NSLog("%@", output)
    }

    nonisolated private func buildFullMessage(_ message: String, error: Error?) -> String {
        if let err = error {
            return "\(message) | Error: \(err.localizedDescription)"
        }
        return message
    }

    nonisolated private func autoTag(from file: StaticString) -> String {
        let filePath = file.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        return (filePath as NSString).lastPathComponent
            .split(separator: ".")
            .first.map(String.init) ?? "Canopy"
    }
}

private extension LogLevel {
    nonisolated var osLogLevel: OSLogType {
        switch self {
        case .verbose, .debug, .warning: return .debug
        case .info: return .info
        case .error: return .fault
        }
    }
}

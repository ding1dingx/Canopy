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

open class DebugTree: Tree {

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
        let effectiveTag = tag ?? CanopyContext.current ?? autoTag(from: file)
        let fullMessage = buildFullMessage(message(), arguments, error: error)

        let fileName = (file.withUTF8Buffer { String(decoding: $0, as: UTF8.self) } as NSString).lastPathComponent
        let sourceRef = "\(fileName):\(line)"
        let output = "[\(effectiveTag)] \(fullMessage) (\(sourceRef))"

        #if canImport(os.log)
        if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Canopy", category: effectiveTag)
            let osLevel: OSLogType = priority.osLogLevel
            logger.log(level: osLevel, "\(output)")
            return
        }
        #endif

        NSLog("%@", output)
    }

    nonisolated(unsafe) private func buildFullMessage(_ template: String, _ args: [CVarArg], error: Error?) -> String {
        let msg = formatMessage(template, args)
        if let err = error {
            return "\(msg) | Error: \(err.localizedDescription)"
        }
        return msg
    }

    nonisolated(unsafe) private func autoTag(from file: StaticString) -> String {
        let filePath = file.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        return (filePath as NSString).lastPathComponent
            .split(separator: ".")
            .first.map(String.init) ?? "Canopy"
    }
}

private extension LogLevel {
    var osLogLevel: OSLogType {
        switch self {
        case .verbose, .debug: return .debug
        case .info: return .info
        case .warning: return .error
        case .error: return .fault
        }
    }
}

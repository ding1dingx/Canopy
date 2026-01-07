//
//  Tree.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation

open class Tree {
    nonisolated(unsafe) var explicitTag: String?

    @discardableResult
    nonisolated(unsafe) open func tag(_ tag: String?) -> Self {
        self.explicitTag = tag?.isEmpty == false ? tag : nil
        return self
    }

    nonisolated(unsafe) open func isLoggable(priority: LogLevel) -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    nonisolated(unsafe) open func log(
        priority: LogLevel,
        tag: String?,
        message: @autoclosure () -> String,
        arguments: [CVarArg],
        error: Error?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        let msg = formatMessage(message(), arguments)
        log(priority: priority, tag: tag, message: msg, error: error)
    }

    nonisolated(unsafe) open func log(priority: LogLevel, tag: String?, message: String, error: Error?) {}

    nonisolated(unsafe) func prepareLog(
        priority: LogLevel,
        message: @escaping @autoclosure () -> String,
        arguments: [CVarArg],
        error: Error?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        guard isLoggable(priority: priority) else { return }

        let finalTag = explicitTag
        explicitTag = nil

        self.log(
            priority: priority,
            tag: finalTag,
            message: message(),
            arguments: arguments,
            error: error,
            file: file,
            function: function,
            line: line
        )
    }

    nonisolated(unsafe) func formatMessage(_ template: String, _ args: [CVarArg]) -> String {
        guard !args.isEmpty else { return template }
        return String(format: template, arguments: args)
    }
}

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
    nonisolated open func tag(_ tag: String?) -> Self {
        self.explicitTag = tag?.isEmpty == false ? tag : nil
        return self
    }

    nonisolated open func isLoggable(priority: LogLevel) -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    nonisolated open func log(
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

    nonisolated open func log(priority: LogLevel, tag: String?, message: String, error: Error?) {}

    nonisolated func prepareLog(
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

    nonisolated func formatMessage(_ template: String, _ args: [CVarArg]) -> String {
        // Validate inputs to prevent format string issues
        guard !template.isEmpty else { return template }
        guard !args.isEmpty else { return template }
        return String(format: template, arguments: args)
    }
}

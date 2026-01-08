//
//  Tree.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation

/// Base class for all logging trees.
/// Subclasses must ensure thread-safe access to properties using locks.
/// Marked as @unchecked Sendable because subclasses use locks for thread safety.
open class Tree: @unchecked Sendable {
    /// Thread-unsafe tag property - must be protected by locks in subclasses.
    /// Marked as nonisolated(unsafe) because subclasses use locks for thread safety.
    nonisolated(unsafe) var explicitTag: String?
    
    /// Thread-unsafe minimum log level - must be protected by locks in subclasses.
    /// Marked as nonisolated(unsafe) because subclasses use locks for thread safety.
    nonisolated(unsafe) open var minLevel: LogLevel = .verbose

    @discardableResult
    nonisolated open func tag(_ tag: String?) -> Self {
        self.explicitTag = tag?.isEmpty == false ? tag : nil
        return self
    }

    nonisolated open func isLoggable(priority: LogLevel) -> Bool {
        priority >= minLevel
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
        let tagToUse = explicitTag ?? tag
        explicitTag = nil

        let msg = formatMessage(message(), arguments)
        log(priority: priority, tag: tagToUse, message: msg, error: error)
    }

    nonisolated open func log(priority: LogLevel, tag: String?, message: String, error: Error?) {}

    nonisolated func formatMessage(_ template: String, _ args: [CVarArg]) -> String {
        guard !template.isEmpty else { return template }
        guard !args.isEmpty else { return template }

        let specifierCount = template.components(separatedBy: "%").count - 1
        guard specifierCount == args.count else { return template }

        return String(format: template, arguments: args)
    }
}

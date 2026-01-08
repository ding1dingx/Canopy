//
//  Tree.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation

open class Tree {
    nonisolated(unsafe) var explicitTag: String?
    nonisolated(unsafe) open var minLevel: LogLevel = .verbose

    @discardableResult
    nonisolated open func tag(_ tag: String?) -> Self {
        self.explicitTag = tag?.isEmpty == false ? tag : nil
        return self
    }

    nonisolated open func isLoggable(priority: LogLevel) -> Bool {
        return priority >= minLevel
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
        if specifierCount != args.count {
            return template
        }

        return String(format: template, arguments: args)
    }
}

//
//  Canopy.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation

public enum Canopy {
    private static let lock = NSLock()
    private static var trees: [Tree] = []

    public static func plant(_ trees: Tree...) {
        lock.lock()
        defer { lock.unlock() }
        self.trees.append(contentsOf: trees)
    }

    public static func uprootAll() {
        lock.lock()
        defer { lock.unlock() }
        trees.removeAll()
    }

    @discardableResult
    public static func tag(_ tag: String?) -> TaggedTreeProxy {
        return TaggedTreeProxy(tag: tag)
    }

    // MARK: - Log Methods

    public static func v(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        #if DEBUG
        log(LogLevel.verbose, message(), args, file: file, function: function, line: line)
        #else
        if hasNonDebugTrees() {
            log(LogLevel.verbose, message(), args, file: file, function: function, line: line)
        }
        #endif
    }

    public static func d(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        #if DEBUG
        log(LogLevel.debug, message(), args, file: file, function: function, line: line)
        #else
        if hasNonDebugTrees() {
            log(LogLevel.debug, message(), args, file: file, function: function, line: line)
        }
        #endif
    }

    public static func i(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        #if DEBUG
        log(LogLevel.info, message(), args, file: file, function: function, line: line)
        #else
        if hasNonDebugTrees() {
            log(LogLevel.info, message(), args, file: file, function: function, line: line)
        }
        #endif
    }

    public static func w(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        #if DEBUG
        log(LogLevel.warning, message(), args, file: file, function: function, line: line)
        #else
        if hasNonDebugTrees() {
            log(LogLevel.warning, message(), args, file: file, function: function, line: line)
        }
        #endif
    }

    public static func e(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        #if DEBUG
        log(LogLevel.error, message(), args, file: file, function: function, line: line)
        #else
        if hasNonDebugTrees() {
            log(LogLevel.error, message(), args, file: file, function: function, line: line)
        }
        #endif
    }

    // MARK: - Internal Helpers

    private static func hasNonDebugTrees() -> Bool {
        return trees.contains { !($0 is DebugTree) }
    }

    private static func log(
        _ priority: LogLevel,
        _ message: @autoclosure () -> String,
        _ args: [CVarArg],
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        let capturedMessage = message()
        lock.lock()
        let treesToUse = self.trees
        lock.unlock()

        treesToUse.forEach { tree in
            tree.prepareLog(
                priority: priority,
                message: capturedMessage,
                arguments: args,
                error: nil as Error?,
                file: file,
                function: function,
                line: line
            )
        }
    }
}

// MARK: - Proxy for Tagged Logs
public struct TaggedTreeProxy {
    private let tag: String?

    init(tag: String?) {
        self.tag = tag
    }

    public func v(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        Canopy.log(LogLevel.verbose, message(), args, file: file, function: function, line: line, withTag: tag)
    }

    public func d(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        Canopy.log(LogLevel.debug, message(), args, file: file, function: function, line: line, withTag: tag)
    }

    public func i(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        Canopy.log(LogLevel.info, message(), args, file: file, function: function, line: line, withTag: tag)
    }

    public func w(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        Canopy.log(LogLevel.warning, message(), args, file: file, function: function, line: line, withTag: tag)
    }

    public func e(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        Canopy.log(LogLevel.error, message(), args, file: file, function: function, line: line, withTag: tag)
    }
}

// MARK: - Helper for Tagged Logs
fileprivate extension Canopy {
    static func log(
        _ priority: LogLevel,
        _ message: @autoclosure () -> String,
        _ args: [CVarArg],
        file: StaticString,
        function: StaticString,
        line: UInt,
        withTag tag: String?
    ) {
        let capturedMessage = message()
        lock.lock()
        let treesToUse = self.trees
        lock.unlock()

        treesToUse.forEach { tree in
            // Create a temporary tree with the tag
            let taggedTree = tree.tag(tag)
            taggedTree.prepareLog(
                priority: priority,
                message: capturedMessage,
                arguments: args,
                error: nil as Error?,
                file: file,
                function: function,
                line: line
            )
        }
    }
}

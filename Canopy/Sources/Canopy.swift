//
//  Canopy.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation
import os

// MARK: - Proxy for Tagged Logs (forward declaration needed)

/// A proxy that adds a tag to all subsequent log calls.
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

/// The main entry point for the Canopy logging framework.
/// All logging operations go through this enum.
public enum Canopy {
    private static let lock: NSLock = NSLock()
    private static var trees: [Tree] = []
    private static var cachedHasNonDebugTrees: Bool = false
    private static var needsRecalc: Bool = true

    public static func plant(_ trees: Tree...) {
        lock.lock()
        defer { lock.unlock() }
        self.trees.append(contentsOf: trees)
        needsRecalc = true
    }

    public static func uprootAll() {
        lock.lock()
        defer { lock.unlock() }
        trees.removeAll()
        needsRecalc = true
    }

    @discardableResult
    public static func tag(_ tag: String?) -> TaggedTreeProxy {
        TaggedTreeProxy(tag: tag)
    }

    // MARK: - Log Methods

    public static func v(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        log(LogLevel.verbose, message(), args, file: file, function: function, line: line)
    }

    public static func d(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        log(LogLevel.debug, message(), args, file: file, function: function, line: line)
    }

    public static func i(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        log(LogLevel.info, message(), args, file: file, function: function, line: line)
    }

    public static func w(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        log(LogLevel.warning, message(), args, file: file, function: function, line: line)
    }

    public static func e(_ message: @autoclosure () -> String, _ args: CVarArg..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        log(LogLevel.error, message(), args, file: file, function: function, line: line)
    }

    // MARK: - Internal Helpers

    private static func hasNonDebugTrees() -> Bool {
        if needsRecalc {
            lock.lock()
            cachedHasNonDebugTrees = !trees.isEmpty && !trees.allSatisfy { $0 is DebugTree }
            needsRecalc = false
            lock.unlock()
        }
        return cachedHasNonDebugTrees
    }

    fileprivate static func log(
        _ priority: LogLevel,
        _ message: String,
        _ args: [CVarArg],
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        #if !DEBUG
        guard hasNonDebugTrees() else { return }
        #endif

        let treesToUse: [Tree]
        lock.lock()
        treesToUse = trees
        lock.unlock()

        for tree in treesToUse {
            guard tree.isLoggable(priority: priority) else { continue }
            tree.log(
                priority: priority,
                tag: nil,
                message: message,
                arguments: args,
                error: nil,
                file: file,
                function: function,
                line: line
            )
        }
    }

    fileprivate static func log(
        _ priority: LogLevel,
        _ message: String,
        _ args: [CVarArg],
        file: StaticString,
        function: StaticString,
        line: UInt,
        withTag tag: String?
    ) {
        #if !DEBUG
        guard hasNonDebugTrees() else { return }
        #endif

        let treesToUse: [Tree]
        lock.lock()
        treesToUse = trees
        lock.unlock()

        for tree in treesToUse {
            guard tree.isLoggable(priority: priority) else { continue }
            let taggedTree = tree.tag(tag)
            taggedTree.log(
                priority: priority,
                tag: nil,
                message: message,
                arguments: args,
                error: nil,
                file: file,
                function: function,
                line: line
            )
        }
    }
}

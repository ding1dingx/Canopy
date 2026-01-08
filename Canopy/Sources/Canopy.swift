//
//  Canopy.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation
import os

public enum Canopy {
    private static var lock = os_unfair_lock()
    private static var trees: [Tree] = []
    private static var cachedHasNonDebugTrees = false
    private static var needsRecalc = true

    public static func plant(_ trees: Tree...) {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        self.trees.append(contentsOf: trees)
        needsRecalc = true
    }

    public static func uprootAll() {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        trees.removeAll()
        needsRecalc = true
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
        if needsRecalc {
            os_unfair_lock_lock(&lock)
            cachedHasNonDebugTrees = trees.contains { !isDebugTree($0) }
            needsRecalc = false
            os_unfair_lock_unlock(&lock)
        }
        return cachedHasNonDebugTrees
    }

    private static func isDebugTree(_ tree: Tree) -> Bool {
        return tree is DebugTree
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
        os_unfair_lock_lock(&lock)
        let treesToUse = self.trees
        os_unfair_lock_unlock(&lock)

        treesToUse.forEach { tree in
            guard tree.isLoggable(priority: priority) else { return }
            tree.log(
                priority: priority,
                tag: nil,
                message: capturedMessage,
                arguments: args,
                error: nil,
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
        os_unfair_lock_lock(&lock)
        let treesToUse = self.trees
        os_unfair_lock_unlock(&lock)

        treesToUse.forEach { tree in
            guard tree.isLoggable(priority: priority) else { return }
            let taggedTree = tree.tag(tag)
            taggedTree.log(
                priority: priority,
                tag: nil,
                message: capturedMessage,
                arguments: args,
                error: nil,
                file: file,
                function: function,
                line: line
            )
        }
    }
}

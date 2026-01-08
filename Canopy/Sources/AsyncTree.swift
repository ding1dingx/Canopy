//
//  AsyncTree.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation

public final class AsyncTree: Tree {
    private let wrapped: Tree
    private let queue: DispatchQueue

    public init(wrapping tree: Tree, on queue: DispatchQueue = .global(qos: .utility)) {
        self.wrapped = tree
        self.queue = queue
        super.init()
    }

    nonisolated public override func isLoggable(priority: LogLevel) -> Bool {
        wrapped.isLoggable(priority: priority)
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
        let currentContext = CanopyContext.current
        let capturedTag = explicitTag
        explicitTag = nil
        let capturedMessage = formatMessage(message(), arguments)

        queue.async {
            let previous = CanopyContext.current
            CanopyContext.current = currentContext

            self.wrapped.log(
                priority: priority,
                tag: capturedTag,
                message: capturedMessage,
                arguments: arguments,
                error: error,
                file: file,
                function: function,
                line: line
            )

            CanopyContext.current = previous
        }
    }
}

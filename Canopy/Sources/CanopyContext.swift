//
//  CanopyContext.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum CanopyContext {
    nonisolated private static let threadKey: String = "CanopyContext.current"

    nonisolated static var current: String? {
        get {
            Thread.current.threadDictionary[threadKey] as? String
        }
        set {
            Thread.current.threadDictionary[threadKey] = newValue
        }
    }

    /// Execute a block with a scoped context tag.
    /// The context is automatically restored after the block completes,
    /// even if an error occurs.
    ///
    /// ```swift
    /// // Automatically manages context lifecycle
    /// CanopyContext.with("Network") {
    ///     Canopy.i("Request started")  // Tag: "Network"
    ///     Canopy.i("Request completed")  // Tag: "Network"
    /// }  // Context automatically restored
    ///
    /// Canopy.i("Back to previous context")  // No tag
    /// ```
    ///
    /// - Parameters:
    ///   - tag: The context tag to set for the duration of the block
    ///   - block: The code block to execute with the scoped context
    /// - Returns: The return value of the block
    @discardableResult
    nonisolated static func with<T>(_ tag: String?, block: () throws -> T) rethrows -> T {
        let previous = current
        current = tag
        defer { current = previous }
        return try block()
    }

    #if canImport(UIKit)
    static func push(viewController: UIViewController) {
        current = String(describing: type(of: viewController))
    }

    static func push(scrollView: UIScrollView) {
        current = "ScrollView.\(scrollView.hash)"
    }
    #endif
}

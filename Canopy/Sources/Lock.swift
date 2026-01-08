//
//  Lock.swift
//  Canopy
//
//  Created by syxc on 2026-01-09.
//

import Foundation

extension NSLock {
    /// Executes a closure while holding the lock.
    /// - Parameter body: The closure to execute.
    /// - Returns: The return value of the closure.
    @inline(__always)
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}

//
//  LogLevel.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation

public enum LogLevel: Int, CaseIterable, Comparable, Sendable {
    case verbose = 2
    case debug = 3
    case info = 4
    case warning = 5
    case error = 6

    nonisolated public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

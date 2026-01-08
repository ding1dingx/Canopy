//
//  CanopyBenchmarkTests.swift
//  CanopyTests
//
//  Created by syxc on 2026-01-09.
//

import XCTest
@testable import Canopy

/// Performance benchmark tests for Canopy logging framework.
/// Run with: swift test --filter CanopyBenchmarkTests
final class CanopyBenchmarkTests: XCTestCase {

    // MARK: - Log Method Benchmarks

    func testLogPerformance_noArgs() {
        let tree = BenchmarkTestTree()
        measure {
            for _ in 0..<10_000 {
                tree.log(
                    priority: .debug,
                    tag: nil,
                    message: "Test message",
                    arguments: [],
                    error: nil,
                    file: #file,
                    function: #function,
                    line: #line
                )
            }
        }
    }

    func testLogPerformance_singleArg() {
        let tree = BenchmarkTestTree()
        measure {
            for _ in 0..<10_000 {
                tree.log(
                    priority: .debug,
                    tag: nil,
                    message: "User %@ logged in",
                    arguments: ["Alice"],
                    error: nil,
                    file: #file,
                    function: #function,
                    line: #line
                )
            }
        }
    }

    func testLogPerformance_multipleArgs() {
        let tree = BenchmarkTestTree()
        measure {
            for _ in 0..<10_000 {
                tree.log(
                    priority: .debug,
                    tag: nil,
                    message: "User %@ logged in from %@ at %@",
                    arguments: ["Alice", "NYC", "10:00"],
                    error: nil,
                    file: #file,
                    function: #function,
                    line: #line
                )
            }
        }
    }

    // MARK: - Format Message Benchmarks

    func testFormatMessagePerformance_noArgs() {
        let tree = BenchmarkTestTree()
        measure {
            for _ in 0..<10_000 {
                _ = tree.formatMessage("Simple message without args", [])
            }
        }
    }

    func testFormatMessagePerformance_emptyTemplate() {
        let tree = BenchmarkTestTree()
        measure {
            for _ in 0..<10_000 {
                _ = tree.formatMessage("", ["arg"])
            }
        }
    }

    func testFormatMessagePerformance_mismatchedArgs() {
        let tree = BenchmarkTestTree()
        measure {
            for _ in 0..<10_000 {
                _ = tree.formatMessage("User %@ logged in", ["Alice", "Extra"])
            }
        }
    }

    // MARK: - Canopy API Benchmarks

    func testCanopyPerformance_noTree() {
        Canopy.uprootAll()
        measure {
            for _ in 0..<1_000 {
                Canopy.v("Benchmark test message")
            }
        }
    }

    func testCanopyPerformance_withDebugTree() {
        Canopy.uprootAll()
        Canopy.plant(DebugTree())
        measure {
            for _ in 0..<1_000 {
                Canopy.v("Benchmark test message")
            }
        }
        Canopy.uprootAll()
    }

    func testCanopyPerformance_withTagParameter() {
        Canopy.uprootAll()
        Canopy.plant(DebugTree())
        measure {
            for _ in 0..<1_000 {
                Canopy.v("Benchmark test message", tag: "Performance")
            }
        }
        Canopy.uprootAll()
    }

    func testCanopyPerformance_tagMethod() {
        Canopy.uprootAll()
        Canopy.plant(DebugTree())
        measure {
            for _ in 0..<1_000 {
                Canopy.tag("Performance").v("Benchmark test message")
            }
        }
        Canopy.uprootAll()
    }

    // MARK: - AsyncTree Benchmarks

    func testAsyncTreePerformance() {
        let tree = BenchmarkTestTree()
        let asyncTree = AsyncTree(wrapping: tree)
        measure {
            for i in 0..<1_000 {
                asyncTree.log(
                    priority: .debug,
                    tag: nil,
                    message: "Async log \(i)",
                    arguments: [],
                    error: nil,
                    file: #file,
                    function: #function,
                    line: #line
                )
            }
        }
    }

    // MARK: - Tree Operations Benchmarks

    func testTagPerformance() {
        let tree = BenchmarkTestTree()
        measure {
            for i in 0..<10_000 {
                _ = tree.tag("Tag\(i)")
            }
        }
    }

    func testIsLoggablePerformance() {
        let tree = BenchmarkTestTree()
        tree.minLevel = .info
        measure {
            for _ in 0..<10_000 {
                _ = tree.isLoggable(priority: .debug)
                _ = tree.isLoggable(priority: .error)
            }
        }
    }

    // MARK: - Concurrency Benchmarks

    func testConcurrentLoggingPerformance() {
        Canopy.uprootAll()
        Canopy.plant(DebugTree())

        let iterations = 1_000
        let queue = DispatchQueue(label: "com.canopy.benchmark", attributes: .concurrent)

        measure {
            let group = DispatchGroup()
            for _ in 0..<10 {
                group.enter()
                queue.async {
                    for i in 0..<iterations {
                        Canopy.v("Concurrent log \(i)")
                    }
                    group.leave()
                }
            }
            group.wait()
        }

        Canopy.uprootAll()
    }

    func testConcurrentTaggedLoggingPerformance() {
        Canopy.uprootAll()
        Canopy.plant(DebugTree())

        let iterations = 1_000
        let queue = DispatchQueue(label: "com.canopy.benchmark.tagged", attributes: .concurrent)

        measure {
            let group = DispatchGroup()
            for tag in ["Network", "Database", "UI", "Auth"] {
                group.enter()
                queue.async {
                    for i in 0..<iterations {
                        Canopy.v("Log \(i)", tag: tag)
                    }
                    group.leave()
                }
            }
            group.wait()
        }

        Canopy.uprootAll()
    }
}

// MARK: - Test Tree Helper

private final class BenchmarkTestTree: Tree {
    var logs: [(LogLevel, String)] = []

    nonisolated override func log(priority: LogLevel, tag: String?, message: String, error: Error?) {
        // No-op for benchmarks
    }
}

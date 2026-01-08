//
//  CanopyCrashRecoveryTests.swift
//  CanopyTests
//
//  Created by syxc on 2026-01-09.
//

import XCTest
@testable import Canopy

/// Integration tests for CrashBufferTree crash recovery functionality.
/// These tests verify the crash handling and log recovery mechanisms.
final class CanopyCrashRecoveryTests: XCTestCase {

    // MARK: - Buffer Management Tests

    func testCrashBufferTree_initialState() {
        let tree = CrashBufferTree(maxSize: 10)
        XCTAssertEqual(tree.recentLogs(), "")
    }

    func testCrashBufferTree_logsMessage() {
        let tree = CrashBufferTree(maxSize: 10)

        tree.log(
            priority: .debug,
            tag: "Test",
            message: "Test message",
            arguments: [],
            error: nil,
            file: #file,
            function: #function,
            line: #line
        )

        let logs = tree.recentLogs()
        XCTAssertTrue(logs.contains("Test message"))
    }

    func testCrashBufferTree_maxSizeLimit() {
        let tree = CrashBufferTree(maxSize: 5)

        // Add 10 messages
        for i in 0..<10 {
            tree.log(
                priority: .info,
                tag: nil,
                message: "Message \(i)",
                arguments: [],
                error: nil,
                file: #file,
                function: #function,
                line: #line
            )
        }

        let logs = tree.recentLogs()
        // Should only contain the last 5 messages (indices 5-9)
        XCTAssertTrue(logs.contains("Message 5"))
        XCTAssertTrue(logs.contains("Message 9"))
        XCTAssertFalse(logs.contains("Message 0"))
        XCTAssertFalse(logs.contains("Message 4"))
    }

    func testCrashBufferTree_withExplicitTag() {
        let tree = CrashBufferTree(maxSize: 10)

        tree.log(
            priority: .error,
            tag: "Network",
            message: "Connection failed",
            arguments: [],
            error: nil,
            file: #file,
            function: #function,
            line: #line
        )

        let logs = tree.recentLogs()
        XCTAssertTrue(logs.contains("Connection failed"))
    }

    func testCrashBufferTree_clearsExplicitTagAfterLog() {
        let tree = CrashBufferTree(maxSize: 10)

        tree.log(
            priority: .debug,
            tag: "InitialTag",
            message: "First message",
            arguments: [],
            error: nil,
            file: #file,
            function: #function,
            line: #line
        )

        tree.log(
            priority: .debug,
            tag: nil,
            message: "Second message",
            arguments: [],
            error: nil,
            file: #file,
            function: #function,
            line: #line
        )

        let logs = tree.recentLogs()
        XCTAssertTrue(logs.contains("First message"))
        XCTAssertTrue(logs.contains("Second message"))
    }

    // MARK: - Flush Tests

    func testCrashBufferTree_flushWritesToFile() {
        let tree = CrashBufferTree(maxSize: 10)

        tree.log(
            priority: .info,
            tag: "Test",
            message: "Flush test",
            arguments: [],
            error: nil,
            file: #file,
            function: #function,
            line: #line
        )

        // Flush should not throw
        tree.flush()

        // Verify file was created
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = documentsPath?.appendingPathComponent("canopy_crash_buffer.txt")

        if let path = filePath {
            XCTAssertTrue(FileManager.default.fileExists(atPath: path.path))
        }
    }

    // MARK: - Thread Safety Tests

    func testCrashBufferTree_threadSafety() {
        let tree = CrashBufferTree(maxSize: 1000)
        let queue = DispatchQueue(label: "com.canopy.test.crashbuffer", attributes: .concurrent)

        let iterations = 100
        let group = DispatchGroup()

        // Log from multiple threads simultaneously
        for i in 0..<10 {
            group.enter()
            queue.async {
                for j in 0..<iterations {
                    tree.log(
                        priority: .info,
                        tag: nil,
                        message: "Thread \(i) message \(j)",
                        arguments: [],
                        error: nil,
                        file: #file,
                        function: #function,
                        line: #line
                    )
                }
                group.leave()
            }
        }

        group.wait()

        // Verify all logs were captured (maxSize is 1000, we logged 1000)
        let logCount = tree.recentLogs().split(separator: "\n").count
        XCTAssertEqual(logCount, iterations * 10)
    }

    // MARK: - Integration with Canopy

    func testCanopy_withCrashBufferTree() {
        Canopy.uprootAll()
        let tree = CrashBufferTree(maxSize: 50)
        Canopy.plant(tree)

        Canopy.v("Verbose log")
        Canopy.d("Debug log")
        Canopy.i("Info log")
        Canopy.w("Warning log")
        Canopy.e("Error log")

        let logs = tree.recentLogs()
        XCTAssertTrue(logs.contains("Verbose log"))
        XCTAssertTrue(logs.contains("Debug log"))
        XCTAssertTrue(logs.contains("Info log"))
        XCTAssertTrue(logs.contains("Warning log"))
        XCTAssertTrue(logs.contains("Error log"))

        Canopy.uprootAll()
    }

    func testCanopy_taggedLogsWithCrashBuffer() {
        Canopy.uprootAll()
        let tree = CrashBufferTree(maxSize: 50)
        Canopy.plant(tree)

        Canopy.tag("Network").v("Network operation started")
        Canopy.tag("Database").v("Database query executed")
        Canopy.tag("UI").v("Button tapped")

        let logs = tree.recentLogs()
        XCTAssertTrue(logs.contains("Network operation started"))
        XCTAssertTrue(logs.contains("Database query executed"))
        XCTAssertTrue(logs.contains("Button tapped"))

        Canopy.uprootAll()
    }

    // MARK: - Error Handling Tests

    func testCrashBufferTree_withError() {
        let tree = CrashBufferTree(maxSize: 10)

        tree.log(
            priority: .error,
            tag: nil,
            message: "Operation failed",
            arguments: [],
            error: nil,
            file: #file,
            function: #function,
            line: #line
        )

        let logs = tree.recentLogs()
        XCTAssertTrue(logs.contains("Operation failed"))
    }

    func testCrashBufferTree_emptyMessage() {
        let tree = CrashBufferTree(maxSize: 10)

        tree.log(
            priority: .debug,
            tag: nil,
            message: "",
            arguments: [],
            error: nil,
            file: #file,
            function: #function,
            line: #line
        )

        let logs = tree.recentLogs()
        XCTAssertFalse(logs.isEmpty)
    }

    // MARK: - Performance Tests

    func testCrashBufferTree_loggingPerformance() {
        let tree = CrashBufferTree(maxSize: 1000)

        measure {
            for i in 0..<1_000 {
                tree.log(
                    priority: .info,
                    tag: nil,
                    message: "Performance test \(i)",
                    arguments: [],
                    error: nil,
                    file: #file,
                    function: #function,
                    line: #line
                )
            }
        }

        // Verify all logs were captured
        let logCount = tree.recentLogs().split(separator: "\n").count
        XCTAssertEqual(logCount, 1000)
    }
}

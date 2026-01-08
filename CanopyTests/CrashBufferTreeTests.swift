//
//  CrashBufferTreeTests.swift
//  CanopyTests
//
//  Tests for CrashBufferTree functionality
//

import XCTest
@testable import Canopy

final class CrashBufferTreeTests: XCTestCase {

    override func setUpWithError() throws {
        Canopy.uprootAll()
    }

    override func tearDownWithError() throws {
        Canopy.uprootAll()
    }

    // MARK: - Initialization Tests

    func testCrashBufferTreeInitialization() {
        let crashTree = CrashBufferTree(maxSize: 50)

        XCTAssertNotNil(crashTree)
    }

    func testCrashBufferTreeDefaultMaxSize() {
        let crashTree = CrashBufferTree()

        XCTAssertNotNil(crashTree)
    }

    // MARK: - Buffer Tests

    func testCrashBufferTreeStoresLogs() {
        let crashTree = CrashBufferTree(maxSize: 10)
        Canopy.plant(crashTree)

        Canopy.d("Message 1")
        Canopy.i("Message 2")
        Canopy.w("Message 3")

        let logs = crashTree.recentLogs()
        XCTAssertTrue(logs.contains("[debug] : Message 1"))
        XCTAssertTrue(logs.contains("[info] : Message 2"))
        XCTAssertTrue(logs.contains("[warning] : Message 3"))
    }

    func testCrashBufferTreeMaxSize() {
        let crashTree = CrashBufferTree(maxSize: 5)
        Canopy.plant(crashTree)

        for i in 0..<10 {
            Canopy.d("Message \(i)")
        }

        let logs = crashTree.recentLogs()
        let logLines = logs.components(separatedBy: "\n").filter { !$0.isEmpty }

        XCTAssertEqual(logLines.count, 5)
        XCTAssertFalse(logs.contains("Message 0"))
        XCTAssertFalse(logs.contains("Message 1"))
        XCTAssertFalse(logs.contains("Message 2"))
        XCTAssertFalse(logs.contains("Message 3"))
        XCTAssertFalse(logs.contains("Message 4"))
        XCTAssertTrue(logs.contains("Message 5"))
        XCTAssertTrue(logs.contains("Message 9"))
    }

    func testCrashBufferTreeOldestLogsRemoved() {
        let crashTree = CrashBufferTree(maxSize: 3)
        Canopy.plant(crashTree)

        Canopy.d("Message 1")
        Canopy.d("Message 2")
        Canopy.d("Message 3")
        Canopy.d("Message 4")

        let logs = crashTree.recentLogs()

        XCTAssertFalse(logs.contains("Message 1"))
        XCTAssertTrue(logs.contains("Message 2"))
        XCTAssertTrue(logs.contains("Message 3"))
        XCTAssertTrue(logs.contains("Message 4"))
    }

    // MARK: - Tag Tests

    func testCrashBufferTreeWithTag() {
        let crashTree = CrashBufferTree()
        Canopy.plant(crashTree)

        Canopy.tag("Network").d("Request started")

        let logs = crashTree.recentLogs()
        XCTAssertTrue(logs.contains("Network"))
    }

    // MARK: - Min Level Tests

    func testCrashBufferTreeRespectsMinLevel() {
        let crashTree = CrashBufferTree()
        crashTree.minLevel = .warning
        Canopy.plant(crashTree)

        Canopy.v("Verbose")
        Canopy.d("Debug")
        Canopy.i("Info")
        Canopy.w("Warning")
        Canopy.e("Error")

        let logs = crashTree.recentLogs()

        XCTAssertFalse(logs.contains("[verbose]"))
        XCTAssertFalse(logs.contains("[debug]"))
        XCTAssertFalse(logs.contains("[info]"))
        XCTAssertTrue(logs.contains("[warning]"))
        XCTAssertTrue(logs.contains("[error]"))
    }

    // MARK: - Flush Tests

    func testCrashBufferTreeFlush() {
        let crashTree = CrashBufferTree()
        Canopy.plant(crashTree)

        Canopy.d("Message 1")
        Canopy.d("Message 2")

        XCTAssertNoThrow(crashTree.flush())

        let logs = crashTree.recentLogs()
        XCTAssertTrue(logs.contains("Message 1"))
        XCTAssertTrue(logs.contains("Message 2"))
    }

    // MARK: - Thread Safety Tests

    func testCrashBufferTreeThreadSafety() {
        let crashTree = CrashBufferTree(maxSize: 100)
        Canopy.plant(crashTree)

        let expectation = XCTestExpectation(description: "Thread safety test")
        expectation.expectedFulfillmentCount = 10

        let queue = DispatchQueue.global(qos: .userInitiated)
        for i in 0..<10 {
            queue.async {
                for j in 0..<100 {
                    Canopy.d("Thread \(i), Log \(j)")
                }
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            let logs = crashTree.recentLogs()
            let logLines = logs.components(separatedBy: "\n").filter { !$0.isEmpty }
            XCTAssertEqual(logLines.count, 100)
        }
    }
}

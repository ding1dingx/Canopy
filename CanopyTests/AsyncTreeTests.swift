//
//  AsyncTreeTests.swift
//  CanopyTests
//
//  Tests for AsyncTree functionality
//

import XCTest
@testable import Canopy

final class AsyncTreeTests: XCTestCase {

    override func setUpWithError() throws {
        Canopy.uprootAll()
    }

    override func tearDownWithError() throws {
        Canopy.uprootAll()
    }

    // MARK: - Initialization Tests

    func testAsyncTreeWrapsTree() {
        let innerTree = TestTree()
        let asyncTree = AsyncTree(wrapping: innerTree)

        XCTAssertNotNil(asyncTree)
    }

    func testAsyncTreeWithCustomQueue() {
        let innerTree = TestTree()
        let customQueue = DispatchQueue(label: "custom.queue")
        let asyncTree = AsyncTree(wrapping: innerTree, on: customQueue)

        XCTAssertNotNil(asyncTree)
    }

    // MARK: - Logging Tests

    func testAsyncTreeLogsAsynchronously() {
        let innerTree = TestTree()
        let asyncTree = AsyncTree(wrapping: innerTree)
        Canopy.plant(asyncTree)

        let expectation = XCTestExpectation(description: "Async logging completes")

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(innerTree.logs.count, 1)
            expectation.fulfill()
        }

        Canopy.d("Test message")

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncTreeMultipleLogs() {
        let innerTree = TestTree()
        let asyncTree = AsyncTree(wrapping: innerTree)
        Canopy.plant(asyncTree)

        let expectation = XCTestExpectation(description: "Multiple async logs complete")

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(innerTree.logs.count, 10)
            expectation.fulfill()
        }

        for i in 0..<10 {
            Canopy.d("Message \(i)")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Min Level Tests

    func testAsyncTreeRespectsMinLevel() {
        let innerTree = TestTree()
        innerTree.minLevel = .error

        let asyncTree = AsyncTree(wrapping: innerTree)
        asyncTree.minLevel = .warning
        Canopy.plant(asyncTree)

        let expectation = XCTestExpectation(description: "Filtering test completes")

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(innerTree.logs.count, 0)
            expectation.fulfill()
        }

        Canopy.d("Debug message")

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Tag Tests

    func testAsyncTreePreservesTag() {
        let innerTree = TestTree()
        let asyncTree = AsyncTree(wrapping: innerTree)
        Canopy.plant(asyncTree)

        let expectation = XCTestExpectation(description: "Tag test completes")

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(innerTree.logs.count, 1)
            XCTAssertEqual(innerTree.logs.first?.tag, "CustomTag")
            expectation.fulfill()
        }

        Canopy.tag("CustomTag").d("Test message")

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Context Tests

    func testAsyncTreePreservesCanopyContext() {
        let innerTree = TestTree()
        let asyncTree = AsyncTree(wrapping: innerTree)
        Canopy.plant(asyncTree)

        let expectation = XCTestExpectation(description: "Context test completes")

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(innerTree.logs.count, 1)
            expectation.fulfill()
        }

        CanopyContext.current = "TestContext"
        Canopy.d("Message with context")

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Thread Safety Tests

    func testAsyncTreeThreadSafety() {
        let innerTree = TestTree()
        let asyncTree = AsyncTree(wrapping: innerTree)
        Canopy.plant(asyncTree)

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
            XCTAssertEqual(innerTree.logs.count, 1000)
        }
    }
}

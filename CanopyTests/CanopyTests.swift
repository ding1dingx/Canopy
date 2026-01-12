import XCTest
@testable import Canopy

final class CanopyTests: XCTestCase {

    override func setUpWithError() throws {
        Canopy.uprootAll()
    }

    override func tearDownWithError() throws {
        Canopy.uprootAll()
    }

    func testPlantAndUproot() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        Canopy.d("Test")

        XCTAssertEqual(tree.logs.count, 1)

        Canopy.uprootAll()

        Canopy.d("After uproot")

        XCTAssertEqual(tree.logs.count, 1)
    }

    func testUprootAll() throws {
        let tree1 = TestTree()
        let tree2 = TestTree()
        Canopy.plant(tree1, tree2)

        Canopy.d("Test")

        XCTAssertEqual(tree1.logs.count, 1)
        XCTAssertEqual(tree2.logs.count, 1)

        Canopy.uprootAll()

        Canopy.d("After uprootAll")

        XCTAssertEqual(tree1.logs.count, 1)
        XCTAssertEqual(tree2.logs.count, 1)
    }

    func testPlantMultipleTrees() throws {
        let tree1 = TestTree()
        let tree2 = TestTree()
        let tree3 = TestTree()

        Canopy.plant(tree1, tree2, tree3)

        tree1.log(priority: .debug, tag: nil, message: "Test1", error: nil)
        tree2.log(priority: .debug, tag: nil, message: "Test2", error: nil)
        tree3.log(priority: .debug, tag: nil, message: "Test3", error: nil)

        XCTAssertEqual(tree1.logs.count, 1)
        XCTAssertEqual(tree2.logs.count, 1)
        XCTAssertEqual(tree3.logs.count, 1)
    }

    func testCannotPlantItself() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        tree.log(priority: .debug, tag: nil, message: "Test", error: nil)

        XCTAssertEqual(tree.logs.count, 1)
    }

    func testVerboseLogging() throws {
        let tree = TestTree()
        tree.minLevel = .verbose
        Canopy.plant(tree)

        Canopy.v("Verbose message")
        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.level, .verbose)
    }

    func testDebugLogging() throws {
        let tree = TestTree()
        tree.minLevel = .debug
        Canopy.plant(tree)

        Canopy.d("Debug message")
        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.level, .debug)
    }

    func testInfoLogging() throws {
        let tree = TestTree()
        tree.minLevel = .info
        Canopy.plant(tree)

        Canopy.i("Info message")
        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.level, .info)
    }

    func testWarningLogging() throws {
        let tree = TestTree()
        tree.minLevel = .warning
        Canopy.plant(tree)

        Canopy.w("Warning message")
        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.level, .warning)
    }

    func testErrorLogging() throws {
        let tree = TestTree()
        tree.minLevel = .error
        Canopy.plant(tree)

        Canopy.e("Error message")
        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.level, .error)
    }

    func testMinLevelFiltering() throws {
        let tree = TestTree()
        tree.minLevel = .warning
        Canopy.plant(tree)

        Canopy.v("Verbose")
        Canopy.d("Debug")
        Canopy.i("Info")
        Canopy.w("Warning")
        Canopy.e("Error")

        XCTAssertEqual(tree.logs.count, 2)
        XCTAssertEqual(tree.logs[0].level, .warning)
        XCTAssertEqual(tree.logs[1].level, .error)
    }

    func testFormattedLogging() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        Canopy.d("User %@ has %lld items", "Alice", 5)

        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertTrue(tree.logs.first?.message.contains("Alice") ?? false)
        XCTAssertTrue(tree.logs.first?.message.contains("5") ?? false)
    }

    func testTaggedLogging() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        Canopy.tag("Network").d("Request started")

        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.tag, "Network")
    }

    func testTaggedLoggingChaining() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        Canopy.tag("API").i("User %@ logged in", "Bob")
        Canopy.tag("DB").w("Slow query detected")

        XCTAssertEqual(tree.logs.count, 2)
        XCTAssertEqual(tree.logs[0].tag, "API")
        XCTAssertEqual(tree.logs[1].tag, "DB")
    }

    func testEmptyTag() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        Canopy.tag("").d("Message with empty tag")

        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertNil(tree.logs.first?.tag)
    }

    func testMultipleTreesReceiveLogs() throws {
        let tree1 = TestTree()
        let tree2 = TestTree()

        Canopy.plant(tree1, tree2)

        Canopy.i("Test message")

        XCTAssertEqual(tree1.logs.count, 1)
        XCTAssertEqual(tree2.logs.count, 1)
    }

    func testDifferentMinLevelsForTrees() throws {
        let tree1 = TestTree()
        tree1.minLevel = .verbose

        let tree2 = TestTree()
        tree2.minLevel = .error

        Canopy.plant(tree1, tree2)

        Canopy.d("Debug message")
        Canopy.e("Error message")

        XCTAssertEqual(tree1.logs.count, 2)
        XCTAssertEqual(tree2.logs.count, 1)
        XCTAssertEqual(tree2.logs.first?.level, .error)
    }

    func testLogLocationInfo() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        Canopy.d("Test message")

        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertNotNil(tree.logs.first?.file)
        XCTAssertNotNil(tree.logs.first?.function)
        XCTAssertNotNil(tree.logs.first?.line)
    }

    func testTreeWithTagOverride() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        tree.tag("CustomTag")

        Canopy.d("Message")

        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.tag, "CustomTag")
    }

    func testTreeTagIsClearedAfterUse() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        tree.tag("Tag1")
        Canopy.d("Message 1")
        XCTAssertEqual(tree.logs.first?.tag, "Tag1")

        Canopy.d("Message 2")
        XCTAssertNil(tree.logs[1].tag)
    }

    func testLogLevelComparison() throws {
        XCTAssertLessThan(LogLevel.verbose, LogLevel.debug)
        XCTAssertLessThan(LogLevel.debug, LogLevel.info)
        XCTAssertLessThan(LogLevel.info, LogLevel.warning)
        XCTAssertLessThan(LogLevel.warning, LogLevel.error)
    }

    func testLogLevelEquality() throws {
        XCTAssertEqual(LogLevel.verbose, LogLevel.verbose)
        XCTAssertNotEqual(LogLevel.verbose, LogLevel.debug)
    }

    func testHighVolumeLogging() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        let count = 1000
        for i in 0..<count {
            Canopy.d("Log entry \(i)")
        }

        XCTAssertEqual(tree.logs.count, count)
    }

    func testThreadSafety() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        let expectation = XCTestExpectation(description: "Thread safety test")
        expectation.expectedFulfillmentCount = 10

        let queue = DispatchQueue.global(qos: .userInitiated)
        for _ in 0..<10 {
            queue.async {
                for i in 0..<100 {
                    Canopy.d("Thread log \(i)")
                }
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)

        XCTAssertEqual(tree.logs.count, 1000)
    }

    func testCanopyContextWithScopedTag() throws {
        CanopyContext.current = nil  // Ensure clean state
        XCTAssertNil(CanopyContext.current)

        let result = CanopyContext.with("ScopedTag") {
            XCTAssertEqual(CanopyContext.current, "ScopedTag")
            return "completed"
        }

        XCTAssertEqual(result, "completed")
        XCTAssertNil(CanopyContext.current, "Context should be restored after with()")
    }

    func testCanopyContextWithNilTag() throws {
        CanopyContext.current = nil  // Ensure clean state

        let result = CanopyContext.with(nil) {
            XCTAssertNil(CanopyContext.current)
            return "nil-tag"
        }

        XCTAssertEqual(result, "nil-tag")
        XCTAssertNil(CanopyContext.current, "Previous context should be restored")
    }

    func testCanopyContextWithNestedScopes() throws {
        CanopyContext.current = nil  // Ensure clean state

        let result = CanopyContext.with("Middle") {
            XCTAssertEqual(CanopyContext.current, "Middle")

            let inner = CanopyContext.with("Inner") {
                XCTAssertEqual(CanopyContext.current, "Inner")
                return "inner-completed"
            }

            XCTAssertEqual(inner, "inner-completed")
            XCTAssertEqual(CanopyContext.current, "Middle", "Should restore to Middle scope")
            return "middle-completed"
        }

        XCTAssertEqual(result, "middle-completed")
        XCTAssertNil(CanopyContext.current, "Should restore to nil")
    }

    func testCanopyContextWithErrorHandling() throws {
        CanopyContext.current = nil  // Ensure clean state
        XCTAssertNil(CanopyContext.current)

        do {
            try CanopyContext.with("ErrorScope") {
                XCTAssertEqual(CanopyContext.current, "ErrorScope")
                throw NSError(domain: "Test", code: 1, userInfo: nil)
            }
        } catch {
            // Expected error
        }

        XCTAssertNil(CanopyContext.current, "Context should be restored even after error")
    }

    func testLoggingWithError() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        let testError = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Test error"])

        Canopy.e("Error occurred", error: testError)

        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.level, .error)
        XCTAssertNotNil(tree.logs.first?.error)

        let loggedError = tree.logs.first?.error as? NSError
        XCTAssertEqual(loggedError?.code, 42)
        XCTAssertEqual(loggedError?.domain, "TestDomain")
    }

    func testLoggingWithNilError() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        Canopy.e("Error without error object", error: nil)

        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.level, .error)
        XCTAssertNil(tree.logs.first?.error)
    }

    func testAllLogLevelsWithError() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        let testError = NSError(domain: "Test", code: 1, userInfo: nil)

        Canopy.v("Verbose", error: testError)
        Canopy.d("Debug", error: testError)
        Canopy.i("Info", error: testError)
        Canopy.w("Warning", error: testError)
        Canopy.e("Error", error: testError)

        XCTAssertEqual(tree.logs.count, 5)

        for logEntry in tree.logs {
            XCTAssertNotNil(logEntry.error)
            XCTAssertEqual((logEntry.error as? NSError)?.code, 1)
        }
    }

    func testTaggedLoggingWithError() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        let testError = NSError(domain: "Test", code: 99, userInfo: nil)

        Canopy.tag("TestTag").e("Tagged error", error: testError)

        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.tag, "TestTag")
        XCTAssertNotNil(tree.logs.first?.error)
        XCTAssertEqual((tree.logs.first?.error as? NSError)?.code, 99)
    }

    func testLoggingWithFormatArgsAndError() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        let testError = NSError(domain: "Test", code: 123, userInfo: nil)

        Canopy.e("Error %@ at %d", error: testError, "network", 42)

        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.message, "Error network at 42")
        XCTAssertNotNil(tree.logs.first?.error)
        XCTAssertEqual((tree.logs.first?.error as? NSError)?.code, 123)
    }

    func testMultipleTreesReceiveError() throws {
        let tree1 = TestTree()
        let tree2 = TestTree()
        Canopy.plant(tree1, tree2)

        let testError = NSError(domain: "MultiTree", code: 999, userInfo: nil)

        Canopy.e("Error in multiple trees", error: testError)

        XCTAssertEqual(tree1.logs.count, 1)
        XCTAssertEqual(tree2.logs.count, 1)

        XCTAssertNotNil(tree1.logs.first?.error)
        XCTAssertNotNil(tree2.logs.first?.error)

        XCTAssertEqual((tree1.logs.first?.error as? NSError)?.code, 999)
        XCTAssertEqual((tree2.logs.first?.error as? NSError)?.code, 999)
    }

    func testErrorLoggingWithMinLevelFiltering() throws {
        let tree = TestTree()
        tree.minLevel = .error
        Canopy.plant(tree)

        let testError = NSError(domain: "FilterTest", code: 1, userInfo: nil)

        Canopy.v("Verbose", error: testError)
        Canopy.d("Debug", error: testError)
        Canopy.i("Info", error: testError)
        Canopy.w("Warning", error: testError)
        Canopy.e("Error", error: testError)

        XCTAssertEqual(tree.logs.count, 1)
        XCTAssertEqual(tree.logs.first?.level, .error)
    }

    func testMixedNilAndNonNullErrors() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        let testError = NSError(domain: "Mixed", code: 42, userInfo: nil)

        Canopy.e("Error with error", error: testError)
        Canopy.e("Error without error", error: nil)
        Canopy.e("Another error", error: testError)

        XCTAssertEqual(tree.logs.count, 3)
        XCTAssertNotNil(tree.logs[0].error)
        XCTAssertNil(tree.logs[1].error)
        XCTAssertNotNil(tree.logs[2].error)
    }

    func testHighVolumeLoggingWithErrors() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        let testError = NSError(domain: "Volume", code: 1, userInfo: nil)

        for i in 0..<1000 {
            let error: Error? = i % 2 == 0 ? testError : nil
            Canopy.e("Log entry %d", error: error, i)
        }

        XCTAssertEqual(tree.logs.count, 1000)

        var errorCount = 0
        for log in tree.logs {
            if log.error != nil {
                errorCount += 1
            }
        }
        XCTAssertEqual(errorCount, 500)
    }

    func testErrorWithDifferentErrorTypes() throws {
        let tree = TestTree()
        Canopy.plant(tree)

        let nsError = NSError(domain: "NSErrorDomain", code: 100, userInfo: nil)
        let customError = CustomError.someError

        Canopy.e("NSError", error: nsError)
        Canopy.e("CustomError", error: customError)

        XCTAssertEqual(tree.logs.count, 2)

        XCTAssertNotNil(tree.logs[0].error)
        switch tree.logs[0].error {
        case let err as NSError:
            XCTAssertEqual(err.domain, "NSErrorDomain")
        default:
            XCTFail("Expected NSError")
        }

        XCTAssertNotNil(tree.logs[1].error)
        switch tree.logs[1].error {
        case is CustomError:
            break
        default:
            XCTFail("Expected CustomError")
        }
    }

    func testErrorLoggingWithAsyncTree() throws {
        let baseTree = TestTree()
        let asyncTree = AsyncTree(wrapping: baseTree)
        Canopy.plant(asyncTree)

        let testError = NSError(domain: "Async", code: 777, userInfo: nil)

        Canopy.e("Async error", error: testError)

        let expectation = self.expectation(description: "Async logging")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(baseTree.logs.count, 1)
        XCTAssertNotNil(baseTree.logs.first?.error)
        XCTAssertEqual((baseTree.logs.first?.error as? NSError)?.code, 777)
    }
}

enum CustomError: Error {
    case someError
}

class TestTree: Tree, @unchecked Sendable {
    struct LogEntry {
        let level: LogLevel
        let tag: String?
        let message: String
        let error: Error?
        let file: String
        let function: String
        let line: UInt
    }

    var logs: [LogEntry] = []
    private let lock = NSLock()

    override func log(
        priority: LogLevel,
        tag: String?,
        message: String,
        error: Error?
    ) {
        let file = ""
        let function = ""
        let line: UInt = 0

        let entry = LogEntry(
            level: priority,
            tag: tag,
            message: message,
            error: error,
            file: file,
            function: function,
            line: line
        )

        lock.lock()
        logs.append(entry)
        lock.unlock()
    }
}

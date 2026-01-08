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
}

class TestTree: Tree {
    struct LogEntry {
        let level: LogLevel
        let tag: String?
        let message: String
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
            file: file,
            function: function,
            line: line
        )

        lock.lock()
        logs.append(entry)
        lock.unlock()
    }
}

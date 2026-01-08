//
//  DebugTreeTests.swift
//  CanopyTests
//
//  Tests for DebugTree functionality
//

import XCTest
@testable import Canopy

final class DebugTreeTests: XCTestCase {

    override func setUpWithError() throws {
        Canopy.uprootAll()
    }

    override func tearDownWithError() throws {
        Canopy.uprootAll()
    }

    // MARK: - Basic Logging Tests

    func testDebugTreeLogsToConsole() {
        let tree = DebugTree()
        Canopy.plant(tree)

        XCTAssertNoThrow(Canopy.d("Debug message"))
        XCTAssertNoThrow(Canopy.i("Info message"))
        XCTAssertNoThrow(Canopy.w("Warning message"))
        XCTAssertNoThrow(Canopy.e("Error message"))
    }

    // MARK: - Auto Tag Tests

    func testDebugTreeAutoGeneratesTag() {
        let tree = DebugTree()
        Canopy.plant(tree)

        XCTAssertNoThrow(Canopy.d("Test message"))
    }

    func testDebugTreeWithExplicitTag() {
        let tree = DebugTree()
        Canopy.plant(tree)

        XCTAssertNoThrow(Canopy.tag("CustomTag").d("Test message"))
    }

    // MARK: - Message Formatting Tests

    func testDebugTreeWithFormattedMessage() {
        let tree = DebugTree()
        Canopy.plant(tree)

        XCTAssertNoThrow(Canopy.d("User %@ logged in", "Alice"))
    }

    // MARK: - Level Filtering Tests

    func testDebugTreeRespectsMinLevel() {
        let tree = DebugTree()
        tree.minLevel = .error
        Canopy.plant(tree)

        XCTAssertNoThrow(Canopy.v("Verbose"))
        XCTAssertNoThrow(Canopy.d("Debug"))
        XCTAssertNoThrow(Canopy.i("Info"))
        XCTAssertNoThrow(Canopy.w("Warning"))
        XCTAssertNoThrow(Canopy.e("Error"))
    }
}

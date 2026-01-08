//
//  TreeTests.swift
//  CanopyTests
//
//  Tests for Tree base class functionality
//

import XCTest
@testable import Canopy

final class TreeTests: XCTestCase {

    // MARK: - Min Level Tests

    func testDefaultMinLevel() {
        let tree = TestTree()
        XCTAssertEqual(tree.minLevel, .verbose)
    }

    func testSetMinLevel() {
        let tree = TestTree()
        tree.minLevel = .error

        XCTAssertEqual(tree.minLevel, .error)
    }

    func testIsLoggableWithDefaultMinLevel() {
        let tree = TestTree()

        XCTAssertTrue(tree.isLoggable(priority: .verbose))
        XCTAssertTrue(tree.isLoggable(priority: .debug))
        XCTAssertTrue(tree.isLoggable(priority: .info))
        XCTAssertTrue(tree.isLoggable(priority: .warning))
        XCTAssertTrue(tree.isLoggable(priority: .error))
    }

    func testIsLoggableWithHigherMinLevel() {
        let tree = TestTree()
        tree.minLevel = .warning

        XCTAssertFalse(tree.isLoggable(priority: .verbose))
        XCTAssertFalse(tree.isLoggable(priority: .debug))
        XCTAssertFalse(tree.isLoggable(priority: .info))
        XCTAssertTrue(tree.isLoggable(priority: .warning))
        XCTAssertTrue(tree.isLoggable(priority: .error))
    }

    // MARK: - Tag Tests

    func testDefaultTag() {
        let tree = TestTree()
        XCTAssertNil(tree.explicitTag)
    }

    func testSetTag() {
        let tree = TestTree()
        tree.tag("CustomTag")

        XCTAssertEqual(tree.explicitTag, "CustomTag")
    }

    func testSetEmptyTag() {
        let tree = TestTree()
        tree.tag("")

        XCTAssertNil(tree.explicitTag)
    }

    func testTagReturnsSelf() {
        let tree = TestTree()
        let result = tree.tag("Tag")

        XCTAssertTrue(result === tree)
    }

    func testTagIsClearedAfterLog() {
        let tree = TestTree()
        tree.tag("Tag1")

        tree.log(priority: .debug, tag: nil, message: "Test", arguments: [], error: nil, file: "", function: "", line: 1)

        XCTAssertNil(tree.explicitTag)
    }

    // MARK: - Format Message Tests

    func testFormatMessageWithoutArgs() {
        let tree = TestTree()
        let result = tree.formatMessage("Simple message", [])

        XCTAssertEqual(result, "Simple message")
    }

    func testFormatMessageWithArgs() {
        let tree = TestTree()
        let result = tree.formatMessage("User %@ has %lld items", ["Alice", 5])

        XCTAssertEqual(result, "User Alice has 5 items")
    }

    func testFormatMessageWithMultipleArgs() {
        let tree = TestTree()
        let result = tree.formatMessage("%@ %@ %@ %@", ["One", "Two", "Three", "Four"])

        XCTAssertEqual(result, "One Two Three Four")
    }

    func testFormatMessageWithEmptyTemplate() {
        let tree = TestTree()
        let result = tree.formatMessage("", ["arg1"])

        XCTAssertEqual(result, "")
    }

    func testFormatMessageWithMismatchedArgCount() {
        let tree = TestTree()
        let result = tree.formatMessage("User %@ logged in", ["Alice", "Extra"])

        // When specifier count doesn't match args count, return original template
        XCTAssertEqual(result, "User %@ logged in")
    }

    // MARK: - Log Method Tests

    func testLogMethodCapturesTag() {
        let tree = TestTree()
        tree.tag("CustomTag")

        // The log method should use the captured tag
        tree.log(priority: .debug, tag: nil, message: "Test", arguments: [], error: nil, file: "", function: "", line: 1)

        // After log, tag should be cleared
        XCTAssertNil(tree.explicitTag)
    }
}

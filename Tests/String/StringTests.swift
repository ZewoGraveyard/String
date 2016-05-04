import XCTest
@testable import String

class StringTests: XCTestCase {
    func testReality() {
        XCTAssert(2 + 2 == 4, "Something is severely wrong here.")
    }

    func testTrim() {
        XCTAssertEqual(" left space".trim(), "left space")
        XCTAssertEqual("left space".trim(), "left space")
        XCTAssertEqual("right space ".trim(), "right space")
        XCTAssertEqual("right space".trim(), "right space")
        XCTAssertEqual("  left and right ".trim(), "left and right")
        XCTAssertEqual("left and right".trim(), "left and right")
        XCTAssertEqual(" ,multiple characters ".trim([" ", ","]), "multiple characters")
        XCTAssertEqual("multiple characters".trim([" ", ","]), "multiple characters")
    }
}

extension StringTests {
    static var allTests: [(String, StringTests -> () throws -> Void)] {
        return [
           ("testReality", testReality),
           ("testTrim", testTrim)
        ]
    }
}

import XCTest
@testable import String

class StringTests: XCTestCase {
    func testReality() {
        XCTAssert(2 + 2 == 4, "Something is severely wrong here.")
    }
}

extension StringTests {
    static var allTests : [(String, StringTests -> () throws -> Void)] {
        return [
           ("testReality", testReality),
        ]
    }
}

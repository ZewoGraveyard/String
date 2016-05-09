import XCTest
@testable import String

class StringTests: XCTestCase {
    func testHexadecimal() {
        var value: UInt8
        value = 0
        XCTAssertEqual(value.hexadecimal(), "00")
        value = 15
        XCTAssertEqual(value.hexadecimal(), "0F")
        value = 255
        XCTAssertEqual(value.hexadecimal(), "FF")
        value = 15
        XCTAssertEqual(value.hexadecimal(uppercased: false), "0f")
        value = 255
        XCTAssertEqual(value.hexadecimal(uppercased: false), "ff")
    }
    
    func testIndex() {
        let string = "A test string."
        XCTAssertEqual(string.index(of: "A"), string.startIndex)
        XCTAssertEqual(string.index(of: "test"), string.characters.index(of: "t"))
        XCTAssertEqual(string.index(of: "A test string."), string.characters.index(of: "A"))
    }
    
    func testReplace() {
        var string = "A sample string to test replacement on."
        string.replace(string: "A sample string", with: "Sometimes we need a test string")
        XCTAssertEqual(string, "Sometimes we need a test string to test replacement on.")
        string.replace(string: "Gobeldigook", with: "HELLO!")
        XCTAssertEqual(string, "Sometimes we need a test string to test replacement on.")
    }

    func testURIQueryPercentEncoding() {
        XCTAssertEqual(try "abc".percentEncoded(allowing: .uriQueryAllowed), "abc")
        XCTAssertEqual(try "joão".percentEncoded(allowing: .uriQueryAllowed), "jo%C3%A3o")
        XCTAssertEqual(try "💩".percentEncoded(allowing: .uriQueryAllowed), "%F0%9F%92%A9")
        XCTAssertEqual(try "foo bar".percentEncoded(allowing: .uriQueryAllowed), "foo%20bar")
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
           ("testHexadecimal", testHexadecimal),
           ("testURIQueryPercentEncoding", testURIQueryPercentEncoding),
           ("testTrim", testTrim),
           ("testIndex", testIndex),
           ("testReplace", testReplace)
        ]
    }
}

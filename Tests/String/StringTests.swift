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
        string = "short"
        string.replace(string: "longnonexistentstring", with: "replacement string")
        XCTAssertEqual(string, "short")
    }
    
    func testURIComponentPercentEncoding() {
        XCTAssertEqual(try "aBc123".percentEncoded(allowing: .uriComponentAllowed), "aBc123")
        XCTAssertEqual(try "-._~".percentEncoded(allowing: .uriComponentAllowed), "-._~")
        XCTAssertEqual(try "너가 보여".percentEncoded(allowing: .uriComponentAllowed), "%EB%84%88%EA%B0%80%20%EB%B3%B4%EC%97%AC")
        XCTAssertEqual(try "💩".percentEncoded(allowing: .uriComponentAllowed), "%F0%9F%92%A9")
        XCTAssertEqual(try "foo bar".percentEncoded(allowing: .uriComponentAllowed), "foo%20bar")
        XCTAssertEqual(try "foo\nbar".percentEncoded(allowing: .uriComponentAllowed), "foo%0Abar")
        
        /// The following code was generated using this code:
        ///   http://sandbox.onlinephpfunctions.com/code/ee5ecf05e114d9869ead7b45769c7c487ca46484
        ///
        /// It checks chracters from RFC3986 2.2 Reserved Characters as well as
        /// section 2.3 Unreserved Characters
        
        XCTAssertEqual(try "co:on".percentEncoded(allowing: .uriComponentAllowed), "co%3Aon")
        XCTAssertEqual(try "fs/ash".percentEncoded(allowing: .uriComponentAllowed), "fs%2Fash")
        XCTAssertEqual(try "?mark".percentEncoded(allowing: .uriComponentAllowed), "%3Fmark")
        XCTAssertEqual(try "#sign".percentEncoded(allowing: .uriComponentAllowed), "%23sign")
        XCTAssertEqual(try "[sbracket]".percentEncoded(allowing: .uriComponentAllowed), "%5Bsbracket%5D")
        XCTAssertEqual(try "@sign".percentEncoded(allowing: .uriComponentAllowed), "%40sign")
        XCTAssertEqual(try "exc!amation".percentEncoded(allowing: .uriComponentAllowed), "exc%21amation")
        XCTAssertEqual(try "do$$ar".percentEncoded(allowing: .uriComponentAllowed), "do%24%24ar")
        XCTAssertEqual(try "ampers&".percentEncoded(allowing: .uriComponentAllowed), "ampers%26")
        XCTAssertEqual(try "apos\'rophe".percentEncoded(allowing: .uriComponentAllowed), "apos%27rophe")
        XCTAssertEqual(try "\"quote\"".percentEncoded(allowing: .uriComponentAllowed), "%22quote%22")
        XCTAssertEqual(try "(paren)".percentEncoded(allowing: .uriComponentAllowed), "%28paren%29")
        XCTAssertEqual(try "astr*ck".percentEncoded(allowing: .uriComponentAllowed), "astr%2Ack")
        XCTAssertEqual(try "pl+us".percentEncoded(allowing: .uriComponentAllowed), "pl%2Bus")
        XCTAssertEqual(try "com,ma".percentEncoded(allowing: .uriComponentAllowed), "com%2Cma")
        XCTAssertEqual(try "semico;on".percentEncoded(allowing: .uriComponentAllowed), "semico%3Bon")
        XCTAssertEqual(try "equ=als".percentEncoded(allowing: .uriComponentAllowed), "equ%3Dals")
        XCTAssertEqual(try "da-sh".percentEncoded(allowing: .uriComponentAllowed), "da-sh")
        XCTAssertEqual(try "per.od".percentEncoded(allowing: .uriComponentAllowed), "per.od")
        XCTAssertEqual(try "_nderscore".percentEncoded(allowing: .uriComponentAllowed), "_nderscore")
        XCTAssertEqual(try "til~de".percentEncoded(allowing: .uriComponentAllowed), "til~de")
    }

    func testURIQueryPercentEncoding() {
        XCTAssertEqual(try "abc".percentEncoded(allowing: .uriQueryAllowed), "abc")
        XCTAssertEqual(try "joão".percentEncoded(allowing: .uriQueryAllowed), "jo%C3%A3o")
        XCTAssertEqual(try "💩".percentEncoded(allowing: .uriQueryAllowed), "%F0%9F%92%A9")
        XCTAssertEqual(try "foo bar".percentEncoded(allowing: .uriQueryAllowed), "foo%20bar")
        XCTAssertEqual(try "foo\nbar".percentEncoded(allowing: .uriQueryAllowed), "foo%0Abar")
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
    static var allTests: [(String, (StringTests) -> () throws -> Void)] {
        return [
           ("testHexadecimal", testHexadecimal),
           ("testURIComponentPercentEncoding", testURIComponentPercentEncoding),
           ("testURIQueryPercentEncoding", testURIQueryPercentEncoding),
           ("testTrim", testTrim),
           ("testIndex", testIndex),
           ("testReplace", testReplace)
        ]
    }
}

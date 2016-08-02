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
    
        /// The following dictionary code was generated using:
        ///   http://sandbox.onlinephpfunctions.com/code/ee5ecf05e114d9869ead7b45769c7c487ca46484
        
        let tests = [
            // Quick RFC3986 2.3 Unreserved Characters simple tests
            "aBc123":      "aBc123",
            "-._~":        "-._~",
            
            // Misc. other tests.
            "너가 보여":      "%EB%84%88%EA%B0%80%20%EB%B3%B4%EC%97%AC",
            "💩":          "%F0%9F%92%A9",
            "foo bar":     "foo%20bar",
            "foo\nbar":    "foo%0Abar",
            
            // Quick RFC3986 2.2 Reserved Characters test
            "co:on":       "co%3Aon",
            "fs/ash":      "fs%2Fash",
            "?mark":       "%3Fmark",
            "#sign":       "%23sign",
            "[sbracket]":  "%5Bsbracket%5D",
            "@sign":       "%40sign",
            "exc!amation": "exc%21amation",
            "do$$ar":      "do%24%24ar",
            "ampers&":     "ampers%26",
            "apos\'rophe": "apos%27rophe",
            "\"quote\"":   "%22quote%22",
            "(paren)":     "%28paren%29",
            "astr*ck":     "astr%2Ack",
            "pl+us":       "pl%2Bus",
            "com,ma":      "com%2Cma",
            "semico;on":   "semico%3Bon",
            "equ=als":     "equ%3Dals",
            
            // Quick RFC3986 2.3 Unreserved Characters test (non-alphanumeric)
            "da-sh":       "da-sh",
            "per.od":      "per.od",
            "_nderscore":  "_nderscore",
            "til~de":      "til~de"
        ]
        
        for (raw, encoded) in tests {
            XCTAssertEqual(try raw.percentEncoded(allowing: .uriComponentAllowed), encoded)
        }
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

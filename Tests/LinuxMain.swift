#if os(Linux)

import XCTest
@testable import StringTests

XCTMain([
    testCase(StringTests.allTests)
])

#endif

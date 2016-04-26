#if os(Linux)

import XCTest
@testable import StringTestSuite

XCTMain([
    testCase(StringTests.allTests)
])

#endif

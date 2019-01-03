import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(swift_decision_treeTests.allTests),
    ]
}
#endif

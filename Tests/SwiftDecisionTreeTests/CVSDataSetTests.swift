import XCTest
@testable import SwiftDecisionTree

final class swift_decision_treeTests: XCTestCase {
	
    func test_EmptyContent() {
		let ds = CSVDataSet(content: "", withHeader: true, separator: ",")
		XCTAssertNil(ds)
    }
	
	func test_EmptyContent_WithHeader() {
		let ds = CSVDataSet(content: """
weight,height,sex
""", withHeader: true, separator: ",")
		XCTAssertNotNil(ds)
		XCTAssertNotNil(ds?.weight)
		XCTAssertEqual(0, ds!.weight!.count)
	}
	
	func test_WithHeader_Complete() {
		let ds = CSVDataSet(content: """
weight,height,sex
1,2,3
4,5,6
""", withHeader: true, separator: ",")
		XCTAssertNotNil(ds)
		XCTAssertNotNil(ds?.weight)
		XCTAssertEqual(2, ds!.weight!.count)
		XCTAssertEqual(2, ds!.height!.count)
		XCTAssertEqual(2, ds!.sex!.count)
	}
	
	func test_WithHeader_MissingValue() {
		let ds = CSVDataSet(content: """
weight,height,sex
1,2,3
4,,6
""", withHeader: true, separator: ",")
		XCTAssertNotNil(ds)
		XCTAssertNotNil(ds?.weight)
		XCTAssertEqual(2, ds!.weight!.count)
		XCTAssertEqual(2, ds!.height!.count)
		XCTAssertEqual(2, ds!.sex!.count)
		
		XCTAssertEqual("", ds!.height![1])
		XCTAssertEqual("6", ds!.sex![1])
	}

    static var allTests = [
        ("test_EmptyContent", test_EmptyContent),
        ("test_EmptyContent_WithHeader", test_EmptyContent_WithHeader),
        ("test_WithHeader_Complete", test_WithHeader_Complete),
        ("test_WithHeader_MissingValue", test_WithHeader_MissingValue)
    ]
}

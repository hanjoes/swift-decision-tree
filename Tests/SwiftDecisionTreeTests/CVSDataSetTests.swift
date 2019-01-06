import XCTest
@testable import SwiftDecisionTree

final class swift_decision_treeTests: XCTestCase {
    
    // MARK: - Test Input
    let dsEmpty = CSVDataSet(content: """
""", withHeader: true, separator: ",")
    
    let dsHeadOnly = CSVDataSet(content: """
weight,height,sex
""", withHeader: true, separator: ",")
    
    let dsComplete = CSVDataSet(content: """
weight,height,sex
1,2,3
4,5,6
""", withHeader: true, separator: ",")
    
    let dsIncomplete = CSVDataSet(content: """
weight,,sex,hobby
1,2,3,
4,,6,juice
""", withHeader: true, separator: ",")
    
    // MARK: - Access Column
    
    func testAccessColumn() {
        // empty content
        XCTAssertEqual([], dsHeadOnly.weight)
        
        // empty content with header
        XCTAssertEqual([], dsHeadOnly.weight)
        
        // access non-existent header
        XCTAssertNil(dsComplete.something)
        
        // access complete column
        XCTAssertEqual(dsComplete.sex, ["3", "6"])
        
        // access incomplete column
        XCTAssertEqual(dsIncomplete.hobby, ["", "juice"])
        
        // access missing column
        XCTAssertEqual(dsIncomplete.column1, ["2", ""])
    }
    
    // MARK: - Access Row
    
    func testAccessRow() {
        // empty content
        XCTAssertNil(dsEmpty[0])
        
        // empty content with header
        XCTAssertNil(dsHeadOnly[0])
        
        // access row for complete dataset
        XCTAssertEqual(dsComplete[0], ["1", "2", "3"])
        
        // access row with missing value
        XCTAssertEqual(dsIncomplete[1], ["4", "", "6", "juice"])
    }
    
//    func test_IncompleteHeader() {
//        let ds = CSVDataSet(content: """
//weight,,sex,hobby
//1,2,3,4
//4,,6,
//""", withHeader: true, separator: ",")
//        XCTAssertEqual(["1", "4"], ds!.weight!)
//        XCTAssertEqual(["2", ""], ds!.sex!)
//        XCTAssertEqual(["2", ""], ds!.col1!)
//
//        let (X, y) = ds!.divide(into: ["weight", "height", "sex"], and: "sex")
//        XCTAssertNotNil(y)
//        XCTAssertEqual([["1", "4"], ["3", "6"]], X)
//        XCTAssertEqual(["3", "6"], y!)
//    }
    
    static var allTests = [
        ("testAccessColumn", testAccessColumn),
        ("testAccessRow", testAccessRow),
    ]
}

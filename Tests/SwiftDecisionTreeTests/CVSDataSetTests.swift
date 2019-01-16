import XCTest
@testable import SwiftDecisionTree

final class swift_decision_treeTests: XCTestCase {
    
    // MARK: - Test Input
    let dsEmpty = CSVDataSet(content: """
""", withHeader: true, separator: ",")
    
    let dsHeadOnly = CSVDataSet(content: """
weight,height,sex
""", withHeader: true, separator: ",")
    
    let dsCompleteNoHeader = CSVDataSet(content: """
1,2,3
4,5,6
""", withHeader: false, separator: ",")
    
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
        XCTAssertEqual([], dsEmpty.column0)

        // empty content with header
        XCTAssertEqual([], dsHeadOnly.weight)
        
        // no header
        XCTAssertEqual(["3", "6"], dsCompleteNoHeader.column2)
        
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
    
    // MARK: - Training Test Split
    
    func testTrainingTestSplit() {
        // split empty dataset
        let (dsEmptyTrain, dsEmptyTest) = dsEmpty.trainingTestSplit(testPercentage: 0.2)
        XCTAssertEqual(0, dsEmptyTrain.count)
        XCTAssertEqual(0, dsEmptyTest.count)
        
        // split dataset doesn't have enough rows for test set
        var (dsCompleteTrain, dsCompleteTest) = dsComplete.trainingTestSplit(testPercentage: 0.2)
        XCTAssertEqual(2, dsCompleteTrain.count)
        XCTAssertEqual(0, dsCompleteTest.count)
        
        // split dataset that has enough rows for test set
        (dsCompleteTrain, dsCompleteTest) = dsComplete.trainingTestSplit(testPercentage: 0.5)
        XCTAssertEqual(1, dsCompleteTrain.count)
        XCTAssertEqual(1, dsCompleteTest.count)
    }

    static var allTests = [
        ("testAccessColumn", testAccessColumn),
        ("testAccessRow", testAccessRow),
        ("testTrainingTestSplit", testTrainingTestSplit)
    ]
}

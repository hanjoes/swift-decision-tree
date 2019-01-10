import XCTest
@testable import SwiftDecisionTree

final class DecisionTreeTests: XCTestCase {
    
    var testFilePath: String {
        return Bundle(for: type(of: self)).path(forResource: "iris.data", ofType: "txt")!
    }

    func test_BuildTree() {
        guard let ds = CSVDataSet(csvPath: testFilePath, withHeader: false, separator: ",") else {
            return
        }
        
        let tree = DecisionTree(dataSet: ds)
        tree.learn(features: ["column0", "column1", "column2", "column3"], target: "column4")
//        print(tree.basicStats)
    }

    static var allTests = [
        ("test_BuildTree", test_BuildTree),
    ]
}

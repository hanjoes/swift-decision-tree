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
        tree.learn(features: ["column0", "column1"], target: "column4")
    }

    static var allTests = [
        ("test_BuildTree", test_BuildTree),
    ]
}

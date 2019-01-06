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
        
//        print(ds.0)

    }

    static var allTests = [
        ("test_BuildTree", test_BuildTree),
    ]
}

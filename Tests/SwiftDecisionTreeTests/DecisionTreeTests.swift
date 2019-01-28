import XCTest
@testable import SwiftDecisionTree

final class DecisionTreeTests: XCTestCase {
    
    var irisFilePath: String {
        return Bundle(for: type(of: self)).path(forResource: "iris.data", ofType: "txt")!
    }
    
    var adultTrainFilePath: String {
        return Bundle(for: type(of: self)).path(forResource: "adult", ofType: "data")!
    }
    
    var adultTestFilePath: String {
        return Bundle(for: type(of: self)).path(forResource: "adult", ofType: "test")!
    }
    
    func test_BuildTree_Iris() {
        guard let ds = CSVDataSet(csvPath: irisFilePath, withHeader: false, separator: ",") else {
            return
        }
        
        let (train, test) = ds.trainingTestSplit(testPercentage: 0.2)
        let tree = DecisionTree(dataset: ds, rowIndices: train,
                                features: ["column0", "column1", "column2", "column3"],
                                target: "column4", type: .classifier).learn()
        //        print(tree.basicstats)
        tree.evaluate(testRows: test)
    }
    
    func test_BuildTree_adult() {
        guard let train = CSVDataSet(csvPath: adultTrainFilePath, withHeader: false, separator: ",") else {
            return
        }
        
        guard let test = CSVDataSet(csvPath: adultTestFilePath, withHeader: false, separator: ",") else {
            return
        }
        
        print("\(train.rowCount) rows in training set, \(test.rowCount) rows in the test set.")
        let col = train[0]!.count
        print("\(col) columns in the datasets")
        var features = [String]()
        for index in 0..<col-1 {
            features.append("column\(index)")
        }

        let tree = DecisionTree(dataset: train, rowIndices: Array(0..<train.rowCount),
                                features: features,
                                target: "column\(col-1)", type: .classifier).learn()
        //        print(tree.basicstats)
//        tree.evaluate(testRows: )
    }
    
    static var allTests = [
        ("test_BuildTree", test_BuildTree_Iris),
        ]
}

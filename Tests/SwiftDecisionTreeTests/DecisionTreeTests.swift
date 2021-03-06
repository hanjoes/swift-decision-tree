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
    
    var wineFilePath: String {
        return Bundle(for: type(of: self)).path(forResource: "wine", ofType: "data")!
    }
    
    func test_BuildTree_Iris() {
        guard let ds = CSVDataSet(csvPath: irisFilePath, withHeader: false, separator: ",") else {
            return
        }
        
        print("Training Iris dataset...")
        let (train, test) = ds.trainingTestSplit(testPercentage: 0.2)
        let tree = DecisionTree(dataset: ds, rowIndices: train,
                                features: ["column0", "column1", "column2", "column3"],
                                target: "column4", type: .classifier).learn()
        tree.evaluate(testRows: test)
    }
    
    func test_BuildTree_Adult() {
        guard let train = CSVDataSet(csvPath: adultTrainFilePath, withHeader: false, separator: ",") else {
            return
        }
        
        guard let test = CSVDataSet(csvPath: adultTestFilePath, withHeader: false, separator: ",") else {
            return
        }
        print("Training adult dataset...")
        
        let col = train[0]!.count
        var features = [String]()
        for index in 0..<col-1 {
            features.append("column\(index)")
        }

        let tree = DecisionTree(dataset: train, rowIndices: Array(0..<train.rowCount),
                                features: features,
                                target: "column\(col-1)", type: .classifier).learn()
    }
    
    func test_BuildTree_Wine() {
        guard let ds = CSVDataSet(csvPath: wineFilePath, withHeader: false, separator: ",") else {
            return
        }
        
        print("Training Wine dataset...")
        let col = ds[0]!.count
        var features = [String]()
        for index in 1..<col-1 {
            features.append("column\(index)")
        }

        let (train, test) = ds.trainingTestSplit(testPercentage: 0.2)
        print("\(ds.rowCount) rows in dataset, \(train.count) rows in training set and \(test.count) rows in test set")
        let tree = DecisionTree(dataset: ds, rowIndices: train,
                                features: features,
                                target: "column0", type: .classifier).learn()
        //        print(tree.basicstats)
        tree.evaluate(testRows: test)
    }
    
    static var allTests = [
        ("test_BuildTree_Iris", test_BuildTree_Iris),
        ("test_BuildTree_Adult", test_BuildTree_Adult),
        ("test_BuildTree_Wine", test_BuildTree_Wine)
    ]
}

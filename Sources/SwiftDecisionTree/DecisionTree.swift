import Foundation

// MARK: - DecisionTree

/// Representation of a decision tree.
///
/// Decision trees are formed by a collection of rules based on variables in the modeling data set:
/// - Rules based on variables' values are selected to get the best split to differentiate observations based
///   on the dependent variable
/// - Once a rule is selected and splits a node into two, the same process is applied to each "child" node
///   (i.e. it is a recursive procedure)
/// - Splitting stops when CART detects no further gain can be made, or some pre-set stopping rules are met.
///   (Alternatively, the data are split as much as possible and then the tree is later pruned.)
///
/// Reference from:
/// - [Predictive Analytics](https://en.wikipedia.org/wiki/Predictive_analytics#Classification_and_regression_trees_.28CART.29)
/// - [Decision Tree Learning](https://en.wikipedia.org/wiki/Decision_tree_learning)
class DecisionTree {

    /// Boolean indicating if this tree is a leaf.
    var isLeaf: Bool {
        return l == nil && r == nil
    }
    
    var type: TreeType
    
    /// Majority value of the targets stored in this node.
    ///
    /// When this tree node is a leaf, this indicates the prediction result.
    var majority: String? {
        let targetColumn = dataset[dynamicMember: target]!
        var histogram = [String:Int]()
        var majority: String?
        var majorityCount = Int.min
        for rowIndex in rowIndices {
            let targetValue = targetColumn[rowIndex]
            if histogram[targetValue] != nil {
                histogram[targetValue]! += 1
            }
            else {
                histogram[targetValue] = 1
            }
            
            let currentCount = histogram[targetValue]!
            if currentCount > majorityCount {
                majority = targetValue
                majorityCount = currentCount
            }
        }
        return majority
    }
    
    private let rowIndices: [Int]
    private let dataset: CSVDataSet
    private let features: [String]
    private let target: String
    
    private var rule: DecisionTreeRule?
    private var l: DecisionTree?
    private var r: DecisionTree?

    
    /// Initialize a __DecisionTree__ from a __CSVDataSet__.
    ///
    /// When first constracted from a dataset, the tree is just a container which
    /// stores data. To make it "smart" enough to make predictions, it needs to
    /// "learn" from the features and the target.
    ///
    /// - note: check the __learn__ method
    ///
    /// - Parameters:
    ///   - dataset: the dataset
    ///   - features: list of feature columns as input
    ///   - target: the target column as output
    ///   - type: type of the tree, __regressor__ or __classifier__
    init(dataset:CSVDataSet, features: [String], target: String, type: TreeType) {
        self.dataset = dataset
        self.type = type
        var _rowIndices = [Int]()
        for index in 0..<dataset.rowCount {
            _rowIndices.append(index)
        }
        self.rowIndices = _rowIndices
        self.features = features
        self.target = target
    }

    
    /// Initializer that takes a reference to the dataset and a list of indices of rows in that dataset.
    ///
    /// - Parameters:
    ///   - dataset: the dataset
    ///   - rowIndices: indices into the dataset that are valid rows
    ///   - features: list of feature columns as input
    ///   - target: the target column as output
    ///   - type: type of the tree, __regressor__ or __classifier__
    init(dataset: CSVDataSet, rowIndices: [Int], features: [String], target: String, type: TreeType) {
        self.dataset = dataset
        self.rowIndices = rowIndices
        self.features = features
        self.target = target
        self.type = type
    }
    
    
    /// A tree need to "learn" before it can make predictions.
    @discardableResult
    func learn() -> DecisionTree {
        var purity: (CSVDataSet, String, [Int]) -> Double
        switch self.type {
        case .regressor: purity = std
        case .classifier: purity = gini
        }
        if let rule = DecisionTreeRule.findRule(dataset: self.dataset,
                                                rowIndices: self.rowIndices,
                                                features: features,
                                                target: target,
                                                purity: purity) {
            self.rule = rule
            let (left, right) = rule.split(dataset: dataset, rowIndices: self.rowIndices)
            l = DecisionTree(dataset: self.dataset, rowIndices: left, features: features,
                             target: target, type: self.type).learn()
            r = DecisionTree(dataset: self.dataset, rowIndices: right, features: features,
                             target: target, type: self.type).learn()
//            print("rule found, divided trees into left(\(left.count) entries) and right(\(right.count) entries).")
        }
        return self
    }

    // TODO: better naming
    /// Predict the output given an input row.
    ///
    /// - Parameter rowIndex: index of the input row
    /// - Returns: the prediction
    func predict(rowIndex: Int) -> String? {
        var currentTree = self
        while currentTree.rule != nil {
            if currentTree.rule!.goRight(dataset: self.dataset, rowIndex: rowIndex) {
                currentTree = currentTree.r!
            }
            else {
                currentTree = currentTree.l!
            }
        }
        
        return currentTree.majority
    }
    
    // TODO: better naming
    /// Predict the output given a list of input rows.
    ///
    /// - Parameter rowIndices: list of input rows
    /// - Returns: the prediction for each of the input rows
    func predict(rowIndices: [Int]) -> [String?] {
        return rowIndices.map { predict(rowIndex: $0) }
    }
    
    /// Evaluate the model based on the test input.
    ///
    /// - Parameter testRows: list of test rows
    func evaluate(testRows: [Int]) {
        let predictions = predict(rowIndices: testRows)
        let targets = dataset[dynamicMember: target]!
        var totalDiff = 0.0
        for (index, prediction) in predictions.enumerated() {
            let expectation = targets[testRows[index]]
            switch self.type {
            case .classifier:
                if expectation != prediction! {
                    totalDiff += 1.0
                }
            case .regressor:
                totalDiff += abs(Double(expectation)! - Double(prediction!)!)
            }
        }
        switch self.type {
        case .regressor:
            print("test size: \(testRows.count), total diff: \(totalDiff), avgDiff: \(totalDiff/Double(testRows.count))")
        case .classifier:
            print("test size: \(testRows.count), total diff: \(totalDiff), misclassification: \(totalDiff/Double(testRows.count))")
        }
    }
}

// MARK: - Math Functions

/// Calculates the GINI impurity of the given subset a dataset.
///
/// - Parameters:
///   - dataset: CSVDataSet
///   - target: feature (target) in the dataset to calculate impurity for
///   - rowIndices: number of row indices into the dataset as the subset
/// - Returns: the gini impurity given the subset and feature of the dataset
func gini(of dataset: CSVDataSet, target: String, rowIndices: [Int]) -> Double {
    let targetColumn = dataset[dynamicMember: target]!
    
    var histogram = [String:Double]()
    for rowIndex in rowIndices {
        let value = targetColumn[rowIndex]
        if let _ = histogram[value] {
            histogram[value]! += 1.0
        }
        else {
            histogram[value] = 0.0
        }
    }
    
    var uncertainty = 0.0
    for v in histogram.values {
        let p = (v / Double(rowIndices.count))
        uncertainty += p * p
    }
    
    return 1.0 - uncertainty
}


/// Calculates the standard variation of the given subset of a datset.
///
/// - Parameters:
///   - dataset: CSVDataSet
///   - target: feature (target) in the dataset to calculate impurity for
///   - rowIndices: number of row indices into the dataset as the subset
/// - Returns: the standard deviation given the subset and feature of the dataset
func std(of dataset: CSVDataSet, target: String, rowIndices: [Int]) -> Double {
    let targetColumn = dataset[dynamicMember: target]!
    let n = Double(rowIndices.count)
    var sum = 0.0
    for rowIndex in rowIndices {
        sum += Double(targetColumn[rowIndex])!
    }
    let mean = sum / n
    var deviation = 0.0
    for rowIndex in rowIndices {
        let diff = Double(targetColumn[rowIndex])! - mean
        deviation += (diff * diff)
    }
    
    return sqrt(deviation / n)
}

// MARK: - TreeType

/// DecisionTree type.
///
/// - classifier: indicates a tree is for classification
/// - regressor: indicates a tree is for regression
enum TreeType {
    case classifier
    case regressor
}

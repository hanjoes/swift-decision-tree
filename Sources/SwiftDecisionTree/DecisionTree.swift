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
    init(dataset:CSVDataSet, features: [String], target: String) {
        self.dataset = dataset
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
    init(dataset: CSVDataSet, rowIndices: [Int], features: [String], target: String) {
        self.dataset = dataset
        self.rowIndices = rowIndices
        self.features = features
        self.target = target
    }
    
    
    /// A tree need to "learn" before it can make predictions.
    func learn() {
        if let rule = DecisionTreeRule.findRule(dataset: self.dataset,
                                                rowIndices: self.rowIndices,
                                                features: features,
                                                target: target) {
            self.rule = rule
            let (left, right) = rule.split(dataset: dataset, rowIndices: self.rowIndices)
            l = DecisionTree(dataset: self.dataset, rowIndices: left, features: features, target: target)
            l?.learn()
            r = DecisionTree(dataset: self.dataset, rowIndices: right, features: features, target: target)
            r?.learn()
        }
    }

    func predict(rowIndex: Int) -> String {
        var currentTree = self
        while currentTree.rule != nil {
            if currentTree.rule!.goRight(dataset: self.dataset, rowIndex: rowIndex) {
                currentTree = currentTree.r!
            }
            else {
                currentTree = currentTree.l!
            }
        }
        return "found"
    }
    
    func predict(rowIndices: [Int]) -> [String] {
        return rowIndices.map { predict(rowIndex: $0) }
    }
    
    func evaluate(testRows: [Int]) {
        let predictions = predict(rowIndices: testRows)
        let targets = dataset[dynamicMember: target]!
        var totalDiff = 0.0
        for (index, prediction) in predictions.enumerated() {
            let expectation = targets[testRows[index]]
            if expectation != prediction {
                totalDiff += 1.0
            }
        }
        print("total diff: \(totalDiff), avgDiff: \(totalDiff/rowIndices.count)")
    }
}

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
    private var rule: DecisionTreeRule?
    private var l: DecisionTree?
    private var r: DecisionTree?
    private var dataset: CSVDataSet

    
    /// Initialize a __DecisionTree__ from a __CSVDataSet__.
    ///
    /// When first constracted from a dataset, the tree is just a container which
    /// stores data. To make it "smart" enough to make predictions, it needs to
    /// "learn" from the features and the target.
    ///
    /// - note: check the __learn__ method
    ///
    /// - Parameter dataSet: the dataset used to build the tree
    init(dataSet:CSVDataSet) {
        self.dataset = dataSet
        var _rowIndices = [Int]()
        for index in 0..<dataSet.rowCount {
            _rowIndices.append(index)
        }
        self.rowIndices = _rowIndices
    }

    private init(dataset: CSVDataSet, rowIndices: [Int]) {
        self.dataset = dataset
        self.rowIndices = rowIndices
    }
    
    
    /// A tree need to "learn" from the specified features before it can classify/predict values.
    ///
    /// - Parameters:
    ///   - features: feature columns as input
    ///   - target: target value as output
    func learn(features: [String], target: String) {
        if let rule = DecisionTreeRule.findRule(dataset: self.dataset,
                                                rowIndices: self.rowIndices,
                                                features: features,
                                                target: target) {
            self.rule = rule
            let (left, right) = rule.split(dataset: dataset, rowIndices: rowIndices)
            l = DecisionTree(dataset: dataset, rowIndices: left)
            l?.learn(features: features, target: target)
            r = DecisionTree(dataset: dataset, rowIndices: right)
            r?.learn(features: features, target: target)
        }
    }

    func predict(X: [Double]) -> Double {
        return 0.0
    }
}

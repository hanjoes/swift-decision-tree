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
    
    var dataSet: CSVDataSet
    let rowIndices: [Int]
    var rule: DecisionTreeRule?
    var l: DecisionTree?
    var r: DecisionTree?
    
    init(dataSet: CSVDataSet, rowIndices: [Int]) {
        self.dataSet = dataSet
        self.rowIndices = rowIndices
    }
    
    init(dataSet: CSVDataSet) {
        self.dataSet = dataSet
        var _rowIndices = [Int]()
        for index in 0..<dataSet.rowCount {
            _rowIndices.append(index)
        }
        self.rowIndices = _rowIndices
    }
    
    func learn(features: [String], target: String) {
        if let rule = DecisionTreeRule.findRule(from: dataSet, with: features, and: target) {
            self.rule = rule
            let (left, right) = rule.split(dataSet: dataSet)
            l = DecisionTree(dataSet: left, rowIndices: rowIndices)
            l?.learn(features: [String](), target: target)
            r = DecisionTree(dataSet: right, rowIndices: rowIndices)
            r?.learn(features: [String](), target: target)
        }
    }

    func predict(X: [Double]) -> Double {
        return 0.0
    }
}

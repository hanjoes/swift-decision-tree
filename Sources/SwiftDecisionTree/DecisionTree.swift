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
//    let level: Int
//    var depth: Int {
//        // TODO
//        return 0
//    }
    
//    var basicStats: String {
//        return String(format: """
//depth: %10d
//level: %10d
//""", depth)
//    }
    
    init(dataSet: CSVDataSet, rowIndices: [Int]) {
        self.dataSet = dataSet
        self.rowIndices = rowIndices
//        self.level = level
    }
    
    init(dataSet:CSVDataSet) {
        self.dataSet = dataSet
        var _rowIndices = [Int]()
        for index in 0..<dataSet.rowCount {
            _rowIndices.append(index)
        }
        self.rowIndices = _rowIndices
//        self.level = 0
    }
    
    func learn(features: [String], target: String) {
        if let rule = DecisionTreeRule.findRule(from: dataSet, rows: rowIndices, with: features, and: target) {
            self.rule = rule
            let (left, right) = rule.split(dataSet: dataSet)
            print("left: \(left.count) rows, right: \(right.count) rows")
            l = DecisionTree(dataSet: dataSet, rowIndices: left)
            l?.learn(features: features, target: target)
            r = DecisionTree(dataSet: dataSet, rowIndices: right)
            r?.learn(features: features, target: target)
            
        }
    }

    func predict(X: [Double]) -> Double {
        return 0.0
    }
}

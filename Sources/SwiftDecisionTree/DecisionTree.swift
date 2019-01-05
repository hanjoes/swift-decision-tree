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
/// Reference from: [Wikipedia Predictive Analytics CART](https://en.wikipedia.org/wiki/Predictive_analytics#Classification_and_regression_trees_.28CART.29)
class DecisionTree {
    
    var dataSet: CSVDataSet
    var rule: DecisionTreeRule?
    var l: DecisionTree?
    var r: DecisionTree?
    
    init(dataSet: CSVDataSet) {
        self.dataSet = dataSet
    }
    
    func learn(features: [String], target: String) {
        if let rule = DecisionTreeRule.findRule(from: dataSet, with: features, and: target) {
            self.rule = rule
            let (left, right) = rule.split(dataSet: dataSet, features: features, target: target)
            l = DecisionTree(dataSet: left)
            l?.learn(features: [String](), target: "")
            r = DecisionTree(dataSet: right)
            r?.learn(features: [String](), target: "")
        }
    }

    func predict(X: [Double]) -> Double {
        return 0.0
    }
}

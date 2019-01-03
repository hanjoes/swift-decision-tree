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
class DecisionTree<T> where T: Comparable & Equatable {

	var root: DecisionTreeNode<T>

	init(root: DecisionTreeNode<T>) {
		self.root = root
	}

    static func learn(X: [[String]], y: [String]) -> DecisionTree {
		let root = split(X: X, y: y)
		return DecisionTree<T>(root: root)
    }

	private static func split(X: [[String]], y: [String]) -> DecisionTreeNode<T> {
		return DecisionTreeNode<T>(isLeaf: true, dataSet: (X, y))
	}
	
	func predict(X: [Double]) -> Double {
		return 0.0
	}
}

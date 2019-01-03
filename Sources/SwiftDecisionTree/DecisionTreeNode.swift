import Foundation


/// A __node__ represents a portion of the dataset.
class DecisionTreeNode<T> where T: Comparable & Equatable {
	let isLeaf: Bool
	var left: DecisionTreeNode?
	var right: DecisionTreeNode?
	var DecisionTreeRule: DecisionTreeRule<T>?
	
	init(isLeaf: Bool, dataSet: (X: [[String]], y: [String])) {
		self.isLeaf = isLeaf
	}
}

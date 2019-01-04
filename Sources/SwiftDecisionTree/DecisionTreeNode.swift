import Foundation


/// A __node__ represents a portion of the dataset.
class DecisionTreeNode {
    let isLeaf: Bool
    var left: DecisionTreeNode?
    var right: DecisionTreeNode?
    var DecisionTreeRule: DecisionTreeRule?
    
    init(isLeaf: Bool, dataSet: (X: [[String]], y: [String])) {
        self.isLeaf = isLeaf
    }
}

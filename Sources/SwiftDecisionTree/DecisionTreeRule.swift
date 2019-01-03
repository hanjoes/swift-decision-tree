import Foundation


/// Rule is an abstraction of the guidelines for dividing the __nodes__.
///
/// Each rule uses a rule from one feature as the boundary to split the dataset.
/// Rules can either be _numeric (for continuous values like length, weight, etc.)_ or _non-numeric (discrete values,
/// categories like: color, sex, etc.)_
///
struct DecisionTreeRule<T> where T: Comparable & Equatable {
    var feature: String
    var boundary: T
    var isNumeric: Bool
    
    func conditionSatisfied(x: T) -> Bool {
        if isNumeric {
            return x > boundary
        }
        else {
            return x == boundary
        }
    }
}

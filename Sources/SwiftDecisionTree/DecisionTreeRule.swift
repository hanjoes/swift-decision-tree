import Foundation


/// Rule is an abstraction of the guidelines for dividing the __nodes__.
///
/// Each rule uses a rule from one feature as the boundary to split the dataset.
/// Rules can either be _numeric (for continuous values like length, weight, etc.)_ or _non-numeric (discrete values,
/// categories like: color, sex, etc.)_
///
struct DecisionTreeRule {
    var feature: String
    var boundary: Double
    var isNumeric: Bool
    
    func split(dataSet: CSVDataSet, features: [String], target: String) -> (left: CSVDataSet, right: CSVDataSet) {
        return (CSVDataSet(content: "", withHeader: false, separator: ",")!, CSVDataSet(content: "", withHeader: false, separator: ",")!)
    }
    
    func conditionSatisfied(x: Double) -> Bool {
        if isNumeric {
            return x > boundary
        }
        else {
            return x == boundary
        }
    }
    
    static func findRule(from dataSet: CSVDataSet,
                         with features: [String],
                         and target: String) -> DecisionTreeRule? {
        return nil
    }
}

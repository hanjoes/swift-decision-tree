import Foundation


/// Rule is an abstraction of the guidelines for dividing the __nodes__.
///
/// Each rule uses a rule from one feature as the boundary to split the dataset.
/// Rules can either be _numeric (for continuous values like length, weight, etc.)_ or _non-numeric (discrete values,
/// categories like: color, sex, etc.)_
///
struct DecisionTreeRule {
    var feature: String
    var boundary: String
    var ruleType: RuleType
    
    private static let THRESHOLD = 0.1
    
    enum RuleType {
        case numeric
        case object
    }
    
    func split(dataset: CSVDataSet, rowIndices: [Int]) -> (leftRows: [Int], rightRows: [Int]) {
        return DecisionTreeRule.divide(dataset: dataset, using: self.boundary, for: self.feature, rowIndices: rowIndices, type: self.ruleType)
    }

    static func findRule(dataset: CSVDataSet,
                         rowIndices: [Int],
                         features: [String],
                         target: String) -> DecisionTreeRule? {
        let currentGini = gini(of: dataset, target: target, rowIndices: rowIndices)
        var maxInformationGain = 0.0
        var result: (String, String, RuleType)?
        for feature in features {
            if let (lgini, rgini, boundary, type) = findBoundary(for: feature,
                                                                 target: target,
                                                                 rowIndices: rowIndices,
                                                                 in: dataset) {
                // simple information gain by subtracting the avg of subtrees' gini from the parent's gini
                let avgGini = (lgini + rgini) / 2
                let informationGain = currentGini - avgGini
                if informationGain > maxInformationGain {
                    maxInformationGain = informationGain
                    result = (feature, boundary, type)
                }
            }
        }
        
        guard let (feature, boundary, type) = result else {
            return nil
        }
        return DecisionTreeRule(feature: feature, boundary: boundary, ruleType: type)
    }
    
    private static func findBoundary(for feature: String,
                                     target: String,
                                     rowIndices: [Int],
                                     in dataset: CSVDataSet) -> (Double, Double, String, RuleType)? {
        let column = dataset[dynamicMember: feature]!
        let type = analyze(column: column)
        var maxInformationGain = Double(Int.min)
        var result: (Double, Double, String, RuleType)?
        for rowIndex in rowIndices {
            let currentBoundary = column[rowIndex]
            let (l, r) = divide(dataset: dataset, using: currentBoundary, for: feature, rowIndices: rowIndices, type: type)
            if l.count == 0 || r.count == 0 {
                continue
            }
            let lgini = gini(of: dataset, target: target, rowIndices: l)
            let rgini = gini(of: dataset, target: target, rowIndices: r)
            let informationGain =  -((lgini + rgini) / 2)
            if informationGain > maxInformationGain {
                maxInformationGain = informationGain
                result = (lgini, rgini, currentBoundary, type)
            }
        }
        return result
    }
    
    private static func divide(dataset: CSVDataSet, using boundary: String,
                               for feature: String, rowIndices: [Int],
                               type: RuleType) -> ([Int], [Int]) {
        var left = [Int]()
        var right = [Int]()
        let column = dataset[dynamicMember: feature]!
        for rowIndex in rowIndices {
            let value = column[rowIndex]
            switch type {
            case .numeric:
                if Double(value)! < Double(boundary)! {
                    left.append(rowIndex)
                }
                else {
                    right.append(rowIndex)
                }
            case .object:
                if value != boundary {
                    left.append(rowIndex)
                }
                else {
                    right.append(rowIndex)
                }
            }
        }
        return (left, right)
    }

    private static func analyze(column: [String]) -> RuleType {
        return column.allSatisfy { Double($0) != nil } ? .numeric : .object
    }
    
    private static func gini(of dataset: CSVDataSet, target: String, rowIndices: [Int]) -> Double {
        let targetColumn = dataset[dynamicMember: target]!
        
        var histogram = [String:Double]()
        for rowIndex in rowIndices {
            let value = targetColumn[rowIndex]
            if let _ = histogram[value] {
                histogram[value]! += 1.0
            }
            else {
                histogram[value] = 0.0
            }
        }
        
        var uncertainty = 0.0
        for v in histogram.values {
            let p = (v / Double(rowIndices.count))
            uncertainty += p * p
        }
        
        return 1.0 - uncertainty
    }
}

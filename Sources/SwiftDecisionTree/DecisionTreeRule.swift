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

    enum RuleType {
        case numeric
        case object
    }

    /// Finds a __DecisionTreeRule__ for a given dataset and feature/target sets.
    ///
    /// - Parameters:
    ///   - dataset: dataset
    ///   - rowIndices: indices into the dataset as input
    ///   - features: list of feature (columns) in the given dataset as input
    ///   - target: the target (column) used as the output
    ///   - purity: function to calculate purity (e.g.: gini for classification and standard deviation for regression)
    /// - Returns: a __DecisionTreeRule__ object based on the input dataset.
    static func findRule(dataset: CSVDataSet,
                         rowIndices: [Int],
                         features: [String],
                         target: String,
                         purity: (CSVDataSet, String, [Int]) -> Double) -> DecisionTreeRule? {
        let currentGini = purity(dataset, target, rowIndices)
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
    
    /// Split a given dataset into two sets, indicated by the row indices.
    ///
    /// - Parameters:
    ///   - dataset: the dataset to be split
    ///   - rowIndices: the row indices to be considered in the given dataset
    /// - Returns: a tuple containing two row indices lists, should add up to the input row indices list
    func split(dataset: CSVDataSet, rowIndices: [Int]) -> (leftRows: [Int], rightRows: [Int]) {
        return DecisionTreeRule.divide(dataset: dataset,
                                       boundary: self.boundary,
                                       feature: self.feature,
                                       rowIndices: rowIndices,
                                       type: self.ruleType)
    }
    
    func goRight(dataset: CSVDataSet, rowIndex: Int) -> Bool {
        let column = dataset[dynamicMember: feature]!
        let value = column[rowIndex]
        return DecisionTreeRule.goesRight(value: value, ruleType: self.ruleType, boundary: self.boundary)
    }
}

// MARK: - Utility

private extension DecisionTreeRule {
    
    static let THRESHOLD = 0.1
    
    static func goesRight(value: String, ruleType: RuleType, boundary: String) -> Bool {
        switch ruleType {
        case .numeric:
            if Double(value)! < Double(boundary)! {
                return false
            }
            else {
                return true
            }
        case .object:
            if value != boundary {
                return false
            }
            else {
                return true
            }
        }
    }
    
    static func findBoundary(for feature: String,
                                     target: String,
                                     rowIndices: [Int],
                                     in dataset: CSVDataSet) -> (Double, Double, String, RuleType)? {
        let column = dataset[dynamicMember: feature]!
        let type = analyze(column: column)
        var maxInformationGain = Double(Int.min)
        var result: (Double, Double, String, RuleType)?
        for rowIndex in rowIndices {
            let currentBoundary = column[rowIndex]
            let (l, r) = divide(dataset: dataset,
                                boundary: currentBoundary,
                                feature: feature,
                                rowIndices: rowIndices,
                                type: type)
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
    
    static func divide(dataset: CSVDataSet,
                               boundary: String,
                               feature: String,
                               rowIndices: [Int],
                               type: RuleType) -> ([Int], [Int]) {
        var left = [Int]()
        var right = [Int]()
        let column = dataset[dynamicMember: feature]!
        for rowIndex in rowIndices {
            let value = column[rowIndex]
            if DecisionTreeRule.goesRight(value: value, ruleType: type, boundary: boundary) {
                right.append(rowIndex)
            }
            else {
                left.append(rowIndex)
            }
        }
        return (left, right)
    }
    
    static func analyze(column: [String]) -> RuleType {
        return column.allSatisfy { Double($0) != nil } ? .numeric : .object
    }

}

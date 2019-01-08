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
    
    func split(dataSet: CSVDataSet) -> (left: CSVDataSet, right: CSVDataSet) {
        let boundaryColumn = dataSet[dynamicMember: feature]!
        var leftRows = [[String]]()
        var rightRows = [[String]]()
        for (index, value) in boundaryColumn.enumerated() {
            switch ruleType {
            case .numeric:
                if Double(value)! < Double(boundary)! {
                    leftRows.append(dataSet[index]!)
                }
                else {
                    rightRows.append(dataSet[index]!)
                }
            case .object:
                if value != boundary {
                    leftRows.append(dataSet[index]!)
                }
                else {
                    rightRows.append(dataSet[index]!)
                }
            }
        }
        
        let headers = dataSet.headers.keys.map { $0 }
        return (CSVDataSet(rows: leftRows, headers: headers), CSVDataSet(rows: rightRows, headers: headers))
    }

    static func findRule(from dataSet: CSVDataSet,
                         with features: [String],
                         and target: String) -> DecisionTreeRule? {
        let targetColumn = dataSet[dynamicMember: target]!
        let currentGini = gini(of: targetColumn)
        var maxInformationGain = 0.0
        var result: (String, String, RuleType)?
        for feature in features {
            print("analyzing feature: \(feature), maxInformationGain: \(maxInformationGain)")
            let currentColumn = dataSet[dynamicMember: feature]!
            if let (lgini, rgini, boundary, type) = findBestBoundary(target: targetColumn,
                                                                     column: currentColumn,
                                                                     currentGini: currentGini) {

                // simple information gain by subtracting the avg of subtrees' gini from the parent's gini
                let avgGini = (lgini + rgini) / 2
                let informationGain = currentGini - avgGini
                print("lgini: \(lgini), rgini: \(rgini), informationGain: \(informationGain)")
                if informationGain > maxInformationGain {
                    maxInformationGain = informationGain
                    result = (feature, boundary, type)
                }
            }
        }
        
        guard let (feature, boundary, type) = result else {
            return nil
        }
        print("found rule with feature: \(feature), boundary: \(boundary), type: \(type)")
        return DecisionTreeRule(feature: feature, boundary: boundary, ruleType: type)
    }
    
    private static func findBestBoundary(target: [String], column: [String],
                                         currentGini: Double) -> (Double, Double, String, RuleType)? {
        let type = analyze(column: column)
        var maxInformationGain = 0.0
        var result: (Double, Double, String, RuleType)?
        for currentBoundary in column {
            let (l, r) = divide(target: target, boundary: currentBoundary, feature: column, type: type)
            let lgini = gini(of: l)
            let rgini = gini(of: r)
            let informationGain = currentGini - ((lgini + rgini) / 2)
//            print("currentBoundary \(currentBoundary), divided, l size: \(l.count), r size: \(r.count), lgini: \(lgini), rgini: \(rgini), informationGain: \(informationGain)")
            if informationGain > maxInformationGain {
                maxInformationGain = informationGain
                result = (lgini, rgini, currentBoundary, type)
            }
        }
        return result
    }
    
    private static func divide(target: [String], boundary: String,
                               feature: [String], type: RuleType) -> ([String], [String]) {
        var left = [String]()
        var right = [String]()
        switch type {
        case .numeric:
            for (index, value) in feature.enumerated() {
                if Double(value)! < Double(boundary)! {
                    left.append(target[index])
                }
                else {
                    right.append(target[index])
                }
            }
        case .object:
            for (index, value) in feature.enumerated() {
                if value != boundary {
                    left.append(target[index])
                }
                else {
                    right.append(target[index])
                }
            }
            
        }
        return (left, right)
    }
    
    private static func analyze(column: [String]) -> RuleType {
        return column.allSatisfy { Double($0) != nil } ? .numeric : .object
    }

    private static func gini(of rows: [String]) -> Double {
        var histogram = [String:Double]()
        for value in rows {
            if let _ = histogram[value] {
                histogram[value]! += 1.0
            }
            else {
                histogram[value] = 0.0
            }
        }
        
        var uncertainty = 0.0
        for v in histogram.values {
            let p = (v / Double(rows.count))
            uncertainty += p * p
        }

        return 1.0 - uncertainty
    }
}

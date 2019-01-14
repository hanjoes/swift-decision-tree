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
    
    func split(dataSet: CSVDataSet, rows: [Int]) -> (leftRows: [Int], rightRows: [Int]) {
        let boundaryColumn = dataSet[dynamicMember: feature]!
        var leftRows = [Int]()
        var rightRows = [Int]()
        for rowIndex in rows {
            let value = boundaryColumn[rowIndex]
            switch ruleType {
            case .numeric:
                if Double(value)! < Double(boundary)! {
                    leftRows.append(rowIndex)
                }
                else {
                    rightRows.append(rowIndex)
                }
            case .object:
                if value != boundary {
                    leftRows.append(rowIndex)
                }
                else {
                    rightRows.append(rowIndex)
                }
            }
        }
        return (leftRows, rightRows)
    }

    static func findRule(from dataSet: CSVDataSet,
                         rows: [Int],
                         with features: [String],
                         and target: String) -> DecisionTreeRule? {
        let targetColumn = dataSet[dynamicMember: target]!
        let currentGini = gini(of: targetColumn)
        var maxInformationGain = 0.0
        var result: (String, String, RuleType)?
        for feature in features {
//            print("analyzing feature: \(feature), maxInformationGain: \(maxInformationGain)")
            let currentColumn = dataSet[dynamicMember: feature]!
            if let (lgini, rgini, boundary, type) = findBestBoundary(target: targetColumn,
                                                                     column: currentColumn,
                                                                     rows: rows,
                                                                     currentGini: currentGini) {

                // simple information gain by subtracting the avg of subtrees' gini from the parent's gini
                let avgGini = (lgini + rgini) / 2
                let informationGain = currentGini - avgGini
//                print("lgini: \(lgini), rgini: \(rgini), informationGain: \(informationGain)")
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
    
    private static func findBestBoundary(target: [String], column: [String], rows: [Int],
                                         currentGini: Double) -> (Double, Double, String, RuleType)? {
        let type = analyze(column: column)
        var maxInformationGain = 0.0
        var result: (Double, Double, String, RuleType)?
        for rowIndex in rows {
            let currentBoundary = column[rowIndex]
            let (l, r) = divide(target: target, boundary: currentBoundary, feature: column, rows: rows, type: type)
            if l.count == 0 || r.count == 0 {
                continue
            }
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
                               feature column: [String], rows: [Int],
                               type: RuleType) -> ([String], [String]) {
        var left = [String]()
        var right = [String]()
        for row in rows {
            let value = column[row]
            switch type {
                case .numeric:
                    if Double(value)! < Double(boundary)! {
                        left.append(target[row])
                    }
                    else {
                        right.append(target[row])
                    }
                case .object:
                    if value != boundary {
                        left.append(target[row])
                    }
                    else {
                        right.append(target[row])
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

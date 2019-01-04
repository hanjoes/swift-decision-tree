import Foundation

/// Naive _DataSet_ represents a collection of data.
///
/// It supports index using both column names and row numbers.
/// This implementation stores everything in the memory.
@dynamicMemberLookup
class CSVDataSet {
    
    private var headers: [String:Int]?
    private var dataFrame = [[String]]()
    
    /// Initialize from csv string.
    ///
    /// - Parameters:
    ///   - content: csv content string
    ///   - withHeader: boolean indicating whether this CSV object has header
    ///   - separator: separator used in the CSV to separate values
    init?(content: String, withHeader: Bool, separator: Character) {
        guard content.count > 0 else { return nil }
        self.iniializeFromContent(content: content, withHeader: withHeader, separator: separator)
    }
    
    /// Initialize from a path pointing to a CSV file.
    ///
    /// - Parameters:
    ///   - content: csv content string
    ///   - withHeader: boolean indicating whether this CSV object has header
    ///   - separator: separator used in the CSV to separate values
    init?(csvPath path: String, withHeader: Bool, separator: Character) {
        if let content = try? String(contentsOfFile: path) {
            self.iniializeFromContent(content: content, withHeader: withHeader, separator: separator)
        }
        return nil
    }
    
    
    /// Divide the dataset into two features and target vectors.
    ///
    /// - Parameters:
    ///   - features: a list of feature names
    ///   - target: target name
    /// - Returns: tuple that has feature (X, 2d) and target (y) vectors.
    func divide(into features: [String], and target: String) -> (X: [[String]], Y: [String]?) {
        let y = self[dynamicMember: target]
        var X = [[String]]()
        for feature in features {
            if let featureX = self[dynamicMember: feature] {
                X.append(featureX)
            }
        }
        return (X, y)
    }
    
    private func iniializeFromContent(content: String, withHeader: Bool, separator: Character) {
        let lines = content.split(separator: "\n")
        if withHeader {
            headers = [String:Int]()
            lines[0].split(separator: separator,
                           maxSplits: Int.max,
                           omittingEmptySubsequences: false).enumerated().forEach {
                (arg) in
                let (index, header) = arg
                headers![header.trimmingCharacters(in: CharacterSet.whitespaces)] = index
            }
        }
        let contentRows = lines.dropFirst()
        
        for row in contentRows {
            dataFrame.append(row.split(separator: separator,
                                       maxSplits: Int.max,
                                       omittingEmptySubsequences: false).map {
                return $0.trimmingCharacters(in: CharacterSet.whitespaces)
            })
        }
    }
    
    subscript(row: Int) -> [String] {
        return dataFrame[row]
    }
    
    subscript(row: Int, col: Int) -> String {
        return dataFrame[row][col]
    }
    
    subscript(dynamicMember member: String) -> [String]? {
        guard let headers = headers else {
            return nil
        }
        
        guard let mappedColumnIndex = headers[member], mappedColumnIndex >= 0 else {
            return nil
        }
        
        var result = [String]()
        for row in dataFrame {
            if mappedColumnIndex < row.count {
                result.append(row[mappedColumnIndex])
            }
        }
        
        return result
    }
}

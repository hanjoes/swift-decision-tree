import Foundation

/// Naive _DataSet_ represents a collection of data.
///
/// It supports index using both column names and row numbers.
/// This implementation stores everything in the memory.
@dynamicMemberLookup
class CSVDataSet {
    
    var headers = [String:Int]()
    
    var rowCount: Int {
        return dataFrame.count
    }
    
    private var dataFrame = [[String]]()
    
    /// Initialize from csv string.
    ///
    /// - Parameters:
    ///   - content: csv content string
    ///   - withHeader: boolean indicating whether this CSV object has header
    ///   - separator: separator used in the CSV to separate values
    init(content: String, withHeader: Bool, separator: Character) {
        self.initalizeFromContent(content: content, withHeader: withHeader, separator: separator)
    }
    
    /// Initialize from a path pointing to a CSV file.
    ///
    /// - Parameters:
    ///   - content: csv content string
    ///   - withHeader: boolean indicating whether this CSV object has header
    ///   - separator: separator used in the CSV to separate values
    init?(csvPath path: String, withHeader: Bool, separator: Character) {
        guard let content = try? String(contentsOfFile: path) else { return nil }
        self.initalizeFromContent(content: content, withHeader: withHeader, separator: separator)
    }
    
    
    /// Initialize directly from rows and headers.
    ///
    /// - Parameters:
    ///   - rows: list of rows
    ///   - headers: headers
    init(rows: [[String]], headers: [String]) {
        self.dataFrame = rows
        for (index, header) in headers.enumerated() {
            self.headers[header] = index
        }
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
            guard let featureX = self[dynamicMember: feature] else {
                continue
            }
            X.append(featureX)
        }
        return (X, y)
    }

    /// Access a whole role by row index.
    ///
    /// When the index is out-of-bound, return _nil_.
    ///
    /// - Parameter row: row index
    subscript(row: Int) -> [String]? {
        guard row >= 0 && row < dataFrame.count else {
            return nil
        }
        return dataFrame[row]
    }

    /// Access one sigle element by row index and column index.
    ///
    /// When the index is out-of-bound, return _nil_.
    ///
    /// - Parameters:
    ///   - row: row index
    ///   - col: column index
    subscript(row: Int, col: Int) -> String? {
        guard row >= 0 && row < dataFrame.count else {
            return nil
        }
        
        guard col >= 0 && col < dataFrame[row].count else {
            return nil
        }
        return dataFrame[row][col]
    }
    
    /// Access one whole column by the name of that column.
    ///
    /// When the column doesn't exist, return _nil_.
    ///
    /// - Parameter member: column name
    subscript(dynamicMember member: String) -> [String]? {
        guard let colIndex = headers[member] else {
            return nil
        }
        
        var result = [String]()
        for row in dataFrame {
            if colIndex < row.count {
                result.append(row[colIndex])
            }
        }
        
        return result
    }
    
    private func initalizeFromContent(content: String, withHeader: Bool, separator: Character) {
        var lines = content.split(separator: "\n")
        if lines.count > 0 {
            let columns = lines[0].split(separator: separator,
                                         maxSplits: Int.max,
                                         omittingEmptySubsequences: false)
            if withHeader {
                columns.enumerated().forEach {
                    (index, header) in
                    let trimmedHeader = header.trimmingCharacters(in: CharacterSet.whitespaces)
                    if trimmedHeader.count > 0 {
                        headers[trimmedHeader] = index
                    }
                    else {
                        headers["column\(index)"] = index
                    }
                }
            }
            else {
                let columnCount = columns.count
                for index in 0..<columnCount {
                    headers["column\(index)"] = index
                }
            }
        }
        else {
            headers["column0"] = 0

        }
        

        let firstIndex = withHeader ? 1 : 0
        
        if lines.count > (withHeader ? 1 : 0) {
            for row in lines[firstIndex...] {
                dataFrame.append(row.split(separator: separator,
                                           maxSplits: Int.max,
                                           omittingEmptySubsequences: false).map {
                                            return $0.trimmingCharacters(in: CharacterSet.whitespaces)
                })
            }
        }
    }
}

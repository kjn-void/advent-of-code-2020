import Foundation

func inputGet() -> [Int64] {
    let cwdURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = URL(fileURLWithPath: "input", relativeTo: cwdURL).appendingPathExtension("txt")
    let content = try! String(contentsOf: fileURL, encoding: String.Encoding.utf8)
    return content.components(separatedBy: "\n").filter { $0.length > 0 }.map { Int64($0)! }
}

let input = inputGet().sorted { $0 < $1 } 
let requiredSum: Int64 = 2020

extension RandomAccessCollection {    
    func binarySearch(predicate: (Element) -> Int64) -> Element? {
        var lo = startIndex
        var hi = endIndex
        while lo != hi {
            let i = index(lo, offsetBy: distance(from: lo, to: hi) / 2)
            switch predicate(self[i]) {
            case let diff where diff < 0:
                lo = index(after: i)
            case let diff where diff > 0:
                hi = i
            default:
                return self[i]
            }

        }
        return nil
    }
}

func part1(expenseReport: [Int64]) -> Int64? {
    for (i, x) in input.enumerated() {
        if let y = input[(i+1)...].binarySearch(predicate: { $0 + x - requiredSum }) {
            return x * y
        }
    }
    return nil
}

func part2(expenseReport: [Int64]) -> Int64?  {
    for (i, x) in input.enumerated() {
        for (j, y) in input[(i+1)...].enumerated() {
            if let z = input[(j+1)...].binarySearch(predicate: { $0 + x + y - requiredSum }) {
                return x * y * z
            }
        }
    }
    return nil
}

print("🌟 Part 1 : \(part1(expenseReport: input)!)")
print("🌟 Part 2 : \(part2(expenseReport: input)!)")

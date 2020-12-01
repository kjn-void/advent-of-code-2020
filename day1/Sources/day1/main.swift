import Foundation

func inputGet() -> [UInt64] {
    let cwdURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = URL(fileURLWithPath: "input", relativeTo: cwdURL).appendingPathExtension("txt")
    let content = try! String(contentsOf: fileURL, encoding: String.Encoding.utf8)
    return content.components(separatedBy: "\n").filter { $0.length > 0 }.map { UInt64($0)! }
}

let input = inputGet()
let requiredSum = 2020

func part1(expenseReport: [UInt64]) -> UInt64? {
    for (i, x) in input.enumerated() {
        for y in input[(i+1)...] {
            if x + y == requiredSum {
                return x * y
            }
        }
    }
    return nil
}

func part2(expenseReport: [UInt64]) -> UInt64?  {
    for (i, x) in input.enumerated() {
        for (j, y) in input[(i+1)...].enumerated() {
            for z in input[(j+1)...] {
                if x + y + z == requiredSum {
                    return x * y * z
                }
            }
        }
    }
    return nil
}

print("🌟 Part 1 : \(part1(expenseReport: input)!)")
print("🌟 Part 2 : \(part2(expenseReport: input)!)")

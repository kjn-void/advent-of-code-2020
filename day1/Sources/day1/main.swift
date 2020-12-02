import Foundation
import AocUtils

func part1(expenseReport: [UInt64], requiredSum: UInt64) -> UInt64? {
    for (i, x) in expenseReport.enumerated() {
        for y in expenseReport[(i+1)...] {
            if x + y == requiredSum {
                return x * y
            }
        }
    }
    return nil
}

func part2(expenseReport: [UInt64], requiredSum: UInt64) -> UInt64?  {
    for (i, x) in expenseReport.enumerated() {
        for (j, y) in expenseReport[(i+1)...].enumerated() {
            for z in expenseReport[(j+1)...] {
                if x + y + z == requiredSum {
                    return x * y * z
                }
            }
        }
    }
    return nil
}

let input = inputGet().map { UInt64($0)! }
print("🌟 Part 1 : \(part1(expenseReport: input, requiredSum: 2020)!)")
print("🌟 Part 2 : \(part2(expenseReport: input, requiredSum: 2020)!)")

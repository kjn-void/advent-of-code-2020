import AocUtils

func havePair(sum: Int64, candidates: ArraySlice<Int64>) -> Bool {
    for (i, x) in candidates.enumerated() {
        for y in candidates[(i + candidates.startIndex + 1)...] {
            if x + y == sum {
                return true
            }
        }
    }
    return false
}

func firstViolationFind(_ numbers: [Int64], _ preambleLen: Int) -> Int64? {
    var ns = numbers[0..<(preambleLen-1)]
    for i in preambleLen..<numbers.count {
        ns.append(numbers[i-1])
        let n = numbers[i]
        if !havePair(sum: n, candidates: ns) {
            return n
        }
        ns.removeFirst(1)
    }
    return nil
}

func contiguousSetFind(_ numbers: [Int64], _ fv: Int64) -> ArraySlice<Int64>? {
    for first in 0..<numbers.count {
        var last = first + 1
        var sum = numbers[first]
        while sum < fv {
            sum += numbers[last]
            last += 1
        }
        if sum == fv {
            return numbers[first...last]
        }
    }
    return nil
}

let numbers = inputGet().map{ Int64($0)! }
let preambleLen = numbers.count > 25 ? 25 : 5;

bench {
    let fv = firstViolationFind(numbers, preambleLen)!    
    print("🌟 Part 1 : \(fv)")
    let cs = contiguousSetFind(numbers, fv)!
    print("🌟 Part 2 : \(cs.min()! + cs.max()!)")    
}

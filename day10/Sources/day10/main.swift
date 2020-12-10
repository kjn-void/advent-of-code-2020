import AocUtils

extension Collection where Element: Numeric {
    func adjacentDifference() -> [Element] {
        return zip(self.dropFirst(), self).map(-)
    }
}

func countAdjacent(_ numbers: [Int], what: Int) -> [Int] {
    var series = Array<Int>()
    var cnt = 0
    for n in numbers {
        if n == what {
            cnt += 1
        } else if cnt > 0 {
            series.append(cnt)
            cnt = 0
        }
    }
    return series
}

func distinctArrangements(oneLengths: [Int]) -> Int64 {
    var cnt: Int64 = 1
    for n in oneLengths {
        cnt *= tribinacci(n)
    }
    return cnt
}

func tribinacci(_ n: Int) -> Int64 {
    if n < 0 {
        return 0
    }
    if n == 0 {
        return 1
    }
    return tribinacci(n - 3) + tribinacci(n - 2) + tribinacci(n - 1)
}

let adapters = inputGet().map{ Int($0)! }

bench {
    let series = ([0] + adapters.sorted() + [adapters.max()! + 3])
    let steps = series.adjacentDifference()
    let ones = steps.filter{ $0 == 1 }.count
    let threes = steps.filter{ $0 == 3 }.count
    print("🌟 Part 1 : \(ones * threes)")
    let adjOnes = countAdjacent(steps, what: 1)
    print("🌟 Part 2 : \(distinctArrangements(oneLengths: adjOnes))")
}

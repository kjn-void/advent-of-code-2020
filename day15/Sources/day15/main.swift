import AocUtils

let startNumbers = inputGet()
  .first!
  .components(separatedBy: ",")
  .map{ Int($0)! }

func numberGame(startNumbers: [Int], rounds: Int) -> Int {
    var history = Array(repeating: 0, count: rounds)
    for (turn, sn) in startNumbers.dropLast(1).enumerated() {
        history[sn] = turn + 1
    }
    var lastSpoken = startNumbers.last!
    for turn in startNumbers.count..<rounds {
        let spoken = history[lastSpoken] == 0 ? 0 : turn - history[lastSpoken]
        history[lastSpoken] = turn
        lastSpoken = spoken
    }
    return lastSpoken
}

bench {
    print("🌟 Part 1 : \(numberGame(startNumbers: startNumbers, rounds: 2020))")
}

bench {
    print("🌟 Part 2 : \(numberGame(startNumbers: startNumbers, rounds: 30_000_000))")
}

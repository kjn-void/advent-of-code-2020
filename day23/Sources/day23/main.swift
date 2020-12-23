import AocUtils

typealias Cup = Int
typealias NextCup = Int

struct CrabCups {
    var cups: Array<NextCup>
    var current: Cup

    var part1: String {
        var cup = cups[1]
        var labels = ""
        while cup != 1 {
            labels += "\(cup)"
            cup = cups[cup]
        }
        return labels
    }
    
    var part2: Int64 {
        let cw1 = cups[1]
        let cw2 = cups[cw1]
        return Int64(cw1) * Int64(cw2)
    }
    
    init(_ labels: [Cup], ringSize: Int = 9) {
        current = labels[0]
        cups = Array<Int>(repeating: -1, count: ringSize + 1)
        for i in 0..<(labels.count - 1) {
            // "cups[i]" is the cup clockwise to cup "i"
            cups[labels[i]] = labels[i + 1]
        }
        if labels.count >= ringSize {
            cups[labels.last!] = current
        } else {
            cups[labels.last!] = (labels.count + 1)
            for i in (labels.count + 1)..<ringSize {
                cups[i] = i + 1
            }
            cups[ringSize] = current
        }
    }
    
    mutating func move() {
        let pickHead = cups[current]
        let pickMid = cups[pickHead]
        let pickTail = cups[pickMid]
        var dest = current
        repeat {
            dest -= 1
            if dest == 0 {
                dest = cups.count - 1
            }
        } while dest == pickHead || dest == pickMid || dest == pickTail
        // Current cup is now followed by what used to follow last picked up cup
        cups[current] = cups[pickTail]
        // Insert the picked-up sequence between destination and what used to
        // follow destination
        cups[pickTail] = cups[dest]
        cups[dest] = pickHead
        // Move current pointer one step clockwise
        current = cups[current]
    }
}

let labels = inputGet()[0].map{ Cup(String($0))! }

bench {
    var cups = CrabCups(labels)
    for _ in 1...100 {
        cups.move()
    }
    print("🌟 Part 1 :", cups.part1)
}

bench {
    var cups = CrabCups(labels, ringSize: 1_000_000)
    for _ in 1...10_000_000 {
        cups.move()
    }
    print("🌟 Part 2 :", cups.part2)
}

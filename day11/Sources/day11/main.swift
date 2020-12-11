import AocUtils

struct Pos: Hashable {
    var x: Int
    var y: Int    
}

extension Pos {
    static func + (a: Pos, b: Pos) -> Pos {
        return Pos(x: a.x + b.x, y: a.y + b.y)
    }
}

struct WaitingArea {
    var seats: Set<Pos> = Set<Pos>()
    var occupied: Set<Pos> = Set<Pos>()
    var width: Int
    var height: Int
    var isPart1: Bool
    
    init(desc: [String], part1: Bool) {
        isPart1 = part1
        for (y, line) in desc.enumerated() {
            for (x, tile) in line.enumerated() {
                if tile != "." {
                    seats.insert(Pos(x: x, y: y))
                }
            }
        }
        width = desc[0].count
        height = desc.count
    }

    func countAdjacentOccupied(pos: Pos) -> Int {
        var cnt = 0
        for dy in -1...1 {
            for dx in -1...1 {
                if !(dy == 0 && dx == 0) && occupied.contains(Pos(x: pos.x + dx, y: pos.y + dy)) {
                    cnt += 1
                }
            }
        }
        return cnt
    }

    func isOccupiedVisible(from: Pos, dir: Pos) -> Bool {
        var pos = from + dir
        while pos.x >= 0 && pos.x < width && pos.y >= 0 && pos.y < height {
            if occupied.contains(pos) {
                return true
            }
            if seats.contains(pos) {
                return false
            }
            pos = pos + dir
        }
        return false
    }
    
    func countVisibleOccupied(pos: Pos) -> Int {
        var cnt = 0
        for dy in -1...1 {
            for dx in -1...1 {
                if !(dy == 0 && dx == 0) && isOccupiedVisible(from: pos, dir: Pos(x: dx, y: dy)) {
                    cnt += 1
                }
            }
        }
        return cnt        
    }
    
    mutating func nextGeneration() -> Bool {
        var nextOccupied = Set<Pos>()

        for seat in seats {
            if isPart1 {
                let n = countAdjacentOccupied(pos: seat)
                if n == 0 || (n < 4 && occupied.contains(seat)) {
                    nextOccupied.insert(seat)
                }
            } else {
                let n = countVisibleOccupied(pos: seat)
                if n == 0 || (n < 5 && occupied.contains(seat)) {
                    nextOccupied.insert(seat)
                }                
            }                
        }

        if occupied == nextOccupied {
            return true
        }

        occupied = nextOccupied
        return false
    }    
}

var waitingArea1 = WaitingArea(desc: inputGet(), part1: true)
var waitingArea2 = WaitingArea(desc: inputGet(), part1: false)

bench {
    while !waitingArea1.nextGeneration() {
    }
    print("🌟 Part 1 : \(waitingArea1.occupied.count)")

    while !waitingArea2.nextGeneration() {
    }
    print("🌟 Part 2 : \(waitingArea2.occupied.count)")
}

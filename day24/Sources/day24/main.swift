import AocUtils

enum Direction: CaseIterable {
    case east, northeast, northwest, west, southwest, southeast
}

struct AxialPos: Hashable {
    var p: Int = 0
    var q: Int = 0
    
    func move(_ dir: Direction) -> AxialPos {
        switch dir {
        case .east:      return AxialPos(p: p - 1, q: q)
        case .northeast: return AxialPos(p: p, q: q - 1)
        case .northwest: return AxialPos(p: p + 1, q: q - 1)
        case .west:      return AxialPos(p: p + 1, q: q)
        case .southwest: return AxialPos(p: p, q: q + 1)
        case .southeast: return AxialPos(p: p - 1, q: q + 1)
        }
    }
    
    func follow(_ directions: [Direction]) -> AxialPos {
        return directions.reduce(self, { $0.move($1) })
    }
    
    func adjacent() -> [AxialPos] {
        return Direction.allCases.map(move)
    }
}

func countAdjacent(to: AxialPos, floor: Set<AxialPos>) -> Int {
    return to.adjacent().reduce(0, { $0 + (floor.contains($1) ? 1 : 0) })
}

func directionsMake(desc: String) -> [Direction] {
    var north: Bool?
    var directions = Array<Direction>()
    for ch in desc {
        switch ch {
        case "n":
            north = true
        case "s":
            north = false
        case "e":
            if let n = north {
                directions.append(n ? .northeast : .southeast)
                north = nil
            } else {
                directions.append(.east)
            }
        case "w":
            if let n = north {
                directions.append(n ? .northwest : .southwest)
                north = nil
            } else {
                directions.append(.west)
            }
        default:
            assertionFailure("\(ch) is an invalid direction character")
        }
    }
    return directions
}

let tiles = inputGet().map{ directionsMake(desc: $0) }
var flippedTiles = Dictionary<AxialPos, Bool>()

bench {
    for directions in tiles {
        let pos = AxialPos().follow(directions)
        flippedTiles[pos] = !(flippedTiles[pos] ?? false)
    }
    let numBlackTiles = flippedTiles.values.reduce(0, { $0 + ($1 ? 1 : 0) })
    print("🌟 Part 1 :", numBlackTiles)
}

bench {
    var blackTiles = Set<AxialPos>()
    for (pos, isBlack) in flippedTiles {
        if isBlack {
            blackTiles.insert(pos)
        }
    }
    for _ in 1...100 {
        var nextBlackTiles = Set<AxialPos>()
        for blackTile in blackTiles {
            let numAdjBlack = countAdjacent(to: blackTile, floor: blackTiles)
            if numAdjBlack != 0 && numAdjBlack <= 2 {
                // Does NOT match first rule, still black
                nextBlackTiles.insert(blackTile)
            }
            for adjWhiteTile in blackTile.adjacent().filter({ !blackTiles.contains($0) }) {
                if countAdjacent(to: adjWhiteTile, floor: blackTiles) == 2 {
                    // Match second rule
                    nextBlackTiles.insert(adjWhiteTile)
                }
            }
        }
        blackTiles = nextBlackTiles
    }
    print("🌟 Part 2 :", blackTiles.count)
}

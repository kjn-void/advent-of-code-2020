import AocUtils

enum Tile {
    case clear
    case tree
}

struct Map {
    let map: [[Tile]]
    let width: Int
    let height: Int

    init(description: [String]) {
        map = description.map { $0.map { $0 == "#" ? Tile.tree : Tile.clear } }
        width = map[0].count
        height = map.count
    }

    func tileGet(_ x: Int, _ y: Int) -> Tile {
        return map[y][x]
    }

    func treesCount(right: Int, down: Int) -> Int {
        var x = 0
        var y = 0
        var trees = 0
        while y < height {
            if tileGet(x, y) == .tree {
                trees += 1
            }
            x += right
            if x >= width {
                x -= width
            }
            y += down
        }
        return trees
    }
}

let map = Map(description: inputGet())
let part1 = map.treesCount(right: 3, down: 1)
print("🌟 Part 1 : \(part1)")

let slopes = [(1,1), (3,1), (5,1), (7,1), (1,2)]
let part2 = slopes.map { map.treesCount(right: $0.0, down: $0.1) }.reduce(1, *)
print("🌟 Part 2 : \(part2)")

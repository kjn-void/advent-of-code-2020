import AocUtils

let TILE_DOTS = 10
let TILE_IMAGE_DOTS = (TILE_DOTS - 2)
let TILE_ID_NONE = -1

let EDGE_LEFT = 0
let EDGE_TOP = 1
let EDGE_RIGHT = 2
let EDGE_BOTTOM = 3
let EDGE_RLEFT = 4
let EDGE_RTOP = 5
let EDGE_RRIGHT = 6
let EDGE_RBOTTOM = 7

typealias TileId = Int

extension Array where Element == TileId {
    func anySatisfy(_ pred: (Element) -> Bool) -> Bool {
        return !self.allSatisfy{ !pred($0) }
    }
}

extension Array where Element == (TileId, TileId) {
    func anySatisfy(_ pred: (Element) -> Bool) -> Bool {
        return !self.allSatisfy{ !pred($0) }
    }
}

enum TileClass {
    case corner, frame, inside
}

class Tile {
    var id: TileId
    var image: UInt64 = 0
    var edges: Array<Int>
    var neighbors = Array<TileId>(repeating: TILE_ID_NONE, count: 4)
    
    init(desc: [String]) {
        id = Int(desc.first!.groups(re: "Tile (\\d+):")[1])!
        var left = 0
        var top = 0
        var right = 0
        var bottom = 0
        for (y, line) in desc[1...].enumerated() {
            for (x, dot) in line.enumerated() {
                let bit = (dot == "#" ? 1 : 0)
                var isFrame = false
                
                if x == 0 {
                    left = (left << 1) + bit
                    isFrame = true
                } else if x == (TILE_DOTS - 1) {
                    right = (right << 1) + bit
                    isFrame = true
                }
                
                if y == 0 {
                    top = (top << 1) + bit
                    isFrame = true
                } else if y == (TILE_DOTS - 1) {
                    bottom = (bottom << 1) + bit
                    isFrame = true
                }
                
                if !isFrame {
                    image |= UInt64(bit) << imageBitGet(x: x - 1, y: y - 1)
                }
            }
        }
        edges = [left, top, right, bottom,
                 bitReverse(left), bitReverse(top),
		 bitReverse(right), bitReverse(bottom) ]
    }
    
    func classGet() -> TileClass {
        if [(0, 1), (1, 2), (2, 3), (3, 0)]
            .anySatisfy({ neighbors[$0.0] == TILE_ID_NONE && neighbors[$0.1] == TILE_ID_NONE }) {
            return .corner
        }
        if neighbors.anySatisfy({ $0 == TILE_ID_NONE }) {
            return .frame
        }
        return .inside
    }

    // Find tiles where an edge matches one of the four edges on the "self" tile
    func fit(tile: inout Tile) {
        for (edgeId, neighId) in neighbors.enumerated() {
            if neighId == TILE_ID_NONE {
                let edge = edges[edgeId]
                let match = (EDGE_LEFT...EDGE_RBOTTOM)
                    .enumerated()
                    .filter{ (edge ^ tile.edges[$0.1]) == 0 }
                if let m = match.first {
                    neighbors[edgeId] = tile.id
                    tile.neighbors[m.element < EDGE_RLEFT ? m.element : m.element - EDGE_RLEFT] = id
                    return
                }
            }
        }
    }
    
    // Starting from top-left corner, each tile can be arranged so that top and left
    // neighbor match
    func orientate(_ leftId: TileId, _ topId: TileId) {
        let rot = (0...3).first{ leftId == neighbors[$0] }!
        neighbors = neighbors.enumerated().map{ neighbors[($0.0 + rot) % 4] }
        imageRotate(rot)
        if neighbors[EDGE_TOP] != topId {
            (neighbors[EDGE_TOP], neighbors[EDGE_BOTTOM]) = (neighbors[EDGE_BOTTOM], neighbors[EDGE_TOP])
            imageHorizontalFlip()
        }
    }

    func imageHorizontalFlip() {
    	 imageRotate(-1)
    }

    // Rotate image 0, 90, 180 or 270 degrees, or do a horizonal flip
    func imageRotate(_ steps: Int) {
        var newImage: UInt64 = 0
        for y in 0..<TILE_IMAGE_DOTS {
            for x in 0..<TILE_IMAGE_DOTS {
                let bitVal = ((1 << imageBitGet(x: x, y: y)) & image) == 0 ? 0 : 1
		var bitPos: Int
                switch steps {
                case 0: // 0 degrees
                    bitPos = imageBitGet(x: x, y: y)
                case 1: // 90 degrees
                    bitPos = imageBitGet(x: y, y: TILE_IMAGE_DOTS - x - 1)
                case 2: // 180 degrees
                    bitPos = imageBitGet(x: TILE_IMAGE_DOTS - x - 1, y: TILE_IMAGE_DOTS - y - 1)
                case 3: // 270 degrees
                    bitPos = imageBitGet(x: TILE_IMAGE_DOTS - y - 1, y: x)
                default: // horizontal flip
                    bitPos = imageBitGet(x: x, y: TILE_IMAGE_DOTS - y - 1)
                }
		newImage |= UInt64(bitVal) << bitPos
            }
        }
        image = newImage
    }
}
    
func imageBitGet(x: Int, y: Int) -> Int {
    let xOffset = x
    let yOffset = y * TILE_IMAGE_DOTS
    return xOffset + yOffset
}

func bitReverse(_ bits: Int) -> Int {
    var rval = 0
    var val = bits
    for _ in 1...TILE_DOTS {
        rval = (rval << 1) + ((val & 1) == 1 ? 1 : 0)
        val >>= 1
    }
    return rval
}

func splitIntoTiles(_ input: [String]) -> [[String]] {
    var tiles = Array<[String]>()
    var tile = Array<String>()
    for line in input {
        if line.isEmpty {
            tiles.append(tile)
            tile.removeAll()
        } else {
            tile.append(line)
        }
    }
    return tiles
}

struct Pos2D: Hashable {
    var x: Int
    var y: Int

    static func +(a: Pos2D, b: Pos2D) -> Pos2D {
        return Pos2D(x: a.x + b.x, y: a.y + b.y)
    }
}

func seaMonstersGet() -> [[Pos2D]] {
    let desc = ["                  # ",
                "#    ##    ##    ###",
                " #  #  #  #  #  #   "]
    let xMax = desc[0].count - 1
    let yMax = desc.count - 1
    var images = Array<Array<Pos2D>>()
    var image = Array<Pos2D>()
    for (dy, line) in desc.enumerated() {
        for (dx, dot) in line.enumerated() {
            if dot == "#" {
                image.append(Pos2D(x: dx, y: dy))
            }
        }
    }
    // Horizontal combinations
    images.append(image)
    images.append(image.map{ Pos2D(x: xMax - $0.x, y: $0.y) })
    images.append(image.map{ Pos2D(x: $0.x, y: yMax - $0.y) })
    images.append(image.map{ Pos2D(x: xMax - $0.x, y: yMax - $0.y) })
    // Vertical combinations
    images.append(image.map{ Pos2D(x: $0.y, y: $0.x) })
    images.append(image.map{ Pos2D(x: yMax - $0.y, y: $0.x) })
    images.append(image.map{ Pos2D(x: $0.y, y: xMax - $0.x) })
    images.append(image.map{ Pos2D(x: yMax - $0.y, y: xMax - $0.x) })
    return images
}

// Select one corner piece as top-left, rotate/flip the rest acording to that
func arrangeTiles(_ topLeft: Tile, _ tiles: Dictionary<TileId, Tile>) {
    var tile = tiles[topLeft.id]!
    var leftId = TILE_ID_NONE
    var topId = TILE_ID_NONE
    var x = 0
    var y = 0
    var width = tiles.count
    done: while true {
        let leftCol = tile
        let sentinel: TileClass = (y == 0 || y == (tiles.count / width - 1) ? .corner : .frame)
        while true {
            tile.orientate(leftId, topId)
            if x != 0 && tile.classGet() == sentinel {
                if y != 0 && tile.classGet() == .corner {
                    break done
                }
                width = x + 1
                break
            }
            if topId != TILE_ID_NONE {
                let topTile = tiles[topId]!
                topId = tiles[topTile.neighbors[EDGE_RIGHT]]!.id
            }
            leftId = tile.id
            x += 1
            tile = tiles[tile.neighbors[EDGE_RIGHT]]!
        }
        x = 0
        y += 1
        leftId = TILE_ID_NONE
        topId = leftCol.id
        tile = tiles[leftCol.neighbors[EDGE_BOTTOM]]!
    }
}

// Generate a set of positions in the puzzle holding dot with "#"
func render(_ topLeft: Tile, _ tiles: Dictionary<TileId, Tile>) -> Set<Pos2D> {
    var puzzleImage = Set<Pos2D>()
    var tilePos = Pos2D(x: 0, y: 0)
    var tile = tiles[topLeft.id]!
    while true {
        let leftCol = tile
        while true {
            for y in 0..<TILE_IMAGE_DOTS {
                for x in 0..<TILE_IMAGE_DOTS {
                    if tile.image & (1 << imageBitGet(x: x, y: y)) != 0 {
                        puzzleImage.insert(Pos2D(x: tilePos.x * TILE_IMAGE_DOTS + x,
                                                 y: tilePos.y * TILE_IMAGE_DOTS + y))
                    }
                }
            }
            if tile.neighbors[EDGE_RIGHT] == TILE_ID_NONE {
                break
            }
            tilePos.x += 1
            tile = tiles[tile.neighbors[EDGE_RIGHT]]!
         }
        if leftCol.neighbors[EDGE_BOTTOM] == TILE_ID_NONE {
            break
        }
        tilePos.x = 0
        tilePos.y += 1
        tile = tiles[leftCol.neighbors[EDGE_BOTTOM]]!
    }
    return puzzleImage
}

var tiles = splitIntoTiles(inputGet(keepEmpty: true)).map(Tile.init)

bench {
    // Find matching left, top, right and bottom tile for each tile
    for i in 0..<tiles.count {
        let tile = tiles[i]
        for j in (i+1)..<tiles.count {
            tile.fit(tile: &tiles[j])
        }
    }
    let corners = tiles.filter{ $0.classGet() == .corner }
    let cornerProd = corners.reduce(Int64(1), { $0 * Int64($1.id) })
    print("🌟 Part 1 : \(cornerProd)")
}

bench {
    var tileMap = Dictionary<TileId, Tile>()
    for tile in tiles {
        tileMap[tile.id] = tile
    }
    let topLeft = tiles.first{ $0.classGet() == .corner  }!
    arrangeTiles(topLeft, tileMap)

    var image = render(topLeft, tileMap)
    let width = image.max(by: { $0.x < $1.x })!.x
    let height = image.max(by: { $0.y < $1.y })!.y

    //draw(image, width, height)

    // Remove matching dots from image for each found sea-monster
    for seaMonster in seaMonstersGet() {
    	for y in 0..<height {
            for x in 0..<width {
                if seaMonster.allSatisfy({ image.contains(Pos2D(x: $0.x + x, y: $0.y + y)) }) {
                    image.subtract(seaMonster.map{ Pos2D(x: $0.x + x, y: $0.y + y) })
                }
            }
        }
    }
    
    print("🌟 Part 2 : \(image.count)")
}

// Debug, draw puzzle
func draw(_ image: Set<Pos2D>, _ width: Int, _ height: Int) {
    for y in 0..<height {
        for x in 0..<width {
            if image.contains(Pos2D(x: x, y: y)) {
                print("#", terminator: "")
            } else {
                print(".", terminator: "")
            }
            if x % TILE_IMAGE_DOTS == (TILE_IMAGE_DOTS - 1) {
                print(" ", terminator: "")
            }
        }
        print()
        if y % TILE_IMAGE_DOTS == (TILE_IMAGE_DOTS - 1) {
            print()
        }
    }
}

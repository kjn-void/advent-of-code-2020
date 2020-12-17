import AocUtils

struct Pos4D : Hashable {
    var x: Int
    var y: Int
    var z: Int
    var w: Int
    var neighbors: [Pos4D] {
        get {
            var neigh = Array<Pos4D>()
            for dw in -1...1 {
                for dz in -1...1 {
                    for dy in -1...1 {
                        for dx in -1...1 {
                            if dx != 0 || dy != 0 || dz != 0 || dw != 0 {
                                neigh.append(Pos4D(x: x + dx, y: y + dy, z: z + dz, w: w + dw))
                            }
                        }
                    }
                }
            }
            return neigh
        }
    }
}

struct World {
    var activeCubes = Set<Pos4D>()
    var xLim: (Int, Int)
    var yLim: (Int, Int)
    var zLim = (0, 0)
    var wLim = (0, 0)
    var haveFourDim: Bool

    init(initialState: [String], useForthDim: Bool = false) {
        xLim = (0, initialState.first!.count)
        yLim = (0, initialState.count)
        haveFourDim = useForthDim
        for (y, line) in initialState.enumerated() {
            for (x, repr) in line.enumerated() {
                if repr == "#" {
                    activeCubes.insert(Pos4D(x: x, y: y, z: 0, w: 0))
                }
            }
        }
    }
    
    func neighborCount(_ center: Pos4D) -> Int {
        return center.neighbors.reduce(0, { $0 + (activeCubes.contains($1) ? 1 : 0) })
    }
    
    func boundaryExtend(_ bound: (Int, Int)) -> (Int, Int) {
        return (bound.0 - 1, bound.1 + 1)
    }
    
    mutating func nextCycle() {
        var nextActiveCubes = Set<Pos4D>()
        
        xLim = boundaryExtend(xLim)
        yLim = boundaryExtend(yLim)
        zLim = boundaryExtend(zLim)
        if haveFourDim {
            wLim = boundaryExtend(wLim)
        }

        for w in wLim.0...wLim.1 {
            for z in zLim.0...zLim.1 {
                for y in yLim.0..<yLim.1 {
                    for x in xLim.0..<xLim.1 {
                        let pos = Pos4D(x: x, y: y, z: z, w: w)
                        let neighCnt = neighborCount(pos)
                        if neighCnt == 3 || (neighCnt == 2 && activeCubes.contains(pos)) {
                            nextActiveCubes.insert(pos)
                        }
                    }
                }
            }
        }
        
        activeCubes = nextActiveCubes
    }
}

let input = inputGet()

bench {
    var world = World(initialState: input)
    for _ in 1...6 {
        world.nextCycle()
    }
    print("🌟 Part 1 : \(world.activeCubes.count)")
}

bench {
    var world = World(initialState: input, useForthDim: true)
    for _ in 1...6 {
        world.nextCycle()
    }
    print("🌟 Part 2 : \(world.activeCubes.count)")
}

import AocUtils

enum Instruction {
    case north(Int), south(Int), east(Int), west(Int),
         left(Int), right(Int), forward(Int)
}

struct Vec2D {
    var x: Int = 0
    var y: Int = 0

    func manhattanDistance(rhs: Vec2D = Vec2D()) -> Int {
        return abs(x - rhs.x) + abs(y - rhs.y)
    }

    mutating func rotate(steps: Int, clockwise: Bool) {
        let s = (clockwise ? steps : 4 - steps)
        switch s {
        case 1:  (x, y) = (-y,  x)
        case 2:  (x, y) = (-x, -y)
        default: (x, y) = ( y, -x)
        }
    }
}

extension Vec2D {
    static func +=(lhs: inout Vec2D, rhs: Vec2D) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    static func *(n: Int, dir: Vec2D) -> Vec2D {
        return Vec2D(x: n * dir.x, y: n * dir.y)
    }
}

struct Ship {
    var pos: Vec2D = Vec2D()
    var heading: Vec2D = Vec2D(x: -1, y: 0)
    var waypoint: Vec2D = Vec2D(x: -10, y: 1)

    mutating func apply1(_ instr: Instruction) {
        switch instr {
        case let .north(n):   pos.y += n
        case let .south(n):   pos.y -= n
        case let .east(n):    pos.x -= n
        case let .west(n):    pos.x += n
        case let .left(n):    heading.rotate(steps: n / 90, clockwise: false)
        case let .right(n):   heading.rotate(steps: n / 90, clockwise: true)
        case let .forward(n): pos += n * heading
        }
    }

    mutating func apply2(_ instr: Instruction) {
        switch instr {
        case let .north(n):   waypoint.y += n
        case let .south(n):   waypoint.y -= n
        case let .east(n):    waypoint.x -= n
        case let .west(n):    waypoint.x += n
        case let .left(n):    waypoint.rotate(steps: n / 90, clockwise: false)
        case let .right(n):   waypoint.rotate(steps: n / 90, clockwise: true)
        case let .forward(n): pos += n * waypoint
        }
    }
}

func toInstr(desc: String) -> Instruction {
    let n = Int(desc.dropFirst(1))!
    switch desc.prefix(1) {
    case "N": return .north(n)
    case "S": return .south(n)
    case "E": return .east(n)
    case "W": return .west(n)
    case "L": return .left(n)
    case "R": return .right(n)
    default:  return .forward(n)
    }
}

let instructions = inputGet().map({ toInstr(desc: $0) })

bench {
    var ship = Ship()
    for instr in  instructions {
        ship.apply1(instr)
    }
    print("🌟 Part 1 : \(ship.pos.manhattanDistance())")
}

bench {
    var ship = Ship()
    for instr in instructions {
        ship.apply2(instr)
    }
    print("🌟 Part 2 : \(ship.pos.manhattanDistance())")
}

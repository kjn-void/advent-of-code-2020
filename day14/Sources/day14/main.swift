import AocUtils
import Foundation

enum Instruction {
    case mem(Int64, Int64), mask(Int64, Int64)
    
    init(desc: String) {
        let parts = desc.components(separatedBy: " = ")
        let op = parts[0]
        let arg = parts[1]
        if op == "mask" {
            var clr = Int64(0)
            var set = Int64(0)
            for (idx, val) in arg.reversed().enumerated() {
                switch val {
                case "0": clr |= (1 << idx)
                case "1": set |= (1 << idx)
                default:  break
                }
            }
            self = .mask(clr, set)
        } else {
            let s = Scanner(string: op)
            let _ = s.scanUpToCharacters(from: .decimalDigits)
            self = .mem(s.scanInt64()!, Int64(arg)!)
        }
    }
}

struct Machine {
    var ram = Dictionary<Int64, Int64>()
    var clrMask: Int64 = 0
    var setMask: Int64 = 0
    var floatingBits: [Int64] {
        let fbMask = ~(clrMask | setMask)
        return (0..<36).compactMap{fbMask & (1 << $0) == 0 ? nil : $0}
    }

    func addrsGet(_ baseAddr: Int64) -> [Int64] {
        let fb = floatingBits
        var addrs = Array<Int64>()
        for i in 0..<(1 << fb.count) {
            var addr = baseAddr
            for (idx, bit) in fb.enumerated() {
                if ((1 << idx) & i) == 0 {
                    addr &= ~(1 << bit)
                } else {
                    addr |= (1 << bit)
                }
            }
            addrs.append(addr)
        }
        return addrs
    }

    mutating func exec1(_ instr: Instruction) {
        switch instr {
        case let .mask(clr, set):
            setMask = set
            clrMask = clr
        case let .mem(addr, val):
            ram[addr] = (val | setMask) & ~clrMask
        }
    }

    mutating func exec2(_ instr: Instruction) {
        switch instr {
        case let .mask(clr, set):
            setMask = set
            clrMask = clr
        case let .mem(addr, val):
            addrsGet(addr | setMask).forEach{ ram[$0] = val }
        }
    }
}

let instructions = inputGet().map(Instruction.init)

bench {
    var machine = Machine()
    for instr in instructions {
        machine.exec1(instr)
    }
    let sum = machine.ram.values.reduce(0, +)
    print("🌟 Part 1 : \(sum)")
}

bench {
    var machine = Machine()
    for instr in instructions {
        machine.exec2(instr)
    }
    let sum = machine.ram.values.reduce(0, +)
    print("🌟 Part 2 : \(sum)")
}


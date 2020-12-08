import AocUtils

enum Opcode: String {
    case acc, jmp, nop
}

struct Instruction {
    var op: Opcode
    var arg: Int

    init(desc: String) {
        let parts = desc.components(separatedBy: " ")
        op = Opcode(rawValue: parts[0])!
        arg = Int(parts[1])!
    }
}

struct Machine {
    var pc: Int = 0
    var a: Int = 0
    var ram: [Instruction]
    var executed: Set<Int> = Set<Int>()

    var pcVisited: Bool {
        get {
            return executed.contains(pc)
        }
    }

    mutating func step() -> Bool {
        executed.insert(pc)
        let instr = ram[pc]
        switch instr.op {
        case .acc:
            a += instr.arg
            pc += 1
        case .jmp:
            pc += instr.arg
        case .nop:
            pc += 1
        }
        return pc == ram.count
    }

    mutating func instructionSwap(from: Int, what: Dictionary<Opcode, Opcode>) -> Int {
        let instr = ram[from]
        if let newOp = what[instr.op] {
            ram[from].op = newOp
            return from
        }
        return instructionSwap(from: from + 1, what: what)
    }
}

bench {
    let ram = inputGet().map{ Instruction(desc: $0) }

    var machine = Machine(ram: ram)
    while !machine.pcVisited {
        let _ = machine.step()
    }
    print("🌟 Part 1 : \(machine.a)")

    var scanFromPc = 0
    let instrCandidates: Dictionary<Opcode, Opcode> = [.jmp: .nop, .nop: .jmp]
    done: while true {
        var machine = Machine(ram: ram)
        scanFromPc = machine.instructionSwap(from: scanFromPc, what: instrCandidates) + 1
        while !machine.pcVisited {
            if machine.step() {
                print("🌟 Part 2 : \(machine.a)")
                break done
            }
        }
    }
}

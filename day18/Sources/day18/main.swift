import AocUtils

enum Token: Equatable {
    case number(Int64), add, mul, openParen, closeParen
}

func shuntingYard(expr: String, addHigherPrec: Bool = false) -> [Token] {
    let exprSepParen = expr
        .replacingOccurrences(of: "(", with: "( ")
        .replacingOccurrences(of: ")", with: " )")
    var operators = Array<Token>()
    var reversePolishNotation = Array<Token>()
    
    for token in exprSepParen.components(separatedBy: " ") {
        if let n = Int64(token) {
            reversePolishNotation.append(.number(n))
        } else if token == "(" {
            operators.append(.openParen)
        } else if token == ")" {
            while true {
                let op = operators.removeLast()
                if op == .openParen {
                    break
                }
                reversePolishNotation.append(op)
            }
        } else {
            let newOp: Token = (token == "+" ? .add : .mul)
            
            while let op = operators.last {
                if op == .openParen || (addHigherPrec && newOp == .add && op == .mul) {
                    break
                }
                reversePolishNotation.append(operators.removeLast())
            }
            operators.append(newOp)
        }
    }
    
    reversePolishNotation += operators.reversed()
    return reversePolishNotation
}

func eval(_ rpn: [Token]) -> Int64 {
    var stack = Array<Int64>()
    
    for token in rpn {
        switch token {
        case let .number(n):
            stack.append(n)
        case .add:
            stack.append(stack.removeLast() + stack.removeLast())
        default:
            stack.append(stack.removeLast() * stack.removeLast())
        }
    }
    return stack.removeLast()
}

let input = inputGet()

bench {
    let sum = input
        .map{ shuntingYard(expr: $0) }
        .map{ eval($0) }
        .reduce(0, +)
    print("🌟 Part 1 : \(sum)")
}

bench {
    let sum = input
        .map{ shuntingYard(expr: $0, addHigherPrec: true) }
        .map{ eval($0) }
        .reduce(0, +)
    print("🌟 Part 2 : \(sum)")
}

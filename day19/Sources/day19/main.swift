import AocUtils

typealias RuleId = Int

enum Rule {
    case letter(Character), sequence(Array<RuleId>), choice(Array<Rule>)
    
    init(desc: String) {
        if desc.first! == "\"" {
            self = .letter(desc.charAt(index: 1))
        } else {
            let parts = desc.components(separatedBy: " | ")
            if parts.count == 1 {
                self = .sequence(desc.components(separatedBy: " ").map{ RuleId($0)! })
            } else {
                self = .choice(parts.map(Rule.init))
            }
        }
    }
    
    func apply(_ msg: Substring, _ rules: [Rule]) -> [Substring]? {
        if !msg.isEmpty {
            switch self {
            case let .letter(ch):
                if ch == msg.first! {
                    return [msg[msg.index(msg.startIndex, offsetBy: 1)...]]
                }
            case let .sequence(rIds):
                var rems: [Substring] = [msg]
                for ruleId in rIds {
                    let rule = rules[ruleId]
                    rems = rems
                        .compactMap{ rule.apply($0, rules) }
                        .flatMap{ $0 }
                    if rems.isEmpty {
                        break
                    }
                }
                return rems.isEmpty ? nil : rems
            case let .choice(ruleChoices):
                let rems = ruleChoices
                    .compactMap{ $0.apply(msg, rules) }
                    .flatMap{ $0 }
                return rems.isEmpty ? nil : rems
            }
        }
        return nil
    }
    
    func match(message: String, rules: [Rule]) -> Bool {
        if let rems = apply(message[...], rules) {
            // anySatisfy() does not exist
            return !rems.allSatisfy{ $0.count > 0 }
        }
        return false
    }
}

func rulesParse(_ input: [String]) -> ([Rule], Int)? {
    var rules = Dictionary<RuleId, Rule>()
    for (idx, line) in input.enumerated() {
        if line.isEmpty {
            let maxId = rules.keys.max()!
            var rs = Array<Rule>(repeating: .letter(" "), count: maxId + 1)
            for (k, v) in rules {
                rs[k] = v
            }
            return (rs, idx + 1)
        }
        let parts = line.components(separatedBy: ": ")
        rules[RuleId(parts[0])!] = Rule(desc: parts[1])
    }
    return nil
}

let input = inputGet(keepEmpty: true)
let (rules, msgIdx) = rulesParse(input)!
let messages = input[msgIdx...]

bench {
    let cnt = messages
        .filter{ rules[0].match(message: $0, rules: rules) }
        .count
    print("🌟 Part 1 : \(cnt)")
}

let rules2 = rules.enumerated().map{ (ruleId: Int, rule: Rule) -> Rule in
    if ruleId == 8 {
        return .choice([.sequence([42]), .sequence([42, 8])])
    } else if ruleId == 11 {
        return .choice([.sequence([42, 31]), .sequence([42, 11, 31])])
    } else {
        return rule
    }
}

bench {
    let cnt = messages
        .filter{ rules2[0].match(message: $0, rules: rules2) }
        .count
    print("🌟 Part 2 : \(cnt)")
}

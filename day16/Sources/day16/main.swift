import AocUtils

typealias Ticket = Array<Int>

struct Valid {
    var lo: ClosedRange<Int>
    var hi: ClosedRange<Int>
    init(desc: ArraySlice<String>) {
        lo = Int(desc[desc.startIndex + 0])!...Int(desc[desc.startIndex + 1])!
        hi = Int(desc[desc.startIndex + 2])!...Int(desc[desc.startIndex + 3])!
    }
    
    func inRange(_ val: Int) -> Bool {
        return lo.contains(val) || hi.contains(val)
    }
}

struct Rules {
    var fields = Dictionary<String, Valid>()

    init(desc: ArraySlice<String>) {
        for line in desc {
            let grps = line.groups(re: "(.+): (\\d+)-(\\d+) or (\\d+)-(\\d+)")
            fields[grps[1]] = Valid(desc: grps[2...])
        }
    }

    func isValid(_ field: Int) -> Bool {
        return !fields.values.allSatisfy{ !$0.inRange(field) }
    }

    func ticketErrors(_ ticket: Ticket) -> Int {
        return ticket.reduce(0, { $0 + (isValid($1) ? 0 : $1) })
    }

    func ticketScanningErrorRate(_ tickets: [Ticket]) -> Int {
        return tickets.reduce(0, { $0 + ticketErrors($1) })
    }
    
    func validFields(row: Int, _ tickets: [Ticket]) -> [String] {
        var vf = Array<String>(fields.keys)
        for ticket in tickets {
            vf = vf.filter({ fields[$0]!.inRange(ticket[row]) })
        }
        return vf
    }
    
    func fieldOrderGet(_ possibleFields: ArraySlice<(Int, [String])>,
                       _ order: [(Int, String)] = []) -> [(Int, String)]? {
        if possibleFields.isEmpty {
            return order
        }
        let row = possibleFields.first!.0
        for field in possibleFields.first!.1 {
            if order.firstIndex(where: { $0.1 == field }) == nil {
                if let ans = fieldOrderGet(possibleFields.dropFirst(1), order + [(row, field)]) {
                    return ans
                }
            }
        }
        return nil
    }
}

func ticketMake(desc: String) -> Ticket {
    return desc.components(separatedBy: ",").map{ Int($0)! }
}

func inputParse(input: [String]) -> (Rules, Ticket, [Ticket]) {
    var line = 0
    while input[line] != "your ticket:" {
        line += 1
    }
    let rules = Rules(desc: input[..<line])
    
    line += 1
    let myTicket = ticketMake(desc: input[line])
    
    line += 2
    var tickets = Array<Ticket>()
    for td in input[line...] {
        tickets.append(ticketMake(desc: td))
    }
    
    return (rules, myTicket, tickets)
}

let (rules, myTicket, tickets) = inputParse(input: inputGet())

bench {
    print("🌟 Part 1 : \(rules.ticketScanningErrorRate(tickets))")
}

bench {
    let validTickets = tickets.filter{ $0.allSatisfy({ rules.isValid($0) }) }
    let possibilties = (0..<rules.fields.count)
        .map{ ($0, rules.validFields(row: $0, validTickets)) }
        .sorted(by: { $0.1.count < $1.1.count })
    let fieldOrder = rules.fieldOrderGet(possibilties[...])!
    let depatureFields = fieldOrder.filter{ $1.hasPrefix("departure") }
    let answer = depatureFields.reduce(Int64(1), { $0 * Int64(myTicket[$1.0]) })
    print("🌟 Part 2 : \(answer)")
}

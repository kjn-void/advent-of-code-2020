import AocUtils

struct Bag {
    var color: String
    var contents: Dictionary<String, Int>

    func contains(color: String, _ bags: [Bag]) -> Bool {
        for content in self.contents {
            if content.key == color {
                return true
            }
            if bagGet(color: content.key, bags).contains(color: color, bags) {
                return true
            }
        }
        return false
    }

    func numBags(_ bags: [Bag]) -> Int {
        return contents.reduce(0, { $0 + $1.value + $1.value * bagGet(color: $1.key, bags).numBags(bags) })
    }
}

func bagGet(color: String, _ bags: [Bag]) -> Bag {
    return bags[bags.firstIndex(where: { $0.color == color })!]
}

func bagMake(desc: String) -> Bag {
    let parts = desc.components(separatedBy: " bags contain ")
    return Bag(color: parts[0],
               contents: Dictionary(uniqueKeysWithValues: parts[1]
                                      .allMatches(re: "(\\d)+ (\\w+ \\w+) bags?[,.]")
                                      .map{ ($0[2], Int($0[1])!) }))
}

bench {
    let bags = inputGet().map{ bagMake(desc: $0) }
    let containsShinyBag = bags.filter{ $0.contains(color: "shiny gold", bags) }
    print("🌟 Part 1 : \(containsShinyBag.count)")
    let bagsCnt = bagGet(color: "shiny gold", bags).numBags(bags)
    print("🌟 Part 2 : \(bagsCnt)")
}

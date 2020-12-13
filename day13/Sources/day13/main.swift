import AocUtils
import BigNumber

let input = inputGet()

bench {
    let earliestTs = Int(input[0])!
    let busses = input[1].components(separatedBy: ",").compactMap{ Int($0) }
    let idToDeparture = busses.map{ ($0, $0 - earliestTs % $0) }.min{$0.1<$1.1}!
    print("🌟 Part 1 : \(idToDeparture.0 * idToDeparture.1)")
}

func part2(_ tsOffsetsAndBusses: [(Int, Int)]) -> BInt {
    var ts = BInt(0)
    var step = BInt(1)
    for (tsOffset, busId) in tsOffsetsAndBusses {
        let id = BInt(busId)
        while (ts + tsOffset) % id != 0 {
            ts += step
        } 
        step *= id
    }
    return ts
}

bench {
    let tsOffsetsAndBusses = input[1]
        .components(separatedBy: ",")
        .enumerated()
        .map{ ($0.0, Int($0.1)) }
        .filter{ $0.1 != nil }
        .map{ ($0.0, $0.1!) }
    print("🌟 Part 2 : \(part2(tsOffsetsAndBusses))")
}

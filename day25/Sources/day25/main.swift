import AocUtils

let cardPubKey = UInt(inputGet()[0])!
let doorPubKey = UInt(inputGet()[1])!
let divisor: UInt = 20201227

func transform(_ subjectNumber: UInt, _ loopSize: UInt) -> UInt {
    return (0..<loopSize).reduce(1, { value, _ in (value * subjectNumber) % divisor })
}

func loopSizeCalc(pubKey: UInt) -> UInt {
    let subjectNumber: UInt = 7
    var loopSize: UInt = 0
    var value: UInt = 1
    while value != pubKey {
        loopSize += 1
        value = (value * subjectNumber) % divisor
    }
    return loopSize
}

bench {
    let cardLoopSize = loopSizeCalc(pubKey: cardPubKey)
    let secretKey = transform(doorPubKey, cardLoopSize)
    print("🌟 Part 1 :", secretKey)
}
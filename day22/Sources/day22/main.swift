import AocUtils

typealias Card = Int
typealias Deck = [Card]

func decksGet(_ input: [String]) -> [Deck] {
    var deck1: Deck?
    var deck = Deck()
    for line in input[1...] {
        if let card = Card(line) {
            deck.append(card)
        } else {
            deck1 = deck
            deck.removeAll()
        }
    }
    return [deck1!, deck]
}

func cardsDraw(_ decks: inout [Deck]) -> [Card] {
    return [decks[0].removeFirst(), decks[1].removeFirst()]
}

func scoreGet(_ decks: [Deck]) -> Int {
    return decks[decks[0].count > 0 ? 0 : 1]
        .reversed()
        .enumerated()
        .reduce(0, { $0 + ($1.0 + 1) * $1.1 })
}

func decksNext(_ player1Won: Bool, _ decks: [Deck], _ cards: [Card]) -> [Deck] {
    if player1Won {
        return [decks[0] + cards, decks[1]]
    }
    return [decks[0], decks[1] + cards.reversed()]
}

func recursiveCombat(_ initialDecks: [Deck]) -> (player1Won: Bool, score: Int) {
    var rounds = Set<[Deck]>()
    var decks = initialDecks
    
    while decks.allSatisfy({ !$0.isEmpty }) {
        if !rounds.insert(decks).inserted {
            // Avoid inifinite recursive games, player 1 wins game
            return (true, 0)
        }
        
        let cards = cardsDraw(&decks)
        let decksAndCards = zip(decks, cards)
        if decksAndCards.allSatisfy({ $0.count >= $1 }) {
            // Both players have at least as many cards remaining as value of drawn cards
            let subDecks = decksAndCards.map{ Array<Card>($0[..<$1]) }
            decks = decksNext(recursiveCombat(subDecks).player1Won, decks, cards)
        } else {
            // Winner is the one with the higher card
            decks = decksNext(cards[0] > cards[1], decks, cards)
        }
    }
    
    return (decks[1].isEmpty, scoreGet(decks))
}

let initialDecks = decksGet(inputGet())

bench {
    var decks = initialDecks
    while decks.allSatisfy({ !$0.isEmpty }) {
        let cards = cardsDraw(&decks)
        decks = decksNext(cards[0] > cards[1], decks, cards)
    }
    print("🌟 Part 1 : \(scoreGet(decks))")
}

bench {
    print("🌟 Part 2 : \(recursiveCombat(initialDecks).score)")
}

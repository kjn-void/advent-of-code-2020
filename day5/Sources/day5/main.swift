import AocUtils

let numRows = 128
let numColumns = 8

typealias Rows = Range<Int>
typealias Columns = Range<Int>

struct Seats {
    var rows: Rows = 0..<numRows
    var cols: Columns = 0..<numColumns
}

struct Seat {
    var row: Int
    var col: Int
}

func seatsPartition(seats: Seats, how: Character) -> Seats {
    switch how {
    case "F":
        return Seats(rows: seats.rows.prefix(seats.rows.count / 2), cols: seats.cols)
    case "B":
        return Seats(rows: seats.rows.suffix(seats.rows.count / 2), cols: seats.cols)
    case "L":
        return Seats(rows: seats.rows, cols: seats.cols.prefix(seats.cols.count / 2))
    default: // "R"
        return Seats(rows: seats.rows, cols: seats.cols.suffix(seats.cols.count / 2))
    }
}

func seatFind(boardingCard: String) -> Seat {
    let seat = boardingCard.reduce(Seats(), seatsPartition)
    return Seat(row: seat.rows.first!, col: seat.cols.first!)
}

func seatId(seat: Seat) -> Int {
    return seat.row * 8 + seat.col
}

let boardingCards = inputGet()
let takenSeats = boardingCards.map{ seatFind(boardingCard: $0) }
let seatIds = Set<Int>(takenSeats.map { seatId(seat: $0) })
print("🌟 Part 1 : \(seatIds.max()!)")

// Filter out non-taken possible seat and where seat -1 and +1 i taken
let mySeatId = (0..<(numRows*8)).filter { !seatIds.contains($0) && seatIds.contains($0 - 1) && seatIds.contains($0 + 1) }
print("🌟 Part 2 : \(mySeatId.first!)")

import AocUtils

struct PasswdRec {
    let password: String
    let requiredLetter: Character
    let range: (Int, Int)

    var followsPolicy1: Bool {
        get {
            let rlCnt = password.filter { $0 == requiredLetter }.count
            return range.0 <= rlCnt && range.1 >= rlCnt
        }
    }

    var followsPolicy2: Bool {
        get {
            let letters = (password.charAt(index: range.0 - 1),
                           password.charAt(index: range.1 - 1))
            return (requiredLetter == letters.0) != (requiredLetter == letters.1)
        }
    }

    init(description: String) {
        let parts = description.split(separator: " ")
        password = String(parts[2])
        requiredLetter = parts[1].first!
        let rng = String(parts[0]).split(separator: "-")
        range = (Int(rng[0])!, Int(rng[1])!)
    }
}

let passwords = inputGet().map { PasswdRec(description: $0) }
print("🌟 Part 1 : \(passwords.filter { $0.followsPolicy1 }.count)")
print("🌟 Part 2 : \(passwords.filter { $0.followsPolicy2 }.count)")

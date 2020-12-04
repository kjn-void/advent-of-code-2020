import AocUtils

enum EyeColor: String {
    case amb, blu, brn, gry, grn, hzl, oth
}

enum Field: String, CaseIterable {
    case byr, iyr, eyr, hgt, hcl, ecl, pid, cid
}

typealias Passport = Dictionary<Field, String>

func fieldMake(repr: String) -> (Field, String) {
    let kv = repr.split(separator: ":")
    return (Field(rawValue: String(kv.first!))!, String(kv.last!))
}

func passportMake(record: String) -> Passport {
    return Passport(uniqueKeysWithValues: record.split(separator: " ").map{ fieldMake(repr: String($0)) } )
}

func isValid1(passport: Passport) -> Bool {
    return passport.count == Field.allCases.count
      || (passport.count == Field.allCases.count - 1 && !passport.keys.contains(.cid))
}

func isValid2(passport: Passport) -> Bool {
    return isValid1(passport: passport)
      && isInRange(passport[.byr]!, min: 1920, max: 2002)
      && isInRange(passport[.iyr]!, min: 2010, max: 2020)
      && isInRange(passport[.eyr]!, min: 2020, max: 2030)
      && isHgtValid(passport[.hgt]!)
      && isHclValid(passport[.hcl]!)
      && isEclValid(passport[.ecl]!)
      && isPidValid(passport[.pid]!)
}

func isInRange(_ val: String, min: Int, max: Int) -> Bool {
    if let n = Int(val) {
        return n >= min && n <= max
    }
    return false
}

func isHgtValid(_ val: String) -> Bool {
    if let height = Int(val.dropLast(2)) {
        let suffix = String(val.suffix(2))
        return (suffix == "cm" && height >= 150 && height <= 193)
          || (suffix == "in" && height >= 59 && height <= 76)
    }
    return false
}

func isHclValid(_ val: String) -> Bool {
    let prefix = String(val.prefix(1))
    let hexnum = UInt64(val.dropFirst(1), radix: 16)
    return prefix == "#" && hexnum != nil
}

func isEclValid(_ val: String) -> Bool {
    return EyeColor(rawValue: val) != nil
}

func isPidValid(_ val: String) -> Bool {
    return val.count == 9 && UInt64(val) != nil
}

let passports = recordsGet().map{ passportMake(record: $0) }
let validCnt1 = passports.reduce(0, { $0 + (isValid1(passport: $1) ? 1 : 0) })
print("🌟 Part 1 : \(validCnt1)")
let validCnt2 = passports.reduce(0, { $0 + (isValid2(passport: $1) ? 1 : 0) })
print("🌟 Part 2 : \(validCnt2)")

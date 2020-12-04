import AocUtils

enum EyeColor: String {
    case amb, blu, brn, gry, grn, hzl, oth
}

enum Field: String, CaseIterable {
    case byr, iyr, eyr, hgt, hcl, ecl, pid, cid
}

typealias Passport = Dictionary<Field, String>

extension String {
    func isIntIn(range: ClosedRange<Int>) -> Bool {
        guard let n = Int(self) else {
            return false
        }
        return range.contains(n)
    }
}

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
      && passport[.byr]!.isIntIn(range: 1920...2002)
      && passport[.iyr]!.isIntIn(range: 2010...2020)
      && passport[.eyr]!.isIntIn(range: 2020...2030)
      && isHgtValid(passport[.hgt]!)
      && isHclValid(passport[.hcl]!)
      && isEclValid(passport[.ecl]!)
      && isPidValid(passport[.pid]!)
}

func isHgtValid(_ val: String) -> Bool {
    let grps = val.groups(re: "^(\\d+)(cm|in)$")
    return (grps.count == 3)
      && (grps[2] == "cm" && grps[1].isIntIn(range: 150...193)
            || grps[2] == "in" && grps[1].isIntIn(range: 59...76))
}

func isHclValid(_ val: String) -> Bool {
    return val.match(re: "^#[0-9a-f]{6}$")
}

func isEclValid(_ val: String) -> Bool {
    return EyeColor(rawValue: val) != nil
}

func isPidValid(_ val: String) -> Bool {
    return val.match(re: "^\\d{9}$")
}

let passports = recordsGet().map{ passportMake(record: $0) }
let validCnt1 = passports.reduce(0, { $0 + (isValid1(passport: $1) ? 1 : 0) })
print("🌟 Part 1 : \(validCnt1)")
let validCnt2 = passports.reduce(0, { $0 + (isValid2(passport: $1) ? 1 : 0) })
print("🌟 Part 2 : \(validCnt2)")

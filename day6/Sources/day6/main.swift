import AocUtils

typealias Form = Set<Character>

func groupFormsMake(groupDesc: String) -> [Form] {
    return groupDesc.components(separatedBy: " ").map{ Form($0) }
}

func groupAnySelection(forms: [Form]) -> Form {
    return forms.reduce(Form(), { $0.union($1) })
}

func groupAllSelection(forms: [Form]) -> Form {
    return forms.reduce(forms.first!, { $0.intersection($1) })
}

let groups = recordsGet().map{ groupFormsMake(groupDesc: $0) }
let sumAny = groups.map{ groupAnySelection(forms: $0).count }.reduce(0, +)
print("🌟 Part 1 : \(sumAny)")
let sumAll = groups.map{ groupAllSelection(forms: $0).count }.reduce(0, +)
print("🌟 Part 2 : \(sumAll)")

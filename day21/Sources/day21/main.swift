import AocUtils

typealias Ingredient = String
typealias Allergen = String

struct Food {
    var ingredients: Array<Ingredient>
    var allergens: Array<Allergen>
    
    init(desc: String) {
        let grps = desc.groups(re: "(.+) \\(contains (.+)\\)")
        ingredients = grps[1].components(separatedBy: " ")
        allergens = grps[2].components(separatedBy: ", ")
    }
}

extension Dictionary where Key == String, Value == Int {
    mutating func update(_ items: Array<Key>) {
        for item in items {
            if let cnt = self[item] {
                self[item] = cnt + 1
            } else {
                self[item] = 1
            }
        }
    }
}

let foods = inputGet().map(Food.init)
var allergenToIngredients = Dictionary<Allergen, Set<Ingredient>>()

bench {
    var ingredientsCount = Dictionary<Ingredient, Int>()
    // Intersection of ingredients listed with a specific allergen
    // Also count all ingredients
    for food in foods {
        ingredientsCount.update(food.ingredients)
        for allergen in food.allergens {
            if let ingredients = allergenToIngredients[allergen] {
                allergenToIngredients[allergen] = ingredients.intersection(food.ingredients)
            } else {
                allergenToIngredients[allergen] = Set<Ingredient>(food.ingredients)
            }
        }
    }
    // Remove all ingredients with non-zero allergen(s) associated with them
    for possibleAllergens in allergenToIngredients.values {
        possibleAllergens.forEach{ ingredientsCount.removeValue(forKey: $0) }
    }
    // Sum occurances of ingredients with zero allergen
    let cnt = ingredientsCount.reduce(0, { $0 + $1.value })
    print("🌟 Part 1 : \(cnt)")
}

bench {
    var ingredientToAllergen = Array<(Ingredient, Allergen)>()
    // Contintune until every ingredient got an unique allergen association
    while !allergenToIngredients.isEmpty {
        var unques = Array<(Ingredient, Allergen)>()
        // Extract all ingredients with exactly one allergen
        for (allergen, ingredients) in allergenToIngredients {
            if ingredients.count == 1 {
                unques.append((ingredients.first!, allergen))
            }
        }
        // Remove ingredients with unique allergen assoication from remaining
        // allergen-to-ingredients mapping
        for (ingredient, allergen) in unques {
            allergenToIngredients.removeValue(forKey: allergen)
            for (k, v) in allergenToIngredients {
                allergenToIngredients[k] = v.subtracting([ingredient])
            }
        }
        ingredientToAllergen += unques
    }
    ingredientToAllergen.sort(by: { $0.1 < $1.1 })
    let canonicalDangerousIngredients = ingredientToAllergen
        .map{$0.0}
        .joined(separator: ",")
    print("🌟 Part 2 : \(canonicalDangerousIngredients)")
}

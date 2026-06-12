import Foundation

struct CatDraft {
    var name: String = ""
    var birthday: Date = .now
    var weightText: String = ""
    var isNeutered: Bool = true
    var memo: String = ""
    var imageData: Data?

    init(cat: CatProfile? = nil) {
        guard let cat else { return }
        name = cat.name
        birthday = cat.birthday
        weightText = String(format: "%.1f", cat.weight)
        isNeutered = cat.isNeutered
        memo = cat.memo
    }
}

struct FoodDraft {
    var name: String = ""
    var calorieText: String = ""
    var calorieUnit: CalorieUnit = .per100g
    var memo: String = ""
    var imageData: Data?

    init(food: FoodItem? = nil) {
        guard let food else { return }
        name = food.name
        calorieText = food.calorieValue == floor(food.calorieValue) ? String(Int(food.calorieValue)) : String(format: "%.1f", food.calorieValue)
        calorieUnit = food.calorieUnit
        memo = food.memo
    }
}

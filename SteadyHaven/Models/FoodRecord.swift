import Foundation
import SwiftData

@Model
final class FoodRecord {
    var id: UUID
    var date: Date
    var mealType: String?
    var foodName: String
    var amount: Double
    var unit: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var sodium: Double
    var feeling: String?
    var note: String?

    var totalCalories: Double { calories * (amount / 100) }
    var totalProtein: Double { protein * (amount / 100) }
    var totalCarbs: Double { carbs * (amount / 100) }
    var totalFat: Double { fat * (amount / 100) }
    var totalSodium: Double { sodium * (amount / 100) }

    init(
        date: Date = Date(),
        mealType: String? = nil,
        foodName: String = "",
        amount: Double = 100,
        unit: String = "g",
        calories: Double = 0,
        protein: Double = 0,
        carbs: Double = 0,
        fat: Double = 0,
        sodium: Double = 0,
        feeling: String? = nil,
        note: String? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.mealType = mealType
        self.foodName = foodName
        self.amount = amount
        self.unit = unit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.sodium = sodium
        self.feeling = feeling
        self.note = note
    }
}

import Foundation
import SwiftData

@Model
final class FoodTemplate {
    var id: UUID
    var name: String
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    var sodiumPer100g: Double
    var createdAt: Date

    init(
        name: String = "",
        caloriesPer100g: Double = 0,
        proteinPer100g: Double = 0,
        carbsPer100g: Double = 0,
        fatPer100g: Double = 0,
        sodiumPer100g: Double = 0
    ) {
        self.id = UUID()
        self.name = name
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.carbsPer100g = carbsPer100g
        self.fatPer100g = fatPer100g
        self.sodiumPer100g = sodiumPer100g
        self.createdAt = Date()
    }
}

import SwiftUI

struct FoodRecordCard: View {
    let record: FoodRecord
    @State private var isExpanded = false
    @State private var showEatAgain = false

    private var feelingEmoji: String? {
        switch record.feeling {
        case "satisfied": return "😋"
        case "neutral": return "😐"
        case "stuffed": return "😣"
        default: return nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.foodName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        if let meal = record.mealType {
                            Text(meal)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let emoji = feelingEmoji {
                        Text(emoji)
                            .font(.title3)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(String(format: "%.0f", record.amount))\(record.unit)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.0f", record.totalCalories)) kcal")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                }
                .padding(16)
                .background(Color.blue.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        ExpandedNutrientItem(label: "蛋白质", value: record.totalProtein, unit: "g")
                        ExpandedNutrientItem(label: "碳水", value: record.totalCarbs, unit: "g")
                        ExpandedNutrientItem(label: "脂肪", value: record.totalFat, unit: "g")
                        ExpandedNutrientItem(label: "钠", value: record.totalSodium, unit: "mg")
                    }

                    if let note = record.note, !note.isEmpty {
                        HStack {
                            Image(systemName: "text.bubble")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }

                    Button {
                        showEatAgain = true
                    } label: {
                        Label("再吃一次", systemImage: "repeat")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(Color.blue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 8)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .sheet(isPresented: $showEatAgain) {
            AddFoodSheet(
                prefillName: record.foodName,
                prefillMealType: record.mealType,
                prefillCalories: record.calories,
                prefillProtein: record.protein,
                prefillCarbs: record.carbs,
                prefillFat: record.fat,
                prefillSodium: record.sodium,
                prefillAmount: record.amount,
                prefillUnit: record.unit,
                showTemplateButton: true
            )
        }
    }
}

private struct ExpandedNutrientItem: View {
    let label: String
    let value: Double
    let unit: String

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.1f", value))
                .font(.subheadline)
                .fontWeight(.medium)
            Text("\(label) \(unit)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

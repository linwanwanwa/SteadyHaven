import SwiftUI

struct NutritionSummaryCard: View {
    let records: [FoodRecord]

    private var totalCalories: Double {
        records.reduce(0) { $0 + $1.totalCalories }
    }

    private var totalProtein: Double {
        records.reduce(0) { $0 + $1.totalProtein }
    }

    private var totalCarbs: Double {
        records.reduce(0) { $0 + $1.totalCarbs }
    }

    private var totalFat: Double {
        records.reduce(0) { $0 + $1.totalFat }
    }

    private var totalSodium: Double {
        records.reduce(0) { $0 + $1.totalSodium }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(String(format: "%.0f", totalCalories))
                .font(.system(size: 48, weight: .bold, design: .default))
                .foregroundColor(.primary)
            Text("千卡")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                NutrientBadge(label: "蛋白质", value: totalProtein, unit: "g")
                NutrientBadge(label: "碳水", value: totalCarbs, unit: "g")
                NutrientBadge(label: "脂肪", value: totalFat, unit: "g")
                NutrientBadge(label: "钠", value: totalSodium, unit: "mg")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

private struct NutrientBadge: View {
    let label: String
    let value: Double
    let unit: String

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.1f", value))
                .font(.system(.headline, design: .default))
                .fontWeight(.semibold)
            Text("\(label)(\(unit))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

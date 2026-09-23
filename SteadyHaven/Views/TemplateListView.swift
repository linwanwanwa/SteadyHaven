import SwiftUI
import SwiftData

struct TemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodTemplate.createdAt, order: .reverse) private var allTemplates: [FoodTemplate]
    @State private var searchText = ""
    @State private var showAddSheet = false
    @State private var templateToEdit: FoodTemplate?
    @State private var templateToDelete: FoodTemplate?
    @State private var showDeleteConfirmation = false

    private var filteredTemplates: [FoodTemplate] {
        if searchText.isEmpty { return allTemplates }
        return allTemplates.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if allTemplates.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 40))
                            .foregroundColor(.blue.opacity(0.3))
                        Text("还没有食物模板")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("添加常用食物，记录时快速选用")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("搜索模板", text: $searchText)
                            .textFieldStyle(.plain)
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .padding(.top, 8)

                    List {
                        ForEach(filteredTemplates) { template in
                            Button {
                                templateToEdit = template
                                showAddSheet = true
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(template.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("每100g: \(String(format: "%.0f", template.caloriesPer100g)) kcal")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    templateToDelete = template
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("模板")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        templateToEdit = nil
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                TemplateEditSheet(template: templateToEdit)
            }
            .confirmationDialog("确认删除", isPresented: $showDeleteConfirmation, presenting: templateToDelete) { template in
                Button("删除", role: .destructive) {
                    modelContext.delete(template)
                }
                Button("取消", role: .cancel) {}
            } message: { template in
                Text("确定要删除模板「\(template.name)」吗？")
            }
        }
    }
}

// MARK: - Template Edit Sheet (add / edit)
private struct TemplateEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let template: FoodTemplate?

    @State private var name: String
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var sodium: String

    private var isEditing: Bool { template != nil }
    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    init(template: FoodTemplate?) {
        self.template = template
        _name = State(initialValue: template?.name ?? "")
        _calories = State(initialValue: template.map { String(format: "%.0f", $0.caloriesPer100g) } ?? "")
        _protein = State(initialValue: template.map { String(format: "%.1f", $0.proteinPer100g) } ?? "")
        _carbs = State(initialValue: template.map { String(format: "%.1f", $0.carbsPer100g) } ?? "")
        _fat = State(initialValue: template.map { String(format: "%.1f", $0.fatPer100g) } ?? "")
        _sodium = State(initialValue: template.map { String(format: "%.0f", $0.sodiumPer100g) } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("模板名称") {
                    TextField("例如：白米饭", text: $name)
                }
                Section("每100g(ml)含量") {
                    NutrientRow(label: "热量", text: $calories, unit: "千卡")
                    NutrientRow(label: "蛋白质", text: $protein, unit: "g")
                    NutrientRow(label: "碳水", text: $carbs, unit: "g")
                    NutrientRow(label: "脂肪", text: $fat, unit: "g")
                    NutrientRow(label: "钠", text: $sodium, unit: "mg")
                }
            }
            .navigationTitle(isEditing ? "编辑模板" : "新建模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        if let existing = template {
            existing.name = name.trimmingCharacters(in: .whitespaces)
            existing.caloriesPer100g = Double(calories) ?? 0
            existing.proteinPer100g = Double(protein) ?? 0
            existing.carbsPer100g = Double(carbs) ?? 0
            existing.fatPer100g = Double(fat) ?? 0
            existing.sodiumPer100g = Double(sodium) ?? 0
        } else {
            let newTemplate = FoodTemplate(
                name: name.trimmingCharacters(in: .whitespaces),
                caloriesPer100g: Double(calories) ?? 0,
                proteinPer100g: Double(protein) ?? 0,
                carbsPer100g: Double(carbs) ?? 0,
                fatPer100g: Double(fat) ?? 0,
                sodiumPer100g: Double(sodium) ?? 0
            )
            modelContext.insert(newTemplate)
        }
        dismiss()
    }
}

private struct NutrientRow: View {
    let label: String
    @Binding var text: String
    let unit: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text(unit)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)
        }
    }
}

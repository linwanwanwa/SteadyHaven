import SwiftUI
import SwiftData

struct AddFoodSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Prefill data (for "再吃一次" or template)
    var prefillName: String = ""
    var prefillMealType: String? = nil
    var prefillCalories: Double? = nil
    var prefillProtein: Double? = nil
    var prefillCarbs: Double? = nil
    var prefillFat: Double? = nil
    var prefillSodium: Double? = nil
    var prefillAmount: Double? = nil
    var prefillUnit: String = "g"
    var showTemplateButton: Bool = false

    @State private var foodName: String
    @State private var mealType: String? = nil
    @State private var caloriesPer100: String
    @State private var proteinPer100: String
    @State private var carbsPer100: String
    @State private var fatPer100: String
    @State private var sodiumPer100: String
    @State private var amount: String
    @State private var unit: String

    // Template picker
    @State private var showTemplatePicker = false
    // Scanner
    @State private var showScanner = false
    // Recipe mode
    @State private var isRecipeMode = false
    @State private var recipeTotalCalories = ""
    @State private var recipeTotalProtein = ""
    @State private var recipeTotalCarbs = ""
    @State private var recipeTotalFat = ""
    @State private var recipeTotalSodium = ""
    @State private var recipeTotalWeight = ""
    // Feeling & note
    @State private var showFeelingSection = false
    @State private var feeling: String? = nil
    @State private var note = ""
    // Save as template
    @State private var templateNameForSave = ""
    @State private var showTemplateNameInput = false
    @State private var showSaveSuccess = false

    private let mealTypes = ["早餐", "午餐", "晚餐", "加餐"]
    private let units = ["g", "ml"]

    private var baseUnitLabel: String {
        unit == "g" ? "每100g含量" : "每100ml含量"
    }

    private var amountValue: Double { Double(amount) ?? 0 }
    private var caloriesValue: Double { Double(caloriesPer100) ?? 0 }
    private var proteinValue: Double { Double(proteinPer100) ?? 0 }
    private var carbsValue: Double { Double(carbsPer100) ?? 0 }
    private var fatValue: Double { Double(fatPer100) ?? 0 }
    private var sodiumValue: Double { Double(sodiumPer100) ?? 0 }

    private var previewCalories: Double {
        caloriesValue * (amountValue / 100)
    }

    private var isFormValid: Bool {
        !foodName.trimmingCharacters(in: .whitespaces).isEmpty && amountValue > 0
    }

    private var hasNutritionFilled: Bool {
        caloriesValue > 0 || proteinValue > 0 || carbsValue > 0 || fatValue > 0
    }

    init(
        prefillName: String = "",
        prefillMealType: String? = nil,
        prefillCalories: Double? = nil,
        prefillProtein: Double? = nil,
        prefillCarbs: Double? = nil,
        prefillFat: Double? = nil,
        prefillSodium: Double? = nil,
        prefillAmount: Double? = nil,
        prefillUnit: String = "g",
        showTemplateButton: Bool = false
    ) {
        self.prefillName = prefillName
        self.prefillMealType = prefillMealType
        self.prefillCalories = prefillCalories
        self.prefillProtein = prefillProtein
        self.prefillCarbs = prefillCarbs
        self.prefillFat = prefillFat
        self.prefillSodium = prefillSodium
        self.prefillAmount = prefillAmount
        self.prefillUnit = prefillUnit
        self.showTemplateButton = showTemplateButton

        _foodName = State(initialValue: prefillName)
        _mealType = State(initialValue: prefillMealType)
        _caloriesPer100 = State(initialValue: prefillCalories.map { formatDouble($0) } ?? "")
        _proteinPer100 = State(initialValue: prefillProtein.map { formatDouble($0) } ?? "")
        _carbsPer100 = State(initialValue: prefillCarbs.map { formatDouble($0) } ?? "")
        _fatPer100 = State(initialValue: prefillFat.map { formatDouble($0) } ?? "")
        _sodiumPer100 = State(initialValue: prefillSodium.map { formatDouble($0) } ?? "")
        _amount = State(initialValue: prefillAmount.map { formatDouble($0) } ?? "")
        _unit = State(initialValue: prefillUnit)
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - 食物信息
                Section("食物信息") {
                    TextField("食物名称", text: $foodName)
                        .onChange(of: foodName) { _, newValue in
                            if showTemplateButton && !newValue.isEmpty && !templateNameForSave.isEmpty {
                                templateNameForSave = newValue
                            }
                        }

                    Picker("餐别", selection: $mealType) {
                        Text("无").tag(nil as String?)
                        ForEach(mealTypes, id: \.self) { type in
                            Text(type).tag(type as String?)
                        }
                    }

                    Button {
                        showTemplatePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("从模板选择")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // MARK: - 基准营养
                Section {
                    HStack {
                        Text(baseUnitLabel)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button {
                            showScanner = true
                        } label: {
                            Image(systemName: "camera.fill")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }

                    NutrientFieldRow(label: "热量", text: $caloriesPer100, unit: "千卡")
                    NutrientFieldRow(label: "蛋白质", text: $proteinPer100, unit: "g")
                    NutrientFieldRow(label: "碳水", text: $carbsPer100, unit: "g")
                    NutrientFieldRow(label: "脂肪", text: $fatPer100, unit: "g")
                    NutrientFieldRow(label: "钠", text: $sodiumPer100, unit: "mg")
                }

                // MARK: - 自制食谱
                Section {
                    Toggle("这是自制食谱", isOn: $isRecipeMode)

                    if isRecipeMode {
                        Text("输入整份菜的营养总量和总重量")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        NutrientFieldRow(label: "总热量", text: $recipeTotalCalories, unit: "千卡")
                        NutrientFieldRow(label: "总蛋白质", text: $recipeTotalProtein, unit: "g")
                        NutrientFieldRow(label: "总碳水", text: $recipeTotalCarbs, unit: "g")
                        NutrientFieldRow(label: "总脂肪", text: $recipeTotalFat, unit: "g")
                        NutrientFieldRow(label: "总钠", text: $recipeTotalSodium, unit: "mg")

                        HStack {
                            Text("菜的总重量")
                            Spacer()
                            TextField("0", text: $recipeTotalWeight)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("g")
                                .foregroundColor(.secondary)
                        }

                        if let preview = recipePreview {
                            Text("每100g含量：\(String(format: "%.0f", preview.calories)) kcal | 蛋白质 \(String(format: "%.1f", preview.protein))g | 碳水 \(String(format: "%.1f", preview.carbs))g | 脂肪 \(String(format: "%.1f", preview.fat))g | 钠 \(String(format: "%.0f", preview.sodium))mg")
                                .font(.caption)
                                .foregroundColor(.blue)

                            Button("填入基准营养") {
                                fillFromRecipe()
                            }
                            .font(.subheadline)
                        }
                    }
                }

                // MARK: - 实际食用量
                Section("实际食用量") {
                    HStack {
                        TextField("数量", text: $amount)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Picker("单位", selection: $unit) {
                            ForEach(units, id: \.self) { u in
                                Text(u).tag(u)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // MARK: - 热量预览
                Section("热量预览") {
                    HStack {
                        Text("总热量")
                        Spacer()
                        Text("\(String(format: "%.1f", previewCalories)) kcal")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    Text("= \(String(format: "%.1f", caloriesValue)) kcal × (\(String(format: "%.1f", amountValue))\(unit) ÷ 100)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // MARK: - 感受与备注
                Section {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showFeelingSection.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "face.smiling")
                            Text("饮食感受与备注")
                            Spacer()
                            Image(systemName: showFeelingSection ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if showFeelingSection {
                        HStack(spacing: 24) {
                            FeelingButton(emoji: "😋", label: "满足", value: "satisfied", selected: $feeling)
                            FeelingButton(emoji: "😐", label: "一般", value: "neutral", selected: $feeling)
                            FeelingButton(emoji: "😣", label: "撑了", value: "stuffed", selected: $feeling)
                        }
                        .padding(.vertical, 4)

                        TextField("备注（可选）", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }

                // MARK: - 存为模板
                if showTemplateButton || hasNutritionFilled {
                    Section {
                        HStack {
                            TextField("模板名称", text: $templateNameForSave)
                                .textFieldStyle(.plain)
                            Button("存为模板") {
                                saveAsTemplate()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(templateNameForSave.trimmingCharacters(in: .whitespaces).isEmpty || !hasNutritionFilled)
                        }
                    }
                }
            }
            .navigationTitle("添加饮食记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") { addRecord() }
                        .fontWeight(.semibold)
                        .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showTemplatePicker) {
                TemplatePickerSheet { template in
                    foodName = template.name
                    caloriesPer100 = formatDouble(template.caloriesPer100g)
                    proteinPer100 = formatDouble(template.proteinPer100g)
                    carbsPer100 = formatDouble(template.carbsPer100g)
                    fatPer100 = formatDouble(template.fatPer100g)
                    sodiumPer100 = formatDouble(template.sodiumPer100g)
                    templateNameForSave = template.name
                }
            }
            .sheet(isPresented: $showScanner) {
                NutritionScannerView { result in
                    caloriesPer100 = formatDouble(result.calories)
                    proteinPer100 = formatDouble(result.protein)
                    carbsPer100 = formatDouble(result.carbs)
                    fatPer100 = formatDouble(result.fat)
                    sodiumPer100 = formatDouble(result.sodium)
                }
            }
            .overlay(
                Group {
                    if showSaveSuccess {
                        Text("已保存模板")
                            .font(.subheadline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.green.opacity(0.9))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                , alignment: .top
            )
        }
    }

    // MARK: - Actions

    private func addRecord() {
        let record = FoodRecord(
            date: Date(),
            mealType: mealType,
            foodName: foodName.trimmingCharacters(in: .whitespaces),
            amount: amountValue,
            unit: unit,
            calories: caloriesValue,
            protein: proteinValue,
            carbs: carbsValue,
            fat: fatValue,
            sodium: sodiumValue,
            feeling: feeling,
            note: note.trimmingCharacters(in: .whitespaces).isEmpty ? nil : note.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(record)
        dismiss()
    }

    private func saveAsTemplate() {
        let name = templateNameForSave.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, hasNutritionFilled else { return }

        let template = FoodTemplate(
            name: name,
            caloriesPer100g: caloriesValue,
            proteinPer100g: proteinValue,
            carbsPer100g: carbsValue,
            fatPer100g: fatValue,
            sodiumPer100g: sodiumValue
        )
        modelContext.insert(template)
        templateNameForSave = ""
        withAnimation { showSaveSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showSaveSuccess = false }
        }
    }

    private func fillFromRecipe() {
        guard let preview = recipePreview else { return }
        caloriesPer100 = formatDouble(preview.calories)
        proteinPer100 = formatDouble(preview.protein)
        carbsPer100 = formatDouble(preview.carbs)
        fatPer100 = formatDouble(preview.fat)
        sodiumPer100 = formatDouble(preview.sodium)
    }

    private var recipePreview: ScannedNutrition? {
        guard isRecipeMode,
              let totalWeight = Double(recipeTotalWeight), totalWeight > 0 else { return nil }

        let c = (Double(recipeTotalCalories) ?? 0) / totalWeight * 100
        let p = (Double(recipeTotalProtein) ?? 0) / totalWeight * 100
        let cb = (Double(recipeTotalCarbs) ?? 0) / totalWeight * 100
        let f = (Double(recipeTotalFat) ?? 0) / totalWeight * 100
        let s = (Double(recipeTotalSodium) ?? 0) / totalWeight * 100

        return ScannedNutrition(calories: c, protein: p, carbs: cb, fat: f, sodium: s)
    }
}

// MARK: - Subviews

private struct NutrientFieldRow: View {
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

private struct FeelingButton: View {
    let emoji: String
    let label: String
    let value: String
    @Binding var selected: String?

    var isSelected: Bool { selected == value }

    var body: some View {
        Button {
            selected = isSelected ? nil : value
        } label: {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.title)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .padding(8)
            .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helpers
private func formatDouble(_ value: Double) -> String {
    let rounded = (value * 10).rounded() / 10
    if rounded == rounded.rounded(.down) {
        return String(format: "%.0f", value)
    }
    return String(format: "%.1f", value)
}

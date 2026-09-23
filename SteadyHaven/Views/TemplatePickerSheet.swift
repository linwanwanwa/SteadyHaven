import SwiftUI
import SwiftData

struct TemplatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FoodTemplate.createdAt, order: .reverse) private var allTemplates: [FoodTemplate]
    @State private var searchText = ""

    var onSelect: (FoodTemplate) -> Void

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
                        Text("还没有模板")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("请先在「模板」Tab 中添加")
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

                    List(filteredTemplates) { template in
                        Button {
                            onSelect(template)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("每100g: \(String(format: "%.0f", template.caloriesPer100g)) kcal | 蛋白质 \(String(format: "%.1f", template.proteinPer100g))g")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 2)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("选择模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

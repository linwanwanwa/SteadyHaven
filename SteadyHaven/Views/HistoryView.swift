import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \FoodRecord.date, order: .reverse) private var allRecords: [FoodRecord]
    @State private var selectedDate = Date()
    @State private var searchText = ""

    private var selectedRecords: [FoodRecord] {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let records = allRecords.filter { $0.date >= startOfDay && $0.date < endOfDay }
        if searchText.isEmpty { return records }
        return records.filter { $0.foodName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "选择日期",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                .padding(.bottom, 8)

                let allDayRecords: [FoodRecord] = {
                    let startOfDay = Calendar.current.startOfDay(for: selectedDate)
                    let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
                    return allRecords.filter { $0.date >= startOfDay && $0.date < endOfDay }
                }()

                if allDayRecords.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        NutritionSummaryCard(records: [])
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(.blue.opacity(0.3))
                        Text("该日期没有记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            NutritionSummaryCard(records: selectedRecords)

                            // Search bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("搜索食物", text: $searchText)
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

                            LazyVStack(spacing: 10) {
                                ForEach(selectedRecords) { record in
                                    FoodRecordCard(record: record)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("历史")
        }
    }
}

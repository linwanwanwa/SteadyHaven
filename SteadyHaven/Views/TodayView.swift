import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodRecord.date, order: .reverse) private var allRecords: [FoodRecord]
    @State private var showAddSheet = false
    @State private var recordToDelete: FoodRecord?
    @State private var showDeleteConfirmation = false
    @State private var searchText = ""

    private var todayRecords: [FoodRecord] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let today = allRecords.filter { $0.date >= startOfDay && $0.date < endOfDay }
        if searchText.isEmpty { return today }
        return today.filter { $0.foodName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                if allRecords.filter({
                    let startOfDay = Calendar.current.startOfDay(for: Date())
                    let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
                    return $0.date >= startOfDay && $0.date < endOfDay
                }).isEmpty {
                    VStack(spacing: 16) {
                        NutritionSummaryCard(records: [])
                        Spacer()
                        Image(systemName: "fork.knife")
                            .font(.system(size: 48))
                            .foregroundColor(.blue.opacity(0.3))
                        Text("今天还没有记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("点击右下角 + 开始记录")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            NutritionSummaryCard(records: todayRecords)

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
                                ForEach(todayRecords) { record in
                                    FoodRecordCard(record: record)
                                        .padding(.horizontal)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                recordToDelete = record
                                                showDeleteConfirmation = true
                                            } label: {
                                                Label("删除", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.bottom, 80)
                    }
                }

                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(width: 60, height: 60)
                        .background(Color.blue.opacity(0.15))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("今日")
            .sheet(isPresented: $showAddSheet) {
                AddFoodSheet()
            }
            .confirmationDialog("确认删除", isPresented: $showDeleteConfirmation, presenting: recordToDelete) { record in
                Button("删除", role: .destructive) {
                    modelContext.delete(record)
                }
                Button("取消", role: .cancel) {}
            } message: { record in
                Text("确定要删除「\(record.foodName)」吗？")
            }
        }
    }
}

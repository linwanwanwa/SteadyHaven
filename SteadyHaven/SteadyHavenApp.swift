import SwiftUI
import SwiftData

@main
struct SteadyHavenApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                TodayView()
                    .tabItem {
                        Label("今日", systemImage: "sun.max")
                    }

                HistoryView()
                    .tabItem {
                        Label("历史", systemImage: "calendar")
                    }

                TemplateListView()
                    .tabItem {
                        Label("模板", systemImage: "doc.text")
                    }
            }
            .tint(.blue)
        }
        .modelContainer(for: [FoodRecord.self, FoodTemplate.self])
    }
}

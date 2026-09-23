# 技术规范 — SteadyHaven

## 技术栈

| 项目 | 版本/方案 |
|------|----------|
| 语言 | Swift 5.9+ |
| UI 框架 | SwiftUI |
| 数据持久化 | SwiftData |
| 最低支持 | iOS 17.0 |
| 网络依赖 | 无 |
| 第三方库 | 无 |

## 架构

```
App Entry (SteadyHavenApp)
  └── TabView
        ├── TodayView
        │     ├── NutritionSummaryCard
        │     ├── FoodRecordCard (List)
        │     └── AddFoodSheet (Sheet)
        └── HistoryView
              ├── DatePicker
              ├── NutritionSummaryCard
              └── FoodRecordCard (List)
```

## 数据层

- 使用 `@Model` 宏定义 `FoodRecord`
- 使用 `@Query` / `FetchDescriptor` 查询数据
- 使用 `@Environment(\.modelContext)` 进行增删操作
- 通过 `.modelContainer(for: FoodRecord.self)` 注入容器

### 日期查询方式

```swift
let startOfDay = Calendar.current.startOfDay(for: date)
let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
let predicate = #Predicate<FoodRecord> { $0.date >= startOfDay && $0.date < endOfDay }
```

## 关键实现细节

- 计算属性（totalXxx）不持久化，在需要时动态计算
- `NutritionSummaryCard` 接收 `[FoodRecord]`，内部 `reduce` 求和
- `FoodRecordCard` 使用 `@State isExpanded` 控制展开/折叠
- Sheet 中的基准营养输入使用 `.keyboardType(.decimalPad)`
- 浮动按钮使用 `ZStack(alignment: .bottomTrailing)` 定位

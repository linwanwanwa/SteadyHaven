# 开发执行指南 — SteadyHaven

## 开发原则

1. **小步迭代**：每次只完成一个独立的模块，确认无误后再推进
2. **先核心后边缘**：先完成数据模型 → 共享组件 → 页面 → 项目配置
3. **每个阶段完成后验证**：不攒到最后一口气编译

## 文件结构

```
SteadyHaven/
├── SteadyHaven.xcodeproj/
├── SteadyHaven/
│   ├── SteadyHavenApp.swift
│   ├── Models/
│   │   └── FoodRecord.swift
│   └── Views/
│       ├── NutritionSummaryCard.swift
│       ├── FoodRecordCard.swift
│       ├── AddFoodSheet.swift
│       ├── TodayView.swift
│       └── HistoryView.swift
├── docs/
│   ├── requirements.md
│   ├── tech-specs.md
│   ├── design-specs.md
│   └── development-guide.md
└── dev-logs/
    └── 2026-05-28.md
```

## 执行步骤

### 第 1 步：创建文档体系
- 创建 docs/ 和 dev-logs/ 目录
- 编写需求、技术、设计、开发指南文档
- 创建 CLAUDE.md 指引文件

### 第 2 步：编写数据模型
- `FoodRecord.swift`：@Model 类 + 计算属性

### 第 3 步：编写共享组件
- `NutritionSummaryCard.swift`：营养汇总卡片（今日/历史共用）
- `FoodRecordCard.swift`：记录卡片（可展开）

### 第 4 步：编写添加记录 Sheet
- `AddFoodSheet.swift`：表单 + 实时预览 + 存储逻辑

### 第 5 步：编写页面
- `TodayView.swift`：今日 Tab
- `HistoryView.swift`：历史 Tab

### 第 6 步：组装 App 入口
- `SteadyHavenApp.swift`：TabView + modelContainer

### 第 7 步：生成 Xcode 项目
- 创建 .xcodeproj 项目文件

### 第 8 步：编译验证
- Xcode Build & Run，验证核心功能

## 验证清单

- [ ] App 启动不崩溃
- [ ] 今日页显示空状态（无记录时）
- [ ] 添加记录后汇总数据正确
- [ ] 记录卡片可展开/折叠
- [ ] 删除确认弹窗正常
- [ ] 历史页日期选择器可用
- [ ] 历史页数据只读
- [ ] 基准单位跟随食用量 g/ml 切换
- [ ] 实时热量预览计算正确
- [ ] 手动验算一份记录的营养值

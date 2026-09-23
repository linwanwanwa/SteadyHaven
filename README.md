# CLAUDE.md — SteadyHaven 项目指引

## 项目简介

SteadyHaven（稳港）是一款极简饮食记录 iOS App。SwiftUI + SwiftData，纯本地存储，iOS 17+。

## 标准文件路径

| 文件 | 路径 | 说明 |
|------|------|------|
| 需求文档 | [docs/requirements.md](docs/requirements.md) | 核心功能与非功能需求 |
| 技术规范 | [docs/tech-specs.md](docs/tech-specs.md) | 技术栈、架构、数据层设计 |
| 设计规范 | [docs/design-specs.md](docs/design-specs.md) | 配色、字体、间距、组件规范 |
| 开发指南 | [docs/development-guide.md](docs/development-guide.md) | 执行步骤与验证清单 |
| 开发日志 | [dev-logs/](dev-logs/) | 每日开发记录 |

## 工作原则

1. **小步迭代**：一次只做一个模块，确认无误后再推进
2. **先读标准文件**：每次开发前先查阅 docs/ 下的对应规范
3. **每日记录日志**：在 dev-logs/ 下以 `YYYY-MM-DD.md` 格式记录当天完成和待办事项
4. **不引入第三方依赖**：只用 Apple 原生框架
5. **保持简约**：UI 遵循设计规范，不过度设计

## 项目结构

```
SteadyHaven/
├── SteadyHavenApp.swift          # @main 入口
├── Models/
│   └── FoodRecord.swift          # @Model 数据模型
├── Views/
│   ├── TodayView.swift           # 今日 Tab
│   ├── HistoryView.swift         # 历史 Tab
│   ├── AddFoodSheet.swift        # 添加记录 Sheet
│   ├── FoodRecordCard.swift      # 记录卡片组件
│   └── NutritionSummaryCard.swift # 汇总卡片组件
```

## 常见操作

- 修改数据模型后需删除 App 重新安装（SwiftData 迁移）
- 编译前确认 Xcode 版本支持 SwiftData（Xcode 15+）
- UI 调整遵循 [docs/design-specs.md](docs/design-specs.md) 中的配色和间距规范

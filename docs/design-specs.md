# 设计规范 — SteadyHaven

## 配色

| 用途 | 颜色 |
|------|------|
| 卡片背景 | `Color.blue.opacity(0.15)` |
| 展开背景 | `Color.blue.opacity(0.08)` |
| 按钮/强调色 | 系统蓝色 (`.tint(.blue)`) |
| 浮动按钮背景 | `Color.blue.opacity(0.15)` |
| 浮动按钮图标 | 蓝色 `Image(systemName: "plus")` |
| 文字主色 | `.primary`（自适应深色模式） |
| 文字辅色 | `.secondary` |

## 字体

- 全局使用 SF Pro（SwiftUI 默认）
- 总热量数字：`.system(size: 48, weight: .bold)`
- 卡片标题：`.headline`
- 营养素数值：`.subheadline` / `.caption2`

## 间距

- 汇总卡片与列表间距：12pt
- 列表项间距：10pt
- 卡片内边距：16pt（记录卡片）/ 24pt（汇总卡片）
- 浮动按钮距边缘：24pt
- 页面水平边距：系统默认 padding

## 圆角

- 汇总卡片：16pt
- 记录卡片：12pt
- 展开详情：8pt
- 浮动按钮：圆形（Circle）

## 组件

### NutritionSummaryCard（汇总卡片）
- 顶部：大号热量数字 + "千卡" 单位
- 底部：4 项营养素横向排列
- 背景：`Color.blue.opacity(0.15)`，圆角 16

### FoodRecordCard（记录卡片）
- 折叠态：食物名 + 餐别 | 食用量 + 总热量 + 展开箭头
- 展开态：附加 4 项营养素水平排列
- 点击展开/折叠，带动画

### AddFoodSheet（添加记录）
- Form 布局，四个 Section：食物信息、基准营养、实际食用量、热量预览
- 导航栏左"取消"右"添加"

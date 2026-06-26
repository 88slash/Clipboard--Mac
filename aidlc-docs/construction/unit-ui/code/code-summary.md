# 代码摘要 — Unit 2: UI

## 生成文件列表

| 文件 | 位置 | 说明 |
|------|------|------|
| `MainPanelView.swift` | `ClipSmart/UI/` | 根面板视图，键盘导航，Glass 修饰器 |
| `SearchBarView.swift` | `ClipSmart/UI/` | 搜索栏，自动聚焦，清除按钮 |
| `PinnedSectionView.swift` | `ClipSmart/UI/` | 固定区域，橙色 Pin 标题 |
| `ClipListView.swift` | `ClipSmart/UI/` | 普通记录列表（组合辅助组件）|
| `ClipItemView.swift` | `ClipSmart/UI/` | 单条记录，右键菜单，hover 效果 |
| `EmptyStateView.swift` | `ClipSmart/UI/` | 空状态，脉冲动画图标 |

## 关键实现要点

| 特性 | 实现方式 |
|------|---------|
| macOS 26 Liquid Glass | `#available(macOS 26.0, *)` + `.glassBackground` / 否则 `.ultraThinMaterial` |
| 键盘导航（↑↓↩⌫）| `onKeyPress` modifier + `selectedIndex` 状态 |
| 搜索实时过滤 | `HistoryViewModel.searchQuery` @Observable 驱动 |
| 图片缩略图 | `ClipboardItem.thumbnailImage` 懒加载，44×44pt |
| 右键仅复制 | `contextMenu` 内独立写入，不触发 `onRequestClose` |
| 相对时间戳 | 本地化字符串（刚刚 / N分钟前 / N小时前 / MM/dd）|
| 深色/浅色 | 全部使用语义色（.primary / .secondary / .tint），自动跟随系统 |
| 空结果状态 | 搜索无结果时展示专用提示，区别于无历史记录状态 |

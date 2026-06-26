# 单元依赖矩阵 — ClipSmart

## 单元间依赖

```
Unit 1 (Core)
    │
    │  HistoryViewModel, ClipboardItem, HistoryStore
    v
Unit 2 (UI)
    │
    │  MainPanelView + HistoryViewModel
    v
Unit 3 (AppShell)
```

> Core → UI → AppShell 严格单向依赖，禁止反向引用。

## 依赖矩阵

| 单元 | 依赖 Core | 依赖 UI | 依赖 AppShell |
|------|-----------|---------|---------------|
| Core | —         | ✗       | ✗             |
| UI   | ✓         | —       | ✗             |
| AppShell | ✓     | ✓       | —             |

## 开发顺序

```
阶段 1 ──► Unit 1 (Core)
              ↓ 完成后
阶段 2 ──► Unit 2 (UI)
              ↓ 完成后
阶段 3 ──► Unit 3 (AppShell)
              ↓ 完成后
阶段 4 ──► 集成测试 + 构建 .dmg
```

## 集成点

| 集成点 | 涉及单元 | 接口 |
|--------|---------|------|
| UI 消费 Core 数据 | UI ← Core | `HistoryViewModel`（@Observable）注入 MainPanelView |
| AppShell 显示 UI | AppShell ← UI | `MainPanelView` 嵌入 `PanelWindowController` (NSHostingView) |
| AppShell 操控 Core | AppShell ← Core | `HistoryStore.clearAll()`、`PreferencesStore` |
| 热键触发面板 | AppShell 内部 | `HotkeyManager` → `PanelWindowController.togglePanel()` |

## 外部 SPM 依赖

| 包 | 版本 | 引入单元 |
|-----|------|---------|
| [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) | 2.x | AppShell |

## 风险点

| 风险 | 影响单元 | 缓解方案 |
|------|---------|---------|
| NSPanel + SwiftUI 兼容性 | AppShell + UI | 使用 NSHostingController 桥接，充分测试 |
| NSPasteboard 轮询性能 | Core | 轮询间隔 500ms，非主线程执行 |
| SwiftData 首次迁移 | Core | 定义 VersionedSchema，预留迁移路径 |
| KeyboardShortcuts 沙盒限制 | AppShell | 禁用 App Sandbox（Info.plist 配置） |

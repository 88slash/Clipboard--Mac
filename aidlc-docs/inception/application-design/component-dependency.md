# 组件依赖关系 — ClipSmart

## 依赖矩阵

| 组件 | 依赖 | 被依赖 |
|------|------|--------|
| `ClipboardItem` | — | ClipboardMonitor, HistoryStore, HistoryViewModel, ClipItemView |
| `ClipboardMonitor` | HistoryStore | ClipSmartApp |
| `HistoryStore` | ClipboardItem (SwiftData) | ClipboardMonitor, HistoryViewModel, MenuBarManager |
| `HistoryViewModel` | HistoryStore | MainPanelView, ClipListView, PinnedSectionView, SearchBarView |
| `MainPanelView` | HistoryViewModel, SearchBarView, ClipListView, PinnedSectionView | PanelWindowController |
| `ClipItemView` | ClipboardItem | ClipListView, PinnedSectionView |
| `PanelWindowController` | MainPanelView | HotkeyManager, MenuBarManager |
| `HotkeyManager` | PanelWindowController, PreferencesStore | ClipSmartApp |
| `MenuBarManager` | PanelWindowController, PreferencesStore, HistoryStore | ClipSmartApp |
| `PreferencesStore` | — | HotkeyManager, MenuBarManager, HistoryStore, SettingsView |
| `SettingsView` | PreferencesStore, HotkeyManager | ClipSmartApp (Settings scene) |
| `ClipSmartApp` | 所有单例服务 | — |

---

## 数据流图

```
系统剪切板 (NSPasteboard)
        │
        │ 轮询 (500ms)
        v
  ClipboardMonitor
        │
        │ addItem(ClipboardItem)
        v
   HistoryStore ──────────────────► SwiftData (持久化)
        │
        │ 数据变更通知
        v
  HistoryViewModel
    │          │
    │          │ searchQuery 过滤
    v          v
pinnedItems  regularItems
    │          │
    v          v
PinnedSection  ClipList
    └────┬─────┘
         │
         v
    ClipItemView
         │
    单击 │ 右键
    ┌────┘────┐
    v         v
写入         上下文菜单
NSPasteboard  (固定/删除/复制)
关闭面板
```

---

## 事件流图

```
用户按下 ⌘+Shift+V
        │
        v
  HotkeyManager
        │
        v
PanelWindowController.togglePanel()
        │
        ├── 若已显示 → hidePanel() → 动画关闭
        │
        └── 若已隐藏 → showPanel()
                        │
                        v
                  居中定位 + 动画显示
                  MainPanelView (SwiftUI)
                        │
                        v
                  SearchBarView 自动聚焦
```

---

## 外部系统依赖

| 外部依赖 | 用途 | 集成方式 |
|---------|------|---------|
| `NSPasteboard` | 读取/写入系统剪切板 | macOS 系统 API |
| `SwiftData` | 历史记录持久化 | macOS 14+ 框架 |
| `KeyboardShortcuts` | 全局热键注册 | Swift Package Manager |
| `NSStatusItem` | 菜单栏图标 | macOS AppKit |
| `NSPanel` | 浮动无标题栏窗口 | macOS AppKit |
| `SMAppService` | 开机自启管理 | macOS 13+ ServiceManagement 框架 |
| `NSVisualEffectView` | Liquid Glass 背景模糊 | macOS AppKit |

---

## 依赖注入策略

```
ClipSmartApp (@main)
    ├── 创建 ModelContainer (SwiftData)
    ├── 创建 PreferencesStore
    ├── 创建 HistoryStore (注入 ModelContext)
    ├── 创建 ClipboardMonitor (注入 HistoryStore)
    ├── 创建 HistoryViewModel (注入 HistoryStore)
    ├── 创建 PanelWindowController (注入 HistoryViewModel)
    ├── 创建 HotkeyManager (注入 PanelWindowController)
    └── 创建 MenuBarManager (注入 PanelWindowController + HistoryStore)

所有服务通过 @EnvironmentObject / @Environment 向下传递到 SwiftUI 视图树
```

---

## 层间通信规则

| 规则 | 说明 |
|------|------|
| **UI → ViewModel** | 直接调用方法（`viewModel.selectItem()`） |
| **ViewModel → Store** | 直接调用方法（`store.addItem()`） |
| **Store → UI** | 通过 `@Observable` 自动响应式更新 |
| **AppShell → Core** | 直接引用（初始化时注入） |
| **跨 Unit 通信** | 仅通过公开接口，禁止跨层直接访问内部实现 |

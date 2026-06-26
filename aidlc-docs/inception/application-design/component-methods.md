# 组件方法签名 — ClipSmart

> 详细业务逻辑将在 Construction 阶段的功能设计中定义

---

## Unit 1 — Core 层

### ClipboardItem
```swift
// 构造
init(textContent: String, type: ClipboardItemType, sourceApp: String?)
init(imageData: Data, type: ClipboardItemType, sourceApp: String?)
init(fileURLs: [URL], sourceApp: String?)

// 计算属性
var displayPreview: String { get }    // 文本截断预览 or "[图片]" or "[文件: name]"
var thumbnailImage: NSImage? { get }  // 图片类型返回缩略图，其他返回 nil
```

### ClipboardMonitor
```swift
// 生命周期
func startMonitoring()
func stopMonitoring()

// 内部
private func checkForChanges()                          // 定时器回调
private func extractItem(from pasteboard: NSPasteboard) -> ClipboardItem?
```

### HistoryStore
```swift
// 查询
func allItems() -> [ClipboardItem]
func pinnedItems() -> [ClipboardItem]
func regularItems() -> [ClipboardItem]
func search(query: String) -> [ClipboardItem]

// 写入
func addItem(_ item: ClipboardItem)                     // 含去重 + FIFO 淘汰逻辑
func deleteItem(_ item: ClipboardItem)
func clearAll()

// 固定
func togglePin(_ item: ClipboardItem)

// 容量管理
private func evictOldestIfNeeded()                      // FIFO 淘汰非固定记录
```

### HistoryViewModel
```swift
// 状态（@Published / @Observable）
var searchQuery: String
var pinnedItems: [ClipboardItem]    // 计算属性，过滤后的固定记录
var regularItems: [ClipboardItem]  // 计算属性，过滤后的普通记录
var isEmpty: Bool

// 操作
func selectItem(_ item: ClipboardItem)   // 写入 NSPasteboard
func deleteItem(_ item: ClipboardItem)
func togglePin(_ item: ClipboardItem)
func clearAll()
```

---

## Unit 2 — UI 层

### MainPanelView
```swift
// SwiftUI View body — 组合子视图
// 环境注入: @EnvironmentObject var viewModel: HistoryViewModel
var body: some View                                      // SearchBar + PinnedSection + ClipList
```

### SearchBarView
```swift
// 绑定到 HistoryViewModel.searchQuery
// @FocusState 自动聚焦
var body: some View
```

### ClipListView
```swift
// 渲染 viewModel.regularItems
// 支持键盘导航（.focusable + .onKeyPress）
var body: some View
```

### PinnedSectionView
```swift
// 渲染 viewModel.pinnedItems
// 仅在 pinnedItems 非空时显示
var body: some View
```

### ClipItemView
```swift
// 接收单个 ClipboardItem
// 单击回调: onTap: (ClipboardItem) -> Void
// 右键菜单: .contextMenu
var body: some View
```

---

## Unit 3 — AppShell 层

### MenuBarManager
```swift
func setup()                         // 初始化 NSStatusItem 和菜单
func updateMenu()                    // 刷新菜单状态
private func togglePanel()          // 显示/隐藏面板
```

### HotkeyManager
```swift
func registerHotkey()               // 注册当前设置的快捷键
func unregisterHotkey()
func updateHotkey(to newShortcut: KeyboardShortcut)
```

### PanelWindowController
```swift
func showPanel()                    // 居中显示面板 + 弹簧动画
func hidePanel()                    // 隐藏动画 + 失焦
func togglePanel()

private func centerOnScreen()
private func setupWindow()          // 配置 NSPanel 样式（无标题栏、圆角、材质）
```

### PreferencesStore
```swift
// @AppStorage 属性
var maxHistoryCount: Int            // 默认 50，范围 1-200
var hotkeyModifiers: Int            // 快捷键修饰键掩码
var hotkeyKeyCode: Int              // 快捷键 keyCode
var showInDock: Bool                // 默认 false
var launchAtLogin: Bool             // 默认 false

// 方法
func resetToDefaults()
```

### SettingsView
```swift
// SwiftUI Settings Scene View
// 分区: 通用 / 快捷键 / 存储 / 关于
var body: some View
```

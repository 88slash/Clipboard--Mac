# 业务逻辑模型 — Unit 1: Core

## 主流程：剪切板监听与写入

```
[后台 Timer，500ms]
        │
        v
ClipboardMonitor.checkForChanges()
        │
        ├─► 读取 NSPasteboard.changeCount
        │         │
        │         ├── 未变化 → 返回（等待下次）
        │         │
        │         └── 已变化 ──────────────────────────────────┐
        │                                                       │
        v                                                       v
提取内容（BR-01 优先级）                              更新 lastChangeCount
        │
        ├─► 无内容 → 返回
        │
        v
构建 ClipboardItem
        │
        v
HistoryStore.addItem(item)
        │
        ├─► BR-02 去重检查
        │         ├── 重复 → 返回
        │         └── 不重复 → 继续
        │
        ├─► BR-03 FIFO 淘汰
        │         └── regularCount >= max → 删除最老 regular 记录
        │
        └─► 写入 SwiftData
```

---

## 主流程：用户选中历史记录

```
HistoryViewModel.selectItem(item)
        │
        v
写入 NSPasteboard（BR-08）
        │
        v
通知 UI 关闭面板
```

---

## 主流程：搜索过滤

```
HistoryViewModel.searchQuery 变化
        │
        v
重新计算 pinnedItems / regularItems
        │
        ├── searchQuery 为空
        │       ├── pinnedItems = store.all().filter { isPinned }，按 timestamp 降序
        │       └── regularItems = store.all().filter { !isPinned }，按 timestamp 降序
        │
        └── searchQuery 非空
                ├── pinnedItems = pinnedAll.filter { matches(searchQuery) }
                └── regularItems = regularAll.filter { matches(searchQuery) }

matches(query):
    plainText/richText → textContent.localizedCaseInsensitiveContains(query)
    image              → false（不参与文本搜索，但仍然保留在无搜索时的列表中）
    fileURLs           → displayPreview.localizedCaseInsensitiveContains(query)
```

---

## 主流程：容量变更

```
用户在 SettingsView 调整 maxHistoryCount
        │
        v
PreferencesStore.maxHistoryCount = newValue
        │
        v
HistoryStore 监听到变化
        │
        v
若 regularCount > newMax
    循环删除最老的 regular 记录，直至 regularCount == newMax
```

---

## 状态机：ClipboardMonitor 生命周期

```
            ┌─────────┐
  应用启动 →│  IDLE   │
            └────┬────┘
                 │ startMonitoring()
                 v
         ┌───────────────┐
         │  MONITORING   │◄──────── 500ms Timer
         └───────┬───────┘
                 │ stopMonitoring() / 应用退出
                 v
            ┌─────────┐
            │ STOPPED │
            └─────────┘
```

---

## HistoryStore 内部数据结构

```swift
// 内存中维护两个有序数组（从 SwiftData @Query 派生）
var allItems: [ClipboardItem]     // 全量，按 timestamp DESC

// 派生计算属性
var pinnedItems: [ClipboardItem]  { allItems.filter { $0.isPinned } }
var regularItems: [ClipboardItem] { allItems.filter { !$0.isPinned } }

// 容量上限从 PreferencesStore 读取
var maxRegularCount: Int          { preferences.maxHistoryCount }
```

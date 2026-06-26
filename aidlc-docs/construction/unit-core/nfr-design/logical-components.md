# 逻辑组件设计 — Unit 1: Core

## 组件职责划分（细化）

```
Core 层内部结构
├── Models/
│   ├── ClipboardItem.swift          @Model SwiftData 实体
│   └── ClipboardItemType.swift      内容类型枚举 + NSPasteboard 类型映射
│
├── Services/
│   ├── ClipboardMonitor.swift       后台 DispatchSourceTimer 轮询
│   │   ├── startMonitoring()        启动定时器
│   │   ├── stopMonitoring()         停止定时器
│   │   ├── pauseMonitoring()        临时暂停（防抖用）
│   │   ├── resumeMonitoring()       恢复监听
│   │   └── extractItem(from:)       内容提取（优先级 BR-01）
│   │
│   └── HistoryStore.swift           @MainActor 历史记录管理
│       ├── addItem()                含去重 + FIFO 淘汰
│       ├── deleteItem()             单条删除
│       ├── clearAll()               批量删除
│       ├── togglePin()              固定/取消固定
│       └── evictOldestIfNeeded()    FIFO 淘汰私有方法
│
└── ViewModels/
    └── HistoryViewModel.swift       @Observable 数据过滤与 UI 操作
        ├── searchQuery              双向绑定
        ├── pinnedItems (computed)   固定记录（过滤后）
        ├── regularItems (computed)  普通记录（过滤后）
        ├── selectItem()             写入 NSPasteboard + 触发关闭面板
        ├── deleteItem()             委托 HistoryStore
        └── togglePin()              委托 HistoryStore
```

## 跨组件通信

```
ClipboardMonitor
    ──写入──► HistoryStore (via Task { @MainActor in })

HistoryStore (@MainActor)
    ──@Observable 自动通知──► HistoryViewModel (计算属性重新求值)

HistoryViewModel (@Observable)
    ──@Observable 自动通知──► SwiftUI Views（自动重绘）
```

## 关键并发边界

| 代码区域 | 执行线程 | 原因 |
|---------|---------|------|
| `ClipboardMonitor.checkForChanges()` | background queue | 不阻塞主线程 |
| `NSPasteboard` 读取 | background queue | 跟随 checkForChanges |
| `HistoryStore` 所有方法 | @MainActor (主线程) | SwiftData ModelContext 线程安全 |
| `HistoryViewModel` 计算属性 | @MainActor (主线程) | 驱动 SwiftUI 视图更新 |
| `ClipboardMonitor → HistoryStore` 写入 | Task { @MainActor in } | 线程跳转 |

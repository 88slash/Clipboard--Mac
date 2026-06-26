# 代码摘要 — Unit 1: Core

## 生成文件列表

| 文件 | 位置 | 说明 |
|------|------|------|
| `ClipboardItemType.swift` | `ClipSmart/Core/Models/` | 内容类型枚举 |
| `ClipboardItem.swift` | `ClipSmart/Core/Models/` | SwiftData 持久化实体，含 NSImage 扩展 |
| `HistoryStore.swift` | `ClipSmart/Core/Services/` | 历史记录仓库，FIFO + 去重逻辑 |
| `ClipboardMonitor.swift` | `ClipSmart/Core/Services/` | 后台轮询监听，内容提取 |
| `HistoryViewModel.swift` | `ClipSmart/Core/ViewModels/` | 视图模型，搜索过滤 + 操作代理 |
| `ClipboardItemTests.swift` | `ClipSmartTests/CoreTests/` | 模型单元测试 |
| `HistoryStoreTests.swift` | `ClipSmartTests/CoreTests/` | 仓库单元测试（含 FIFO/去重） |
| `HistoryViewModelTests.swift` | `ClipSmartTests/CoreTests/` | 视图模型单元测试（含搜索过滤） |

## 业务规则覆盖

| 规则 | 实现位置 | 测试覆盖 |
|------|---------|---------|
| BR-01 内容提取优先级 | `ClipboardMonitor.extractItem()` | — |
| BR-02 去重 | `HistoryStore.isDuplicate()` | ✅ `HistoryStoreTests` |
| BR-03 FIFO 淘汰 | `HistoryStore.evictOldestIfNeeded()` | ✅ `HistoryStoreTests` |
| BR-04 固定记录 | `HistoryStore.togglePin()` | ✅ `HistoryStoreTests` |
| BR-05 搜索过滤 | `HistoryViewModel.filtered()` | ✅ `HistoryViewModelTests` |
| BR-06 轮询监听 | `ClipboardMonitor.checkForChanges()` | — |
| BR-07 持久化 | `HistoryStore` + SwiftData | ✅ In-memory 测试 |
| BR-08 写回剪切板 | `HistoryViewModel.writeToPasteboard()` | ✅ 关闭回调测试 |

## 关键技术点

- `@Model` + SwiftData `@Attribute(.externalStorage)` — 图片数据外部存储
- `DispatchSourceTimer` (QoS: .utility) — 低功耗后台轮询
- `@MainActor` + `Task { @MainActor in }` — 线程安全写入
- `@Observable` — SwiftUI 响应式绑定（替代 `@Published`）

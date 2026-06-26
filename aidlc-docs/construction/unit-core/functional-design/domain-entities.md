# 领域实体 — Unit 1: Core

## ClipboardItem（核心实体）

```
ClipboardItem
├── id: UUID                          // 唯一标识
├── contentType: ClipboardItemType    // 内容类型枚举
├── textContent: String?              // 纯文本 / 富文本内容
├── imageData: Data?                  // 图片原始数据（PNG/JPEG/TIFF）
├── fileURLStrings: [String]          // 文件路径列表（URL 序列化为 String）
├── timestamp: Date                   // 复制时间
├── isPinned: Bool                    // 是否固定（默认 false）
└── sourceApp: String?                // 来源应用 Bundle ID（可选，用于展示）
```

### ClipboardItemType 枚举

```
ClipboardItemType
├── plainText      // NSPasteboard.PasteboardType.string
├── richText       // NSPasteboard.PasteboardType.rtf / html
├── image          // NSPasteboard.PasteboardType.tiff / png
└── fileURLs       // NSPasteboard.PasteboardType.fileURL
```

### 计算属性（非持久化）

```
displayPreview: String
├── plainText/richText → textContent 前 100 字符（超出截断 + "…"）
├── image             → "[图片]"
└── fileURLs          → "[文件: <最后一个路径分量>]"

thumbnailImage: NSImage?
├── image type → NSImage(data: imageData)，缩放至 44×44pt
└── 其他 type  → nil

fileURLs: [URL]
└── fileURLStrings.compactMap { URL(string: $0) }
```

---

## AppPreferences（配置值对象）

> 非 SwiftData 模型，使用 @AppStorage / UserDefaults 存储

```
AppPreferences
├── maxHistoryCount: Int     // 1-200，默认 50
├── showInDock: Bool         // 默认 false
├── launchAtLogin: Bool      // 默认 false
└── hotkeyShortcut: String   // KeyboardShortcuts 序列化键名
```

---

## 实体关系

```
HistoryStore
    │  持有集合
    ├──► [ClipboardItem] (pinnedItems)   // isPinned == true，按 timestamp 降序
    └──► [ClipboardItem] (regularItems) // isPinned == false，按 timestamp 降序

ClipboardMonitor
    └──► 产生 ClipboardItem → 写入 HistoryStore

HistoryViewModel
    ├──► 读取 HistoryStore
    └──► 输出过滤后的 pinnedItems / regularItems 给 UI
```

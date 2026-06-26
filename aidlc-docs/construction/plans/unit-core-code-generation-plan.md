# 代码生成计划 — Unit 1: Core

## 单元上下文
- **单元**: Core（核心层）
- **目标目录**: `ClipSmart/Core/`（工作区根目录下）
- **覆盖需求**: FR-01, FR-02, FR-03, FR-07, FR-09（BR-01~BR-08）
- **依赖**: SwiftData（系统框架）

---

## 步骤列表

### Step 1: 创建 Xcode 项目基础结构
- [ ] 创建 `ClipSmart/` 目录
- [ ] 创建 `ClipSmart/Core/Models/` 目录
- [ ] 创建 `ClipSmart/Core/Services/` 目录
- [ ] 创建 `ClipSmart/Core/ViewModels/` 目录
- [ ] 创建 `ClipSmartTests/CoreTests/` 目录

### Step 2: 生成 ClipboardItemType.swift
- [ ] 定义 `ClipboardItemType` 枚举（plainText, richText, image, fileURLs）
- [ ] 添加 `NSPasteboard.PasteboardType` 映射计算属性
- [ ] 添加 displayName 本地化字符串

### Step 3: 生成 ClipboardItem.swift
- [ ] 定义 `@Model class ClipboardItem`（SwiftData 实体）
- [ ] 实现所有属性（id, contentType, textContent, imageData, fileURLStrings, timestamp, isPinned, sourceApp）
- [ ] 实现计算属性（displayPreview, thumbnailImage, fileURLs）
- [ ] 实现便捷构造器（文本、图片、文件三种）

### Step 4: 生成 HistoryStore.swift
- [ ] 定义 `@MainActor final class HistoryStore`
- [ ] 注入 `ModelContext`
- [ ] 实现 `addItem()` — 含 BR-02 去重 + BR-03 FIFO 淘汰
- [ ] 实现 `deleteItem()`
- [ ] 实现 `clearAll()`
- [ ] 实现 `togglePin()`
- [ ] 实现私有 `evictOldestIfNeeded()`
- [ ] 实现 `allItems / pinnedItems / regularItems` 查询属性

### Step 5: 生成 ClipboardMonitor.swift
- [ ] 定义 `final class ClipboardMonitor`
- [ ] 实现 `DispatchSourceTimer` 后台轮询（500ms）
- [ ] 实现 `startMonitoring() / stopMonitoring() / pauseMonitoring() / resumeMonitoring()`
- [ ] 实现 `extractItem(from: NSPasteboard)` — BR-01 优先级提取
- [ ] 实现主线程写入 `HistoryStore`（Task { @MainActor in }）

### Step 6: 生成 HistoryViewModel.swift
- [ ] 定义 `@MainActor @Observable final class HistoryViewModel`
- [ ] 实现 `searchQuery` 状态
- [ ] 实现 `pinnedItems / regularItems` 计算属性（含搜索过滤 BR-05）
- [ ] 实现 `selectItem()` — 写入 NSPasteboard（BR-08）
- [ ] 实现 `deleteItem() / togglePin() / clearAll()` 委托方法

### Step 7: 生成单元测试
- [ ] `ClipboardItemTests.swift` — 模型构造、displayPreview、thumbnailImage
- [ ] `HistoryStoreTests.swift` — addItem 去重、FIFO 淘汰、固定记录淘汰豁免、clearAll、togglePin
- [ ] `HistoryViewModelTests.swift` — 搜索过滤（文本/图片/文件）、pinnedItems/regularItems 分组

### Step 8: 生成代码摘要文档
- [ ] 创建 `aidlc-docs/construction/unit-core/code/code-summary.md`

---

## 生成完成标准
- [ ] 所有 Swift 文件语法正确，无编译错误
- [ ] 所有业务规则（BR-01~BR-08）均在代码中有对应实现
- [ ] 单元测试覆盖核心业务逻辑

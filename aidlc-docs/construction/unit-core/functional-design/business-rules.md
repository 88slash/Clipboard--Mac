# 业务规则 — Unit 1: Core

## BR-01：内容提取优先级

当 NSPasteboard 发生变化时，按以下优先级提取内容（高优先级覆盖低优先级）：

```
优先级 1: 文件 URL (NSFilenamesPboardType / .fileURL)
优先级 2: 图片 (TIFF / PNG / JPEG)
优先级 3: 富文本 (RTF / HTML)
优先级 4: 纯文本 (String)
```

> 同一次复制只生成一条 ClipboardItem，取最高优先级类型。

---

## BR-02：去重规则

**触发时机**: 每次检测到 NSPasteboard 内容变化后，提取新 ClipboardItem 前

**规则**:
```
IF 新内容类型 == 历史列表最新一条的内容类型
AND 新内容与最新一条内容完全一致
    → 丢弃新内容，不写入 HistoryStore
ELSE
    → 正常写入
```

**内容一致性判断**:
- `plainText` / `richText` → `textContent` 字符串相等（区分大小写）
- `image` → `imageData.hashValue` 相等（SHA256 摘要比对）
- `fileURLs` → `fileURLStrings` 集合完全一致（顺序无关）

---

## BR-03：FIFO 容量淘汰规则

**触发时机**: `HistoryStore.addItem()` 写入新记录时

**规则**:
```
计算 regularCount = 非固定记录数量

IF regularCount >= preferences.maxHistoryCount
    找到 regularItems 中 timestamp 最早的记录 (oldestRegular)
    删除 oldestRegular（从持久化存储中移除）

写入新记录
```

**约束**:
- 固定记录（isPinned == true）**永不参与淘汰**
- 若所有记录均为固定记录，仍可无限追加（固定记录不受容量限制）
- maxHistoryCount 范围：1 ≤ N ≤ 200

---

## BR-04：固定记录规则

**固定操作**: 将 ClipboardItem.isPinned 设为 true，持久化更新
**取消固定**: 将 ClipboardItem.isPinned 设为 false，持久化更新
**展示规则**: isPinned == true 的记录始终显示在列表顶部（独立于普通记录）
**淘汰豁免**: 固定记录不受 BR-03 FIFO 淘汰影响

---

## BR-05：搜索规则

**搜索范围**: 仅 `textContent`（plainText / richText 类型）
**搜索方式**: 大小写不敏感的包含匹配（`contains`）
**图片记录**: 不参与文本搜索，但搜索结果中默认**显示**（搜索词为空时）
**文件记录**: 对 `displayPreview` 文本（文件名）进行搜索

**搜索为空时**: 返回全部记录（固定 + 普通，按 timestamp 降序）

---

## BR-06：监听轮询规则

**轮询间隔**: 500ms（后台 DispatchQueue 执行，不占用主线程）
**变化检测**: 通过 `NSPasteboard.general.changeCount` 与上次保存值对比
```
IF currentChangeCount != lastChangeCount
    lastChangeCount = currentChangeCount
    执行内容提取 → BR-01 → BR-02 → 写入 HistoryStore
```

**应用无焦点时**: 继续监听（全局后台服务）
**内容提取失败时**: 静默忽略，不写入，不报错（如剪切板内容为空）

---

## BR-07：持久化规则

- 所有 ClipboardItem（含图片 imageData）持久化到 SwiftData
- 应用启动时从 SwiftData 恢复历史记录
- 图片数据以原始 Data 存储（不压缩，SwiftData 支持大 Binary）
- 删除记录时同步从持久化层删除
- 清空全部时执行批量删除

---

## BR-08：内容写回规则（选中操作）

**触发**: 用户在 UI 层单击某条历史记录
**执行**:
```
NSPasteboard.general.clearContents()
根据 contentType:
    plainText  → setString(textContent, forType: .string)
    richText   → setData(textContent.data(rtf), forType: .rtf)
    image      → setData(imageData, forType: .tiff)
    fileURLs   → writeObjects(fileURLs as [NSURL])
```
**副作用**: 此写回操作本身会触发 ClipboardMonitor 检测到变化，
           但 BR-02 去重规则会确保不重复写入历史。

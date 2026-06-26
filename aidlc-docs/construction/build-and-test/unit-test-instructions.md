# 单元测试执行指南 — ClipSmart

## 运行所有单元测试

```
Xcode 快捷键: ⌘ + U（Test All）
或: Product → Test
```

---

## 单独运行测试套件

在 Xcode 的 **Test Navigator**（⌘ + 6）中找到对应测试类，点击运行按钮。

### ClipboardItemTests（11 个测试）
覆盖：`displayPreview` 截断、图片预览、文件预览、多文件预览、内容类型、URL 往返、缩略图、isPinned 默认值、Equatable

### HistoryStoreTests（9 个测试）
覆盖：addItem 基本、FIFO 淘汰、固定记录淘汰豁免、去重（相同文本）、去重（不同文本）、去重（不同类型）、togglePin、deleteItem、clearAll

### HistoryViewModelTests（10 个测试）
覆盖：空查询返回全部、大小写不敏感搜索、搜索无匹配、图片不参与文本搜索、文件名搜索、固定/普通分组、isEmpty、clearAll、selectItem 关闭回调

---

## 预期测试结果

```
Test Suite 'All tests' passed
    ClipboardItemTests     11 passed  (0 failed)
    HistoryStoreTests       9 passed  (0 failed)
    HistoryViewModelTests  10 passed  (0 failed)
Total: 30 tests, 0 failures
```

---

## 覆盖率查看

1. **Xcode → Product → Test**（勾选 Gather Coverage Data）
2. Report Navigator（⌘ + 9）→ Coverage 标签页
3. 目标：Core 层核心业务逻辑覆盖率 ≥ 80%

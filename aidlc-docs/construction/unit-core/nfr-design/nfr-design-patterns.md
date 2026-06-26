# NFR 设计模式 — Unit 1: Core

## 模式 1：后台轮询（Background Polling）

**解决**: CPU 占用 < 0.5% 的性能需求

```swift
// 专用后台队列，QoS 为 utility（比 background 稍高但不抢 UI 资源）
private let monitorQueue = DispatchQueue(
    label: "com.clipsmart.clipboard-monitor",
    qos: .utility
)

// 定时器在后台队列上调度
private var timer: DispatchSourceTimer?

func startMonitoring() {
    timer = DispatchSource.makeTimerSource(queue: monitorQueue)
    timer?.schedule(deadline: .now(), repeating: .milliseconds(500))
    timer?.setEventHandler { [weak self] in
        self?.checkForChanges()
    }
    timer?.resume()
}
```

**为何选 DispatchSourceTimer 而非 Timer.scheduledTimer**:
- `Timer.scheduledTimer` 依赖 RunLoop，在主线程可能被 UI 事件阻塞
- `DispatchSourceTimer` 精度更高，不受 RunLoop 模式影响

---

## 模式 2：Actor 隔离（Swift Concurrency Actor）

**解决**: HistoryStore 的并发安全需求

```swift
// HistoryStore 标记为 @MainActor，确保所有写操作在主线程
// SwiftData ModelContext 默认绑定到 @MainActor
@MainActor
final class HistoryStore: ObservableObject {
    private let modelContext: ModelContext
    // ...
}

// ClipboardMonitor 在后台线程检测到变化后，
// 通过 Task { @MainActor in ... } 切换到主线程写入
private func checkForChanges() {
    // 在 monitorQueue（后台）执行
    guard let item = extractItem() else { return }
    Task { @MainActor in
        historyStore.addItem(item)
    }
}
```

---

## 模式 3：懒加载缩略图（Lazy Thumbnail）

**解决**: 内存 < 30MB 的需求（避免加载所有图片）

```swift
// ClipItemView 中仅在可见时计算缩略图
// SwiftUI List 的虚拟化机制自动处理离屏 Cell
var thumbnailImage: NSImage? {
    // 仅在 UI 请求时计算，不在模型初始化时预计算
    guard contentType == .image, let data = imageData else { return nil }
    return NSImage(data: data)?.resized(to: CGSize(width: 44, height: 44))
}
```

---

## 模式 4：防抖写回（Anti-bounce on Pasteboard Write）

**解决**: 用户选中记录写回剪切板时，避免触发 ClipboardMonitor 重复记录

```swift
// 方案：写回时暂停监听 + 延迟恢复（200ms 足够 changeCount 更新）
func selectItem(_ item: ClipboardItem) {
    clipboardMonitor.pauseMonitoring()
    writeToPasteboard(item)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        self.clipboardMonitor.resumeMonitoring()
    }
}
```

> 备选方案：BR-02 去重规则已可处理此情况（写回内容与刚选中的记录内容一致），
> 因此防抖暂停是双重保险，非强制必需。

---

## 模式 5：VersionedSchema（可迁移持久化）

**解决**: 未来 ClipboardItem 结构变更时数据不丢失

```swift
enum ClipSmartSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] = [ClipboardItem.self]
}

// 迁移计划（当前只有 V1，预留扩展）
let migrationPlan = SchemaMigrationPlan(
    schemas: [ClipSmartSchemaV1.self],
    stages: []
)
```

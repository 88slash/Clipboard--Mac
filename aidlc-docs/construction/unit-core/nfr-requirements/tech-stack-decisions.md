# 技术栈决策 — Unit 1: Core

| 技术选型 | 选择 | 理由 |
|---------|------|------|
| **持久化框架** | SwiftData | 原生支持 Swift Concurrency，@Model 宏简化模型定义，与 SwiftUI 深度集成 |
| **数据模型** | `@Model` 类 | SwiftData 要求，支持 Codable、关系映射 |
| **并发模型** | Swift Concurrency (async/await) | 类型安全，避免回调地狱，与 SwiftData actor 配合 |
| **内存监听** | `Timer` + `NSPasteboard.changeCount` | 最简单可靠的方案，无需事件监听 API（macOS 未提供剪切板变化通知） |
| **后台执行** | `DispatchQueue` (background QoS) | 轮询放在后台队列，主线程零压力 |
| **图片数据** | 原始 `Data` (tiff/png) | 避免格式转换损耗，SwiftData 原生支持 Binary |
| **搜索实现** | 内存过滤（`filter` + `localizedCaseInsensitiveContains`）| 200 条以内无需全文索引，内存过滤足够快 |
| **日志** | `os.Logger` (unified logging) | 系统原生，Console.app 可查看，Release 自动过滤 Debug 日志 |
| **错误处理** | `Result<T, Error>` + `do-catch` | 明确错误路径，避免静默失败 |

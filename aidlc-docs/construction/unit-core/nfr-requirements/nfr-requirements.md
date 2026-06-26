# NFR 需求 — Unit 1: Core

## 性能需求

| 需求 | 指标 | 测量方式 |
|------|------|---------|
| 后台 CPU 占用 | < 0.5%（空闲轮询时） | Instruments → Activity Monitor |
| 内存占用 | < 30MB（Core 层自身） | Instruments → Allocations |
| 写入延迟 | < 10ms（addItem 完成） | 代码计时 |
| 查询延迟 | < 20ms（200条全量查询）| 单元测试计时断言 |
| 搜索延迟 | < 30ms（200条全文搜索）| 单元测试计时断言 |
| 图片存储 | 单张图片 Data 写入 < 200ms | 单元测试计时断言 |
| 持久化恢复 | 应用冷启动，200条记录加载 < 500ms | 集成测试计时 |

## 可靠性需求

| 需求 | 规格 |
|------|------|
| NSPasteboard 访问失败 | 静默忽略，不崩溃，下次轮询重试 |
| SwiftData 写入失败 | 记录错误日志，内存中仍保留，下次启动重试 |
| 图片 Data 损坏 | 过滤该条记录，不影响其他条目 |
| 容量超限处理 | 确保 FIFO 淘汰原子操作，不出现竞态 |

## 并发安全需求

| 需求 | 规格 |
|------|------|
| 监听轮询线程 | 在专用后台 DispatchQueue 执行，不阻塞主线程 |
| SwiftData 写入 | 在 ModelContext 所属线程执行（@MainActor 或 background actor） |
| HistoryViewModel 更新 | 必须在主线程（@MainActor）触发 UI 更新 |

## 存储需求

| 需求 | 规格 |
|------|------|
| 最大存储容量估算 | 200条文本（~200KB）+ 图片（最多几十 MB，视用户复制量） |
| 存储位置 | ~/Library/Application Support/ClipSmart/（SwiftData 默认路径） |
| 数据迁移 | 预留 VersionedSchema 支持未来 Schema 迁移 |

## 可维护性需求

| 需求 | 规格 |
|------|------|
| 测试覆盖率 | Core 层核心逻辑 ≥ 80% |
| 日志级别 | Debug 模式：详细日志；Release 模式：仅 Error 级别 |

# 功能需求 → 开发单元映射 — ClipSmart

## 映射表

| 功能需求 | 主要单元 | 辅助单元 |
|----------|---------|---------|
| FR-01 剪切板监控 | **Unit 1 Core** | — |
| FR-02 历史记录管理（FIFO、固定、容量）| **Unit 1 Core** | Unit 3 AppShell（容量读取）|
| FR-03 多内容类型支持（文本/图片/文件）| **Unit 1 Core** | Unit 2 UI（缩略图渲染）|
| FR-04 全局唤醒快捷键 | **Unit 3 AppShell** | — |
| FR-05 UI 面板（Liquid Glass）| **Unit 2 UI** | Unit 3 AppShell（窗口托管）|
| FR-06 记录交互（单击复制/右键菜单）| **Unit 2 UI** | Unit 1 Core（写入 NSPasteboard）|
| FR-07 全文搜索 | **Unit 1 Core**（过滤逻辑）| Unit 2 UI（搜索栏 + 高亮）|
| FR-08 菜单栏 + Dock 双模式 | **Unit 3 AppShell** | — |
| FR-09 数据持久化 | **Unit 1 Core** | — |
| FR-10 偏好设置界面 | **Unit 3 AppShell** | — |

## 每单元完成标准

### Unit 1 完成标准
- [ ] ClipboardItem 模型可正确序列化/反序列化（SwiftData）
- [ ] ClipboardMonitor 能检测到剪切板变化并提取文本、图片、文件
- [ ] HistoryStore FIFO 淘汰逻辑正确（超限只删非固定记录）
- [ ] HistoryStore 固定/取消固定逻辑正确
- [ ] HistoryStore 持久化：重启后数据恢复
- [ ] HistoryViewModel 搜索过滤返回正确结果

### Unit 2 完成标准
- [ ] MainPanelView 在 SwiftUI Preview 中可正常渲染
- [ ] 列表正确区分固定区和普通区
- [ ] ClipItemView 文本显示截断预览，图片显示缩略图
- [ ] 搜索栏输入后列表实时过滤
- [ ] 右键菜单所有操作可正确触发
- [ ] 键盘导航（↑↓↩⌫）正常工作
- [ ] 深色/浅色模式自动适应

### Unit 3 完成标准
- [ ] 菜单栏图标正常显示，单击显示/隐藏面板
- [ ] 全局热键在任意应用下均可触发面板
- [ ] PanelWindowController 面板居中、圆角、无标题栏
- [ ] 面板点击外部区域自动关闭
- [ ] SettingsView 各项设置可读写并立即生效
- [ ] Dock 模式切换后重启仍保持所选模式
- [ ] 开机自启开关可正常注册/注销 SMAppService

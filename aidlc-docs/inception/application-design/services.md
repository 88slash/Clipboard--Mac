# 服务定义 — ClipSmart

## 服务架构概览

ClipSmart 采用面向服务的设计，核心业务逻辑封装在以下服务中：

```
┌──────────────────────────────────────────────┐
│              服务协调层                        │
│         ClipSmartApp (组合根)                 │
│    注入: HistoryStore, PreferencesStore       │
└──────────────┬───────────────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
    v                     v
┌─────────────┐    ┌──────────────────┐
│  Core 服务  │    │  AppShell 服务   │
│             │    │                  │
│ Clipboard   │    │  MenuBarManager  │
│ Monitor     │    │  HotkeyManager   │
│             │    │  PanelWindow     │
│ History     │    │  Controller      │
│ Store       │    │                  │
└─────────────┘    └──────────────────┘
```

---

## 服务详情

### ClipboardMonitor 服务

**职责**: 系统剪切板变化监听与内容提取

| 项目 | 内容 |
|------|------|
| **生命周期** | 应用启动时创建，随应用存活 |
| **实例策略** | 单例（通过环境注入） |
| **监听机制** | `Timer.scheduledTimer` + `NSPasteboard.changeCount` |
| **轮询间隔** | 500ms（可配置） |
| **内容提取优先级** | 1. 文件URL → 2. 图片 → 3. 富文本 → 4. 纯文本 |
| **去重判断** | 新内容与历史最新一条完全一致则跳过 |
| **输出** | 调用 `HistoryStore.addItem()` |

**监听流程:**
```
Timer 触发 → 读取 NSPasteboard.changeCount
    → 若与上次相同 → 忽略
    → 若已变化 → 提取内容 → 构建 ClipboardItem → 写入 HistoryStore
```

---

### HistoryStore 服务

**职责**: 历史记录的内存管理、持久化和 FIFO 策略执行

| 项目 | 内容 |
|------|------|
| **生命周期** | 应用启动时创建，随应用存活 |
| **实例策略** | 单例（通过 `@Environment(\.modelContext)` 注入） |
| **持久化** | SwiftData（`ModelContainer` 配置于 `ClipSmartApp`） |
| **内存缓存** | `@Query` 宏或手动 `fetch` 维护内存列表 |

**FIFO 淘汰规则:**
```
添加新记录时:
  1. 统计非固定记录数量 (regularCount)
  2. 若 regularCount >= maxHistoryCount (来自 PreferencesStore)
     → 找到 regularItems 中 timestamp 最早的记录
     → 删除该记录
  3. 插入新记录
  4. 固定记录永不参与淘汰
```

---

### HotkeyManager 服务

**职责**: 全局快捷键的注册、注销和回调分发

| 项目 | 内容 |
|------|------|
| **生命周期** | 应用启动时注册，退出时注销 |
| **实现方案** | [KeyboardShortcuts SPM 包](https://github.com/sindresorhus/KeyboardShortcuts) |
| **默认快捷键** | ⌘ + Shift + V |
| **更新时机** | 用户在 SettingsView 修改快捷键后，自动重新注册 |
| **回调** | 触发 `PanelWindowController.togglePanel()` |

**快捷键名称定义（扩展）:**
```swift
extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel")
}
```

---

### PanelWindowController 服务

**职责**: 浮动面板窗口的创建、定位和生命周期管理

| 项目 | 内容 |
|------|------|
| **窗口类型** | `NSPanel`（`.nonactivatingPanel` + `.hudWindow`） |
| **位置策略** | 屏幕中央，垂直方向偏上 1/3 处（仿 Spotlight） |
| **尺寸** | 宽 680pt，高自适应内容（最大 500pt） |
| **材质** | `NSVisualEffectView`（`.hudWindow` 或 `.sidebar`） |
| **关闭触发** | 点击面板外区域 / Esc 键 / 再次按热键 |
| **动画** | 显示: `scaleEffect(0.95→1) + opacity(0→1)`；隐藏: 反向 |

---

### MenuBarManager 服务

**职责**: 菜单栏图标和快捷菜单管理

| 项目 | 内容 |
|------|------|
| **图标** | SF Symbol `clipboard` 或自定义 SVG（16pt，Template 模式） |
| **左键单击** | 调用 `PanelWindowController.togglePanel()` |
| **右键菜单项** | 显示/隐藏面板 / 偏好设置 / 清空历史 / ── / 退出 |

---

### PreferencesStore 服务

**职责**: 用户配置的读写（UserDefaults via @AppStorage）

| 配置键 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `maxHistoryCount` | Int | 50 | 历史记录上限 |
| `showInDock` | Bool | false | 是否在 Dock 显示 |
| `launchAtLogin` | Bool | false | 开机自启 |
| `hotkeyName` | String | "togglePanel" | 当前绑定的快捷键名 |

**Dock 模式切换实现:**
```swift
// showInDock = true
NSApp.setActivationPolicy(.regular)
// showInDock = false
NSApp.setActivationPolicy(.accessory)
```

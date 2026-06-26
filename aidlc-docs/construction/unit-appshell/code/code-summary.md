# 代码摘要 — Unit 3: AppShell

## 生成文件列表

| 文件 | 位置 | 说明 |
|------|------|------|
| `ClipSmartApp.swift` | `ClipSmart/` | @main 入口，组合根，所有服务初始化 |
| `PanelWindowController.swift` | `ClipSmart/AppShell/` | NSPanel 浮动窗口，显示/隐藏/居中 |
| `HotkeyManager.swift` | `ClipSmart/AppShell/` | KeyboardShortcuts 全局热键注册 |
| `MenuBarManager.swift` | `ClipSmart/AppShell/` | NSStatusItem 菜单栏图标与菜单 |
| `PreferencesStore.swift` | `ClipSmart/AppShell/Settings/` | @AppStorage 用户配置读写 |
| `SettingsView.swift` | `ClipSmart/AppShell/Settings/` | TabView 设置面板（3个标签页） |
| `Info.plist` | `ClipSmart/Resources/` | 应用配置（LSUIElement, Bundle ID 等）|
| `ClipSmart.entitlements` | `ClipSmart/Resources/` | 权限声明（关闭沙盒，文件访问）|

## 关键实现要点

| 特性 | 实现方式 |
|------|---------|
| 菜单栏模式 | `LSUIElement=YES` + `NSApp.setActivationPolicy(.accessory)` |
| Dock 模式切换 | `NSApp.setActivationPolicy(.regular/.accessory)` |
| 浮动面板 | `NSPanel` + `.nonactivatingPanel` + `.borderless` |
| 点击外部关闭 | `NSWindow.didResignKeyNotification` |
| 入场动画 | `NSAnimationContext` + `alphaValue` 淡入淡出 |
| 全局热键 | `KeyboardShortcuts` SPM 包，默认 ⌘+Shift+V |
| 偏好设置 | SwiftUI `Settings` scene + `Form(.grouped)` + `Slider` |
| 开机自启 | `SMAppService`（macOS 13+，占位实现预留）|
| 组合根 | `ClipSmartApp.init()` 统一初始化所有服务，手动依赖注入 |

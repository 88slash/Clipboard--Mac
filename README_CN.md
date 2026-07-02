<div align="center">
  <img src="logo.png" alt="ClipSmart Logo" width="128" height="128" />
  <h1>ClipSmart</h1>
  <p><strong>轻量、原生的 macOS 剪切板管理器，基于 SwiftUI 构建。</strong></p>
  <p>Spotlight 风格浮动面板 · 持久化历史记录 · 全局快捷键 · Liquid Glass UI</p>

  <p>
    <img alt="macOS" src="https://img.shields.io/badge/macOS-14.0%2B-blue?logo=apple&logoColor=white" />
    <img alt="Swift" src="https://img.shields.io/badge/Swift-6.0-orange?logo=swift&logoColor=white" />
    <img alt="SwiftUI" src="https://img.shields.io/badge/UI-SwiftUI%20%2B%20AppKit-purple" />
    <img alt="Architecture" src="https://img.shields.io/badge/架构-MVVM-green" />
    <img alt="License" src="https://img.shields.io/badge/协议-MIT-lightgrey" />
    <img alt="Platform" src="https://img.shields.io/badge/平台-Apple%20Silicon%20%7C%20Intel-black?logo=apple" />
  </p>

  <p>
    <a href="README.md">English</a> · <strong>简体中文</strong>
  </p>
</div>

---

## 简介

ClipSmart 是一款完全原生的 macOS 剪切板管理器，常驻菜单栏，自动记录你复制过的一切内容——文本、富文本、图片和文件。按下快捷键唤出 Spotlight 风格的浮动面板，毫秒级定位目标，一键粘贴。

- **完全本地** — 无云同步、无遥测、无需网络连接
- **极低开销** — 后台空闲时 CPU 占用 < 0.5%，监控间隔 500 ms
- **原生 macOS 公民** — 基于 Swift 6、SwiftUI、SwiftData 构建，完整支持 Apple Silicon
- **macOS 26 液态玻璃** — 在 macOS 26+ 上自动使用原生 `glassEffect` API，低版本平稳回退至 `.ultraThinMaterial`

---

## 功能特性

### 剪切板捕获
- 在独立后台队列上**持续监控** `NSPasteboard`
- 支持**纯文本**、**富文本（RTF）**、**图片（PNG / TIFF）** 和**文件 URL**（Finder 复制）
- **自动去重** — 连续复制相同内容时静默忽略，不重复记录

### 历史记录管理
- 基于 **SwiftData 持久化存储** — 历史记录在重启应用或重启 Mac 后仍然保留
- 容量可配置，范围 **1 至 200 条**（默认 50 条），超限自动 FIFO 淘汰
- **固定记录** — 将任意条目置顶，不受容量淘汰影响
- **来源应用追踪** — 每条记录显示来自哪个 App
- **相对时间戳** — "刚刚"、"5 分钟前"、"昨天"

### 浮动面板
- 无标题栏、圆角设计，**Spotlight 风格窗口**（680 × 440 pt），居中显示
- 显示 / 隐藏带有流畅的 **弹簧动画**
- 点击面板外区域或再次按快捷键即可关闭
- macOS 26+ 使用 **液态玻璃材质**；macOS 14–25 使用 `ultraThinMaterial` 高斯模糊
- 完整支持**深色 / 浅色模式**，跟随系统外观

### 搜索与筛选
- 对所有文本和文件条目进行**实时全文搜索**
- **类型筛选标签** — 全部 / 文本 / 图片 / 文件
- **时间范围筛选** — 全部时间 / 今天 / 近 7 天 / 近 30 天
- 图片条目显示缩略图，文本条目显示前 120 字预览

### 键盘优先导航
| 按键 | 操作 |
|------|------|
| `↑` / `↓` | 上下浏览条目 |
| `↩ 回车` | 粘贴选中条目并关闭面板 |
| `⌫ 删除` | 删除选中条目 |
| `Esc` | 清空搜索 → 退出多选 → 关闭面板 |

### 全局触发
- **可自定义快捷键** — 默认 `⌘ ⇧ V`，通过原生 KeyboardShortcuts 录制控件设置
- **双击修饰键触发** — 支持 `⌘⌘`、`⌥⌥`、`⌃⌃` 或 `⇧⇧`（需要辅助功能权限）

### 多选与批量操作
- 从搜索栏切换到勾选模式
- **全选**快捷方式 + 带确认弹窗的批量删除
- 键盘友好：多选模式下 `↩` 可勾选 / 取消勾选当前条目

### 图片预览
- 点击图片缩略图，弹出全分辨率预览浮层
- 展示像素尺寸和文件大小

### 菜单栏集成
- 默认以**菜单栏应用**模式运行（不出现在 Dock）
- 可选**显示 Dock 图标** — 在「设置 → 通用」中切换
- 右键菜单栏图标可快速执行常用操作

### 偏好设置
| 标签页 | 选项 |
|--------|------|
| **通用** | 显示 Dock 图标 · 登录时自动启动 |
| **快捷键** | 全局热键录制 · 双击修饰键选择 · 辅助功能授权 |
| **存储** | 最大历史条数滑块 · 清空所有历史记录 |

---

## 环境要求

| | 最低版本 | 推荐版本 |
|---|---|---|
| **macOS** | 14.0（Sonoma） | 26.0（液态玻璃效果） |
| **Xcode** | 16.0 | 26.0 |
| **Swift** | 6.0 | 6.0 |
| **架构** | Apple Silicon (arm64) | Apple Silicon |

> 发行版构建同样支持 Intel (x86_64)。

---

## 安装

### 直接下载（推荐）

1. 前往 [Releases 页面](https://github.com/88slash/Clipboard--Mac/releases/latest) 下载最新的 `ClipSmart-x.x.x.dmg`
2. 打开 `.dmg` 文件，将 **ClipSmart** 拖入**应用程序（Applications）**文件夹
3. 推出磁盘镜像

### 首次启动 — macOS 安全拦截问题

由于 ClipSmart 未通过 Mac App Store 分发，macOS Gatekeeper 会在首次打开时拦截。这是正常现象，有三种方式可以解决：

**方式 A — 右键打开（最简单）**
> 右键点击（或按住 Control 点击）应用图标 → **打开** → 在弹出对话框中再次点击**打开**。

**方式 B — 系统设置**
> 被拦截后，前往**系统设置 → 隐私与安全性**，滚动到底部，点击 ClipSmart 旁边的**仍然打开**按钮。

**方式 C — 终端命令（最彻底）**
> 在终端执行以下命令一次，之后即可正常打开：
> ```bash
> xattr -cr /Applications/ClipSmart.app
> ```

以上操作只需做一次，此后每次启动均可正常打开。

---

## 使用说明

### 基本工作流

1. **启动应用** — ClipSmart 以菜单栏图标形式运行，启动后立即开始监控剪切板。
2. **复制任意内容** — 文本、图片、文件，ClipSmart 自动在后台记录。
3. **唤出面板** — 在任意应用中按下 **`⌘ ⇧ V`** 打开历史记录面板。
4. **选择条目** — 单击任意条目，内容写入剪切板并关闭面板，再按 **`⌘ V`** 正常粘贴即可。

### 面板快捷键

| 按键 | 操作 |
|------|------|
| `⌘ ⇧ V` | 唤出 / 关闭面板（默认，可自定义） |
| `↑` / `↓` | 上下浏览条目 |
| `↩ 回车` | 粘贴选中条目并关闭面板 |
| `⌫ 删除` | 删除选中条目 |
| `Esc` | 清空搜索 → 退出多选 → 关闭面板 |

### 使用技巧

- **固定常用内容** — 右键任意条目 → **固定**。固定的条目始终置顶，不会被自动淘汰。
- **搜索** — 面板打开时直接输入关键字，实时过滤结果。
- **按类型筛选** — 使用顶部标签只显示文本、图片或文件。
- **批量删除** — 点击搜索栏的多选图标，勾选要删除的条目，按删除键确认。
- **双击修饰键触发** — 在「设置 → 快捷键」中可启用 `⌘⌘` / `⌥⌥` / `⌃⌃` / `⇧⇧` 作为备用触发方式（需辅助功能权限）。
- **修改快捷键** — 打开「设置 → 快捷键」，点击录制控件，按下你想要的组合键即可。

### 系统权限

| 权限 | 何时需要 |
|------|----------|
| 无需任何权限 | 正常使用（复制到剪切板 + 手动 `⌘V`） |
| **辅助功能** | 仅在启用「双击修饰键触发」时需要 |

---

## 从源码构建

### 1. 克隆仓库

```bash
git clone https://github.com/YOUR_USERNAME/ClipSmart.git
cd ClipSmart
```

### 2. 安装依赖

```bash
# 安装 XcodeGen（项目文件生成工具）
brew install xcodegen
```

### 3. 生成 Xcode 项目

```bash
xcodegen generate
```

### 4. 打开并构建

```bash
open ClipSmart.xcodeproj
```

选择 **ClipSmart** Scheme，按 `⌘R` 构建并运行。

> **注意：** 应用启用了 Hardened Runtime 并关闭了 App Sandbox（支持全局热键所必需）。打包分发前，需在 `project.yml` 中填写你的 Apple Development Team ID。

### 运行测试

```bash
swift test
# 或在 Xcode 中按 ⌘U
```

---

## 项目结构

```
ClipSmart/
├── ClipSmartApp.swift              # @main 入口 & AppDelegate
├── AppShell/
│   ├── AppServices.swift           # 单例 DI 容器，管理应用生命周期
│   ├── DoubleTapMonitor.swift      # 双击修饰键检测（NSEvent）
│   ├── HotkeyManager.swift         # 全局热键（KeyboardShortcuts）
│   ├── MenuBarManager.swift        # NSStatusItem 及右键菜单
│   ├── PanelWindowController.swift # NSPanel 承载 SwiftUI 浮动面板
│   └── Settings/
│       ├── PreferencesStore.swift  # @Observable，UserDefaults 持久化设置
│       ├── SettingsView.swift      # TabView：通用 / 快捷键 / 存储
│       └── SettingsWindowController.swift
├── Core/
│   ├── Models/
│   │   ├── ClipboardItem.swift     # @Model（SwiftData），所有内容类型
│   │   └── ClipboardItemType.swift # 枚举：plainText / richText / image / fileURLs
│   ├── Services/
│   │   ├── ClipboardMonitor.swift  # 500ms NSPasteboard 轮询
│   │   └── HistoryStore.swift      # SwiftData CRUD，FIFO 淘汰，固定，去重
│   └── ViewModels/
│       └── HistoryViewModel.swift  # 筛选 / 搜索 / 选择 / 粘贴逻辑
├── UI/
│   ├── MainPanelView.swift         # 根视图 680×440，玻璃面板修饰符
│   ├── ClipItemView.swift          # 列表行：图标、预览、来源应用、时间戳
│   ├── ClipListView.swift          # 可滚动条目列表
│   ├── FilterBarView.swift         # 类型标签 + 时间筛选菜单
│   ├── SearchBarView.swift         # 搜索框 + 条目计数 + 多选开关
│   ├── BulkActionBarView.swift     # 全选 / 批量删除操作栏
│   ├── PinnedSectionView.swift     # 固定条目区域
│   ├── EmptyStateView.swift        # 空状态 / 无结果占位视图
│   └── ImagePreviewView.swift      # 全分辨率图片预览浮层
└── Resources/
    ├── Assets.xcassets             # 应用图标及颜色资产
    ├── Info.plist
    └── ClipSmart.entitlements
ClipSmartTests/
└── CoreTests/                      # Core 层单元测试
```

---

## 架构设计

ClipSmart 采用整洁的 **MVVM** 架构，数据单向流动：

```
NSPasteboard
     │  500ms 轮询
     ▼
ClipboardMonitor  ──────────▶  HistoryStore（SwiftData）
                                     │
                                     │ onChange 回调
                                     ▼
                             HistoryViewModel
                           （筛选 / 搜索 / 选择）
                                     │
                                     ▼
                              MainPanelView（SwiftUI）
```

`AppServices` 是顶层依赖注入容器，负责组装所有服务并管理其生命周期。它是 `@MainActor` 单例，确保所有 UI 更新始终在主线程上发生。

**关键设计决策：**
- `ClipboardMonitor` 在 `.utility` QoS 的独立 `DispatchQueue` 上轮询，通过 `Task` 将结果派发回 `@MainActor`
- `HistoryStore` 标注 `@Observable` 和 `@MainActor`，以 `allItems` 作为唯一数据源
- `HistoryViewModel` 纯内存执行筛选和搜索，无需额外的 SwiftData fetch descriptor
- 浮动面板是 `NSPanel` 的子类（`KeyablePanel`），可接收键盘事件，同时不抢占前台应用的焦点

---

## 依赖

| 包 | 用途 | 协议 |
|----|------|------|
| [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) | 全局热键录制与响应 | MIT |

其余所有功能均使用 Apple 原生框架：`AppKit`、`SwiftUI`、`SwiftData`、`ApplicationServices`。

---

## 隐私说明

ClipSmart **不会**：
- 向任何服务器上传数据
- 需要网络连接
- 收集分析数据或崩溃报告
- 在应用本地容器以外存储任何数据

唯一可能申请的系统权限是**辅助功能（Accessibility）** — 且仅在用户在「设置 → 快捷键」中主动启用双击修饰键触发时才会申请。

---

## 参与贡献

欢迎提交 Issue 和 Pull Request。贡献流程如下：

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/my-feature`
3. 提交更改：`git commit -m 'Add some feature'`
4. 推送分支：`git push origin feature/my-feature`
5. 发起 Pull Request

提交代码前，请确保：
- 在 Swift 6 严格并发下编译无错误（`SWIFT_STRICT_CONCURRENCY = complete`）
- 通过所有现有单元测试（`swift test`）
- 遵循现有 MVVM 结构 — UI 逻辑保留在 ViewModel 层，持久化逻辑保留在 Store 层

---

## 支持项目

ClipSmart 完全免费开源。如果它帮你节省了时间，或让日常工作流顺畅了一点，欢迎请我喝杯咖啡——这对项目的持续维护有很大的鼓励。

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="docs/wechat-donate.jpg" alt="微信赞赏" width="200" />
        <br />
        <sub>微信赞赏</sub>
      </td>
      <td width="60"></td>
      <td align="center">
        <img src="docs/alipay-donate.jpg" alt="支付宝收款" width="200" />
        <br />
        <sub>支付宝</sub>
      </td>
    </tr>
  </table>
  <p><sub>金额随意，心意已到。感谢你的支持 ♥</sub></p>
</div>

---

## 开源协议

ClipSmart 基于 [MIT 协议](LICENSE) 开源发布。

---

<div align="center">
  <sub>使用 Swift & SwiftUI 用心构建 · 仅支持 macOS</sub>
</div>

# 开发单元定义 — ClipSmart

## 项目结构（Xcode 目录布局）

```
ClipSmart/                              ← Xcode 项目根目录
├── ClipSmart.xcodeproj/
├── ClipSmart/                          ← 主 Target 源码
│   ├── ClipSmartApp.swift              ← @main 入口
│   ├── Core/                           ← Unit 1
│   │   ├── Models/
│   │   │   ├── ClipboardItem.swift
│   │   │   └── ClipboardItemType.swift
│   │   ├── Services/
│   │   │   ├── ClipboardMonitor.swift
│   │   │   └── HistoryStore.swift
│   │   └── ViewModels/
│   │       └── HistoryViewModel.swift
│   ├── UI/                             ← Unit 2
│   │   ├── MainPanelView.swift
│   │   ├── SearchBarView.swift
│   │   ├── ClipListView.swift
│   │   ├── PinnedSectionView.swift
│   │   ├── ClipItemView.swift
│   │   └── EmptyStateView.swift
│   ├── AppShell/                       ← Unit 3
│   │   ├── ClipSmartApp+Setup.swift
│   │   ├── MenuBarManager.swift
│   │   ├── HotkeyManager.swift
│   │   ├── PanelWindowController.swift
│   │   └── Settings/
│   │       ├── SettingsView.swift
│   │       └── PreferencesStore.swift
│   └── Resources/
│       ├── Assets.xcassets
│       └── Info.plist
├── ClipSmartTests/                     ← 单元测试
│   ├── CoreTests/
│   │   ├── ClipboardItemTests.swift
│   │   ├── HistoryStoreTests.swift
│   │   └── ClipboardMonitorTests.swift
│   └── ViewModelTests/
│       └── HistoryViewModelTests.swift
└── Package.swift (或 SPM 依赖在 Xcode project settings 中)
```

---

## Unit 1 — Core（核心层）

### 基本信息
| 项目 | 内容 |
|------|------|
| **单元名称** | Core |
| **目录** | `ClipSmart/Core/` |
| **开发顺序** | 第 1 个（其他单元依赖此单元） |
| **部署模型** | 作为主 Target 的一部分，非独立模块 |

### 职责范围
- 定义 `ClipboardItem` 数据模型（SwiftData `@Model`）
- 实现 `ClipboardMonitor` — NSPasteboard 监听与内容提取
- 实现 `HistoryStore` — 历史记录集合管理、FIFO 淘汰、持久化
- 实现 `HistoryViewModel` — 数据过滤、搜索、UI 操作代理

### 包含文件
| 文件 | 组件 |
|------|------|
| `Core/Models/ClipboardItem.swift` | ClipboardItem 模型 |
| `Core/Models/ClipboardItemType.swift` | 内容类型枚举 |
| `Core/Services/ClipboardMonitor.swift` | 剪切板监听服务 |
| `Core/Services/HistoryStore.swift` | 历史记录仓库 |
| `Core/ViewModels/HistoryViewModel.swift` | 视图模型 |

### 外部依赖
- `SwiftData`（系统框架）
- `AppKit`（NSPasteboard）

### 测试覆盖
- `ClipboardItemTests` — 模型构建、预览文本、缩略图
- `HistoryStoreTests` — FIFO 淘汰、固定记录、持久化、去重
- `ClipboardMonitorTests` — 内容提取、去重判断（Mock NSPasteboard）
- `HistoryViewModelTests` — 搜索过滤、pinnedItems/regularItems 分组

---

## Unit 2 — UI（界面层）

### 基本信息
| 项目 | 内容 |
|------|------|
| **单元名称** | UI |
| **目录** | `ClipSmart/UI/` |
| **开发顺序** | 第 2 个（依赖 Core 的 HistoryViewModel） |
| **部署模型** | 作为主 Target 的一部分 |

### 职责范围
- 实现主浮动面板视图（macOS 26 Liquid Glass 风格）
- 实现历史记录滚动列表（固定区 + 普通区）
- 实现实时搜索输入框
- 实现单条记录渲染（文本预览 / 图片缩略图）
- 实现右键上下文菜单
- 实现键盘导航（↑↓ 选择、↩ 复制、⌫ 删除）
- 实现空状态视图

### 包含文件
| 文件 | 组件 |
|------|------|
| `UI/MainPanelView.swift` | 根面板视图 |
| `UI/SearchBarView.swift` | 搜索栏 |
| `UI/ClipListView.swift` | 普通记录列表 |
| `UI/PinnedSectionView.swift` | 固定记录区域 |
| `UI/ClipItemView.swift` | 单条记录 + 右键菜单 |
| `UI/EmptyStateView.swift` | 无记录时空状态 |

### 外部依赖
- `Core`（HistoryViewModel, ClipboardItem）
- `SwiftUI`
- `AppKit`（NSImage 缩略图）

### 视觉规范
- 背景：`NSVisualEffectView` 或 SwiftUI `.ultraThinMaterial`
- 圆角：16pt
- 宽度：680pt 固定，高度自适应（最大 520pt）
- 内边距：16pt
- 记录间距：6pt
- 色彩跟随系统深/浅模式自动切换

---

## Unit 3 — AppShell（应用外壳层）

### 基本信息
| 项目 | 内容 |
|------|------|
| **单元名称** | AppShell |
| **目录** | `ClipSmart/AppShell/` |
| **开发顺序** | 第 3 个（依赖 Core + UI） |
| **部署模型** | 作为主 Target 的一部分 |

### 职责范围
- `@main` 应用入口与 SwiftData 容器初始化
- 菜单栏图标与快捷菜单管理
- 全局热键注册与回调（KeyboardShortcuts SPM）
- `NSPanel` 浮动窗口创建与生命周期
- 偏好设置界面与配置持久化（@AppStorage）
- Dock 模式切换
- 开机自启（SMAppService）

### 包含文件
| 文件 | 组件 |
|------|------|
| `ClipSmartApp.swift` | @main 入口 + 场景配置 |
| `AppShell/ClipSmartApp+Setup.swift` | 服务初始化扩展 |
| `AppShell/MenuBarManager.swift` | 菜单栏管理 |
| `AppShell/HotkeyManager.swift` | 全局热键管理 |
| `AppShell/PanelWindowController.swift` | 浮动窗口控制 |
| `AppShell/Settings/SettingsView.swift` | 偏好设置界面 |
| `AppShell/Settings/PreferencesStore.swift` | 配置存储 |

### 外部依赖
- `Core`（HistoryStore, PreferencesStore）
- `UI`（MainPanelView）
- `KeyboardShortcuts`（SPM 包，[sindresorhus/KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)）
- `ServiceManagement`（SMAppService，开机自启）
- `AppKit`（NSPanel, NSStatusItem）

---

## 构建配置

| 配置项 | 值 |
|--------|-----|
| **Bundle ID** | `com.clipsmart.app` |
| **最低 macOS 版本** | macOS 14.0（SwiftData 要求） |
| **目标架构** | Universal（arm64 + x86_64） |
| **Sandbox** | 关闭（需要全局热键权限） |
| **LSUIElement** | YES（默认无 Dock 图标） |
| **代码签名** | 开发阶段使用 Developer ID（分发 .dmg） |

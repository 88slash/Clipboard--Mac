# 组件定义 — ClipSmart

## 架构概览

ClipSmart 采用 **MVVM + 分层架构**，分为三层：

```
┌─────────────────────────────────────────────────┐
│                 AppShell 层 (Unit 3)             │
│  ClipSmartApp · MenuBarManager · HotkeyManager  │
│  PanelWindowController · SettingsView           │
├─────────────────────────────────────────────────┤
│                   UI 层 (Unit 2)                │
│  MainPanelView · ClipListView · ClipItemView    │
│  SearchBarView · PinnedSectionView              │
├─────────────────────────────────────────────────┤
│                  Core 层 (Unit 1)               │
│  ClipboardMonitor · HistoryStore                │
│  ClipboardItem · HistoryViewModel               │
└─────────────────────────────────────────────────┘
```

---

## Unit 1 — Core 层

### 1.1 ClipboardItem（数据模型）
| 属性 | 说明 |
|------|------|
| **类型** | SwiftData `@Model` 类 |
| **职责** | 表示一条剪切板历史记录，持有内容、类型、元数据 |
| **核心属性** | id, contentType, textContent, imageData, fileURLs, timestamp, isPinned, sourceApp |

**支持的内容类型（ClipboardItemType 枚举）：**
- `plainText` — 纯文本
- `richText` — 富文本（RTF/HTML）
- `image` — 图片（PNG/JPEG/TIFF）
- `fileURLs` — 文件引用路径列表

---

### 1.2 ClipboardMonitor（剪切板监听服务）
| 属性 | 说明 |
|------|------|
| **类型** | `ObservableObject` / `@Observable` 单例服务 |
| **职责** | 轮询 `NSPasteboard`，检测新内容并提取结构化数据 |
| **监听策略** | 定时轮询（默认间隔 0.5s），通过 `changeCount` 判断内容变化 |
| **依赖** | `HistoryStore`（写入新记录） |

---

### 1.3 HistoryStore（历史记录仓库）
| 属性 | 说明 |
|------|------|
| **类型** | `@Observable` 单例服务 |
| **职责** | 管理历史记录集合（内存 + 持久化），实现 FIFO 淘汰和固定逻辑 |
| **持久化** | SwiftData（`ModelContainer` + `ModelContext`） |
| **FIFO 规则** | 仅淘汰非固定记录；固定记录不计入容量上限的淘汰候选 |

---

### 1.4 HistoryViewModel（历史记录视图模型）
| 属性 | 说明 |
|------|------|
| **类型** | `@Observable` 类 |
| **职责** | 为 UI 层提供过滤/搜索后的记录列表，处理用户操作指令 |
| **持有** | `HistoryStore` 引用，`searchQuery` 状态 |
| **输出** | `pinnedItems: [ClipboardItem]`、`regularItems: [ClipboardItem]` |

---

## Unit 2 — UI 层

### 2.1 MainPanelView（主面板视图）
| 属性 | 说明 |
|------|------|
| **类型** | SwiftUI `View` |
| **职责** | 浮动面板的根视图，组合搜索栏 + 固定区 + 记录列表 |
| **视觉** | macOS 26 Liquid Glass 材质（`.ultraThinMaterial`），圆角，无标题栏 |
| **动画** | 弹簧动画入场/离场（`.spring(duration: 0.3)`） |

---

### 2.2 SearchBarView（搜索栏）
| 属性 | 说明 |
|------|------|
| **类型** | SwiftUI `View` |
| **职责** | 接收用户输入，实时更新 `HistoryViewModel.searchQuery` |
| **行为** | 面板打开时自动聚焦；Esc 清除搜索或关闭面板 |

---

### 2.3 ClipListView（记录列表）
| 属性 | 说明 |
|------|------|
| **类型** | SwiftUI `View` |
| **职责** | 虚拟化滚动列表，渲染普通历史记录 |
| **支持** | 键盘导航（↑↓ 选择，↩ 复制，Delete 删除） |

---

### 2.4 PinnedSectionView（固定区域）
| 属性 | 说明 |
|------|------|
| **类型** | SwiftUI `View` |
| **职责** | 在列表顶部展示固定记录，视觉上与普通记录区分 |
| **显示条件** | 仅当有固定记录时显示 |

---

### 2.5 ClipItemView（单条记录视图）
| 属性 | 说明 |
|------|------|
| **类型** | SwiftUI `View` |
| **职责** | 渲染单条 ClipboardItem，按内容类型展示文本预览或图片缩略图 |
| **交互** | 单击 → 写入剪切板 + 关闭面板；右键 → 上下文菜单 |

---

### 2.6 ClipItemContextMenu（右键菜单）
| 属性 | 说明 |
|------|------|
| **类型** | SwiftUI `contextMenu` modifier |
| **职责** | 提供「仅复制」「固定/取消固定」「删除」操作 |

---

## Unit 3 — AppShell 层

### 3.1 ClipSmartApp（应用入口）
| 属性 | 说明 |
|------|------|
| **类型** | `@main` SwiftUI `App` |
| **职责** | 应用启动入口，初始化 SwiftData 容器，注入环境依赖 |
| **窗口策略** | `Settings` scene + 无主窗口（LSUIElement = true） |

---

### 3.2 MenuBarManager（菜单栏管理器）
| 属性 | 说明 |
|------|------|
| **类型** | `NSObject` + `NSStatusItem` 封装 |
| **职责** | 管理菜单栏图标，处理图标单击（显示/隐藏面板）和右键菜单 |
| **菜单项** | 显示面板 / 偏好设置 / 分隔线 / 退出 |

---

### 3.3 HotkeyManager（热键管理器）
| 属性 | 说明 |
|------|------|
| **类型** | `@Observable` 类，封装 `KeyboardShortcuts` SPM 包 |
| **职责** | 注册全局快捷键，响应唤醒/关闭面板事件 |
| **依赖** | [KeyboardShortcuts](https://github.com/nicklockwood/KeyboardShortcuts)（或等效实现） |

---

### 3.4 PanelWindowController（面板窗口控制器）
| 属性 | 说明 |
|------|------|
| **类型** | `NSWindowController` 子类，持有 `NSPanel` |
| **职责** | 创建无标题栏浮动面板，控制显示/隐藏/位置居中逻辑 |
| **窗口特性** | `NSPanel` + `.nonactivatingPanel`，点击外部自动关闭 |

---

### 3.5 SettingsView（偏好设置视图）
| 属性 | 说明 |
|------|------|
| **类型** | SwiftUI `View`，通过 `Settings` scene 呈现 |
| **职责** | 用户配置界面（快捷键录制、容量滑块、模式切换、清空历史） |

---

### 3.6 PreferencesStore（偏好设置存储）
| 属性 | 说明 |
|------|------|
| **类型** | `@Observable` 类，使用 `@AppStorage` |
| **职责** | 读写用户偏好（快捷键配置、最大容量、Dock 显示模式、开机启动） |

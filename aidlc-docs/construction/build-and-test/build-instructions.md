# 构建指南 — ClipSmart

## 前置条件

| 工具 | 版本 | 安装方式 |
|------|------|---------|
| **Xcode** | 16.0+ | Mac App Store |
| **macOS** | 14.0+（开发）/ 26.0+（完整 Liquid Glass 体验）| — |
| **Swift** | 6.0+ | 随 Xcode 附带 |
| **xcodegen** | 2.40+ | `brew install xcodegen` |
| **Apple Developer Account** | 免费账户即可本地运行 | developer.apple.com |

---

## 步骤 1：生成 Xcode 项目

```bash
# 进入项目根目录
cd "/Users/a17269/Desktop/project/Clipboard- Mac"

# 使用 xcodegen 从 project.yml 生成 .xcodeproj
xcodegen generate
```

生成后目录中会出现 `ClipSmart.xcodeproj`。

---

## 步骤 2：打开 Xcode 并配置签名

```bash
open ClipSmart.xcodeproj
```

在 Xcode 中：
1. 点击左侧 `ClipSmart` 项目 → **Signing & Capabilities** 标签页
2. 选择你的 **Team**（Apple ID 登录后可见个人团队）
3. 确认 Bundle Identifier 为 `com.clipsmart.app`（或改为你自己的）

---

## 步骤 3：验证 SPM 依赖已加载

打开后 Xcode 会自动拉取 `KeyboardShortcuts` 包（需联网）。
若未自动加载：**File → Packages → Resolve Package Versions**

---

## 步骤 4：构建项目

```
快捷键: ⌘ + B（Build）
或: Product → Build
```

**预期输出**: Build Succeeded，无错误（可能有少量弃用警告可忽略）

---

## 步骤 5：首次运行

```
快捷键: ⌘ + R（Run）
或: Product → Run
```

首次运行会：
1. 应用以菜单栏模式启动（Dock 中无图标）
2. 在顶部状态栏出现剪切板图标
3. 按 **⌘+Shift+V** 唤出面板（若被其他应用占用请先去设置中修改快捷键）

---

## 步骤 6：打包 .dmg（分发）

安装打包工具：
```bash
brew install create-dmg
```

Archive 并导出：
1. Xcode → **Product → Archive**
2. 选择 **Direct Distribution** 或 **Developer ID**
3. 导出 .app 后执行：

```bash
create-dmg \
  --volname "ClipSmart" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "ClipSmart.app" 175 190 \
  --hide-extension "ClipSmart.app" \
  --app-drop-link 425 190 \
  "ClipSmart-1.0.0.dmg" \
  "path/to/exported/ClipSmart.app"
```

---

## 常见问题

| 问题 | 解决方案 |
|------|---------|
| 全局热键不生效 | 检查 `ClipSmart.entitlements` 中 `ENABLE_APP_SANDBOX` 是否为 `NO` |
| KeyboardShortcuts 找不到 | File → Packages → Resolve Package Versions |
| App 在 Dock 中显示 | 检查 `Info.plist` 的 `LSUIElement` 是否为 `YES` |
| SwiftData 报错 | 确认 deployment target 为 macOS 14.0+ |
| `.glassBackground` 编译报错 | 将 deployment target 改为 macOS 26.0+，或用 `#available` 包裹 |

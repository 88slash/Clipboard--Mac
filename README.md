<div align="center">
  <img src="logo.png" alt="ClipSmart Logo" width="128" height="128" />
  <h1>ClipSmart</h1>
  <p><strong>A lightweight, native macOS clipboard manager built with SwiftUI.</strong></p>
  <p>Spotlight-style floating panel · Persistent history · Global hotkey · Liquid Glass UI</p>

  <p>
    <img alt="macOS" src="https://img.shields.io/badge/macOS-14.0%2B-blue?logo=apple&logoColor=white" />
    <img alt="Swift" src="https://img.shields.io/badge/Swift-6.0-orange?logo=swift&logoColor=white" />
    <img alt="SwiftUI" src="https://img.shields.io/badge/UI-SwiftUI%20%2B%20AppKit-purple" />
    <img alt="Architecture" src="https://img.shields.io/badge/Architecture-MVVM-green" />
    <img alt="License" src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <img alt="Platform" src="https://img.shields.io/badge/Platform-Apple%20Silicon%20%7C%20Intel-black?logo=apple" />
  </p>

  <p>
    <strong>English</strong> · <a href="README_CN.md">简体中文</a>
  </p>
</div>

---

## Overview

ClipSmart is a fully native macOS clipboard manager that lives in your menu bar and remembers everything you copy — text, rich text, images, and files. Bring up a Spotlight-style panel with a single hotkey, find what you need in milliseconds, and paste it right back.

- **100% local** — no cloud sync, no telemetry, no internet connection required
- **Zero overhead** — runs at < 0.5% CPU idle with a background polling interval of 500 ms
- **First-class macOS citizen** — built with Swift 6, SwiftUI, SwiftData, and full Apple Silicon support
- **macOS 26 Liquid Glass** — the panel automatically uses the native `glassEffect` API on macOS 26+, with graceful `.ultraThinMaterial` fallback on earlier releases

---

## Features

### Clipboard Capture
- **Continuous monitoring** of `NSPasteboard` on a dedicated background queue
- Supports **plain text**, **rich text (RTF)**, **images (PNG / TIFF)**, and **file URLs** (Finder copies)
- **Automatic deduplication** — consecutive identical copies are silently ignored

### History Management
- **Persistent storage** via SwiftData — history survives app restarts and reboots
- Configurable capacity from **1 to 200 items** (default: 50) with FIFO eviction
- **Pin items** to keep them at the top, exempt from eviction
- **Source app tracking** — each item shows which app it came from
- **Relative timestamps** — "just now", "5 minutes ago", "yesterday"

### Floating Panel
- Borderless, rounded, **Spotlight-style window** (680 × 440 pt), centered on screen
- Smooth **spring animation** on show / hide
- Click outside to dismiss, or press the hotkey again
- **Liquid Glass material** on macOS 26+; `ultraThinMaterial` blur on macOS 14–25
- Fully supports **Light / Dark mode** (follows system appearance)

### Search & Filters
- **Real-time full-text search** across all text and file items
- **Type filter chips** — All / Text / Image / Files
- **Time range filter** — All time / Today / Last 7 days / Last 30 days
- Image items display thumbnails; text items show a 120-character preview

### Keyboard-First Navigation
| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate items |
| `↩ Return` | Paste selected item and close panel |
| `⌫ Delete` | Delete selected item |
| `Esc` | Clear search → exit multi-select → close panel |

### Global Triggers
- **Customizable hotkey** — default `⌘ ⇧ V`, recorded via native KeyboardShortcuts UI
- **Double-tap modifier key** — trigger with `⌘⌘`, `⌥⌥`, `⌃⌃`, or `⇧⇧` (requires Accessibility permission)

### Multi-Select & Bulk Actions
- Toggle checklist mode from the search bar
- **Select All** shortcut and bulk delete with confirmation dialog
- Keyboard-friendly: `↩` checks/unchecks the focused item in multi-select mode

### Image Preview
- Click the image thumbnail to open a full-resolution popover
- Displays pixel dimensions and file size

### Menu Bar Integration
- Runs as a **menu bar app** by default (no Dock icon)
- Optional **Dock icon** — toggled in Settings → General
- Right-click the menu bar icon for quick actions

### Settings
| Tab | Options |
|-----|---------|
| **General** | Show Dock icon · Launch at login |
| **Shortcuts** | Global hotkey recorder · Double-tap modifier picker · Accessibility grant |
| **Storage** | Max history count slider · Clear all history |

---

## Requirements

| | Minimum | Recommended |
|---|---|---|
| **macOS** | 14.0 (Sonoma) | 26.0 (for Liquid Glass) |
| **Xcode** | 16.0 | 26.0 |
| **Swift** | 6.0 | 6.0 |
| **Architecture** | Apple Silicon (arm64) | Apple Silicon |

> Intel (x86_64) is also supported for distribution builds.

---

## Installation

### Download (Recommended)

1. Go to the [Releases](https://github.com/88slash/Clipboard--Mac/releases/latest) page and download `ClipSmart-x.x.x.dmg`
2. Open the `.dmg` file and drag **ClipSmart** into your **Applications** folder
3. Eject the disk image

### First Launch — macOS Security Warning

Because ClipSmart is not distributed through the Mac App Store, macOS Gatekeeper will block it on the first open. This is expected. There are three ways to get past it:

**Option A — Right-click to open (easiest)**
> Right-click (or Control-click) the app icon → **Open** → click **Open** in the dialog that appears.

**Option B — System Settings**
> After the blocked launch attempt, go to **System Settings → Privacy & Security**, scroll to the bottom, and click **Open Anyway** next to the ClipSmart entry.

**Option C — Terminal (most reliable)**
> Run the following command once, then launch the app normally:
> ```bash
> xattr -cr /Applications/ClipSmart.app
> ```

You only need to do this once. The app opens normally on every subsequent launch.

---

## Usage

### Basic Workflow

1. **Launch** — ClipSmart starts in your menu bar (look for the clipboard icon `⊞`). It begins monitoring your clipboard immediately.
2. **Copy anything** — text, images, files. ClipSmart captures it automatically in the background.
3. **Open the panel** — Press **`⌘ ⇧ V`** from any app to bring up the history panel.
4. **Pick an item** — Click any item to write it to the clipboard and close the panel, then paste with **`⌘ V`** as usual.

### Panel Shortcuts

| Key | Action |
|-----|--------|
| `⌘ ⇧ V` | Toggle panel (default, customizable) |
| `↑` / `↓` | Navigate items |
| `↩ Return` | Paste selected item & close |
| `⌫ Delete` | Delete selected item |
| `Esc` | Clear search → exit multi-select → close |

### Tips

- **Pin frequently-used items** — right-click any item → **Pin**. Pinned items stay at the top and are never auto-deleted.
- **Search** — start typing with the panel open to instantly filter by content.
- **Filter by type** — use the chips at the top to show only Text, Images, or Files.
- **Bulk delete** — click the multi-select icon in the search bar, check what you want to remove, then hit Delete.
- **Double-tap trigger** — in Settings → Shortcuts, you can enable `⌘⌘` / `⌥⌥` / `⌃⌃` / `⇧⇧` as an alternative trigger (requires Accessibility permission).
- **Change the hotkey** — open Settings → Shortcuts, click the recorder, press your preferred combination.

### Permissions

| Permission | When Required |
|------------|--------------|
| None | Normal use (copy to clipboard + manual `⌘V`) |
| **Accessibility** | Only if you enable the double-tap modifier key trigger |

---

## Building from Source

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/ClipSmart.git
cd ClipSmart
```

### 2. Install dependencies

```bash
# Install XcodeGen (project file generator)
brew install xcodegen
```

### 3. Generate the Xcode project

```bash
xcodegen generate
```

### 4. Open and build

```bash
open ClipSmart.xcodeproj
```

Then select the **ClipSmart** scheme and press `⌘R` to build and run.

> **Note:** The app requires **Hardened Runtime** and runs without App Sandbox to support global hotkeys. You will need to set your Apple Development Team ID in `project.yml` before archiving for distribution.

### Running Tests

```bash
swift test
# or via Xcode: ⌘U
```

---

## Project Structure

```
ClipSmart/
├── ClipSmartApp.swift              # @main entry point & AppDelegate
├── AppShell/
│   ├── AppServices.swift           # Singleton DI container, lifecycle management
│   ├── DoubleTapMonitor.swift      # Double-tap modifier key detection (NSEvent)
│   ├── HotkeyManager.swift         # Global hotkey via KeyboardShortcuts
│   ├── MenuBarManager.swift        # NSStatusItem & context menu
│   ├── PanelWindowController.swift # NSPanel hosting the SwiftUI panel view
│   └── Settings/
│       ├── PreferencesStore.swift  # @Observable UserDefaults-backed settings
│       ├── SettingsView.swift      # TabView: General / Shortcuts / Storage
│       └── SettingsWindowController.swift
├── Core/
│   ├── Models/
│   │   ├── ClipboardItem.swift     # @Model (SwiftData) — all content types
│   │   └── ClipboardItemType.swift # Enum: plainText / richText / image / fileURLs
│   ├── Services/
│   │   ├── ClipboardMonitor.swift  # 500ms NSPasteboard polling
│   │   └── HistoryStore.swift      # SwiftData CRUD, FIFO eviction, pin, dedup
│   └── ViewModels/
│       └── HistoryViewModel.swift  # Filter / search / selection / paste logic
├── UI/
│   ├── MainPanelView.swift         # Root 680×440 panel, glass modifier
│   ├── ClipItemView.swift          # List row: icon, preview, source app, timestamp
│   ├── ClipListView.swift          # Scrollable item list
│   ├── FilterBarView.swift         # Type chips + time filter menu
│   ├── SearchBarView.swift         # Search field + item count + multi-select toggle
│   ├── BulkActionBarView.swift     # Select all / bulk delete bar
│   ├── PinnedSectionView.swift     # Pinned items section
│   ├── EmptyStateView.swift        # Empty / no-results placeholder
│   └── ImagePreviewView.swift      # Full-resolution image popover
└── Resources/
    ├── Assets.xcassets             # App icon & color assets
    ├── Info.plist
    └── ClipSmart.entitlements
ClipSmartTests/
└── CoreTests/                      # Unit tests for Core layer
```

---

## Architecture

ClipSmart follows a clean **MVVM** architecture with a unidirectional data flow:

```
NSPasteboard
     │  500ms poll
     ▼
ClipboardMonitor  ──────────▶  HistoryStore (SwiftData)
                                     │
                                     │ onChange callback
                                     ▼
                             HistoryViewModel
                           (filter / search / selection)
                                     │
                                     ▼
                              MainPanelView (SwiftUI)
```

`AppServices` is the top-level dependency injection container that wires all services together and manages their lifecycle. It is a `@MainActor` singleton to ensure UI updates always happen on the main thread.

**Key design decisions:**
- `ClipboardMonitor` polls on a dedicated `DispatchQueue` with `.utility` QoS and dispatches results back to `@MainActor` via `Task`
- `HistoryStore` is `@Observable` and `@MainActor`, exposing `allItems` as a single source of truth
- `HistoryViewModel` applies filters/search purely in-memory — no secondary fetch descriptors
- The floating panel is an `NSPanel` subclass (`KeyablePanel`) so it can receive keyboard events without stealing focus from the frontmost app

---

## Dependencies

| Package | Purpose | License |
|---------|---------|---------|
| [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) | Global hotkey recording & handling | MIT |

All other functionality uses Apple-native frameworks: `AppKit`, `SwiftUI`, `SwiftData`, `ApplicationServices`.

---

## Privacy

ClipSmart does **not**:
- Upload any data to any server
- Require a network connection
- Collect analytics or crash reports
- Store any data outside the app's local container

The only system permission optionally requested is **Accessibility** — and only when the user explicitly enables the double-tap modifier key trigger in Settings.

---

## Contributing

Contributions are welcome. To get started:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

Please make sure your code:
- Compiles cleanly with Swift 6 strict concurrency (`SWIFT_STRICT_CONCURRENCY = complete`)
- Passes all existing unit tests (`swift test`)
- Follows the existing MVVM structure — UI logic stays in ViewModels, persistence stays in the Store layer

---

## Support the Project

ClipSmart is free and open source. If it saves you time or makes your workflow a little smoother, consider buying me a coffee — it genuinely helps keep the project going.

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="docs/wechat-donate.jpg" alt="WeChat Pay" width="200" />
        <br />
        <sub>WeChat Pay</sub>
      </td>
      <td width="60"></td>
      <td align="center">
        <img src="docs/alipay-donate.jpg" alt="Alipay" width="200" />
        <br />
        <sub>Alipay</sub>
      </td>
    </tr>
  </table>
  <p><sub>Any amount is appreciated. Thank you for your support ♥</sub></p>
</div>

---

## License

ClipSmart is released under the [MIT License](LICENSE).

---

<div align="center">
  <sub>Built with ♥ using Swift & SwiftUI · macOS only</sub>
</div>

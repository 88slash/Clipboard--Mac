import SwiftUI
import SwiftData

/// 应用级服务容器 — 统一初始化和启动所有服务
/// 使用单例确保 AppDelegate 和 SwiftUI Scene 共享同一份服务
@MainActor
final class AppServices {

    // MARK: - Singleton（懒初始化，首次访问时自动创建，线程安全）
    @MainActor static let shared = AppServices()

    // MARK: - Services

    let modelContainer: ModelContainer
    let preferences: PreferencesStore
    let historyStore: HistoryStore
    let clipboardMonitor: ClipboardMonitor
    let viewModel: HistoryViewModel
    let panelController: PanelWindowController
    let hotkeyManager: HotkeyManager
    let menuBarManager: MenuBarManager
    let settingsController: SettingsWindowController
    let doubleTapMonitor: DoubleTapMonitor

    // MARK: - Init（仅构建，不启动）

    init() {
        // 1. 持久化容器
        self.modelContainer = {
            do { return try ModelContainer(for: ClipboardItem.self) }
            catch { fatalError("ModelContainer init failed: \(error)") }
        }()

        // 2. 偏好设置
        let prefs = PreferencesStore()
        self.preferences = prefs

        // 3. 核心服务
        let store = HistoryStore(modelContext: modelContainer.mainContext, preferences: prefs)
        self.historyStore = store

        let mon = ClipboardMonitor(historyStore: store)
        self.clipboardMonitor = mon

        let vm = HistoryViewModel(historyStore: store, clipboardMonitor: mon)
        self.viewModel = vm

        // 4. AppShell 服务
        let panel = PanelWindowController(viewModel: vm)
        self.panelController = panel

        self.hotkeyManager = HotkeyManager { @Sendable [weak panel] in
            DispatchQueue.main.async { panel?.togglePanel() }
        }
        self.menuBarManager = MenuBarManager(panelController: panel, historyStore: store)
        self.settingsController = SettingsWindowController(preferences: prefs, historyStore: store)
        self.doubleTapMonitor = DoubleTapMonitor { [weak panel] in panel?.togglePanel() }
    }

    // MARK: - Lifecycle

    /// 在 applicationDidFinishLaunching 后调用
    func start() {
        // Dock / 菜单栏模式
        let showInDock = preferences.showInDock
        NSApp.setActivationPolicy(showInDock ? .regular : .accessory)

        // 菜单栏图标
        menuBarManager.setup()
        menuBarManager.onOpenSettings = { [weak self] in
            self?.settingsController.showSettings()
        }

        // 全局热键注册
        hotkeyManager.register()

        // 双击修饰键触发（按存储的偏好启用）
        applyDoubleTap()

        // 剪切板监听
        clipboardMonitor.startMonitoring()
    }

    /// 读取偏好并应用双击修饰键设置（静默，不弹权限框）
    func applyDoubleTap() {
        let modifier = DoubleTapMonitor.Modifier(rawValue: preferences.doubleTapModifier) ?? .none
        doubleTapMonitor.apply(modifier)
    }

    func stop() {
        clipboardMonitor.stopMonitoring()
        hotkeyManager.unregister()
    }
}

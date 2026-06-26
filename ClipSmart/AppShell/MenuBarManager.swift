import AppKit

@MainActor
final class MenuBarManager {
    private var statusItem: NSStatusItem?
    private let panelController: PanelWindowController
    private let historyStore: HistoryStore

    /// 外部注入的设置回调，由 AppServices 设置
    var onOpenSettings: (() -> Void)?

    init(panelController: PanelWindowController, historyStore: HistoryStore) {
        self.panelController = panelController
        self.historyStore = historyStore
    }

    func setup() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let btn = item.button {
            btn.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "ClipSmart")
            btn.image?.isTemplate = true
            btn.action = #selector(statusItemClicked(_:))
            btn.target = self
            btn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        statusItem = item
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp { showContextMenu() }
        else { panelController.togglePanel() }
    }

    private func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "显示 ClipSmart",    action: #selector(showPanel),    keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "偏好设置…",          action: #selector(openSettings), keyEquivalent: ",").target = self
        menu.addItem(withTitle: "清空历史记录…",      action: #selector(clearHistory), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "退出 ClipSmart",    action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func showPanel()    { panelController.showPanel() }
    @objc private func openSettings() { onOpenSettings?() }

    @objc private func clearHistory() {
        let alert = NSAlert()
        alert.messageText = "清空所有历史记录"
        alert.informativeText = "此操作不可撤销。"
        alert.addButton(withTitle: "清空")
        alert.addButton(withTitle: "取消")
        alert.alertStyle = .warning
        alert.buttons.first?.hasDestructiveAction = true
        if alert.runModal() == .alertFirstButtonReturn { historyStore.clearAll() }
    }
}

import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {

    init(preferences: PreferencesStore, historyStore: HistoryStore) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 320),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "ClipSmart 偏好设置"
        window.isReleasedWhenClosed = false

        // 关键：确保 NSHostingView 可以成为 first responder，让键盘事件正确送达
        let hosting = NSHostingView(
            rootView: SettingsView()
                .environment(preferences)
                .environment(historyStore)
        )
        hosting.translatesAutoresizingMaskIntoConstraints = false
        window.contentView = hosting

        if let cv = window.contentView {
            NSLayoutConstraint.activate([
                hosting.topAnchor.constraint(equalTo: cv.topAnchor),
                hosting.bottomAnchor.constraint(equalTo: cv.bottomAnchor),
                hosting.leadingAnchor.constraint(equalTo: cv.leadingAnchor),
                hosting.trailingAnchor.constraint(equalTo: cv.trailingAnchor),
            ])
        }

        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func showSettings() {
        // 菜单栏 App 是 .accessory，必须先切到 .regular 才能让窗口成为 key window
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()

        // 二次确保：菜单 tracking 结束后再激活一次，保证窗口真正成为 key（否则键盘事件不送达）
        DispatchQueue.main.async { [weak self] in
            NSApp.activate(ignoringOtherApps: true)
            self?.window?.makeKeyAndOrderFront(nil)
            self?.window?.makeFirstResponder(self?.window?.contentView)
        }
    }

    // 设置窗口关闭时恢复菜单栏 App 模式
    func windowWillClose(_ notification: Notification) {
        let showInDock = UserDefaults.standard.bool(forKey: "showInDock")
        if !showInDock {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

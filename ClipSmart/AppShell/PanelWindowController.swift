import AppKit
import SwiftUI

@MainActor
final class PanelWindowController: NSWindowController {

    private var isVisible = false
    private let panelWidth:  CGFloat = 680
    private let panelHeight: CGFloat = 440
    private var keyMonitor: Any?   // 本地键盘事件监听器

    // MARK: - Init

    init(viewModel: HistoryViewModel) {
        let panel = KeyablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 680, height: 440),
            styleMask: [.borderless, .nonactivatingPanel, .hudWindow, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .modalPanel
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = false

        super.init(window: panel)

        // 关键：让 NSHostingView 完全填满 panel，不受初始 frame 限制
        let hosting = NSHostingView(
            rootView: MainPanelView().environment(viewModel)
        )
        hosting.translatesAutoresizingMaskIntoConstraints = false
        panel.contentView = hosting

        // 自动布局：hosting 撑满整个 panel
        if let cv = panel.contentView {
            NSLayoutConstraint.activate([
                hosting.topAnchor.constraint(equalTo: cv.topAnchor),
                hosting.bottomAnchor.constraint(equalTo: cv.bottomAnchor),
                hosting.leadingAnchor.constraint(equalTo: cv.leadingAnchor),
                hosting.trailingAnchor.constraint(equalTo: cv.trailingAnchor),
            ])
        }

        viewModel.onRequestClose = { [weak self] in
            Task { @MainActor in self?.hidePanel() }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResignKey),
            name: NSWindow.didResignKeyNotification,
            object: panel
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public API

    func togglePanel() { isVisible ? hidePanel() : showPanel() }

    func showPanel() {
        guard let panel = window else { return }

        panel.setContentSize(NSSize(width: panelWidth, height: panelHeight))
        centerOnScreen()
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        panel.makeKey()
        isVisible = true

        // 注册本地键盘监听：ESC 关闭面板
        if keyMonitor == nil {
            keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self else { return event }
                if event.keyCode == 53 { // ESC
                    self.hidePanel()
                    return nil          // 消费事件，不传递给系统
                }
                return event
            }
        }

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }

        NSApp.activate(ignoringOtherApps: true)
    }

    func hidePanel() {
        guard let panel = window, isVisible else { return }
        isVisible = false

        // 注销键盘监听
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }) {
            panel.orderOut(nil)
            panel.alphaValue = 1
        }
    }

    // MARK: - Private

    private func centerOnScreen() {
        guard let panel = window, let screen = NSScreen.main else { return }
        let sf = screen.visibleFrame
        let x  = sf.midX - panelWidth / 2
        let y  = sf.minY + sf.height * 0.6 - panelHeight / 2
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    @objc private func windowDidResignKey(_ notification: Notification) {
        hidePanel()
    }
}

/// 可成为 key window 的浮动面板
/// 默认 borderless + nonactivatingPanel 的 NSPanel 无法成为 key window，
/// 导致内部 SwiftUI 搜索框无法获得键盘焦点、ESC 无法响应。重写以下属性即可修复。
final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

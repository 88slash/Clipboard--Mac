import AppKit
import ApplicationServices

/// 双击修饰键监听器 — 检测「短时间内连按两次同一修饰键」（如 ⌥⌥）
/// 需要辅助功能(Accessibility)权限才能全局生效
@MainActor
final class DoubleTapMonitor {

    enum Modifier: String, CaseIterable, Identifiable {
        case none, command, option, control, shift
        var id: String { rawValue }
        var display: String {
            switch self {
            case .none:    return "关闭"
            case .command: return "⌘⌘"
            case .option:  return "⌥⌥"
            case .control: return "⌃⌃"
            case .shift:   return "⇧⇧"
            }
        }
        var flag: NSEvent.ModifierFlags? {
            switch self {
            case .none:    return nil
            case .command: return .command
            case .option:  return .option
            case .control: return .control
            case .shift:   return .shift
            }
        }
    }

    private let onTrigger: () -> Void
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var target: NSEvent.ModifierFlags?
    private var lastTap: TimeInterval = 0
    private var wasDown = false
    private let interval: TimeInterval = 0.35   // 两次按下的最大间隔

    init(onTrigger: @escaping () -> Void) { self.onTrigger = onTrigger }
}

extension DoubleTapMonitor {

    /// 应用某个修饰键设置；none 表示关闭监听
    func apply(_ modifier: Modifier) {
        stop()
        guard let flag = modifier.flag else { return }
        target = flag
        start()
    }

    /// 是否已获得辅助功能权限（静默检查，不弹框）
    nonisolated static var isTrusted: Bool { AXIsProcessTrusted() }

    /// 显式申请辅助功能权限（会弹系统引导框）—— 仅在用户点击「去授权」时调用
    @discardableResult
    nonisolated static func ensureAccessibilityPermission() -> Bool {
        // kAXTrustedCheckOptionPrompt 的字符串值，避免 Swift 6 并发安全告警
        let promptKey = "AXTrustedCheckOptionPrompt"
        return AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)
    }

    private func start() {
        // 全局监听（其他 App 在前台时也能触发，需辅助功能权限）
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
            DispatchQueue.main.async { [weak self] in self?.handle(event) }
        }
        // 本地监听（本 App 前台时触发，无需权限）
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handle(event)
            return event
        }
    }

    private func stop() {
        if let m = globalMonitor { NSEvent.removeMonitor(m); globalMonitor = nil }
        if let m = localMonitor  { NSEvent.removeMonitor(m); localMonitor = nil }
        wasDown = false
        lastTap = 0
    }

    private func handle(_ event: NSEvent) {
        guard let target else { return }
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let isDown = flags.contains(target)

        if isDown && !wasDown {
            // 按下边沿：要求只按了目标修饰键（排除 ⌘⌥ 这类组合）
            if flags == target {
                let now = event.timestamp
                if now - lastTap < interval {
                    lastTap = 0
                    onTrigger()
                } else {
                    lastTap = now
                }
            } else {
                lastTap = 0
            }
        }
        wasDown = isDown
    }
}

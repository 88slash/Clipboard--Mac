import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel", default: .init(.v, modifiers: [.command, .shift]))
}

/// 全局热键管理器
/// 注意：handler 只注册一次。用户在录制控件里改快捷键后，
/// KeyboardShortcuts 会自动把新组合键绑定到这个 handler，无需重注册。
final class HotkeyManager {
    private let onToggle: @Sendable () -> Void

    init(onToggle: @Sendable @escaping () -> Void) {
        self.onToggle = onToggle
    }

    func register() {
        let toggle = onToggle
        KeyboardShortcuts.onKeyUp(for: .togglePanel) { toggle() }
    }

    func unregister() { KeyboardShortcuts.disable(.togglePanel) }
}

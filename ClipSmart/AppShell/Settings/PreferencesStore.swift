import Foundation
import AppKit
import Observation
#if canImport(ClipSmartCore)
import ClipSmartCore
#endif

/// 用户偏好设置存储
/// 关键：必须用**存储属性** + didSet 同步 UserDefaults
/// @Observable 只追踪存储属性，计算属性不会触发 SwiftUI 重绘
@Observable
final class PreferencesStore {

    private enum Keys {
        static let maxHistoryCount   = "maxHistoryCount"
        static let showInDock        = "showInDock"
        static let launchAtLogin     = "launchAtLogin"
        static let doubleTapModifier = "doubleTapModifier"
    }

    // MARK: - 存储属性（@Observable 可以追踪）

    var maxHistoryCount: Int {
        didSet {
            let clamped = max(1, min(200, maxHistoryCount))
            if maxHistoryCount != clamped { maxHistoryCount = clamped }
            UserDefaults.standard.set(clamped, forKey: Keys.maxHistoryCount)
        }
    }

    var showInDock: Bool {
        didSet {
            UserDefaults.standard.set(showInDock, forKey: Keys.showInDock)
            applyDockPolicy(showInDock)
        }
    }

    var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin)
        }
    }

    /// 双击修饰键触发（存 DoubleTapMonitor.Modifier 的 rawValue，默认 none）
    var doubleTapModifier: String {
        didSet {
            UserDefaults.standard.set(doubleTapModifier, forKey: Keys.doubleTapModifier)
        }
    }

    // MARK: - Init（从 UserDefaults 恢复）

    init() {
        let saved = UserDefaults.standard.integer(forKey: Keys.maxHistoryCount)
        self.maxHistoryCount = saved == 0 ? 50 : max(1, min(200, saved))
        self.showInDock      = UserDefaults.standard.bool(forKey: Keys.showInDock)
        self.launchAtLogin   = UserDefaults.standard.bool(forKey: Keys.launchAtLogin)
        self.doubleTapModifier = UserDefaults.standard.string(forKey: Keys.doubleTapModifier) ?? "none"
    }

    // MARK: - Actions

    func resetToDefaults() {
        maxHistoryCount = 50
        showInDock      = false
        launchAtLogin   = false
    }

    // MARK: - Private

    private func applyDockPolicy(_ show: Bool) {
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(show ? .regular : .accessory)
        }
    }
}

extension PreferencesStore: HistoryStoreConfiguration {}

// MARK: - Binding 辅助

extension Int {
    /// 供 Slider 直接绑定 Int 存储属性使用
    var double: Double {
        get { Double(self) }
        set { self = Int(newValue) }
    }
}

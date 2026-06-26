import SwiftUI
import SwiftData
import KeyboardShortcuts

struct SettingsView: View {
    @Environment(PreferencesStore.self) private var preferences
    @Environment(HistoryStore.self) private var historyStore

    var body: some View {
        TabView {
            GeneralSettingsTab(prefs: preferences)
                .tabItem { Label("通用", systemImage: "gear") }
            ShortcutsSettingsTab(prefs: preferences)
                .tabItem { Label("快捷键", systemImage: "keyboard") }
            StorageSettingsTab(prefs: preferences, historyStore: historyStore)
                .tabItem { Label("存储", systemImage: "internaldrive") }
        }
        .frame(width: 480, height: 300)
    }
}

// MARK: - 通用

private struct GeneralSettingsTab: View {
    @Bindable var prefs: PreferencesStore
    var body: some View {
        Form {
            Section("外观") { Toggle("在 Dock 中显示图标", isOn: $prefs.showInDock) }
            Section("启动") { Toggle("登录时自动启动",    isOn: $prefs.launchAtLogin) }
        }
        .formStyle(.grouped).padding(.top, 8)
    }
}

// MARK: - 快捷键

private struct ShortcutsSettingsTab: View {
    @Bindable var prefs: PreferencesStore
    @State private var trusted = DoubleTapMonitor.isTrusted

    var body: some View {
        Form {
            Section("快捷键") {
                KeyboardShortcuts.Recorder("呼出 / 隐藏面板：", name: .togglePanel)
                Text("点击右侧区域后按下组合键（需含 ⌘ / ⌥ / ⌃ / ⇧）")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("双击修饰键") {
                Picker("双击唤醒", selection: $prefs.doubleTapModifier) {
                    ForEach(DoubleTapMonitor.Modifier.allCases) { m in
                        Text(m.display).tag(m.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: prefs.doubleTapModifier) { _, _ in
                    AppServices.shared.applyDoubleTap()
                    trusted = DoubleTapMonitor.isTrusted     // 静默刷新，不弹框
                }

                // 仅当启用双击且未授权时，才显示授权入口（绝不自动弹框）
                if prefs.doubleTapModifier != "none" {
                    if trusted {
                        Label("辅助功能权限已授予", systemImage: "checkmark.circle.fill")
                            .font(.caption).foregroundStyle(.green)
                    } else {
                        HStack {
                            Label("尚未授予辅助功能权限", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption).foregroundStyle(.orange)
                            Spacer()
                            Button("去授权") { DoubleTapMonitor.ensureAccessibilityPermission() }
                            Button("刷新") {
                                trusted = DoubleTapMonitor.isTrusted
                                AppServices.shared.applyDoubleTap()  // 重装监听，授权后立即生效
                            }
                        }
                        Text("连按两次所选修饰键唤醒（如 ⌥⌥）。授权后点「刷新」确认状态。")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .formStyle(.grouped).padding(.top, 8)
        .onAppear { trusted = DoubleTapMonitor.isTrusted }
    }
}

// MARK: - 存储

private struct StorageSettingsTab: View {
    @Bindable var prefs: PreferencesStore
    let historyStore: HistoryStore
    @State private var showClearConfirm = false

    var body: some View {
        Form {
            Section("历史记录") {
                HStack {
                    Text("最大保留条数")
                    Spacer()
                    Text("\(prefs.maxHistoryCount) 条")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                // 不用 step（macOS 上 step 会渲染刻度线 = 那条白条）；在 setter 里取整
                Slider(
                    value: Binding(
                        get: { Double(prefs.maxHistoryCount) },
                        set: { prefs.maxHistoryCount = Int($0.rounded()) }
                    ),
                    in: 1...200
                )
                HStack {
                    Text("1").font(.caption2).foregroundStyle(.tertiary)
                    Spacer()
                    Text("200").font(.caption2).foregroundStyle(.tertiary)
                }
            }
            Section("数据管理") {
                Button(role: .destructive) { showClearConfirm = true } label: {
                    Label("清空所有历史记录…", systemImage: "trash")
                }
                .confirmationDialog("清空所有历史记录", isPresented: $showClearConfirm, titleVisibility: .visible) {
                    Button("清空", role: .destructive) { historyStore.clearAll() }
                    Button("取消", role: .cancel) {}
                } message: {
                    Text("此操作不可撤销，所有剪切板历史将被永久删除。")
                }
            }
        }
        .formStyle(.grouped).padding(.top, 8)
    }
}

import SwiftUI
import SwiftData

@main
struct ClipSmartApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environment(AppServices.shared.preferences)
                .environment(AppServices.shared.historyStore)
        }
    }
}

// MARK: - AppDelegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // AppServices.shared 已被 SwiftUI body 懒创建，这里直接 start()
        AppServices.shared.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppServices.shared.stop()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        AppServices.shared.panelController.showPanel()
        return false
    }
}

// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ClipSmartCore",
    platforms: [.macOS(.v14)],
    targets: [
        .target(
            name: "ClipSmartCore",
            path: "ClipSmart/Core"
        ),
        .target(
            name: "ClipSmartPrefs",
            dependencies: ["ClipSmartCore"],
            path: "ClipSmart/AppShell/Settings",
            sources: ["PreferencesStore.swift"]
        ),
        .testTarget(
            name: "ClipSmartCoreTests",
            dependencies: ["ClipSmartCore", "ClipSmartPrefs"],
            path: "ClipSmartTests/CoreTests"
        )
    ]
)

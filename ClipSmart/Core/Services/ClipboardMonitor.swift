import Foundation
import AppKit
import os

final class ClipboardMonitor {
    struct ItemSnapshot: Sendable {
        let contentType: ClipboardItemType
        let textContent: String?
        let imageData: Data?
        let fileURLStrings: [String]
        let timestamp: Date
        let sourceApp: String?
        func toClipboardItem() -> ClipboardItem {
            ClipboardItem(contentType: contentType, textContent: textContent,
                          imageData: imageData, fileURLStrings: fileURLStrings,
                          timestamp: timestamp, sourceApp: sourceApp)
        }
    }

    private let historyStore: HistoryStore
    private let logger = Logger(subsystem: "com.clipsmart.app", category: "ClipboardMonitor")
    private var timerSource: DispatchSourceTimer?
    private var lastChangeCount: Int
    private var isPaused = false
    private let monitorQueue = DispatchQueue(label: "com.clipsmart.clipboard-monitor", qos: .utility)

    init(historyStore: HistoryStore) {
        self.historyStore = historyStore
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    func startMonitoring() {
        guard timerSource == nil else { return }
        let source = DispatchSource.makeTimerSource(queue: monitorQueue)
        source.schedule(deadline: .now() + .milliseconds(500), repeating: .milliseconds(500))
        source.setEventHandler { [weak self] in self?.checkForChanges() }
        source.resume()
        timerSource = source
    }

    func stopMonitoring() { timerSource?.cancel(); timerSource = nil }
    func pauseMonitoring() { isPaused = true }
    func resumeMonitoring() { lastChangeCount = NSPasteboard.general.changeCount; isPaused = false }

    private func checkForChanges() {
        guard !isPaused else { return }
        let pb = NSPasteboard.general
        let cur = pb.changeCount
        guard cur != lastChangeCount else { return }
        lastChangeCount = cur
        guard let snapshot = extractSnapshot(from: pb) else { return }
        let store = historyStore
        Task { @MainActor in store.addItem(snapshot.toClipboardItem()) }
    }

    func extractSnapshot(from pb: NSPasteboard) -> ItemSnapshot? {
        let app = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        let now = Date()
        let types = pb.types ?? []

        // 1) 仅识别真正的「文件 URL」(Finder 复制的文件)
        if let urls = pb.readObjects(forClasses: [NSURL.self],
                                     options: [.urlReadingFileURLsOnly: true]) as? [URL], !urls.isEmpty {
            return ItemSnapshot(contentType: .fileURLs, textContent: nil, imageData: nil,
                                fileURLStrings: urls.map { $0.absoluteString }, timestamp: now, sourceApp: app)
        }

        // 判断剪切板上是否同时存在文本
        let hasText = types.contains(.string) || types.contains(.rtf) || types.contains(.html)
        // 判断是否存在图片数据
        let hasImage = types.contains(.png) || types.contains(.tiff)

        // 2) 如果有文本内容 → 优先当文本（很多 app 复制文本时会附带 TIFF 渲染图，必须跳过）
        if hasText {
            // 富文本
            if let d = pb.data(forType: .rtf),
               let s = NSAttributedString(rtf: d, documentAttributes: nil)?.string, !s.isEmpty {
                return ItemSnapshot(contentType: .richText, textContent: s, imageData: nil,
                                    fileURLStrings: [], timestamp: now, sourceApp: app)
            }
            // 纯文本
            if let t = pb.string(forType: .string), !t.isEmpty {
                return ItemSnapshot(contentType: .plainText, textContent: t, imageData: nil,
                                    fileURLStrings: [], timestamp: now, sourceApp: app)
            }
        }

        // 3) 纯图片（没有文本伴随）
        if hasImage {
            if let d = pb.data(forType: .png), !d.isEmpty {
                return ItemSnapshot(contentType: .image, textContent: nil, imageData: d,
                                    fileURLStrings: [], timestamp: now, sourceApp: app)
            }
            if let d = pb.data(forType: .tiff), !d.isEmpty {
                return ItemSnapshot(contentType: .image, textContent: nil, imageData: d,
                                    fileURLStrings: [], timestamp: now, sourceApp: app)
            }
        }

        // 4) 兜底：任何纯文本
        if let t = pb.string(forType: .string), !t.isEmpty {
            return ItemSnapshot(contentType: .plainText, textContent: t, imageData: nil,
                                fileURLStrings: [], timestamp: now, sourceApp: app)
        }

        return nil
    }
}

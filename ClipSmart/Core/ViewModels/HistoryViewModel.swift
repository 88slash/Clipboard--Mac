import Foundation
import AppKit
import Observation

@MainActor
@Observable
final class HistoryViewModel {

    // MARK: - 筛选类型

    enum TypeFilter: String, CaseIterable, Identifiable {
        case all, text, image, files
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: return "全部"; case .text: return "文本"
            case .image: return "图片"; case .files: return "文件"
            }
        }
    }

    enum TimeFilter: String, CaseIterable, Identifiable {
        case all, today, week, month
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: return "全部时间"; case .today: return "今天"
            case .week: return "近 7 天"; case .month: return "近 30 天"
            }
        }
        var cutoff: Date? {
            let cal = Calendar.current
            switch self {
            case .all:   return nil
            case .today: return cal.startOfDay(for: Date())
            case .week:  return cal.date(byAdding: .day, value: -7,  to: Date())
            case .month: return cal.date(byAdding: .day, value: -30, to: Date())
            }
        }
    }

    var searchQuery: String = ""
    var typeFilter: TypeFilter = .all
    var timeFilter: TimeFilter = .all
    var onRequestClose: (() -> Void)?

    private let historyStore: HistoryStore
    private let clipboardMonitor: ClipboardMonitor

    init(historyStore: HistoryStore, clipboardMonitor: ClipboardMonitor) {
        self.historyStore = historyStore
        self.clipboardMonitor = clipboardMonitor
    }

    var pinnedItems: [ClipboardItem]  { filtered(historyStore.pinnedItems) }
    var regularItems: [ClipboardItem] { filtered(historyStore.regularItems) }
    var isEmpty: Bool   { historyStore.allItems.isEmpty }
    var hasSearchResults: Bool { !pinnedItems.isEmpty || !regularItems.isEmpty }
    var totalCount: Int { historyStore.allItems.count }

    /// 当前是否处于「筛选/搜索」状态（用于区分"无结果"与"无历史"）
    var isFiltering: Bool {
        !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty || typeFilter != .all || timeFilter != .all
    }

    func selectItem(_ item: ClipboardItem) {
        clipboardMonitor.pauseMonitoring()
        writeToPasteboard(item)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.clipboardMonitor.resumeMonitoring()
        }
        onRequestClose?()
    }

    func deleteItem(_ item: ClipboardItem) { historyStore.deleteItem(item) }
    func togglePin(_ item: ClipboardItem)  { historyStore.togglePin(item) }
    func clearAll()                        { historyStore.clearAll() }
    func clearSearch()                     { searchQuery = "" }

    private func filtered(_ items: [ClipboardItem]) -> [ClipboardItem] {
        var result = items

        // 1) 类型筛选
        switch typeFilter {
        case .all:   break
        case .text:  result = result.filter { $0.contentType == .plainText || $0.contentType == .richText }
        case .image: result = result.filter { $0.contentType == .image }
        case .files: result = result.filter { $0.contentType == .fileURLs }
        }

        // 2) 时间筛选
        if let cutoff = timeFilter.cutoff {
            result = result.filter { $0.timestamp >= cutoff }
        }

        // 3) 文本搜索
        let q = searchQuery.trimmingCharacters(in: .whitespaces)
        if !q.isEmpty {
            result = result.filter { item in
                switch item.contentType {
                case .plainText, .richText: return item.textContent?.localizedCaseInsensitiveContains(q) ?? false
                case .image:    return false
                case .fileURLs: return item.displayPreview.localizedCaseInsensitiveContains(q)
                }
            }
        }
        return result
    }

    private func writeToPasteboard(_ item: ClipboardItem) {
        let pb = NSPasteboard.general
        pb.clearContents()
        switch item.contentType {
        case .plainText, .richText:
            if let t = item.textContent { pb.setString(t, forType: .string) }
        case .image:
            if let d = item.imageData { pb.setData(d, forType: .tiff) }
        case .fileURLs:
            pb.writeObjects(item.fileURLs as [NSURL])
        }
    }
}

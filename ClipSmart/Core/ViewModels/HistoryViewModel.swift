import Foundation
import AppKit
import Observation

@MainActor
@Observable
final class HistoryViewModel {

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

    // 展示用的【存储属性】—— 直接 mutate 它们一定会触发 SwiftUI 刷新（不依赖跨对象的传递式观察）
    private(set) var pinnedItems: [ClipboardItem] = []
    private(set) var regularItems: [ClipboardItem] = []
    private(set) var totalCount: Int = 0

    // MARK: - 批量选择（勾选删除）

    /// 是否处于「多选」模式
    var isSelecting: Bool = false {
        didSet { if !isSelecting { selectedIDs.removeAll() } }
    }
    /// 当前勾选的记录 id 集合
    var selectedIDs: Set<UUID> = []

    /// 当前是否勾选了指定记录
    func isChecked(_ item: ClipboardItem) -> Bool { selectedIDs.contains(item.id) }

    /// 切换单条记录的勾选状态
    func toggleChecked(_ item: ClipboardItem) {
        if selectedIDs.contains(item.id) { selectedIDs.remove(item.id) }
        else { selectedIDs.insert(item.id) }
    }

    /// 全选当前可见记录（固定 + 普通，已按筛选/搜索过滤）
    func selectAllVisible() {
        selectedIDs = Set((pinnedItems + regularItems).map { $0.id })
    }

    /// 取消全选
    func deselectAll() { selectedIDs.removeAll() }

    /// 删除所有勾选的记录
    func deleteSelected() {
        let all = pinnedItems + regularItems
        let toDelete = all.filter { selectedIDs.contains($0.id) }
        historyStore.deleteItems(toDelete)
        selectedIDs.removeAll()
        isSelecting = false
    }

    /// 进入/退出多选模式
    func toggleSelectingMode() { isSelecting.toggle() }

    /// 删除确认框是否打开。提升到这里（而不是行内 @State），
    /// 让 PanelWindowController（AppKit 层）能感知到 confirmationDialog 正在显示，
    /// 从而不把它抢占的 key window 状态误判成"用户要关闭整个面板"。
    var isShowingDeleteConfirm: Bool = false

    /// 当前正在预览图片的记录 id（nil 表示没有预览弹窗打开）
    /// 提升到这里而不是行内 @State，是为了让 PanelWindowController（AppKit 层）
    /// 也能感知预览状态，从而正确区分「预览弹窗抢占焦点」和「用户真的要关闭面板」。
    var previewingItemID: UUID? {
        didSet {
            // 预览从"开着"变成"关闭"时，通知面板重新拿回键盘焦点
            if oldValue != nil && previewingItemID == nil {
                onPreviewDismissed?()
            }
        }
    }
    @ObservationIgnored var onPreviewDismissed: (() -> Void)?

    var searchQuery: String = "" { didSet { refresh() } }
    var typeFilter: TypeFilter = .all { didSet { refresh() } }
    var timeFilter: TimeFilter = .all { didSet { refresh() } }
    @ObservationIgnored var onRequestClose: (() -> Void)?

    @ObservationIgnored private let historyStore: HistoryStore
    @ObservationIgnored private let clipboardMonitor: ClipboardMonitor

    init(historyStore: HistoryStore, clipboardMonitor: ClipboardMonitor) {
        self.historyStore = historyStore
        self.clipboardMonitor = clipboardMonitor
        // 存储层任何变化（监听新增 / 删除 / 固定 / 清空）都回调，刷新展示列表
        historyStore.onChange = { [weak self] in self?.refresh() }
        refresh()
    }
}

extension HistoryViewModel {

    /// 重新计算展示列表（数据或筛选变化后调用）
    func refresh() {
        pinnedItems  = filtered(historyStore.pinnedItems)
        regularItems = filtered(historyStore.regularItems)
        totalCount   = historyStore.allItems.count
    }

    /// 面板每次显示前调用：重置搜索/筛选 + 重新加载存储
    func prepareForShow() {
        searchQuery = ""
        typeFilter = .all
        timeFilter = .all
        previewingItemID = nil
        isSelecting = false
        isShowingDeleteConfirm = false
        historyStore.reload()   // → onChange → refresh
        refresh()
    }

    var isEmpty: Bool { totalCount == 0 }
    var hasSearchResults: Bool { !pinnedItems.isEmpty || !regularItems.isEmpty }
    var isFiltering: Bool {
        !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty || typeFilter != .all || timeFilter != .all
    }

    // MARK: - 用户操作

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
}

private extension HistoryViewModel {

    func filtered(_ items: [ClipboardItem]) -> [ClipboardItem] {
        var result = items
        switch typeFilter {
        case .all:   break
        case .text:  result = result.filter { $0.contentType == .plainText || $0.contentType == .richText }
        case .image: result = result.filter { $0.contentType == .image }
        case .files: result = result.filter { $0.contentType == .fileURLs }
        }
        if let cutoff = timeFilter.cutoff {
            result = result.filter { $0.timestamp >= cutoff }
        }
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

    func writeToPasteboard(_ item: ClipboardItem) {
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

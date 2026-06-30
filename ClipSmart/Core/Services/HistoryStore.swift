import Foundation
import SwiftData
import os

// 协议解耦：Core 层不直接依赖 PreferencesStore
public protocol HistoryStoreConfiguration {
    var maxHistoryCount: Int { get }
}

@MainActor
@Observable
final class HistoryStore {
    private let modelContext: ModelContext
    private let preferences: any HistoryStoreConfiguration
    private let logger = Logger(subsystem: "com.clipsmart.app", category: "HistoryStore")

    private(set) var allItems: [ClipboardItem] = []

    /// 数据变化回调（增/删/改/清空后触发），由 ViewModel 监听以刷新展示
    @ObservationIgnored var onChange: (() -> Void)?

    init(modelContext: ModelContext, preferences: any HistoryStoreConfiguration) {
        self.modelContext = modelContext
        self.preferences = preferences
        loadItems()
    }

    var pinnedItems: [ClipboardItem]  { allItems.filter { $0.isPinned } }
    var regularItems: [ClipboardItem] { allItems.filter { !$0.isPinned } }

    func addItem(_ item: ClipboardItem) {
        if let latest = allItems.first, isDuplicate(item, of: latest) { return }
        evictOldestIfNeeded()
        modelContext.insert(item)
        save()
    }

    func deleteItem(_ item: ClipboardItem) { modelContext.delete(item); save() }

    func clearAll() {
        try? modelContext.delete(model: ClipboardItem.self)
        try? modelContext.save()
        loadItems()   // 置空 allItems 并触发 onChange
    }

    func togglePin(_ item: ClipboardItem) { item.isPinned.toggle(); save() }

    private func save() {
        try? modelContext.save()
        loadItems()
    }

    private func loadItems() {
        let descriptor = FetchDescriptor<ClipboardItem>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        allItems = (try? modelContext.fetch(descriptor)) ?? []
        onChange?()
    }

    /// 公开的重新加载入口（面板显示前调用，确保内存数据最新）
    func reload() { loadItems() }

    private func isDuplicate(_ n: ClipboardItem, of e: ClipboardItem) -> Bool {
        guard n.contentTypeRaw == e.contentTypeRaw else { return false }
        switch n.contentType {
        case .plainText, .richText: return n.textContent == e.textContent
        case .image:
            guard let nd = n.imageData, let ed = e.imageData else { return false }
            return nd == ed
        case .fileURLs: return Set(n.fileURLStrings) == Set(e.fileURLStrings)
        }
    }

    private func evictOldestIfNeeded() {
        let maxCount = preferences.maxHistoryCount
        guard regularItems.count >= maxCount, let oldest = regularItems.last else { return }
        modelContext.delete(oldest)
    }
}

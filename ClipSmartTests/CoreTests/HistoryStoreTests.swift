import XCTest
import SwiftData
@testable import ClipSmartCore
import ClipSmartPrefs

// Mock 配置，用于测试
struct MockPrefs: HistoryStoreConfiguration {
    var maxHistoryCount: Int
}

@MainActor
final class HistoryStoreTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var store: HistoryStore!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: ClipboardItem.self, configurations: config)
        modelContext = modelContainer.mainContext
        store = HistoryStore(modelContext: modelContext, preferences: MockPrefs(maxHistoryCount: 5))
    }

    override func tearDown() async throws {
        store.clearAll()
        modelContainer = nil
    }

    func testAddItem_basic() {
        store.addItem(.fromText("hello"))
        XCTAssertEqual(store.allItems.count, 1)
    }

    func testFIFO_evictsOldestRegularItem() {
        for i in 1...5 { store.addItem(.fromText("item \(i)")) }
        XCTAssertEqual(store.regularItems.count, 5)
        store.addItem(.fromText("item 6"))
        XCTAssertEqual(store.regularItems.count, 5)
        XCTAssertFalse(store.regularItems.contains { $0.textContent == "item 1" })
        XCTAssertTrue(store.regularItems.contains { $0.textContent == "item 6" })
    }

    func testFIFO_pinnedItemsNeverEvicted() {
        let pinned = ClipboardItem.fromText("pinned item")
        store.addItem(pinned)
        store.togglePin(pinned)
        for i in 1...5 { store.addItem(.fromText("regular \(i)")) }
        XCTAssertTrue(store.pinnedItems.contains { $0.textContent == "pinned item" })
        XCTAssertEqual(store.regularItems.count, 5)
    }

    func testDeduplication_identicalText_skipped() {
        store.addItem(.fromText("same text"))
        store.addItem(.fromText("same text"))
        XCTAssertEqual(store.allItems.count, 1)
    }

    func testDeduplication_differentText_bothAdded() {
        store.addItem(.fromText("text A"))
        store.addItem(.fromText("text B"))
        XCTAssertEqual(store.allItems.count, 2)
    }

    func testDeduplication_differentType_bothAdded() {
        store.addItem(.fromText("hello"))
        store.addItem(.fromRichText("hello"))
        XCTAssertEqual(store.allItems.count, 2)
    }

    func testTogglePin_setsTrue() {
        let item = ClipboardItem.fromText("pin me")
        store.addItem(item)
        store.togglePin(store.allItems.first!)
        XCTAssertEqual(store.pinnedItems.count, 1)
        XCTAssertTrue(store.regularItems.isEmpty)
    }

    func testTogglePin_togglesBackToFalse() {
        let item = ClipboardItem.fromText("toggle me")
        store.addItem(item)
        store.togglePin(store.allItems.first!)
        store.togglePin(store.allItems.first!)
        XCTAssertTrue(store.pinnedItems.isEmpty)
        XCTAssertEqual(store.regularItems.count, 1)
    }

    func testDeleteItem_removesFromStore() {
        let item = ClipboardItem.fromText("delete me")
        store.addItem(item)
        XCTAssertEqual(store.allItems.count, 1)
        store.deleteItem(store.allItems.first!)
        XCTAssertEqual(store.allItems.count, 0)
    }

    func testClearAll_removesAllItems() {
        for i in 1...3 { store.addItem(.fromText("item \(i)")) }
        XCTAssertEqual(store.allItems.count, 3)
        store.clearAll()
        XCTAssertEqual(store.allItems.count, 0)
    }
}

import XCTest
import SwiftData
@testable import ClipSmartCore

struct TestPrefs: HistoryStoreConfiguration {
    var maxHistoryCount: Int = 50
}

@MainActor
final class HistoryViewModelTests: XCTestCase {

    var modelContainer: ModelContainer!
    var store: HistoryStore!
    var monitor: ClipboardMonitor!
    var viewModel: HistoryViewModel!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: ClipboardItem.self, configurations: config)
        store = HistoryStore(modelContext: modelContainer.mainContext, preferences: TestPrefs())
        monitor = ClipboardMonitor(historyStore: store)
        viewModel = HistoryViewModel(historyStore: store, clipboardMonitor: monitor)
    }

    func testSearch_emptyQuery_returnsAll() {
        store.addItem(.fromText("hello"))
        store.addItem(.fromText("world"))
        viewModel.searchQuery = ""
        XCTAssertEqual(viewModel.regularItems.count, 2)
    }

    func testSearch_textMatch_caseInsensitive() {
        store.addItem(.fromText("Hello World"))
        store.addItem(.fromText("Goodbye Moon"))
        viewModel.searchQuery = "hello"
        XCTAssertEqual(viewModel.regularItems.count, 1)
        XCTAssertEqual(viewModel.regularItems.first?.textContent, "Hello World")
    }

    func testSearch_noMatch_returnsEmpty() {
        store.addItem(.fromText("Hello World"))
        viewModel.searchQuery = "xyz"
        XCTAssertTrue(viewModel.regularItems.isEmpty)
    }

    func testSearch_imageNotFilteredByText() {
        store.addItem(.fromImage(Data([0x89, 0x50])))
        viewModel.searchQuery = ""
        XCTAssertEqual(viewModel.regularItems.count, 1)
        viewModel.searchQuery = "anything"
        XCTAssertEqual(viewModel.regularItems.count, 0)
    }

    func testPinnedAndRegular_separation() {
        let pinned = ClipboardItem.fromText("pinned")
        let regular = ClipboardItem.fromText("regular")
        store.addItem(pinned)
        store.addItem(regular)
        store.togglePin(store.allItems.first { $0.textContent == "pinned" }!)
        XCTAssertEqual(viewModel.pinnedItems.count, 1)
        XCTAssertEqual(viewModel.regularItems.count, 1)
    }

    func testIsEmpty_noItems()    { XCTAssertTrue(viewModel.isEmpty) }
    func testIsEmpty_withItems()  { store.addItem(.fromText("x")); XCTAssertFalse(viewModel.isEmpty) }

    func testClearAll_emptiesStore() {
        store.addItem(.fromText("data"))
        viewModel.clearAll()
        XCTAssertTrue(viewModel.isEmpty)
    }

    func testSelectItem_callsOnRequestClose() {
        var closed = false
        viewModel.onRequestClose = { closed = true }
        viewModel.selectItem(ClipboardItem.fromText("close me"))
        XCTAssertTrue(closed)
    }
}

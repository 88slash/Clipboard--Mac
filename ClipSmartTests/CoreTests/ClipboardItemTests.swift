import XCTest
@testable import ClipSmartCore

final class ClipboardItemTests: XCTestCase {

    func testDisplayPreview_shortText() {
        XCTAssertEqual(ClipboardItem.fromText("Hello World").displayPreview, "Hello World")
    }

    func testDisplayPreview_longText_truncated() {
        let item = ClipboardItem.fromText(String(repeating: "A", count: 150))
        XCTAssertEqual(item.displayPreview.count, 121)  // 120 + "…"
        XCTAssertTrue(item.displayPreview.hasSuffix("…"))
    }

    func testDisplayPreview_image() {
        XCTAssertEqual(ClipboardItem.fromImage(Data([0x89, 0x50])).displayPreview, "[图片]")
    }

    func testDisplayPreview_singleFile() {
        let url = URL(string: "file:///Users/test/document.pdf")!
        XCTAssertEqual(ClipboardItem.fromFileURLs([url]).displayPreview, "[文件: document.pdf]")
    }

    func testDisplayPreview_multipleFiles() {
        let urls = [URL(string: "file:///a.pdf")!, URL(string: "file:///b.png")!, URL(string: "file:///c.txt")!]
        XCTAssertTrue(ClipboardItem.fromFileURLs(urls).displayPreview.contains("3 项"))
    }

    func testContentType_fromText()     { XCTAssertEqual(ClipboardItem.fromText("x").contentType, .plainText) }
    func testContentType_fromImage()    { XCTAssertEqual(ClipboardItem.fromImage(Data()).contentType, .image) }
    func testContentType_fromFileURLs() {
        XCTAssertEqual(ClipboardItem.fromFileURLs([URL(string: "file:///x")!]).contentType, .fileURLs)
    }

    func testFileURLs_roundTrip() {
        let urls = [URL(string: "file:///a.txt")!, URL(string: "file:///b.png")!]
        XCTAssertEqual(ClipboardItem.fromFileURLs(urls).fileURLs, urls)
    }

    func testThumbnailImage_nonImageType_returnsNil() {
        XCTAssertNil(ClipboardItem.fromText("hi").thumbnailImage)
    }

    func testThumbnailImage_invalidData_returnsNil() {
        XCTAssertNil(ClipboardItem.fromImage(Data([0x00, 0x01])).thumbnailImage)
    }

    func testIsPinned_defaultFalse() {
        XCTAssertFalse(ClipboardItem.fromText("test").isPinned)
    }

    func testEquality_sameInstance() {
        let item = ClipboardItem.fromText("hello")
        XCTAssertEqual(item, item)
    }
}

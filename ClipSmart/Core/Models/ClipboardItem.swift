import Foundation
import SwiftData
import AppKit

@Model
final class ClipboardItem {
    var id: UUID
    var contentTypeRaw: String
    var textContent: String?
    @Attribute(.externalStorage) var imageData: Data?
    var fileURLStrings: [String]
    var timestamp: Date
    var isPinned: Bool
    var sourceApp: String?

    init(contentType: ClipboardItemType, textContent: String? = nil,
         imageData: Data? = nil, fileURLStrings: [String] = [],
         timestamp: Date = Date(), isPinned: Bool = false, sourceApp: String? = nil) {
        self.id = UUID()
        self.contentTypeRaw = contentType.rawValue
        self.textContent = textContent
        self.imageData = imageData
        self.fileURLStrings = fileURLStrings
        self.timestamp = timestamp
        self.isPinned = isPinned
        self.sourceApp = sourceApp
    }

    var contentType: ClipboardItemType { ClipboardItemType(rawValue: contentTypeRaw) ?? .plainText }

    var displayPreview: String {
        switch contentType {
        case .plainText, .richText:
            let t = textContent ?? ""; return t.count > 120 ? String(t.prefix(120)) + "…" : t
        case .image: return "[图片]"
        case .fileURLs:
            let n = fileURLStrings.last.flatMap { URL(string: $0)?.lastPathComponent } ?? "文件"
            return fileURLStrings.count > 1 ? "[文件: \(n) 等 \(fileURLStrings.count) 项]" : "[文件: \(n)]"
        }
    }

    var thumbnailImage: NSImage? {
        guard contentType == .image, let d = imageData else { return nil }
        return NSImage(data: d)?.resized(to: NSSize(width: 44, height: 44))
    }

    var fileURLs: [URL] { fileURLStrings.compactMap { URL(string: $0) } }

    static func fromText(_ text: String, sourceApp: String? = nil) -> ClipboardItem {
        ClipboardItem(contentType: .plainText, textContent: text, sourceApp: sourceApp)
    }
    static func fromRichText(_ text: String, sourceApp: String? = nil) -> ClipboardItem {
        ClipboardItem(contentType: .richText, textContent: text, sourceApp: sourceApp)
    }
    static func fromImage(_ data: Data, sourceApp: String? = nil) -> ClipboardItem {
        ClipboardItem(contentType: .image, imageData: data, sourceApp: sourceApp)
    }
    static func fromFileURLs(_ urls: [URL], sourceApp: String? = nil) -> ClipboardItem {
        ClipboardItem(contentType: .fileURLs, fileURLStrings: urls.map { $0.absoluteString }, sourceApp: sourceApp)
    }
}

extension ClipboardItem: Equatable {
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool { lhs.id == rhs.id }
}

extension NSImage {
    func resized(to newSize: NSSize) -> NSImage {
        let result = NSImage(size: newSize)
        result.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: size),
             operation: .copy, fraction: 1.0)
        result.unlockFocus()
        return result
    }
}

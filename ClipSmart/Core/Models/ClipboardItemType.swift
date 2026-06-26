import AppKit

enum ClipboardItemType: String, Codable, CaseIterable {
    case plainText = "plainText"
    case richText  = "richText"
    case image     = "image"
    case fileURLs  = "fileURLs"

    var displayName: String {
        switch self {
        case .plainText: return "文本"
        case .richText:  return "富文本"
        case .image:     return "图片"
        case .fileURLs:  return "文件"
        }
    }

    var systemImageName: String {
        switch self {
        case .plainText: return "doc.text"
        case .richText:  return "doc.richtext"
        case .image:     return "photo"
        case .fileURLs:  return "folder"
        }
    }
}

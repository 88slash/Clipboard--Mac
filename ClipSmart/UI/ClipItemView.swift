import SwiftUI
import SwiftData

struct ClipItemView: View {
    @Environment(HistoryViewModel.self) private var viewModel
    let item: ClipboardItem
    let isSelected: Bool
    let globalIndex: Int
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            typeIcon
            contentPreview
            Spacer(minLength: 4)
            trailingInfo
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
        .onTapGesture { viewModel.selectItem(item) }
        .onHover { isHovered = $0 }
        .contextMenu { contextMenuItems }
        .animation(.easeInOut(duration: 0.1), value: isSelected)
        .animation(.easeInOut(duration: 0.08), value: isHovered)
    }

    private var typeIcon: some View {
        Group {
            if item.contentType == .image, let thumb = item.thumbnailImage {
                Image(nsImage: thumb).resizable().scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            } else {
                Image(systemName: item.contentType.systemImageName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(iconColor)
                    .frame(width: 32, height: 32)
                    .background(iconBackground, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
        }
    }

    private var contentPreview: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.displayPreview)
                .font(.system(size: 13))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .lineLimit(item.contentType == .image ? 1 : 2)
                .truncationMode(.tail)
            if let app = item.sourceApp, !app.isEmpty {
                Text(app.components(separatedBy: ".").last?.capitalized ?? app)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color.secondary)
            }
        }
    }

    private var trailingInfo: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(relativeTime(item.timestamp))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color.secondary)
            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.orange.opacity(0.9))
            }
        }
    }

    @ViewBuilder
    private var contextMenuItems: some View {
        Button { copyOnly(item) } label: { Label("复制到剪切板", systemImage: "doc.on.doc") }
        Divider()
        Button { viewModel.togglePin(item) } label: {
            Label(item.isPinned ? "取消固定" : "固定", systemImage: item.isPinned ? "pin.slash" : "pin")
        }
        Divider()
        Button(role: .destructive) { viewModel.deleteItem(item) } label: {
            Label("删除", systemImage: "trash")
        }
    }

    private var rowBackground: some ShapeStyle {
        if isSelected { return AnyShapeStyle(.tint) }
        else if isHovered { return AnyShapeStyle(.quinary) }
        else { return AnyShapeStyle(.clear) }
    }

    private var iconColor: Color {
        if isSelected { return .white }
        switch item.contentType {
        case .plainText: return .blue; case .richText: return .purple
        case .image: return .green; case .fileURLs: return .orange
        }
    }

    private var iconBackground: AnyShapeStyle {
        if isSelected { return AnyShapeStyle(.white.opacity(0.2)) }
        switch item.contentType {
        case .plainText: return AnyShapeStyle(.blue.opacity(0.12))
        case .richText:  return AnyShapeStyle(.purple.opacity(0.12))
        case .image:     return AnyShapeStyle(.green.opacity(0.12))
        case .fileURLs:  return AnyShapeStyle(.orange.opacity(0.12))
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let s = Int(-date.timeIntervalSinceNow)
        if s < 60 { return "刚刚" }
        if s < 3600 { return "\(s / 60)分钟前" }
        if s < 86400 { return "\(s / 3600)小时前" }
        let f = DateFormatter(); f.dateFormat = "MM/dd"; return f.string(from: date)
    }

    private func copyOnly(_ item: ClipboardItem) {
        let pb = NSPasteboard.general; pb.clearContents()
        switch item.contentType {
        case .plainText, .richText: if let t = item.textContent { pb.setString(t, forType: .string) }
        case .image: if let d = item.imageData { pb.setData(d, forType: .tiff) }
        case .fileURLs: pb.writeObjects(item.fileURLs as [NSURL])
        }
    }
}

import SwiftUI
import SwiftData

struct ClipItemView: View {
    @Environment(HistoryViewModel.self) private var viewModel
    let item: ClipboardItem
    let isSelected: Bool
    let globalIndex: Int
    @State private var isHovered = false

    /// 是否显示预览：与 viewModel.previewingItemID 双向同步，
    /// 这样 AppKit 层（PanelWindowController）也能感知到预览开着，避免 ESC/失焦误关主面板
    private var showPreview: Bool {
        get { viewModel.previewingItemID == item.id }
        nonmutating set { viewModel.previewingItemID = newValue ? item.id : nil }
    }

    var body: some View {
        HStack(spacing: 10) {
            if viewModel.isSelecting { checkbox }
            typeIcon
            contentPreview
            Spacer(minLength: 4)
            previewButton
            trailingInfo
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(itemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.isSelecting { viewModel.toggleChecked(item) }
            else { viewModel.selectItem(item) }
        }
        .onHover { isHovered = $0 }
        .contextMenu { contextMenuItems }
        .animation(.easeInOut(duration: 0.1), value: isSelected)
        .animation(.easeInOut(duration: 0.08), value: isHovered)
    }

    /// 多选模式下显示的勾选框
    private var checkbox: some View {
        Image(systemName: viewModel.isChecked(item) ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 15))
            .foregroundStyle(viewModel.isChecked(item) ? Color.accentColor : Color.secondary.opacity(0.5))
            .frame(width: 18)
    }

    /// 图片行悬停时显示的预览按钮
    @ViewBuilder
    private var previewButton: some View {
        if item.contentType == .image && (isHovered || showPreview) {
            Button { showPreview = true } label: {
                Image(systemName: "eye")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? Color.white : Color.secondary)
            }
            .buttonStyle(.plain)
            .help("预览图片")
            .transition(.opacity)
        }
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
        .popover(isPresented: Binding(get: { showPreview }, set: { showPreview = $0 }), arrowEdge: .trailing) {
            ImagePreviewView(item: item) { showPreview = false }
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
        if item.contentType == .image {
            Button { showPreview = true } label: { Label("预览图片", systemImage: "eye") }
            Divider()
        }
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

    @ViewBuilder
    private var itemBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.accentColor.opacity(0.85),
                            Color.accentColor.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        } else if isHovered {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                )
        } else {
            Color.clear
        }
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

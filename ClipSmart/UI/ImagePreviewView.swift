import SwiftUI

/// 图片预览弹窗内容 —— 展示完整图片 + 尺寸/大小信息
struct ImagePreviewView: View {
    let item: ClipboardItem
    var onClose: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 10) {
            if onClose != nil {
                HStack {
                    Spacer()
                    Button { onClose?() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("关闭预览（Esc）")
                }
            }
            if let img = item.fullImage {
                Image(nsImage: img)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 420, maxHeight: 420)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    )
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(.secondary)
                    Text("无法预览此图片").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                .frame(width: 220, height: 140)
            }

            HStack(spacing: 10) {
                if let size = item.imagePixelSize {
                    Label("\(Int(size.width)) × \(Int(size.height))",
                          systemImage: "aspectratio")
                        .font(.system(size: 11, design: .monospaced))
                }
                if let bytes = item.imageByteSizeText {
                    Label(bytes, systemImage: "internaldrive")
                        .font(.system(size: 11, design: .monospaced))
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(14)
    }
}

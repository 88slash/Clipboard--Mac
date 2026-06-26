import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clipboard")
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundStyle(.quaternary)
                .symbolEffect(.pulse, options: .repeating)
            Text("暂无剪切板记录")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            Text("复制任何内容，它将出现在这里")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

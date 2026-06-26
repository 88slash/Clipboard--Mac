import SwiftUI

struct PinnedSectionView: View {
    @Environment(HistoryViewModel.self) private var viewModel
    @Binding var selectedIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "pin.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.orange)
                Text("固定")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            ForEach(Array(viewModel.pinnedItems.enumerated()), id: \.element.id) { index, item in
                ClipItemView(item: item, isSelected: selectedIndex == index, globalIndex: index)
                    .id("item-\(index)")
            }

            if !viewModel.regularItems.isEmpty {
                Rectangle()
                    .fill(.separator.opacity(0.5))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            }
        }
    }
}

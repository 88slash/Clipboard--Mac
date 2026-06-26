import SwiftUI

struct ClipListView: View {
    @Environment(HistoryViewModel.self) private var viewModel
    @Binding var selectedIndex: Int
    var indexOffset: Int = 0

    var body: some View {
        ForEach(Array(viewModel.regularItems.enumerated()), id: \.element.id) { index, item in
            ClipItemView(
                item: item,
                isSelected: selectedIndex == (index + indexOffset),
                globalIndex: index + indexOffset
            )
            .id("item-\(index + indexOffset)")
        }
    }
}

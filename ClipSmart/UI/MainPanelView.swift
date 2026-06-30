import SwiftUI
import SwiftData

struct MainPanelView: View {
    @Environment(HistoryViewModel.self) private var viewModel
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(selectedIndex: $selectedIndex)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)
            FilterBarView()
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            Divider().opacity(0.15)
            contentArea
        }
        .frame(width: 680, height: 440)
        .glassPanel()
        .onChange(of: viewModel.typeFilter) { _, _ in selectedIndex = 0 }
        .onChange(of: viewModel.timeFilter) { _, _ in selectedIndex = 0 }
        .onKeyPress(.escape)    { handleEscape();      return .handled }
        .onKeyPress(.upArrow)   { navigateUp();         return .handled }
        .onKeyPress(.downArrow) { navigateDown();       return .handled }
        .onKeyPress(.return)    { confirmSelection();   return .handled }
        .onKeyPress(.delete)    { deleteSelected();     return .handled }
    }

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isEmpty {
            EmptyStateView().padding(.vertical, 40)
        } else if !viewModel.hasSearchResults && viewModel.isFiltering {
            noResultsView
        } else {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        if !viewModel.pinnedItems.isEmpty {
                            PinnedSectionView(selectedIndex: $selectedIndex)
                        }
                        let offset = viewModel.pinnedItems.count
                        ForEach(Array(viewModel.regularItems.enumerated()), id: \.element.id) { i, item in
                            ClipItemView(item: item, isSelected: selectedIndex == (i + offset), globalIndex: i + offset)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .onChange(of: selectedIndex) { _, n in
                    let all = viewModel.pinnedItems + viewModel.regularItems
                    guard n >= 0, n < all.count else { return }
                    withAnimation(.easeInOut(duration: 0.15)) { proxy.scrollTo(all[n].id, anchor: .center) }
                }
            }
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 28, weight: .light)).foregroundStyle(.secondary)
            Text(noResultsText).font(.system(size: 13)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 40)
    }

    private var noResultsText: String {
        let q = viewModel.searchQuery.trimmingCharacters(in: .whitespaces)
        if !q.isEmpty { return "没有找到 \"\(q)\"" }
        return "该筛选下暂无记录"
    }

    private var totalCount: Int { viewModel.pinnedItems.count + viewModel.regularItems.count }
    private func navigateUp()   { guard totalCount > 0 else { return }; selectedIndex = max(0, selectedIndex - 1) }
    private func navigateDown() { guard totalCount > 0 else { return }; selectedIndex = min(totalCount - 1, selectedIndex + 1) }
    private func confirmSelection() {
        let all = viewModel.pinnedItems + viewModel.regularItems
        guard selectedIndex < all.count else { return }
        viewModel.selectItem(all[selectedIndex])
    }
    private func deleteSelected() {
        let all = viewModel.pinnedItems + viewModel.regularItems
        guard selectedIndex < all.count else { return }
        viewModel.deleteItem(all[selectedIndex])
        selectedIndex = max(0, min(selectedIndex, totalCount - 2))
    }
    private func handleEscape() {
        if !viewModel.searchQuery.isEmpty { viewModel.clearSearch(); selectedIndex = 0 }
        else { viewModel.onRequestClose?() }
    }
}

private struct GlassPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .glassEffect(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: 16)
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.25), radius: 40, x: 0, y: 16)
        }
    }
}

extension View {
    func glassPanel() -> some View { modifier(GlassPanelModifier()) }
}

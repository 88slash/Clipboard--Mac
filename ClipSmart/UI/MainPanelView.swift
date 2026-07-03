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
            if viewModel.isSelecting {
                BulkActionBarView()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            Divider().opacity(0.15)
            contentArea
        }
        .frame(width: 680, height: 440)
        .glassPanel()
        .onChange(of: viewModel.typeFilter) { _, _ in selectedIndex = 0 }
        .onChange(of: viewModel.timeFilter) { _, _ in selectedIndex = 0 }
        .onChange(of: viewModel.isSelecting) { _, _ in selectedIndex = 0 }
        .onKeyPress(.escape)    { handleEscape();      return .handled }
        .onKeyPress(.upArrow)   { navigateUp();         return .handled }
        .onKeyPress(.downArrow) { navigateDown();       return .handled }
        .onKeyPress(.return)    { confirmSelection();   return .handled }
        .onKeyPress(.delete)    { deleteSelected();     return .handled }
    }

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isEmpty {
            VStack {
                Spacer()
                EmptyStateView()
                Spacer()
            }
            .frame(maxHeight: .infinity)
        } else if !viewModel.hasSearchResults && viewModel.isFiltering {
            VStack {
                Spacer()
                noResultsView
                Spacer()
            }
            .frame(maxHeight: .infinity)
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
        .frame(maxWidth: .infinity)
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
        if viewModel.isSelecting { viewModel.toggleChecked(all[selectedIndex]) }
        else { viewModel.selectItem(all[selectedIndex]) }
    }
    private func deleteSelected() {
        // 多选模式下，Delete 键交给批量删除逻辑处理，避免和单条删除混淆
        guard !viewModel.isSelecting else { return }
        let all = viewModel.pinnedItems + viewModel.regularItems
        guard selectedIndex < all.count else { return }
        viewModel.deleteItem(all[selectedIndex])
        selectedIndex = max(0, min(selectedIndex, totalCount - 2))
    }
    private func handleEscape() {
        if viewModel.isSelecting { viewModel.isSelecting = false }
        else if !viewModel.searchQuery.isEmpty { viewModel.clearSearch(); selectedIndex = 0 }
        else { viewModel.onRequestClose?() }
    }
}

private struct GlassPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            // Base background: macOS hardware-accelerated blur effect
            .background(
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            )
            // Liquid dark color layering
            .background(
                Color.black.opacity(0.35)
            )
            // Mirror surface gloss highlight gradient
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.12),
                        Color.white.opacity(0.02),
                        Color.clear,
                        Color.black.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            // Liquid glass highlight edge stroke
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.38),
                                Color.white.opacity(0.08),
                                Color.clear,
                                Color.black.opacity(0.25),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State = .active

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

extension View {
    func glassPanel() -> some View { modifier(GlassPanelModifier()) }
}

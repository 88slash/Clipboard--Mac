import SwiftUI
import SwiftData

struct SearchBarView: View {
    @Environment(HistoryViewModel.self) private var viewModel
    @Binding var selectedIndex: Int
    @FocusState private var isFocused: Bool

    var body: some View {
        @Bindable var vm = viewModel
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
            TextField("搜索剪切板历史…", text: $vm.searchQuery)
                .textFieldStyle(.plain)
                .font(.system(size: 15))
                .focused($isFocused)
                .onChange(of: vm.searchQuery) { _, _ in selectedIndex = 0 }
            if !viewModel.searchQuery.isEmpty {
                Button { viewModel.clearSearch(); selectedIndex = 0 } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
            Text("\(viewModel.totalCount)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                .opacity(viewModel.searchQuery.isEmpty ? 1 : 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.quinary, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { isFocused = true } }
        .animation(.easeInOut(duration: 0.15), value: viewModel.searchQuery.isEmpty)
    }
}

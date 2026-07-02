import SwiftUI

/// 多选模式下的操作条：全选 / 取消全选 / 显示已选数量 / 删除所选
struct BulkActionBarView: View {
    @Environment(HistoryViewModel.self) private var viewModel

    private var allVisibleCount: Int { viewModel.pinnedItems.count + viewModel.regularItems.count }
    private var selectedCount: Int { viewModel.selectedIDs.count }
    private var isAllSelected: Bool { selectedCount > 0 && selectedCount == allVisibleCount }

    var body: some View {
        @Bindable var vm = viewModel
        HStack(spacing: 10) {
            Button {
                isAllSelected ? viewModel.deselectAll() : viewModel.selectAllVisible()
            } label: {
                Label(isAllSelected ? "取消全选" : "全选",
                      systemImage: isAllSelected ? "checkmark.circle.fill" : "circle.dashed")
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(.plain)

            Text(selectedCount > 0 ? "已选 \(selectedCount) 项" : "未选择任何项")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Spacer()

            Button(role: .destructive) {
                vm.isShowingDeleteConfirm = true
            } label: {
                Label("删除所选", systemImage: "trash")
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundStyle(selectedCount > 0 ? Color.red : Color.secondary.opacity(0.4))
            .disabled(selectedCount == 0)
            .confirmationDialog(
                "删除已选中的 \(selectedCount) 条记录？",
                isPresented: $vm.isShowingDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("删除", role: .destructive) { viewModel.deleteSelected() }
                Button("取消", role: .cancel) {}
            } message: {
                Text("此操作不可撤销。")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.quinary, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

import SwiftUI

/// 顶部筛选条：类型(全部/文本/图片/文件) + 时间范围
struct FilterBarView: View {
    @Environment(HistoryViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        HStack(spacing: 6) {
            ForEach(HistoryViewModel.TypeFilter.allCases) { f in
                Chip(title: f.label, selected: vm.typeFilter == f) {
                    vm.typeFilter = f
                }
            }

            Spacer(minLength: 4)

            // 时间范围：菜单选择
            Menu {
                ForEach(HistoryViewModel.TimeFilter.allCases) { t in
                    Button {
                        vm.timeFilter = t
                    } label: {
                        if vm.timeFilter == t { Label(t.label, systemImage: "checkmark") }
                        else { Text(t.label) }
                    }
                }
            } label: {
                Chip(title: vm.timeFilter.label, selected: vm.timeFilter != .all, showsChevron: true) {}
                    .allowsHitTesting(false)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
    }
}

// MARK: - 单个筛选标签

private struct Chip: View {
    let title: String
    let selected: Bool
    var showsChevron: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 12, weight: selected ? .semibold : .medium))
                if showsChevron {
                    Image(systemName: "chevron.down").font(.system(size: 8, weight: .bold))
                }
            }
            .foregroundStyle(selected ? Color.white : Color.primary.opacity(0.75))
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .background(chipBackground)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.12), value: selected)
    }

    @ViewBuilder private var chipBackground: some View {
        if selected {
            Capsule().fill(.tint)
        } else {
            Capsule().fill(.quaternary)
        }
    }
}

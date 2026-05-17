//  Views/SidebarView.swift

import SwiftUI

struct SidebarView: View {
    @Environment(WishStore.self) private var store
    @Binding var selectedItem: SidebarItem?
    @State private var showingAddCategory = false

    // Categories: non-empty ones first (sorted by most recent wish),
    // empty ones last (sorted alphabetically).
    private var sortedCategories: [WishCategory] {
        let liveItems = store.items.filter { !$0.isDeleted && !$0.isBought }

        let nonEmpty = store.categories
            .filter { cat in liveItems.contains { $0.categoryID == cat.id } }
            .sorted { a, b in
                let latestA =
                    liveItems.filter { $0.categoryID == a.id }.map(\.createdAt).max()
                    ?? .distantPast
                let latestB =
                    liveItems.filter { $0.categoryID == b.id }.map(\.createdAt).max()
                    ?? .distantPast
                return latestA > latestB
            }

        let empty = store.categories
            .filter { cat in !liveItems.contains { $0.categoryID == cat.id } }
            .sorted { $0.name < $1.name }

        return nonEmpty + empty
    }

    private func liveCount(for category: WishCategory) -> Int {
        store.items.filter { !$0.isDeleted && !$0.isBought && $0.categoryID == category.id }.count
    }
    private func priorityCount(_ p: Priority) -> Int {
        store.items.filter { !$0.isDeleted && !$0.isBought && $0.priority == p }.count
    }
    private var allCount: Int { store.items.filter { !$0.isDeleted && !$0.isBought }.count }
    private var boughtCount: Int { store.items.filter { !$0.isDeleted && $0.isBought }.count }
    private var trashedCount: Int { store.trashedItems.count }

    var body: some View {
        List(selection: $selectedItem) {
            Section("Browse") {
                SidebarRow(label: "All Wishes", icon: "sparkles", count: allCount)
                    .tag(SidebarItem.all)
                SidebarRow(label: "Bought", icon: "checkmark.seal.fill", count: boughtCount)
                    .tag(SidebarItem.bought)
                SidebarRow(label: "Deleted", icon: "trash", count: trashedCount)
                    .tag(SidebarItem.deleted)
            }

            Section("By Priority") {
                SidebarRow(
                    label: "High Priority", icon: "arrow.up.circle.fill",
                    count: priorityCount(.high)
                )
                .tag(SidebarItem.priority(.high))
                SidebarRow(
                    label: "Medium Priority", icon: "minus.circle.fill",
                    count: priorityCount(.medium)
                )
                .tag(SidebarItem.priority(.medium))
                SidebarRow(
                    label: "Low Priority", icon: "arrow.down.circle.fill",
                    count: priorityCount(.low)
                )
                .tag(SidebarItem.priority(.low))
            }

            Section("Categories") {
                ForEach(sortedCategories) { category in
                    SidebarRow(
                        label: category.name, icon: category.icon, count: liveCount(for: category)
                    )
                    .tag(SidebarItem.category(category.id))
                }
            }

        }
        .navigationTitle("Wishlist ✨")
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddCategory = true
                } label: {
                    Label("Add Category", systemImage: "folder.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
                .environment(store)
        }
    }
}

// MARK: - SidebarRow
struct SidebarRow: View {
    let label: String
    let icon: String
    let count: Int

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            if count > 0 {
                Text("\(count)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

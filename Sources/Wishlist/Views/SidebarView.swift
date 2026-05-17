//  Views/SidebarView.swift

import SwiftUI

struct SidebarView: View {
    @Environment(WishStore.self) private var store
    @Binding var selectedItem: SidebarItem?

    private func liveCount(for category: WishCategory) -> Int {
        store.items.filter { !$0.isDeleted && !$0.isBought && $0.categoryID == category.id }.count
    }

    private func priorityCount(_ p: Priority) -> Int {
        store.items.filter { !$0.isDeleted && !$0.isBought && $0.priority == p }.count
    }

    private var allCount: Int {
        store.items.filter { !$0.isDeleted && !$0.isBought }.count
    }

    private var boughtCount: Int {
        store.items.filter { !$0.isDeleted && $0.isBought }.count
    }

    private var trashedCount: Int {
        store.trashedItems.count
    }

    var body: some View {
        List(selection: $selectedItem) {

            Section("Browse") {
                Label("All Wishes", systemImage: "sparkles")
                    .tag(SidebarItem.all)
                    .badgeIfPositive(allCount)

                Label("Bought", systemImage: "checkmark.seal.fill")
                    .tag(SidebarItem.bought)
                    .badgeIfPositive(boughtCount)

                // NOTE: never pass 0 to .badge() — it hides the row's
                // selection highlight on macOS. Always use a Text badge
                // or omit entirely.
                Label("Deleted", systemImage: "trash")
                    .tag(SidebarItem.deleted)
                    .badgeIfPositive(trashedCount)
            }

            Section("By Priority") {
                Label("High Priority", systemImage: "arrow.up.circle.fill")
                    .tag(SidebarItem.priority(.high))
                    .badgeIfPositive(priorityCount(.high))

                Label("Medium Priority", systemImage: "minus.circle.fill")
                    .tag(SidebarItem.priority(.medium))
                    .badgeIfPositive(priorityCount(.medium))

                Label("Low Priority", systemImage: "arrow.down.circle.fill")
                    .tag(SidebarItem.priority(.low))
                    .badgeIfPositive(priorityCount(.low))
            }

            Section("Categories") {
                ForEach(store.categories) { category in
                    Label(category.name, systemImage: category.icon)
                        .tag(SidebarItem.category(category.id))
                        .badgeIfPositive(liveCount(for: category))
                }
            }
        }
        .navigationTitle("Wishlist ✨")
        .listStyle(.sidebar)
    }
}

// Only attach a badge when count > 0; attaching .badge(0) on macOS
// causes the sidebar row to lose its clickable highlight in some OS versions.
private extension View {
    @ViewBuilder
    func badgeIfPositive(_ count: Int) -> some View {
        if count > 0 {
            self.badge(count)
        } else {
            self
        }
    }
}

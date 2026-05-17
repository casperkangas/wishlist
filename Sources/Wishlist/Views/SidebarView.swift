//  Views/SidebarView.swift

import SwiftUI

struct SidebarView: View {
    @Environment(WishStore.self) private var store
    @Binding var selectedItem: SidebarItem?

    var body: some View {
        List(selection: $selectedItem) {
            Section("Browse") {
                Label("All Wishes", systemImage: "sparkles")
                    .tag(SidebarItem.all)
                Label("Bought", systemImage: "checkmark.seal.fill")
                    .tag(SidebarItem.bought)
            }

            Section("Categories") {
                ForEach(store.categories) { category in
                    Label(category.name, systemImage: category.icon)
                        .tag(SidebarItem.category(category.id))
                }
            }
        }
        .navigationTitle("Wishlist ✨")
        .listStyle(.sidebar)
    }
}

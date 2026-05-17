//  Views/ContentView.swift

import SwiftUI

// Sidebar selection: nil = All Wishes, UUID = specific category
enum SidebarItem: Hashable {
    case all
    case category(UUID)
}

struct ContentView: View {
    @Environment(WishStore.self) private var store

    @State private var selectedItem: SidebarItem? = .all
    @State private var showingAddWish = false
    @State private var searchText = ""

    private var selectedCategory: WishCategory? {
        guard case .category(let id) = selectedItem else { return nil }
        return store.categories.first(where: { $0.id == id })
    }

    private var filteredItems: [WishItem] {
        let base = store.items(for: selectedCategory)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return base.sorted { $0.createdAt > $1.createdAt }
        }
        return base.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            ($0.notes?.localizedCaseInsensitiveContains(query) ?? false)
        }.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedItem: $selectedItem)
                .navigationSplitViewColumnWidth(min: 200, ideal: 230)
        } detail: {
            WishListView(
                title: selectedCategory?.name ?? "All Wishes",
                subtitle: selectedCategory == nil
                    ? "Everything you're dreaming about."
                    : "Your curated list for this category.",
                items: filteredItems,
                selectedCategory: selectedCategory,
                onAddWish: { showingAddWish = true }
            )
        }
        .searchable(text: $searchText, prompt: "Search wishes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddWish = true } label: {
                    Label("Add Wish", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddWish) {
            AddWishView(
                preselectedCategoryID: {
                    if case .category(let id) = selectedItem { return id }
                    return nil
                }()
            )
            .environment(store)
        }
        .onAppear {
            applyWarmWindowBackground()
        }
    }
}

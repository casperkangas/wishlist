//  Views/ContentView.swift

import SwiftUI

enum SidebarItem: Hashable {
    case all
    case bought
    case category(UUID)
}

enum SortOption: String, CaseIterable, Identifiable {
    case priority   = "Priority"
    case priceAsc   = "Price: Low to High"
    case priceDesc  = "Price: High to Low"
    case newest     = "Newest First"
    case oldest     = "Oldest First"
    var id: String { rawValue }
}

struct ContentView: View {
    @Environment(WishStore.self) private var store

    @State private var selectedItem: SidebarItem? = .all
    @State private var showingAddWish = false
    @State private var searchText     = ""
    @State private var sortOption: SortOption = .priority
    @State private var showingSortMenu = false

    private var selectedCategory: WishCategory? {
        guard case .category(let id) = selectedItem else { return nil }
        return store.categories.first(where: { $0.id == id })
    }

    private var isBoughtView: Bool { selectedItem == .bought }

    private var filteredItems: [WishItem] {
        if isBoughtView {
            return store.items
                .filter { $0.isBought }
                .sorted { $0.createdAt > $1.createdAt }
        }

        var base = store.items(for: selectedCategory).filter { !$0.isBought }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            base = base.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                ($0.notes?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }

        return base.sorted(using: sortOption)
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedItem: $selectedItem)
                .navigationSplitViewColumnWidth(min: 200, ideal: 230)
        } detail: {
            WishListView(
                title: title,
                subtitle: subtitle,
                items: filteredItems,
                selectedCategory: selectedCategory,
                isBoughtView: isBoughtView,
                sortOption: sortOption,
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
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: sortOption == .priority
                          ? "line.3.horizontal.decrease.circle"
                          : "line.3.horizontal.decrease.circle.fill")
                }
                .help("Sort wishes")
            }
        }
        .sheet(isPresented: $showingAddWish) {
            AddWishView(preselectedCategoryID: {
                if case .category(let id) = selectedItem { return id }
                return nil
            }())
            .environment(store)
        }
        .onAppear { applyWarmWindowBackground() }
    }

    private var title: String {
        switch selectedItem {
        case .bought:   return "Bought Wishes"
        case .category: return selectedCategory?.name ?? "Wishes"
        default:        return "All Wishes"
        }
    }

    private var subtitle: String {
        switch selectedItem {
        case .bought:   return "Things you've already treated yourself to."
        case .category: return "Your curated list for this category."
        default:        return "Everything you're dreaming about."
        }
    }
}

// MARK: - Sorting
private extension Array where Element == WishItem {
    func sorted(using option: SortOption) -> [WishItem] {
        switch option {
        case .priority:
            let order: [Priority] = [.high, .medium, .low]
            return sorted {
                if $0.priority != $1.priority {
                    return (order.firstIndex(of: $0.priority) ?? 2) <
                           (order.firstIndex(of: $1.priority) ?? 2)
                }
                return $0.createdAt > $1.createdAt
            }
        case .priceAsc:
            return sorted { ($0.price ?? 0) < ($1.price ?? 0) }
        case .priceDesc:
            return sorted { ($0.price ?? 0) > ($1.price ?? 0) }
        case .newest:
            return sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            return sorted { $0.createdAt < $1.createdAt }
        }
    }
}

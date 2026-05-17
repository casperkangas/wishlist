//  Views/ContentView.swift

import SwiftUI

enum SidebarItem: Hashable {
    case all
    case bought
    case deleted
    case priority(Priority)
    case category(UUID)
}

enum SortOption: String, CaseIterable, Identifiable {
    case priority  = "Priority"
    case priceAsc  = "Price: Low to High"
    case priceDesc = "Price: High to Low"
    case newest    = "Newest First"
    case oldest    = "Oldest First"
    var id: String { rawValue }
}

struct ContentView: View {
    @Environment(WishStore.self) private var store

    @State private var selectedItem: SidebarItem? = .all
    @State private var displayedItem: SidebarItem? = .all
    @State private var showingAddWish = false
    @State private var searchText     = ""
    @State private var sortOption: SortOption = .priority

    private var selectedCategory: WishCategory? {
        guard case .category(let id) = displayedItem else { return nil }
        return store.categories.first(where: { $0.id == id })
    }
    private var isDeletedView: Bool { displayedItem == .deleted }
    private var isBoughtView:  Bool { displayedItem == .bought  }
    private var selectedPriority: Priority? {
        guard case .priority(let p) = displayedItem else { return nil }
        return p
    }

    private var filteredItems: [WishItem] {
        // Deleted: apply sort to trash too
        if isDeletedView {
            return store.trashedItems.sorted(using: sortOption)
        }
        // Bought: apply sort
        if isBoughtView {
            return store.items
                .filter { $0.isBought && !$0.isDeleted }
                .sorted(using: sortOption)
        }
        var base: [WishItem]
        if let p = selectedPriority {
            base = store.items(for: p).filter { !$0.isBought }
        } else {
            base = store.items(for: selectedCategory).filter { !$0.isBought }
        }
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
            ZStack {
                WishListView(
                    title: listTitle,
                    subtitle: listSubtitle,
                    items: filteredItems,
                    selectedCategory: selectedCategory,
                    isBoughtView: isBoughtView,
                    isDeletedView: isDeletedView,
                    sortOption: sortOption,
                    onAddWish: { showingAddWish = true }
                )
                .id(displayedItem)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .trailing).combined(with: .opacity)
                    )
                )
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.82), value: displayedItem)
        }
        .searchable(text: $searchText, prompt: "Search wishes")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Picker(selection: $sortOption) {
                    ForEach(SortOption.allCases) { opt in
                        Text(opt.rawValue).tag(opt)
                    }
                } label: {
                    Label("Sort", systemImage: "line.3.horizontal.decrease.circle")
                }
                .pickerStyle(.menu)
                .help("Sort wishes")

                Button { showingAddWish = true } label: {
                    Label("Add Wish", systemImage: "plus")
                }
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                displayedItem = newValue
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

    private var listTitle: String {
        switch displayedItem {
        case .bought:           return "Bought Wishes"
        case .deleted:          return "Deleted Wishes"
        case .priority(let p):  return "\(p.rawValue) Priority"
        case .category:         return selectedCategory?.name ?? "Wishes"
        default:                return "All Wishes"
        }
    }

    private var listSubtitle: String {
        switch displayedItem {
        case .bought:            return "Things you've already treated yourself to."
        case .deleted:           return "Items are permanently removed after 3 days."
        case .priority(.high):   return "Your most important wishes."
        case .priority(.medium): return "Wishes you'd love but aren't urgent."
        case .priority(.low):    return "Nice to have someday."
        case .category:          return "Your curated list for this category."
        default:                 return "Everything you're dreaming about."
        }
    }
}

// MARK: - Sort
extension Array where Element == WishItem {
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
        case .priceAsc:  return sorted { ($0.price ?? 0) < ($1.price ?? 0) }
        case .priceDesc: return sorted { ($0.price ?? 0) > ($1.price ?? 0) }
        case .newest:    return sorted { $0.createdAt > $1.createdAt }
        case .oldest:    return sorted { $0.createdAt < $1.createdAt }
        }
    }
}

//  Views/WishListView.swift

import SwiftUI

struct WishListView: View {
    let title: String
    let subtitle: String
    let items: [WishItem]
    let selectedCategory: WishCategory?
    let isBoughtView: Bool
    let isDeletedView: Bool
    let sortOption: SortOption
    let onAddWish: () -> Void

    private let primaryText = Color(red: 0.16, green: 0.13, blue: 0.10)
    private let secondaryText = Color(red: 0.42, green: 0.38, blue: 0.32)
    private let amber = Color(red: 0.78, green: 0.55, blue: 0.08)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if items.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 14) {
                        ForEach(items) { item in
                            Group {
                                if isDeletedView {
                                    TrashedCardView(item: item)
                                } else {
                                    WishCardView(item: item)
                                }
                            }
                            // Per-card removal animation (mark bought / delete)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                )
                            )
                        }
                    }
                    totalFooter
                        .animation(
                            .spring(response: 0.38, dampingFraction: 0.78),
                            value: items.map { $0.id }
                        )
                }
            }
            .padding(24)
            .frame(maxWidth: 860, alignment: .leading)
        }
        // No .id() or .transition() here — the parent ContentView
        // handles the full-view slide via ZStack + .id(displayedItem).
    }

    private var header: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(secondaryText)
            }
            Spacer()
            if !items.isEmpty && !isDeletedView {
                Text("Sorted by \(sortOption.rawValue.lowercased())")
                    .font(.caption)
                    .foregroundStyle(secondaryText.opacity(0.7))
            }
        }
        .padding(.bottom, 4)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: emptyIcon)
                .font(.system(size: 32))
                .foregroundStyle(amber)

            Text(emptyTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(primaryText)

            Text(emptyMessage)
                .foregroundStyle(secondaryText)

            if !isBoughtView && !isDeletedView {
                Button(action: onAddWish) {
                    Label("Add Your First Wish", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(amber)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.98, green: 0.96, blue: 0.92))
                .shadow(color: .black.opacity(0.07), radius: 8, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(red: 0.80, green: 0.74, blue: 0.64).opacity(0.5), lineWidth: 1)
        )
    }

    private var emptyIcon: String {
        if isDeletedView { return "trash" }
        if isBoughtView { return "checkmark.seal" }
        return "gift"
    }
    private var emptyTitle: String {
        if isDeletedView { return "Trash is empty" }
        if isBoughtView { return "Nothing bought yet" }
        return "No wishes yet"
    }
    private var emptyMessage: String {
        if isDeletedView { return "Deleted wishes appear here and are removed after 3 days." }
        if isBoughtView { return "Mark wishes as bought and they'll appear here." }
        return "Start your list by adding something you'd love to have."
    }

    private var totalSum: Double {
        items.compactMap { $0.price }.reduce(0, +)
    }

    private var hasPrices: Bool {
        items.contains { $0.price != nil }
    }

    @ViewBuilder
    private var totalFooter: some View {
        if hasPrices && !isDeletedView {
            HStack {
                Text("Total")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(secondaryText)
                Spacer()
                Text(
                    totalSum, format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                )
                .font(.title3.weight(.bold))
                .foregroundStyle(primaryText)
                .monospacedDigit()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .padding(.top, 4)
        }
    }

}

//  Views/WishListView.swift

import SwiftUI

struct WishListView: View {
    let title: String
    let subtitle: String
    let items: [WishItem]
    let selectedCategory: WishCategory?
    let onAddWish: () -> Void

    // Consistent dark text colors — readable on the warm tan window background
    private let primaryText   = Color(red: 0.16, green: 0.13, blue: 0.10)
    private let secondaryText = Color(red: 0.42, green: 0.38, blue: 0.32)
    private let amber         = Color(red: 0.78, green: 0.55, blue: 0.08)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if items.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 14) {
                        ForEach(items) { item in
                            WishCardView(item: item)
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 860, alignment: .leading)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(primaryText)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(secondaryText)
        }
        .padding(.bottom, 4)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "gift")
                .font(.system(size: 32))
                .foregroundStyle(amber)

            Text("No wishes yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(primaryText)

            Text("Start your list by adding something you'd love to have.")
                .foregroundStyle(secondaryText)

            Button(action: onAddWish) {
                Label("Add Your First Wish", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(amber)
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
}

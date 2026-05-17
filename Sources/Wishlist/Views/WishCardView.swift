//  Views/WishCardView.swift

import SwiftUI

struct WishCardView: View {
    @Environment(WishStore.self) private var store
    let item: WishItem

    @State private var showingEdit      = false
    @State private var confirmingDelete = false

    private let primaryText   = Color(red: 0.16, green: 0.13, blue: 0.10)
    private let secondaryText = Color(red: 0.42, green: 0.38, blue: 0.32)
    private let deleteRed     = Color(red: 0.72, green: 0.20, blue: 0.15)

    private var priorityColor: Color {
        switch item.priority {
        case .high:   return Color(red: 0.78, green: 0.55, blue: 0.08)
        case .medium: return Color(red: 0.55, green: 0.48, blue: 0.20)
        case .low:    return Color(red: 0.42, green: 0.40, blue: 0.36)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Image ──────────────────────────────────────────────────────
            if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.92, green: 0.88, blue: 0.82))
                    case .failure:
                        HStack {
                            Spacer()
                            Label("Image unavailable", systemImage: "photo")
                                .foregroundStyle(secondaryText).font(.caption)
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .background(Color(red: 0.92, green: 0.88, blue: 0.82))
                    case .empty:
                        ZStack {
                            Color(red: 0.92, green: 0.88, blue: 0.82)
                            ProgressView()
                        }.frame(height: 120)
                    @unknown default: EmptyView()
                    }
                }
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 20, bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0, topTrailingRadius: 20,
                    style: .continuous))
            }

            // ── Body ──────────────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 14) {

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.name)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(item.isBought ? secondaryText : primaryText)
                            .strikethrough(item.isBought)
                        if let price = item.formattedPrice {
                            Text(price)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(item.isBought ? secondaryText : priorityColor)
                        }
                    }
                    Spacer()
                    Label(item.priority.rawValue, systemImage: item.priority.icon)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(priorityColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(priorityColor)
                }

                if let notes = item.notes, !notes.isEmpty {
                    Text(notes).font(.subheadline).foregroundStyle(secondaryText)
                }

                Text("Added \(item.createdAt.formatted(.dateTime.day().month(.wide).year()))")
                    .font(.caption2).foregroundStyle(secondaryText.opacity(0.6))

                Divider().background(Color(red: 0.75, green: 0.70, blue: 0.63))

                // ── Actions ───────────────────────────────────────────────
                HStack(spacing: 4) {
                    if let url = item.url {
                        Link(destination: url) {
                            Label("Open Link", systemImage: "arrow.up.right.square")
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10).padding(.vertical, 6)
                        }
                        .foregroundStyle(priorityColor)
                    }

                    Spacer()

                    // Duplicate
                    CardButton(tint: secondaryText) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            store.duplicate(item)
                        }
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(secondaryText)
                    }
                    .help("Duplicate wish")

                    // Edit
                    CardButton(tint: secondaryText) {
                        showingEdit = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(secondaryText)
                    }
                    .help("Edit wish (or double-click card)")

                    // Mark Bought
                    CardButton(tint: priorityColor, bordered: true) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                            store.toggleBought(item)
                        }
                    } label: {
                        Text(item.isBought ? "Unmark" : "Mark Bought")
                            .font(.subheadline)
                            .foregroundStyle(item.isBought ? secondaryText : priorityColor)
                    }

                    // Delete — two-step
                    if confirmingDelete {
                        CardButton(tint: deleteRed, bordered: true) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                store.softDelete(item)
                            }
                        } label: {
                            Text("Are you sure?")
                                .font(.subheadline)
                                .foregroundStyle(deleteRed)
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        CardButton(tint: deleteRed) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                confirmingDelete = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation { confirmingDelete = false }
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(deleteRed.opacity(0.7))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: confirmingDelete)
            }
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.98, green: 0.96, blue: 0.92))
                .shadow(color: Color(red: 0.55, green: 0.45, blue: 0.30).opacity(0.12),
                        radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(red: 0.80, green: 0.74, blue: 0.64).opacity(0.5), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture(count: 2) { showingEdit = true }
        .sheet(isPresented: $showingEdit) {
            EditWishView(item: item).environment(store)
        }
    }
}

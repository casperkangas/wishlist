//  Views/WishCardView.swift

import SwiftUI

struct WishCardView: View {
    @Environment(WishStore.self) private var store
    let item: WishItem

    private var priorityColor: Color {
        switch item.priority {
        case .low:    return Color(red: 0.50, green: 0.54, blue: 0.58)   // muted silver
        case .medium: return Color(red: 0.65, green: 0.50, blue: 0.25)   // warm amber
        case .high:   return Color(red: 0.78, green: 0.55, blue: 0.08)   // bright amber
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(item.isBought
                            ? Color(red: 0.55, green: 0.52, blue: 0.48)
                            : Color(red: 0.18, green: 0.15, blue: 0.12)  // near-black warm
                        )
                        .strikethrough(item.isBought)

                    if let price = item.formattedPrice {
                        Text(price)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(item.isBought
                                ? Color(red: 0.55, green: 0.52, blue: 0.48)
                                : priorityColor
                            )
                    }
                }

                Spacer()

                // Priority badge
                Label(item.priority.rawValue, systemImage: item.priority.icon)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(priorityColor.opacity(0.15),
                                in: Capsule())
                    .foregroundStyle(priorityColor)
            }

            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.40, green: 0.37, blue: 0.33))
            }

            Divider()
                .background(Color(red: 0.75, green: 0.70, blue: 0.63))

            HStack {
                if let url = item.url {
                    Link(destination: url) {
                        Label("Open Link", systemImage: "arrow.up.right.square")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.link)
                    .foregroundStyle(priorityColor)
                }

                Spacer()

                Button(item.isBought ? "Unmark" : "Mark Bought") {
                    store.toggleBought(item)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(priorityColor)

                Button(role: .destructive) {
                    store.delete(item)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color(red: 0.60, green: 0.35, blue: 0.30))
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(20)
        // Card background: warm parchment, clearly distinct from window background
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
    }
}

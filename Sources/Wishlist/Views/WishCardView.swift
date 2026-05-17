//  Views/WishCardView.swift

import SwiftUI

// MARK: - HoverButtonStyle
// All visual chrome (background tint, optional border, scale) lives
// inside ONE ButtonStyle so no extra modifiers are stacked outside it.
// Stacking .overlay() after a ButtonStyle forces an extra geometry pass
// on every frame and causes the ~1s response delay on macOS.
struct HoverButtonStyle: ButtonStyle {
    var hoverTint: Color
    var bordered: Bool = false
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isHovered ? hoverTint.opacity(0.18) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(bordered ? hoverTint.opacity(0.45) : Color.clear, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.easeOut(duration: 0.10), value: isHovered)
            .animation(.easeOut(duration: 0.06), value: configuration.isPressed)
            .onHover { isHovered = $0 }
    }
}

// MARK: - WishCardView
struct WishCardView: View {
    @Environment(WishStore.self) private var store
    @Environment(\.accentHue) private var accentHue
    let item: WishItem

    @State private var showingEdit      = false
    @State private var confirmingDelete = false

    private let primaryText   = Color(red: 0.16, green: 0.13, blue: 0.10)
    private let secondaryText = Color(red: 0.42, green: 0.38, blue: 0.32)
    private let deleteRed     = Color(red: 0.72, green: 0.20, blue: 0.15)

    // High priority uses the user-chosen accent hue.
    // Medium and Low shift the hue by fixed offsets so they stay distinct.
    private var priorityColor: Color {
        switch item.priority {
        case .high:   return Color(hue: accentHue / 360,          saturation: 0.72, brightness: 0.78)
        case .medium: return Color(hue: (accentHue + 30) / 360,   saturation: 0.55, brightness: 0.68)
        case .low:    return Color(hue: (accentHue + 180) / 360,  saturation: 0.20, brightness: 0.58)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Image ──────────────────────────────────────────────────────
            if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
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
                        }
                        .buttonStyle(HoverButtonStyle(hoverTint: priorityColor))
                        .foregroundStyle(priorityColor)
                    }

                    Spacer()

                    // Edit pencil — no border, instant
                    Button { showingEdit = true } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(HoverButtonStyle(hoverTint: secondaryText))
                    .foregroundStyle(secondaryText)
                    .help("Edit wish (or double-click card)")

                    // Mark Bought — border lives inside HoverButtonStyle
                    Button(item.isBought ? "Unmark" : "Mark Bought") {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                            store.toggleBought(item)
                        }
                    }
                    .buttonStyle(HoverButtonStyle(hoverTint: priorityColor, bordered: true))
                    .foregroundStyle(item.isBought ? secondaryText : priorityColor)

                    // Delete with 2-step confirmation
                    if confirmingDelete {
                        Button("Are you sure?") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                store.softDelete(item)
                            }
                        }
                        .buttonStyle(HoverButtonStyle(hoverTint: deleteRed, bordered: true))
                        .foregroundStyle(deleteRed)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                confirmingDelete = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    confirmingDelete = false
                                }
                            }
                        } label: { Image(systemName: "trash") }
                        .buttonStyle(HoverButtonStyle(hoverTint: deleteRed))
                        .foregroundStyle(deleteRed.opacity(0.7))
                        .transition(.scale.combined(with: .opacity))
                    }
                }
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

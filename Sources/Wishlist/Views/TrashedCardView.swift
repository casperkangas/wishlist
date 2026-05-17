//  Views/TrashedCardView.swift

import SwiftUI

struct TrashedCardView: View {
    @Environment(WishStore.self) private var store
    let item: WishItem

    @State private var confirmingPermanent = false

    private let primaryText = Color(red: 0.16, green: 0.13, blue: 0.10)
    private let secondaryText = Color(red: 0.42, green: 0.38, blue: 0.32)
    private let red = Color(red: 0.72, green: 0.20, blue: 0.15)

    private var daysRemaining: Int {
        let deleted = item.deletedAt ?? Date()
        let expiry = Calendar.current.date(byAdding: .day, value: 3, to: deleted) ?? Date()
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail
            if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        Color(red: 0.88, green: 0.84, blue: 0.78)
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(primaryText)
                    .strikethrough()
                HStack(spacing: 6) {
                    if let price = item.formattedPrice {
                        Text(price).font(.subheadline).foregroundStyle(secondaryText)
                    }
                    Text("·").foregroundStyle(secondaryText.opacity(0.5))
                    Text("Deleted \(item.deletedAt?.formatted(.dateTime.day().month()) ?? "")")
                        .font(.caption)
                        .foregroundStyle(secondaryText.opacity(0.7))
                    Text("·").foregroundStyle(secondaryText.opacity(0.5))
                    Text("\(daysRemaining)d left")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(daysRemaining <= 1 ? red : secondaryText.opacity(0.7))
                }
            }

            Spacer()

            // Actions
            Button("Restore") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    store.restore(item)
                }
            }
            .buttonStyle(HoverButtonStyle(hoverTint: Color(red: 0.78, green: 0.55, blue: 0.08)))
            .foregroundStyle(Color(red: 0.78, green: 0.55, blue: 0.08))

            if confirmingPermanent {
                Button("Delete forever?") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        store.hardDelete(item)
                    }
                }
                .buttonStyle(HoverButtonStyle(hoverTint: red))
                .foregroundStyle(red)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        confirmingPermanent = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { confirmingPermanent = false }
                    }
                } label: {
                    Image(systemName: "trash.slash")
                }
                .buttonStyle(HoverButtonStyle(hoverTint: red))
                .foregroundStyle(red.opacity(0.7))
                .help("Permanently delete")
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.95, green: 0.92, blue: 0.88).opacity(0.7))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(red: 0.80, green: 0.74, blue: 0.64).opacity(0.4), lineWidth: 1)
        )
    }
}

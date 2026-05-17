//  Views/SidebarView.swift

import SwiftUI

struct SidebarView: View {
    @Environment(WishStore.self) private var store
    @Binding var selectedItem: SidebarItem?

    // Persisted accent hue (0–360). Default 38 = warm amber.
    @AppStorage("accentHue") private var accentHue: Double = 38

    // Categories sorted by the most recently added live wish
    private var sortedCategories: [WishCategory] {
        store.categories.sorted { a, b in
            let latestA = store.items
                .filter { !$0.isDeleted && $0.categoryID == a.id }
                .map(\.createdAt).max() ?? .distantPast
            let latestB = store.items
                .filter { !$0.isDeleted && $0.categoryID == b.id }
                .map(\.createdAt).max() ?? .distantPast
            return latestA > latestB
        }
    }

    private func liveCount(for category: WishCategory) -> Int {
        store.items.filter { !$0.isDeleted && !$0.isBought && $0.categoryID == category.id }.count
    }
    private func priorityCount(_ p: Priority) -> Int {
        store.items.filter { !$0.isDeleted && !$0.isBought && $0.priority == p }.count
    }
    private var allCount:     Int { store.items.filter { !$0.isDeleted && !$0.isBought }.count }
    private var boughtCount:  Int { store.items.filter { !$0.isDeleted && $0.isBought }.count }
    private var trashedCount: Int { store.trashedItems.count }

    var body: some View {
        List(selection: $selectedItem) {

            Section("Browse") {
                SidebarRow(label: "All Wishes",  icon: "sparkles",           count: allCount)
                    .tag(SidebarItem.all)
                SidebarRow(label: "Bought",       icon: "checkmark.seal.fill", count: boughtCount)
                    .tag(SidebarItem.bought)
                SidebarRow(label: "Deleted",      icon: "trash",              count: trashedCount)
                    .tag(SidebarItem.deleted)
            }

            Section("By Priority") {
                SidebarRow(label: "High Priority",   icon: "arrow.up.circle.fill",   count: priorityCount(.high))
                    .tag(SidebarItem.priority(.high))
                SidebarRow(label: "Medium Priority", icon: "minus.circle.fill",       count: priorityCount(.medium))
                    .tag(SidebarItem.priority(.medium))
                SidebarRow(label: "Low Priority",    icon: "arrow.down.circle.fill", count: priorityCount(.low))
                    .tag(SidebarItem.priority(.low))
            }

            Section("Categories") {
                ForEach(sortedCategories) { category in
                    SidebarRow(label: category.name, icon: category.icon, count: liveCount(for: category))
                        .tag(SidebarItem.category(category.id))
                }
            }

            // ── Accent colour ─────────────────────────────────────
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Accent Colour")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        // Small swatch preview
                        Circle()
                            .fill(Color(hue: accentHue / 360, saturation: 0.72, brightness: 0.78))
                            .frame(width: 14, height: 14)
                    }

                    // Rainbow gradient track with a slider overlay
                    ZStack(alignment: .leading) {
                        LinearGradient(
                            stops: stride(from: 0.0, through: 1.0, by: 0.05).map { h in
                                .init(color: Color(hue: h, saturation: 0.72, brightness: 0.78),
                                      location: h)
                            },
                            startPoint: .leading, endPoint: .trailing
                        )
                        .frame(height: 6)
                        .clipShape(Capsule())

                        Slider(value: $accentHue, in: 0...360)
                            .opacity(0.015) // invisible but interactive
                    }
                    .frame(height: 20)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Wishlist ✨")
        .listStyle(.sidebar)
        // Broadcast the chosen hue into the environment so cards can read it
        .environment(\.accentHue, accentHue)
    }
}

// MARK: - SidebarRow
struct SidebarRow: View {
    let label: String
    let icon:  String
    let count: Int

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            if count > 0 {
                Text("\(count)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

// MARK: - Environment key so child views can read the chosen hue
struct AccentHueKey: EnvironmentKey {
    static let defaultValue: Double = 38
}
extension EnvironmentValues {
    var accentHue: Double {
        get { self[AccentHueKey.self] }
        set { self[AccentHueKey.self] = newValue }
    }
}

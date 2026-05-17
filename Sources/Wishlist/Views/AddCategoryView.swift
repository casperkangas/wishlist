//  Views/AddCategoryView.swift

import SwiftUI

struct AddCategoryView: View {
    @Environment(WishStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedIcon: String = "star"
    @State private var searchText: String = ""

    // SF Symbols commonly used in wishlist/shopping contexts
    // grouped for easy browsing
    private let iconGroups: [(String, [String])] = [
        (
            "Objects",
            [
                "star", "heart", "gift", "bag", "cart", "creditcard",
                "tag", "ticket", "crown", "trophy", "medal",
                "camera", "headphones", "keyboard", "gamecontroller",
                "tv", "phone", "laptopcomputer", "desktopcomputer", "printer",
                "watch.analog", "earbuds", "airpodspro",
            ]
        ),
        (
            "Home & Life",
            [
                "house", "sofa", "bed.double", "lamp.desk", "fork.knife",
                "cup.and.saucer", "wineglass", "cabinet", "washer", "refrigerator",
                "paintbrush", "hammer", "wrench", "lightbulb", "plant",
            ]
        ),
        (
            "Clothing & Style",
            [
                "tshirt", "shoe", "eyeglasses", "sunglasses", "backpack",
                "suitcase", "umbrella", "figure.walk", "figure.run",
                "sportscourt", "bicycle", "dumbbell",
            ]
        ),
        (
            "Culture & Learning",
            [
                "books.vertical", "book", "magazine", "music.note",
                "music.mic", "guitars", "theatermasks", "film",
                "photo", "paintpalette", "pencil", "graduationcap",
            ]
        ),
        (
            "Travel & Nature",
            [
                "airplane", "car", "bus", "tram", "ferry",
                "map", "mappin", "mountain.2", "tent", "beach.umbrella",
                "leaf", "flame", "drop", "snowflake", "sun.max",
            ]
        ),
        (
            "Health & Food",
            [
                "cross", "pills", "bandage", "stethoscope",
                "carrot", "birthday.cake", "takeoutbag.and.cup.and.straw",
                "fork.knife.circle", "apple.logo",
            ]
        ),
    ]

    private var filteredGroups: [(String, [String])] {
        if searchText.isEmpty { return iconGroups }
        let q = searchText.lowercased()
        return iconGroups.compactMap { (title, icons) in
            let filtered = icons.filter { $0.contains(q) }
            return filtered.isEmpty ? nil : (title, filtered)
        }
    }

    private let columns = Array(repeating: GridItem(.fixed(44), spacing: 8), count: 7)

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Category")
                    .font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            // Name field
            HStack(spacing: 12) {
                // Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: selectedIcon)
                        .font(.system(size: 22))
                        .foregroundStyle(Color.accentColor)
                }

                TextField("Category name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
            }
            .padding()

            Divider()

            // Icon search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search icons…", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.textBackgroundColor).opacity(0.5))

            Divider()

            // Icon grid
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(filteredGroups, id: \.0) { (groupName, icons) in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(groupName)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)

                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(icons, id: \.self) { icon in
                                    Button {
                                        withAnimation(.spring(response: 0.2)) {
                                            selectedIcon = icon
                                        }
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    selectedIcon == icon
                                                        ? Color.accentColor.opacity(0.18)
                                                        : Color.clear)
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(
                                                    selectedIcon == icon
                                                        ? Color.accentColor
                                                        : Color.clear, lineWidth: 1.5)
                                            Image(systemName: icon)
                                                .font(.system(size: 20))
                                                .foregroundStyle(
                                                    selectedIcon == icon
                                                        ? Color.accentColor
                                                        : Color.primary)
                                        }
                                        .frame(width: 44, height: 44)
                                    }
                                    .buttonStyle(.plain)
                                    .help(icon)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 12)
            }
        }
        .frame(width: 380, height: 520)
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let category = WishCategory(name: trimmed, icon: selectedIcon)
        store.addCategory(category)
        dismiss()
    }
}

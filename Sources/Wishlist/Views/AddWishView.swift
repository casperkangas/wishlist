//  Views/AddWishView.swift

import AppKit
import SwiftUI

struct AddWishView: View {
    @Environment(WishStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let preselectedCategoryID: UUID?

    @State private var name = ""
    @State private var price = ""
    @State private var urlString = ""
    @State private var imageURLString = ""
    @State private var notes = ""
    @State private var priority: Priority = .medium
    @State private var categoryID: UUID?
    @State private var showingValidation = false

    // Focus management — auto-focus the name field so keyboard works immediately
    @FocusState private var focusedField: Field?
    private enum Field { case name }

    init(preselectedCategoryID: UUID?) {
        self.preselectedCategoryID = preselectedCategoryID
        _categoryID = State(initialValue: preselectedCategoryID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add Wish")
                .font(.system(size: 28, weight: .semibold, design: .rounded))

            Form {
                Section {
                    TextField("Name", text: $name)
                        .focused($focusedField, equals: .name)

                    TextField("Price (e.g. 29.99)", text: $price)

                    TextField("Link", text: $urlString)

                    TextField("Image URL (optional)", text: $imageURLString)
                }

                Section {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases.reversed()) { level in
                            Label(level.rawValue, systemImage: level.icon)
                                .tag(level)
                        }
                    }

                    Picker("Category", selection: $categoryID) {
                        Text("None").tag(nil as UUID?)
                        ForEach(store.categories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category.id as UUID?)
                        }
                    }
                }

                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(4...8)
                }
            }
            .formStyle(.grouped)

            if showingValidation && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Please add a name for your wish.")
                    .foregroundStyle(.red)
                    .font(.caption)
                    .padding(.horizontal, 4)
            }

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])

                Button("Save Wish") {
                    saveWish()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.78, green: 0.67, blue: 0.40))
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(24)
        .frame(minWidth: 520, minHeight: 520)
        .background(.regularMaterial)
        .onAppear {
            // Claim keyboard focus from VS Code / terminal
            NSApplication.shared.activate(ignoringOtherApps: true)
            // Small delay so the sheet animation finishes before focusing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedField = .name
            }
        }
    }

    private func saveWish() {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            showingValidation = true
            return
        }

        let parsedPrice = Double(price.replacingOccurrences(of: ",", with: "."))

        let item = WishItem(
            name: cleanName,
            price: parsedPrice,
            urlString: urlString.isEmpty ? nil : urlString,
            imageURLString: imageURLString.isEmpty ? nil : imageURLString,
            notes: notes.isEmpty ? nil : notes,
            priority: priority,
            categoryID: categoryID
        )

        store.add(item)
        dismiss()
    }
}

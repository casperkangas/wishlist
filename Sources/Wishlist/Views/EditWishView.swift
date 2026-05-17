//  Views/EditWishView.swift

import AppKit
import SwiftUI

struct EditWishView: View {
    @Environment(WishStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let item: WishItem

    @State private var name: String
    @State private var price: String
    @State private var urlString: String
    @State private var imageURLString: String
    @State private var notes: String
    @State private var priority: Priority
    @State private var categoryID: UUID?
    @State private var showValidation = false

    @FocusState private var focusedField: Field?
    private enum Field { case name }

    init(item: WishItem) {
        self.item = item
        _name = State(initialValue: item.name)
        _price = State(initialValue: item.price.map { String($0) } ?? "")
        _urlString = State(initialValue: item.urlString ?? "")
        _imageURLString = State(initialValue: item.imageURLString ?? "")
        _notes = State(initialValue: item.notes ?? "")
        _priority = State(initialValue: item.priority)
        _categoryID = State(initialValue: item.categoryID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit Wish")
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
                        ForEach(Priority.allCases) { level in
                            Label(level.rawValue, systemImage: level.icon).tag(level)
                        }
                    }
                    Picker("Category", selection: $categoryID) {
                        Text("None").tag(nil as UUID?)
                        ForEach(store.categories) { cat in
                            Label(cat.name, systemImage: cat.icon).tag(cat.id as UUID?)
                        }
                    }
                }

                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(4...8)
                }
            }
            .formStyle(.grouped)

            if showValidation && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Please add a name for your wish.")
                    .foregroundStyle(.red)
                    .font(.caption)
                    .padding(.horizontal, 4)
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])
                Button("Save Changes") { save() }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.78, green: 0.67, blue: 0.40))
                    .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(24)
        .frame(minWidth: 520, minHeight: 520)
        .background(.regularMaterial)
        .onAppear {
            NSApplication.shared.activate(ignoringOtherApps: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedField = .name
            }
        }
    }

    private func save() {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            showValidation = true
            return
        }

        var updated = item
        updated.name = cleanName
        updated.price = Double(price.replacingOccurrences(of: ",", with: "."))
        updated.urlString = urlString.isEmpty ? nil : urlString
        updated.imageURLString = imageURLString.isEmpty ? nil : imageURLString
        updated.notes = notes.isEmpty ? nil : notes
        updated.priority = priority
        updated.categoryID = categoryID

        store.update(updated)
        dismiss()
    }
}

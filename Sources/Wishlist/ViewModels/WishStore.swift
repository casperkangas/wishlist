//  ViewModels/WishStore.swift
//  Observable store — holds all data and handles JSON persistence.

import Foundation
import Observation

@Observable
final class WishStore {

    // MARK: – State
    var items:      [WishItem]      = []
    var categories: [WishCategory]  = WishCategory.defaults

    // MARK: – Persistence
    private static var saveURL: URL {
        let dir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Wishlist", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir,
                                                 withIntermediateDirectories: true)
        return dir.appendingPathComponent("data.json")
    }

    init() {
        load()
    }

    // MARK: – CRUD

    func add(_ item: WishItem) {
        items.append(item)
        save()
    }

    func update(_ item: WishItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(_ item: WishItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func toggleBought(_ item: WishItem) {
        var copy = item
        copy.isBought.toggle()
        update(copy)
    }

    func addCategory(_ category: WishCategory) {
        categories.append(category)
        save()
    }

    func deleteCategory(_ category: WishCategory) {
        categories.removeAll { $0.id == category.id }
        for i in items.indices where items[i].categoryID == category.id {
            items[i].categoryID = nil
        }
        save()
    }

    // MARK: – Helpers

    func items(for category: WishCategory?) -> [WishItem] {
        guard let category else { return items }
        return items.filter { $0.categoryID == category.id }
    }

    // MARK: – JSON I/O

    private struct SaveData: Codable {
        var items:      [WishItem]
        var categories: [WishCategory]
    }

    private func save() {
        let data = SaveData(items: items, categories: categories)
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: Self.saveURL, options: .atomic)
        }
    }

    private func load() {
        guard let data    = try? Data(contentsOf: Self.saveURL),
              let decoded = try? JSONDecoder().decode(SaveData.self, from: data)
        else { return }
        items      = decoded.items
        categories = decoded.categories
    }
}

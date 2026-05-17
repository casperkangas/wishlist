//  ViewModels/WishStore.swift

import Foundation
import Observation

@Observable
final class WishStore {

    var items: [WishItem] = []
    var categories: [WishCategory] = WishCategory.defaults

    private static let trashRetentionDays = 3

    private static var saveURL: URL {
        let dir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Wishlist", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("data.json")
    }

    init() {
        load()
        purgeExpiredTrash()
    }

    // MARK: - CRUD

    func add(_ item: WishItem) {
        items.append(item)
        save()
    }

    func update(_ item: WishItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    /// Soft-delete: moves item to trash by stamping deletedAt
    func softDelete(_ item: WishItem) {
        var copy = item
        copy.deletedAt = Date()
        update(copy)
    }

    /// Hard-delete: permanently removes item
    func hardDelete(_ item: WishItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    /// Restore a trashed item
    func restore(_ item: WishItem) {
        var copy = item
        copy.deletedAt = nil
        update(copy)
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

    // MARK: - Queries

    /// Live (non-deleted) items, optionally filtered by category
    func items(for category: WishCategory?) -> [WishItem] {
        let live = items.filter { !$0.isDeleted }
        guard let category else { return live }
        return live.filter { $0.categoryID == category.id }
    }

    /// Live items filtered by priority
    func items(for priority: Priority) -> [WishItem] {
        items.filter { !$0.isDeleted && $0.priority == priority }
    }

    /// Items currently in trash
    var trashedItems: [WishItem] {
        items.filter { $0.isDeleted }
            .sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
    }

    // MARK: - Auto-purge trash after 3 days
    func purgeExpiredTrash() {
        let cutoff =
            Calendar.current.date(
                byAdding: .day, value: -Self.trashRetentionDays, to: Date()
            ) ?? Date()
        items.removeAll { item in
            guard let deletedAt = item.deletedAt else { return false }
            return deletedAt < cutoff
        }
        save()
    }

    // MARK: - Persistence

    private struct SaveData: Codable {
        var items: [WishItem]
        var categories: [WishCategory]
    }

    func save() {
        let data = SaveData(items: items, categories: categories)
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: Self.saveURL, options: .atomic)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: Self.saveURL),
            let decoded = try? JSONDecoder().decode(SaveData.self, from: data)
        else { return }
        items = decoded.items
        categories = decoded.categories
    }
}

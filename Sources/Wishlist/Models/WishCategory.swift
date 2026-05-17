//  Models/WishCategory.swift

import Foundation

struct WishCategory: Identifiable, Codable, Equatable {
    var id:   UUID   = UUID()
    var name: String
    var icon: String

    static let defaults: [WishCategory] = [
        WishCategory(name: "Tech",    icon: "laptopcomputer"),
        WishCategory(name: "Clothes", icon: "tshirt"),
        WishCategory(name: "Books",   icon: "books.vertical"),
        WishCategory(name: "Travel",  icon: "airplane"),
        WishCategory(name: "Home",    icon: "house"),
    ]
}

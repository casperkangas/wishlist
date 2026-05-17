//  Models/WishItem.swift

import Foundation

enum Priority: String, Codable, CaseIterable, Identifiable {
    case low    = "Low"
    case medium = "Medium"
    case high   = "High"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .low:    return "arrow.down.circle.fill"
        case .medium: return "minus.circle.fill"
        case .high:   return "arrow.up.circle.fill"
        }
    }
}

struct WishItem: Identifiable, Codable, Equatable {
    var id: UUID          = UUID()
    var name: String
    var price: Double?
    var urlString: String?
    var imageURLString: String?
    var notes: String?
    var priority: Priority = .medium
    var categoryID: UUID?
    var isBought: Bool    = false
    var createdAt: Date   = Date()

    var url: URL? {
        guard let s = urlString, !s.isEmpty else { return nil }
        return URL(string: s)
    }

    var imageURL: URL? {
        guard let s = imageURLString, !s.isEmpty else { return nil }
        return URL(string: s)
    }

    var formattedPrice: String? {
        guard let price else { return nil }
        let f = NumberFormatter()
        f.numberStyle           = .currency
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: price))
    }
}

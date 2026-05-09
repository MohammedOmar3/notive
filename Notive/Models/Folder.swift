import Foundation

struct Folder: Identifiable, Codable, Equatable, Hashable, Sendable {
    var id: UUID
    var name: String
    var createdAt: Date
    /// Hex colour string, e.g. "#6B6BFF"
    var color: String

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        color: String = "#6B6BFF"
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.color = color
    }
}

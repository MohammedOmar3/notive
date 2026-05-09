import Foundation

struct Note: Identifiable, Codable, Equatable, Hashable, Sendable {
    var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var folderID: UUID?
    var tags: [String]
    var isPinned: Bool

    // MARK: - Computed

    var wordCount: Int {
        guard !body.isEmpty else { return 0 }
        return body.split(whereSeparator: \.isWhitespace).count
    }

    /// First 120 characters of body — used in list preview rows.
    var preview: String {
        String(body.prefix(120))
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        title: String = "",
        body: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        folderID: UUID? = nil,
        tags: [String] = [],
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.folderID = folderID
        self.tags = tags
        self.isPinned = isPinned
    }

    static func makeEmpty() -> Note {
        Note()
    }
}

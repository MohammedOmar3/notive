import Foundation

struct TagRepository {
    private let manager: DatabaseManager

    init(manager: DatabaseManager = .shared) {
        self.manager = manager
    }

    func fetchAll() async throws -> [Tag] {
        try await manager.fetchAllTags()
    }

    func fetch(name: String) async throws -> Tag? {
        try await manager.fetchTag(name: name)
    }

    func insert(_ tag: Tag) async throws {
        try await manager.insertTag(tag)
    }

    func delete(id: UUID) async throws {
        try await manager.deleteTag(id: id)
    }

    func countNotes(forTag name: String) async throws -> Int {
        try await manager.countNotes(forTag: name)
    }
}

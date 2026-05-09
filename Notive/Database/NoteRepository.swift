import Foundation

struct NoteRepository {
    private let manager: DatabaseManager

    init(manager: DatabaseManager = .shared) {
        self.manager = manager
    }

    func fetchAll() async throws -> [Note] {
        try await manager.fetchAllNotes()
    }

    func fetch(id: UUID) async throws -> Note? {
        try await manager.fetchNote(id: id)
    }

    func fetch(folderID: UUID) async throws -> [Note] {
        try await manager.fetchNotes(folderID: folderID)
    }

    func fetch(tag: String) async throws -> [Note] {
        try await manager.fetchNotes(tag: tag)
    }

    func fetchPinned() async throws -> [Note] {
        try await manager.fetchPinnedNotes()
    }

    func insert(_ note: Note) async throws {
        try await manager.insertNote(note)
    }

    func update(_ note: Note) async throws {
        try await manager.updateNote(note)
    }

    func delete(id: UUID) async throws {
        try await manager.deleteNote(id: id)
    }

    func count() async throws -> Int {
        try await manager.countNotes()
    }

    func count(folderID: UUID) async throws -> Int {
        try await manager.countNotes(folderID: folderID)
    }

    func countPinned() async throws -> Int {
        try await manager.countPinnedNotes()
    }

    func unassign(fromFolder folderID: UUID) async throws {
        try await manager.unassignNotes(fromFolder: folderID)
    }

    func search(query: String) async throws -> [Note] {
        try await manager.searchNotes(query: query)
    }
}

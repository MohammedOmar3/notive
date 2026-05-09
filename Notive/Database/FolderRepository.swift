import Foundation

struct FolderRepository {
    private let manager: DatabaseManager

    init(manager: DatabaseManager = .shared) {
        self.manager = manager
    }

    func fetchAll() async throws -> [Folder] {
        try await manager.fetchAllFolders()
    }

    func fetch(id: UUID) async throws -> Folder? {
        try await manager.fetchFolder(id: id)
    }

    func insert(_ folder: Folder) async throws {
        try await manager.insertFolder(folder)
    }

    func update(_ folder: Folder) async throws {
        try await manager.updateFolder(folder)
    }

    func delete(id: UUID) async throws {
        try await manager.deleteFolder(id: id)
    }
}

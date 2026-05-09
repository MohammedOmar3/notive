import Foundation
import SQLite

// MARK: - Folders CRUD

extension DatabaseManager {

    func fetchAllFolders() throws -> [Folder] {
        let db = try connection()
        var folders: [Folder] = []
        let rows = try db.prepare(
            "SELECT id, name, created_at, color FROM folders ORDER BY name ASC"
        )
        for row in rows { folders.append(try mapFolder(row)) }
        return folders
    }

    func fetchFolder(id: UUID) throws -> Folder? {
        let db = try connection()
        let rows = try db.prepare(
            "SELECT id, name, created_at, color FROM folders WHERE id = ? LIMIT 1",
            id.uuidString
        )
        return try rows.makeIterator().next().map { try mapFolder($0) }
    }

    func insertFolder(_ folder: Folder) throws {
        let db = try connection()
        try db.run(
            "INSERT INTO folders (id, name, created_at, color) VALUES (?, ?, ?, ?)",
            folder.id.uuidString,
            folder.name,
            folder.createdAt.timeIntervalSince1970,
            folder.color
        )
    }

    func updateFolder(_ folder: Folder) throws {
        let db = try connection()
        try db.run(
            "UPDATE folders SET name = ?, color = ? WHERE id = ?",
            folder.name,
            folder.color,
            folder.id.uuidString
        )
    }

    func deleteFolder(id: UUID) throws {
        let db = try connection()
        try db.run("DELETE FROM folders WHERE id = ?", id.uuidString)
    }

    // MARK: - Private mapper

    private func mapFolder(_ row: Statement.Element) throws -> Folder {
        guard
            let idStr = row[0] as? String, let id = UUID(uuidString: idStr),
            let name  = row[1] as? String,
            let ts    = row[2] as? Double,
            let color = row[3] as? String
        else {
            throw DatabaseError.mappingFailed("folders row missing required fields")
        }
        return Folder(id: id, name: name, createdAt: Date(timeIntervalSince1970: ts), color: color)
    }
}

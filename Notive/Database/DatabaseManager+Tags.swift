import Foundation
import SQLite

// MARK: - Tags CRUD

extension DatabaseManager {

    func fetchAllTags() throws -> [Tag] {
        let db = try connection()
        var tags: [Tag] = []
        let rows = try db.prepare(
            "SELECT id, name, created_at FROM tags ORDER BY name ASC"
        )
        for row in rows { tags.append(try mapTag(row)) }
        return tags
    }

    func fetchTag(name: String) throws -> Tag? {
        let db = try connection()
        let rows = try db.prepare(
            "SELECT id, name, created_at FROM tags WHERE name = ? LIMIT 1",
            name
        )
        return try rows.makeIterator().next().map { try mapTag($0) }
    }

    func insertTag(_ tag: Tag) throws {
        let db = try connection()
        // INSERT OR IGNORE keeps the unique constraint intact without throwing
        try db.run(
            "INSERT OR IGNORE INTO tags (id, name, created_at) VALUES (?, ?, ?)",
            tag.id.uuidString,
            tag.name,
            tag.createdAt.timeIntervalSince1970
        )
    }

    func deleteTag(id: UUID) throws {
        let db = try connection()
        try db.run("DELETE FROM tags WHERE id = ?", id.uuidString)
    }

    func countNotes(forTag name: String) throws -> Int {
        let pattern = "%\"\(name)\"%"
        let db = try connection()
        return Int((try db.scalar("SELECT COUNT(*) FROM notes WHERE tags LIKE ?", pattern) as? Int64) ?? 0)
    }

    // MARK: - Private mapper

    private func mapTag(_ row: Statement.Element) throws -> Tag {
        guard
            let idStr = row[0] as? String, let id = UUID(uuidString: idStr),
            let name  = row[1] as? String,
            let ts    = row[2] as? Double
        else {
            throw DatabaseError.mappingFailed("tags row missing required fields")
        }
        return Tag(id: id, name: name, createdAt: Date(timeIntervalSince1970: ts))
    }
}

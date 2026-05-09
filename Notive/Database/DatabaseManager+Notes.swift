import Foundation
import SQLite

// MARK: - Notes CRUD

extension DatabaseManager {

    func fetchAllNotes() throws -> [Note] {
        let db = try connection()
        var notes: [Note] = []
        let rows = try db.prepare(
            "SELECT id, title, body, created_at, updated_at, folder_id, tags, is_pinned FROM notes ORDER BY is_pinned DESC, updated_at DESC"
        )
        for row in rows {
            notes.append(try mapNote(row))
        }
        return notes
    }

    func fetchNote(id: UUID) throws -> Note? {
        let db = try connection()
        let rows = try db.prepare(
            "SELECT id, title, body, created_at, updated_at, folder_id, tags, is_pinned FROM notes WHERE id = ? LIMIT 1",
            id.uuidString
        )
        return try rows.makeIterator().next().map { try mapNote($0) }
    }

    func fetchNotes(folderID: UUID) throws -> [Note] {
        let db = try connection()
        var notes: [Note] = []
        let rows = try db.prepare(
            "SELECT id, title, body, created_at, updated_at, folder_id, tags, is_pinned FROM notes WHERE folder_id = ? ORDER BY is_pinned DESC, updated_at DESC",
            folderID.uuidString
        )
        for row in rows { notes.append(try mapNote(row)) }
        return notes
    }

    func fetchNotes(tag: String) throws -> [Note] {
        let db = try connection()
        var notes: [Note] = []
        // Use JSON LIKE to filter — works for simple tag arrays stored as JSON
        let pattern = "%\"\(tag)\"%"
        let rows = try db.prepare(
            "SELECT id, title, body, created_at, updated_at, folder_id, tags, is_pinned FROM notes WHERE tags LIKE ? ORDER BY is_pinned DESC, updated_at DESC",
            pattern
        )
        for row in rows { notes.append(try mapNote(row)) }
        return notes
    }

    func fetchPinnedNotes() throws -> [Note] {
        let db = try connection()
        var notes: [Note] = []
        let rows = try db.prepare(
            "SELECT id, title, body, created_at, updated_at, folder_id, tags, is_pinned FROM notes WHERE is_pinned = 1 ORDER BY updated_at DESC"
        )
        for row in rows { notes.append(try mapNote(row)) }
        return notes
    }

    func insertNote(_ note: Note) throws {
        let db = try connection()
        let tagsJSON = encodeJSON(note.tags)
        try db.run(
            "INSERT INTO notes (id, title, body, created_at, updated_at, folder_id, tags, is_pinned) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            note.id.uuidString,
            note.title,
            note.body,
            note.createdAt.timeIntervalSince1970,
            note.updatedAt.timeIntervalSince1970,
            note.folderID?.uuidString,
            tagsJSON,
            note.isPinned ? 1 : 0
        )
    }

    func updateNote(_ note: Note) throws {
        let db = try connection()
        let tagsJSON = encodeJSON(note.tags)
        try db.run(
            "UPDATE notes SET title = ?, body = ?, updated_at = ?, folder_id = ?, tags = ?, is_pinned = ? WHERE id = ?",
            note.title,
            note.body,
            note.updatedAt.timeIntervalSince1970,
            note.folderID?.uuidString,
            tagsJSON,
            note.isPinned ? 1 : 0,
            note.id.uuidString
        )
    }

    func deleteNote(id: UUID) throws {
        let db = try connection()
        try db.run("DELETE FROM notes WHERE id = ?", id.uuidString)
    }

    func countNotes() throws -> Int {
        let db = try connection()
        return Int((try db.scalar("SELECT COUNT(*) FROM notes") as? Int64) ?? 0)
    }

    func countNotes(folderID: UUID) throws -> Int {
        let db = try connection()
        return Int((try db.scalar("SELECT COUNT(*) FROM notes WHERE folder_id = ?", folderID.uuidString) as? Int64) ?? 0)
    }

    func countPinnedNotes() throws -> Int {
        let db = try connection()
        return Int((try db.scalar("SELECT COUNT(*) FROM notes WHERE is_pinned = 1") as? Int64) ?? 0)
    }

    /// Clears the folderID for all notes belonging to the given folder.
    func unassignNotes(fromFolder folderID: UUID) throws {
        let db = try connection()
        try db.run("UPDATE notes SET folder_id = NULL WHERE folder_id = ?", folderID.uuidString)
    }

    // MARK: - Keyword search

    func searchNotes(query: String) throws -> [Note] {
        let db = try connection()
        let pattern = "%\(query)%"
        var notes: [Note] = []
        let rows = try db.prepare(
            "SELECT id, title, body, created_at, updated_at, folder_id, tags, is_pinned FROM notes WHERE title LIKE ? OR body LIKE ? ORDER BY updated_at DESC",
            pattern, pattern
        )
        for row in rows { notes.append(try mapNote(row)) }
        return notes
    }

    // MARK: - Private mapper

    private func mapNote(_ row: Statement.Element) throws -> Note {
        guard
            let idStr    = row[0] as? String, let id = UUID(uuidString: idStr),
            let title    = row[1] as? String,
            let body     = row[2] as? String,
            let createdD = row[3] as? Double,
            let updatedD = row[4] as? Double
        else {
            throw DatabaseError.mappingFailed("notes row missing required fields")
        }
        let folderID = (row[5] as? String).flatMap(UUID.init(uuidString:))
        let tags     = decodeJSON([String].self, from: row[6] as? String ?? "[]")
        let pinned   = (row[7] as? Int64 ?? 0) != 0

        return Note(
            id: id,
            title: title,
            body: body,
            createdAt: Date(timeIntervalSince1970: createdD),
            updatedAt: Date(timeIntervalSince1970: updatedD),
            folderID: folderID,
            tags: tags,
            isPinned: pinned
        )
    }
}

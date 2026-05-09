import Foundation
import SQLite

// MARK: - VoiceNotes CRUD

extension DatabaseManager {

    func fetchAllVoiceNotes() throws -> [VoiceNote] {
        let db = try connection()
        var results: [VoiceNote] = []
        let rows = try db.prepare(
            "SELECT id, title, audio_file_path, transcript, summary, key_points, duration, created_at, linked_note_id, processing_state FROM voice_notes ORDER BY created_at DESC"
        )
        for row in rows { results.append(try mapVoiceNote(row)) }
        return results
    }

    func fetchVoiceNote(id: UUID) throws -> VoiceNote? {
        let db = try connection()
        let rows = try db.prepare(
            "SELECT id, title, audio_file_path, transcript, summary, key_points, duration, created_at, linked_note_id, processing_state FROM voice_notes WHERE id = ? LIMIT 1",
            id.uuidString
        )
        return try rows.makeIterator().next().map { try mapVoiceNote($0) }
    }

    func insertVoiceNote(_ vn: VoiceNote) throws {
        let db = try connection()
        let keyPointsJSON = encodeJSON(vn.keyPoints)
        try db.run(
            "INSERT INTO voice_notes (id, title, audio_file_path, transcript, summary, key_points, duration, created_at, linked_note_id, processing_state) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            vn.id.uuidString,
            vn.title,
            vn.audioFileURL.path,
            vn.transcript,
            vn.summary,
            keyPointsJSON,
            vn.duration,
            vn.createdAt.timeIntervalSince1970,
            vn.linkedNoteID?.uuidString,
            vn.processingState.rawValue
        )
    }

    func updateVoiceNote(_ vn: VoiceNote) throws {
        let db = try connection()
        let keyPointsJSON = encodeJSON(vn.keyPoints)
        try db.run(
            "UPDATE voice_notes SET title = ?, transcript = ?, summary = ?, key_points = ?, duration = ?, linked_note_id = ?, processing_state = ? WHERE id = ?",
            vn.title,
            vn.transcript,
            vn.summary,
            keyPointsJSON,
            vn.duration,
            vn.linkedNoteID?.uuidString,
            vn.processingState.rawValue,
            vn.id.uuidString
        )
    }

    func deleteVoiceNote(id: UUID) throws {
        let db = try connection()
        try db.run("DELETE FROM voice_notes WHERE id = ?", id.uuidString)
    }

    // MARK: - Private mapper

    private func mapVoiceNote(_ row: Statement.Element) throws -> VoiceNote {
        guard
            let idStr    = row[0] as? String, let id = UUID(uuidString: idStr),
            let title    = row[1] as? String,
            let audioPath = row[2] as? String,
            let ts       = row[7] as? Double
        else {
            throw DatabaseError.mappingFailed("voice_notes row missing required fields")
        }
        let transcript  = row[3] as? String
        let summary     = row[4] as? String
        let keyPoints   = decodeJSON([String].self, from: row[5] as? String ?? "[]")
        let duration    = row[6] as? Double ?? 0
        let linkedNoteID = (row[8] as? String).flatMap(UUID.init(uuidString:))
        let stateRaw    = row[9] as? String ?? "idle"
        let state       = VoiceNoteState(rawValue: stateRaw) ?? .idle

        return VoiceNote(
            id: id,
            title: title,
            audioFileURL: URL(fileURLWithPath: audioPath),
            transcript: transcript,
            summary: summary,
            keyPoints: keyPoints,
            duration: duration,
            createdAt: Date(timeIntervalSince1970: ts),
            linkedNoteID: linkedNoteID,
            processingState: state
        )
    }
}

import Foundation

/// Placeholder model for Phase 2+ attachment intelligence.
/// No business logic in this phase.
struct NoteAttachment: Identifiable, Codable, Equatable, Hashable, Sendable {
    var id: UUID
    var noteID: UUID
    var fileURL: URL
    /// e.g. "pdf", "image"
    var type: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        noteID: UUID,
        fileURL: URL,
        type: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.noteID = noteID
        self.fileURL = fileURL
        self.type = type
        self.createdAt = createdAt
    }
}

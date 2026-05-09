import Foundation

struct VoiceNoteRepository {
    private let manager: DatabaseManager

    init(manager: DatabaseManager = .shared) {
        self.manager = manager
    }

    func fetchAll() async throws -> [VoiceNote] {
        try await manager.fetchAllVoiceNotes()
    }

    func fetch(id: UUID) async throws -> VoiceNote? {
        try await manager.fetchVoiceNote(id: id)
    }

    func insert(_ voiceNote: VoiceNote) async throws {
        try await manager.insertVoiceNote(voiceNote)
    }

    func update(_ voiceNote: VoiceNote) async throws {
        try await manager.updateVoiceNote(voiceNote)
    }

    func delete(id: UUID) async throws {
        try await manager.deleteVoiceNote(id: id)
    }
}

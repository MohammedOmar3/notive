import Foundation

enum VoiceNoteState: String, Codable, Equatable, Hashable, Sendable {
    case idle
    case transcribing
    case summarizing
    case complete
    case failed
}

struct VoiceNote: Identifiable, Codable, Equatable, Hashable, Sendable {
    var id: UUID
    var title: String
    var audioFileURL: URL
    var transcript: String?
    var summary: String?
    var keyPoints: [String]
    var duration: TimeInterval
    var createdAt: Date
    /// Set when the voice note was saved as (or linked to) a text note.
    var linkedNoteID: UUID?
    var processingState: VoiceNoteState

    init(
        id: UUID = UUID(),
        title: String = "",
        audioFileURL: URL,
        transcript: String? = nil,
        summary: String? = nil,
        keyPoints: [String] = [],
        duration: TimeInterval = 0,
        createdAt: Date = Date(),
        linkedNoteID: UUID? = nil,
        processingState: VoiceNoteState = .idle
    ) {
        self.id = id
        self.title = title
        self.audioFileURL = audioFileURL
        self.transcript = transcript
        self.summary = summary
        self.keyPoints = keyPoints
        self.duration = duration
        self.createdAt = createdAt
        self.linkedNoteID = linkedNoteID
        self.processingState = processingState
    }

    static func makeEmpty(audioFileURL: URL = URL(fileURLWithPath: "")) -> VoiceNote {
        VoiceNote(audioFileURL: audioFileURL)
    }
}

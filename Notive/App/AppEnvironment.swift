import Foundation
import Combine

@MainActor
final class AppEnvironment: ObservableObject {

    // MARK: - Repositories

    let noteRepository:      NoteRepository
    let folderRepository:    FolderRepository
    let tagRepository:       TagRepository
    let voiceNoteRepository: VoiceNoteRepository

    // MARK: - Navigation state

    @Published var selectedFolderID: UUID?
    @Published var searchQuery: String = ""

    // MARK: - App state

    @Published var isReady: Bool = false
    @Published var setupError: String?

    // MARK: - Init

    init(manager: DatabaseManager = .shared) {
        self.noteRepository      = NoteRepository(manager: manager)
        self.folderRepository    = FolderRepository(manager: manager)
        self.tagRepository       = TagRepository(manager: manager)
        self.voiceNoteRepository = VoiceNoteRepository(manager: manager)
    }

    // MARK: - Setup

    func setUp() async {
        do {
            try await DatabaseManager.shared.setUp()
            isReady = true
            NovLogger.info("AppEnvironment ready")
        } catch {
            setupError = error.localizedDescription
            NovLogger.error("Database setup failed: \(error)", category: .database)
        }
    }
}

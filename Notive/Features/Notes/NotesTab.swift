import SwiftUI

/// Root of the Notes tab — owns the navigation stack and folder/note selection state.
struct NotesTab: View {
    @EnvironmentObject private var env: AppEnvironment

    @State private var folders:      [Folder] = []
    @State private var totalCount:   Int      = 0
    @State private var pinnedCount:  Int      = 0
    @State private var tagCounts:    [String: Int] = [:]
    @State private var allTags:      [Tag]    = []

    // Navigation
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            FolderListView(
                folders: folders,
                allTags: allTags,
                totalCount: totalCount,
                pinnedCount: pinnedCount,
                path: $path
            )
            .navigationTitle("Notive")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .navigationDestination(for: NoteListDestination.self) { dest in
                NoteListView(destination: dest, path: $path)
            }
            .navigationDestination(for: Note.self) { note in
                NoteEditorView(note: note)
            }
        }
        .task { await loadSidebar() }
        .onReceive(NotificationCenter.default.publisher(for: .notesDidChange)) { _ in
            Task { await loadSidebar() }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task { await createNewNote() }
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(NovColor.accent)
            }
            .accessibilityLabel("New Note")
        }
    }

    // MARK: - Data

    private func loadSidebar() async {
        async let foldersResult    = try? env.folderRepository.fetchAll()
        async let totalResult      = try? env.noteRepository.count()
        async let pinnedResult     = try? env.noteRepository.countPinned()
        async let tagsResult       = try? env.tagRepository.fetchAll()

        folders      = await foldersResult ?? []
        totalCount   = await totalResult ?? 0
        pinnedCount  = await pinnedResult ?? 0
        let tags     = await tagsResult ?? []
        allTags      = tags

        var counts: [String: Int] = [:]
        for tag in tags {
            counts[tag.name] = (try? await env.tagRepository.countNotes(forTag: tag.name)) ?? 0
        }
        tagCounts = counts
    }

    private func createNewNote() async {
        let note = Note.makeEmpty()
        try? await env.noteRepository.insert(note)
        NotificationCenter.default.post(name: .notesDidChange, object: nil)
        path.append(note)
    }
}

// MARK: - Navigation destination types

enum NoteListDestination: Hashable {
    case allNotes
    case pinned
    case folder(Folder)
    case tag(String)
}

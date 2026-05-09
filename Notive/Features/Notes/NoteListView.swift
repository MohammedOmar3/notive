import SwiftUI

struct NoteListView: View {
    @EnvironmentObject private var env: AppEnvironment

    let destination: NoteListDestination
    @Binding var path: NavigationPath

    @State private var notes: [Note] = []
    @State private var isLoading = true

    var title: String {
        switch destination {
        case .allNotes:        return "All Notes"
        case .pinned:          return "Pinned"
        case .folder(let f):   return f.name
        case .tag(let name):   return "#\(name)"
        }
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView().tint(NovColor.accent)
            } else if notes.isEmpty {
                EmptyNotesView { Task { await createNewNote() } }
            } else {
                noteList
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .task { await load() }
        .onReceive(NotificationCenter.default.publisher(for: .notesDidChange)) { _ in
            Task { await load() }
        }
    }

    // MARK: - Note list

    private var noteList: some View {
        List {
            ForEach(notes) { note in
                NavigationLink(value: note) {
                    NoteRowView(note: note)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task { await deleteNote(note) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        Task { await togglePin(note) }
                    } label: {
                        Label(note.isPinned ? "Unpin" : "Pin",
                              systemImage: note.isPinned ? "pin.slash" : "pin")
                    }
                    .tint(NovColor.accent)
                }
            }
        }
        .listStyle(.plain)
        .animation(.spring(response: 0.35), value: notes)
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

    private func load() async {
        isLoading = true
        do {
            switch destination {
            case .allNotes:
                notes = try await env.noteRepository.fetchAll()
            case .pinned:
                notes = try await env.noteRepository.fetchPinned()
            case .folder(let f):
                notes = try await env.noteRepository.fetch(folderID: f.id)
            case .tag(let name):
                notes = try await env.noteRepository.fetch(tag: name)
            }
        } catch {
            NovLogger.error("Failed to load notes: \(error)", category: .database)
        }
        isLoading = false
    }

    private func createNewNote() async {
        var note = Note.makeEmpty()
        if case .folder(let f) = destination { note.folderID = f.id }
        if case .tag(let name) = destination  { note.tags = [name]  }
        try? await env.noteRepository.insert(note)
        NotificationCenter.default.post(name: .notesDidChange, object: nil)
        path.append(note)
    }

    private func deleteNote(_ note: Note) async {
        try? await env.noteRepository.delete(id: note.id)
        NotificationCenter.default.post(name: .notesDidChange, object: nil)
    }

    private func togglePin(_ note: Note) async {
        var updated = note
        updated.isPinned = !note.isPinned
        updated.updatedAt = Date()
        try? await env.noteRepository.update(updated)
        NotificationCenter.default.post(name: .notesDidChange, object: nil)
    }
}

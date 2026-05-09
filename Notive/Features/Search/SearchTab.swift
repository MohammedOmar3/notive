import SwiftUI

struct SearchTab: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var query       = ""
    @State private var results:  [Note] = []
    @State private var recentNotes: [Note] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            Group {
                if query.isEmpty {
                    recentList
                } else if isSearching {
                    ProgressView().tint(NovColor.accent)
                } else if results.isEmpty {
                    noResultsView
                } else {
                    resultList
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search notes…")
            .onChange(of: query) { scheduleSearch() }
            .task { recentNotes = (try? await env.noteRepository.fetchAll())?.prefix(5).map { $0 } ?? [] }
        }
    }

    // MARK: - Views

    private var recentList: some View {
        List {
            if !recentNotes.isEmpty {
                Section("Recent") {
                    ForEach(recentNotes) { note in
                        NavigationLink(value: note) {
                            NoteRowView(note: note)
                        }
                    }
                }
            } else {
                ContentUnavailableView("Search your notes",
                                       systemImage: "magnifyingglass",
                                       description: Text("Your notes will appear here as you search."))
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Note.self) { note in
            NoteEditorView(note: note)
        }
    }

    private var resultList: some View {
        List(results) { note in
            NavigationLink(value: note) {
                NoteRowView(note: note)
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Note.self) { note in
            NoteEditorView(note: note)
        }
    }

    private var noResultsView: some View {
        ContentUnavailableView.search(text: query)
    }

    // MARK: - Search

    private func scheduleSearch() {
        searchTask?.cancel()
        guard !query.isEmpty else { return }
        isSearching = true
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    private func performSearch() async {
        do {
            results = try await env.noteRepository.search(query: query)
        } catch {
            NovLogger.error("Search failed: \(error)")
        }
        isSearching = false
    }
}

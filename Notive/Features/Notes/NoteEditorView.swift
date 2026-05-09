import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var note: Note
    @State private var isEditMode: Bool
    @State private var saveTask: Task<Void, Never>?
    @State private var showFolderPicker = false
    @State private var showTagPicker    = false
    @State private var showAIPlaceholder = false
    @State private var folders: [Folder] = []

    init(note: Note) {
        _note = State(initialValue: note)
        // New notes (empty body and title) open in edit mode
        _isEditMode = State(initialValue: note.title.isEmpty && note.body.isEmpty)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NovColor.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    titleField
                    Divider()
                        .padding(.horizontal, NovSpacing.m)
                    bodyArea
                    wordCountBar
                }
            }

            if isEditMode {
                NoteEditorToolbar(
                    note: $note,
                    showFolderPicker:    $showFolderPicker,
                    showTagPicker:       $showTagPicker,
                    showAIPlaceholder:   $showAIPlaceholder
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar { toolbarItems }
        .task { folders = (try? await env.folderRepository.fetchAll()) ?? [] }
        .sheet(isPresented: $showFolderPicker) {
            FolderPickerSheet(folders: folders, selectedFolderID: $note.folderID) {
                scheduleSave()
            }
        }
        .sheet(isPresented: $showTagPicker) {
            TagPickerSheet(selectedTags: $note.tags, allTags: []) {
                scheduleSave()
                Task { await syncTags() }
            }
        }
        .sheet(isPresented: $showAIPlaceholder) {
            AIPlaceholderSheet()
        }
        .onDisappear { saveImmediately() }
    }

    // MARK: - Title field

    private var titleField: some View {
        Group {
            if isEditMode {
                TextField("Title", text: $note.title, axis: .vertical)
                    .font(NovFont.noteTitle)
                    .foregroundStyle(NovColor.textPrimary)
                    .padding(.horizontal, NovSpacing.m)
                    .padding(.top, NovSpacing.m)
                    .padding(.bottom, NovSpacing.s)
                    .onChange(of: note.title) { scheduleSave() }
            } else {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(NovFont.noteTitle)
                    .foregroundStyle(note.title.isEmpty ? NovColor.textTertiary : NovColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, NovSpacing.m)
                    .padding(.top, NovSpacing.m)
                    .padding(.bottom, NovSpacing.s)
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { isEditMode = true } }
            }
        }
    }

    // MARK: - Body area

    @ViewBuilder
    private var bodyArea: some View {
        if isEditMode {
            TextEditor(text: $note.body)
                .font(NovFont.noteBody)
                .foregroundStyle(NovColor.textPrimary)
                .lineSpacing(6)
                .scrollContentBackground(.hidden)
                .background(NovColor.backgroundPrimary)
                .padding(.horizontal, NovSpacing.s)
                .padding(.top, NovSpacing.s)
                .frame(minHeight: 400)
                .onChange(of: note.body) { scheduleSave() }
                .overlay(alignment: .topLeading) {
                    if note.body.isEmpty {
                        Text("Start writing...")
                            .font(NovFont.noteBody)
                            .foregroundStyle(NovColor.textTertiary)
                            .padding(.horizontal, NovSpacing.s + 4)
                            .padding(.top, NovSpacing.s + 8)
                            .allowsHitTesting(false)
                    }
                }
        } else {
            MarkdownPreviewView(text: note.body)
                .padding(.horizontal, NovSpacing.m)
                .padding(.top, NovSpacing.s)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { isEditMode = true } }
        }
    }

    // MARK: - Word count bar

    private var wordCountBar: some View {
        Text(note.wordCount == 1 ? "1 word" : "\(note.wordCount) words")
            .font(NovFont.caption)
            .foregroundStyle(NovColor.textTertiary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, NovSpacing.m)
            .padding(.vertical, NovSpacing.xs)
            .padding(.bottom, isEditMode ? 56 : 0) // clear toolbar
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(isEditMode ? "Done" : "Edit") {
                withAnimation(.easeInOut(duration: 0.2)) { isEditMode.toggle() }
                if !isEditMode { saveImmediately() }
            }
            .foregroundStyle(NovColor.accent)
        }
    }

    // MARK: - Save logic

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            await save()
        }
    }

    private func saveImmediately() {
        saveTask?.cancel()
        Task { await save() }
    }

    private func save() async {
        var updated = note
        updated.updatedAt = Date()
        try? await env.noteRepository.update(updated)
        note = updated
        NotificationCenter.default.post(name: .notesDidChange, object: nil)
    }

    private func syncTags() async {
        for tagName in note.tags {
            let existing = try? await env.tagRepository.fetch(name: tagName)
            if existing == nil {
                try? await env.tagRepository.insert(Tag(name: tagName))
            }
        }
        NotificationCenter.default.post(name: .notesDidChange, object: nil)
    }
}

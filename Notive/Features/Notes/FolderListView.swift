import SwiftUI

struct FolderListView: View {
    @EnvironmentObject private var env: AppEnvironment

    let folders:      [Folder]
    let allTags:      [Tag]
    let totalCount:   Int
    let pinnedCount:  Int
    @Binding var path: NavigationPath

    @State private var isAddingFolder  = false
    @State private var newFolderName   = ""
    @State private var folderToDelete: Folder?
    @State private var showDeleteAlert = false

    var body: some View {
        List {
            librarySection
            foldersSection
            if !allTags.isEmpty { tagsSection }
        }
        .listStyle(.insetGrouped)
        .alert("Delete Folder?", isPresented: $showDeleteAlert, presenting: folderToDelete) { folder in
            Button("Delete", role: .destructive) {
                Task { await deleteFolder(folder) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { folder in
            Text("Notes in \"\(folder.name)\" will be moved to All Notes.")
        }
    }

    // MARK: - Sections

    private var librarySection: some View {
        Section("Library") {
            NavigationLink(value: NoteListDestination.allNotes) {
                Label {
                    HStack {
                        Text("All Notes")
                            .font(NovFont.body)
                            .foregroundStyle(NovColor.textPrimary)
                        Spacer()
                        Text("\(totalCount)")
                            .font(NovFont.footnote)
                            .foregroundStyle(NovColor.textSecondary)
                    }
                } icon: {
                    Image(systemName: "tray")
                        .foregroundStyle(NovColor.accent)
                }
            }

            if pinnedCount > 0 {
                NavigationLink(value: NoteListDestination.pinned) {
                    Label {
                        HStack {
                            Text("Pinned")
                                .font(NovFont.body)
                                .foregroundStyle(NovColor.textPrimary)
                            Spacer()
                            Text("\(pinnedCount)")
                                .font(NovFont.footnote)
                                .foregroundStyle(NovColor.textSecondary)
                        }
                    } icon: {
                        Image(systemName: "pin")
                            .foregroundStyle(NovColor.accent)
                    }
                }
            }
        }
    }

    private var foldersSection: some View {
        Section {
            ForEach(folders) { folder in
                NavigationLink(value: NoteListDestination.folder(folder)) {
                    FolderRowView(folder: folder)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        folderToDelete = folder
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            if isAddingFolder {
                HStack {
                    Image(systemName: "folder")
                        .foregroundStyle(NovColor.accent)
                    TextField("Folder name", text: $newFolderName)
                        .font(NovFont.body)
                        .submitLabel(.done)
                        .onSubmit { Task { await saveNewFolder() } }
                    Button("Cancel") {
                        isAddingFolder = false
                        newFolderName = ""
                    }
                    .font(NovFont.footnote)
                    .foregroundStyle(NovColor.textSecondary)
                }
            }

            Button {
                isAddingFolder = true
            } label: {
                Label("New Folder", systemImage: "plus")
                    .font(NovFont.body)
                    .foregroundStyle(NovColor.accent)
            }
        } header: {
            Text("Folders").font(NovFont.footnote)
        }
    }

    private var tagsSection: some View {
        Section("Tags") {
            ForEach(allTags) { tag in
                NavigationLink(value: NoteListDestination.tag(tag.name)) {
                    HStack {
                        Text("#\(tag.name)")
                            .font(NovFont.body)
                            .foregroundStyle(NovColor.textPrimary)
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func saveNewFolder() async {
        let name = newFolderName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else {
            isAddingFolder = false
            newFolderName = ""
            return
        }
        let folder = Folder(name: name)
        try? await env.folderRepository.insert(folder)
        isAddingFolder = false
        newFolderName = ""
        NotificationCenter.default.post(name: .foldersDidChange, object: nil)
        NotificationCenter.default.post(name: .notesDidChange, object: nil)
    }

    private func deleteFolder(_ folder: Folder) async {
        try? await env.noteRepository.unassign(fromFolder: folder.id)
        try? await env.folderRepository.delete(id: folder.id)
        NotificationCenter.default.post(name: .foldersDidChange, object: nil)
        NotificationCenter.default.post(name: .notesDidChange, object: nil)
    }
}

// MARK: - Folder row

private struct FolderRowView: View {
    let folder: Folder

    var body: some View {
        Label {
            Text(folder.name)
                .font(NovFont.body)
                .foregroundStyle(NovColor.textPrimary)
        } icon: {
            Image(systemName: "folder.fill")
                .foregroundStyle(Color(hex: folder.color) ?? NovColor.accent)
        }
    }
}

// MARK: - Hex colour helper

extension Color {
    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        guard cleaned.count == 6,
              let value = UInt64(cleaned, radix: 16)
        else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >>  8) & 0xFF) / 255
        let b = Double( value        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

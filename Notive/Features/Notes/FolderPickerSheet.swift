import SwiftUI

struct FolderPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let folders: [Folder]
    @Binding var selectedFolderID: UUID?
    let onSelect: () -> Void

    var body: some View {
        NavigationStack {
            List {
                // "No folder" option
                Button {
                    selectedFolderID = nil
                    onSelect()
                    dismiss()
                } label: {
                    HStack {
                        Label("No Folder", systemImage: "tray")
                            .foregroundStyle(NovColor.textPrimary)
                        Spacer()
                        if selectedFolderID == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(NovColor.accent)
                        }
                    }
                }

                ForEach(folders) { folder in
                    Button {
                        selectedFolderID = folder.id
                        onSelect()
                        dismiss()
                    } label: {
                        HStack {
                            Label(folder.name, systemImage: "folder.fill")
                                .foregroundStyle(NovColor.textPrimary)
                            Spacer()
                            if selectedFolderID == folder.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(NovColor.accent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(NovColor.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

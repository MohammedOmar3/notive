import SwiftUI

struct NoteEditorToolbar: View {
    @Binding var note: Note
    @Binding var showFolderPicker:  Bool
    @Binding var showTagPicker:     Bool
    @Binding var showAIPlaceholder: Bool

    @State private var showShareSheet = false

    var body: some View {
        HStack(spacing: NovSpacing.l) {
            toolbarButton("folder",          action: { showFolderPicker  = true }, label: "Change Folder")
            toolbarButton("tag",             action: { showTagPicker     = true }, label: "Edit Tags")
            toolbarButton(note.isPinned ? "pin.slash" : "pin",
                          action: { note.isPinned.toggle() },
                          label: note.isPinned ? "Unpin" : "Pin")
            toolbarButton("sparkles",        action: { showAIPlaceholder = true }, label: "AI Actions")
            Spacer()
            toolbarButton("square.and.arrow.up", action: { showShareSheet = true }, label: "Share")
        }
        .padding(.horizontal, NovSpacing.m)
        .padding(.vertical, NovSpacing.xs)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showShareSheet) {
            let content = [note.title.isEmpty ? "Untitled" : note.title, note.body]
                .filter { !$0.isEmpty }
                .joined(separator: "\n\n")
            ShareSheet(items: [content])
        }
    }

    private func toolbarButton(_ icon: String, action: @escaping () -> Void, label: String) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(NovColor.accent)
        }
        .accessibilityLabel(label)
    }
}

// MARK: - ShareSheet wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// MARK: - AI placeholder sheet

struct AIPlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: NovSpacing.l) {
                Spacer()
                Image(systemName: "sparkles")
                    .font(.system(size: 52))
                    .foregroundStyle(NovColor.accent)
                Text("AI Actions")
                    .font(NovFont.title2)
                    .foregroundStyle(NovColor.textPrimary)
                Text("AI features are coming in Phase 2.\nSummarise, tag, and ask questions about your notes — all on-device.")
                    .font(NovFont.body)
                    .foregroundStyle(NovColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, NovSpacing.xl)
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(NovColor.accent)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

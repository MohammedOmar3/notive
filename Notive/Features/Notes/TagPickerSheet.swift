import SwiftUI

struct TagPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTags: [String]
    let allTags: [String]
    let onDone: () -> Void

    @State private var newTagInput = ""

    var body: some View {
        NavigationStack {
            List {
                // Input for a new tag
                Section {
                    HStack {
                        Image(systemName: "tag")
                            .foregroundStyle(NovColor.accent)
                        TextField("Add tag…", text: $newTagInput)
                            .font(NovFont.body)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                            .onSubmit { addTag() }
                        if !newTagInput.isEmpty {
                            Button("Add") { addTag() }
                                .foregroundStyle(NovColor.accent)
                        }
                    }
                }

                // Existing tags on this note
                if !selectedTags.isEmpty {
                    Section("Applied") {
                        ForEach(selectedTags, id: \.self) { tag in
                            HStack {
                                Text("#\(tag)")
                                    .font(NovFont.body)
                                    .foregroundStyle(NovColor.textPrimary)
                                Spacer()
                                Button {
                                    selectedTags.removeAll { $0 == tag }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(NovColor.textSecondary)
                                }
                            }
                        }
                    }
                }

                // Suggestions from existing tags
                let suggestions = allTags.filter { !selectedTags.contains($0) }
                if !suggestions.isEmpty {
                    Section("Suggestions") {
                        ForEach(suggestions, id: \.self) { tag in
                            Button {
                                if !selectedTags.contains(tag) {
                                    selectedTags.append(tag)
                                }
                            } label: {
                                HStack {
                                    Text("#\(tag)")
                                        .font(NovFont.body)
                                        .foregroundStyle(NovColor.textPrimary)
                                    Spacer()
                                    Image(systemName: "plus")
                                        .foregroundStyle(NovColor.accent)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDone()
                        dismiss()
                    }
                    .foregroundStyle(NovColor.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func addTag() {
        let trimmed = newTagInput
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        guard !trimmed.isEmpty, !selectedTags.contains(trimmed) else {
            newTagInput = ""
            return
        }
        selectedTags.append(trimmed)
        newTagInput = ""
    }
}

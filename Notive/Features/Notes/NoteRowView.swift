import SwiftUI

struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: NovSpacing.xxs) {
            // Title row
            HStack(alignment: .top) {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(NovFont.headline)
                    .foregroundStyle(NovColor.textPrimary)
                    .lineLimit(1)
                Spacer()
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(NovColor.accent)
                }
            }

            // Preview text
            if !note.preview.isEmpty {
                Text(note.preview)
                    .font(NovFont.footnote)
                    .foregroundStyle(NovColor.textSecondary)
                    .lineLimit(2)
            }

            // Footer: date + tags
            HStack(spacing: NovSpacing.xs) {
                Text(note.updatedAt.relativeFormatted)
                    .font(NovFont.caption)
                    .foregroundStyle(NovColor.textTertiary)

                if !note.tags.isEmpty {
                    Spacer()
                    tagPills
                }
            }
        }
        .padding(.vertical, NovSpacing.xs)
    }

    // MARK: - Tag pills

    private var tagPills: some View {
        HStack(spacing: NovSpacing.xxs) {
            ForEach(note.tags.prefix(3), id: \.self) { tag in
                Text("#\(tag)")
                    .font(NovFont.caption)
                    .foregroundStyle(NovColor.accent)
                    .padding(.horizontal, NovSpacing.xxs)
                    .padding(.vertical, 2)
                    .background(NovColor.accent.opacity(0.1))
                    .clipShape(Capsule())
            }
            if note.tags.count > 3 {
                Text("+\(note.tags.count - 3)")
                    .font(NovFont.caption)
                    .foregroundStyle(NovColor.textSecondary)
            }
        }
    }
}

// MARK: - Date formatting

private extension Date {
    var relativeFormatted: String {
        let cal = Calendar.current
        if cal.isDateInToday(self)     { return "Today" }
        if cal.isDateInYesterday(self) { return "Yesterday" }
        let days = cal.dateComponents([.day], from: self, to: Date()).day ?? 0
        if days < 7 { return "\(days) days ago" }
        return formatted(date: .abbreviated, time: .omitted)
    }
}

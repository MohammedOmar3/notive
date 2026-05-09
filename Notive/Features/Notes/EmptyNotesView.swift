import SwiftUI

struct EmptyNotesView: View {
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: NovSpacing.l) {
            Spacer()

            Image(systemName: "note.text")
                .font(.system(size: 56))
                .foregroundStyle(NovColor.textTertiary)

            VStack(spacing: NovSpacing.xs) {
                Text("No Notes")
                    .font(NovFont.title3)
                    .foregroundStyle(NovColor.textPrimary)
                Text("Tap the button to create your first note.")
                    .font(NovFont.body)
                    .foregroundStyle(NovColor.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onCreate) {
                Text("New Note")
                    .font(NovFont.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, NovSpacing.xl)
                    .padding(.vertical, NovSpacing.s)
                    .background(NovColor.accent)
                    .clipShape(RoundedRectangle(cornerRadius: NovRadius.medium, style: .continuous))
            }

            Spacer()
        }
        .padding(.horizontal, NovSpacing.xl)
    }
}

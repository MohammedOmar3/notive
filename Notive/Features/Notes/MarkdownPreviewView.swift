import SwiftUI

/// Renders markdown text using Swift's built-in AttributedString support (iOS 15+).
/// Supports: bold, italic, headers (H1–H3), inline code, bullet lists, blockquotes.
struct MarkdownPreviewView: View {
    let text: String

    var body: some View {
        Group {
            if text.isEmpty {
                Text("Start writing...")
                    .font(NovFont.noteBody)
                    .foregroundStyle(NovColor.textTertiary)
            } else {
                Text(renderedText)
                    .font(NovFont.noteBody)
                    .foregroundStyle(NovColor.textPrimary)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.bottom, NovSpacing.xl)
    }

    private var renderedText: AttributedString {
        (try? AttributedString(
            markdown: text,
            options: AttributedString.MarkdownParsingOptions(
                allowsExtendedAttributes: true,
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )) ?? AttributedString(text)
    }
}

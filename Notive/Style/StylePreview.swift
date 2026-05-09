import SwiftUI

/// Visual preview of all style tokens — used to verify light/dark mode on device.
struct StylePreview: View {
    var body: some View {
        NavigationStack {
            List {
                colorsSection
                fontsSection
                spacingSection
            }
            .navigationTitle("Style Preview")
        }
    }

    // MARK: - Sections

    private var colorsSection: some View {
        Section("Colors") {
            colorRow("Background Primary",   NovColor.backgroundPrimary)
            colorRow("Background Secondary", NovColor.backgroundSecondary)
            colorRow("Background Tertiary",  NovColor.backgroundTertiary)
            colorRow("Text Primary",         NovColor.textPrimary)
            colorRow("Text Secondary",       NovColor.textSecondary)
            colorRow("Text Tertiary",        NovColor.textTertiary)
            colorRow("Accent",               NovColor.accent)
            colorRow("Separator",            NovColor.separator)
            colorRow("Destructive",          NovColor.destructive)
            colorRow("Success",              NovColor.success)
            colorRow("Warning",              NovColor.warning)
        }
    }

    private var fontsSection: some View {
        Section("Typography") {
            Text("Large Title").font(NovFont.largeTitle)
            Text("Title").font(NovFont.title)
            Text("Title 2").font(NovFont.title2)
            Text("Headline").font(NovFont.headline)
            Text("Body").font(NovFont.body)
            Text("Callout").font(NovFont.callout)
            Text("Footnote").font(NovFont.footnote)
            Text("Caption").font(NovFont.caption)
            Text("Note Title").font(NovFont.noteTitle)
            Text("Note Body — generous line spacing for comfortable reading.")
                .noteBodyStyle()
        }
    }

    private var spacingSection: some View {
        Section("Spacing (4pt grid)") {
            ForEach([
                ("xxs", NovSpacing.xxs),
                ("xs",  NovSpacing.xs),
                ("s",   NovSpacing.s),
                ("m",   NovSpacing.m),
                ("l",   NovSpacing.l),
                ("xl",  NovSpacing.xl),
                ("xxl", NovSpacing.xxl)
            ], id: \.0) { name, value in
                HStack {
                    Text(name).font(NovFont.caption).frame(width: 36, alignment: .leading)
                    Rectangle()
                        .fill(NovColor.accent)
                        .frame(width: value, height: 8)
                        .clipShape(RoundedRectangle(cornerRadius: NovRadius.full))
                    Text("\(Int(value))pt").font(NovFont.caption).foregroundStyle(NovColor.textSecondary)
                }
            }
        }
    }

    // MARK: - Helpers

    private func colorRow(_ label: String, _ color: Color) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: NovRadius.small)
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: NovRadius.small)
                        .strokeBorder(NovColor.separator, lineWidth: 0.5)
                )
            Text(label).font(NovFont.body)
        }
    }
}

#Preview {
    StylePreview()
}

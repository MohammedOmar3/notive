import SwiftUI

// MARK: - NovFont
// All fonts use San Francisco (system font) — no custom fonts in Phase 1.

enum NovFont {
    static let largeTitle  = Font.system(size: 34, weight: .bold,     design: .default)
    static let title       = Font.system(size: 28, weight: .semibold, design: .default)
    static let title2      = Font.system(size: 22, weight: .semibold, design: .default)
    static let title3      = Font.system(size: 20, weight: .semibold, design: .default)
    static let headline    = Font.system(size: 17, weight: .semibold, design: .default)
    static let body        = Font.system(size: 17, weight: .regular,  design: .default)
    static let callout     = Font.system(size: 16, weight: .regular,  design: .default)
    static let subheadline = Font.system(size: 15, weight: .semibold, design: .default)
    static let footnote    = Font.system(size: 13, weight: .regular,  design: .default)
    static let caption     = Font.system(size: 12, weight: .regular,  design: .default)

    /// Note body text — regular weight with generous line spacing applied via modifier
    static let noteBody  = Font.system(size: 17, weight: .regular, design: .default)
    /// Note title — display weight
    static let noteTitle = Font.system(size: 24, weight: .semibold, design: .default)
}

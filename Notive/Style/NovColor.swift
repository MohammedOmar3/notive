import SwiftUI

// MARK: - NovColor
// All colours adapt automatically to light/dark mode.
// Use semantic UIKit system colours where available;
// custom adaptive colours for brand-specific tokens.

enum NovColor {

    // MARK: Background

    /// Main screen background
    static let backgroundPrimary   = Color(uiColor: .systemBackground)
    /// Cards, list rows
    static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
    /// Input fields, code blocks
    static let backgroundTertiary  = Color(uiColor: .tertiarySystemBackground)

    // MARK: Text

    static let textPrimary   = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let textTertiary  = Color(uiColor: .placeholderText)

    /// Brand accent — refined indigo-slate, adapts for dark mode
    static let accent: Color = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.55, green: 0.58, blue: 1.00, alpha: 1)
            : UIColor(red: 0.36, green: 0.40, blue: 0.88, alpha: 1)
    })

    // MARK: UI

    static let separator   = Color(uiColor: .separator)
    static let destructive = Color(uiColor: .systemRed)
    static let success     = Color(uiColor: .systemGreen)
    static let warning     = Color(uiColor: .systemOrange)
}

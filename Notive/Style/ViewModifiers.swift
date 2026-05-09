import SwiftUI

// MARK: - Card modifier

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(NovColor.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: NovRadius.medium, style: .continuous))
    }
}

// MARK: - Note body text modifier

struct NoteBodyModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(NovFont.noteBody)
            .lineSpacing(6)
            .foregroundStyle(NovColor.textPrimary)
    }
}

// MARK: - Reduce-motion-aware transition

extension AnyTransition {
    static var novFade: AnyTransition {
        .opacity.animation(.easeInOut(duration: 0.2))
    }
}

// MARK: - View extensions

extension View {
    func novCard() -> some View {
        modifier(CardModifier())
    }

    func noteBodyStyle() -> some View {
        modifier(NoteBodyModifier())
    }
}

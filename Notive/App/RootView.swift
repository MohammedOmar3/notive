import SwiftUI

struct RootView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        if env.isReady {
            mainContent
        } else if let error = env.setupError {
            errorView(message: error)
        } else {
            launchView
        }
    }

    // MARK: - States

    private var launchView: some View {
        ZStack {
            NovColor.backgroundPrimary.ignoresSafeArea()
            VStack(spacing: NovSpacing.m) {
                Text("Notive")
                    .font(NovFont.largeTitle)
                    .foregroundStyle(NovColor.textPrimary)
                ProgressView()
                    .tint(NovColor.accent)
            }
        }
    }

    private func errorView(message: String) -> some View {
        ZStack {
            NovColor.backgroundPrimary.ignoresSafeArea()
            VStack(spacing: NovSpacing.m) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundStyle(NovColor.warning)
                Text("Failed to start Notive")
                    .font(NovFont.headline)
                    .foregroundStyle(NovColor.textPrimary)
                Text(message)
                    .font(NovFont.footnote)
                    .foregroundStyle(NovColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, NovSpacing.xl)
            }
        }
    }

    private var mainContent: some View {
        TabView {
            NotesTab()
                .tabItem { Label("Notes",  systemImage: "note.text") }
            SearchTab()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
            VoiceTab()
                .tabItem { Label("Voice",  systemImage: "waveform") }
        }
        .tint(NovColor.accent)
    }
}

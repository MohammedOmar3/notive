import SwiftUI

struct VoiceTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Voice Notes", systemImage: "waveform")
            } description: {
                Text("Voice recording is coming in Phase 3.\nYou'll be able to record, transcribe, and summarise voice notes — all on-device.")
                    .font(NovFont.body)
                    .foregroundStyle(NovColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("Voice")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

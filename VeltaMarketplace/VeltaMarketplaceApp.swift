import AVFoundation
import SwiftUI

@main
struct VeltaMarketplaceApp: App {
    @State private var app = AppState()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(app)
                .preferredColorScheme(.dark)
                .tint(VeltaTheme.accent)
                .task {
                    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
                    try? AVAudioSession.sharedInstance().setActive(true)
                    await app.load()
                }
        }
    }
}

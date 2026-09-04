import SwiftUI

struct VideoHomeView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        ForYouFeedView()
            .ignoresSafeArea(edges: [.top, .bottom])
            .overlay(alignment: .top) {
                PhotosHeaderBlur(radius: 14, style: .statusBar)
                    .frame(height: 58)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
            }
            .veltaScreen()
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: app.activeClipID) { _, id in
                let hide = id != nil && id != app.catalog.clips.first?.id
                app.hideBottomChrome = hide
            }
            .onAppear {
                app.hideBottomChrome = app.activeClipID != nil
                    && app.activeClipID != app.catalog.clips.first?.id
            }
    }
}

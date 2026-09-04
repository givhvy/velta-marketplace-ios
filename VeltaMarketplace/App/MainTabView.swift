import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var app
    @State private var explorePath: [AppRoute] = []
    @State private var searchPath: [AppRoute] = []
    @State private var cartPath: [AppRoute] = []
    @State private var libraryPath: [AppRoute] = []
    @State private var menuPath: [AppRoute] = []

    var body: some View {
        @Bindable var app = app

        ZStack(alignment: .bottom) {
            GeometryReader { geo in
                ZStack {
                    tabStack(path: $explorePath) { ExploreView() }
                        .opacity(app.selectedTab == .explore ? 1 : 0)
                        .allowsHitTesting(app.selectedTab == .explore)

                    tabStack(path: $searchPath) { SearchView() }
                        .opacity(app.selectedTab == .search ? 1 : 0)
                        .allowsHitTesting(app.selectedTab == .search)

                    tabStack(path: $cartPath) { CartView() }
                        .opacity(app.selectedTab == .cart ? 1 : 0)
                        .allowsHitTesting(app.selectedTab == .cart)

                    tabStack(path: $libraryPath) { LibraryView() }
                        .opacity(app.selectedTab == .library ? 1 : 0)
                        .allowsHitTesting(app.selectedTab == .library)

                    tabStack(path: $menuPath) { AccountView() }
                        .opacity(app.selectedTab == .menu ? 1 : 0)
                        .allowsHitTesting(app.selectedTab == .menu)
                }
                .environment(\.veltaWidth, geo.size.width)
            }
            .padding(.bottom, reservedBottomChrome)

            bottomChrome
        }
        .ignoresSafeArea(edges: .bottom)
        .background(VeltaTheme.ink.ignoresSafeArea())
        .sheet(item: $app.checkout) { target in
            if let beat = app.catalog.beat(id: target.beatId) {
                CheckoutView(beat: beat, tier: target.tier)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
            }
        }
        .overlay(alignment: .top) {
            if let toast = app.toast {
                Text(toast)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.12), in: Capsule())
                    .overlay(Capsule().strokeBorder(VeltaTheme.inkLine))
                    .padding(.top, 8)
                    .onTapGesture { app.toast = nil }
                    .task {
                        try? await Task.sleep(for: .seconds(2.4))
                        if app.toast == toast { app.toast = nil }
                    }
            }
        }
        .animation(.easeOut(duration: 0.2), value: app.toast)
        .animation(.easeOut(duration: 0.15), value: app.selectedTab)
    }

    private var showsMiniPlayer: Bool {
        (app.homePane == .beats || app.selectedTab != .explore) && app.nowPlayingID != nil
    }

    private var reservedBottomChrome: CGFloat {
        VeltaLayout.tabBarContentHeight + (showsMiniPlayer ? VeltaLayout.miniPlayerHeight : 0)
    }

    private var bottomChrome: some View {
        VStack(spacing: 0) {
            if showsMiniPlayer,
               let id = app.nowPlayingID,
               let beat = app.catalog.beat(id: id)
            {
                MiniPlayerBar(beat: beat, webBase: app.catalog.webBase) {
                    app.selectedTab = .explore
                    app.homePane = .beats
                }
            }
            VeltaTabBar(
                selection: Binding(
                    get: { app.selectedTab },
                    set: { app.selectedTab = $0 }
                ),
                cartCount: app.cartCount
            )
        }
        .background(VeltaTheme.ink)
    }

    private func tabStack<Content: View>(
        path: Binding<[AppRoute]>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack(path: path) {
            content()
                .navigationDestination(for: AppRoute.self, destination: destination)
        }
    }

    @ViewBuilder
    private func destination(_ route: AppRoute) -> some View {
        switch route {
        case .beat(let id):
            BeatDetailView(beatId: id)
        case .studio:
            StudioView()
        }
    }
}

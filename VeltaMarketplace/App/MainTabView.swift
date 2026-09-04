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
            .padding(.bottom, contentBottomInset)

            bottomChrome
                .offset(y: app.hideBottomChrome ? reservedBottomChrome + 24 : 0)
                .opacity(app.hideBottomChrome ? 0 : 1)
                .allowsHitTesting(!app.hideBottomChrome)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(VeltaTheme.ink.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.22), value: app.hideBottomChrome)
        .sheet(item: $app.checkout) { target in
            if let beat = app.catalog.beat(id: target.beatId) {
                CheckoutView(beat: beat, tier: target.tier)
                    .presentationDetents([.height(420)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
                    .presentationBackground {
                        VeltaTheme.ink.ignoresSafeArea()
                    }
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = app.toast {
                Text(toast)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .environment(\.colorScheme, .dark)
                    .overlay(Capsule().strokeBorder(VeltaTheme.inkLine))
                    .padding(.horizontal, 20)
                    .padding(.bottom, (app.hideBottomChrome ? 12 : reservedBottomChrome + 12))
                    .onTapGesture { app.toast = nil }
                    .task {
                        try? await Task.sleep(for: .seconds(2.4))
                        if app.toast == toast { app.toast = nil }
                    }
            }
        }
        .animation(.easeOut(duration: 0.2), value: app.toast)
        .animation(.easeOut(duration: 0.15), value: app.selectedTab)
        .onChange(of: app.selectedTab) { _, _ in
            app.hideBottomChrome = false
        }
    }

    private var contentBottomInset: CGFloat {
        if app.hideBottomChrome { return 0 }
        if app.selectedTab == .explore && app.homePane == .forYou { return 0 }
        return reservedBottomChrome
    }

    private var showsMiniPlayer: Bool {
        app.checkout == nil
            && (app.homePane == .beats || app.selectedTab != .explore)
            && app.nowPlayingID != nil
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
                MiniPlayerBar(
                    beat: beat,
                    webBase: app.catalog.webBase,
                    isPlaying: app.isPreviewPlaying(beat.id)
                ) {
                    app.togglePreview(beat)
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
        case .login:
            LoginView()
        case .orders:
            OrdersView()
        case .payments:
            PaymentMethodsView()
        case .settings:
            AccountSettingsView()
        case .help:
            HelpView()
        case .legal(let document):
            LegalDocumentView(document: document)
        }
    }
}

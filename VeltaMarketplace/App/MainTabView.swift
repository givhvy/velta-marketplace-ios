import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var app
    @State private var videoPath: [AppRoute] = []
    @State private var beatsPath: [AppRoute] = []
    @State private var cartPath: [AppRoute] = []
    @State private var menuPath: [AppRoute] = []

    var body: some View {
        @Bindable var app = app

        GeometryReader { geo in
            TabView(selection: $app.selectedTab) {
                Tab(value: AppTab.video) {
                    tabStack(path: $videoPath) { VideoHomeView() }
                } label: {
                    Label("Video", systemImage: "play.rectangle.fill")
                }

                Tab(value: AppTab.beats) {
                    tabStack(path: $beatsPath) { BeatsHomeView() }
                } label: {
                    Label("Beats", systemImage: "music.note.list")
                }

                Tab(value: AppTab.cart) {
                    tabStack(path: $cartPath) { CartView() }
                } label: {
                    Label("Bag", systemImage: "bag")
                }
                .badge(app.cartCount)

                Tab(value: AppTab.menu) {
                    tabStack(path: $menuPath) { AccountView() }
                } label: {
                    Label("Menu", systemImage: "line.3.horizontal")
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .tint(.white)
            .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
            .tabViewBottomAccessory {
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
            }
            .environment(\.veltaWidth, geo.size.width)
        }
        .background(VeltaTheme.ink.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.22), value: app.hideBottomChrome)
        .sheet(isPresented: $app.isBeatSearchPresented) {
            SearchView()
                .presentationDetents([.height(460)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
                .presentationBackground {
                    VeltaTheme.ink.ignoresSafeArea()
                }
        }
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
                    .padding(.bottom, toastBottomPadding)
                    .onTapGesture { app.toast = nil }
                    .task {
                        try? await Task.sleep(for: .seconds(2.4))
                        if app.toast == toast { app.toast = nil }
                    }
            }
        }
        .animation(.easeOut(duration: 0.2), value: app.toast)
        .onChange(of: app.selectedTab) { _, tab in
            if tab != .video {
                app.hideBottomChrome = false
            }
        }
        .onChange(of: app.pendingBeatDetailId) { _, beatId in
            guard let beatId else { return }
            beatsPath.append(.beat(beatId))
            app.pendingBeatDetailId = nil
        }
        .onChange(of: app.pendingMenuRoute) { _, route in
            guard let route else { return }
            menuPath.append(route)
            app.pendingMenuRoute = nil
        }
    }

    private var shouldHideTabBar: Bool {
        app.hideBottomChrome && app.selectedTab == .video
    }

    private var showsMiniPlayer: Bool {
        app.checkout == nil
            && app.selectedTab != .video
            && app.nowPlayingID != nil
    }

    private var toastBottomPadding: CGFloat {
        if shouldHideTabBar { return 12 }
        let accessory = showsMiniPlayer ? VeltaLayout.miniPlayerHeight + 8 : 0
        return VeltaLayout.liquidTabBarReserve + accessory + 12
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
        case .license(let id):
            LicenseDetailView(licenseId: id)
        case .licenses:
            LicensesView()
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

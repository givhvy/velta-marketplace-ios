import SwiftUI

struct ExploreView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width
    @State private var genre: String?
    @State private var hidePanePicker = false

    private var gutter: CGFloat { VeltaLayout.gutter(for: width) }
    private var listenWidth: CGFloat { VeltaLayout.listenCardWidth(for: width) }
    private var videoWidth: CGFloat { VeltaLayout.videoCardWidth(for: width) }
    private var paneChromeHeight: CGFloat { 52 }

    private var genres: [String] {
        Array(Set(app.catalog.beats.flatMap(\.genres))).sorted()
    }

    private var filtered: [Beat] {
        guard let genre else { return app.catalog.beats }
        return app.catalog.beats.filter { $0.genres.contains(genre) }
    }

    var body: some View {
        @Bindable var app = app

        Group {
            if app.homePane == .forYou {
                ZStack(alignment: .top) {
                    ForYouFeedView()
                    feedChrome(pane: $app.homePane)
                        .opacity(hidePanePicker ? 0 : 1)
                        .allowsHitTesting(!hidePanePicker)
                }
            } else {
                beatsHome
                    .safeAreaInset(edge: .top, spacing: 0) {
                        if !hidePanePicker {
                            ZStack {
                                PhotosHeaderBlur(radius: 18, style: .header)
                                    .ignoresSafeArea(edges: .top)
                                beatsPaneChrome(pane: $app.homePane)
                            }
                            .frame(height: paneChromeHeight)
                        }
                    }
                    .overlay(alignment: .top) {
                        if hidePanePicker {
                            PhotosHeaderBlur(radius: 14, style: .statusBar)
                                .frame(height: 58)
                                .frame(maxWidth: .infinity)
                                .ignoresSafeArea(edges: .top)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(homePaneSwipeGesture)
        .veltaScreen()
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.22), value: hidePanePicker)
        .onChange(of: app.homePane) { _, pane in
            if pane == .forYou {
                setExploreChromeHidden(
                    app.activeClipID != nil && app.activeClipID != app.catalog.clips.first?.id
                )
            } else {
                setExploreChromeHidden(false)
            }
        }
        .onChange(of: app.activeClipID) { _, id in
            guard app.homePane == .forYou else { return }
            setExploreChromeHidden(id != nil && id != app.catalog.clips.first?.id)
        }
    }

    private func setExploreChromeHidden(_ hidden: Bool) {
        hidePanePicker = hidden
        app.hideBottomChrome = hidden
    }

    private var homePaneSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 28, coordinateSpace: .local)
            .onEnded { value in
                let dx = value.translation.width
                let dy = value.translation.height
                guard abs(dx) > abs(dy) * 1.15 else { return }
                guard abs(dx) > 64 else { return }

                withAnimation(.easeInOut(duration: 0.22)) {
                    if dx < 0, app.homePane == .beats {
                        app.homePane = .forYou
                    } else if dx > 0, app.homePane == .forYou {
                        app.homePane = .beats
                    }
                }
            }
    }

    private func beatsPaneChrome(pane: Binding<HomePane>) -> some View {
        ZStack {
            HomePanePicker(pane: pane)
                .frame(maxWidth: .infinity)

            HStack {
                Spacer(minLength: 0)
                Image(systemName: "bell")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .accessibilityLabel("Notifications")
            }
            .padding(.horizontal, gutter)
        }
        .frame(height: paneChromeHeight)
        .padding(.top, 2)
    }

    private func feedChrome(pane: Binding<HomePane>) -> some View {
        HomePanePicker(pane: pane)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            .padding(.bottom, 10)
            .background {
                LinearGradient(
                    colors: [.black.opacity(0.55), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
    }

    private var beatsHome: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Button(action: app.openSearch) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white.opacity(0.45))
                        Text("What are you looking for?")
                            .foregroundStyle(.white.opacity(0.45))
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.08), in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, gutter)

                GenreChipRail(genres: genres, selected: $genre)

                section("Continue listening to", browse: app.openSearch) {
                    CompactRail(items: app.continueBeats(), cardWidth: listenWidth, gutter: gutter) { beat in
                        NavigationLink(value: AppRoute.beat(beat.id)) {
                            ListenCard(beat: beat, webBase: app.catalog.webBase, label: beat.featured ? "Boost Track" : beat.genres.first)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !app.catalog.clips.isEmpty {
                    section("Used on these beats", browse: { app.homePane = .forYou }) {
                        CompactRail(items: app.catalog.clips, cardWidth: videoWidth, gutter: gutter) { clip in
                            Button {
                                app.openVideo(clipId: clip.id)
                            } label: {
                                UsageClipCard(
                                    clip: clip,
                                    beat: app.catalog.beat(id: clip.beatId),
                                    webBase: app.catalog.webBase
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                section("New & Notable", browse: app.openSearch) {
                    CompactRail(
                        items: Array((genre == nil ? app.catalog.notable : filtered).prefix(8)),
                        cardWidth: listenWidth,
                        gutter: gutter
                    ) { beat in
                        NavigationLink(value: AppRoute.beat(beat.id)) {
                            NotableCard(beat: beat, webBase: app.catalog.webBase)
                        }
                        .buttonStyle(.plain)
                    }
                }

                section("Top charts", browse: app.openSearch) {
                    CompactRail(
                        items: Array((genre == nil ? app.catalog.trending : filtered).prefix(10)),
                        cardWidth: listenWidth,
                        gutter: gutter
                    ) { beat in
                        NavigationLink(value: AppRoute.beat(beat.id)) {
                            NotableCard(
                                beat: beat,
                                webBase: app.catalog.webBase,
                                rank: (app.catalog.trending.firstIndex(of: beat) ?? 0) + 1
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.bottom, 28)
        }
        .scrollClipDisabled()
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, offset in
            let hide = offset > 36
            if hide != hidePanePicker {
                setExploreChromeHidden(hide)
            }
        }
    }

    private func section<Content: View>(
        _ title: String,
        browse: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title, action: "Browse", onAction: browse)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [VeltaTheme.boost.opacity(0.5), VeltaTheme.accent.opacity(0.15), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, gutter)
            content()
        }
    }
}

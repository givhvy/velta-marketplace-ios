import SwiftUI

struct ExploreView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width
    @State private var genre: String?

    private var gutter: CGFloat { VeltaLayout.gutter(for: width) }
    private var listenWidth: CGFloat { VeltaLayout.listenCardWidth(for: width) }
    private var videoWidth: CGFloat { VeltaLayout.videoCardWidth(for: width) }

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
                }
            } else {
                ZStack(alignment: .top) {
                    beatsHome
                    beatsTopBlur
                    feedChrome(pane: $app.homePane)
                }
            }
        }
        .veltaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func feedChrome(pane: Binding<HomePane>) -> some View {
        Group {
            if app.homePane == .beats {
                HStack {
                    Color.clear
                        .frame(width: 32, height: 32)
                    Spacer(minLength: 0)
                    HomePanePicker(pane: pane)
                    Spacer(minLength: 0)
                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .accessibilityLabel("Notifications")
                }
                .padding(.horizontal, gutter)
            } else {
                HomePanePicker(pane: pane)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 10)
        .background {
            if app.homePane == .forYou {
                LinearGradient(
                    colors: [.black.opacity(0.55), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }

    private var beatsTopBlur: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .overlay(Color.black.opacity(0.18))
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black, location: 0.48),
                        .init(color: .black.opacity(0.45), location: 0.72),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(height: 148)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
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
        .contentMargins(.top, 36, for: .scrollContent)
        .scrollClipDisabled()
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

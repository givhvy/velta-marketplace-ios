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
                VStack(spacing: 0) {
                    topBar
                    HomePanePicker(pane: $app.homePane)
                    beatsHome
                }
            }
        }
        .veltaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func feedChrome(pane: Binding<HomePane>) -> some View {
        let side: CGFloat = width < 380 ? 44 : 100
        return HStack(spacing: 8) {
            VeltaWordmark(markSize: 28, showsName: width >= 380)
                .frame(width: side, alignment: .leading)
            Spacer(minLength: 0)
            HomePanePicker(pane: pane)
            Spacer(minLength: 0)
            Image(systemName: "bell")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: side, alignment: .trailing)
        }
        .padding(.horizontal, gutter)
        .padding(.top, 6)
        .padding(.bottom, 18)
        .background(
            LinearGradient(
                colors: [.black.opacity(0.65), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var topBar: some View {
        HStack(spacing: 8) {
            VeltaWordmark(markSize: 28, showsName: width >= 380)
            Spacer()
            if app.homePane == .beats {
                Text("Explore")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            Image(systemName: "bell")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
        }
        .padding(.horizontal, gutter)
        .padding(.vertical, 8)
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

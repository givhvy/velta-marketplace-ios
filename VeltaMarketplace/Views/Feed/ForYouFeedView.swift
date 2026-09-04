import SwiftUI

struct ForYouFeedView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width

    var body: some View {
        let clips = app.catalog.clips
        @Bindable var app = app

        GeometryReader { geo in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(clips) { clip in
                        clipPage(clip, bottomInset: geo.safeAreaInsets.bottom)
                            .containerRelativeFrame(.vertical)
                            .id(clip.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $app.activeClipID)
            .scrollIndicators(.hidden)
            .background(.black)
            .clipped()
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .onAppear {
            if app.activeClipID == nil {
                app.activeClipID = clips.first?.id
            }
        }
    }

    private func clipPage(_ clip: UsageClip, bottomInset: CGFloat) -> some View {
        let beat = app.catalog.beat(id: clip.beatId)
        let active = app.activeClipID == clip.id

        return ZStack {
            Color.black

            if let url = clip.url {
                LoopingVideoView(url: url, isPlaying: active)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .clipped()
            } else if let beat {
                BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .clipped()
            }

            LinearGradient(
                colors: [.black.opacity(0.42), .clear, .clear, .black.opacity(0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("@\(clip.creatorName)")
                        .font(.headline)
                    Text(clip.caption)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.92))
                    if let beat {
                        Button {
                            app.play(beat)
                            app.selectedTab = .beats
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "music.note")
                                Text(beat.title)
                                    .lineLimit(1)
                            }
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(.black.opacity(0.45), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    Text(clip.location)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.45))
                }
                .foregroundStyle(.white)

                Spacer(minLength: 8)

                VStack(spacing: 10) {
                    actionButton(
                        systemImage: app.isClipLiked(clip.id) ? "heart.fill" : "heart",
                        label: compact(clip.likes + (app.isClipLiked(clip.id) ? 1 : 0)),
                        tint: app.isClipLiked(clip.id) ? .red : .white
                    ) {
                        app.toggleClipLike(clip.id)
                    }
                    actionButton(systemImage: "ellipsis.bubble", label: "Chat") {}
                    if let beat, let license = beat.licenses.first {
                        actionButton(systemImage: "bag.fill", label: "Buy") {
                            app.openCheckout(beat, tier: license.tier)
                        }
                    }
                }
            }
            .padding(.horizontal, VeltaLayout.gutter(for: width))
            .padding(.bottom, VeltaLayout.forYouActionBottom(safeAreaBottom: bottomInset, tabBarHidden: app.hideBottomChrome))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private func actionButton(
        systemImage: String,
        label: String,
        tint: Color = .white,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(.black.opacity(0.35), in: Circle())
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(minWidth: 36)
            }
        }
        .buttonStyle(.plain)
    }

    private func compact(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1fk", Double(value) / 1000)
        }
        return "\(value)"
    }
}

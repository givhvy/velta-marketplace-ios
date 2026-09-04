import SwiftUI

struct GenreChipRail: View {
    var genres: [String]
    @Binding var selected: String?
    @Environment(\.veltaWidth) private var width

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("All", value: nil)
                ForEach(genres, id: \.self) { genre in
                    chip(genre, value: genre)
                }
            }
            .padding(.horizontal, VeltaLayout.gutter(for: width))
        }
    }

    private func chip(_ title: String, value: String?) -> some View {
        Button {
            selected = value
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selected == value ? .black : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selected == value ? Color.white : Color.white.opacity(0.08), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct ListenCard: View {
    let beat: Beat
    var webBase: URL
    var label: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BeatCoverView(beat: beat, webBase: webBase)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text((label ?? beat.genres.first ?? "Track").uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(VeltaTheme.boost)
                .lineLimit(1)

            Text(beat.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(beat.sellerName)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
        }
    }
}

struct NotableCard: View {
    let beat: Beat
    var webBase: URL
    var rank: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                BeatCoverView(beat: beat, webBase: webBase, rank: rank)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text("$\(beat.lowestPrice, specifier: "%.2f")")
                    .font(.caption2.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.black)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(VeltaTheme.price, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .padding(8)
            }

            Text(beat.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)

            Text(beat.sellerName)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
        }
    }
}

struct UsageClipCard: View {
    let clip: UsageClip
    let beat: Beat?
    var webBase: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                if let beat {
                    BeatCoverView(beat: beat, webBase: webBase)
                } else {
                    Color.white.opacity(0.08)
                }

                Rectangle()
                    .fill(.black.opacity(0.28))

                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.black.opacity(0.45), in: Circle())
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(clip.creatorName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            Text(clip.caption)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
                .lineLimit(2)
        }
    }
}

struct CompactRail<Item: Identifiable, Content: View>: View {
    let items: [Item]
    var cardWidth: CGFloat
    var gutter: CGFloat
    @ViewBuilder var content: (Item) -> Content

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(items) { item in
                    content(item)
                        .frame(width: cardWidth, alignment: .topLeading)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, gutter)
        }
        .scrollTargetBehavior(.viewAligned)
    }
}

struct HomePanePicker: View {
    @Binding var pane: HomePane

    var body: some View {
        HStack(spacing: 22) {
            paneButton("For You", value: .forYou)
            paneButton("Beats", value: .beats)
        }
        .padding(.vertical, 6)
    }

    private func paneButton(_ title: String, value: HomePane) -> some View {
        Button {
            pane = value
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(pane == value ? .bold : .medium))
                    .foregroundStyle(pane == value ? .white : .white.opacity(0.4))
                Capsule()
                    .fill(pane == value ? Color.white : Color.clear)
                    .frame(width: 28, height: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

struct MiniPlayerBar: View {
    let beat: Beat
    var webBase: URL
    var onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 10) {
                BeatCoverView(beat: beat, webBase: webBase)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(beat.title)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(beat.sellerName)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "play.fill")
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(VeltaTheme.inkElevated)
        }
        .buttonStyle(.plain)
    }
}

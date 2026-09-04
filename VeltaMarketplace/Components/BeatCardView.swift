import SwiftUI

struct BeatCoverView: View {
    let beat: Beat
    var webBase: URL
    var rank: Int?

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: VeltaTheme.coverColors(for: beat.coverGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if let url = beat.coverURL(webBase: webBase) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    default:
                        EmptyView()
                    }
                }
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )

            if let rank {
                Text("#\(rank)")
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.7), in: Capsule())
                    .foregroundStyle(.white)
                    .padding(10)
            }
        }
        .clipped()
    }
}

struct BeatCardView: View {
    let beat: Beat
    var rank: Int?
    var webBase: URL
    var square: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BeatCoverView(beat: beat, webBase: webBase, rank: rank)
                .aspectRatio(square ? 1 : 4 / 3, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(beat.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 6) {
                Text(beat.sellerName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
                if beat.sellerVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(VeltaTheme.accent)
                }
            }

            Text("$\(beat.lowestPrice, specifier: "%.2f")")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
    }
}

struct BeatRail: View {
    let beats: [Beat]
    var webBase: URL
    var ranked: Bool = false
    @Environment(\.veltaWidth) private var width

    var body: some View {
        let gutter = VeltaLayout.gutter(for: width)
        let cardWidth = VeltaLayout.listenCardWidth(for: width)

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 14) {
                ForEach(Array(beats.enumerated()), id: \.element.id) { index, beat in
                    NavigationLink(value: AppRoute.beat(beat.id)) {
                        BeatCardView(
                            beat: beat,
                            rank: ranked ? index + 1 : nil,
                            webBase: webBase
                        )
                        .frame(width: cardWidth)
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, gutter)
        }
        .scrollTargetBehavior(.viewAligned)
    }
}

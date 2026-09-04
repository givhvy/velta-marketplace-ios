import SwiftUI

struct SearchView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width
    @State private var query = ""

    var body: some View {
        let results = app.catalog.search(query)

        VStack(spacing: 0) {
            ExploreHeader(title: "Search", showsBell: false)
            VeltaSearchField(query: $query)
                .padding(.bottom, 12)

            if results.isEmpty {
                ContentUnavailableView("No beats", systemImage: "magnifyingglass")
                    .foregroundStyle(.white)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(results) { beat in
                            NavigationLink(value: AppRoute.beat(beat.id)) {
                                HStack(spacing: 12) {
                                    BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                                        .frame(width: 72, height: 72)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(beat.genreLine.uppercased())
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(VeltaTheme.boost)
                                        Text(beat.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.white)
                                            .lineLimit(2)
                                        Text(beat.sellerName)
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    Spacer()
                                    Text("$\(beat.lowestPrice, specifier: "%.2f")")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(VeltaTheme.price)
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.white.opacity(0.04))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, VeltaLayout.gutter(for: width))
                    .padding(.bottom, 28)
                }
            }
        }
        .veltaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }
}

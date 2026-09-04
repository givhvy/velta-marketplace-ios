import SwiftUI

struct BeatDetailView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var appWidth
    let beatId: String
    @State private var selectedTier: String?

    private var gutter: CGFloat { VeltaLayout.gutter(for: appWidth) }

    var body: some View {
        Group {
            if let beat = app.catalog.beat(id: beatId) {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                                .frame(maxWidth: .infinity)
                                .frame(height: min(200, max(148, appWidth * 0.48)))
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                            FlowGenreRow(genres: beat.genres)

                            Text(beat.title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(beat.sellerName)
                                    if beat.sellerVerified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(VeltaTheme.accent)
                                    }
                                }
                                Text("\(beat.bpm) BPM · \(beat.key)")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.55))

                            if let owned = app.ownedLicense(for: beat.id) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(VeltaTheme.sky)
                                    Text("You own \(owned.label)")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(VeltaTheme.accentSoft, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }

                            VStack(spacing: 8) {
                                ForEach(beat.licenses) { license in
                                    licenseRow(license, selected: selectedLicense(in: beat)?.tier == license.tier)
                                }
                            }
                        }
                        .padding(gutter)
                        .padding(.bottom, 12)
                    }

                    if let license = selectedLicense(in: beat) {
                        buyBar(beat: beat, license: license)
                    }
                }
                .onAppear {
                    if selectedTier == nil {
                        selectedTier = beat.licenses.first?.tier
                    }
                    app.play(beat)
                }
            } else {
                ContentUnavailableView("Beat not found", systemImage: "music.note")
            }
        }
        .veltaScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let beat = app.catalog.beat(id: beatId) {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        app.toggleLike(beat.id)
                    } label: {
                        Image(systemName: app.isLiked(beat.id) ? "heart.fill" : "heart")
                            .foregroundStyle(app.isLiked(beat.id) ? .red : .white)
                    }
                }
            }
        }
    }

    private func selectedLicense(in beat: Beat) -> BeatLicense? {
        beat.license(tier: selectedTier ?? "") ?? beat.licenses.first
    }

    private func licenseRow(_ license: BeatLicense, selected: Bool) -> some View {
        Button {
            selectedTier = license.tier
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(license.label)
                        .font(.headline)
                    Text(license.description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(license.price, specifier: "%.2f")")
                        .font(.headline)
                        .monospacedDigit()
                    Text(selected ? "Selected" : "Select")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(selected ? VeltaTheme.sky : .white.opacity(0.45))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selected ? VeltaTheme.accentSoft : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(selected ? VeltaTheme.accent : VeltaTheme.inkLine)
                    )
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    private func buyBar(beat: Beat, license: BeatLicense) -> some View {
        VStack(spacing: 10) {
            Rectangle()
                .fill(VeltaTheme.inkLine)
                .frame(height: 0.5)

            HStack(spacing: 10) {
                Button {
                    app.addToCart(beat, tier: license.tier)
                    app.selectedTab = .cart
                } label: {
                    Text("Add to bag")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .strokeBorder(VeltaTheme.inkLine)
                                .background(VeltaTheme.inkElevated, in: Capsule())
                        )
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)

                Button {
                    app.openCheckout(beat, tier: license.tier)
                } label: {
                    Text("Buy \(license.label)")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(VeltaTheme.accent, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, gutter)
            .padding(.bottom, 8)
        }
        .background(VeltaTheme.ink)
        .accessibilityElement(children: .contain)
    }
}

private struct FlowGenreRow: View {
    var genres: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(genres, id: \.self) { genre in
                Text(genre)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.05), in: Capsule())
                    .overlay(Capsule().strokeBorder(VeltaTheme.inkLine))
            }
            Spacer(minLength: 0)
        }
    }
}

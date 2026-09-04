import SwiftUI

struct BeatDetailView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var appWidth
    let beatId: String

    private var gutter: CGFloat { VeltaLayout.gutter(for: appWidth) }

    var body: some View {
        Group {
            if let beat = app.catalog.beat(id: beatId) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: min(appWidth - gutter * 2, 520))
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                ForEach(beat.genres, id: \.self) { genre in
                                    Text(genre)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.white.opacity(0.05), in: Capsule())
                                        .overlay(Capsule().strokeBorder(VeltaTheme.inkLine))
                                }
                            }

                            Text(beat.title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)

                            HStack(spacing: 10) {
                                Text(beat.sellerName)
                                if beat.sellerVerified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(VeltaTheme.accent)
                                }
                                Text("\(beat.bpm) BPM")
                                Text(beat.key)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.55))
                        }

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

                        VStack(spacing: 10) {
                            ForEach(beat.licenses) { license in
                                HStack(alignment: .center, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(license.label)
                                            .font(.headline)
                                        Text(license.description)
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    Spacer()
                                    Text("$\(license.price, specifier: "%.2f")")
                                        .font(.headline)
                                        .monospacedDigit()
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.white.opacity(0.03))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .strokeBorder(VeltaTheme.inkLine)
                                        )
                                )
                            }
                        }

                        HStack(spacing: 10) {
                            if let first = beat.licenses.first {
                                Button {
                                    app.addToCart(beat, tier: first.tier)
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
                                    app.openCheckout(beat, tier: first.tier)
                                } label: {
                                    Text("Buy in app")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(VeltaTheme.accent, in: Capsule())
                                        .foregroundStyle(.white)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(gutter)
                    .padding(.bottom, 24)
                }
                .onAppear { app.play(beat) }
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
}

import SwiftUI

struct CartView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width

    var body: some View {
        VStack(spacing: 0) {
            ExploreHeader(title: "Bag", showsBell: false)

            if app.cart.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "bag")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.4))
                    Text("Bag is empty")
                        .font(.headline)
                    Text("Add a license from any beat. Checkout stays in the app.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                    Button("Explore beats", action: app.openBeats)
                        .font(.headline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(VeltaTheme.accent, in: Capsule())
                        .foregroundStyle(.white)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(app.cart) { item in
                            if let beat = app.catalog.beat(id: item.beatId),
                               let license = beat.license(tier: item.tier)
                            {
                                cartRow(beat: beat, license: license, item: item)
                            }
                        }
                    }
                    .padding(.horizontal, VeltaLayout.gutter(for: width))
                    .padding(.bottom, 120)
                }

                VStack(spacing: 12) {
                    HStack {
                        Text("Total")
                            .foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        Text("$\(app.cartTotal, specifier: "%.2f")")
                            .font(.title3.weight(.bold))
                    }
                    Button {
                        Task { await app.purchaseCart() }
                    } label: {
                        Group {
                            if app.isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Checkout in app")
                            }
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(VeltaTheme.accent, in: Capsule())
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .disabled(app.isPurchasing)
                }
                .padding(16)
                .background(VeltaTheme.inkElevated)
            }
        }
        .veltaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func cartRow(beat: Beat, license: BeatLicense, item: CartItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(beat.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(license.label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                Text("$\(license.price, specifier: "%.2f")")
                    .font(.subheadline.weight(.semibold))
            }

            Spacer()

            Button {
                app.removeFromCart(item)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.white.opacity(0.45))
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }
}

import SwiftUI

struct CartView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width

    private var gutter: CGFloat { VeltaLayout.gutter(for: width) }
    private var likedBeats: [Beat] { app.likedBeats() }

    var body: some View {
        VStack(spacing: 0) {
            ExploreHeader(title: "Bag", showsBell: false)

            if app.cart.isEmpty && likedBeats.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        if !app.cart.isEmpty {
                            bagSection
                        }
                        if !likedBeats.isEmpty {
                            likedSection
                        }
                    }
                    .padding(.horizontal, gutter)
                    .padding(.bottom, app.cart.isEmpty ? 28 : 120)
                }

                if !app.cart.isEmpty {
                    checkoutBar
                }
            }
        }
        .veltaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var bagSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("In your bag")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(app.cart) { item in
                if let beat = app.catalog.beat(id: item.beatId),
                   let license = beat.license(tier: item.tier)
                {
                    cartRow(beat: beat, license: license, item: item)
                }
            }
        }
    }

    private var likedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Liked beats")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(likedBeats) { beat in
                NavigationLink(value: AppRoute.beat(beat.id)) {
                    likedRow(beat)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "bag")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.4))
            Text("Bag is empty")
                .font(.headline)
            Text("Add a license from any beat, or save beats with the heart.")
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
    }

    private var checkoutBar: some View {
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

    private func likedRow(_ beat: Beat) -> some View {
        HStack(spacing: 12) {
            BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(beat.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(beat.sellerName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Image(systemName: "heart.fill")
                .font(.caption)
                .foregroundStyle(.red.opacity(0.85))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }
}

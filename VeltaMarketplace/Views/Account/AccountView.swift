import SwiftUI

struct AccountView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ExploreHeader(title: "Menu", showsBell: false)

                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 52, height: 52)
                        .background(Color.white.opacity(0.08), in: Circle())
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Demo Buyer")
                            .font(.title3.weight(.semibold))
                        Text(app.catalog.isLive ? "Connected to store" : "Offline catalog")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.horizontal, VeltaLayout.gutter(for: width))

                VStack(spacing: 0) {
                    studioRow
                    Button { app.selectedTab = .library } label: {
                        menuLabel(title: "Licenses", subtitle: "\(app.licenses.count) owned in this app", systemImage: "opticaldisc")
                    }
                    .buttonStyle(.plain)
                    Button { app.selectedTab = .cart } label: {
                        menuLabel(title: "Bag", subtitle: app.cart.isEmpty ? "Empty" : "\(app.cartCount) items", systemImage: "bag")
                    }
                    .buttonStyle(.plain)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )
                .padding(.horizontal, VeltaLayout.gutter(for: width))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Catalog")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.45))
                    LabeledContent("Beats", value: "\(app.catalog.beats.count)")
                    LabeledContent("Source", value: app.catalog.isLive ? "Live API" : "Bundled")
                    LabeledContent("Checkout", value: "In-app")
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )
                .padding(.horizontal, VeltaLayout.gutter(for: width))
            }
            .padding(.bottom, 28)
        }
        .veltaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var studioRow: some View {
        NavigationLink(value: AppRoute.studio) {
            menuLabel(title: "Studio", subtitle: "Uploads, payments, and live beats", systemImage: "square.grid.2x2")
        }
        .buttonStyle(.plain)
    }

    private func menuLabel(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(VeltaTheme.inkElevated, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(14)
    }
}

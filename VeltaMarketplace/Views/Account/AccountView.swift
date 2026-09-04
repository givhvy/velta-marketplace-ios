import SwiftUI

struct AccountView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ExploreHeader(title: "Menu", showsBell: false)

                profileCard
                    .padding(.horizontal, VeltaLayout.gutter(for: width))

                menuSection("Account") {
                    if app.auth.isSignedIn {
                        NavigationLink(value: AppRoute.orders) {
                            menuLabel(title: "Orders", subtitle: "\(app.licenses.count) purchases on this device", systemImage: "clock.arrow.circlepath")
                        }
                        .buttonStyle(.plain)
                        NavigationLink(value: AppRoute.payments) {
                            menuLabel(title: "Payment methods", subtitle: "Apple Pay and in-app checkout", systemImage: "creditcard")
                        }
                        .buttonStyle(.plain)
                    }
                    NavigationLink(value: AppRoute.settings) {
                        menuLabel(title: "Settings", subtitle: app.auth.isSignedIn ? app.auth.user?.email ?? "Account" : "Notifications and store", systemImage: "gearshape")
                    }
                    .buttonStyle(.plain)
                }

                menuSection("Shopping") {
                    Button { app.selectedTab = .cart } label: {
                        menuLabel(title: "Bag", subtitle: app.cart.isEmpty ? "Empty" : "\(app.cartCount) items", systemImage: "bag")
                    }
                    .buttonStyle(.plain)
                    Button { app.selectedTab = .library } label: {
                        menuLabel(title: "Licenses", subtitle: "\(app.licenses.count) owned in this app", systemImage: "opticaldisc")
                    }
                    .buttonStyle(.plain)
                    Button {
                        app.selectedTab = .library
                    } label: {
                        menuLabel(title: "Liked beats", subtitle: "\(app.likedBeats().count) saved", systemImage: "heart")
                    }
                    .buttonStyle(.plain)
                }

                if app.auth.user?.role.canAccessStudio == true {
                    menuSection("Producer") {
                        NavigationLink(value: AppRoute.studio) {
                            menuLabel(title: "Studio", subtitle: "Uploads, payments, and live beats", systemImage: "square.grid.2x2")
                        }
                        .buttonStyle(.plain)
                    }
                }

                menuSection("Support") {
                    NavigationLink(value: AppRoute.help) {
                        menuLabel(title: "Help center", subtitle: "Buying, licenses, and Studio", systemImage: "questionmark.circle")
                    }
                    .buttonStyle(.plain)
                    NavigationLink(value: AppRoute.legal(.terms)) {
                        menuLabel(title: "Terms of Service", subtitle: "License rules and usage", systemImage: "doc.text")
                    }
                    .buttonStyle(.plain)
                    NavigationLink(value: AppRoute.legal(.privacy)) {
                        menuLabel(title: "Privacy Policy", subtitle: "How data is stored on device", systemImage: "hand.raised")
                    }
                    .buttonStyle(.plain)
                }

                authAction
                    .padding(.horizontal, VeltaLayout.gutter(for: width))

                Text("Velta Marketplace · v1.0 · \(app.catalog.isLive ? "Live store" : "Offline catalog")")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
            }
            .padding(.bottom, 28)
        }
        .veltaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var profileCard: some View {
        if app.auth.isSignedIn, let user = app.auth.user {
            HStack(spacing: 12) {
                Image(systemName: user.role.canAccessStudio ? "music.mic" : "person.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.08), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.title3.weight(.semibold))
                    Text(user.email)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text(user.role.label)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(VeltaTheme.sky)
                }
                Spacer()
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 52, height: 52)
                        .background(Color.white.opacity(0.08), in: Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sign in to Velta")
                            .font(.title3.weight(.semibold))
                        Text("Sync purchases and open Studio with a seller account.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                NavigationLink(value: AppRoute.login) {
                    Text("Sign in")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(VeltaTheme.accent, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var authAction: some View {
        if app.auth.isSignedIn {
            Button {
                Task {
                    await app.auth.logout()
                    app.toast = "Signed out"
                }
            } label: {
                Text("Sign out")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        Capsule()
                            .strokeBorder(VeltaTheme.inkLine)
                            .background(VeltaTheme.inkElevated, in: Capsule())
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(value: AppRoute.login) {
                Text("Sign in")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(VeltaTheme.accent, in: Capsule())
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
    }

    private func menuSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.45))
                .padding(.horizontal, VeltaLayout.gutter(for: width))

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.04))
            )
            .padding(.horizontal, VeltaLayout.gutter(for: width))
        }
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

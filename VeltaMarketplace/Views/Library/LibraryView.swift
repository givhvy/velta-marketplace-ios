import SwiftUI

struct LibraryView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width
    @State private var segment = 0

    var body: some View {
        VStack(spacing: 0) {
            ExploreHeader(title: "Library", showsBell: false)

            Picker("Library", selection: $segment) {
                Text("Licenses").tag(0)
                Text("Liked").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, VeltaLayout.gutter(for: width))
            .padding(.bottom, 16)

            if segment == 0 {
                licenseList
            } else {
                likedList
            }
        }
        .veltaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var licenseList: some View {
        if app.licenses.isEmpty {
            emptyState(
                title: "No licenses yet",
                systemImage: "heart",
                detail: "Buy a lease in the app and it stays here. Nothing opens Safari."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(app.licenses) { license in
                        if let beat = app.catalog.beat(id: license.beatId) {
                            NavigationLink(value: AppRoute.license(license.id)) {
                                licenseRow(beat: beat, license: license)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, VeltaLayout.gutter(for: width))
                .padding(.bottom, 28)
            }
        }
    }

    @ViewBuilder
    private var likedList: some View {
        let beats = app.likedBeats()
        if beats.isEmpty {
            emptyState(
                title: "No saved beats",
                systemImage: "heart",
                detail: "Tap the heart on a beat to keep it here."
            )
        } else {
            beatList(beats) { $0.sellerName }
        }
    }

    private func licenseRow(beat: Beat, license: OwnedLicense) -> some View {
        HStack(spacing: 12) {
            BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(beat.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text("\(license.label) · $\(String(format: "%.2f", license.amount))")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.25))
        }
    }

    private func beatList(_ beats: [Beat], subtitle: @escaping (Beat) -> String) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(beats) { beat in
                    NavigationLink(value: AppRoute.beat(beat.id)) {
                        HStack(spacing: 12) {
                            BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(beat.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                Text(subtitle(beat))
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, VeltaLayout.gutter(for: width))
            .padding(.bottom, 28)
        }
    }

    private func emptyState(title: String, systemImage: String, detail: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.4))
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Button("Browse beats", action: app.openBeats)
                .font(.headline)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(VeltaTheme.accent, in: Capsule())
                .foregroundStyle(.white)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

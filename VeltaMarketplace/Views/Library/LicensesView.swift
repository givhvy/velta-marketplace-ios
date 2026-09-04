import SwiftUI

struct LicensesView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width

    var body: some View {
        Group {
            if app.licenses.isEmpty {
                ContentUnavailableView(
                    "No licenses yet",
                    systemImage: "opticaldisc",
                    description: Text("Buy a lease in the app and it stays here.")
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
        .veltaScreen()
        .navigationTitle("Licenses")
        .navigationBarTitleDisplayMode(.inline)
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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }
}

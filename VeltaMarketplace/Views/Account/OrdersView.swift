import SwiftUI

struct OrdersView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width

    var body: some View {
        Group {
            if app.licenses.isEmpty {
                ContentUnavailableView(
                    "No orders yet",
                    systemImage: "bag",
                    description: Text("Purchased licenses appear here with price and date.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(app.licenses) { license in
                            if let beat = app.catalog.beat(id: license.beatId) {
                                orderRow(beat: beat, license: license)
                            }
                        }
                    }
                    .padding(.horizontal, VeltaLayout.gutter(for: width))
                    .padding(.bottom, 28)
                }
            }
        }
        .veltaScreen()
        .navigationTitle("Orders")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func orderRow(beat: Beat, license: OwnedLicense) -> some View {
        HStack(spacing: 12) {
            BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(beat.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(license.label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                Text(formattedDate(license.purchasedAt))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))
            }

            Spacer(minLength: 8)

            Text(license.amount, format: .currency(code: "USD"))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(VeltaTheme.price)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }

    private func formattedDate(_ raw: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: raw) else { return raw }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

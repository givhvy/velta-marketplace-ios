import SwiftUI
import UIKit

struct LicenseDetailView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width
    let licenseId: String

    private var gutter: CGFloat { VeltaLayout.gutter(for: width) }

    private var license: OwnedLicense? { app.licenseRecord(id: licenseId) }

    var body: some View {
        Group {
            if let license, let beat = app.catalog.beat(id: license.beatId) {
                detailContent(beat: beat, license: license)
            } else {
                ContentUnavailableView("Purchase not found", systemImage: "doc.text")
                    .foregroundStyle(.white)
            }
        }
        .veltaScreen()
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailContent(beat: Beat, license: OwnedLicense) -> some View {
        let files = beat.downloadCandidates(
            for: license.tier,
            primary: app.catalog.mediaBase,
            fallback: app.catalog.mediaFallbackBase
        )
        let primaryURL = files.first?.urls.first

        return ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                sellerCard(beat: beat)
                orderSummary(license: license, primaryURL: primaryURL)
                transactionSection(beat: beat, license: license)
                filesSection(files: files)
                customerSection
            }
            .padding(.horizontal, gutter)
            .padding(.bottom, 120)
        }
    }

    private func sellerCard(beat: Beat) -> some View {
        HStack(spacing: 12) {
            BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(beat.sellerName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    if beat.sellerVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(VeltaTheme.sky)
                    }
                }
                Text("Licensed beat · \(beat.genreLine)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .padding(.top, 8)
    }

    private func orderSummary(license: OwnedLicense, primaryURL: URL?) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            summaryRow("Order date", value: formattedDate(license.purchasedAt, includeWeekday: true))
            invoiceRow(license.invoiceNumber)
            summaryRow("Total", value: license.amount, format: .currency(code: "USD"))
            summaryRow("Status", value: "Completed")

            if let primaryURL {
                ShareLink(item: primaryURL) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Go to files")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(VeltaTheme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            } else {
                Button {
                    app.toast = "Download links unavailable offline"
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Go to files")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(VeltaTheme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private func transactionSection(beat: Beat, license: OwnedLicense) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transaction details")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 10) {
                Text("Item 01")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.45))
                Text(beat.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                lineItem("Price", value: license.amount)
                lineItem("License", valueText: license.label)
                HStack {
                    Text("Subtotal")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text(license.amount, format: .currency(code: "USD"))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(VeltaTheme.price)
                }
            }
            .padding(16)
            .background(cardBackground)
        }
    }

    private func filesSection(files: [(file: LicenseDownloadFile, urls: [URL])]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your files")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                ForEach(Array(files.enumerated()), id: \.offset) { index, entry in
                    if index > 0 {
                        Divider().overlay(VeltaTheme.inkLine)
                    }
                    fileRow(entry.file, urls: entry.urls)
                }
            }
            .background(cardBackground)
        }
    }

    private func fileRow(_ file: LicenseDownloadFile, urls: [URL]) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon(for: file.fileName))
                .font(.title3)
                .foregroundStyle(VeltaTheme.accent)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(file.fileName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer(minLength: 8)

            if let url = urls.first {
                ShareLink(item: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(VeltaTheme.sky)
                }
            }
        }
        .padding(14)
    }

    private var customerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Customer information")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 8) {
                infoLine("Name", value: app.auth.user?.name ?? "Demo Buyer")
                infoLine("Email", value: app.auth.user?.email ?? "buyer@demo.local")
                infoLine("Device", value: "This iPhone")
            }
            .padding(16)
            .background(cardBackground)
        }
    }

    private func invoiceRow(_ invoice: String) -> some View {
        HStack(alignment: .top) {
            Text("Invoice number")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.55))
            Spacer(minLength: 12)
            HStack(spacing: 8) {
                Text(invoice)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.trailing)
                Button {
                    UIPasteboard.general.string = invoice
                    app.toast = "Invoice copied"
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(VeltaTheme.sky)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func summaryRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.55))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
    }

    private func summaryRow(_ title: String, value: Double, format: FloatingPointFormatStyle<Double>.Currency) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.55))
            Spacer()
            Text(value, format: format)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
        }
    }

    private func lineItem(_ title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
            Spacer()
            Text(value, format: .currency(code: "USD"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private func lineItem(_ title: String, valueText: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
            Spacer()
            Text(valueText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private func infoLine(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.06))
            )
    }

    private func formattedDate(_ raw: String, includeWeekday: Bool = false) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: raw) else { return raw }
        if includeWeekday {
            return date.formatted(.dateTime.weekday(.wide).month().day().year())
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private func icon(for fileName: String) -> String {
        if fileName.hasSuffix(".zip") { return "doc.zipper" }
        if fileName.hasSuffix(".pdf") { return "doc.richtext" }
        if fileName.hasSuffix(".wav") { return "waveform" }
        return "music.note"
    }
}

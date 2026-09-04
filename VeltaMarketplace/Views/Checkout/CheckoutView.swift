import SwiftUI

struct CheckoutView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    let beat: Beat
    @State var tier: String

    var body: some View {
        let selected = beat.license(tier: tier)

        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(beat.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(beat.sellerName)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }

                VStack(spacing: 8) {
                    ForEach(beat.licenses) { license in
                        Button {
                            tier = license.tier
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(license.label)
                                        .font(.subheadline.weight(.semibold))
                                    Text(license.description)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                        .lineLimit(2)
                                }
                                Spacer()
                                Text("$\(license.price, specifier: "%.2f")")
                                    .font(.subheadline.weight(.bold))
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(tier == license.tier ? VeltaTheme.accentSoft : Color.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(
                                                tier == license.tier ? VeltaTheme.accent : VeltaTheme.inkLine
                                            )
                                    )
                            )
                            .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                if let selected {
                    Button {
                        Task {
                            await app.purchase(beat, tier: selected.tier)
                            dismiss()
                        }
                    } label: {
                        Group {
                            if app.isPurchasing {
                                ProgressView().tint(.white)
                            } else {
                                Text("Pay $\(selected.price, specifier: "%.2f") in app")
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

                    Text("License is stored on this iPhone. If Studio is running locally, the purchase is also recorded there.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .veltaScreen()
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

import PassKit
import SwiftUI

struct CheckoutView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let beat: Beat
    @State var tier: String
    @State private var applePay = ApplePaySession()

    var body: some View {
        let selected = beat.license(tier: tier)
        let coverSize: CGFloat = verticalSizeClass == .compact ? 52 : 64

        VStack(spacing: 0) {
            HStack {
                Text("Checkout")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            HStack(alignment: .top, spacing: 12) {
                BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                    .frame(width: coverSize, height: coverSize)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(beat.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(beat.sellerName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(beat.licenses) { license in
                        Button {
                            tier = license.tier
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(license.label)
                                        .font(.subheadline.weight(.semibold))
                                    Text(license.description)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 8)
                                Text(license.price, format: .currency(code: "USD"))
                                    .font(.subheadline.weight(.bold))
                                    .monospacedDigit()
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .padding(14)
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
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }

            if let selected {
                VStack(spacing: 10) {
                    applePayButton(beat: beat, license: selected)

                    Button {
                        Task { await completePurchase(beat: beat, tier: selected.tier) }
                    } label: {
                        Group {
                            if app.isPurchasing {
                                ProgressView().tint(.white)
                            } else {
                                Text("Pay \(selected.price, format: .currency(code: "USD")) without Apple Pay")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                        }
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    .disabled(app.isPurchasing)

                    Text("License is stored on this iPhone. If Studio is running locally, the purchase is also recorded there.")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .veltaScreen()
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func applePayButton(beat: Beat, license: BeatLicense) -> some View {
        PayWithApplePayButton(.buy) {
            applePay.onAuthorized = {
                await completePurchase(beat: beat, tier: license.tier)
            }
            applePay.onUnavailable = {
                app.toast = "Apple Pay isn’t set up on this device"
            }
            applePay.start(amount: license.price, label: "\(beat.title) · \(license.label)")
        }
        .payWithApplePayButtonStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .disabled(app.isPurchasing)
        .accessibilityLabel("Buy with Apple Pay")
    }

    private func completePurchase(beat: Beat, tier: String) async {
        await app.purchase(beat, tier: tier)
        dismiss()
    }
}

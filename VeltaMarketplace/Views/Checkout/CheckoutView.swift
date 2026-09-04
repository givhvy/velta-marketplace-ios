import PassKit
import SwiftUI

struct CheckoutView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    let beat: Beat
    @State var tier: String
    @State private var applePay = ApplePaySession()

    var body: some View {
        let selected = beat.license(tier: tier)

        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("Checkout")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Spacer(minLength: 12)
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
            .frame(minHeight: 44)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            VStack(spacing: 8) {
                ForEach(beat.licenses) { license in
                    licenseRow(license)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)

            Spacer(minLength: 8)

            if let selected {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Button {
                            app.addToCart(beat, tier: selected.tier)
                            dismiss()
                            app.selectedTab = .cart
                        } label: {
                            Text("Add to bag")
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

                        Button {
                            Task { await completePurchase(beat: beat, tier: selected.tier) }
                        } label: {
                            Group {
                                if app.isPurchasing {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Buy \(selected.label)")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                }
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(VeltaTheme.accent, in: Capsule())
                            .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                        .disabled(app.isPurchasing)
                    }

                    applePayButton(beat: beat, license: selected)

                    Text("License stays on this iPhone.")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .safeAreaPadding(.bottom, 12)
            }
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            VeltaTheme.ink
                .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
    }

    private func licenseRow(_ license: BeatLicense) -> some View {
        Button {
            tier = license.tier
        } label: {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(license.label)
                        .font(.subheadline.weight(.semibold))
                    Text(license.description)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(+2)
                }
                Spacer(minLength: 8)
                Text(license.price, format: .currency(code: "USD"))
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tier == license.tier ? VeltaTheme.accentSoft : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(tier == license.tier ? VeltaTheme.accent : VeltaTheme.inkLine)
                    )
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
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
        .frame(height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .disabled(app.isPurchasing)
        .accessibilityLabel("Buy with Apple Pay")
    }

    private func completePurchase(beat: Beat, tier: String) async {
        await app.purchase(beat, tier: tier)
        dismiss()
    }
}

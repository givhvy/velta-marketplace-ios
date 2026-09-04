import SwiftUI

struct HelpView: View {
    private let items: [(String, String)] = [
        ("How do I buy a beat?", "Open a beat, pick a license tier, then tap Buy. Checkout stays inside the app with Apple Pay or card fallback."),
        ("Where are my files?", "Licensed beats appear under Library → Licenses on this iPhone."),
        ("Can I sell beats here?", "Sign in with a seller demo account and open Studio from Menu."),
        ("Need support?", "Email support@velta.local with your order email and beat title."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(items, id: \.0) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.0)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(item.1)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.04))
                    )
                }
            }
            .padding(16)
            .padding(.bottom, 28)
        }
        .veltaScreen()
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

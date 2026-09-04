import SwiftUI

struct PaymentMethodsView: View {
    var body: some View {
        List {
            Section {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Apple Pay")
                            .font(.headline)
                        Text("Default checkout on this iPhone")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "apple.logo")
                }

                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("In-app checkout")
                            .font(.headline)
                        Text("Pay without leaving Velta")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "creditcard")
                }
            } footer: {
                Text("Card vaulting and saved cards will sync here when connected to your live Velta store account.")
            }
        }
        .scrollContentBackground(.hidden)
        .veltaScreen()
        .navigationTitle("Payment methods")
        .navigationBarTitleDisplayMode(.inline)
    }
}

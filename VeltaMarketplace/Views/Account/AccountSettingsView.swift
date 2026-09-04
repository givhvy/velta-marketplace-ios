import SwiftUI

struct AccountSettingsView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        @Bindable var app = app

        List {
            if let user = app.auth.user {
                Section("Account") {
                    LabeledContent("Name", value: user.name)
                    LabeledContent("Email", value: user.email)
                    LabeledContent("Role", value: user.role.label)
                }
            }

            Section("Preferences") {
                Toggle("Push notifications", isOn: $app.notificationsEnabled)
            }

            Section("Store") {
                LabeledContent("Catalog", value: app.catalog.isLive ? "Live API" : "Offline bundle")
                LabeledContent("Media CDN", value: app.catalog.mediaBase.host ?? "wavs.huy.global")
                LabeledContent("Checkout", value: "In-app")
            }
        }
        .scrollContentBackground(.hidden)
        .veltaScreen()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

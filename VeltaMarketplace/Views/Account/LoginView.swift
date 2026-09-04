import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @Environment(\.veltaWidth) private var width

    @State private var email = "buyer@demo.local"
    @State private var error: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Sign in")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text("Use a demo account or enter the email tied to your Velta store profile.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.45))
                    TextField("buyer@demo.local", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red.opacity(0.85))
                }

                Button {
                    Task { await signInWithEmail() }
                } label: {
                    Group {
                        if app.auth.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Continue")
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(VeltaTheme.accent, in: Capsule())
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled(app.auth.isLoading)

                Text("Demo accounts")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(.top, 4)

                VStack(spacing: 10) {
                    ForEach(DemoAccount.allCases) { account in
                        Button {
                            Task { await signIn(demo: account) }
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(account.name)
                                        .font(.subheadline.weight(.semibold))
                                    Text(account.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                Spacer()
                                Text(account.role.label)
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(VeltaTheme.accentSoft, in: Capsule())
                                    .foregroundStyle(VeltaTheme.sky)
                            }
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.04))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(app.auth.isLoading)
                    }
                }
            }
            .padding(VeltaLayout.gutter(for: width))
            .padding(.bottom, 28)
        }
        .veltaScreen()
        .navigationTitle("Sign in")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signInWithEmail() async {
        error = await app.auth.login(email: email, webBase: app.catalog.webBase)
        if error == nil {
            app.toast = "Signed in as \(app.auth.user?.name ?? "Velta")"
            dismiss()
        }
    }

    private func signIn(demo: DemoAccount) async {
        email = demo.email
        error = await app.auth.login(demo: demo)
        if error == nil {
            app.toast = "Signed in as \(demo.name)"
            dismiss()
        }
    }
}

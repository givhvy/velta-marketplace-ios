import Foundation

@MainActor
@Observable
final class AuthStore {
    private(set) var user: AuthUser?
    private(set) var token: String?
    private(set) var isLoading = false

    private let sessionKey = "velta.auth.session"

    init() {
        restoreSession()
    }

    var isSignedIn: Bool { user != nil }

    func restoreSession() {
        guard let data = UserDefaults.standard.data(forKey: sessionKey),
              let session = try? JSONDecoder().decode(AuthSession.self, from: data)
        else {
            user = nil
            token = nil
            return
        }
        user = session.user
        token = session.token
    }

    func login(email: String, webBase: URL) async -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return "Enter an email to continue." }

        isLoading = true
        defer { isLoading = false }

        if let remote = await remoteLogin(email: trimmed, webBase: webBase) {
            apply(session: remote)
            return nil
        }

        if let demo = DemoAccount.allCases.first(where: { $0.email.lowercased() == trimmed }) {
            applyLocal(demo: demo)
            return nil
        }

        return "Unknown account. Try buyer@demo.local or studio@velta.local."
    }

    func login(demo: DemoAccount) async -> String? {
        isLoading = true
        defer { isLoading = false }

        if let remote = await remoteLogin(email: demo.email, webBase: URL(string: "http://127.0.0.1:3000")!) {
            apply(session: remote)
            return nil
        }

        applyLocal(demo: demo)
        return nil
    }

    func logout() async {
        if let token {
            await remoteLogout(token: token)
        }
        user = nil
        self.token = nil
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    func authorizationHeader() -> String? {
        token.map { "Bearer \($0)" }
    }

    private func apply(session: AuthSession) {
        user = session.user
        token = session.token
        persist(session)
    }

    private func applyLocal(demo: DemoAccount) {
        let session = AuthSession(
            token: "local.\(demo.email)",
            user: demo.user
        )
        apply(session: session)
    }

    private func persist(_ session: AuthSession) {
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: sessionKey)
        }
    }

    private func remoteLogin(email: String, webBase: URL) async -> AuthSession? {
        let endpoints = [
            webBase.appending(path: "api/mobile/auth/login"),
            URL(string: "http://127.0.0.1:3000/api/mobile/auth/login"),
            URL(string: "http://localhost:3000/api/mobile/auth/login"),
        ].compactMap { $0 }

        let body = ["email": email]
        guard let payload = try? JSONEncoder().encode(body) else { return nil }

        for url in endpoints {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = payload
            request.timeoutInterval = 4

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
                    continue
                }
                let decoded = try JSONDecoder().decode(AuthLoginResponse.self, from: data)
                guard let token = decoded.token, let user = decoded.user else { continue }
                return AuthSession(token: token, user: user)
            } catch {
                continue
            }
        }

        return nil
    }

    private func remoteLogout(token: String) async {
        guard !token.hasPrefix("local.") else { return }

        let url = URL(string: "http://127.0.0.1:3000/api/mobile/auth/logout")
        guard let url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 3
        _ = try? await URLSession.shared.data(for: request)
    }
}

import Foundation

enum UserRole: String, Codable, Hashable, Sendable {
    case buyer
    case seller
    case admin

    var canAccessStudio: Bool {
        self == .seller || self == .admin
    }

    var label: String {
        switch self {
        case .buyer: "Buyer"
        case .seller: "Seller"
        case .admin: "Admin"
        }
    }
}

struct AuthUser: Identifiable, Hashable, Codable, Sendable {
    var id: String
    var email: String
    var name: String
    var role: UserRole
    var sellerSlug: String?
}

struct AuthSession: Codable, Sendable {
    var token: String
    var user: AuthUser
}

struct AuthLoginResponse: Decodable, Sendable {
    var ok: Bool?
    var token: String?
    var user: AuthUser?
    var error: String?
}

struct AuthMeResponse: Decodable, Sendable {
    var ok: Bool?
    var user: AuthUser?
}

enum DemoAccount: CaseIterable, Identifiable {
    case buyer
    case seller
    case admin

    var id: String { email }

    var email: String {
        switch self {
        case .buyer: "buyer@demo.local"
        case .seller: "studio@velta.local"
        case .admin: "admin@velta.local"
        }
    }

    var name: String {
        switch self {
        case .buyer: "Demo Buyer"
        case .seller: "Velta Beats"
        case .admin: "Platform Admin"
        }
    }

    var role: UserRole {
        switch self {
        case .buyer: .buyer
        case .seller: .seller
        case .admin: .admin
        }
    }

    var subtitle: String {
        switch self {
        case .buyer: "Browse, buy beats, library"
        case .seller: "Uploads, payments, live beats"
        case .admin: "Full platform access"
        }
    }

    var user: AuthUser {
        AuthUser(
            id: userID,
            email: email,
            name: name,
            role: role,
            sellerSlug: self == .seller ? "velta-beats" : nil
        )
    }

    private var userID: String {
        switch self {
        case .buyer: "user_demo_buyer"
        case .seller: "seller_velta"
        case .admin: "user_admin"
        }
    }
}

enum LegalDocument: String, Hashable, Identifiable {
    case terms
    case privacy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .terms: "Terms of Service"
        case .privacy: "Privacy Policy"
        }
    }

    var body: String {
        switch self {
        case .terms:
            """
            Licenses purchased in Velta Marketplace are for the email account signed in on this device. \
            MP3 and WAV leases include stream caps listed on each beat. Exclusive purchases remove the beat from the public store.

            You may not redistribute untagged audio outside the license terms. Chargebacks or fraud may result in license revocation.

            For demo purchases in this app, checkout stays on-device and syncs to the connected store when available.
            """
        case .privacy:
            """
            Velta stores your cart, licenses, and likes on this iPhone. When signed in, purchases can sync to the connected Velta store account.

            We do not sell personal data. Preview playback and checkout events may be logged by the store API for fraud prevention.

            Sign out any time from Menu to clear the active session on this device.
            """
        }
    }
}

import Foundation

@MainActor
@Observable
final class AppState {
    let catalog = CatalogStore()
    let auth = AuthStore()
    let previewPlayer = PreviewPlayer()
    var selectedTab: AppTab = .beats
    var isBeatSearchPresented = false
    var pendingBeatDetailId: String?
    var activeClipID: String?
    var nowPlayingID: String?
    var likedClipIDs: [String] = []
    var cart: [CartItem] = []
    var licenses: [OwnedLicense] = []
    var likedIDs: [String] = []
    var recentlyViewedIDs: [String] = []
    var checkout: CheckoutTarget?
    var toast: String?
    var isPurchasing = false
    var hideBottomChrome = false
    var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: notificationsKey) }
    }

    private let cartKey = "velta.cart"
    private let licensesKey = "velta.licenses"
    private let likesKey = "velta.likes"
    private let recentKey = "velta.recent"
    private let notificationsKey = "velta.notifications"

    init() {
        cart = Self.load(cartKey) ?? []
        licenses = Self.load(licensesKey) ?? []
        likedIDs = UserDefaults.standard.stringArray(forKey: likesKey) ?? []
        recentlyViewedIDs = UserDefaults.standard.stringArray(forKey: recentKey) ?? []
        notificationsEnabled = UserDefaults.standard.object(forKey: notificationsKey) as? Bool ?? true
    }

    var cartCount: Int { cart.count }

    var cartTotal: Double {
        cart.reduce(0) { partial, item in
            guard let beat = catalog.beat(id: item.beatId),
                  let license = beat.license(tier: item.tier)
            else { return partial }
            return partial + license.price
        }
    }

    func load() async {
        await catalog.load()
    }

    func markViewed(_ beatId: String) {
        recentlyViewedIDs.removeAll { $0 == beatId }
        recentlyViewedIDs.insert(beatId, at: 0)
        recentlyViewedIDs = Array(recentlyViewedIDs.prefix(12))
        UserDefaults.standard.set(recentlyViewedIDs, forKey: recentKey)
    }

    func recentBeats() -> [Beat] {
        recentlyViewedIDs.compactMap { catalog.beat(id: $0) }
    }

    func continueBeats() -> [Beat] {
        let recent = recentBeats()
        return recent.isEmpty ? Array(catalog.trending.prefix(8)) : recent
    }

    func openVideo(clipId: String) {
        activeClipID = clipId
        selectedTab = .video
    }

    func isClipLiked(_ id: String) -> Bool {
        likedClipIDs.contains(id)
    }

    func toggleClipLike(_ id: String) {
        if let index = likedClipIDs.firstIndex(of: id) {
            likedClipIDs.remove(at: index)
        } else {
            likedClipIDs.insert(id, at: 0)
        }
    }

    func play(_ beat: Beat) {
        nowPlayingID = beat.id
        markViewed(beat.id)
        let candidates = beat.previewCandidates(
            primary: catalog.mediaBase,
            fallback: catalog.mediaFallbackBase
        )
        guard !candidates.isEmpty else { return }
        Task {
            await previewPlayer.play(beatID: beat.id, candidates: candidates)
        }
    }

    func togglePreview(_ beat: Beat) {
        nowPlayingID = beat.id
        markViewed(beat.id)
        let candidates = beat.previewCandidates(
            primary: catalog.mediaBase,
            fallback: catalog.mediaFallbackBase
        )
        previewPlayer.toggle(beat: beat, candidates: candidates)
    }

    func isPreviewPlaying(_ beatId: String) -> Bool {
        previewPlayer.playingBeatID == beatId && previewPlayer.isPlaying
    }

    func likedBeats() -> [Beat] {
        likedIDs.compactMap { catalog.beat(id: $0) }
    }

    func libraryBeats() -> [Beat] {
        var seen = Set<String>()
        return licenses.compactMap { record in
            guard seen.insert(record.beatId).inserted else { return nil }
            return catalog.beat(id: record.beatId)
        }
    }

    func ownedLicense(for beatId: String) -> OwnedLicense? {
        licenses.first { $0.beatId == beatId }
    }

    func licenseRecord(id: String) -> OwnedLicense? {
        licenses.first { $0.id == id }
    }

    func isLiked(_ beatId: String) -> Bool {
        likedIDs.contains(beatId)
    }

    func toggleLike(_ beatId: String) {
        if let index = likedIDs.firstIndex(of: beatId) {
            likedIDs.remove(at: index)
        } else {
            likedIDs.insert(beatId, at: 0)
        }
        UserDefaults.standard.set(likedIDs, forKey: likesKey)
    }

    func addToCart(_ beat: Beat, tier: String) {
        let item = CartItem(beatId: beat.id, tier: tier)
        if !cart.contains(item) {
            cart.append(item)
            persistCart()
        }
        toast = "Added \(beat.title) to bag"
    }

    func removeFromCart(_ item: CartItem) {
        cart.removeAll { $0.id == item.id }
        persistCart()
    }

    func openCheckout(_ beat: Beat, tier: String) {
        checkout = CheckoutTarget(beatId: beat.id, tier: tier)
    }

    func purchase(_ beat: Beat, tier: String, openLibrary: Bool = true) async {
        guard let license = beat.license(tier: tier) else { return }
        if ownedLicense(for: beat.id) != nil {
            toast = "\(beat.title) is already in your library"
            checkout = nil
            if openLibrary { selectedTab = .library }
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        let remote = await catalog.submitPurchase(
            beatId: beat.id,
            tier: tier,
            authorization: auth.authorizationHeader()
        )
        let record = OwnedLicense(
            id: remote?.id ?? "local_\(UUID().uuidString)",
            beatId: beat.id,
            tier: license.tier,
            label: license.label,
            amount: remote?.amount ?? license.price,
            purchasedAt: remote?.createdAt ?? ISO8601DateFormatter().string(from: Date())
        )
        licenses.insert(record, at: 0)
        cart.removeAll { $0.beatId == beat.id }
        persistCart()
        persistLicenses()
        checkout = nil
        toast = "Licensed \(beat.title) · \(license.label)"
        if openLibrary { selectedTab = .library }
    }

    func purchaseCart() async {
        let items = cart
        for item in items {
            guard let beat = catalog.beat(id: item.beatId) else { continue }
            await purchase(beat, tier: item.tier, openLibrary: false)
        }
        selectedTab = .library
    }

    func openStudio() {
        selectedTab = .menu
    }

    func openBeats() {
        selectedTab = .beats
    }

    func openVideoFeed() {
        selectedTab = .video
    }

    func openSearch() {
        selectedTab = .beats
        isBeatSearchPresented = true
    }

    func openBeatFromSearch(_ beatId: String) {
        pendingBeatDetailId = beatId
        isBeatSearchPresented = false
        selectedTab = .beats
    }

    private func persistCart() {
        Self.save(cart, key: cartKey)
    }

    private func persistLicenses() {
        Self.save(licenses, key: licensesKey)
    }

    private static func load<T: Decodable>(_ key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

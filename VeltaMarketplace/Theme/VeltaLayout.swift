import SwiftUI

private struct VeltaWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 390
}

extension EnvironmentValues {
    var veltaWidth: CGFloat {
        get { self[VeltaWidthKey.self] }
        set { self[VeltaWidthKey.self] = newValue }
    }
}

enum VeltaLayout {
    static func gutter(for width: CGFloat) -> CGFloat {
        width >= 700 ? 28 : 16
    }

    static func heroSize(for width: CGFloat) -> CGFloat {
        min(36, max(24, width * 0.072))
    }

    static func listenCardWidth(for width: CGFloat) -> CGFloat {
        width >= 700 ? 176 : 148
    }

    static func videoCardWidth(for width: CGFloat) -> CGFloat {
        min(width * 0.78, 420)
    }

    static func contentWidth(for width: CGFloat) -> CGFloat {
        min(width, width >= 700 ? 760 : width)
    }

    static func isRegular(_ width: CGFloat) -> Bool {
        width >= 700
    }

    /// Floating Liquid Glass tab pill + home indicator clearance.
    static let liquidTabBarReserve: CGFloat = 74
    /// Legacy reserve used by For You overlays.
    static let tabBarContentHeight: CGFloat = liquidTabBarReserve
    static let miniPlayerHeight: CGFloat = 56
    /// Extra air between For You Buy and the tab icons.
    static let forYouOverlayBottom: CGFloat = 16

    static func forYouActionBottom(safeAreaBottom: CGFloat, tabBarHidden: Bool = false) -> CGFloat {
        if tabBarHidden {
            return max(safeAreaBottom, 16) + forYouOverlayBottom
        }
        return tabBarContentHeight + max(safeAreaBottom, 4) + forYouOverlayBottom
    }
}

extension View {
    func veltaReadable(_ width: CGFloat) -> some View {
        frame(maxWidth: VeltaLayout.contentWidth(for: width))
            .frame(maxWidth: .infinity)
    }
}

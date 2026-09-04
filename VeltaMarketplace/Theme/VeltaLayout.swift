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

    /// 8 top + 44 icons + 18 bottom (clears the home-indicator pill).
    static let tabBarContentHeight: CGFloat = 70
    static let miniPlayerHeight: CGFloat = 56
    /// Extra air between For You Buy and the tab icons.
    static let forYouOverlayBottom: CGFloat = 16

    static func forYouActionBottom(safeAreaBottom: CGFloat, tabBarHidden: Bool = false) -> CGFloat {
        if tabBarHidden {
            return max(safeAreaBottom, 12) + forYouOverlayBottom
        }
        let aboveBar = safeAreaBottom > 1 ? 0 : tabBarContentHeight
        return aboveBar + forYouOverlayBottom
    }
}

extension View {
    func veltaReadable(_ width: CGFloat) -> some View {
        frame(maxWidth: VeltaLayout.contentWidth(for: width))
            .frame(maxWidth: .infinity)
    }
}

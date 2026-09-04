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
}

extension View {
    func veltaReadable(_ width: CGFloat) -> some View {
        frame(maxWidth: VeltaLayout.contentWidth(for: width))
            .frame(maxWidth: .infinity)
    }
}

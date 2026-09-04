import SwiftUI
import UIKit

enum PhotosBlurStyle {
    /// Full header row behind For You / Beats.
    case header
    /// Thin strip under the status bar while scrolling.
    case statusBar
}

struct PhotosHeaderBlur: UIViewRepresentable {
    var radius: CGFloat = 20
    var style: PhotosBlurStyle = .header

    func makeUIView(context: Context) -> PhotosVariableBlurView {
        PhotosVariableBlurView(radius: radius, style: style)
    }

    func updateUIView(_ uiView: PhotosVariableBlurView, context: Context) {
        uiView.isUserInteractionEnabled = false
        uiView.update(radius: radius, style: style)
    }
}

final class PhotosVariableBlurView: UIVisualEffectView {
    private var blurRadius: CGFloat
    private var blurStyle: PhotosBlurStyle

    init(radius: CGFloat, style: PhotosBlurStyle) {
        blurRadius = radius
        blurStyle = style
        super.init(effect: UIBlurEffect(style: .regular))
        backgroundColor = .clear
        isUserInteractionEnabled = false
        applyVariableBlur()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func update(radius: CGFloat, style: PhotosBlurStyle) {
        blurRadius = radius
        blurStyle = style
        applyVariableBlur()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window, let backdrop = subviews.first?.layer else { return }
        backdrop.setValue(window.screen.scale, forKey: "scale")
    }

    private func applyVariableBlur() {
        guard let filterClass = NSClassFromString("CAFilter") as AnyObject as? NSObjectProtocol else {
            return
        }
        let selector = NSSelectorFromString("filterWithType:")
        guard filterClass.responds(to: selector),
              let filter = filterClass.perform(selector, with: "variableBlur")?.takeUnretainedValue() as? NSObject,
              let mask = Self.makeMaskImage(for: blurStyle)
        else { return }

        filter.setValue(blurRadius, forKey: "inputRadius")
        filter.setValue(mask, forKey: "inputMaskImage")
        filter.setValue(true, forKey: "inputNormalizeEdges")

        subviews.first?.layer.filters = [filter]
        for overlay in subviews.dropFirst() {
            overlay.alpha = 0
        }
    }

    private static func makeMaskImage(for style: PhotosBlurStyle) -> CGImage? {
        let size = CGSize(width: 100, height: 100)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false

        let colors: [CGColor]
        let locations: [CGFloat]

        switch style {
        case .header:
            colors = [
                UIColor.black.cgColor,
                UIColor.black.withAlphaComponent(0.7).cgColor,
                UIColor.black.withAlphaComponent(0.12).cgColor,
                UIColor.clear.cgColor,
            ]
            locations = [0, 0.42, 0.72, 1]
        case .statusBar:
            colors = [
                UIColor.black.cgColor,
                UIColor.black.withAlphaComponent(0.82).cgColor,
                UIColor.black.withAlphaComponent(0.35).cgColor,
                UIColor.clear.cgColor,
            ]
            locations = [0, 0.35, 0.62, 1]
        }

        return UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            ) else { return }
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
        }.cgImage
    }
}

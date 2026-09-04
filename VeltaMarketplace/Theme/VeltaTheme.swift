import SwiftUI

enum VeltaTheme {
    static let ink = Color.black
    static let inkElevated = Color(red: 18 / 255, green: 18 / 255, blue: 18 / 255)
    static let inkLine = Color.white.opacity(0.08)
    static let paper = Color.white
    static let paperMuted = Color.white.opacity(0.55)
    static let paperFaint = Color.white.opacity(0.28)
    static let accent = Color(red: 37 / 255, green: 99 / 255, blue: 235 / 255)
    static let accentSoft = Color(red: 37 / 255, green: 99 / 255, blue: 235 / 255).opacity(0.18)
    static let sky = Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255)
    static let boost = Color(red: 168 / 255, green: 85 / 255, blue: 247 / 255)
    static let price = Color(red: 125 / 255, green: 211 / 255, blue: 252 / 255)
    static let free = Color(red: 249 / 255, green: 115 / 255, blue: 22 / 255)

    static let display: Font = .system(.largeTitle, design: .default).weight(.bold)
    static let title: Font = .system(.title2, design: .default).weight(.semibold)
    static let body: Font = .system(.body, design: .default)
    static let meta: Font = .system(.caption, design: .default).weight(.medium)

    static func coverColors(for token: String) -> [Color] {
        if token.contains("amber") || token.contains("orange") {
            return [
                Color(red: 0.47, green: 0.27, blue: 0.08),
                Color(red: 0.27, green: 0.10, blue: 0.04),
                .black,
            ]
        }
        if token.contains("indigo") || token.contains("violet") {
            return [
                Color(red: 0.19, green: 0.15, blue: 0.45),
                Color(red: 0.18, green: 0.08, blue: 0.32),
                .black,
            ]
        }
        if token.contains("slate") {
            return [
                Color(red: 0.28, green: 0.33, blue: 0.41),
                Color(red: 0.09, green: 0.11, blue: 0.16),
                .black,
            ]
        }
        return [
            Color(red: 0.05, green: 0.22, blue: 0.45),
            Color(red: 0.07, green: 0.14, blue: 0.32),
            .black,
        ]
    }
}

struct VeltaMark: View {
    var size: CGFloat = 28
    var filled = true

    var body: some View {
        Image("VeltaLogo")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .padding(size * 0.18)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background {
                if filled {
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .fill(VeltaTheme.accent)
                }
            }
            .accessibilityLabel("Velta")
    }
}

struct VeltaWordmark: View {
    var markSize: CGFloat = 28
    var showsName: Bool = true

    var body: some View {
        HStack(spacing: 8) {
            VeltaMark(size: markSize)
            if showsName {
                Text("Velta")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Velta")
    }
}

struct VeltaScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(VeltaTheme.ink.ignoresSafeArea())
    }
}

extension View {
    func veltaScreen() -> some View {
        modifier(VeltaScreenBackground())
    }
}

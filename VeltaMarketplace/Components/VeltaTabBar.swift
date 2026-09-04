import SwiftUI

struct VeltaTabBar: View {
    @Binding var selection: AppTab
    var cartCount: Int

    var body: some View {
        HStack {
            tabButton(.explore, icon: "house.fill")
            tabButton(.search, icon: "magnifyingglass")
            tabButton(.cart, icon: "bag", badge: cartCount)
            tabButton(.library, icon: "heart")
            tabButton(.menu, icon: "line.3.horizontal")
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 18)
        .background(VeltaTheme.ink.opacity(0.96))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(VeltaTheme.inkLine)
                .frame(height: 0.5)
        }
    }

    private func tabButton(_ tab: AppTab, icon: String, badge: Int = 0) -> some View {
        Button {
            selection = tab
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(selection == tab ? .white : .white.opacity(0.32))
                    .frame(width: 44, height: 44)

                if badge > 0 {
                    Text(badge > 9 ? "9+" : "\(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(VeltaTheme.accent, in: Capsule())
                        .offset(x: 6, y: -4)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label(for: tab))
    }

    private func label(for tab: AppTab) -> String {
        switch tab {
        case .explore: "Home"
        case .search: "Search"
        case .cart: "Bag"
        case .library: "Library"
        case .menu: "Menu"
        }
    }
}

struct ExploreHeader: View {
    var title: String
    var showsBell: Bool = true
    @Environment(\.veltaWidth) private var width

    var body: some View {
        HStack {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer(minLength: 8)
            if showsBell {
                Image(systemName: "bell")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, VeltaLayout.gutter(for: width))
        .padding(.vertical, 10)
    }
}

struct VeltaSearchField: View {
    @Binding var query: String
    var placeholder: String = "What are you looking for?"
    var onSubmit: (() -> Void)?
    @Environment(\.veltaWidth) private var width

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.45))
            TextField(placeholder, text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(.white)
                .onSubmit { onSubmit?() }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color.white.opacity(0.08), in: Capsule())
        .padding(.horizontal, VeltaLayout.gutter(for: width))
    }
}

struct SectionHeader: View {
    var title: String
    var action: String = "Browse"
    var onAction: () -> Void
    @Environment(\.veltaWidth) private var width

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Spacer(minLength: 8)
            Button(action: onAction) {
                Text(action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VeltaTheme.sky)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, VeltaLayout.gutter(for: width))
    }
}

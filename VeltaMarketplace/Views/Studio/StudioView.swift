import SwiftUI

struct StudioView: View {
    @Environment(AppState.self) private var app
    @Environment(\.veltaWidth) private var width
    @State private var statsPeriod = "This Week"
    @State private var searchQuery = ""

    private var gutter: CGFloat { VeltaLayout.gutter(for: width) }
    private var weeklyPlays: [StudioDayStat] { Self.mockWeeklyPlays(from: app.catalog.beats) }
    private var weeklyTotal: Int { weeklyPlays.reduce(0) { $0 + $1.plays } }
    private var totalPlays: Int { app.catalog.beats.reduce(0) { $0 + $1.plays } }
    private var filteredBeats: [Beat] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return app.catalog.beats }
        return app.catalog.beats.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || $0.genres.joined().localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                studioHero

                VStack(alignment: .leading, spacing: 22) {
                    searchRow
                    quickStatsSection
                    actionButtonsRow
                    recentSalesSection
                    catalogSection
                }
                .padding(.horizontal, gutter)
                .padding(.top, 18)
                .padding(.bottom, 120)
            }
        }
        .background(VeltaTheme.ink)
        .navigationTitle("Studio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var studioHero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.42, blue: 0.72),
                    Color(red: 0.04, green: 0.18, blue: 0.42),
                    VeltaTheme.ink,
                ],
                startPoint: .topLeading,
                endPoint: .bottom
            )
            .frame(height: 148)
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .blur(radius: 2)
                    .offset(x: 24, y: -20)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(app.auth.user?.name ?? "Velta Beats")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text("Producer dashboard")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }
            .padding(.horizontal, gutter)
            .padding(.bottom, 18)
        }
    }

    private var searchRow: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.45))
                TextField("Search my content", text: $searchQuery)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Color.white.opacity(0.08), in: Capsule())

            studioIconButton("bell")
            studioIconButton("ellipsis.bubble")
        }
    }

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick stats")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Menu {
                    Button("This Week") { statsPeriod = "This Week" }
                    Button("This Month") { statsPeriod = "This Month" }
                    Button("All Time") { statsPeriod = "All Time" }
                } label: {
                    HStack(spacing: 4) {
                        Text(statsPeriod)
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.white.opacity(0.72))
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Plays \(statsPeriod.lowercased())")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.55))
                        Text("\(displayTotal)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Revenue")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                        Text("$\(mockRevenue, specifier: "%.0f")")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(VeltaTheme.price)
                    }
                }

                StudioPlaysChart(data: chartData)
                    .frame(height: 148)

                HStack(spacing: 10) {
                    miniStat("Beats", value: "\(app.catalog.beats.count)")
                    miniStat("Sold", value: "\(app.licenses.count)")
                    miniStat("All plays", value: compact(totalPlays))
                }
            }
            .padding(16)
            .background(studioCardBackground)
        }
    }

    private var actionButtonsRow: some View {
        HStack(spacing: 10) {
            studioOutlineButton("View all stats", systemImage: "chart.xyaxis.line")
            studioOutlineButton("View all sales", systemImage: "dollarsign.circle")
        }
    }

    private var recentSalesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent activity")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                activityRow(
                    title: "MP3 lease sold",
                    detail: app.catalog.beats.first?.title ?? "Beat",
                    amount: "$29.99"
                )
                Divider().overlay(VeltaTheme.inkLine)
                activityRow(
                    title: "WAV lease sold",
                    detail: app.catalog.beats.dropFirst().first?.title ?? "Beat",
                    amount: "$49.99"
                )
            }
            .background(studioCardBackground)
        }
    }

    private var catalogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your catalog")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(filteredBeats.count) live")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.45))
            }

            VStack(spacing: 10) {
                ForEach(filteredBeats.prefix(6)) { beat in
                    NavigationLink(value: AppRoute.beat(beat.id)) {
                        catalogRow(beat)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func catalogRow(_ beat: Beat) -> some View {
        HStack(spacing: 12) {
            BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(beat.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(compact(beat.plays)) plays · $\(beat.lowestPrice, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer(minLength: 8)

            Text("Live")
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(VeltaTheme.accentSoft, in: Capsule())
                .foregroundStyle(VeltaTheme.sky)
        }
        .padding(12)
        .background(studioCardBackground)
    }

    private func activityRow(title: String, detail: String, amount: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "bag.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(VeltaTheme.accent)
                .frame(width: 36, height: 36)
                .background(VeltaTheme.accentSoft, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(1)
            }

            Spacer()

            Text(amount)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(VeltaTheme.price)
        }
        .padding(14)
    }

    private func miniStat(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func studioIconButton(_ systemImage: String) -> some View {
        Button {} label: {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(Color.white.opacity(0.08), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func studioOutlineButton(_ title: String, systemImage: String) -> some View {
        Button {} label: {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12))
                    .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            )
        }
        .buttonStyle(.plain)
    }

    private var studioCardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.06))
            )
    }

    private var displayTotal: Int {
        switch statsPeriod {
        case "This Month": return Int(Double(weeklyTotal) * 4.2)
        case "All Time": return totalPlays
        default: return weeklyTotal
        }
    }

    private var chartData: [StudioDayStat] {
        switch statsPeriod {
        case "This Month":
            return weeklyPlays.map { StudioDayStat(label: $0.label, plays: $0.plays * 4) }
        case "All Time":
            return weeklyPlays.map { StudioDayStat(label: $0.label, plays: max($0.plays * 18, 1)) }
        default:
            return weeklyPlays
        }
    }

    private var mockRevenue: Double {
        Double(app.licenses.count) * 39.99 + Double(app.catalog.beats.count) * 12.5
    }

    private func compact(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1fk", Double(value) / 1000)
        }
        return "\(value)"
    }

    private static func mockWeeklyPlays(from beats: [Beat]) -> [StudioDayStat] {
        let base = max(beats.reduce(0) { $0 + $1.plays } / 480, 8)
        return [
            StudioDayStat(label: "Mon", plays: base + 4),
            StudioDayStat(label: "Tue", plays: base + 11),
            StudioDayStat(label: "Wed", plays: base + 7),
            StudioDayStat(label: "Thu", plays: base * 4 + 18),
            StudioDayStat(label: "Fri", plays: base + 16),
        ]
    }
}

private struct StudioDayStat: Identifiable {
    let id = UUID()
    let label: String
    let plays: Int
}

private struct StudioPlaysChart: View {
    let data: [StudioDayStat]

    var body: some View {
        GeometryReader { geo in
            let maxValue = max(data.map(\.plays).max() ?? 1, 1)
            let stepX = geo.size.width / CGFloat(max(data.count - 1, 1))

            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { index in
                        Spacer(minLength: 0)
                        if index < 3 {
                            Rectangle()
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 1)
                        }
                    }
                }

                Path { path in
                    guard let first = data.first else { return }
                    let points = data.enumerated().map { index, item in
                        CGPoint(
                            x: CGFloat(index) * stepX,
                            y: geo.size.height - (CGFloat(item.plays) / CGFloat(maxValue) * (geo.size.height - 16))
                        )
                    }
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(VeltaTheme.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                Path { path in
                    guard let first = data.first else { return }
                    let points = data.enumerated().map { index, item in
                        CGPoint(
                            x: CGFloat(index) * stepX,
                            y: geo.size.height - (CGFloat(item.plays) / CGFloat(maxValue) * (geo.size.height - 16))
                        )
                    }
                    path.move(to: CGPoint(x: points[0].x, y: geo.size.height))
                    path.addLine(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                    path.addLine(to: CGPoint(x: points.last?.x ?? 0, y: geo.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [VeltaTheme.accent.opacity(0.28), VeltaTheme.accent.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    Circle()
                        .fill(.white)
                        .frame(width: 7, height: 7)
                        .position(
                            x: CGFloat(index) * stepX,
                            y: geo.size.height - (CGFloat(item.plays) / CGFloat(maxValue) * (geo.size.height - 16))
                        )
                }
            }
            .overlay(alignment: .bottom) {
                HStack {
                    ForEach(data) { item in
                        Text(item.label)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.45))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

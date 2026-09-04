import SwiftUI

struct StudioView: View {
    @Environment(AppState.self) private var app
    @State private var draftTitle = ""
    @State private var savedDraft = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Producer Studio")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text("Upload, license, and track beats without leaving Velta.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))

                HStack(spacing: 10) {
                    metric("Beats", value: "\(app.catalog.beats.count)")
                    metric("Plays", value: compact(app.catalog.beats.reduce(0) { $0 + $1.plays }))
                    metric("Sold", value: "\(app.licenses.count)")
                }

                pipeline

                VStack(alignment: .leading, spacing: 10) {
                    Text("New upload")
                        .font(.headline)
                    TextField("Beat title", text: $draftTitle)
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Button {
                        savedDraft = true
                        draftTitle = ""
                    } label: {
                        Text(savedDraft ? "Draft saved" : "Save draft in app")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(VeltaTheme.accent, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .disabled(draftTitle.trimmingCharacters(in: .whitespaces).isEmpty && !savedDraft)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Your catalog")
                        .font(.headline)
                    ForEach(app.catalog.beats.prefix(6)) { beat in
                        NavigationLink(value: AppRoute.beat(beat.id)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(beat.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                    Text("\(beat.plays) plays · $\(beat.lowestPrice, specifier: "%.0f")")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.45))
                                }
                                Spacer()
                                Text("Live")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(VeltaTheme.accentSoft, in: Capsule())
                                    .foregroundStyle(VeltaTheme.sky)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 28)
        }
        .veltaScreen()
        .navigationTitle("Studio")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pipeline: some View {
        HStack(spacing: 0) {
            ForEach(["Upload", "Licenses", "Live"], id: \.self) { step in
                VStack(spacing: 8) {
                    Circle()
                        .fill(VeltaTheme.accent)
                        .frame(width: 10, height: 10)
                    Text(step)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                if step != "Live" {
                    Rectangle()
                        .fill(VeltaTheme.accent.opacity(0.4))
                        .frame(height: 1)
                        .padding(.bottom, 18)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }

    private func metric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
            Text(value)
                .font(.title3.weight(.bold))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }

    private func compact(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1fk", Double(value) / 1000)
        }
        return "\(value)"
    }
}

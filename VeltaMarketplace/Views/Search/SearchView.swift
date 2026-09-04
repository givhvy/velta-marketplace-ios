import SwiftUI

struct SearchView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @Environment(\.veltaWidth) private var width
    @FocusState private var isFieldFocused: Bool
    @State private var query = ""

    var body: some View {
        let results = app.catalog.search(query)
        let gutter = VeltaLayout.gutter(for: width)

        VStack(spacing: 0) {
            HStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white.opacity(0.45))
                    TextField("What are you looking for?", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundStyle(.white)
                        .focused($isFieldFocused)
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color.white.opacity(0.08), in: Capsule())

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, gutter)
            .padding(.top, 10)
            .padding(.bottom, 12)

            if results.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.35))
                    Text(query.isEmpty ? "Search beats" : "No beats found")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(results) { beat in
                            Button {
                                app.openBeatFromSearch(beat.id)
                            } label: {
                                HStack(spacing: 10) {
                                    BeatCoverView(beat: beat, webBase: app.catalog.webBase)
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(beat.genreLine.uppercased())
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(VeltaTheme.boost)
                                            .lineLimit(1)
                                        Text(beat.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                        Text(beat.sellerName)
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.45))
                                            .lineLimit(1)
                                    }

                                    Spacer(minLength: 8)

                                    Text("$\(beat.lowestPrice, specifier: "%.0f")")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(VeltaTheme.price)
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.white.opacity(0.04))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, gutter)
                    .padding(.bottom, 12)
                }
            }
        }
        .background(VeltaTheme.ink)
        .onAppear { isFieldFocused = true }
    }
}

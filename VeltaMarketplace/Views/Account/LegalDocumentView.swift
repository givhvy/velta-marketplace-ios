import SwiftUI

struct LegalDocumentView: View {
    let document: LegalDocument

    var body: some View {
        ScrollView {
            Text(document.body)
                .font(.body)
                .foregroundStyle(.white.opacity(0.78))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .padding(.bottom, 28)
        }
        .veltaScreen()
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

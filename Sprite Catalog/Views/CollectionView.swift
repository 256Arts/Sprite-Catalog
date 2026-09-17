import SwiftUI

struct CollectionView: View {
    
    @State var collection: SpriteCollection
    @State var webpageURL: URL?
    @State private var selection = SpriteSelection()
    @State private var exporting: [SpriteSet] = []
    
    var body: some View {
        ScrollView {
            if let url = webpageURL {
                HStack {
                    Link(destination: url) {
                        Label(url.label, systemImage: "globe")
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 64))]) {
                ForEach(collection.sprites) { sprite in
                    SpriteGridCell(sprite: sprite, selection: selection) { exporting = $0 }
                }
            }
            .padding()
        }
        .background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
        .navigationTitle(collection.title)
        .navigationTitleDisplayMode(.large)
        .spriteSelectionToolbar(selection, displaying: collection.sprites, exporting: $exporting)
    }
}

#Preview {
    CollectionView(collection: SpriteCollection(title: "", spriteIDs: []), webpageURL: nil)
}

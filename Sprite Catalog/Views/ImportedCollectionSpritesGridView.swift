import SwiftUI

struct ImportedCollectionSpritesGridView: View {

    @Bindable var userCollection: SpriteCollection

    @State var showingImport = false

    var body: some View {
        SpritesGridView(title: userCollection.title, sprites: userCollection.sprites)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Import", systemImage: "plus") {
                        showingImport = true
                    }
                }
            }
            .sheet(isPresented: $showingImport) {
                ImportSpritesView(importer: .init(debugMode: false))
            }
    }
}

#Preview {
    ImportedCollectionSpritesGridView(userCollection: .myCollection)
}

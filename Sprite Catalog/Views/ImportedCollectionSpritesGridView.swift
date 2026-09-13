import SwiftUI

struct ImportedCollectionSpritesGridView: View {

    /// The window's import sheet, so this toolbar button and the Import Sprites menu item open the
    /// same one. Optional because a preview has no window around it.
    @Environment(MainWindowState.self) private var window: MainWindowState?

    @Bindable var userCollection: SpriteCollection

    var body: some View {
        SpritesGridView(title: userCollection.title, sprites: userCollection.sprites)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Import", systemImage: "plus") {
                        window?.showingImport = true
                    }
                }
            }
    }
}

#Preview {
    ImportedCollectionSpritesGridView(userCollection: .myCollection)
}

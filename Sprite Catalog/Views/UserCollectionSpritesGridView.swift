import SwiftUI

struct UserCollectionSpritesGridView: View {
    
    @Bindable var userCollection: SpriteCollection

    @State var showingHelp = false
    
    var body: some View {
        SpritesGridView(title: userCollection.title, sprites: userCollection.sprites)
            .toolbar {
                if userCollection.title == SpriteCollection.stickersCollection.title {
                    Button("Help", systemImage: "questionmark.circle") {
                        showingHelp = true
                    }
                }
            }
            .sheet(isPresented: $showingHelp) {
                NavigationStack {
                    StickersHelpView()
                }
            }
    }
}

#Preview {
    UserCollectionSpritesGridView(userCollection: .myCollection)
}

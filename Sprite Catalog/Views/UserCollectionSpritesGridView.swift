//
//  UserCollectionSpritesGridView.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-06-27.
//

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

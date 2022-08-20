//
//  UserCollectionSpritesGridView.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-06-27.
//

import SwiftUI

struct UserCollectionSpritesGridView: View {
    
    @ObservedObject var userCollection: SpriteCollection

    @State var showingImport = false
    
    var body: some View {
        SpritesGridView(title: userCollection.title, sprites: userCollection.sprites)
    }
}

struct UserCollectionSpritesGridView_Previews: PreviewProvider {
    static var previews: some View {
        UserCollectionSpritesGridView(userCollection: .myCollection)
    }
}

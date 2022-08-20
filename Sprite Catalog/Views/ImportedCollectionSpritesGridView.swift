//
//  ImportedCollectionSpritesGridView.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2022-04-26.
//

import SwiftUI

struct ImportedCollectionSpritesGridView: View {

    @ObservedObject var userCollection: SpriteCollection

    @State var showingImport = false

    var body: some View {
        SpritesGridView(title: userCollection.title, sprites: userCollection.sprites)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingImport = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .symbolVariant(.fill)
                    }
                }
            }
            .sheet(isPresented: $showingImport) {
                ImportSpritesView(importer: .init(debugMode: false))
            }
    }
}

struct ImportedCollectionSpritesGridView_Previews: PreviewProvider {
    static var previews: some View {
        ImportedCollectionSpritesGridView(userCollection: .myCollection)
    }
}

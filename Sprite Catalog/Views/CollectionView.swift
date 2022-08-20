//
//  ArtistView.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-04-03.
//

import SwiftUI

struct CollectionView: View {
    
    @State var collection: SpriteCollection
    @State var webpageURL: URL?
    
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
                    NavigationLink(destination: SpriteDetailView(sprite: sprite)) {
                        TileThumbnail(tile: sprite.tiles.first!)
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(collection.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ArtistView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView(collection: SpriteCollection(title: "", spriteIDs: []), webpageURL: nil)
    }
}

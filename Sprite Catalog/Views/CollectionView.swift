//
//  ArtistView.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-04-03.
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
                    NavigationLink(value: sprite.id) {
                        TileThumbnail(tile: sprite.tiles.first!)
                    }
                    #if os(visionOS)
                    .buttonBorderShape(.roundedRectangle)
                    #elseif targetEnvironment(macCatalyst)
                    .buttonStyle(.plain)
                    #endif
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(collection.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    CollectionView(collection: SpriteCollection(title: "", spriteIDs: []), webpageURL: nil)
}

//
//  SpriteLink.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-03-25.
//

import SwiftUI

/// Normal thumbnail for use in the grid
struct TileThumbnail: View {
    
    @State var tile: SpriteSet.Tile
    
    var body: some View {
        #if os(visionOS)
        Image(uiImage: tile.variants[0].frameImage())
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .padding(6)
            .frame(minWidth: 64, idealWidth: 64, minHeight: 64, idealHeight: 64)
            .draggable(tile.variants[0])
        #else
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
            .aspectRatio(1, contentMode: .fit)
            .frame(minWidth: 64, idealWidth: 64, minHeight: 64, idealHeight: 64)
            .overlay {
                Image(uiImage: tile.variants[0].frameImage())
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .padding(6)
            }
            .draggable(tile.variants[0])
        #endif
    }
}

/// Thumbnail with no border or background
struct PlainTileThumbnail: View {
    
    @State var tile: SpriteSet.Tile
    
    var body: some View {
        Image(uiImage: tile.variants[0].frameImage())
            .resizable()
            .interpolation(.none)
            .aspectRatio(contentMode: .fit)
            .draggable(tile.variants.first!)
    }
}

/// Larger thumbnail
struct ArtworkTileThumbnail: View {
    
    @State var tile: SpriteSet.Tile
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .background(
                Image(uiImage: tile.variants[0].frameImage())
                    .resizable()
                    .interpolation(.none)
                    .scaledToFill()
            )
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(16)
            .draggable(tile.variants[0])
    }
}

#Preview {
    TileThumbnail(tile: .init(variants: [.init(imageName: "")]))
}

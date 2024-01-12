//
//  DebugPromoGridView.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-07-06.
//

#if DEBUG
import SwiftUI

struct DebugPromoGridView: View {
    
    @State var size = 10
    @State var allSprites = SpriteSet.allSprites.filter({ !$0.tags.contains(.effect) }).shuffled()
    var sprites: [[SpriteSet]] {
        var sprites: [[SpriteSet]] = []
        for x in 0..<size {
            sprites.append(Array(allSprites[(x*size)..<(x*size + size)]))
        }
        return sprites
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Stepper("Size", value: $size)
                    Button {
                        allSprites.shuffle()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                Spacer()
                VStack {
                    ForEach(sprites, id: \.first!.id) { row in
                        HStack {
                            ForEach(row) { sprite in
                                PlainTileThumbnail(tile: sprite.tiles[0])
                                    .frame(width: 48, height: 48)
                            }
                        }
                    }
                }
                .background(Color.green)
                Spacer()
            }
            .padding()
            .navigationTitle("Create Promo Grid")
        }
    }
}

#Preview {
    DebugPromoGridView()
}
#endif

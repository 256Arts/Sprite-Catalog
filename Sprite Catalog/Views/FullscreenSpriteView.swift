//
//  FullscreenSprite.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-07-11.
//

import SwiftUI

struct FullscreenSpriteView: View {
    
    let timer = Timer.publish(every: 0.3, on: .main, in: .default).autoconnect()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var sprite: SpriteSet
    @State var frame: Int = 0
    
    var body: some View {
        TabView {
            ForEach(sprite.states) { tile in
                Image(uiImage: tile.variants.first!.frameImages()[frame])
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .onDrag {
                        NSItemProvider(object: UIImage(named: tile.variants.first!.imageName)!)
                    }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        #if !targetEnvironment(macCatalyst)
        .overlay(alignment: .topLeading) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding()
            }
        }
        #endif
        .onReceive(timer) { (_) in
            guard let frameCount = sprite.states[0].variants.first?.frameCount, 1 < frameCount else { return }
            if frame + 1 == frameCount {
                frame = 0
            } else {
                frame += 1
            }
        }
    }
}

struct FullscreenSprite_Previews: PreviewProvider {
    static var previews: some View {
        FullscreenSpriteView(sprite: SpriteSet(id: "xxxxxx", name: "Title", artist: Artist(name: "Jayden"), licence: .cc0, layer: .object, tags: [], tiles: [.init(variants: [.init(imageName: "")])]))
    }
}

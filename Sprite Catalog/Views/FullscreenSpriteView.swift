import SwiftUI

struct FullscreenSpriteView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var sprite: SpriteSet
    
    var body: some View {
        states
        #if !os(macOS)
        .overlay(alignment: .topLeading) {
            Button("Close", systemImage: "xmark") {
                dismiss()
            }
        }
        #endif
        .scenePadding()
    }
    
    /// The sprite's states, one screenful at a time. macOS has no paged `TabView`, so it pages a
    /// scroll view instead.
    @ViewBuilder
    private var states: some View {
        #if os(macOS)
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(sprite.states) { tile in
                    stateImage(tile)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        #else
        TabView {
            ForEach(sprite.states) { tile in
                stateImage(tile)
            }
        }
        .tabViewStyle(.page)
        #endif
    }
    
    private func stateImage(_ tile: SpriteSet.Tile) -> some View {
        AnimatedSpriteImage(variant: tile.variants[0])
            .aspectRatio(contentMode: .fit)
            .draggable(sprite.transfer(of: tile))
    }
}

#Preview {
    FullscreenSpriteView(sprite: SpriteSet(id: "xxxxxx", name: "Title", artist: Artist(name: "Jayden"), licence: .cc0, layer: .object, tags: [], tiles: [.init(variants: [.init(imageName: "")])]))
}

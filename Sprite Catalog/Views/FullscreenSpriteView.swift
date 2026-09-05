import SwiftUI

struct FullscreenSpriteView: View {
    
    let timer = Timer.publish(every: 0.3, on: .main, in: .default).autoconnect()
    
    @Environment(\.dismiss) var dismiss
    
    @State var sprite: SpriteSet
    @State var frame: Int = 0
    
    var body: some View {
        states
        #if !os(macOS) && !targetEnvironment(macCatalyst)
        .overlay(alignment: .topLeading) {
            Button("Close", systemImage: "xmark") {
                dismiss()
            }
        }
        #endif
        .scenePadding()
        .onReceive(timer) { (_) in
            guard let frameCount = sprite.states[0].variants.first?.frameCount, 1 < frameCount else { return }
            if frame + 1 == frameCount {
                frame = 0
            } else {
                frame += 1
            }
        }
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
        Image(sprite: tile.variants[0].frameImages()[frame])
            .resizable()
            .interpolation(.none)
            .aspectRatio(contentMode: .fit)
            .onDrag {
                NSItemProvider(object: PlatformImage.sprite(tile.variants[0].cgImage))
            }
    }
}

#Preview {
    FullscreenSpriteView(sprite: SpriteSet(id: "xxxxxx", name: "Title", artist: Artist(name: "Jayden"), licence: .cc0, layer: .object, tags: [], tiles: [.init(variants: [.init(imageName: "")])]))
}

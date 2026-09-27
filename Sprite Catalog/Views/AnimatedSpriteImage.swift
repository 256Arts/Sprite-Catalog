import SwiftUI

/// A variant's pixels, resizable and crisp, cycling through its frames when it is animated.
///
/// The frame comes from the timeline's date rather than a counter, so every animated sprite on
/// screen shares one clock, a state switch never indexes past a shorter strip, and the timeline
/// stops ticking while the view is off screen.
struct AnimatedSpriteImage: View {

    static let frameDuration: TimeInterval = 0.3

    let variant: SpriteSet.Tile.RandomVariant

    var body: some View {
        let frames = variant.frameImages()
        if frames.count > 1 {
            TimelineView(.periodic(from: .distantPast, by: Self.frameDuration)) { context in
                let tick = Int(context.date.timeIntervalSinceReferenceDate / Self.frameDuration)
                image(frames[tick % frames.count])
            }
        } else {
            image(frames.first ?? .blank)
        }
    }

    private func image(_ frame: CGImage) -> some View {
        Image(sprite: frame)
            .resizable()
            .interpolation(.none)
    }
}

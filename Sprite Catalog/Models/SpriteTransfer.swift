import CoreTransferable
import UniformTypeIdentifiers

/// A sprite on its way out of the app.
///
/// Sprites are compiled into the asset catalog, so there is no file to hand over and no useful name
/// on one either — the catalog files every sprite under a six-character ID. This encodes the pixels
/// on demand instead, at their native size with no resampling, and names the result after the
/// sprite. Dropping one in the Finder therefore writes `Genie.png`, not `0zbdd3.png`.
struct SpriteTransfer: Transferable {

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { transfer in
            try transfer.variant.cgImage.hueRotated(angle: transfer.hueRotationDegrees).pngData()
        }
        .suggestedFileName { "\($0.name).png" }
    }

    let variant: SpriteSet.Tile.RandomVariant
    let name: String
    /// Carries Quick Recolor into the drag, so what leaves the app is what is on screen.
    var hueRotationDegrees: Double = 0

}

extension SpriteSet {

    /// The sprite as a draggable PNG: its first tile, the one every grid shows.
    var transfer: SpriteTransfer {
        SpriteTransfer(variant: tiles[0].variants[0], name: name)
    }

    /// One of the sprite's other tiles — a state or a direction — as a draggable PNG.
    func transfer(of tile: Tile, hueRotationDegrees: Double = 0) -> SpriteTransfer {
        SpriteTransfer(variant: tile.variants[0], name: name, hueRotationDegrees: hueRotationDegrees)
    }

}

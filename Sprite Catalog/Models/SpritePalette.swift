import CoreGraphics
import PaletteKit

extension SpriteSet {

    /// The most colors a sprite can have and still read as a palette. Past this it is artwork —
    /// shaded or dithered pixels — and its "palette" would be hundreds of near-duplicates.
    static let maxPaletteColors = 64

    /// Every distinct opaque color across all of the sprite's tiles, variants and frames, ordered
    /// grays first (dark to light), then by hue, then by lightness — so ramps sit together.
    /// `nil` when there are none, or more than ``maxPaletteColors``.
    func paletteColors() -> [PaletteColor]? {
        var unique = Set<SRGB8>()
        for variant in tiles.flatMap(\.variants) {
            guard variant.cgImage.collectOpaqueColors(into: &unique, limit: Self.maxPaletteColors) else { return nil }
        }
        guard !unique.isEmpty else { return nil }

        // Grays share bucket -1; everything else falls in a 15° hue band, so a ramp whose hue
        // drifts a little as it lightens stays in one run, ordered by lightness.
        func hueBucket(_ color: PaletteColor) -> Int {
            guard color.chromaFraction >= 0.02 else { return -1 }
            let degrees = color.hueAngle.degrees.truncatingRemainder(dividingBy: 360)
            return Int((degrees < 0 ? degrees + 360 : degrees) / 15)
        }
        return unique
            .map { PaletteColor($0, colorSpace: .okLch) }
            .sorted { (hueBucket($0), $0.lightnessFraction) < (hueBucket($1), $1.lightnessFraction) }
    }

}

private extension CGImage {

    /// Adds each fully-opaque pixel's color to `colors`. Returns `false` once there are more than
    /// `limit`, or when the pixels can't be read.
    func collectOpaqueColors(into colors: inout Set<SRGB8>, limit: Int) -> Bool {
        // Redraw into a known sRGB RGBA8 buffer so any source pixel format reads uniformly.
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        guard let srgb = CGColorSpace(name: CGColorSpace.sRGB),
              let context = pixels.withUnsafeMutableBytes({ raw in
                  CGContext(data: raw.baseAddress, width: width, height: height, bitsPerComponent: 8,
                            bytesPerRow: width * 4, space: srgb,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
              }) else { return false }
        context.interpolationQuality = .none
        context.draw(self, in: CGRect(origin: .zero, size: pixelSize))

        for i in stride(from: 0, to: pixels.count, by: 4) where pixels[i + 3] == 255 {
            colors.insert(SRGB8(red: pixels[i], green: pixels[i + 1], blue: pixels[i + 2]))
            if colors.count > limit { return false }
        }
        return true
    }

}

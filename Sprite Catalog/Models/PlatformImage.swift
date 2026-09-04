import SwiftUI
import CoreImage.CIFilterBuiltins
import ImageIO
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
/// The platform's image type.
///
/// Sprite pixels travel as `CGImage`, which is identical on every platform; this alias exists only
/// for the few UIKit/AppKit boundaries that still demand a platform image (asset-catalog lookup,
/// `NSItemProvider`).
typealias PlatformImage = UIImage
#else
import AppKit
typealias PlatformImage = NSImage
#endif

enum ImageEditError: Error {
    case failedToApplyFilter
    case failedToEncodePNG
}

#if canImport(UIKit)
extension UIImage {
    /// Wraps sprite pixels in the platform image type, for the APIs that still require one.
    static func sprite(_ cgImage: CGImage) -> UIImage {
        UIImage(cgImage: cgImage)
    }
}
#else
extension NSImage {
    /// Matches `UIImage.cgImage`, so shared code can ask either platform's image for its pixels.
    var cgImage: CGImage? {
        cgImage(forProposedRect: nil, context: nil, hints: nil)
    }

    /// Wraps sprite pixels in the platform image type, sized in pixels so a Retina screen does not
    /// halve the sprite.
    static func sprite(_ cgImage: CGImage) -> NSImage {
        NSImage(cgImage: cgImage, size: cgImage.pixelSize)
    }
}
#endif

extension CGImage {

    /// A 1×1 transparent image: the stand-in for a sprite whose pixels are missing, so a stale
    /// catalog entry or a not-yet-downloaded iCloud file degrades to blank instead of crashing.
    static let blank: CGImage = {
        // Fixed, valid parameters — this cannot fail at runtime.
        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        return context.makeImage()!
    }()

    /// The image's dimensions in pixels.
    ///
    /// Sprite code sizes off this rather than a platform image's `size`, which is in points on
    /// macOS and would silently halve every measurement on a Retina display.
    var pixelSize: CGSize {
        CGSize(width: width, height: height)
    }

    /// Loads pixels from a file on disk.
    static func loading(contentsOf url: URL) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    /// Loads pixels from encoded image data.
    static func loading(data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    /// Looks up a bundled asset-catalog image — the one lookup that still needs a platform image.
    static func named(_ name: String) -> CGImage? {
        PlatformImage(named: name)?.cgImage
    }

    /// A hue-rotated copy, for the app's Quick Recolor.
    func hueRotated(angle degrees: Double) throws -> CGImage {
        guard !degrees.isZero else { return self }

        let filter = CIFilter.hueAdjust()
        filter.angle = Float(degrees * (.pi / 180.0))
        filter.inputImage = CIImage(cgImage: self)
        guard let outputImage = filter.outputImage,
              let rendered = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            throw ImageEditError.failedToApplyFilter
        }
        return rendered
    }

    /// PNG-encodes the pixels at their native size, with no rescaling.
    func pngData() throws -> Data {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            throw ImageEditError.failedToEncodePNG
        }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw ImageEditError.failedToEncodePNG
        }
        return data as Data
    }

}

extension Image {

    /// A sprite's pixels as a SwiftUI image, at 1× so one source pixel maps to one point before
    /// `.resizable()` scales it. Pair with `.interpolation(.none)` to keep the pixel grid crisp.
    init(sprite cgImage: CGImage) {
        self.init(decorative: cgImage, scale: 1)
    }

}

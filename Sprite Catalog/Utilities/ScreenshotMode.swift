import PaletteKit
import SwiftUI
#if targetEnvironment(macCatalyst)
import UIKit
#endif

/// Deterministic demo state for App Store screenshots, switched on by the `-screenshotMode` launch
/// argument the UI test passes.
///
/// The catalog itself ships in the bundle, so most screens are already full on a fresh install. What
/// is missing is the *personal* half of the app — My Collection, stickers, saved palettes, recent
/// activity — and what a repeat run is missing is determinism: Browse picks its artists at random
/// and swaps in a seasonal collection by month.
///
/// Everything here is seeded in memory only. Nothing is written to the documents directory, the
/// iCloud container, or the persistent defaults domain, so a run on the Mac — where the app shares a
/// container with the real library — neither shows nor disturbs the sprites and palettes actually
/// saved on that machine.
enum ScreenshotMode {

    /// Whether this launch is a screenshot run. Read by the `App`'s `init`, by `PaletteLibrary` to
    /// stay off disk, and by `CutterView` to arrive with a spritesheet already loaded.
    static let isActive = ProcessInfo.processInfo.arguments.contains("-screenshotMode")

    /// The collection to photograph: the curated favorites below, topped up from the catalog until
    /// the grid fills a 13" iPad. A library shown as two and a half rows in a tall window reads as
    /// empty, which is the opposite of the point.
    @MainActor
    private static var myCollectionIDs: Set<String> {
        var ids = curatedIDs
        for sprite in SpriteSet.allSprites where ids.count < 72 {
            guard sprite.tags.contains(where: { fillTags.contains($0) }) else { continue }
            ids.insert(sprite.id)
        }
        return ids
    }

    /// Categories worth filling with: things that read at thumbnail size.
    private static let fillTags: Set<SpriteSet.Tag> = [.peopleAnimal, .food, .treasure, .weaponTool]

    /// A varied, recognizable slice of the catalog: something from every category, so a grid of it
    /// reads as a library someone actually built rather than a run of near-identical tiles.
    private static let curatedIDs: Set<String> = [
        "mfagjz", "0zbdd3", "rguzq7", "ag3ay9", "j2xqtd", "axxyp3", "4jqgdk", "igp635",
        "5imunc", "6x8eev", "4lnb06", "ro4mup", "oc43ow",
        "hmr0d1", "591kg2", "e6h1vp", "f4b7gv", "di7r1x", "ckhln9",
        "p5hy8i", "yw83oy", "60by9c", "ga3ovi"
    ]

    /// Characters, which is what people actually send as stickers.
    private static let stickerIDs: Set<String> = [
        "0zbdd3", "rguzq7", "ag3ay9", "j2xqtd", "axxyp3", "470pzo", "653ens", "37lqb9",
        "gn6i29", "rf8xm0", "igp635", "mfagjz"
    ]

    /// Feeds Browse's "Based on Your Recent Activity" row, which needs more than three to appear.
    private static let suggestionIDs = ["5imunc", "ag3ay9", "p5hy8i", "hmr0d1", "j2xqtd", "6x8eev"]

    /// Artists to feature on Browse. Pinned because `BrowseView` otherwise shuffles.
    private static let featuredArtistNames = [
        "PiiiXL", "Kyrise", "Franuka", "ansimuz", "Caz Wolf", "Quintino Pixels"
    ]


    /// Seeds every screen the walk visits. Called from the `App`'s `init`, after the app registers
    /// its own defaults so the seeded suggestions win.
    @MainActor
    static func activate() {
        guard isActive else { return }

        SpriteCollection.myCollection = SpriteCollection(title: "My Collection", spriteIDs: myCollectionIDs)
        SpriteCollection.stickersCollection = SpriteCollection(title: "iMessage Stickers", spriteIDs: stickerIDs)

        // Featured leads with a seasonal collection during February, October, and December; drop
        // those so a shot taken in October matches one taken in March.
        let seasonal = [SpriteCollection.valentines, SpriteCollection.halloween, SpriteCollection.holiday]
        SpriteCollection.featured.removeAll { collection in seasonal.contains(collection) }

        BrowseView.featuredArtists = featuredArtistNames.map(Artist.init(name:))

        // The registration domain is in-memory and never written out, which is exactly what a
        // screenshot run wants: seeded activity that disappears with the process.
        UserDefaults.standard.register(defaults: [UserDefaults.Key.suggestions: suggestionIDs])

        // Every premade PaletteKit ships, as if the user had saved them: real palettes people
        // recognize, and enough rows that the list fills a tall window instead of trailing off.
        for var palette in Palette.premadePalettes(colorSpace: .okLch) {
            palette.source = .user
            PaletteLibrary.shared.add(palette)   // a no-op on disk while `isActive`
        }
    }

    /// Pins the window to a fixed size on the Mac.
    ///
    /// The runner clears the app's saved `NSWindow Frame` defaults before a Mac run, but `defaults`
    /// resolves a sandboxed app's domain to its container, and this app is sandboxed — so it finds
    /// nothing to clear and macOS restores whatever size the window was last dragged to. Requesting
    /// the geometry from inside the app is then the only deterministic option.
    @MainActor
    static func pinWindowLayout() {
        guard isActive else { return }
        #if targetEnvironment(macCatalyst)
        let frame = CGRect(x: 0, y: 0, width: 1440, height: 900)   // 16:10, the shot's own aspect
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            scene.requestGeometryUpdate(.Mac(systemFrame: frame))
        }
        #endif
    }

    /// A spritesheet for the cutter to arrive holding, so its screenshot shows the feature working
    /// instead of its "Drop spritesheet here" empty state. `nil` outside a screenshot run.
    ///
    /// Built by drawing catalog sprites into a grid rather than shipping a fixture image: the cutter
    /// is for sheets exactly like this, and the sprites are already in the bundle.
    static var demoSpritesheet: CGImage? {
        guard isActive else { return nil }

        let tile = 16
        let columns = 4
        // Distinct names, so the sheet reads as a character set rather than seven apples: the
        // catalog holds many same-named variations of the same subject next to each other.
        var names: Set<String> = []
        let sprites = SpriteSet.allSprites
            .filter { sprite in
                sprite.tags.contains(.peopleAnimal)
                && sprite.tiles[0].variants[0].frameImage().pixelSize == CGSize(width: tile, height: tile)
                && names.insert(sprite.name).inserted
            }
            .prefix(columns * columns)
        guard !sprites.isEmpty else { return nil }

        // Drawn in pixels, because the sheet is measured in pixels and the cutter cuts it in pixels.
        let rows = (sprites.count + columns - 1) / columns
        guard let context = CGContext(data: nil, width: columns * tile, height: rows * tile, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.interpolationQuality = .none

        for (index, sprite) in sprites.enumerated() {
            // A bitmap context's origin is bottom-left, so the grid's first row draws at the top.
            let origin = CGPoint(x: (index % columns) * tile, y: (rows - 1 - index / columns) * tile)
            context.draw(sprite.tiles[0].variants[0].frameImage(), in: CGRect(origin: origin, size: CGSize(width: tile, height: tile)))
        }
        return context.makeImage()
    }
}

extension View {

    /// Pins the sidebar width during a screenshot run, for the same reason as `pinWindowLayout()`:
    /// a dragged sidebar is user state the runner cannot reach, and it would otherwise decide how
    /// much of every Mac and iPad shot the sidebar takes up.
    @ViewBuilder
    func screenshotModeSidebarWidth() -> some View {
        if ScreenshotMode.isActive {
            navigationSplitViewColumnWidth(260)
        } else {
            self
        }
    }
}

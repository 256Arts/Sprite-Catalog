import SwiftUI

@main
struct Sprite_CatalogApp: App {
    
    /// The container the "Open in Sprite Pencil" handoff writes its PNG into.
    ///
    /// Resolved rather than hard-coded, because a native Mac app is normally given the team-prefixed
    /// form while iOS and Mac Catalyst use the bare one — and Sprite Pencil still ships on the Mac as
    /// a Catalyst app, so the bare container is the one both apps actually meet in. Both are declared
    /// in the macOS entitlements and the bare form is preferred; getting this wrong doesn't fail
    /// loudly, it just drops the sprite into a directory Sprite Pencil never looks at.
    static let spritePencilAppGroupID: String = {
        let bare = "group.com.jaydenirwin.spritepencil"
        #if os(macOS)
        if FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: bare) == nil {
            return "VA3SY54YU8." + bare
        }
        #endif
        return bare
    }()
    static let appWhatsNewVersion = 1
    static let defaultFontTestString = "The quick brown fox jumps over the lazy dog and runs away."
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
        // A catalog is a browsing window, so it opens roomy and stays freely resizable — no
        // `.windowResizability(.contentSize)`, which would pin it to whichever grid is on screen.
        .defaultSize(width: 1100, height: 720)
        .commands {
            SpriteCatalogCommands()
        }
        // No `Settings` scene, deliberately: everything `UserDefaults.register()` holds is
        // bookkeeping the app writes for itself — sprites viewed, sprites edited, and the sprite IDs
        // behind Browse's recent-activity row. There is not one user-facing preference to put in it.
        
        WindowGroup("Fullscreen Sprite", for: String.self) { $id in
            if let id, let sprite = SpriteSet.withID(id) {
                FullscreenSpriteView(sprite: sprite)
            }
        }
        .defaultSize(width: 640, height: 640)
        .commandsRemoved()
    }
    
    init() {
        UserDefaults.standard.register()
        ScreenshotMode.activate()   // no-op unless launched with -screenshotMode
        
        let appGroupDefaults = UserDefaults(suiteName: Sprite_CatalogApp.spritePencilAppGroupID)
        appGroupDefaults?.set(true, forKey: "ownsSpriteCatalog")
    }
}

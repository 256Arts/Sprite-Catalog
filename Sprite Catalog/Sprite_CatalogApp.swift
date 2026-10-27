import SwiftUI

@main
struct Sprite_CatalogApp: App {
    
    /// The container the "Open in Sprite Pencil" handoff writes its PNG into. The bare form on every
    /// platform: Sprite Pencil ships on the Mac as a Catalyst app, so that is where both apps meet.
    /// A team-prefixed form would also need registering on the App ID, which Xcode Cloud can't do.
    static let spritePencilAppGroupID = "group.com.jaydenirwin.spritepencil"
    static let defaultFontTestString = "The quick brown fox jumps over the lazy dog and runs away."
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .screenshotWindowSize()   // a no-op unless launched with -screenshotMode
                .screenshotModeStatus()   // a no-op unless launched with -screenshotMode
        }
        // A catalog is a browsing window, so it opens roomy and stays freely resizable.
        .defaultSize(width: 1100, height: 720)
        #if os(macOS)
        // `.contentSize` only for a screenshot run, where `screenshotWindowSize()` has fixed the
        // content and the window has to take it. Outside one it would pin the window to whichever
        // grid is on screen.
        .windowResizability(ScreenshotMode.isActive ? .contentSize : .automatic)
        // A screenshot run also opts out of state restoration, so it starts from the same window
        // every time: restoring would otherwise reopen whichever Fullscreen Sprite windows happened
        // to be open when the app was last quit, and the walk would photograph those.
        .restorationBehavior(ScreenshotMode.isActive ? .disabled : .automatic)
        #endif
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

import SwiftUI

@main
struct Sprite_CatalogApp: App {
    
    static let spritePencilAppGroupID = "group.com.jaydenirwin.spritepencil"
    static let appWhatsNewVersion = 1
    static let defaultFontTestString = "The quick brown fox jumps over the lazy dog and runs away."
    
    @Bindable var cloudController: CloudController = .shared
    
    @State var selectedScreen: MainScreen? = .browse
    @State var fontPreviewMode: FamilyDetailView.PreviewMode = .sample
    @State var fontTestString = Self.defaultFontTestString
    @State var showingEvent = false
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                Sidebar(selectedScreen: $selectedScreen)
            } detail: {
                NavigationStack {
                    Group {
                        switch selectedScreen {
                        case .browse:
                            BrowseView()
                        case .fonts:
                            FontsGridView()
                        case .palettes:
                            PalettesView()
                        case .myPalettes:
                            MyPalettesView()
                        case .imports:
                            if let collection = cloudController.spriteCollection {
                                ImportedCollectionSpritesGridView(userCollection: collection)
                            } else {
                                ProgressView()
                            }
                        case .category(let tag):
                            SpritesGridView(title: tag.rawValue, sprites: SpriteSet.allSprites.filter({ $0.tags.contains(tag) }))
                        case .collection(let collection):
                            UserCollectionSpritesGridView(userCollection: collection)
                        case nil:
                            EmptyView()
                        }
                    }
                    .navigationDestination(for: String.self) { spriteID in
                        if let sprite = SpriteSet.withID(spriteID) {
                            SpriteDetailView(sprite: sprite)
                        }
                    }
                    .navigationDestination(for: SpriteCollection.self) { collection in
                        CollectionView(collection: collection, webpageURL: nil)
                    }
                    .navigationDestination(for: Artist.self) { artist in
                        CollectionView(collection: SpriteCollection(artist: artist), webpageURL: artist.url)
                    }
                    .navigationDestination(for: FontFamily.self) { family in
                        FamilyDetailView(previewMode: $fontPreviewMode, customString: $fontTestString, family: family)
                    }
                }
            }
            .alert("Event Intro", isPresented: $showingEvent) {
                Button("OK", role: .close) { }
            } message: {
                Text("Now you can celebrate by tapping the sprite collection from the \"Browse\" tab, and trying out the new features!")
            }
            .onOpenURL { url in
                if url.path().contains("spritecatalog/appstoreevent") {
                    showingEvent = true
                }
            }
        }
        
        WindowGroup("Fullscreen Sprite", for: String.self) { $id in
            if let id, let sprite = SpriteSet.withID(id) {
                FullscreenSpriteView(sprite: sprite)
            }
        }
        .commandsRemoved()
    }
    
    init() {
        UserDefaults.standard.register()
        
        let appGroupDefaults = UserDefaults(suiteName: Sprite_CatalogApp.spritePencilAppGroupID)
        appGroupDefaults?.set(true, forKey: "ownsSpriteCatalog")
    }
}

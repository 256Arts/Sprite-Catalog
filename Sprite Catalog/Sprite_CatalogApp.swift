//
//  Sprite_CatalogApp.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-03-24.
//

import SwiftUI

@main
struct Sprite_CatalogApp: App {
    
    static let spritePencilAppGroupID =  "group.com.jaydenirwin.spritepencil"
    static let appWhatsNewVersion = 1
    
    @State var selectedScreen: MainScreen? = .browse
    
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
                        case .category(let tag):
                            SpritesGridView(title: tag.rawValue, sprites: SpriteSet.allSprites.filter({ $0.tags.contains(tag) }))
                        case .collection(let collection):
                            UserCollectionSpritesGridView(userCollection: collection)
                        case nil:
                            EmptyView()
                        }
                    }
                    .navigationDestination(for: String.self) { spriteID in
                        SpriteDetailView(sprite: SpriteSet.allSprites.first(where: { $0.id == spriteID })!)
                    }
                    .navigationDestination(for: SpriteCollection.self) { collection in
                        CollectionView(collection: collection, webpageURL: nil)
                    }
                    .navigationDestination(for: Artist.self) { artist in
                        CollectionView(collection: SpriteCollection(artist: artist), webpageURL: artist.url)
                    }
                }
            }
        }
        
        WindowGroup("Fullscreen Sprite", for: String.self) { $id in
            if let sprite = SpriteSet.allSprites.first(where: { $0.id == id }) {
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

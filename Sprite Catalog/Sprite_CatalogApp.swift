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
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                CategoriesView()
                BrowseView()
            }
        }
    }
    
    init() {
        UserDefaults.standard.register()
        
        let appGroupDefaults = UserDefaults(suiteName: Sprite_CatalogApp.spritePencilAppGroupID)
        appGroupDefaults?.set(true, forKey: "ownsSpriteCatalog")
    }
}

//
//  SpriteCatalogAppShortcutsProvider.swift
//  Sprite Cutter
//
//  Created by Jayden Irwin on 2023-10-08.
//

import AppIntents

struct SpriteCatalogAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CutSprites(),
            phrases: [
                "Cut sprites",
                "Cut spritesheet"
            ],
            shortTitle: "Cut Sprites"
        )
    }
    static var shortcutTileColor: ShortcutTileColor = .teal
}

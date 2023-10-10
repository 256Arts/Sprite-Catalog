//
//  UserDefaults.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-04-05.
//

import Foundation

extension UserDefaults {
    
    struct Key {
        static let whatsNewVersion = "whatsNewVersion"
        static let spritesViewed = "spritesViewed"
        static let spritesEdited = "spritesEdited"
        static let suggestions = "suggestions"
    }
    
    func register() {
        register(defaults: [
            Key.whatsNewVersion: 0,
            Key.spritesViewed: 0,
            Key.spritesEdited: 0,
            Key.suggestions: [String](),
        ])
    }
    
    func addSuggestion(basedOn sprite: SpriteSet) {
        var suggestions = stringArray(forKey: Key.suggestions) ?? []
        if let related = sprite.relatedSprites().first, !suggestions.contains(related.id) {
            suggestions.append(related.id)
            suggestions = Array(suggestions.suffix(12))
            setValue(suggestions, forKey: Key.suggestions)
        }
    }
    
}

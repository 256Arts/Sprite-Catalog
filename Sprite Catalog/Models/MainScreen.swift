//
//  MainScreen.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2022-08-21.
//

import SwiftUI

enum MainScreen: Hashable, Identifiable {
    case browse, fonts, imports, category(SpriteSet.Tag), collection(SpriteCollection)
    
    var id: String {
        switch self {
        case .browse:
            return "browse"
        case .fonts:
            return "fonts"
        case .imports:
            return "imports"
        case .category(let tag):
            return tag.rawValue
        case .collection(let collection):
            return collection.title
        }
    }
}

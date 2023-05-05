//
//  MainScreen.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2022-08-21.
//

import SwiftUI

enum MainScreen: Hashable, Identifiable {
    case browse, category(SpriteSet.Tag), collection(SpriteCollection)
    
    static func == (lhs: MainScreen, rhs: MainScreen) -> Bool {
        switch lhs {
        case .browse:
            if case .browse = rhs {
                return true
            }
            return false
        case .category(let tag):
            if case .category(let tag2) = rhs {
                return tag == tag2
            }
            return false
        case .collection(let collection):
            if case .collection(let collection2) = rhs {
                return collection == collection2
            }
            return false
        }
    }
    
    var id: String {
        switch self {
        case .browse:
            return "browse"
        case .category(let tag):
            return tag.rawValue
        case .collection(let collection):
            return collection.title
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

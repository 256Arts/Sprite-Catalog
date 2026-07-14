import SwiftUI

enum MainScreen: Hashable, Identifiable {
    case browse, fonts, palettes, myPalettes, imports, category(SpriteSet.Tag), collection(SpriteCollection)

    var id: String {
        switch self {
        case .browse:
            "browse"
        case .fonts:
            "fonts"
        case .palettes:
            "palettes"
        case .myPalettes:
            "myPalettes"
        case .imports:
            "imports"
        case .category(let tag):
            tag.rawValue
        case .collection(let collection):
            "collection-" + collection.title
        }
    }
}

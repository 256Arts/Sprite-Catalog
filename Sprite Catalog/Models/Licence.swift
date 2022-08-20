//
//  Licence.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-03-27.
//

import Foundation

enum Licence: String, CaseIterable, Identifiable, Codable {
    case none = ""
    case cc0 = "CC0"
    case attribution = "CC BY"
    case attributionShareAlike = "CC BY-SA"
    case attributionNonCommercial = "CC BY-NC"
    
    var id: Self {
        self
    }
    var name: String {
        switch self {
        case .none:
            return "N/A"
        case .cc0:
            return "Public Domain"
        case .attribution:
            return "Attribution"
        case .attributionShareAlike:
            return "Attribution-Share Alike"
        case .attributionNonCommercial:
            return "Attribution-Non Commercial"
        }
    }
    var url: URL {
        switch self {
        case .none:
            return URL(string: "https://creativecommons.org/licenses")!
        case .cc0:
            return URL(string: "https://creativecommons.org/publicdomain/zero/1.0")!
        case .attribution:
            return URL(string: "https://creativecommons.org/licenses/by/4.0")!
        case .attributionShareAlike:
            return URL(string: "https://creativecommons.org/licenses/by-sa/4.0")!
        case .attributionNonCommercial:
            return URL(string: "https://creativecommons.org/licenses/by-nc/4.0")!
        }
    }
}

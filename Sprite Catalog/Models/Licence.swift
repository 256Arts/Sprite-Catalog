//
//  Licence.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-03-27.
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
            "N/A"
        case .cc0:
            "Public Domain"
        case .attribution:
            "Attribution"
        case .attributionShareAlike:
            "Attribution-Share Alike"
        case .attributionNonCommercial:
            "Attribution-Non Commercial"
        }
    }
    var url: URL {
        switch self {
        case .none:
            URL(string: "https://apple.com")!
        case .cc0:
            URL(string: "https://creativecommons.org/publicdomain/zero/1.0")!
        case .attribution:
            URL(string: "https://creativecommons.org/licenses/by/4.0")!
        case .attributionShareAlike:
            URL(string: "https://creativecommons.org/licenses/by-sa/4.0")!
        case .attributionNonCommercial:
            URL(string: "https://creativecommons.org/licenses/by-nc/4.0")!
        }
    }
}

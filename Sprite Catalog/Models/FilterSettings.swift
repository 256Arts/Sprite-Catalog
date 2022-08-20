//
//  FilterSettings.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-07-07.
//

import Foundation

class FilterSettings: ObservableObject {
    
    enum SizeCategory {
        case lessThan16, equal16, moreThan16
    }
    
    static let shared = FilterSettings()
    
    @Published var sizeFilter: SizeCategory?
    @Published var animatedOnly = false
    @Published var tagFilters: Set<SpriteSet.Tag> = []
    
}

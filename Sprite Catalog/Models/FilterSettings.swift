//
//  FilterSettings.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-07-07.
//

import Foundation

@Observable
class FilterSettings {
    
    enum SizeCategory: Identifiable, CaseIterable {
        case lessThan16, equal16, moreThan16
        
        var id: Self { self }
        var title: String {
            switch self {
            case .lessThan16:
                "Small"
            case .equal16:
                "Medium (16x16)"
            case .moreThan16:
                "Large"
            }
        }
    }
    
    static let shared = FilterSettings()
    
    var sizeFilter: SizeCategory?
    var animatedOnly = false
    var tagFilters: Set<SpriteSet.Tag> = []
    
}

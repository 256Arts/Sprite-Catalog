//
//  FilterSettings.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-07-07.
//

import Foundation

class FilterSettings: ObservableObject {
    
    enum SizeCategory: Identifiable, CaseIterable {
        case lessThan16, equal16, moreThan16
        
        var id: Self { self }
        var title: String {
            switch self {
            case .lessThan16:
                return "Small"
            case .equal16:
                return "Medium (16x16)"
            case .moreThan16:
                return "Large"
            }
        }
    }
    
    static let shared = FilterSettings()
    
    @Published var sizeFilter: SizeCategory?
    @Published var animatedOnly = false
    @Published var tagFilters: Set<SpriteSet.Tag> = []
    
}

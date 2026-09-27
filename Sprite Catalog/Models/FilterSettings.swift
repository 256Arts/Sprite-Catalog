import Foundation

@Observable
class FilterSettings {
    
    enum SizeCategory: Identifiable, CaseIterable {
        case lessThan16, equal16, moreThan16
        
        var id: Self { self }
        var title: LocalizedStringResource {
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
    
    /// The perspective tag in `tagFilters`, if any. Picking one replaces the other perspectives, since a sprite has at most one.
    var perspective: SpriteSet.Tag? {
        get { SpriteSet.Tag.perspectives.first(where: tagFilters.contains) }
        set {
            tagFilters.subtract(SpriteSet.Tag.perspectives)
            if let newValue {
                tagFilters.insert(newValue)
            }
        }
    }
    
    var isFiltering: Bool {
        sizeFilter != nil || animatedOnly || !tagFilters.isEmpty
    }
    
}

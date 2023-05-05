//
//  BrowseCollectionPreview.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-07-05.
//

import SwiftUI

struct BrowseCollectionPreview: View {
    
    @State var collection: SpriteCollection
    @State var isLarge: Bool
    var rows: Int {
        isLarge ? 3 : 2
    }
    var columns: Int {
        isLarge ? 4 : 3
    }
    
    var body: some View {
        VStack {
            Grid {
                ForEach(0..<rows) { row in
                    GridRow {
                        ForEach(0..<columns) { column in
                            if let tile = tile(row: row, column: column) {
                                PlainTileThumbnail(tile: tile)
                                    .frame(width: isLarge ? 46 : 40, height: isLarge ? 46 : 40)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(LinearGradient(gradient: generateGradient(for: collection.title), startPoint: .top, endPoint: .bottom))
            .cornerRadius(16)
            Text(collection.title)
                .foregroundColor(.primary)
        }
    }
    
    func tile(row: Int, column: Int) -> SpriteSet.Tile? {
        let index = (row * columns) + column
        guard collection.sprites.indices.contains(index) else { return nil }
        
        return collection.sprites[index].tiles.first
    }
    
    func generateGradient(for string: String) -> Gradient {
        let baseColor: Color = {
            switch string {
            case "Playstation", "Mac", "PC":
                return .blue
            case "Switch":
                return .red
            case "Xbox":
                return .green
            case "Apple TV":
                return .gray
            case "Sci-Fi":
                return .purple
            case "Paintings":
                return .orange
            case "Valentines":
                return .pink
            case "Halloween":
                return .orange
            default:
                let colors = [Color.blue, .red, .purple, .orange, .green, .yellow, .pink, .gray]
                let index = abs(string.hash % colors.count)
                return colors[index]
            }
        }()
        return Gradient(colors: [baseColor.opacity(0.65), baseColor])
    }
    
}

struct BrowseCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseCollectionPreview(collection: SpriteCollection(title: "", spriteIDs: []), isLarge: true)
    }
}

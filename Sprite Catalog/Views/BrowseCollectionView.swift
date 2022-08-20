//
//  BrowseCollectionView.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-07-05.
//

import SwiftUI

struct BrowseCollectionView: View {
    
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
            LazyVGrid(columns: [GridItem(.fixed(isLarge ? 46 : 40))]) {
                ForEach(collection.sprites) { sprite in
                    PlainTileThumbnail(tile: sprite.tiles[0])
                        .frame(width: isLarge ? 46 : 40, height: isLarge ? 46 : 40)
                }
            }
            .padding()
            .background(LinearGradient(gradient: generateGradient(for: collection.title), startPoint: .top, endPoint: .bottom))
            .cornerRadius(16)
            Text(collection.title)
                .foregroundColor(.primary)
        }
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
        BrowseCollectionView(collection: SpriteCollection(title: "", spriteIDs: []), isLarge: true)
    }
}

import SwiftUI

struct BrowseCollectionPreview: View {
    
    let collection: SpriteCollection
    let isLarge: Bool
    
    var rows: Int {
        isLarge ? 3 : 2
    }
    var columns: Int {
        isLarge ? 4 : 3
    }
    var tileSize: CGFloat {
        isLarge ? 46 : 40
    }
    /// The hero's exact width, so the title below it can be given a real frame. Sizing the title to
    /// fit instead would let a long collection name stretch the card wider than its artwork.
    var width: CGFloat {
        (CGFloat(columns) * tileSize) + (CGFloat(columns - 1) * Self.tileSpacing) + (Self.heroPadding * 2)
    }
    var heroRadius: CGFloat {
        #if os(visionOS)
        8
        #else
        16
        #endif
    }
    
    private static let tileSpacing: CGFloat = 8
    private static let heroPadding: CGFloat = 16
    
    var body: some View {
        VStack {
            Grid(horizontalSpacing: Self.tileSpacing, verticalSpacing: Self.tileSpacing) {
                ForEach(0..<rows) { row in
                    GridRow {
                        ForEach(0..<columns) { column in
                            PlainTileThumbnail(tile: tile(row: row, column: column))
                                .frame(width: tileSize, height: tileSize)
                        }
                    }
                }
            }
            .padding(Self.heroPadding)
            .background(LinearGradient(gradient: generateGradient(for: collection.title), startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: heroRadius))
            
            Text(collection.title)
                .lineLimit(1)
                .allowsTightening(true)
                .truncationMode(.tail)
                .foregroundColor(.primary)
                .frame(width: width)
        }
        #if os(visionOS)
        .padding(.vertical, 6)
        .padding(.horizontal, 2)
        #endif
    }
    
    func tile(row: Int, column: Int) -> SpriteSet.Tile {
        let index = ((row * columns) + column) % collection.sprites.count
        return collection.sprites[index].tiles[0]
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

#Preview {
    BrowseCollectionPreview(collection: SpriteCollection(title: "", spriteIDs: []), isLarge: true)
}

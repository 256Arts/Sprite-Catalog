//
//  Sprite.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-03-24.
//

import SwiftUI

struct SpriteSet: Equatable, Identifiable, Codable {
    
    enum Layer: String, CaseIterable, Identifiable, Codable {
        case sky, floor, floorOverlay, object, item, particle
        // Examples: sky, grass, cobblestones on grass, wall, window, smoke
        var id: Self {
            self
        }
    }
    enum Tag: String, Identifiable, Codable {
        // Meta
        case blackOutline = "Black Outline"
        case limitedPalette = "Limited Palette"
        case topDown = "Top Down"
        case sideView = "Side View"
        case isometric = "Isometric"
        // Categories
        case peopleAnimal = "People & Animals"
        case food = "Food"
        case treasure = "Treasure" // Timeless valuables
        case weaponTool = "Weapons & Tools"
        case clothing = "Clothing"
        case miscItem = "Misc. Items" // Smaller than furnature, typically used for inventory items
        case nature = "Nature"
        case object = "Objects" // Can be placed on the ground, and typically take up vertical space such that the character cannot walk inside them
        case effect = "Effects"
        case tile = "Tiles"
        case interface = "Interface"
        case artwork = "Artwork" // Complete art pieces, comparable to real photos
        
        var id: Self {
            self
        }
    }
    
    struct Tile: Identifiable, Codable {
        
        struct ConnectedEdges: Equatable, Codable {
            static let all = ConnectedEdges(top: true, bottom: true, left: true, right: true, topLeft: true, topRight: true, bottomLeft: true, bottomRight: true)
            
            let top: Bool
            let bottom: Bool
            let left: Bool
            let right: Bool
            let topLeft: Bool
            let topRight: Bool
            let bottomLeft: Bool
            let bottomRight: Bool
        }
        enum Direction: String, Comparable, Identifiable, Codable {
            case up, down, left, right
            case upLeft = "up.left"
            case upRight = "up.right"
            case downLeft = "down.left"
            case downRight = "down.right"
            
            static func < (lhs: SpriteSet.Tile.Direction, rhs: SpriteSet.Tile.Direction) -> Bool {
                lhs.hashValue < rhs.hashValue
            }
            
            var id: Self {
                self
            }
        }
        struct RandomVariant: Codable, Transferable {
            
            static var transferRepresentation: some TransferRepresentation {
                FileRepresentation(exportedContentType: .png) {
                    SentTransferredFile($0.url)
                }
            }
            
            let weight: Int?
            let frameCount: Int?
            let reverses: Bool?
            let imageName: String
            var url: URL {
                if imageName.starts(with: "c-") {
                    let fileName = String(imageName.dropFirst(2))
                    return CloudController.shared.userSpritesDirectoryURL.appendingPathComponent(fileName, isDirectory: false).appendingPathExtension("png")
                } else {
                    return Bundle.main.url(forResource: imageName, withExtension: "png")!
                }
            }

            private var uiImage: UIImage {
                if imageName.starts(with: "c-") {
                    return UIImage(contentsOfFile: url.path) ?? UIImage()
                } else {
                    return UIImage(named: imageName)!
                }
            }
            
            func frameImage(frame: Int = 0) -> UIImage {
                if let frameCount = frameCount {
                    let cgImage = uiImage.cgImage!
                    let frameWidth = cgImage.width / frameCount
                    let frameSize = CGSize(width: frameWidth, height: cgImage.height)
                    let frameRect = CGRect(origin: CGPoint(x: frameWidth * frame, y: 0), size: frameSize)
                    let frame = cgImage.cropping(to: frameRect)!
                    return UIImage(cgImage: frame)
                } else {
                    return uiImage
                }
            }
            func frameImages() -> [UIImage] {
                if let frameCount = frameCount {
                    let cgImage = uiImage.cgImage!
                    let frameWidth = cgImage.width / frameCount
                    let frameSize = CGSize(width: frameWidth, height: cgImage.height)
                    var images: [UIImage] = []
                    for frame in 0..<frameCount {
                        let frameRect = CGRect(origin: CGPoint(x: frameWidth * frame, y: 0), size: frameSize)
                        images.append(UIImage(cgImage: cgImage.cropping(to: frameRect)!))
                    }
                    return images
                } else {
                    return [uiImage]
                }
            }
            
            init(weight: Int? = nil, frameCount: Int? = nil, reverses: Bool? = nil, imageName: String) {
                self.weight = weight
                self.frameCount = frameCount
                self.reverses = reverses
                self.imageName = imageName
            }
        }
        
        let connectedEdges: ConnectedEdges?
        let facing: Direction?
        let variants: [RandomVariant]
        var id: String {
            variants.first!.imageName
        }
        
        init(borders: ConnectedEdges? = nil, facing: Direction? = nil, variants: [RandomVariant]) {
            self.connectedEdges = borders
            self.facing = facing
            self.variants = variants
        }
        
    }
    
    static func == (lhs: SpriteSet, rhs: SpriteSet) -> Bool {
        lhs.id == rhs.id
    }
    
    static var allSprites: [SpriteSet] = {
        guard let url = Bundle.main.url(forResource: "ZCatalog", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            #if DEBUG
            var sprites = try JSONDecoder().decode([SpriteSet].self, from: data)
            // Edit array here
//            for index in sprites.indices {
//                if sprites[index].layer == .floor || sprites[index].layer == .floorOverlay {
//                    sprites[index].tags.insert(.tile)
//                }
//            }
//            // Print
//            if let newData = try? JSONEncoder().encode(sprites), let jsonString = String(data: newData, encoding: .utf8) {
//                print(jsonString)
//            }
            return sprites
            #else
            return try JSONDecoder().decode([SpriteSet].self, from: data)
            #endif
        } catch {
            print("Failed to load data from JSON file.")
            return []
        }
    }()
    
    var id: String
    let name: String
    let artist: Artist
    let licence: Licence
    let layer: Layer
    let tags: Set<Tag>
    let tiles: [Tile]
    
    var states: [Tile] {
        // Tiles with the same border and direction used to store different sprite 'states'
        tiles.filter({ $0.connectedEdges == tiles.first!.connectedEdges && $0.facing == tiles.first!.facing })
    }
    
    func relatedScore(to other: SpriteSet) -> Int {
        var score = 0
        if name == other.name {
            score += 40
        } else if name.split(separator: " ").contains(where: other.name.contains) {
            score += 20
        }
        if artist == other.artist {
            score += 10
        }
        score += tags.intersection(other.tags).count
        return score
    }
    func relatedSprites() -> [SpriteSet] {
        var matchesAndScores: [(sprite: SpriteSet, rating: Int)] = SpriteSet.allSprites.map({ ($0, $0.relatedScore(to: self)) })
        matchesAndScores.removeAll(where: { $0.rating < 10 || $0.sprite == self })
        matchesAndScores.sort(by: { $0.rating > $1.rating })
        return matchesAndScores.map({ $0.sprite })
    }
    
    func exportImageDocuments() -> [ImageDocument] {
        var documents: [ImageDocument] = []
        
        for (tIndex, tile) in tiles.enumerated() {
            let tileSuffix = tiles.count == 1 ? "" : " \(tile.facing?.rawValue ?? String(tIndex+1))"
            
            for (vIndex, variant) in tile.variants.enumerated() {
                let variantSuffix = tile.variants.count == 1 ? "" : " \(vIndex+1)"
                let filename = name + tileSuffix + variantSuffix
                
                documents.append(ImageDocument(image: UIImage(named: variant.imageName)!, filename: filename))
            }
        }
        return documents
    }
    
}

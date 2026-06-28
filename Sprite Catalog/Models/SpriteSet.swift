//
//  Sprite.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-03-24.
//

import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

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
                    // User-imported sprites are stored as "<imageName>.png" (the "c-" prefix is part of the filename, see SpriteImporter.save()).
                    return CloudController.shared.userSpritesDirectoryURL.appendingPathComponent(imageName, isDirectory: false).appendingPathExtension("png")
                } else {
                    return Bundle.main.url(forResource: imageName, withExtension: "png")!
                }
            }

            /// The variant's full image. Falls back to an empty image rather than crashing when a bundle resource is missing or a `c-` file hasn't finished downloading from iCloud.
            var uiImage: UIImage {
                if imageName.starts(with: "c-") {
                    UIImage(contentsOfFile: url.path) ?? UIImage()
                } else if let image = UIImage(named: imageName) {
                    image
                } else {
                    // A non-empty name with no matching asset means a stale catalog entry — surface it in development, degrade to blank in production. An empty name is an intentional placeholder.
                    assert(imageName.isEmpty, "Missing bundled sprite image: \(imageName)")
                    UIImage()
                }
            }

            func frameImage(frame: Int = 0) -> UIImage {
                let image = uiImage
                guard let frameCount, frameCount > 0, let cgImage = image.cgImage else { return image }
                let frameWidth = cgImage.width / frameCount
                let frameSize = CGSize(width: frameWidth, height: cgImage.height)
                let frameRect = CGRect(origin: CGPoint(x: frameWidth * frame, y: 0), size: frameSize)
                guard frameWidth > 0, let slice = cgImage.cropping(to: frameRect) else { return image }
                return UIImage(cgImage: slice)
            }
            func frameImages() -> [UIImage] {
                let image = uiImage
                guard let frameCount, frameCount > 0, let cgImage = image.cgImage else { return [image] }
                let frameWidth = cgImage.width / frameCount
                guard frameWidth > 0 else { return [image] }
                let frameSize = CGSize(width: frameWidth, height: cgImage.height)
                return (0..<frameCount).compactMap { frame in
                    let frameRect = CGRect(origin: CGPoint(x: frameWidth * frame, y: 0), size: frameSize)
                    return cgImage.cropping(to: frameRect).map(UIImage.init(cgImage:))
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
            variants[0].imageName
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

    /// Resolves a sprite by `id`, searching the built-in catalog first, then user-imported (`c-`) sprites.
    static func withID(_ id: String) -> SpriteSet? {
        allSprites.first(where: { $0.id == id }) ?? CloudController.shared.userSprites.first(where: { $0.id == id })
    }

    var id: String
    let name: String
    let artist: Artist
    let licence: Licence
    let layer: Layer
    let tags: Set<Tag>
    let tiles: [Tile]
    
    var states: [Tile] {
        // Tiles with the same border and direction used to store different sprite 'states'
        tiles.filter({ $0.connectedEdges == tiles[0].connectedEdges && $0.facing == tiles[0].facing })
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

    /// Related sprites for display, re-ranked by Apple Intelligence when available, otherwise the heuristic ``relatedSprites()``.
    func suggestedRelatedSprites(limit: Int = 10) async -> [SpriteSet] {
        let candidates = relatedSprites()
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *),
           let ranked = await Self.aiRankedRelated(target: self, candidates: Array(candidates.prefix(40)), limit: limit) {
            return ranked
        }
        #endif
        return Array(candidates.prefix(limit))
    }
    
    func exportImageDocuments() -> [ImageDocument] {
        var documents: [ImageDocument] = []
        
        for (tIndex, tile) in tiles.enumerated() {
            let tileSuffix = tiles.count == 1 ? "" : " \(tile.facing?.rawValue ?? String(tIndex+1))"
            
            for (vIndex, variant) in tile.variants.enumerated() {
                let variantSuffix = tile.variants.count == 1 ? "" : " \(vIndex+1)"
                let filename = name + tileSuffix + variantSuffix
                
                documents.append(ImageDocument(image: variant.uiImage, filename: filename))
            }
        }
        return documents
    }

}

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
extension SpriteSet {

    @Generable
    private struct RelatedRanking {
        @Guide(description: "Indices into the candidate list, most related first.")
        let indices: [Int]
    }

    /// Asks the on-device model to rank `candidates` by relevance to `target`. Returns `nil` when Apple Intelligence is unavailable or errors, so the caller can fall back to the heuristic order.
    static func aiRankedRelated(target: SpriteSet, candidates: [SpriteSet], limit: Int) async -> [SpriteSet]? {
        guard case .available = SystemLanguageModel.default.availability, !candidates.isEmpty else { return nil }

        func describe(_ sprite: SpriteSet) -> String {
            "\(sprite.name) [\(sprite.tags.map(\.rawValue).joined(separator: ", "))]"
        }
        let list = candidates.enumerated()
            .map({ "\($0.offset): \(describe($0.element))" })
            .joined(separator: "\n")
        let prompt = """
        Target sprite: \(describe(target))

        Candidate sprites:
        \(list)

        Choose up to \(limit) candidates most thematically related to the target — same subject, setting, or use. Reply with their indices, most related first.
        """
        do {
            let session = LanguageModelSession(instructions: "You curate related items for a pixel-art sprite catalog.")
            let ranking = try await session.respond(to: prompt, generating: RelatedRanking.self).content
            var ordered: [SpriteSet] = []
            for index in ranking.indices where candidates.indices.contains(index) {
                let sprite = candidates[index]
                if !ordered.contains(sprite) {
                    ordered.append(sprite)
                }
            }
            // Top up with the remaining heuristic order so the section is never sparse.
            for sprite in candidates where !ordered.contains(sprite) {
                ordered.append(sprite)
            }
            return Array(ordered.prefix(limit))
        } catch {
            return nil
        }
    }

}
#endif

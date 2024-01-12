//
//  SpriteImporter.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-07-10.
//

import SwiftUI

final class SpriteImporter: ObservableObject {
    
    struct SpriteSetConfiguration: Identifiable {
        var importedFileURLs: [URL]
        var id: URL {
            importedFileURLs.first!
        }
        var name: String
        var category: SpriteSet.Tag
        var frameCount = 1
    }
    
    static let categories: [SpriteSet.Tag] = [.peopleAnimal, .food, .weaponTool, .clothing, .treasure, .miscItem, .nature, .object, .effect, .tile, .interface, .artwork]
    static var generatedIDs: Set<String> = []

    init(debugMode: Bool) {
        self.debugMode = debugMode
    }

    let debugMode: Bool
    let fileManager = FileManager.default
    var importedDirectory: URL {
        debugMode ? fileManager.temporaryDirectory : CloudController.shared.userSpritesDirectoryURL
    }
    
    @Published var artistName = ""
    @Published var artistWebsite = ""
    @Published var licence: Licence = .none
    @Published var defaultCategory: SpriteSet.Tag = .miscItem
    @Published var blackOutline = true
    @Published var limitedPalette = true
    @Published var importFilenames = true
    
    @Published var spriteConfigs: [SpriteSetConfiguration] = []
    
    func clearImportedDirectory() throws {
        guard debugMode else { return }

        let filenames = try fileManager.contentsOfDirectory(atPath: importedDirectory.path)
        for filename in filenames {
            let fileURL = importedDirectory.appendingPathComponent(filename)
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    func importFiles(at urls: [URL]) {
        let sortedPickedURLs = urls.sorted(by: { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending })
        for pickedURL in sortedPickedURLs {
            let importedURL = importedDirectory.appendingPathComponent(pickedURL.lastPathComponent, isDirectory: false)
            do {
                // Copy file immediately to ensure future access
                guard pickedURL.startAccessingSecurityScopedResource() else {
                    print("Failed to start accessing resource")
                    continue
                }
                try fileManager.copyItem(at: pickedURL, to: importedURL)
                pickedURL.stopAccessingSecurityScopedResource()
                
                let name = importFilenames ? pickedURL.deletingPathExtension().lastPathComponent
                    .replacingOccurrences(of: "-", with: " ")
                    .replacingOccurrences(of: "_", with: " ")
                    .replacingOccurrences(of: ".", with: " ")
                    .localizedCapitalized : ""
                
                spriteConfigs.append(SpriteSetConfiguration(importedFileURLs: [importedURL], name: name, category: defaultCategory))
            } catch {
                print("Failed to move imported files")
            }
        }
    }
    
    func mergeWithAbove(config oldConfig: SpriteSetConfiguration) {
        guard let oldIndex = spriteConfigs.firstIndex(where: { $0.id == oldConfig.id }) else { return }
        let newIndex = oldIndex - 1
        guard 0 <= newIndex else { return }
        spriteConfigs[newIndex].importedFileURLs += oldConfig.importedFileURLs
        spriteConfigs.remove(at: oldIndex)
    }
    
    func save() throws {
        // Setup Sprites
        var templateSprites: [SpriteSet] = []
        var spriteURLs: [URL] = []
        for config in spriteConfigs {
            
            let templateSprite = createTemplateSprite(config: config)
            templateSprites.append(templateSprite)
            
            for (urlIndex, importFileURL) in config.importedFileURLs.enumerated() {
                let newImageName = templateSprite.tiles[urlIndex].variants[0].imageName
                let newTempURL = importedDirectory.appendingPathComponent(newImageName).appendingPathExtension("png")
                try fileManager.moveItem(at: importFileURL, to: newTempURL)
                spriteURLs.append(newTempURL)
            }
        }
        
        // Encode JSON
        templateSprites.sort(by: { $0.id.localizedStandardCompare($1.id) == .orderedAscending })
        var data = try JSONEncoder().encode(templateSprites)
        if var jsonString = String(data: data, encoding: .utf8) {
//            jsonString = jsonString.replacingOccurrences(of: "},{\"licence", with: "},\n{\"licence")
            jsonString.removeFirst() // "["
            jsonString.removeLast() // "]"
            jsonString.append(",")
            if let newData = jsonString.data(using: .utf8) {
                data = newData
            }
        }
        let jsonURL = importedDirectory.appendingPathComponent(debugMode ? "WIP Sprites" : "Collection").appendingPathExtension("json")
        try data.write(to: jsonURL)
        
        // Export UI
        if debugMode {
            let exportVC = UIDocumentPickerViewController(forExporting: [jsonURL] + spriteURLs)
            if let rootVC = UIApplication.shared.windows.first?.rootViewController?.presentedViewController {
                rootVC.present(exportVC, animated: true, completion: nil)
            }
        }
    }
    
    func createTemplateSprite(config: SpriteSetConfiguration) -> SpriteSet {
        let newID = generateID()
        let artist = Artist(name: artistName.trimmingCharacters(in: .whitespacesAndNewlines))
        let layer: SpriteSet.Layer = {
            switch config.category {
            case .artwork:
                return .sky
            case .tile:
                return .floor
            case .peopleAnimal, .nature, .object:
                return .object
            case .effect, .interface:
                return .particle
            default:
                return .item
            }
        }()
        var tags: Set<SpriteSet.Tag> = [config.category]
        if blackOutline {
            tags.insert(.blackOutline)
        }
        if limitedPalette {
            tags.insert(.limitedPalette)
        }
        var tiles: [SpriteSet.Tile] = []
        for urlIndex in config.importedFileURLs.indices {
            if urlIndex == 0 {
                tiles.append(SpriteSet.Tile(variants: [.init(imageName: newID)]))
            } else {
                tiles.append(SpriteSet.Tile(variants: [.init(imageName: "\(newID)-\(urlIndex + 1)")]))
            }
        }
        return SpriteSet(id: newID, name: config.name, artist: artist, licence: licence, layer: layer, tags: tags, tiles: tiles)
    }
    
    func generateID() -> String {
        let idCharacters: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m"]
        var newID: String
        repeat {
            newID = debugMode ? "" : "c-"
            for _ in 1...6 {
                newID.append(idCharacters.randomElement()!)
            }
        } while SpriteImporter.generatedIDs.contains(newID) || SpriteSet.allSprites.contains(where: { $0.id == newID }) || (CloudController.shared.spriteCollection?.sprites ?? []).contains(where: { $0.id == newID })
        
        SpriteImporter.generatedIDs.insert(newID)
        return newID
    }
    
}

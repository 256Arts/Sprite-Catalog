//
//  CloudController.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2022-04-26.
//

import Foundation

class CloudController: ObservableObject {

    enum FetchError: Error {
        case noObjectForKey
    }

    static let shared = CloudController()

    let userSpritesDirectoryURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let metadataQuery = NSMetadataQuery()

    @Published var spriteCollection: SpriteCollection?

    init() {
        metadataQuery.notificationBatchingInterval = 1
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope]

        NotificationCenter.default.addObserver(self,
            selector: #selector(metadataQueryDidFinishGathering),
            name: Notification.Name.NSMetadataQueryDidFinishGathering,
            object: metadataQuery)
        metadataQuery.start()
    }

    @objc func metadataQueryDidFinishGathering(_ notification: Notification) {
        metadataQuery.disableUpdates()
        if metadataQuery.results.isEmpty {
            print("No cloud files found. Creating new file.")
            spriteCollection = SpriteCollection(title: "Imported", spriteIDs: [])
        } else {
            do {
                spriteCollection = try fetchUserSprites()
            } catch {
                print("Failed to fetch data after query gather")
            }
        }
        metadataQuery.enableUpdates()
    }

    func fetchUserSprites() throws -> SpriteCollection? {
        #if targetEnvironment(macCatalyst)
        // macOS 12.0 beta 5 bug: Infinate `fetchUserSprites()` loop workaround
        return nil
        #else
        try FileManager.default.startDownloadingUbiquitousItem(at: userSpritesDirectoryURL)
        do {
            let attributes = try userSpritesDirectoryURL.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
            if let status: URLUbiquitousItemDownloadingStatus = attributes.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus {
                switch status {
                case .current, .downloaded:
                    return try loadUserSprites()
                default:
                    // Download again
                    return try fetchUserSprites()
                }
            }
        } catch {
            print(error)
        }

        return try loadUserSprites()
        #endif
    }

    func loadUserSprites() throws -> SpriteCollection? {
        let spriteURLs = try FileManager.default.contentsOfDirectory(at: userSpritesDirectoryURL, includingPropertiesForKeys: nil)
        let sprites = spriteURLs.compactMap {
            loadUserSprite(at: $0)
        }
        return SpriteCollection(title: "Imported", spriteIDs: Set(sprites.map { $0.id }))
    }

    func loadUserSprite(at url: URL) -> SpriteSet? {
        guard url.pathExtension.lowercased() == "png" else { return nil }

        let name = url.lastPathComponent
        return SpriteSet(id: "c-\(name)", name: name, artist: Artist(name: "User"), licence: .none, layer: .object, tags: [], tiles: [
            .init(variants: [.init(imageName: "c-\(name)")])
        ])
    }

}

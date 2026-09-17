import Foundation

@Observable
class CloudController {

    enum FetchError: Error {
        case noObjectForKey
    }

    static let shared = CloudController()

    let userSpritesDirectoryURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let metadataQuery = NSMetadataQuery()

    /// The fully-resolved user-imported sprites. `SpriteSet.withID(_:)` and `SpriteCollection.sprites` resolve `c-` IDs against this.
    var userSprites: [SpriteSet] = []
    var spriteCollection: SpriteCollection?

    init() {
        metadataQuery.notificationBatchingInterval = 1
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope]

        NotificationCenter.default.addObserver(self,
            selector: #selector(metadataQueryDidFinishGathering),
            name: Notification.Name.NSMetadataQueryDidFinishGathering,
            object: metadataQuery)
        NotificationCenter.default.addObserver(self,
            selector: #selector(metadataQueryDidUpdate),
            name: Notification.Name.NSMetadataQueryDidUpdate,
            object: metadataQuery)
        metadataQuery.start()
    }

    @objc func metadataQueryDidFinishGathering(_ notification: Notification) {
        metadataQuery.disableUpdates()
        if metadataQuery.results.isEmpty {
            print("No cloud files found. Creating new file.")
            userSprites = []
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

    /// Another device imported a sprite, or a download started by ``fetchUserSprites()`` finished.
    @objc func metadataQueryDidUpdate(_ notification: Notification) {
        metadataQuery.disableUpdates()
        spriteCollection = try? loadUserSprites()
        metadataQuery.enableUpdates()
    }

    /// Loads what is on disk now and asks iCloud for the rest; the query's updates reload as it lands.
    func fetchUserSprites() throws -> SpriteCollection? {
        try FileManager.default.startDownloadingUbiquitousItem(at: userSpritesDirectoryURL)
        return try loadUserSprites()
    }

    func loadUserSprites() throws -> SpriteCollection? {
        let spriteURLs = try FileManager.default.contentsOfDirectory(at: userSpritesDirectoryURL, includingPropertiesForKeys: nil)
        userSprites = spriteURLs.compactMap {
            loadUserSprite(at: $0)
        }
        return SpriteCollection(title: "Imported", spriteIDs: Set(userSprites.map { $0.id }))
    }

    func loadUserSprite(at url: URL) -> SpriteSet? {
        // iOS lists a sprite that has not downloaded yet as a hidden ".c-XXXXXX.png.icloud" placeholder.
        var url = url
        if url.pathExtension == "icloud", url.lastPathComponent.hasPrefix(".") {
            url = url.deletingLastPathComponent().appendingPathComponent(String(url.deletingPathExtension().lastPathComponent.dropFirst()))
        }
        guard url.pathExtension.lowercased() == "png" else { return nil }

        // The "c-XXXXXX" filename (sans extension) is both the sprite's id and its imageName, matching SpriteImporter's convention.
        let name = url.deletingPathExtension().lastPathComponent
        return SpriteSet(id: name, name: name, artist: Artist(name: "User"), licence: .none, layer: .object, tags: [], tiles: [
            .init(variants: [.init(imageName: name)])
        ])
    }

}

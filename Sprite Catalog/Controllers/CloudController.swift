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
        let fileURLs = try FileManager.default.contentsOfDirectory(at: userSpritesDirectoryURL, includingPropertiesForKeys: nil).map(Self.resolvingPlaceholder)

        // Each import writes "c-XXXXXX.json" beside its PNGs. A sprite whose JSON is still downloading
        // is left out until the query's update reloads it, rather than flashing up as bare images.
        let jsonURLs = fileURLs.filter { $0.pathExtension.lowercased() == "json" }
        let describedIDs = Set(jsonURLs.map { $0.deletingPathExtension().lastPathComponent })
        let describedSprites = jsonURLs.compactMap { url in
            (try? Data(contentsOf: url)).flatMap { try? JSONDecoder().decode(SpriteSet.self, from: $0) }
        }

        // Sprites imported before the JSON existed are only a PNG each.
        let bareSprites = fileURLs.compactMap { url -> SpriteSet? in
            guard url.pathExtension.lowercased() == "png" else { return nil }
            // A sprite's later states are "c-XXXXXX-2.png" and up; the first eight characters are its id.
            let name = url.deletingPathExtension().lastPathComponent
            guard !describedIDs.contains(String(name.prefix(8))) else { return nil }
            return SpriteSet(id: name, name: name, artist: Artist(name: "User"), licence: .none, layer: .object, tags: [], tiles: [
                .init(variants: [.init(imageName: name)])
            ])
        }

        userSprites = describedSprites + bareSprites
        return SpriteCollection(title: "Imported", spriteIDs: Set(userSprites.map { $0.id }))
    }

    /// Removes imported sprites — every PNG and the JSON describing each — from iCloud on all the
    /// user's devices, and drops them from the collections that held them. Built-in sprites are skipped.
    func delete(_ sprites: [SpriteSet]) {
        let sprites = sprites.filter(\.isImported)
        guard !sprites.isEmpty else { return }

        let fileURLs = sprites.flatMap { sprite in
            sprite.tiles.flatMap(\.variants).compactMap(\.fileURL)
                + [userSpritesDirectoryURL.appendingPathComponent(sprite.id).appendingPathExtension("json")]
        }
        for url in fileURLs {
            // A file that never downloaded is only its placeholder; a bare-PNG sprite has no JSON.
            let placeholderURL = url.deletingLastPathComponent().appendingPathComponent(".\(url.lastPathComponent).icloud")
            for url in [url, placeholderURL] where FileManager.default.fileExists(atPath: url.path) {
                NSFileCoordinator().coordinate(writingItemAt: url, options: .forDeleting, error: nil) { url in
                    try? FileManager.default.removeItem(at: url)
                }
            }
        }

        let ids = Set(sprites.map(\.id))
        for collection in [SpriteCollection.myCollection, SpriteCollection.stickersCollection] where !collection.spriteIDs.isDisjoint(with: ids) {
            collection.spriteIDs.subtract(ids)
            try? collection.saveEdits()
        }

        spriteCollection = try? loadUserSprites()
    }

    /// iOS lists a file that has not downloaded yet as a hidden ".<name>.icloud" placeholder.
    private static func resolvingPlaceholder(_ url: URL) -> URL {
        guard url.pathExtension == "icloud", url.lastPathComponent.hasPrefix(".") else { return url }
        return url.deletingLastPathComponent().appendingPathComponent(String(url.deletingPathExtension().lastPathComponent.dropFirst()))
    }

}

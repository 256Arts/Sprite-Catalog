#if DEBUG
import SwiftUI

/// Curates the catalog's order: drag sprites around, then Save moves a re-encoded
/// `ZCatalog.json` out of the app so it can replace the bundled one.
@available(iOS 27, macOS 27, visionOS 27, *)
struct DebugReorderView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var sprites = SpriteSet.allSprites
    @State private var exportURLs: [URL] = []
    @State private var showingExport = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 48), spacing: 8)], spacing: 8) {
                    ForEach(sprites) { sprite in
                        PlainTileThumbnail(tile: sprite.tiles[0])
                            .frame(width: 48, height: 48)
                    }
                    .reorderable()
                }
                .reorderContainer(for: SpriteSet.self) { difference in
                    difference.apply(to: &sprites)
                    // The rest of the app reads the catalog from here, so it shows the new order too.
                    SpriteSet.allSprites = sprites
                }
                .padding()
            }
            .navigationTitle("Reorder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
            .fileMover(isPresented: $showingExport, files: exportURLs) { _ in }
        }
    }

    private func save() {
        do {
            let url = URL.temporaryDirectory.appending(path: "ZCatalog.json")
            try JSONEncoder().encode(sprites).write(to: url)
            exportURLs = [url]
            showingExport = true
        } catch {
            print("Failed to encode sprites JSON: \(error)")
        }
    }
}

@available(iOS 27, macOS 27, visionOS 27, *)
private extension ReorderDifference where CollectionID == ReorderableSingleCollectionIdentifier {
    func apply(to sprites: inout [SpriteSet]) where ItemID == SpriteSet.ID {
        let moving = Set(sources)
        var moved: [SpriteSet] = []
        sprites.removeAll { sprite in
            guard moving.contains(sprite.id) else { return false }
            moved.append(sprite)
            return true
        }
        switch destination.position {
        case .before(let id):
            sprites.insert(contentsOf: moved, at: sprites.firstIndex { $0.id == id } ?? sprites.endIndex)
        case .end:
            sprites.append(contentsOf: moved)
        }
    }
}

@available(iOS 27, macOS 27, visionOS 27, *)
#Preview {
    DebugReorderView()
}
#endif

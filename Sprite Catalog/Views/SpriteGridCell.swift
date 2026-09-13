import SwiftUI

/// One sprite in a grid.
///
/// Every grid in the app is built from this, so a sprite behaves the same in all of them: it opens
/// its detail screen, drags out of the app as a named PNG, and offers the detail screen's actions
/// on a right-click or a long press. A grid that hands it a ``SpriteSelection`` also gets
/// multi-select, where the cell toggles its sprite instead of opening it.
struct SpriteGridCell: View {

    let sprite: SpriteSet
    /// Artwork is browsed at a size worth looking at; every other category is a 64pt tile.
    var isArtwork = false
    /// `nil` on the rows that only ever browse — Related, and Browse's recent activity.
    var selection: SpriteSelection?
    /// Fills the screen's ``spriteExporter(_:)``. The exporter belongs to the screen rather than to
    /// the cell: one sheet per grid, not one behind every thumbnail on it.
    let export: ([SpriteSet]) -> Void

    private var isSelected: Bool? {
        guard let ids = selection?.ids else { return nil }
        return ids.contains(sprite.id)
    }

    /// What a menu item acts on: the whole selection when this cell is part of it, otherwise this
    /// sprite alone — the same rule the Finder follows.
    private var actionSprites: [SpriteSet] {
        if isSelected == true, let selection {
            selection.sprites
        } else {
            [sprite]
        }
    }

    var body: some View {
        cell
            .accessibilityLabel(sprite.name)
            .accessibilityIdentifier("Sprite.\(sprite.id)")
            .cellButtonStyle()
            .draggable(sprite.transfer)
            .contextMenu {
                SpriteActions(sprites: actionSprites, export: export)
            }
    }

    @ViewBuilder
    private var cell: some View {
        if isSelected == nil {
            NavigationLink(value: sprite.id) {
                thumbnail
            }
        } else {
            Button {
                selection?.toggle(sprite.id)
            } label: {
                thumbnail
            }
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if isArtwork {
            ArtworkTileThumbnail(tile: sprite.tiles[0])
                .selectionMark(isSelected)
        } else {
            TileThumbnail(tile: sprite.tiles[0])
                .selectionMark(isSelected)
        }
    }

}

private extension View {

    /// Badges a cell with its selection state, and fades it back when it is not selected. `nil`
    /// leaves the cell alone, which is the grid's normal browsing state.
    @ViewBuilder
    func selectionMark(_ isSelected: Bool?) -> some View {
        if let isSelected {
            overlay(alignment: .bottomTrailing) {
                Group {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .tint)
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.title3)
                .padding(4)
            }
            .opacity(isSelected ? 1 : 0.6)
        } else {
            self
        }
    }

}

#Preview {
    SpriteGridCell(sprite: SpriteSet(id: "xxxxxx", name: "Title", artist: Artist(name: "Jayden"), licence: .cc0, layer: .object, tags: [], tiles: [.init(variants: [.init(imageName: "")])])) { _ in }
}

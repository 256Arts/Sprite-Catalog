import SwiftUI

/// A grid's multi-selection.
///
/// `ids` is `nil` while the grid is browsing, so a cell opens its sprite; turning selection on makes
/// it a set — possibly empty — and a cell toggles its sprite instead. The sprite actions then run
/// against everything selected, so Export and Add to… work on a batch rather than one at a time.
@Observable
final class SpriteSelection {

    var ids: Set<String>? {
        didSet {
            if ids == nil { anchor = nil }
        }
    }

    /// The grid's sprites in the order they are shown, which is what Select All takes and what a
    /// Shift-click's range runs along. Kept by ``View/spriteSelectionToolbar(_:displaying:exporting:)``.
    @ObservationIgnored var displayedIDs: [String] = []
    /// Whether Shift is held, so a click selects a run instead of one sprite. Only a Mac reports it.
    @ObservationIgnored var extendsRange = false
    /// Whether ⌘ is held, so a click while browsing starts a selection instead of opening the sprite.
    /// Only a Mac reports it.
    @ObservationIgnored var addsToSelection = false
    /// Where a Shift-click's run starts: the last sprite clicked without Shift, as in the Finder.
    @ObservationIgnored private var anchor: String?

    var isActive: Bool {
        ids != nil
    }
    var isEmpty: Bool {
        ids?.isEmpty != false
    }
    var isAllSelected: Bool {
        guard let ids else { return false }
        return displayedIDs.allSatisfy(ids.contains)
    }
    var sprites: [SpriteSet] {
        (ids ?? []).compactMap(SpriteSet.withID)
    }

    /// A cell was clicked. Returns `false` when the click should open the sprite instead: the grid is
    /// browsing and neither ⌘ nor Shift is held, which in the Finder would start a selection.
    func click(_ id: String) -> Bool {
        guard ids != nil else {
            guard addsToSelection || extendsRange else { return false }
            ids = [id]
            anchor = id
            return true
        }
        if extendsRange, let anchor,
           let start = displayedIDs.firstIndex(of: anchor),
           let end = displayedIDs.firstIndex(of: id) {
            ids?.formUnion(displayedIDs[min(start, end)...max(start, end)])
        } else {
            toggle(id)
            anchor = id
        }
        return true
    }

    func selectAll() {
        ids = Set(displayedIDs)
    }

    func deselectAll() {
        ids = []
    }

    private func toggle(_ id: String) {
        guard var ids else { return }
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        self.ids = ids
    }

}

/// Everything the user can do to a sprite, wherever it is shown.
///
/// The detail screen's Add to… menu, a grid cell's context menu and a selection's toolbar menu all
/// present these same buttons, calling the same model methods — so none of the three carries its own
/// copy of an action and a sprite behaves the same in all of them. Every button takes the whole
/// list, which is one sprite from a context menu and the selection from the toolbar.
struct SpriteActions: View {

    let sprites: [SpriteSet]
    /// Asks the owning view to present its exporter: a menu cannot put a sheet on screen itself.
    let export: ([SpriteSet]) -> Void

    /// Absent in previews and in the fullscreen sprite window, which has no navigation to push onto.
    @Environment(MainWindowState.self) private var window: MainWindowState?

    var body: some View {
        SpriteCollectionButtons(sprites: sprites)

        Section {
            Button("Export PNG…", systemImage: "square.and.arrow.down") {
                export(sprites)
            }

            if sprites.count == 1, let sprite = sprites.first {
                Button("Show Artist", systemImage: "person") {
                    window?.path.append(sprite.artist)
                }
                .disabled(window == nil)

                #if DEBUG
                Button("Copy Sprite ID", systemImage: "number.square") {
                    Clipboard.copy(sprite.id)
                }
                #endif
            }
        }
    }

}

/// Add-to / remove-from buttons for the two collections the user owns, and for a single sprite,
/// My Palettes — which saves the sprite's colors as a palette rather than the sprite itself.
struct SpriteCollectionButtons: View {

    let sprites: [SpriteSet]

    @Bindable private var myCollection = SpriteCollection.myCollection
    @Bindable private var stickersCollection = SpriteCollection.stickersCollection
    private let paletteLibrary = PaletteLibrary.shared

    init(sprites: [SpriteSet]) {
        self.sprites = sprites
    }

    private var ids: Set<String> {
        Set(sprites.map(\.id))
    }

    var body: some View {
        button(for: myCollection, title: "My Collection")
        if SpriteCollection.stickersAreAvailable {
            button(for: stickersCollection, title: "Stickers")
        }
        // Artwork has too many colors to be a palette, so it doesn't offer one.
        if sprites.count == 1, let sprite = sprites.first, paletteLibrary.colors(of: sprite) != nil {
            Button {
                paletteLibrary.togglePalette(of: sprite)
            } label: {
                if paletteLibrary.palette(of: sprite) != nil {
                    Label("My Palettes", systemImage: "checkmark")
                } else {
                    Text("My Palettes")
                }
            }
        }
    }

    private func button(for collection: SpriteCollection, title: LocalizedStringKey) -> some View {
        Button {
            collection.toggle(ids)
        } label: {
            if collection.contains(ids) {
                Label(title, systemImage: "checkmark")
            } else {
                Text(title)
            }
        }
    }

}

extension View {

    /// Writes sprites out as PNGs — one file per tile and variant — whenever the binding is filled.
    ///
    /// The actions above run inside menus, which cannot present a sheet, so the view that offers
    /// them owns the exporter and hands them this binding to fill. An empty list keeps the exporter
    /// out of the way, and keeps it from re-encoding every sprite on screen on each pass of `body`.
    func spriteExporter(_ sprites: Binding<[SpriteSet]>) -> some View {
        fileExporter(
            isPresented: Binding(get: { !sprites.wrappedValue.isEmpty },
                                 set: { if !$0 { sprites.wrappedValue = [] } }),
            documents: sprites.wrappedValue.flatMap({ $0.exportImageDocuments() }),
            contentType: .png
        ) { _ in
            sprites.wrappedValue = []
        }
    }

    /// The Select / Done pair, and the menu of actions a selection can run, for a screen showing a
    /// grid of sprites. Pairs with ``spriteExporter(_:)``, which it attaches for the same screen.
    ///
    /// `sprites` is what the grid currently shows, in order: Select All takes it, and a Shift-click
    /// selects along it. The screen is also the drag container, so dragging a selected cell carries
    /// the whole selection out rather than that one sprite.
    func spriteSelectionToolbar(_ selection: SpriteSelection, displaying sprites: [SpriteSet], exporting: Binding<[SpriteSet]>) -> some View {
        modifier(SpriteSelectionToolbar(selection: selection, sprites: sprites, exporting: exporting))
    }

}

private struct SpriteSelectionToolbar: ViewModifier {

    let selection: SpriteSelection
    let sprites: [SpriteSet]
    @Binding var exporting: [SpriteSet]

    func body(content: Content) -> some View {
        content
            .dragsSelection(selection)
            #if os(macOS)
            .onModifierKeysChanged(mask: [.shift, .command]) { _, keys in
                selection.extendsRange = keys.contains(.shift)
                selection.addsToSelection = keys.contains(.command)
            }
            #endif
            .focusedSceneValue(\.spriteSelection, selection.isActive ? selection : nil)
            .onChange(of: sprites, initial: true) { _, sprites in
                selection.displayedIDs = sprites.map(\.id)
            }
            .toolbar {
                if selection.isActive {
                    ToolbarItem(placement: .primaryAction) {
                        Menu("Selected Sprites", systemImage: "ellipsis.circle") {
                            Section {
                                Button("Select All", systemImage: "checkmark.circle") {
                                    selection.selectAll()
                                }
                                .disabled(selection.isAllSelected)

                                Button("Deselect All", systemImage: "circle") {
                                    selection.deselectAll()
                                }
                                .disabled(selection.isEmpty)
                            }

                            SpriteActions(sprites: selection.sprites) { exporting = $0 }
                                .disabled(selection.isEmpty)
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            selection.ids = nil
                        }
                    }
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Select", systemImage: "checkmark.circle") {
                            selection.ids = []
                        }
                    }
                }
            }
            .spriteExporter($exporting)
    }

}

extension View {

    /// Makes a grid the drag container its selectable cells hand their IDs to, so a drag that starts
    /// on a selected sprite carries every selected sprite and one on any other carries just itself.
    /// Before OS 27 there is no container, and each cell drags only its own sprite.
    @ViewBuilder
    fileprivate func dragsSelection(_ selection: SpriteSelection) -> some View {
        if #available(iOS 27, macOS 26, visionOS 27, *) {
            dragContainer(for: SpriteTransfer.self) { ids in
                ids.compactMap(SpriteSet.withID).map(\.transfer)
            }
            .dragContainerSelection(Array(selection.ids ?? []))
        } else {
            self
        }
    }

    /// A grid cell's drag: its ID, for the enclosing ``dragsSelection(_:)`` to resolve, when the cell
    /// is selectable; otherwise its own PNG.
    @ViewBuilder
    func draggable(_ sprite: SpriteSet, inContainer: Bool) -> some View {
        if inContainer, #available(iOS 27, macOS 26, visionOS 27, *) {
            draggable(containerItemID: sprite.id)
        } else {
            draggable(sprite.transfer)
        }
    }

}

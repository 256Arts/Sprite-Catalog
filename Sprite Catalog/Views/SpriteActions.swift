import SwiftUI

/// A grid's multi-selection.
///
/// `ids` is `nil` while the grid is browsing, so a cell opens its sprite; turning selection on makes
/// it a set — possibly empty — and a cell toggles its sprite instead. The sprite actions then run
/// against everything selected, so Export and Add to… work on a batch rather than one at a time.
@Observable
final class SpriteSelection {

    var ids: Set<String>?

    var isActive: Bool {
        ids != nil
    }
    var isEmpty: Bool {
        ids?.isEmpty != false
    }
    var sprites: [SpriteSet] {
        (ids ?? []).compactMap(SpriteSet.withID)
    }

    func toggle(_ id: String) {
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

/// Add-to / remove-from buttons for the two collections the user owns.
struct SpriteCollectionButtons: View {

    let sprites: [SpriteSet]

    @Bindable private var myCollection = SpriteCollection.myCollection
    @Bindable private var stickersCollection = SpriteCollection.stickersCollection

    private var ids: Set<String> {
        Set(sprites.map(\.id))
    }

    var body: some View {
        button(for: myCollection, title: "My Collection")
        if SpriteCollection.stickersAreAvailable {
            button(for: stickersCollection, title: "Stickers")
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
    func spriteSelectionToolbar(_ selection: SpriteSelection, exporting: Binding<[SpriteSet]>) -> some View {
        modifier(SpriteSelectionToolbar(selection: selection, exporting: exporting))
    }

}

private struct SpriteSelectionToolbar: ViewModifier {

    let selection: SpriteSelection
    @Binding var exporting: [SpriteSet]

    func body(content: Content) -> some View {
        content
            .toolbar {
                if selection.isActive {
                    ToolbarItem(placement: .primaryAction) {
                        Menu("Selected Sprites", systemImage: "ellipsis.circle") {
                            SpriteActions(sprites: selection.sprites) { exporting = $0 }
                        }
                        .disabled(selection.isEmpty)
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

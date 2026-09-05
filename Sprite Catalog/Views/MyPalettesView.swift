import PaletteKit
import SwiftUI

/// The user's saved palettes: create one (generated, imported from a file, or from scratch), or
/// delete one. The create flow is PaletteKit's `NewPaletteView`, so the app has no color UI of its
/// own — it only owns the list and the file behind it.
struct MyPalettesView: View {

    @State private var library = PaletteLibrary.shared
    @State private var selection: Palette?
    @State private var isCreating = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(library.palettes) { palette in
                    Button {
                        selection = palette
                    } label: {
                        PaletteRow(palette, isSelected: palette.id == selection?.id)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            library.delete(palette)
                        }
                    }
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            library.delete(palette)
                        }
                    }
                }
            }
            .swipeActionsContainerIfAvailable()
            .padding()
        }
        .overlay {
            if library.palettes.isEmpty {
                ContentUnavailableView {
                    Label("No Palettes", systemImage: "swatchpalette")
                } description: {
                    Text("Palettes you create or import appear here.")
                } actions: {
                    Button("New Palette") { isCreating = true }
                }
            }
        }
        .navigationTitle("My Palettes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Palette", systemImage: "plus") {
                    isCreating = true
                }
            }
        }
        .sheet(isPresented: $isCreating) {
            NavigationStack {
                // Names it, generates or imports its colors, previews it — then hands it back.
                NewPaletteView { palette in
                    library.add(palette)
                }
            }
        }
    }
}

private extension View {

    /// `swipeActions` outside a `List` need the container to opt in, which is OS 27 and up.
    /// Below that the rows' context menus are the way to delete.
    @ViewBuilder
    func swipeActionsContainerIfAvailable() -> some View {
        if #available(iOS 27.0, macOS 27.0, visionOS 27.0, *) {
            swipeActionsContainer()
        } else {
            self
        }
    }

}

#Preview {
    NavigationStack {
        MyPalettesView()
    }
}

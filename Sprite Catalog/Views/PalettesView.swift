import PaletteKit
import SwiftUI

/// Browses the premade palettes PaletteKit ships — the same catalog Sprite Pencil paints with.
///
/// Sprite Catalog has no editor, so a palette here is something to look at and pick, not to draw
/// with. The rows, the strip, and the color realization all come from the package; the app only
/// says which palettes and holds the selection.
struct PalettesView: View {

    @State private var selection: Palette?

    var body: some View {
        // No palettes passed means the premade catalog, realized in the environment's color space.
        PaletteBrowser(selection: $selection)
            .navigationTitle("Palettes")
    }
}

#Preview {
    NavigationStack {
        PalettesView()
    }
}

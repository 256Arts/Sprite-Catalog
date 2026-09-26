import Foundation
import PaletteKit

/// The user's saved palettes, persisted as one JSON file in the documents directory — the same
/// plain-Codable storage `SpriteCollection` uses for My Collection.
///
/// `PaletteKit.Palette` is already `Codable`/`Identifiable`, so there's no app-side palette model:
/// this is only the list, the file, and the two edits a catalog needs (add, delete).
@MainActor @Observable
final class PaletteLibrary {

    static let shared = PaletteLibrary()

    static let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Palettes").appendingPathExtension("json")

    private(set) var palettes: [Palette]

    /// A screenshot run gets a fresh library that never reaches the file, so the seeded palettes are
    /// the only ones shown and the real ones on the machine are neither photographed nor overwritten.
    private let isEphemeral = ScreenshotMode.isActive

    private init() {
        palettes = isEphemeral
            ? []
            : (try? JSONDecoder().decode([Palette].self, from: Data(contentsOf: Self.fileURL))) ?? []
    }

    /// Saves a palette, uniquifying its name ("My Palette 2") so two same-named saves stay tellable
    /// apart in the list. Identity is the palette's own `UUID`, so a duplicate name is never fatal.
    func add(_ palette: Palette) {
        var palette = palette
        palette.name = uniqueName(for: palette.name)
        palettes.append(palette)
        save()
    }

    func delete(_ palette: Palette) {
        palettes.removeAll { $0.id == palette.id }
        save()
    }

    /// A sprite's colors, or `nil` for one with too many to be a palette. Cached, since the
    /// sprite menus that ask are rebuilt far more often than a sprite's pixels change.
    func colors(of sprite: SpriteSet) -> [PaletteColor]? {
        if let cached = spriteColors[sprite.id] { return cached }
        let colors = sprite.paletteColors()
        spriteColors[sprite.id] = .some(colors)
        return colors
    }
    @ObservationIgnored private var spriteColors: [String: [PaletteColor]?] = [:]

    /// The saved palette holding exactly this sprite's colors, if there is one — found by its colors
    /// rather than its name, which the user may have saved over or which ``add(_:)`` uniquified.
    func palette(of sprite: SpriteSet) -> Palette? {
        guard let colors = colors(of: sprite) else { return nil }
        // Compared as 8-bit sRGB, which survives the JSON round trip that a palette's fractions may not.
        func pixels(_ colors: [PaletteColor]) -> [SRGB8] { colors.map { $0.srgb8(colorSpace: .okLch) } }
        let target = pixels(colors)
        return palettes.first { pixels($0.colors) == target }
    }

    /// Saves the sprite's colors as a palette named after it, or removes that palette if it's saved —
    /// the same toggle the sprite menus use for collections.
    func togglePalette(of sprite: SpriteSet) {
        if let saved = palette(of: sprite) {
            delete(saved)
        } else if let colors = colors(of: sprite) {
            add(Palette(name: sprite.name, colors: colors, source: .imported))
        }
    }

    private func save() {
        guard !isEphemeral else { return }
        do {
            try JSONEncoder().encode(palettes).write(to: Self.fileURL, options: .atomic)
        } catch {
            print("Failed to save palettes: \(error)")
        }
    }

    private func uniqueName(for name: String) -> String {
        let taken = Set(palettes.map(\.name))
        guard taken.contains(name) else { return name }
        var counter = 2
        while taken.contains("\(name) \(counter)") { counter += 1 }
        return "\(name) \(counter)"
    }
}

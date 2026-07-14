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

    private init() {
        palettes = (try? JSONDecoder().decode([Palette].self, from: Data(contentsOf: Self.fileURL))) ?? []
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

    private func save() {
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

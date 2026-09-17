import SwiftUI

/// The app's menu bar.
///
/// Every item routes through the state its on-screen counterpart already uses — the window's
/// ``MainWindowState`` for the sheets, the focused sprite's ID for the sprite actions — so a menu
/// item never carries a second copy of an action. Items dim when nothing is focused to act on.
///
/// The file commands ship on every platform, because iPadOS shows a menu bar too; the
/// rest is desktop-only, either because the action has no touch equivalent (a sprite has no window
/// of its own on iPhone) or because the menu it belongs to does not exist there.
struct SpriteCatalogCommands: Commands {

    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #endif

    @FocusedValue(\.mainWindow) private var window
    @FocusedValue(\.spriteID) private var spriteID
    @FocusedValue(\.spriteSelection) private var selection

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Import Sprites…", systemImage: "plus") {
                window?.showingImport = true
            }
            .keyboardShortcut("i")
            .disabled(window == nil)

            Button("Cut Spritesheet…", systemImage: "scissors") {
                window?.showingCutter = true
            }
            .keyboardShortcut("k", modifiers: [.command, .shift])
            .disabled(window == nil)
        }

        // A grid's selection is its own, not text's, so it gets its own pair rather than taking over
        // the Edit menu's Select All — which the search field still needs while the grid browses.
        // The pair exists only while a grid is selecting, and sits ahead of that item so ⌘A reaches
        // it first.
        CommandGroup(before: .pasteboard) {
            if let selection {
                Section {
                    Button("Select All Sprites") {
                        selection.selectAll()
                    }
                    .keyboardShortcut("a")

                    Button("Deselect All Sprites") {
                        selection.deselectAll()
                    }
                    .keyboardShortcut("a", modifiers: [.command, .shift])
                }
            }
        }

        #if os(macOS)
        CommandMenu("Sprite") {
            Button("Open in Fullscreen", systemImage: "arrow.up.left.and.arrow.down.right") {
                if let spriteID {
                    openWindow(value: spriteID)
                }
            }
            .keyboardShortcut("f", modifiers: [.command, .option])
            .disabled(spriteID == nil)

            #if DEBUG
            Button("Copy Sprite ID", systemImage: "number.square") {
                if let spriteID {
                    Clipboard.copy(spriteID)
                }
            }
            .keyboardShortcut("c", modifiers: [.command, .control])
            .disabled(spriteID == nil)
            #endif
        }

        CommandGroup(replacing: .help) {
            HelpLinks()
        }
        #endif
    }

}

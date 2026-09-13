import SwiftUI

/// The app's menu bar.
///
/// Every item routes through the state its on-screen counterpart already uses — the window's
/// ``MainWindowState`` for the sheets, the focused sprite's ID for the sprite actions — so a menu
/// item never carries a second copy of an action. Items dim when nothing is focused to act on.
///
/// The file commands ship on every platform, because iPadOS and Catalyst show a menu bar too; the
/// rest is desktop-only, either because the action has no touch equivalent (a sprite has no window
/// of its own on iPhone) or because the menu it belongs to does not exist there.
struct SpriteCatalogCommands: Commands {

    #if os(macOS) || targetEnvironment(macCatalyst)
    @Environment(\.openWindow) private var openWindow
    #endif

    @FocusedValue(\.mainWindow) private var window
    @FocusedValue(\.spriteID) private var spriteID

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

        #if os(macOS) || targetEnvironment(macCatalyst)
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

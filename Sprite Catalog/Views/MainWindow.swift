import SwiftUI

/// The presentation and navigation state of one window, shared with everything outside the view
/// that owns it.
///
/// A `Commands` builder sits outside the view hierarchy, so it cannot reach the `@State` behind a
/// toolbar button's sheet. Hoisting those flags into one object per window — published as a focused
/// scene value — lets a menu item and its toolbar button flip the same flag instead of each owning
/// a copy. It is a reference, so SwiftUI compares the focus value by identity and it stays stable.
///
/// ``MainWindow`` also puts it in the environment, which is how a view deep in the detail stack —
/// a grid cell's Show Artist, say — pushes a screen without threading a path binding down to it.
@Observable
final class MainWindowState {

    var showingCutter = false
    var showingImport = false
    /// Imported sprites waiting on the user to confirm their deletion. A menu cannot present the
    /// confirmation itself, so every Delete button fills this and ``MainWindow`` asks.
    var deleting: [SpriteSet] = []
    /// What the detail column has pushed on top of the screen the sidebar selected.
    var path = NavigationPath()

}

extension FocusedValues {

    /// The frontmost catalog window, for menu items that present one of its sheets.
    @Entry var mainWindow: MainWindowState?

    /// The sprite the frontmost window is showing, or `nil` when it is not on a detail screen.
    /// Plain data rather than an action, so the focus value compares cleanly.
    @Entry var spriteID: String?

    /// The frontmost grid's selection while it is selecting, for Select All and Deselect All; `nil`
    /// while it browses. Published only when active because a menu does not observe the object, so
    /// it is the value turning up that enables the items.
    @Entry var spriteSelection: SpriteSelection?

}

/// The catalog's main window: a sidebar, the screen it selects, and the sheets its toolbar and the
/// menu bar both present.
struct MainWindow: View {

    @Bindable var cloudController: CloudController = .shared

    @State private var state = MainWindowState()
    @State private var selectedScreen: MainScreen? = .browse
    @State private var fontPreviewMode: FamilyDetailView.PreviewMode = .sample
    @State private var fontTestString = Sprite_CatalogApp.defaultFontTestString
    @State private var showingEvent = false
    /// The sprite the detail screen on top is showing, so deleting it can step back off it.
    @FocusedValue(\.spriteID) private var shownSpriteID

    var body: some View {
        NavigationSplitView {
            Sidebar(selectedScreen: $selectedScreen)
                .sidebarColumnWidth()
        } detail: {
            NavigationStack(path: $state.path) {
                Group {
                    switch selectedScreen {
                    case .browse:
                        BrowseView()
                    case .fonts:
                        FontsGridView()
                    case .palettes:
                        PalettesView()
                    case .myPalettes:
                        MyPalettesView()
                    case .imports:
                        if let collection = cloudController.spriteCollection {
                            ImportedCollectionSpritesGridView(userCollection: collection)
                        } else {
                            ProgressView()
                        }
                    case .category(let tag):
                        SpritesGridView(title: String(localized: tag.title), sprites: SpriteSet.allSprites.filter({ $0.tags.contains(tag) }))
                    case .collection(let collection):
                        UserCollectionSpritesGridView(userCollection: collection)
                    case nil:
                        EmptyView()
                    }
                }
                .navigationDestination(for: String.self) { spriteID in
                    if let sprite = SpriteSet.withID(spriteID) {
                        SpriteDetailView(sprite: sprite)
                    }
                }
                .navigationDestination(for: SpriteCollection.self) { collection in
                    CollectionView(collection: collection, webpageURL: nil)
                }
                .navigationDestination(for: Artist.self) { artist in
                    CollectionView(collection: SpriteCollection(artist: artist), webpageURL: artist.url)
                }
                .navigationDestination(for: FontFamily.self) { family in
                    FamilyDetailView(previewMode: $fontPreviewMode, customString: $fontTestString, family: family)
                }
            }
        }
        .environment(state)
        .focusedSceneValue(\.mainWindow, state)
        // Both sheets live here rather than on the screen that opens them, so the menu bar can
        // present either one from whatever screen the window happens to be showing.
        .sheet(isPresented: $state.showingCutter) {
            NavigationStack {
                CutterView()
            }
        }
        .sheet(isPresented: $state.showingImport) {
            ImportSpritesView(importer: .init(debugMode: false))
        }
        .confirmationDialog(
            state.deleting.count == 1 ? "Delete “\(state.deleting[0].name)”?" : "Delete \(state.deleting.count) Sprites?",
            isPresented: Binding(get: { !state.deleting.isEmpty }, set: { if !$0 { state.deleting = [] } }),
            titleVisibility: .visible
        ) {
            Button(state.deleting.count == 1 ? "Delete Sprite" : "Delete Sprites", role: .destructive) {
                if let shownSpriteID, state.deleting.contains(where: { $0.id == shownSpriteID }), !state.path.isEmpty {
                    state.path.removeLast()
                }
                cloudController.delete(state.deleting)
                state.deleting = []
            }
        } message: {
            Text(state.deleting.count == 1 ? "This sprite will be deleted from iCloud on all your devices." : "These sprites will be deleted from iCloud on all your devices.")
        }
        .alert("Event Intro", isPresented: $showingEvent) {
            Button("OK", role: .close) { }
        } message: {
            Text("Now you can celebrate by tapping the sprite collection from the \"Browse\" tab, and trying out the new features!")
        }
        .onChange(of: selectedScreen) {
            // The sidebar picked a new root, so whatever was pushed on the old one is stale.
            state.path = NavigationPath()
        }
        .onOpenURL { url in
            if url.path().contains("spritecatalog/appstoreevent") {
                showingEvent = true
            }
        }
    }

}

#Preview {
    MainWindow()
}

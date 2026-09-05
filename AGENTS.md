# AGENTS.md

## Overview

Sprite Catalog is a SwiftUI app that browses a curated catalog of pixel-art sprites and pixel fonts, lets users import their own sprites (synced via iCloud), cut spritesheets into individual sprites, and export sprites as iMessage stickers. It targets iOS/iPadOS, Mac Catalyst, and visionOS.

## Build & Run

This is an Xcode project (`Sprite Catalog.xcodeproj`). Build and run from Xcode, or use `xcodebuild` with the scheme. The only tests are the App Store screenshot walk (`Sprite CatalogUITests`, run by the `Screenshots` scheme); there are no unit tests.

It depends on one Swift package, **PaletteKit** (`https://github.com/256Arts/PaletteKit`, a remote package reference).

## Targets

- **Sprite Catalog** — main app (SwiftUI). Entry point: `Sprite Catalog/Sprite_CatalogApp.swift`.
- **Sprite Catalog Messages MessagesExtension** — iMessage sticker browser (`Messages/`).

`Shared/` holds code compiled into multiple targets (e.g. `MessagesAppGroupID.swift`).

## Architecture

**Catalog data is JSON-driven.** Every built-in sprite is decoded from the bundled `Sprite Catalog/ZCatalog.json` into `SpriteSet.allSprites` (a static, lazily-loaded array). This array is the single source of truth — views filter it by tag/ID, and lookups happen by matching the sprite's 6-character random `id`. In DEBUG builds, `SpriteSet.allSprites` has a commented-out block for bulk-editing and re-printing the catalog JSON; this is the workflow for mutating the catalog.

**`SpriteSet` model** (`Models/SpriteSet.swift`) is the core type. A sprite has one or more `Tile`s; each tile has `RandomVariant`s (weighted alternatives, optionally multi-frame animations), `ConnectedEdges` (for autotiling), and a `facing` direction. `Tag` and `Layer` enums drive categorization and rendering order.

**User-imported sprites use a `c-` ID prefix.** Built-in sprites resolve their PNG from the app bundle; any `imageName` starting with `c-` resolves to a file in the iCloud ubiquity container instead (`RandomVariant.url` / `CloudController.userSpritesDirectoryURL`). This prefix convention is how imported and built-in sprites coexist in the same model and code paths.

**`CloudController.shared`** (`Controllers/CloudController.swift`) syncs user-imported sprites via `NSMetadataQuery` over the iCloud ubiquitous container and exposes them as a `SpriteCollection`. `SpriteImporter` (`Controllers/SpriteImporter.swift`) handles the import-and-tag flow, generating new `c-` IDs and writing PNGs + a `Collection.json`.

**`SpriteCollection`** (`Models/SpriteCollection.swift`) is a named set of sprite IDs. Featured/seasonal/gaming collections are hardcoded here (seasonal ones are injected by calendar month). `My Collection` and the iMessage stickers collection are persisted as JSON in the documents directory.

**Navigation** is a `NavigationSplitView` in `Sprite_CatalogApp`: `Sidebar` selects a `MainScreen` enum case (`Models/MainScreen.swift`), and `navigationDestination` handlers route by `SpriteSet`/`SpriteCollection`/`Artist`/`FontFamily`/sprite-ID-string. Most observable state uses the `@Observable` macro with shared singletons.

**Stickers / iMessage extension.** `SpriteCollection.saveStickers()` writes selected sprite PNGs into the app group container `group.com.jaydenirwin.spritecatalog.messages`; the extension's `StickerBrowserViewController` reads that container and rescales each sprite to a sticker (nearest-neighbor, no interpolation, to keep pixels crisp). The shared app group ID lives in `Shared/MessagesAppGroupID.swift`.

**Fonts.** `FontProvider.shared` (`Controllers/FontProvider.swift`) installs pixel-font families and tracks which are installed; `FontFamily` (`Models/FontFamily.swift`) models the bundled fonts with licence/tag metadata and reads each face's PostScript name out of its file. Installing means a persistent `CTFontManager` registration, but the platforms differ: iOS registers the bundle's own files and lists them back with `CTFontManagerCopyRegisteredFontDescriptors`, which does not exist on macOS — so macOS registers copies it keeps in Application Support and reads the state back per file with `CTFontManagerGetScopeForURL`. The bundled fonts themselves are declared twice in `Info.plist`: `UIAppFonts` for iOS, `ATSApplicationFontsPath` for macOS.

**Palettes come from PaletteKit.** The app owns no color code and no palette UI. `PalettesView` browses the package's premade catalog (`PaletteBrowser`); `MyPalettesView` lists the user's saved palettes and presents the package's `NewPaletteView` to create one (generated preset, imported .gpl/.clr/palette-image file, or from scratch). `PaletteLibrary` (`Models/PaletteLibrary.swift`) is the only app-side piece: an `@Observable` singleton persisting `[PaletteKit.Palette]` as `Palettes.json` in the documents directory — the same Codable-JSON-in-Documents storage `SpriteCollection` uses. Unlike imported sprites, saved palettes are **not** iCloud-synced.

**Website generation.** `Scripts/GenerateWebsite.swift` builds the public website's category pages from `ZCatalog.json` without running the app: `swift Scripts/GenerateWebsite.swift [output dir] [--no-images]`. Default output is `Website/` (gitignored) — `<slug>/index.html` per category plus `sprite/<imageName>.png` copied out of the asset catalog. The script re-declares a minimal `CatalogSprite` because `SpriteSet` pulls in UIKit/SwiftUI/`CloudController`; if the catalog JSON schema changes, update both.

**App Store screenshots** are automated: `Scripts/screenshots.sh [iphone|ipad|mac|vision]` (add `--upload` to send them to App Store Connect) wraps the shared runner in `Repos/Scripts/screenshots`, which owns simulator boot, the 9:41 status bar, and the Mac window capture. Shots land in `Raw Assets/Screenshots/` as `Phone 6.9 1.png`, `Pad 13 1.png`, `Mac 1.png`, `Vision 1.png` — a symlink out to iCloud, so nothing lands in the repo, beside the `Old (Manual)/` archive of the hand-made ones. The app's part is `.screenshots.conf`, `Utilities/ScreenshotMode.swift` (in-memory demo seeding, switched on by the `-screenshotMode` launch argument), and `Sprite CatalogUITests/ScreenshotTests.swift` (the walk). Seeding writes nothing to disk, so a Mac run leaves the real library alone. The app is sandboxed, so the runner cannot clear its saved window frame — `ScreenshotMode.pinWindowLayout()` and `screenshotModeSidebarWidth()` pin the layout instead.

**Spritesheet cutting.** `Cutter` (`Models/Cutter.swift`) slices an image into a grid of sprites given a pixel size and spacing. It is exposed to Shortcuts via the `CutSprites` App Intent (`App Intent/CutSprites.swift`).

## Conventions

- Cross-platform image code branches on `#if canImport(UIKit)` vs AppKit. Desktop-vs-touch differences branch on `#if os(macOS) || targetEnvironment(macCatalyst)`, and the styling both Macs share lives in `Utilities/PlatformStyle.swift` (`cellButtonStyle()`, `navigationTitleDisplayMode(_:)`, `keepsMenuOpen()`, `Color.groupedBackground` and friends). A bare `#if targetEnvironment(macCatalyst)` now means Catalyst-only behaviour, such as the `CloudController.fetchUserSprites` workaround.
- Pixel art must render with nearest-neighbor scaling — set `interpolationQuality = .none` when drawing sprites.
- `Debug/` contains developer-only views (catalog HTML generation, promo grids, reorder tooling) not shipped to users.

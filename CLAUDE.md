# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Sprite Catalog is a SwiftUI app that browses a curated catalog of pixel-art sprites and pixel fonts, lets users import their own sprites (synced via iCloud), cut spritesheets into individual sprites, and export sprites as iMessage stickers. It targets iOS/iPadOS, Mac Catalyst, and visionOS.

## Build & Run

This is an Xcode project (`Sprite Catalog.xcodeproj`) with no external package dependencies. Build and run from Xcode, or use `xcodebuild` with the scheme. There is no test target.

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

**Fonts.** `FontProvider.shared` tracks registered pixel-font families; `FontFamily` (`Models/FontFamily.swift`) models bundled fonts with licence/tag metadata.

**Spritesheet cutting.** `Cutter` (`Models/Cutter.swift`) slices an image into a grid of sprites given a pixel size and spacing. It is exposed to Shortcuts via the `CutSprites` App Intent (`App Intent/CutSprites.swift`).

## Conventions

- Cross-platform image code branches on `#if canImport(UIKit)` vs AppKit; Mac Catalyst-specific workarounds use `#if targetEnvironment(macCatalyst)` (see `CloudController.fetchUserSprites`).
- Pixel art must render with nearest-neighbor scaling — set `interpolationQuality = .none` when drawing sprites.
- `Debug/` contains developer-only views (catalog HTML generation, promo grids, reorder tooling) not shipped to users.

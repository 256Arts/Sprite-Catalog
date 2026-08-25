#!/usr/bin/env swift

// Generates the Sprite Catalog website's category pages straight from ZCatalog.json,
// so adding sprites no longer requires running the app and exporting each page by hand.
//
//   swift Scripts/GenerateWebsite.swift [output directory] [--no-images]
//
// Writes <output>/<slug>/index.html for every category, plus <output>/sprite/<name>.png
// pulled from the asset catalog (skip with --no-images).

import Foundation

// MARK: - Catalog

/// Mirrors only the ZCatalog.json fields the website needs. The app's `SpriteSet` can't be
/// reused here because it depends on UIKit, SwiftUI and `CloudController`.
struct CatalogSprite: Decodable {

    struct Artist: Decodable {
        let name: String
    }
    struct Tile: Decodable {
        struct Variant: Decodable {
            let imageName: String
            let frameCount: Int?
        }
        let variants: [Variant]
    }

    let id: String
    let name: String
    let artist: Artist
    let licence: String
    let tags: Set<String>
    let tiles: [Tile]

    var primaryVariant: Tile.Variant? {
        tiles.first?.variants.first
    }
    var isAnimated: Bool {
        (primaryVariant?.frameCount ?? 1) != 1
    }
}

/// A website category, in sidebar order. `name` matches the `SpriteSet.Tag` raw value in ZCatalog.json.
struct Category {
    let name: String
    let slug: String
    let icon: String
}

let categories: [Category] = [
    Category(name: "People & Animals", slug: "peopleandanimals", icon: "animals"),
    Category(name: "Food", slug: "food", icon: "food"),
    Category(name: "Weapons & Tools", slug: "tools", icon: "tools"),
    Category(name: "Clothing", slug: "clothing", icon: "clothing"),
    Category(name: "Treasure", slug: "treasure", icon: "treasure"),
    Category(name: "Misc. Items", slug: "items", icon: "items"),
    Category(name: "Nature", slug: "nature", icon: "nature"),
    Category(name: "Objects", slug: "objects", icon: "objects"),
    Category(name: "Effects", slug: "effects", icon: "effects"),
    Category(name: "Interface", slug: "interface", icon: "interface"),
    Category(name: "Tiles", slug: "tiles", icon: "tiles"),
    Category(name: "Artwork", slug: "artwork", icon: "artwork")
]

// MARK: - Escaping

extension String {

    /// Escapes for use inside an HTML attribute value or text node.
    var htmlEscaped: String {
        var result = replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        return result
    }

    /// Escapes for use as a single-quoted JavaScript string inside an HTML attribute.
    /// Names like "Mac N' Cheese" and artists like "Alex's Assets" would otherwise break the handler.
    var jsInAttributeEscaped: String {
        var result = replacingOccurrences(of: "\\", with: "\\\\")
        result = result.replacingOccurrences(of: "'", with: "\\'")
        return result.htmlEscaped
    }
}

// MARK: - Page

func spritesHTML(for category: Category, sprites: [CatalogSprite]) -> String {
    var html = ""
    for sprite in sprites {
        guard let variant = sprite.primaryVariant else { continue }
        html.append(
            """
            <a title="\(sprite.name.htmlEscaped) (\(sprite.licence.htmlEscaped))" onclick="showSprite('\(sprite.name.jsInAttributeEscaped)', '\(sprite.id.jsInAttributeEscaped)', '\(sprite.artist.name.jsInAttributeEscaped)', '\(sprite.licence.jsInAttributeEscaped)')">
                <img src="/sprite/\(variant.imageName.htmlEscaped).png" loading="lazy" alt="\(sprite.name.htmlEscaped)">
            </a>

            """)
    }
    return html
}

func sidebarHTML(selected: Category) -> String {
    let indent = String(repeating: " ", count: 16)
    return categories.map { category in
        [
            "\(indent)<a href=\"/\(category.slug)/\"\(category.name == selected.name ? " class=\"selected\"" : "")>",
            "\(indent)    <img src=\"/global/\(category.icon).png\">",
            "\(indent)    \(category.name.htmlEscaped)",
            "\(indent)</a>"
        ].joined(separator: "\n")
    }.joined(separator: "\n")
}

func pageHTML(for category: Category, sprites: [CatalogSprite]) -> String {
    """
    <html>
        <head>
            <link rel="shortcut icon" href="/global/favicon.ico" type="image/x-icon">
            <link rel="apple-touch-icon" href="/apple-touch-icon.png">
            <link rel="stylesheet" href="/global/style.css">
            <link rel="stylesheet" href="page.css">
            <title>\(category.name.htmlEscaped) - Sprite Catalog</title>
            <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
            <meta name="theme-color" content="#f7f7f7" media="(prefers-color-scheme: light)">
            <meta name="theme-color" content="#111113" media="(prefers-color-scheme: dark)">
            <meta name="og:image" content="/global/opengraph.png">
            <meta name="apple-mobile-web-app-capable" content="yes">
            <meta name="keywords" content="\(category.name.htmlEscaped), game, developer, iphone, ipad, mac, iOS, iPadOS, macOS, sprite, pixel, art, pencil, app">
            <meta name="description" content="Collections of \(category.name.htmlEscaped) downloadable (many free) pixel art assets.">
            <meta name="apple-itunes-app" content="app-id=1560692872">

            <script async src="https://www.googletagmanager.com/gtag/js?id=G-RBM60EGQDR"></script>
            <script>
              window.dataLayer = window.dataLayer || [];
              function gtag(){dataLayer.push(arguments);}
              gtag('js', new Date());
              gtag('config', 'G-RBM60EGQDR');
            </script>
        </head>
        <body ontouchstart>
            <section class="split">
                <section class="sidebar desktop-only">
                    <header>
                        <a href="/">
                            <h2>Sprite Catalog</h2>
                        </a>
                    </header>
    \(sidebarHTML(selected: category))
                    <a title="Not Available on Web" class="disabled">
                        <picture>
                            <source srcset="/global/fonts_dark.png" media="(prefers-color-scheme: dark)">
                            <img src="/global/fonts.png">
                        </picture>
                        Fonts
                    </a>
                    <h4>Library</h4>
                    <a title="Not Available on Web" class="disabled">
                        <img src="/global/folder.png">
                        My Collection
                    </a>
                    <div class="footer">
                        <a href="https://form.jotform.com/211994359527266" target="_blank">Submit Your Sprites</a>
                    </div>
                </section>
                <section class="grid \(category.slug == "artwork" ? "artwork" : "")">
                    <header>
                        <h2>
                            <a href="/" class="mobile-only">&#9776;</a>
                            \(category.name.htmlEscaped)
                        </h2>
                        <h3>Web Beta</h3>
                    </header>
                    <div>
                        \(spritesHTML(for: category, sprites: sprites))
                    </div>
                    <a class="app-promo" href="https://apps.apple.com/app/sprite-catalog/id1560692872" target="_blank">
                        <picture>
                            <source srcset="/global/app_promo_dark.png 2x" media="(prefers-color-scheme: dark)">
                            <img srcset="/global/app_promo.png 2x">
                        </picture>
                    </a>
                </section>
            </section>
            <dialog id="modal" class="sheet">
                <div class="title-bar">
                    <h3 id="sprite-title">Sprite Title</h3>
                    <div>
                        <a title="Not Available on Web" class="disabled">
                            <img srcset="/global/plus_icon_3x.png 3x">
                        </a>
                        <a title="Not Available on Web" class="disabled">
                            <img srcset="/global/recolor_icon_3x.png 3x">
                        </a>
                        <a onclick="closeSprite()">Close</a>
                    </div>
                </div>
                <img id="sprite-preview" src="/global/animals.png">
                <p>Artist: <a id="artist-link" target="_blank">Artist Name</a></p>
                <p>Licence: <a id="licence-link" target="_blank">Licence</a></p>
                <div>
                    <a download="Sprite" id="download" class="button filled">Download</a>
                    <a id="open-sp" class="button">Edit in Sprite Pencil</a>
                    <a id="share" class="button">Share</a>
                </div>
            </dialog>
            <footer>
                <section class="content">
                    <p class="secondary">Copyright &#169; 256 Arts Inc. All rights reserved.</p>
                    <a href="https://www.256arts.com/spritecatalog/">Website</a>
                    <a href="/api/">API</a>
                    <a href="https://www.256arts.com/contact/">Contact</a>
                </section>
            </footer>
            <script async src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
            <script async src="/global/script.js"></script>
        </body>
    </html>
    """
}

// MARK: - Run

let arguments = Array(CommandLine.arguments.dropFirst()).filter { !$0.hasSuffix("GenerateWebsite.swift") }
let copiesImages = !arguments.contains("--no-images")
let outputPath = arguments.first(where: { !$0.hasPrefix("--") })

let scriptURL = URL(fileURLWithPath: CommandLine.arguments.first(where: { $0.hasSuffix("GenerateWebsite.swift") }) ?? "Scripts/GenerateWebsite.swift").standardizedFileURL
let repoURL = scriptURL.deletingLastPathComponent().deletingLastPathComponent()
let catalogURL = repoURL.appendingPathComponent("Sprite Catalog/ZCatalog.json")
let spritesAssetsURL = repoURL.appendingPathComponent("Sprite Catalog/Assets.xcassets/Sprites")
let outputURL = outputPath.map { URL(fileURLWithPath: $0) } ?? repoURL.appendingPathComponent("Website")

let fileManager = FileManager.default

guard let data = try? Data(contentsOf: catalogURL) else {
    print("error: could not read \(catalogURL.path)")
    exit(1)
}
let allSprites: [CatalogSprite]
do {
    allSprites = try JSONDecoder().decode([CatalogSprite].self, from: data)
} catch {
    print("error: could not decode ZCatalog.json — \(error)")
    exit(1)
}

var usedImageNames: Set<String> = []

for category in categories {
    let sprites = allSprites.filter { $0.tags.contains(category.name) && !$0.isAnimated }
    let directoryURL = outputURL.appendingPathComponent(category.slug, isDirectory: true)
    try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    let pageURL = directoryURL.appendingPathComponent("index.html")
    do {
        try pageHTML(for: category, sprites: sprites).write(to: pageURL, atomically: true, encoding: .utf8)
    } catch {
        print("error: could not write \(pageURL.path) — \(error)")
        exit(1)
    }
    usedImageNames.formUnion(sprites.compactMap { $0.primaryVariant?.imageName })
    print("\(category.slug)/index.html — \(sprites.count) sprites")
}

if copiesImages {
    let imagesURL = outputURL.appendingPathComponent("sprite", isDirectory: true)
    try? fileManager.createDirectory(at: imagesURL, withIntermediateDirectories: true)
    var copied = 0
    var missing: [String] = []
    for imageName in usedImageNames.sorted() {
        let sourceURL = spritesAssetsURL
            .appendingPathComponent("\(imageName).imageset", isDirectory: true)
            .appendingPathComponent("\(imageName).png")
        guard fileManager.fileExists(atPath: sourceURL.path) else {
            missing.append(imageName)
            continue
        }
        let destinationURL = imagesURL.appendingPathComponent("\(imageName).png")
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            copied += 1
        } catch {
            missing.append(imageName)
        }
    }
    print("sprite/ — \(copied) images copied")
    if !missing.isEmpty {
        print("warning: \(missing.count) images missing from the asset catalog: \(missing.prefix(10).joined(separator: ", "))\(missing.count > 10 ? "…" : "")")
    }
}

print("Done. Output: \(outputURL.path)")

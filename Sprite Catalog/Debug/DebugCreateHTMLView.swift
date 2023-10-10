//
//  DebugHTMLGenerator.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-07-05.
//

#if DEBUG
import SwiftUI

struct DebugCreateHTMLView: View {
    
    @State var category: SpriteSet.Tag = .peopleAnimal
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Category", selection: $category) {
                    ForEach(SpriteImporter.categories) { category in
                        Text(category.rawValue)
                            .tag(category)
                    }
                }
                .controlSize(.large)
                Button("Export HTML") {
                    exportHTML(createPageHTML())
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Create HTML Pages")
        }
    }
    
    func createSpritesHTML() -> String {
        let sprites = SpriteSet.allSprites.filter({
            $0.tags.contains(category) &&
            ($0.tiles[0].variants[0].frameCount ?? 1) == 1
        })
        var html = ""
        for sprite in sprites {
            html.append(
                """
                <a title="\(sprite.name) (\(sprite.licence.rawValue))" onclick="showSprite('\(sprite.name)', '\(sprite.id)', '\(sprite.artist.name)', '\(sprite.licence.rawValue)')">
                    <img src="/sprite/\(sprite.tiles[0].variants[0].imageName).png" loading="lazy" alt="\(sprite.name)">
                </a>
                
                """)
        }
        return html
    }
    
    func createPageHTML() -> String {
        var html =
"""
<html>
    <head>
        <link rel="shortcut icon" href="/global/favicon.ico" type="image/x-icon">
        <link rel="apple-touch-icon" href="/apple-touch-icon.png">
        <link rel="stylesheet" href="/global/style.css">
        <link rel="stylesheet" href="page.css">
        <title>{category} - Sprite Catalog</title>
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
        <meta name="theme-color" content="#fff">
        <meta name="og:image" content="/global/opengraph.png">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="keywords" content="{category}, game, developer, iphone, ipad, mac, iOS, iPadOS, macOS, sprite, pixel, art, pencil, app">
        <meta name="description" content="Collections of {category} downloadable (many free) pixel art assets.">
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
                <a href="/peopleandanimals/" {category1Selected}>
                    <img src="/global/animals.png">
                    People & Animals
                </a>
                <a href="/food/" {category2Selected}>
                    <img src="/global/food.png">
                    Food
                </a>
                <a href="/tools/" {category3Selected}>
                    <img src="/global/tools.png">
                    Weapons & Tools
                </a>
                <a href="/clothing/" {category4Selected}>
                    <img src="/global/clothing.png">
                    Clothing
                </a>
                <a href="/treasure/" {category5Selected}>
                    <img src="/global/treasure.png">
                    Treasure
                </a>
                <a href="/items/" {category6Selected}>
                    <img src="/global/items.png">
                    Misc. Items
                </a>
                <a href="/nature/" {category7Selected}>
                    <img src="/global/nature.png">
                    Nature
                </a>
                <a href="/objects/" {category8Selected}>
                    <img src="/global/objects.png">
                    Objects
                </a>
                <a href="/effects/" {category9Selected}>
                    <img src="/global/effects.png">
                    Effects
                </a>
                <a href="/interface/" {category10Selected}>
                    <img src="/global/interface.png">
                    Interface
                </a>
                <a href="/tiles/" {category11Selected}>
                    <img src="/global/tiles.png">
                    Tiles
                </a>
                <a href="/artwork/" {category12Selected}>
                    <img src="/global/artwork.png">
                    Artwork
                </a>
                <h4>Library</h4>
                <a title="Not Available on Web" class="disabled">
                    <img src="/global/folder.png">
                    My Collection
                </a>
                <a class="donate" href="https://www.patreon.com/jaydenirwin/" target="_blank">
                    Help keep this website running
                    <div class="button">Support</div>
                </a>
                <div class="footer">
                    <a href="https://form.jotform.com/211994359527266" target="_blank">Submit Your Sprites</a>
                </div>
            </section>
            <section class="grid {artwork-class}">
                <header>
                    <h2>
                        <a href="/" class="mobile-only">&#9776;</a>
                        {category}
                    </h2>
                    <h3>Web Beta</h3>
                </header>
                <div>
                    {sprites}
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
                <p class="secondary">Copyright &#169; Jayden Irwin. All rights reserved.</p>
                <a href="https://www.jaydenirwin.com/spritecatalog/">Website</a>
                <a href="/api/">API</a>
                <a href="https://www.jaydenirwin.com/contact/">Contact</a>
            </section>
        </footer>
        <script async src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
        <script async src="/global/script.js"></script>
    </body>
</html>
"""
        html = html
            .replacingOccurrences(of: "{artwork-class}", with: category == .artwork ? "artwork" : "")
            .replacingOccurrences(of: "{category}", with: category.rawValue)
            .replacingOccurrences(of: "{sprites}", with: createSpritesHTML())
            .replacingOccurrences(of: "{category1Selected}", with: category == .peopleAnimal ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category2Selected}", with: category == .food ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category3Selected}", with: category == .weaponTool ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category4Selected}", with: category == .clothing ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category5Selected}", with: category == .treasure ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category6Selected}", with: category == .miscItem ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category7Selected}", with: category == .nature ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category8Selected}", with: category == .object ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category9Selected}", with: category == .effect ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category10Selected}", with: category == .interface ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category11Selected}", with: category == .tile ? "class=\"selected\"" : "")
            .replacingOccurrences(of: "{category12Selected}", with: category == .artwork ? "class=\"selected\"" : "")
        return html
    }
    
    func exportHTML(_ html: String) {
        do {
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("index").appendingPathExtension("html")
            try html.write(to: fileURL, atomically: false, encoding: .utf8)
            let exportVC = UIDocumentPickerViewController(forExporting: [fileURL])
            if let rootVC = UIApplication.shared.windows.first?.rootViewController?.presentedViewController {
                rootVC.present(exportVC, animated: true, completion: nil)
            }
        } catch {
            print(error)
        }
    }
    
}

struct DebugHTMLGenerator_Previews: PreviewProvider {
    static var previews: some View {
        DebugCreateHTMLView()
    }
}
#endif

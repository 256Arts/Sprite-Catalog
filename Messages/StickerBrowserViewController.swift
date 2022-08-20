//
//  StickerBrowserViewController.swift
//  Sprite Catalog Messages MessagesExtension
//
//  Created by Jayden Irwin on 2021-08-09.
//

import Messages

class StickerBrowserViewController: MSStickerBrowserViewController {
    
    static let stickerMaxSize: CGFloat = 206.0 * 3.0 // @3x
    
    var spriteURLs: [URL] = []
    var stickerURLs: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: messagesAppGroupID) else { return }
        let properties: [URLResourceKey] = [.localizedNameKey, .creationDateKey, .localizedTypeDescriptionKey]
        do {
            spriteURLs = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: properties, options: .skipsHiddenFiles)
            createStickerImages()
        } catch {
            print(error)
        }
    }
    
    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        stickerURLs.count
    }
    
    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        try! MSSticker(contentsOfFileURL: stickerURLs[index], localizedDescription: "Pixel Art Sprite")
    }
    
    func createStickerImages() {
        guard let stickerImageDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        stickerURLs.removeAll()
        
        for spriteURL in spriteURLs {
            guard let sprite = UIImage(contentsOfFile: spriteURL.path) else { continue }
            
            // Find scale
            var stickerWidth: CGFloat
            var stickerHeight: CGFloat
            if sprite.size.height <= sprite.size.width {
                stickerWidth = StickerBrowserViewController.stickerMaxSize - (StickerBrowserViewController.stickerMaxSize.truncatingRemainder(dividingBy: sprite.size.width))
                if stickerWidth == 0 {
                    stickerWidth = StickerBrowserViewController.stickerMaxSize
                }
                let scale = stickerWidth / sprite.size.width
                stickerHeight = sprite.size.height * scale
            } else {
                stickerHeight = StickerBrowserViewController.stickerMaxSize - (StickerBrowserViewController.stickerMaxSize.truncatingRemainder(dividingBy: sprite.size.height))
                if stickerHeight == 0 {
                    stickerHeight = StickerBrowserViewController.stickerMaxSize
                }
                let scale = stickerHeight / sprite.size.height
                stickerWidth = sprite.size.width * scale
            }
            let stickerSize = CGSize(width: max(1, stickerWidth), height: max(1, stickerHeight))
            
            // Render
            let renderer = UIGraphicsImageRenderer(size: stickerSize)
            let pngData = renderer.pngData { context in
                context.cgContext.interpolationQuality = .none
                sprite.draw(in: CGRect(origin: .zero, size: stickerSize))
            }
            let stickerURL = stickerImageDirectory.appendingPathComponent(spriteURL.lastPathComponent).appendingPathExtension("png")
            do {
                try pngData.write(to: stickerURL, options: .atomic)
                stickerURLs.append(stickerURL)
            } catch { print(error) }
        }
    }
    
}

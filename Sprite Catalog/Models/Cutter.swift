import CoreGraphics

struct PixelPoint {
    var x: Int
    var y: Int
}
struct PixelSize {
    var width: Int
    var height: Int
}

struct Cutter {
    
    enum CutError: Error {
        case noInput
    }
    
    var image: CGImage?
    var spriteSize = PixelSize(width: 16, height: 16)
    var spacing = 0
    
    var spriteCounts: PixelPoint {
        get {
            guard let image = image, spriteSize.width > 0, spriteSize.height > 0, spacing >= 0 else { return PixelPoint(x: 0, y: 0) }
            let cols = (image.width + spacing) / (spriteSize.width + spacing)
            let rows = (image.height + spacing) / (spriteSize.height + spacing)
            return PixelPoint(x: cols, y: rows)
        }
        set {
            guard let image = image, newValue.x > 0, newValue.y > 0 else { return }
            spriteSize.width = ((image.width + spacing) / newValue.x) - spacing
            spriteSize.height = ((image.height + spacing) / newValue.y) - spacing
        }
    }
    
    var canCut: Bool {
        image != nil && spriteSize.width > 0 && spriteSize.height > 0 && spriteCounts.x > 0 && spriteCounts.y > 0
    }
    
    func cut() throws -> [CGImage] {
        guard let image = image else {
            throw CutError.noInput
        }
        var sprites: [CGImage] = []
        for row in 0..<spriteCounts.y {
            for col in 0..<spriteCounts.x {
                let origin = PixelPoint(x: col * (spriteSize.width + spacing), y: row * (spriteSize.height + spacing))
                if let spriteImage = image.cropping(to: CGRect(x: origin.x, y: origin.y, width: spriteSize.width, height: spriteSize.height)) {
                    sprites.append(spriteImage)
                }
            }
        }
        return sprites
    }
    
}

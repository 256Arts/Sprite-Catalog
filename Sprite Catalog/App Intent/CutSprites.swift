//
//  CutSprites.swift
//  Sprite Cutter
//
//  Created by Jayden Irwin on 2023-10-08.
//

import UIKit
import UniformTypeIdentifiers
import AppIntents

struct CutSprites: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    
    enum CutError: LocalizedError {
        case failedToLoadImage, imageTooLarge, failedToReadSpriteSize, failedToCut
        
        var errorDescription: String? {
            switch self {
            case .failedToLoadImage:
                return "Failed to load image"
            case .imageTooLarge:
                return "Input image too large. (Max: 512px x 512px)"
            case .failedToReadSpriteSize:
                return "Could not read sprite size"
            case .failedToCut:
                return "Failed to cut sprites"
            }
        }
    }
    
    static let intentClassName = "CutSpritesIntent"

    static var title: LocalizedStringResource = "Cut Sprites"
    static var description = IntentDescription("Cut a spritesheet image into multiple sprites")

    @Parameter(title: "Image")
    var image: IntentFile?

    @Parameter(title: "Width", default: 16)
    var spriteWidth: Int?

    @Parameter(title: "Height", default: 16)
    var spriteHeight: Int?

    static var parameterSummary: some ParameterSummary {
        Summary("Cut \(\.$image) into \(\.$spriteWidth) by \(\.$spriteHeight) sprites")
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$image, \.$spriteWidth, \.$spriteHeight)) { image, spriteWidth, spriteHeight in
            DisplayRepresentation(
                title: "Cut \(image!) into \(spriteWidth!) by \(spriteHeight!) sprites",
                subtitle: "Cut a spritesheet image into multiple sprites"
            )
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
        guard let data = image?.data, let image = UIImage(data: data) else {
            throw CutError.failedToLoadImage
        }
        let maxImageSize = 512
        guard Int(image.size.width) <= maxImageSize, Int(image.size.height) <= maxImageSize else {
            throw CutError.imageTooLarge
        }
        guard let width = spriteWidth, let height = spriteHeight else {
            throw CutError.failedToReadSpriteSize
        }
        var cutter = Cutter()
        cutter.image = image
        cutter.spriteSize = PixelSize(width: width, height: height)
        guard let sprites = try? cutter.cut() else {
            throw CutError.failedToCut
        }
        var files: [IntentFile] = []
        for sprite in sprites {
            if let spriteData = sprite.pngData() {
                files.append(IntentFile(data: spriteData, filename: "Sprite", type: UTType.png))
            }
        }
        return .result(value: files)
    }
}

fileprivate extension IntentDialog {
    static var imageParameterPrompt: Self {
        "What image do you want to cut?"
    }
    static var spriteWidthParameterPrompt: Self {
        "What is the sprites widths?"
    }
    static var spriteHeightParameterPrompt: Self {
        "What is the sprites heights?"
    }
    static var responseSuccess: Self {
        "Sprites cut"
    }
    static func responseFailure(error: String) -> Self {
        "\(error)"
    }
}


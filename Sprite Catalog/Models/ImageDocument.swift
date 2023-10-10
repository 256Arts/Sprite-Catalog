//
//  ImageDocument.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-12-08.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageDocument: FileDocument {
    
    enum FileWrapperError: Error {
        case failedToGetPNGData
    }
    
    static var readableContentTypes: [UTType] { [.jpeg, .png, .tiff] }
    
    let image: UIImage
    let filename: String
    
    init(image: UIImage, filename: String) {
        self.image = image
        self.filename = filename
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let image = UIImage(data: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.image = image
        self.filename = configuration.file.filename ?? "Sprite"
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = image.pngData() else {
            throw FileWrapperError.failedToGetPNGData
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.filename = filename
        return wrapper
    }
    
}

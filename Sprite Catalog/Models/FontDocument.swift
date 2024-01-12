//
//  FontDocument.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2024-01-10.
//

import SwiftUI
import UniformTypeIdentifiers

struct FontDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [] }
    static var writableContentTypes: [UTType] { [.init(exportedAs: "otf"), .init(exportedAs: "ttf")] }
    
    let font: FontFamily.Font
    let filename: String
    
    init(font: FontFamily.Font, filename: String) {
        self.font = font
        self.filename = filename
    }
    
    init(configuration: ReadConfiguration) throws {
        throw CocoaError(.fileReadUnknown)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        try FileWrapper(url: font.fileURL)
    }
    
}

import SwiftUI
import UniformTypeIdentifiers

struct ImageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.jpeg, .png, .tiff] }
    
    let image: CGImage
    let filename: String
    
    init(image: CGImage, filename: String) {
        self.image = image
        self.filename = filename
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let image = CGImage.loading(data: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.image = image
        self.filename = configuration.file.filename ?? "Sprite"
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = FileWrapper(regularFileWithContents: try image.pngData())
        wrapper.filename = filename
        return wrapper
    }
    
}
